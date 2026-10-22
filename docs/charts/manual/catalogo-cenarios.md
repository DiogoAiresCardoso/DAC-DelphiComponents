# Catálogo de cenários e cobertura explícita

[Índice](../README.md) · [Interpretação dos testes](08-testes-evidencias.md)

Fonte executável: [Tests/Charts.Visual/fixtures.json](../../../Tests/Charts.Visual/fixtures.json); SHA-256 `1cc74321269b965b25f7c03dae5ea1243fd88e972c78c1b5c73fa179659c49a2`.

Presença de uma chave na fixture não prova assert específico, alternativas suficientes ou efeito visual.
Ausência de uma chave pode exercitar default implicitamente, mas não prova que esse default foi comparado.

| ID | Título | Fase | Famílias |
| --- | --- | --- | --- |
| C01 | Barra e linha compartilham categorias | core | bar, line |
| C02 | X numérico irregular | core | line |
| C03 | X temporal irregular em UTC | core | line |
| C04 | Limites Y explícitos | core | line |
| C05 | Duas categorias sem duplicação | core | bar |
| C06 | Área interrompida por valor nulo | core | line |
| C07 | Barras positivas e negativas | core | bar |
| C08 | Rosca proporcional | core | pie |
| C09 | Pizza soma zero com default oficial | core | pie |
| C10 | Pizza soma zero sem setores fictícios | core | pie |
| C11 | Dataset orientado por colunas | core | bar, line |
| C12 | Dataset orientado por linhas | core | bar, line |
| C13 | Empilhamento mantém sinais separados | extension | bar |
| C14 | Barras horizontais | extension | bar |
| V01 | Titulos e labels | visual | bar, line |
| V02 | Rich text nativo | visual | bar |
| V03 | Gradiente e sombra | visual | bar |
| V04 | Legenda paginada | visual | bar |
| V05 | Area suave com lacuna | visual | line |
| V06 | Rosca com labels externos | visual | pie |
| V07 | Texto rotacionado | visual | bar, line |
| V08 | Dados vazios | visual | bar |
| V09 | Um ponto e limites fixos | visual | line |
| V10 | Valores iguais | visual | bar |
| V11 | Linha suavizada | visual | line |
| V12 | Area em degraus | visual | line |
| V13 | Eixos invertidos | visual | bar |
| V14 | Linha conectando NULL | visual | line |
| V15 | Texto longo e acentos | visual | bar |

## Caminhos explicitamente presentes

