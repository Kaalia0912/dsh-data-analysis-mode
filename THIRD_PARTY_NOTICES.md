# THIRD-PARTY NOTICES

本项目包含/引用以下第三方内容。许可证全文见 `skills/LICENSES/` 与各来源仓库。

## DuckDB 官方技能（MIT）

来源：https://github.com/duckdb/duckdb-skills
许可：MIT（© 2018-2025 Stichting DuckDB Foundation）
包含：`skills/query`、`skills/read-file`、`skills/convert-file`、`skills/attach-db`、`skills/install-duckdb`
全文：`skills/LICENSES/duckdb-skills.txt`

## deer-flow data-analysis（MIT，改写）

来源：https://github.com/bytedance/deer-flow（`skills/public/data-analysis`）
许可：MIT（© 2025 Bytedance Ltd. and/or its affiliates）
包含：`skills/deer-data-analysis`（本仓库提供**改写版**：适配 DSH 环境的路径约定，技能名改为 `deer-data-analysis` 以避免与自研 `data-analysis` 技能冲突）
全文：`skills/LICENSES/deer-flow.txt`

## anthropics/skills 文档技能（Proprietary — 不随仓库分发）

来源：https://github.com/anthropics/skills（`skills/xlsx`、`skills/pdf`）
许可：**Proprietary**。各技能目录内 `LICENSE.txt` 有完整条款。
本仓库**不包含**这些技能。`scripts/install.ps1 -WithAnthropicDocs` 仅在用户确认接受条款后从官方仓库下载；下载与使用请自行遵守其许可。

## Python 运行时依赖

- `duckdb` / `duckdb-cli`（MIT）
- `mcp-server-duckdb`（MIT）及其依赖 `mcp`（MIT）
- `pywin32`（PSF/BSD 混合）
- `markitdown`（MIT）
- `openpyxl`（MIT）
- 均为可选/按脚本自动安装；安装与使用请遵守各包自身许可。

## 本仓库新增内容（MIT）

- `agent-presets/data-analysis/` 预设组合与 persona
- `skills/data-analysis/`、`skills/pandas-3x/`
- `scripts/install.ps1`、`scripts/recalc_excel.py`（Excel COM 公式重算，替代 LibreOffice 依赖）
- 对 `deer-data-analysis` 的路径改写
