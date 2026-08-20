---
name: visualization
description: matplotlib / seaborn 数据可视化规范（原创技能，MIT）：图表类型选择、中文字体处理、样式与保存规范。当任务需要画图、做图表、生成可视化报告时加载。
---

# visualization — 数据可视化规范

本技能定义 matplotlib / seaborn 的可视化标准，保证图表**清晰、规范、可直接交付**。与 `data-analysis`（工作流）、`pandas-3x`（pandas 技巧）配合使用。

## 环境与字体（Windows 必读）

```python
import matplotlib
matplotlib.use("Agg")                      # 无显示环境用 Agg 后端
import matplotlib.pyplot as plt
import seaborn as sns

# 中文字体：缺失时中文会变方块
plt.rcParams["font.sans-serif"] = ["Microsoft YaHei", "SimHei"]
plt.rcParams["axes.unicode_minus"] = False   # 负号不乱码
```

## 图表类型选择

| 目的 | 图 |
|---|---|
| 分布（单变量） | `sns.histplot` / `sns.kdeplot` / 箱线图 |
| 类别对比 | 柱状图（`sns.barplot`）或点图 |
| 趋势 | 折线图（`plt.plot`） |
| 两个数值列关系 | 散点图（`sns.scatterplot`） |
| 相关性矩阵 | `sns.heatmap(corr, annot=True)` |
| 分组分布 | 箱线图 / 小提琴图（`sns.boxplot` / `sns.violinplot`） |
| 计数 | `sns.countplot` |
| 时间序列 | 折线 + `pd.to_datetime` 索引 |

## 交付规范（每条必须满足）

1. **标题**：说明图内容与口径（如「月度营收趋势（2024）」）
2. **轴标签**：含单位（`金额（万元）`、`时间`）
3. **图例**：多系列必须有
4. **网格**：数值型图表开 `plt.grid(alpha=0.3)` 便于读数
5. **保存**：`plt.savefig("out.png", dpi=200, bbox_inches="tight")`，PNG 交付；矢量报告用 PDF
6. **关闭**：`plt.close(fig)` 防止内存堆积（循环画图时必做）

## 常用模板

### 分组柱状
```python
import pandas as pd
fig, ax = plt.subplots(figsize=(8, 5))
df.groupby("category")["value"].mean().sort_values().plot.bar(ax=ax, color="#4C72B0")
ax.set_title("各品类均值对比", fontsize=13)
ax.set_ylabel("value")
ax.grid(axis="y", alpha=0.3)
plt.tight_layout(); plt.savefig("bar.png", dpi=200, bbox_inches="tight"); plt.close(fig)
```

### 时间序列折线
```python
fig, ax = plt.subplots(figsize=(10, 4))
ts.plot(ax=ax, marker="o", markersize=3)
ax.set_title("时间序列趋势")
ax.set_ylabel("数值")
plt.tight_layout(); plt.savefig("trend.png", dpi=200, bbox_inches="tight"); plt.close(fig)
```

### 热力图（相关性）
```python
sns.heatmap(df.corr(numeric_only=True), annot=True, fmt=".2f", cmap="RdBu_r", center=0)
plt.title("相关性矩阵")
plt.tight_layout(); plt.savefig("corr.png", dpi=200, bbox_inches="tight"); plt.close()
```

## 检查清单

- [ ] 中文不乱码（Microsoft YaHei / SimHei 已设置）
- [ ] 标题、轴标签（含单位）、图例齐全
- [ ] dpi ≥ 200，无元素被裁切（bbox_inches="tight"）
- [ ] 颜色方案统一（sns 默认或统一色板）
- [ ] 交付前读一眼图，确认无空白/重叠/缺数据
