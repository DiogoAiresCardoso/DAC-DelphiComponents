from pathlib import Path
p=Path('Source/Controls/DAC.Components.Controls.DBGrid.pas');s=p.read_bytes().replace(b'dgColumnResize, dgColumnMove,',b'dgColumnResize,');p.write_bytes(s)