| Caminho | Casos | Valores distintos explícitos |
| --- | --- | --- |
| `animation` | C01, C02, C03, C04, C05, C06, C07, C08, C09, C10, C11, C12, C13, C14, V01, V02, V03, V04, V05, V06, V07, V08, V09, V10, V11, V12, V13, V14, V15 | 1 |
| `dataset.dimensions` | C11 | 1 |
| `dataset.source` | C11, C12 | 2 |
| `dataset.sourceHeader` | C12 | 1 |
| `grid.bottom` | C01, C02, C03, C04, C05, C06, C07, C11, C12, C13, C14, V01, V02, V03, V04, V05, V07, V08, V09, V10, V11, V12, V13, V14, V15 | 2 |
| `grid.left` | C01, C02, C03, C04, C05, C06, C07, C11, C12, C13, C14, V01, V02, V03, V04, V05, V07, V08, V09, V10, V11, V12, V13, V14, V15 | 1 |
| `grid.outerBoundsMode` | C01, C02, C03, C04, C05, C06, C07, C11, C12, C13, C14, V01, V02, V03, V04, V05, V07, V08, V09, V10, V11, V12, V13, V14, V15 | 1 |
| `grid.right` | C01, C02, C03, C04, C05, C06, C07, C11, C12, C13, C14, V01, V02, V03, V04, V05, V07, V08, V09, V10, V11, V12, V13, V14, V15 | 1 |
| `grid.top` | C01, C02, C03, C04, C05, C06, C07, C11, C12, C13, C14, V01, V02, V03, V04, V05, V07, V08, V09, V10, V11, V12, V13, V14, V15 | 2 |
| `legend.itemGap` | V04 | 1 |
| `legend.itemWidth` | V04 | 1 |
| `legend.left` | V01, V04 | 2 |
| `legend.top` | V01, V04 | 1 |
| `legend.type` | V04 | 1 |
| `series[].areaStyle` | C06, V05, V12 | 1 |
| `series[].barMinHeight` | C07 | 1 |
| `series[].barWidth` | C01, V01, V02, V03, V07 | 1 |
| `series[].center` | C08, V06 | 1 |
| `series[].connectNulls` | C06, V05, V14 | 2 |
| `series[].data` | C01, C02, C03, C04, C05, C06, C07, C08, C09, C10, C13, C14, V01, V02, V03, V04, V05, V06, V07, V08, V09, V10, V11, V12, V13, V14, V15 | 28 |
| `series[].encode.x` | C11 | 1 |
| `series[].encode.y` | C11 | 2 |
| `series[].itemStyle.borderRadius` | V03 | 1 |
| `series[].itemStyle.color.colorStops` | V03 | 1 |
| `series[].itemStyle.color.type` | V03 | 1 |
| `series[].itemStyle.color.x` | V03 | 1 |
| `series[].itemStyle.color.x2` | V03 | 1 |
| `series[].itemStyle.color.y` | V03 | 1 |
| `series[].itemStyle.color.y2` | V03 | 1 |
| `series[].itemStyle.shadowBlur` | V03 | 1 |
| `series[].itemStyle.shadowColor` | V03 | 1 |
| `series[].itemStyle.shadowOffsetX` | V03 | 1 |
| `series[].itemStyle.shadowOffsetY` | V03 | 1 |
| `series[].label.color` | V01 | 2 |
| `series[].label.formatter` | V01, V02, V06, V15 | 5 |
| `series[].label.overflow` | V15 | 1 |
| `series[].label.position` | V01, V02, V06 | 3 |
| `series[].label.rich.name.color` | V02 | 1 |
| `series[].label.rich.name.fontWeight` | V02 | 1 |
| `series[].label.rich.value.backgroundColor` | V02 | 1 |
| `series[].label.rich.value.borderRadius` | V02 | 1 |
| `series[].label.rich.value.color` | V02 | 1 |
| `series[].label.rich.value.fontSize` | V02 | 1 |
| `series[].label.rich.value.padding` | V02 | 1 |
| `series[].label.show` | C08, C09, C10, V01, V02, V05, V06, V15 | 2 |
| `series[].label.width` | V15 | 1 |
| `series[].labelLine.show` | V06 | 1 |
| `series[].name` | C01, C11, C13, V01, V02, V03, V04, V07 | 18 |
| `series[].radius` | C08, C09, C10, V06 | 2 |
| `series[].seriesLayoutBy` | C11, C12 | 2 |
| `series[].showEmptyCircle` | C10 | 1 |
| `series[].smooth` | V05, V11, V14 | 1 |
| `series[].stack` | C13 | 1 |
| `series[].stackStrategy` | C13 | 1 |
| `series[].step` | V12 | 1 |
| `series[].stillShowZeroSum` | C10 | 1 |
| `series[].type` | C01, C02, C03, C04, C05, C06, C07, C08, C09, C10, C11, C12, C13, C14, V01, V02, V03, V04, V05, V06, V07, V08, V09, V10, V11, V12, V13, V14, V15 | 3 |
| `title.left` | V01 | 1 |
| `title.subtext` | V01 | 1 |
| `title.text` | V01, V15 | 2 |
| `title.textStyle.color` | V01 | 1 |
| `title.textStyle.fontFamily` | V01 | 1 |
| `title.textStyle.fontSize` | V01, V15 | 1 |
| `title.top` | V01 | 1 |
| `tooltip.trigger` | C08, V06 | 1 |
| `useUTC` | C03 | 1 |
| `xAxis.axisLabel.fontSize` | V07 | 1 |
| `xAxis.axisLabel.interval` | C01, C04, C05, C06, C07, C13, V01, V02, V03, V04, V05, V07 | 1 |
| `xAxis.axisLabel.rotate` | V07 | 1 |
| `xAxis.boundaryGap` | C01, C04, C05, C06, C07, C11, C12, C13, V01, V02, V03, V04, V05, V07 | 1 |
| `xAxis.data` | C01, C04, C05, C06, C07, C13, V01, V02, V03, V04, V05, V07, V08, V09, V10, V11, V12, V13, V14, V15 | 8 |
| `xAxis.inverse` | V13 | 1 |
| `xAxis.max` | C02, C03, C14 | 3 |
| `xAxis.min` | C02, C03, C14 | 2 |
| `xAxis.type` | C01, C02, C03, C04, C05, C06, C07, C11, C12, C13, C14, V01, V02, V03, V04, V05, V07, V08, V09, V10, V11, V12, V13, V14, V15 | 3 |
| `yAxis.axisLabel.interval` | C14 | 1 |
| `yAxis.boundaryGap` | C14 | 1 |
| `yAxis.data` | C14 | 1 |
| `yAxis.inverse` | V13 | 1 |
| `yAxis.max` | C01, C02, C03, C04, C05, C06, C07, C11, C12, C13, V01, V02, V03, V04, V05, V07, V08, V09, V10, V11, V12, V13, V14, V15 | 5 |
| `yAxis.min` | C01, C02, C03, C04, C05, C06, C07, C11, C12, C13, V01, V02, V03, V04, V05, V07, V08, V09, V10, V11, V12, V13, V14, V15 | 3 |
| `yAxis.type` | C01, C02, C03, C04, C05, C06, C07, C11, C12, C13, C14, V01, V02, V03, V04, V05, V07, V08, V09, V10, V11, V12, V13, V14, V15 | 2 |

