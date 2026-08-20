---
name: statistical-modeling
description: 统计建模与机器学习标准流程（原创技能，MIT）：假设检验选择与前提检查、回归诊断、sklearn 建模与评估、过拟合检查。当任务涉及假设检验、回归、分类、聚类或模型评估时加载。
---

# statistical-modeling — 统计建模与 ML 标准流程

本技能固化假设检验、回归与机器学习建模的**标准流程与检查清单**，保证结论可辩护、模型不过度自信。依赖：`scipy`、`statsmodels`、`sklearn`（均为常用科学计算库）。

## 0. 建模前（先回答三个问题）

1. **目标**：是要「证明差异」（推断）还是「预测结果」（预测）？
2. **数据形态**：样本量多大？正态吗？独立吗？分组几个？
3. **业务约束**：可解释性重要吗（回归/树）？还是纯预测精度（GBM）？

## 1. 假设检验选择（scipy / statsmodels）

| 场景 | 检验 | 前提检查 |
|---|---|---|
| 两组均值差异（独立） | `scipy.stats.ttest_ind` | 方差齐性（Levene）→ 不等用 `equal_var=False` |
| 两组均值差异（配对） | `scipy.stats.ttest_rel` | 差值近似正态 |
| 多组均值差异 | `scipy.stats.f_oneway`（ANOVA）→ 事后 Tukey | 正态 + 方差齐 |
| 两组差异（非参） | `scipy.stats.mannwhitneyu` | 有序/偏态/小样本 |
| 多组差异（非参） | `scipy.stats.kruskal` | 偏态 |
| 分类变量关联 | `scipy.stats.chi2_contingency` | 期望频数 ≥5 |
| 正态性检验 | `scipy.stats.shapiro`（n<5000） | — |

**汇报规范**：给出统计量、p 值、**效应量**（Cohen's d / η² / Cramér's V）——p 值显著不等于差异有实际意义。p 值 <0.05 时说明「差异显著」，同时给出置信区间。

## 2. 回归（statsmodels）

```python
import statsmodels.api as sm
X = sm.add_constant(df[["x1", "x2"]])
model = sm.OLS(df["y"], X).fit()
print(model.summary())
```

**诊断清单（必须逐项看）**：
- 系数显著性与方向是否符合业务直觉
- `R²` / 调整 `R²`：解释力度
- 残差正态性：`sm.qqplot` / Shapiro
- 异方差：`model.resid` 与拟合值散点（漏斗状=异方差，用 `sm.RLM` 或加权）
- 多重共线性：`VIF`（>10 提示共线，考虑删变量/合并）
- 预测用：做 train/test 或交叉验证，别只报训练集 R²

逻辑回归用 `sm.Logit`；分类指标见下节。

## 3. 机器学习流程（sklearn）

```python
from sklearn.model_selection import train_test_split, cross_val_score, GridSearchCV
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import classification_report, roc_auc_score

X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)
clf = RandomForestClassifier(random_state=42)
clf.fit(X_train, y_train)
print(classification_report(y_test, clf.predict(X_test)))
```

**硬性规范**：
- **固定随机种子**（`random_state=42`），结果可复现
- 训练/测试划分**先于任何特征缩放/填充**（防数据泄漏）
- 类别不均衡：报告 `roc_auc` / PR-AUC，别只看 accuracy；可用 `class_weight`
- 调参用 `GridSearchCV` + 交叉验证，禁止用测试集调参
- **对比基线**：至少和「多数类预测」或简单模型对比，证明模型真的有增益
- 特征重要性（树模型）输出 Top N，帮助解释

## 4. 模型评估指标速查

| 任务 | 指标 |
|---|---|
| 二分类 | accuracy（均衡时）、precision/recall/F1、AUC、混淆矩阵 |
| 多分类 | macro/micro F1、混淆矩阵 |
| 回归 | MAE、RMSE、R²、MAPE |
| 聚类 | 轮廓系数（silhouette）、簇内 SSE |

## 5. 交付检查清单

- [ ] 检验/模型的前提条件已验证（正态/方差齐/独立性）
- [ ] 固定随机种子，训练/测试划分正确（无泄漏）
- [ ] 报了效应量或置信区间，不只报 p 值
- [ ] 对比了基线模型，不夸大增益
- [ ] 结论区分相关与因果；局限与假设已说明
