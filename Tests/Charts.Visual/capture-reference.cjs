/* Reference runner; never a dependency of the Delphi runtime. */
const fs = require('node:fs');
const path = require('node:path');
const crypto = require('node:crypto');
const { chromium } = require('playwright');
(async () => {
  const [fixtureFile, libraryFile, outputDir] = process.argv.slice(2);
  if (!outputDir) throw new Error('Usage: node capture-reference.cjs fixtures.json echarts.min.js output');
  const fixtures = JSON.parse(fs.readFileSync(fixtureFile, 'utf8'));
  const env=fixtures.environment;
  const sha256=crypto.createHash('sha256').update(fs.readFileSync(libraryFile)).digest('hex');
  if (env && require('playwright/package.json').version!==env.playwright) throw new Error('Unexpected Playwright version');
  if (env && sha256!==env.librarySha256) throw new Error('Unexpected ECharts bundle hash');
  fs.mkdirSync(outputDir, {recursive:true});
  const browser = await chromium.launch({headless:true});
  try {
    if(env && browser.version()!==env.chromium) throw new Error('Unexpected Chromium version');
    const page = await browser.newPage({viewport: fixtures.viewport, deviceScaleFactor:1, locale:'en-US', timezoneId:'UTC'});
    await page.setContent('<html><body style="margin:0;background:white"><div id="chart" style="width:100vw;height:100vh"></div></body></html>');
    await page.addScriptTag({path:path.resolve(libraryFile)});
    const version = await page.evaluate(() => echarts.version);
    if (version !== fixtures.referenceVersion) throw new Error(`Wrong reference: ${version}`);
    const report = {version, browser:browser.version(), sha256, environment:env, cases:[]};
    for (const c of fixtures.cases) {
      const result = await page.evaluate(async c => {
        if (window.chart && typeof window.chart.dispose === 'function') window.chart.dispose();
        window.chart = echarts.init(document.getElementById('chart'), {textStyle:{fontFamily:'Arial'}}, {renderer:'canvas', devicePixelRatio:1});
        chart.setOption(c.option, {notMerge:true});
        await document.fonts.ready;
        await new Promise(requestAnimationFrame);
        const series = chart.getModel().getSeries().map(s => {
          const d=s.getData();
          const points=d.getLayout('points');
          return {name:s.name,type:s.subType,items:Array.from({length:d.count()},(_,i)=>({name:d.getName(i),layout:d.getItemLayout(i),point:points?Array.from(points.slice(i*2,i*2+2)):undefined}))};
        });
        const axes={};
        for(const key of ['xAxis','yAxis']) {
          const model=chart.getModel().getComponent(key);
          if(model) axes[key]={ticks:model.axis.scale.getTicks().map(t=>({value:t.value,label:model.axis.scale.getLabel(t)}))};
        }
        const texts=chart.getZr().storage.getDisplayList(true).filter(e=>e.type==='tspan' && !e.ignore && e.style.text).map(e=>{
          const r=e.getBoundingRect().clone();r.applyTransform(e.getComputedTransform());
          let visible=r.x<chart.getWidth() && r.y<chart.getHeight() && r.x+r.width>0 && r.y+r.height>0;
          for(const clip of e.__clipPaths||[]) {
            const b=clip.getBoundingRect().clone();b.applyTransform(clip.getComputedTransform());
            if(!r.intersect(b)) visible=false;
          }
          return {text:e.style.text,x:r.x,y:r.y,width:r.width,height:r.height,font:e.style.font,visible};
        }).filter(e=>e.visible);
        return {id:c.id,series,axes,texts,option:chart.getOption()};
      }, c);
      await page.screenshot({path:path.join(outputDir, `${c.id}.png`)});
      fs.writeFileSync(path.join(outputDir, `${c.id}.json`), JSON.stringify(result,null,2));
      report.cases.push({id:c.id,status:'captured'});
    }
    fs.writeFileSync(path.join(outputDir,'manifest.json'), JSON.stringify(report,null,2));
    console.log(JSON.stringify({version,captured:report.cases.length,outputDir}));
  } finally {await browser.close();}
})().catch(e=>{console.error(e);process.exitCode=1;});