## Conteúdo integral por cenário

Dados e opções canônicos permanecem nas fixtures; expectativas abaixo são metadados de teste, não API.

### C01 — Barra e linha compartilham categorias

```json
{
  "id": "C01",
  "title": "Barra e linha compartilham categorias",
  "phase": "core",
  "option": {
    "animation": false,
    "grid": {
      "left": 80,
      "right": 40,
      "top": 40,
      "bottom": 60,
      "outerBoundsMode": "none"
    },
    "xAxis": {
      "type": "category",
      "boundaryGap": true,
      "data": [
        "A",
        "B",
        "C"
      ],
      "axisLabel": {
        "interval": 0
      }
    },
    "yAxis": {
      "type": "value",
      "min": 0,
      "max": 40
    },
    "series": [
      {
        "name": "Barra",
        "type": "bar",
        "barWidth": 40,
        "data": [
          10,
          20,
          30
        ]
      },
      {
        "name": "Linha",
        "type": "line",
        "data": [
          10,
          20,
          30
        ]
      }
    ]
  },
  "expected": {
    "categoryCentersNormalized": [
      0.16666666666666666,
      0.5,
      0.8333333333333334
    ],
    "sameXForBothSeries": true
  }
}
```

### C02 — X numérico irregular

```json
{
  "id": "C02",
  "title": "X numérico irregular",
  "phase": "core",
  "option": {
    "animation": false,
    "grid": {
      "left": 80,
      "right": 40,
      "top": 40,
      "bottom": 60,
      "outerBoundsMode": "none"
    },
    "xAxis": {
      "type": "value",
      "min": 0,
      "max": 100
    },
    "yAxis": {
      "type": "value",
      "min": 0,
      "max": 40
    },
    "series": [
      {
        "type": "line",
        "data": [
          [
            0,
            10
          ],
          [
            1,
            20
          ],
          [
            100,
            30
          ]
        ]
      }
    ]
  },
  "expected": {
    "xDomain": [
      0,
      100
    ],
    "normalizedX": [
      0,
      0.01,
      1
    ]
  }
}
```

### C03 — X temporal irregular em UTC

```json
{
  "id": "C03",
  "title": "X temporal irregular em UTC",
  "phase": "core",
  "option": {
    "animation": false,
    "grid": {
      "left": 80,
      "right": 40,
      "top": 40,
      "bottom": 60,
      "outerBoundsMode": "none"
    },
    "xAxis": {
      "type": "time",
      "min": 1767225600000,
      "max": 1768089600000
    },
    "yAxis": {
      "type": "value",
      "min": 0,
      "max": 40
    },
    "series": [
      {
        "type": "line",
        "data": [
          [
            1767225600000,
            10
          ],
          [
            1767312000000,
            20
          ],
          [
            1768089600000,
            30
          ]
        ]
      }
    ],
    "useUTC": true
  },
  "expected": {
    "timestamps": [
      1767225600000,
      1767312000000,
      1768089600000
    ],
    "elapsedDays": [
      0,
      1,
      10
    ],
    "normalizedX": [
      0,
      0.1,
      1
    ]
  }
}
```

### C04 — Limites Y explícitos

```json
{
  "id": "C04",
  "title": "Limites Y explícitos",
  "phase": "core",
  "option": {
    "animation": false,
    "grid": {
      "left": 80,
      "right": 40,
      "top": 40,
      "bottom": 60,
      "outerBoundsMode": "none"
    },
    "xAxis": {
      "type": "category",
      "boundaryGap": true,
      "data": [
        "A",
        "B"
      ],
      "axisLabel": {
        "interval": 0
      }
    },
    "yAxis": {
      "type": "value",
      "min": 0,
      "max": 100
    },
    "series": [
      {
        "type": "line",
        "data": [
          20,
          80
        ]
      }
    ]
  },
  "expected": {
    "yDomain": [
      0,
      100
    ],
    "normalizedYFromBottom": [
      0.2,
      0.8
    ],
    "automaticPadding": false
  }
}
```

### C05 — Duas categorias sem duplicação

```json
{
  "id": "C05",
  "title": "Duas categorias sem duplicação",
  "phase": "core",
  "option": {
    "animation": false,
    "grid": {
      "left": 80,
      "right": 40,
      "top": 40,
      "bottom": 60,
      "outerBoundsMode": "none"
    },
    "xAxis": {
      "type": "category",
      "boundaryGap": true,
      "data": [
        "A",
        "B"
      ],
      "axisLabel": {
        "interval": 0
      }
    },
    "yAxis": {
      "type": "value",
      "min": 0,
      "max": 30
    },
    "series": [
      {
        "type": "bar",
        "data": [
          10,
          20
        ]
      }
    ]
  },
  "expected": {
    "axisLabels": [
      "A",
      "B"
    ],
    "categoryCentersNormalized": [
      0.25,
      0.75
    ]
  }
}
```

