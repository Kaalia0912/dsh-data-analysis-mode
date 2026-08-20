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

## OpenAI 官方 pdf 技能（Apache-2.0）

来源：https://github.com/openai/skills（`skills/.curated/pdf`）
许可：Apache License 2.0（许可证全文随技能保留：`skills/pdf/LICENSE.txt`）
包含：`skills/pdf`（原样收录，未修改）
说明：本项目以 Apache-2.0 的 pdf 技能替代 anthropics 的专有 pdf 技能（后者为 Proprietary 许可，不可再分发）。

## 为什么没有 anthropics 的 xlsx/pdf 技能

Anthropic 官方技能（`skills/xlsx`、`skills/pdf`）为 **Proprietary 专有许可**，不可作为作品再分发，因此未收录。
替代方案：
- PDF：采用上述 OpenAI 官方 pdf 技能（Apache-2.0）
- Excel：本仓库自研 **`skills/xlsx-tools`**（MIT，内容原创，见下）

## 本仓库新增内容（MIT，原创）

- `agent-presets/data-analysis/` 预设组合与 persona
- `skills/data-analysis/`、`skills/pandas-3x/`、`skills/xlsx-tools/`（含 `scripts/recalc_excel.py`：Excel COM 公式重算，替代 LibreOffice 依赖）
- `scripts/install.ps1`
- 对 `deer-data-analysis` 的路径改写

## Python 运行时依赖

- `duckdb` / `duckdb-cli`（MIT）
- `mcp-server-duckdb`（MIT）及其依赖 `mcp`（MIT）
- `pywin32`（PSF/BSD 混合）
- `openpyxl` / `pandas`（MIT / BSD）
- `reportlab`（BSD）、`pdfplumber`（MIT）、`pypdf`（BSD）
- 均为按需安装；安装与使用请遵守各包自身许可。
