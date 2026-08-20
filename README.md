# dsh-data-analysis-mode 📊

**DeepSeek Harness「数据分析模式」**：一个开源的数据分析 agent 预设（preset）+ 技能集 + DuckDB MCP 服务器接入。

在 DeepSeek Harness（DSH）Web 上新建会话时选择「数据分析模式」，即可获得一位**资深数据分析师**：完整编码助手能力 + 专业分析工作流 + 12 个即用技能 + 本地 DuckDB SQL 引擎（MCP）。

作者：**Kaalia0912**（MIT License，见 `LICENSE`）

## ✨ 特性

- **专业 persona**：结论先行、数据质量优先、可复现性、严谨统计；保留 `{{model}}` / `{{cwd}}` 插值，工具面与标准模式完全一致（shell、文件系统、后台任务、技能、目标、计划模式、委派、工作流）
- **12 个即用技能**（发现实时生效，无需重启）：
  - 自研（MIT）：`data-analysis`（五阶段分析工作流）、`pandas-3x`（pandas 3.x 行为坑位与高效模式）、`xlsx-tools`（Excel 读写/公式重算/报表）
  - DuckDB 官方（MIT）：`query`、`read-file`、`convert-file`、`attach-db`、`install-duckdb`
  - 字节 deer-flow（MIT，改写适配 DSH 路径）：`deer-data-analysis`（带 analyze.py 脚本）
  - OpenAI 官方（Apache-2.0）：`pdf`（reportlab/pdfplumber 生成与提取）
- **DuckDB MCP 服务器**：SQL 直接查询 CSV/Parquet/Excel/JSON，工具以 `mcp__duckdb__*` 命名空间暴露
- **Excel 公式重算**：`skills/xlsx-tools/scripts/recalc_excel.py` 用本机 Microsoft Excel COM 重算公式，替代 LibreOffice 依赖（无 Excel 时回退 LibreOffice）

> 📌 第三方内容均选用开源许可（DuckDB 官方 MIT、OpenAI 官方 Apache-2.0），许可声明见 `THIRD_PARTY_NOTICES.md`。

## 📦 前置依赖

| 组件 | 用途 | 必需 |
|---|---|---|
| Python 3.10+ | 数据脚本 | ✅ |
| `duckdb`（pip） | DuckDB Python 库 | ✅（install.ps1 自动装） |
| `mcp-server-duckdb`（pip） | MCP 服务器 | ✅（install.ps1 自动装） |
| `openpyxl` / `pandas` | xlsx-tools 运行时 | 推荐 |
| `pywin32` | Excel COM 公式重算（有 Microsoft Excel 时） | 可选 |
| `reportlab` / `pdfplumber` / `pypdf` | pdf 技能运行时 | 可选 |
| Microsoft Excel 或 LibreOffice | xlsx 公式重算 | 可选 |

## 🚀 安装

### 方式一：一键脚本（推荐）

```powershell
git clone https://github.com/Kaalia0912/dsh-data-analysis-mode.git
cd dsh-data-analysis-mode
.\scripts\install.ps1
```

脚本会：
1. 检查/安装 `duckdb` 与 `mcp-server-duckdb`
2. 把 `agent-presets/data-analysis/` → `~/.dsh/.agent-presets/data-analysis/`（**自动解析占位符**，写入本机 mcp-server-duckdb 路径与分析数据库路径）
3. 把 `skills/` 下全部技能 → `~/.dsh/skills/`（全部开源许可，随仓库分发）

### 方式二：手动

```powershell
# 1) 拷贝预设（替换占位符 {{MCP_DUCKDB_EXE}} / {{ANALYSIS_DB_PATH}}）
New-Item -ItemType Directory -Force "$HOME\.dsh\.agent-presets" | Out-Null
Copy-Item -Recurse agent-presets\data-analysis "$HOME\.dsh\.agent-presets\data-analysis"

# 2) 拷贝技能
Get-ChildItem skills -Directory | Where-Object Name -ne 'LICENSES' | ForEach-Object {
  Copy-Item -Recurse $_.FullName "$HOME\.dsh\skills\$($_.Name)"
}

# 3) 依赖
python -m pip install duckdb mcp-server-duckdb openpyxl pandas
```

## 🎯 使用

1. 重启 `dsh web`（预设发现实时，但已有会话保持创建时的预设）
2. 新建会话 → 预设选择器选「**数据分析模式**」
3. 直接甩数据文件给模型，或让它执行分析工作流（`data-analysis` 技能定义了 采集 → 清洗 → EDA → 建模 → 报告 的标准流程）

技能目录对所有会话实时可见；MCP 工具仅对挂载本预设的会话暴露。

## 📁 仓库结构

```
agent-presets/data-analysis/   # 预设：standard 分叉 + 数据分析师 persona（占位符模板）
  agent.cordis.yml
  preset.yml
skills/                        # 技能（平铺布局，可直接并入 ~/.dsh/skills/）
  data-analysis/               # 自研：分析工作流
  pandas-3x/                   # 自研：pandas 3.x 指南
  xlsx-tools/                  # 自研：Excel 读写/公式重算（含 recalc_excel.py）
  deer-data-analysis/          # 字节 MIT（改写）：DuckDB SQL 分析
  pdf/                         # OpenAI Apache-2.0：PDF 生成与提取
  query/ read-file/ convert-file/ attach-db/ install-duckdb/   # DuckDB 官方 MIT
  LICENSES/                    # 第三方许可证副本
scripts/
  install.ps1                  # 一键安装（解析占位符 + 拷贝 + 依赖）
```

## 📜 许可证

- 本仓库代码与自研技能：**MIT**（© 2026 Kaalia0912，见 `LICENSE`）
- 第三方内容见 **`THIRD_PARTY_NOTICES.md`**：
  - DuckDB 官方技能：MIT（© Stichting DuckDB Foundation）
  - deer-flow `data-analysis`：MIT（© Bytedance Ltd.），本仓库提供改写版（DSH 路径适配）
  - OpenAI 官方 `pdf`：Apache-2.0（原样收录，许可证随技能保留）

## ⚠️ 说明

本项目是一个独立的开源项目，与 DeepSeek 官方及其任何产品无关联。
