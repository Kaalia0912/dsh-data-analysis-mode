---
name: xlsx-tools
description: Excel 工作簿（.xlsx/.xlsm）的读取、写入与报表制作（原创技能，MIT）：openpyxl/pandas 读写、公式重算（优先 Excel COM，无 Excel 则 LibreOffice）、样式与基础图表。当任务是处理 Excel 文件、生成表格报表、导出数据时加载。
---

# xlsx-tools — Excel 工作簿处理

本技能覆盖 Excel 文件的常用处理路径。与 `data-analysis`（分析工作流）和 `pandas-3x`（pandas 技巧）配合使用。

## 读写路径选择

| 任务 | 工具 |
|---|---|
| 批量读写（整表） | `pandas.read_excel` / `to_excel`（快，样式少） |
| 精细控制（单元格、样式、合并、公式） | `openpyxl`（`load_workbook` / `Workbook`） |
| 快速预览 | `pandas.read_excel(..., nrows=5)` 或 `openpyxl` 读前几行 |
| 多 sheet / 大文件 | `pd.read_excel(path, sheet_name=None)` 一次读全部 sheet |

## 公式处理（关键坑）

`openpyxl` 写公式只写文本、**不计算结果**——用 `pandas` 或 `data_only=True` 读取公式单元格会得到 `None`。所以**凡含公式的工作簿，交付前必须重算**：

```bash
# 本机有 Microsoft Excel（推荐）：用 Excel COM 重算
python scripts/recalc_excel.py output.xlsx

# 没有 Excel：用 LibreOffice 重算
python scripts/recalc.py output.xlsx   # 需要 LibreOffice 的 soffice 在 PATH
```

`recalc_excel.py` 输出 JSON：`status`（`success`/`errors_found`）、`total_formulas`、`total_errors`、`error_summary`（错误类型 → 单元格列表）。**只有 `error` 键表示重算失败（exit 1）；`errors_found` 正常 exit 0**，所以看 `status` 字段，别只看退出码。

> 重算通过只证明公式「能算」，不证明「算得对」——写完公式先抽查 2-3 个格子的值再铺开。

## 常用写法

### openpyxl 基础
```python
import openpyxl
wb = openpyxl.load_workbook("a.xlsx")            # 默认含公式文本
wb = openpyxl.load_workbook("a.xlsx", data_only=True)  # 只读缓存值（未重算则为 None）
ws = wb.active
ws["B2"] = "=SUM(B3:B99)"
wb.save("a.xlsx")

# 新建
wb2 = openpyxl.Workbook(); ws2 = wb2.active
ws2.title = "汇总"
```

### pandas 批量
```python
import pandas as pd
df = pd.read_excel("a.xlsx", sheet_name="数据")          # 读指定 sheet
all_sheets = pd.read_excel("a.xlsx", sheet_name=None)    # 全部 sheet -> dict
df.to_excel("out.xlsx", index=False, sheet_name="结果")   # 写出
# 多 sheet 一次写
with pd.ExcelWriter("out.xlsx") as writer:
    df1.to_excel(writer, sheet_name="A", index=False)
    df2.to_excel(writer, sheet_name="B", index=False)
```

### 样式与合并
```python
from openpyxl.styles import Font, PatternFill, Alignment
from openpyxl.utils import get_column_letter
hdr = ws["A1"]
hdr.font = Font(bold=True, color="FFFFFF")
hdr.fill = PatternFill("solid", fgColor="4472C4")
ws.merge_cells("A1:D1")
ws["A1"].alignment = Alignment(horizontal="center")
# 列宽
for col in range(1, 5):
    ws.column_dimensions[get_column_letter(col)].width = 14
```

### 基础图表（openpyxl）
```python
from openpyxl.chart import BarChart, Reference
chart = BarChart()
data = Reference(ws, min_col=2, min_row=1, max_row=13)
cats = Reference(ws, min_col=1, min_row=2, max_row=13)
chart.add_data(data, titles_from_data=True)
chart.set_categories(cats)
ws.add_chart(chart, "F2")
```

## Windows 环境注意

- 路径用原生 Windows 形式（`C:\...`），写文件统一 UTF-8。
- 中文列名/内容没问题；注意 Excel 读取 CSV 时编码：`pd.read_csv(..., encoding="utf-8-sig")`（带 BOM，Excel 双击不乱码）。
- 若用 Excel COM 重算，确保没有残留的 EXCEL.EXE 进程（可先 `Stop-Process -Name EXCEL`）。

## 交付检查清单

- [ ] 含公式的工作簿已重算（`status: success` 或已处理 `errors_found` 指出的单元格）
- [ ] 表头加粗、列宽合理、数字格式正确（`#,##0.00` 等）
- [ ] 交付前用 `data_only=True` 抽查几个关键单元格的值
- [ ] 假定与硬编码数字在注释或相邻单元格说明