### C06 — Área interrompida por valor nulo

```json
{
  "id": "C06",
  "title": "Área interrompida por valor nulo",
  "phase": "core",
  "option": {
    "animation": false,
    "grid": {
      "left": 80,
      "right": 40,
      "top": 40,
      "bottom": 60,
      "outerBoundsMode": "none"
    },
    "xAxis": {
      "type": "category",
      "boundaryGap": true,
      "data": [
        "A",
        "B",
        "C",
        "D"
      ],
      "axisLabel": {
        "interval": 0
      }
    },
    "yAxis": {
      "type": "value",
      "min": 0,
      "max": 50
    },
    "series": [
      {
        "type": "line",
        "areaStyle": {},
        "connectNulls": false,
        "data": [
          10,
          null,
          30,
          40
        ]
      }
    ]
  },
  "expected": {
    "validDataIndices": [
      0,
      2,
      3
    ],
    "connectedRuns": [
      [
        0
      ],
      [
        2,
        3
      ]
    ],
    "bridgeAcrossNull": false,
    "tooltipMustNotInventZero": true
  }
}
```

### C07 — Barras positivas e negativas

```json
{
  "id": "C07",
  "title": "Barras positivas e negativas",
  "phase": "core",
  "option": {
    "animation": false,
    "grid": {
      "left": 80,
      "right": 40,
      "top": 40,
      "bottom": 60,
      "outerBoundsMode": "none"
    },
    "xAxis": {
      "type": "category",
      "boundaryGap": true,
      "data": [
        "Negativo",
        "Zero",
        "Positivo"
      ],
      "axisLabel": {
        "interval": 0
      }
    },
    "yAxis": {
      "type": "value",
      "min": -30,
      "max": 40
    },
    "series": [
      {
        "type": "bar",
        "barMinHeight": 0,
        "data": [
          -20,
          0,
          30
        ]
      }
    ]
  },
  "expected": {
    "baselineValue": 0,
    "normalizedBaselineFromBottom": 0.42857142857142855,
    "normalizedEndpointsFromBottom": [
      0.14285714285714285,
      0.42857142857142855,
      0.8571428571428571
    ],
    "zeroBarValueExtent": 0
  }
}
```

### C08 — Rosca proporcional

```json
{
  "id": "C08",
  "title": "Rosca proporcional",
  "phase": "core",
  "option": {
    "animation": false,
    "tooltip": {
      "trigger": "item"
    },
    "series": [
      {
        "type": "pie",
        "center": [
          "50%",
          "50%"
        ],
        "radius": [
          50,
          100
        ],
        "label": {
          "show": false
        },
        "data": [
          {
            "name": "A",
            "value": 10
          },
          {
            "name": "B",
            "value": 30
          }
        ]
      }
    ]
  },
  "expected": {
    "radiiPixels": [
      50,
      100
    ],
    "sectorAnglesDegrees": [
      90,
      270
    ],
    "centerHit": false
  }
}
```

### C09 — Pizza soma zero com default oficial

```json
{
  "id": "C09",
  "title": "Pizza soma zero com default oficial",
  "phase": "core",
  "option": {
    "animation": false,
    "series": [
      {
        "type": "pie",
        "radius": 100,
        "label": {
          "show": false
        },
        "data": [
          {
            "name": "A",
            "value": 0
          },
          {
            "name": "B",
            "value": 0
          }
        ]
      }
    ]
  },
  "expected": {
    "resolvedStillShowZeroSum": true,
    "sectorAnglesDegrees": [
      180,
      180
    ],
    "rawValues": [
      0,
      0
    ]
  }
}
```

### C10 — Pizza soma zero sem setores fictícios

```json
{
  "id": "C10",
  "title": "Pizza soma zero sem setores fictícios",
  "phase": "core",
  "option": {
    "animation": false,
    "series": [
      {
        "type": "pie",
        "radius": 100,
        "stillShowZeroSum": false,
        "showEmptyCircle": false,
        "label": {
          "show": false
        },
        "data": [
          {
            "name": "A",
            "value": 0
          },
          {
            "name": "B",
            "value": 0
          }
        ]
      }
    ]
  },
  "expected": {
    "sectorAnglesDegrees": [
      0,
      0
    ],
    "visibleProportionalSectors": 0,
    "rawValues": [
      0,
      0
    ]
  }
}
```

### C11 — Dataset orientado por colunas

