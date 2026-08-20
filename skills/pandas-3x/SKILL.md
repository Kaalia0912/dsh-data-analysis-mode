---
name: pandas-3x
description: pandas 3.x 高效数据分析技巧与新版行为坑位指南（Copy-on-Write、string dtype、groupby 默认参数等）。当分析任务使用 pandas 且版本为 3.x 时加载。
---

# pandas 3.x 实战指南

本技能覆盖 pandas 3.x（当前环境 `pandas 3.0.3`）的关键行为变化与高效用法，避免写「2.x 时代」的低效或失效代码。

## 3.x 关键行为变化（写代码前先记住）

- **Copy-on-Write（CoW）默认开启**：`df["a"] = ...` 等链式赋值（chained assignment）**不再可靠**。改数据统一走显式路径：
  - 单列赋值：`df["a"] = values`（正常）
  - 按条件改子集：先 `mask = df["x"] > 0`，再 `df.loc[mask, "a"] = 1`（**必须用 .loc**）
  - 绝不写 `df[df.x>0]["a"] = 1` 这种链式赋值——在 CoW 下会静默无效。
- **字符串默认 string dtype**：`str` 列不再用 object dtype。不再需要 `df["s"] = df["s"].astype("string")`；`df["s"].str.*` 直接可用。
- **groupby 的 `observed` 默认改为 True**：分类列分组不再默认展开所有组合。需要「全组合计数」时显式 `groupby(..., observed=False)`。
- **数值列缺失值**：统一用 `pd.NA`，`np.nan` 在整数列会强制转 float；`df.info()` 看 dtype 时注意 `Int64`（大写，可空整数）与 `int64` 的区别。
- **`read_csv` 解析错误行**：用 `on_bad_lines="warn"` 或 `"error"`（不要用已废弃的 `error_bad_lines`）。

## 高效模式（替代低效写法）

- **分组统计一次算完**：`df.groupby("cat").agg(mean=("v","mean"), cnt=("v","count"), med=("v","median"))`，不要循环 groupby。
- **组内变换**：`df["v_ratio"] = df.groupby("cat")["v"].transform(lambda s: s / s.sum())`。
- **透视**：`pd.crosstab(df["a"], df["b"], normalize="index")` 出比例；`df.pivot_table(index=..., columns=..., values=..., aggfunc="mean")`。
- **宽长互转**：`df.melt(id_vars=["id"], var_name="metric", value_name="val")` 与 `df.pivot(...)`。
- **大文件**（>1GB 或百万行）：别硬扛 pandas——先试 DuckDB（见 `duckdb` 技能）或 polars；pandas 读大 CSV 至少指定 `dtype`、`usecols`、`parse_dates`。

## 与可视化衔接

- 图表规范见 `data-analysis` 技能的检查清单（标题、轴标签、单位）。
- Windows 中文标签：matplotlib 用 `plt.rcParams["font.sans-serif"] = ["Microsoft YaHei"]`，并 `plt.rcParams["axes.unicode_minus"] = False`，否则中文变方块、负号乱码。

## 交付检查

- [ ] 无链式赋值（CoW 下静默失效）
- [ ] 分组/聚合不用显式循环
- [ ] 大文件已考虑 DuckDB/polars 或分块读取
- [ ] 随机操作固定种子；结果可复现