```json
{
  "id": "C11",
  "title": "Dataset orientado por colunas",
  "phase": "core",
  "option": {
    "animation": false,
    "grid": {
      "left": 80,
      "right": 40,
      "top": 40,
      "bottom": 60,
      "outerBoundsMode": "none"
    },
    "xAxis": {
      "type": "category",
      "boundaryGap": true
    },
    "yAxis": {
      "type": "value",
      "min": 0,
      "max": 40
    },
    "series": [
      {
        "type": "bar",
        "name": "Realizado",
        "seriesLayoutBy": "column",
        "encode": {
          "x": "MES",
          "y": "REAL"
        }
      },
      {
        "type": "line",
        "name": "Meta",
        "seriesLayoutBy": "column",
        "encode": {
          "x": "MES",
          "y": "META"
        }
      }
    ],
    "dataset": {
      "dimensions": [
        {
          "name": "MES",
          "type": "ordinal"
        },
        {
          "name": "REAL",
          "type": "float"
        },
        {
          "name": "META",
          "type": "float"
        }
      ],
      "source": [
        [
          "Jan",
          10,
          15
        ],
        [
          "Fev",
          20,
          25
        ],
        [
          "Mar",
          30,
          35
        ]
      ]
    }
  },
  "expected": {
    "categories": [
      "Jan",
      "Fev",
      "Mar"
    ],
    "seriesValues": {
      "Realizado": [
        10,
        20,
        30
      ],
      "Meta": [
        15,
        25,
        35
      ]
    }
  }
}
```

### C12 — Dataset orientado por linhas

```json
{
  "id": "C12",
  "title": "Dataset orientado por linhas",
  "phase": "core",
  "option": {
    "animation": false,
    "grid": {
      "left": 80,
      "right": 40,
      "top": 40,
      "bottom": 60,
      "outerBoundsMode": "none"
    },
    "xAxis": {
      "type": "category",
      "boundaryGap": true
    },
    "yAxis": {
      "type": "value",
      "min": 0,
      "max": 40
    },
    "series": [
      {
        "type": "bar",
        "seriesLayoutBy": "row"
      },
      {
        "type": "line",
        "seriesLayoutBy": "row"
      }
    ],
    "dataset": {
      "sourceHeader": true,
      "source": [
        [
          "Produto",
          "Jan",
          "Fev",
          "Mar"
        ],
        [
          "Realizado",
          10,
          20,
          30
        ],
        [
          "Meta",
          15,
          25,
          35
        ]
      ]
    }
  },
  "expected": {
    "categories": [
      "Jan",
      "Fev",
      "Mar"
    ],
    "seriesNames": [
      "Realizado",
      "Meta"
    ],
    "seriesValues": {
      "Realizado": [
        10,
        20,
        30
      ],
      "Meta": [
        15,
        25,
        35
      ]
    },
    "encodeResolution": "Mapeamento automático de dimensões, conforme dataset/seriesLayoutBy."
  }
}
```

### C13 — Empilhamento mantém sinais separados

```json
{
  "id": "C13",
  "title": "Empilhamento mantém sinais separados",
  "phase": "extension",
  "option": {
    "animation": false,
    "grid": {
      "left": 80,
      "right": 40,
      "top": 40,
      "bottom": 60,
      "outerBoundsMode": "none"
    },
    "xAxis": {
      "type": "category",
      "boundaryGap": true,
      "data": [
        "A",
        "B"
      ],
      "axisLabel": {
        "interval": 0
      }
    },
    "yAxis": {
      "type": "value",
      "min": -12,
      "max": 20
    },
    "series": [
      {
        "name": "S1",
        "type": "bar",
        "stack": "total",
        "stackStrategy": "samesign",
        "data": [
          10,
          -4
        ]
      },
      {
        "name": "S2",
        "type": "bar",
        "stack": "total",
        "stackStrategy": "samesign",
        "data": [
          5,
          -6
        ]
      }
    ]
  },
  "expected": {
    "firstSeriesBaseline": [
      0,
      0
    ],
    "secondSeriesBaseline": [
      10,
      -4
    ],
    "secondSeriesEndpoints": [
      15,
      -10
    ],
    "rawValuesUnchanged": true
  }
}
```

### C14 — Barras horizontais

```json
{
  "id": "C14",
  "title": "Barras horizontais",
  "phase": "extension",
  "option": {
    "animation": false,
    "grid": {
      "left": 80,
      "right": 40,
      "top": 40,
      "bottom": 60,
      "outerBoundsMode": "none"
    },
    "xAxis": {
      "type": "value",
      "min": 0,
      "max": 40
    },
    "yAxis": {
      "type": "category",
      "boundaryGap": true,
      "data": [
        "A",
        "B",
        "C"
      ],
      "axisLabel": {
        "interval": 0
      }
    },
    "series": [
      {
        "type": "bar",
        "data": [
          10,
          20,
          30
        ]
      }
    ]
  },
  "expected": {
    "xDomain": [
      0,
      40
    ],
    "normalizedValueEndpoints": [
      0.25,
      0.5,
      0.75
    ],
    "categoryCentersFromBottom": [
      0.16666666666666666,
      0.5,
      0.8333333333333334
    ]
  }
}
```

### V01 — Titulos e labels

```json
{
  "id": "V01",
  "title": "Titulos e labels",
  "phase": "visual",
  "option": {
    "animation": false,
    "grid": {
      "left": 80,
      "right": 40,
      "top": 85,
      "bottom": 60,
      "outerBoundsMode": "none"
    },
    "xAxis": {
      "type": "category",
      "boundaryGap": true,
      "data": [
        "A",
        "B",
        "C"
      ],
      "axisLabel": {
        "interval": 0
      }
    },
    "yAxis": {
      "type": "value",
      "min": 0,
      "max": 40
    },
    "series": [
      {
        "name": "Barra",
        "type": "bar",
        "barWidth": 40,
        "data": [
          10,
          20,
          30
        ],
        "label": {
          "show": true,
          "position": "inside",
          "color": "#ffffff",
          "formatter": "{c} t"
        }
      },
      {
        "name": "Linha",
        "type": "line",
        "data": [
          10,
          20,
          30
        ],
        "label": {
          "show": true,
          "position": "top",
          "color": "#505372",
          "formatter": "{c}"
        }
      }
    ],
    "title": {
      "text": "Producao por periodo",
      "subtext": "Titulos, labels e legendas configuraveis",
      "left": "center",
      "top": 4,
      "textStyle": {
        "fontSize": 18,
        "fontFamily": "Arial",
        "color": "#333333"
      }
    },
    "legend": {
      "top": "bottom",
      "left": "center"
    }
  },
  "expected": {
    "visualReviewRequired": true
  }
}
```

### V02 — Rich text nativo

```json
{
  "id": "V02",
  "title": "Rich text nativo",
  "phase": "visual",
  "option": {
    "animation": false,
    "grid": {
      "left": 80,
      "right": 40,
      "top": 40,
      "bottom": 60,
      "outerBoundsMode": "none"
    },
    "xAxis": {
      "type": "category",
      "boundaryGap": true,
      "data": [
        "A",
        "B",
        "C"
      ],
      "axisLabel": {
        "interval": 0
      }
    },
    "yAxis": {
      "type": "value",
      "min": 0,
      "max": 40
    },
    "series": [
      {
        "name": "Barra",
        "type": "bar",
        "barWidth": 40,
        "data": [
          10,
          20,
          30
        ],
        "label": {
          "show": true,
          "position": "top",
          "formatter": "{name|{b}} {value|{c}}",
          "rich": {
            "name": {
              "fontWeight": "bold",
              "color": "#333333"
            },
            "value": {
              "fontSize": 16,
              "color": "#ffffff",
              "backgroundColor": "#5070dd",
              "borderRadius": 3,
              "padding": 2
            }
          }
        }
      }
    ]
  },
  "expected": {
    "visualReviewRequired": true
  }
}
```

### V03 — Gradiente e sombra

```json
{
  "id": "V03",
  "title": "Gradiente e sombra",
  "phase": "visual",
  "option": {
    "animation": false,
    "grid": {
      "left": 80,
      "right": 40,
      "top": 40,
      "bottom": 60,
      "outerBoundsMode": "none"
    },
    "xAxis": {
      "type": "category",
      "boundaryGap": true,
      "data": [
        "A",
        "B",
        "C"
      ],
      "axisLabel": {
        "interval": 0
      }
    },
    "yAxis": {
      "type": "value",
      "min": 0,
      "max": 40
    },
    "series": [
      {
        "name": "Barra",
        "type": "bar",
        "barWidth": 40,
        "data": [
          10,
          20,
          30
        ],
        "itemStyle": {
          "color": {
            "type": "linear",
            "x": 0,
            "y": 0,
            "x2": 0,
            "y2": 1,
            "colorStops": [
              {
                "offset": 0,
                "color": "#74D64A"
              },
              {
                "offset": 1,
                "color": "#2F9E22"
              }
            ]
          },
          "borderRadius": 4,
          "shadowBlur": 8,
          "shadowColor": "rgba(0,0,0,0.3)",
          "shadowOffsetX": 3,
          "shadowOffsetY": 4
        }
      }
    ]
  },
  "expected": {
    "visualReviewRequired": true
  }
}
```

### V04 — Legenda paginada

```json
{
  "id": "V04",
  "title": "Legenda paginada",
  "phase": "visual",
  "option": {
    "animation": false,
    "grid": {
      "left": 80,
      "right": 40,
      "top": 40,
      "bottom": 60,
      "outerBoundsMode": "none"
    },
    "xAxis": {
      "type": "category",
      "boundaryGap": true,
      "data": [
        "A",
        "B",
        "C"
      ],
      "axisLabel": {
        "interval": 0
      }
    },
    "yAxis": {
      "type": "value",
      "min": 0,
      "max": 40
    },
    "series": [
      {
        "name": "Serie 0",
        "type": "bar",
        "data": [
          5,
          10,
          15
        ]
      },
      {
        "name": "Serie 1",
        "type": "bar",
        "data": [
          6,
          11,
          16
        ]
      },
      {
        "name": "Serie 2",
        "type": "bar",
        "data": [
          7,
          12,
          17
        ]
      },
      {
        "name": "Serie 3",
        "type": "bar",
        "data": [
          8,
          13,
          18
        ]
      },
      {
        "name": "Serie 4",
        "type": "bar",
        "data": [
          9,
          14,
          19
        ]
      },
      {
        "name": "Serie 5",
        "type": "bar",
        "data": [
          10,
          15,
          20
        ]
      },
      {
        "name": "Serie 6",
        "type": "bar",
        "data": [
          11,
          16,
          21
        ]
      },
      {
        "name": "Serie 7",
        "type": "bar",
        "data": [
          12,
          17,
          22
        ]
      },
      {
        "name": "Serie 8",
        "type": "bar",
        "data": [
          13,
          18,
          23
        ]
      },
      {
        "name": "Serie 9",
        "type": "bar",
        "data": [
          14,
          19,
          24
        ]
      },
      {
        "name": "Serie 10",
        "type": "bar",
        "data": [
          15,
          20,
          25
        ]
      },
      {
        "name": "Serie 11",
        "type": "bar",
        "data": [
          16,
          21,
          26
        ]
      }
    ],
    "legend": {
      "type": "scroll",
      "top": "bottom",
      "left": 20,
      "itemWidth": 18,
      "itemGap": 8
    }
  },
  "expected": {
    "visualReviewRequired": true
  }
}
```

### V05 — Area suave com lacuna

```json
{
  "id": "V05",
  "title": "Area suave com lacuna",
  "phase": "visual",
  "option": {
    "animation": false,
    "grid": {
      "left": 80,
      "right": 40,
      "top": 40,
      "bottom": 60,
      "outerBoundsMode": "none"
    },
    "xAxis": {
      "type": "category",
      "boundaryGap": true,
      "data": [
        "A",
        "B",
        "C",
        "D"
      ],
      "axisLabel": {
        "interval": 0
      }
    },
    "yAxis": {
      "type": "value",
      "min": 0,
      "max": 50
    },
    "series": [
      {
        "type": "line",
        "areaStyle": {},
        "connectNulls": false,
        "data": [
          10,
          null,
          30,
          40
        ],
        "smooth": true,
        "label": {
          "show": true
        }
      }
    ]
  },
  "expected": {
    "visualReviewRequired": true
  }
}
```

### V06 — Rosca com labels externos

```json
{
  "id": "V06",
  "title": "Rosca com labels externos",
  "phase": "visual",
  "option": {
    "animation": false,
    "tooltip": {
      "trigger": "item"
    },
    "series": [
      {
        "type": "pie",
        "center": [
          "50%",
          "50%"
        ],
        "radius": [
          50,
          100
        ],
        "label": {
          "show": true,
          "position": "outside",
          "formatter": "{b}: {d}%"
        },
        "data": [
          {
            "name": "A",
            "value": 10
          },
          {
            "name": "B",
            "value": 30
          }
        ],
        "labelLine": {
          "show": true
        }
      }
    ]
  },
  "expected": {
    "visualReviewRequired": true
  }
}
```

### V07 — Texto rotacionado

```json
{
  "id": "V07",
  "title": "Texto rotacionado",
  "phase": "visual",
  "option": {
    "animation": false,
    "grid": {
      "left": 80,
      "right": 40,
      "top": 40,
      "bottom": 90,
      "outerBoundsMode": "none"
    },
    "xAxis": {
      "type": "category",
      "boundaryGap": true,
      "data": [
        "Categoria A",
        "Categoria B",
        "Categoria C"
      ],
      "axisLabel": {
        "interval": 0,
        "rotate": 45,
        "fontSize": 14
      }
    },
    "yAxis": {
      "type": "value",
      "min": 0,
      "max": 40
    },
    "series": [
      {
        "name": "Barra",
        "type": "bar",
        "barWidth": 40,
        "data": [
          10,
          20,
          30
        ]
      },
      {
        "name": "Linha",
        "type": "line",
        "data": [
          10,
          20,
          30
        ]
      }
    ]
  },
  "expected": {
    "visualReviewRequired": true
  }
}
```

### V08 — Dados vazios

```json
{
  "id": "V08",
  "title": "Dados vazios",
  "phase": "visual",
  "option": {
    "animation": false,
    "grid": {
      "left": 80,
      "right": 40,
      "top": 40,
      "bottom": 60,
      "outerBoundsMode": "none"
    },
    "xAxis": {
      "type": "category",
      "data": []
    },
    "yAxis": {
      "type": "value",
      "min": 0,
      "max": 40
    },
    "series": [
      {
        "type": "bar",
        "data": []
      }
    ]
  }
}
```

### V09 — Um ponto e limites fixos

```json
{
  "id": "V09",
  "title": "Um ponto e limites fixos",
  "phase": "visual",
  "option": {
    "animation": false,
    "grid": {
      "left": 80,
      "right": 40,
      "top": 40,
      "bottom": 60,
      "outerBoundsMode": "none"
    },
    "xAxis": {
      "type": "category",
      "data": [
        "Unico"
      ]
    },
    "yAxis": {
      "type": "value",
      "min": 0,
      "max": 40
    },
    "series": [
      {
        "type": "line",
        "data": [
          20
        ]
      }
    ]
  }
}
```

### V10 — Valores iguais

```json
{
  "id": "V10",
  "title": "Valores iguais",
  "phase": "visual",
  "option": {
    "animation": false,
    "grid": {
      "left": 80,
      "right": 40,
      "top": 40,
      "bottom": 60,
      "outerBoundsMode": "none"
    },
    "xAxis": {
      "type": "category",
      "data": [
        "A",
        "B",
        "C"
      ]
    },
    "yAxis": {
      "type": "value",
      "min": 0,
      "max": 40
    },
    "series": [
      {
        "type": "bar",
        "data": [
          20,
          20,
          20
        ]
      }
    ]
  }
}
```

### V11 — Linha suavizada

```json
{
  "id": "V11",
  "title": "Linha suavizada",
  "phase": "visual",
  "option": {
    "animation": false,
    "grid": {
      "left": 80,
      "right": 40,
      "top": 40,
      "bottom": 60,
      "outerBoundsMode": "none"
    },
    "xAxis": {
      "type": "category",
      "data": [
        "A",
        "B",
        "C"
      ]
    },
    "yAxis": {
      "type": "value",
      "min": 0,
      "max": 40
    },
    "series": [
      {
        "type": "line",
        "smooth": true,
        "data": [
          10,
          35,
          15
        ]
      }
    ]
  }
}
```

### V12 — Area em degraus

```json
{
  "id": "V12",
  "title": "Area em degraus",
  "phase": "visual",
  "option": {
    "animation": false,
    "grid": {
      "left": 80,
      "right": 40,
      "top": 40,
      "bottom": 60,
      "outerBoundsMode": "none"
    },
    "xAxis": {
      "type": "category",
      "data": [
        "A",
        "B",
        "C"
      ]
    },
    "yAxis": {
      "type": "value",
      "min": 0,
      "max": 40
    },
    "series": [
      {
        "type": "line",
        "step": "middle",
        "areaStyle": {},
        "data": [
          10,
          35,
          15
        ]
      }
    ]
  }
}
```

### V13 — Eixos invertidos

```json
{
  "id": "V13",
  "title": "Eixos invertidos",
  "phase": "visual",
  "option": {
    "animation": false,
    "grid": {
      "left": 80,
      "right": 40,
      "top": 40,
      "bottom": 60,
      "outerBoundsMode": "none"
    },
    "xAxis": {
      "type": "category",
      "inverse": true,
      "data": [
        "A",
        "B",
        "C"
      ]
    },
    "yAxis": {
      "type": "value",
      "inverse": true,
      "min": 0,
      "max": 40
    },
    "series": [
      {
        "type": "bar",
        "data": [
          10,
          20,
          30
        ]
      }
    ]
  }
}
```

### V14 — Linha conectando NULL

```json
{
  "id": "V14",
  "title": "Linha conectando NULL",
  "phase": "visual",
  "option": {
    "animation": false,
    "grid": {
      "left": 80,
      "right": 40,
      "top": 40,
      "bottom": 60,
      "outerBoundsMode": "none"
    },
    "xAxis": {
      "type": "category",
      "data": [
        "A",
        "B",
        "C"
      ]
    },
    "yAxis": {
      "type": "value",
      "min": 0,
      "max": 40
    },
    "series": [
      {
        "type": "line",
        "connectNulls": true,
        "smooth": true,
        "data": [
          10,
          null,
          30
        ]
      }
    ]
  }
}
```

### V15 — Texto longo e acentos

```json
{
  "id": "V15",
  "title": "Texto longo e acentos",
  "phase": "visual",
  "option": {
    "animation": false,
    "grid": {
      "left": 80,
      "right": 40,
      "top": 40,
      "bottom": 60,
      "outerBoundsMode": "none"
    },
    "xAxis": {
      "type": "category",
      "data": [
        "Produção agrícola extensa",
        "Milho safrinha",
        "Feijão"
      ]
    },
    "yAxis": {
      "type": "value",
      "min": 0,
      "max": 40
    },
    "series": [
      {
        "type": "bar",
        "label": {
          "show": true,
          "formatter": "{b}: {c}",
          "width": 90,
          "overflow": "truncate"
        },
        "data": [
          10,
          20,
          30
        ]
      }
    ],
    "title": {
      "text": "Produção - demonstração",
      "textStyle": {
        "fontSize": 18
      }
    }
  }
}
```
