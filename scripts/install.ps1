# dsh-data-analysis-mode — 一键安装脚本
# 用法：
#   .\scripts\install.ps1                     # 安装预设 + 全部随仓库技能
#   .\scripts\install.ps1 -PresetRoot X -SkillsRoot Y   # 自定义安装位置
param(
    [string]$PresetRoot = (Join-Path $HOME '.dsh\.agent-presets'),
    [string]$SkillsRoot = (Join-Path $HOME '.dsh\skills')
)
$ErrorActionPreference = 'Stop'
$repo = $PSScriptRoot | Split-Path -Parent

Write-Host "==> dsh-data-analysis-mode installer" -ForegroundColor Cyan

# ── 1. 前置检查：python / duckdb / mcp-server-duckdb ──────────────────────
Write-Host "==> 检查 Python 环境..." -ForegroundColor Cyan
python --version 2>$null | Out-Null
if ($LASTEXITCODE -ne 0) { throw "未找到 python，请先安装 Python 3.10+ 并加入 PATH" }

python -c "import duckdb" 2>$null
if ($LASTEXITCODE -ne 0) {
    Write-Host "    duckdb 未安装，正在 pip install duckdb mcp-server-duckdb ..." -ForegroundColor Yellow
    python -m pip install --disable-pip-version-check duckdb mcp-server-duckdb
}

# ── 2. 定位 mcp-server-duckdb 可执行入口 ───────────────────────────────────
Write-Host "==> 定位 mcp-server-duckdb ..." -ForegroundColor Cyan
$exe = $null
$cmd = Get-Command mcp-server-duckdb -ErrorAction SilentlyContinue
if ($cmd) { $exe = $cmd.Source }
if (-not $exe) {
    $cands = @()
    $cands += Get-ChildItem (Join-Path $env:APPDATA 'Python\Python*\Scripts\mcp-server-duckdb.exe') -ErrorAction SilentlyContinue
    $cands += Get-ChildItem (Join-Path $env:LOCALAPPDATA 'Programs\Python\Python*\Scripts\mcp-server-duckdb.exe') -ErrorAction SilentlyContinue
    $cands += Get-ChildItem 'C:\Python*\Scripts\mcp-server-duckdb.exe' -ErrorAction SilentlyContinue
    if ($cands) { $exe = ($cands | Select-Object -First 1).FullName }
}
if (-not $exe) {
    Write-Warning "未找到 mcp-server-duckdb.exe。MCP 工具将不可用（预设仍可正常使用）。"
    Write-Warning "可手动安装：python -m pip install mcp-server-duckdb"
    $exe = '<mcp-server-duckdb-not-found>'
} else {
    Write-Host "    MCP 服务器: $exe" -ForegroundColor Green
}

# ── 3. 安装预设（模板替换占位符）───────────────────────────────────────────
Write-Host "==> 安装预设到 $PresetRoot ..." -ForegroundColor Cyan
$dbDir = Join-Path $HOME '.dsh\data-analysis'
New-Item -ItemType Directory -Force $dbDir | Out-Null
$dbPath = Join-Path $dbDir 'analysis.duckdb'
$dstPreset = Join-Path $PresetRoot 'data-analysis'
New-Item -ItemType Directory -Force $dstPreset | Out-Null

$template = Get-Content (Join-Path $repo 'agent-presets\data-analysis\agent.cordis.yml') -Raw -Encoding UTF8
# 占位符替换：YAML 单引号标量中反斜杠是字面量，Windows 路径原样写入（不转义双反斜杠）。
$content = $template.Replace('{{MCP_DUCKDB_EXE}}', $exe).Replace('{{ANALYSIS_DB_PATH}}', $dbPath)
Set-Content -Path (Join-Path $dstPreset 'agent.cordis.yml') -Value $content -Encoding UTF8 -NoNewline
Copy-Item (Join-Path $repo 'agent-presets\data-analysis\preset.yml') (Join-Path $dstPreset 'preset.yml') -Force
Write-Host "    预设: $dstPreset" -ForegroundColor Green

# 初始化分析数据库（可选，首次创建）
python -c "import duckdb; duckdb.connect(r'$dbPath').execute('CREATE TABLE IF NOT EXISTS _meta(v VARCHAR)')" 2>$null
Write-Host "    数据库: $dbPath" -ForegroundColor Green

# ── 4. 安装技能（平铺到技能根，LICENSES 目录除外）──────────────────────────
Write-Host "==> 安装技能到 $SkillsRoot ..." -ForegroundColor Cyan
New-Item -ItemType Directory -Force $SkillsRoot | Out-Null
Get-ChildItem (Join-Path $repo 'skills') -Directory | Where-Object { $_.Name -ne 'LICENSES' } | ForEach-Object {
    Copy-Item $_.FullName (Join-Path $SkillsRoot $_.Name) -Recurse -Force
    Write-Host "    + $($_.Name)" -ForegroundColor Green
}

# ── 5. 运行时依赖提示 ──────────────────────────────────────────────────────
Write-Host ""
Write-Host "==> 运行时依赖（按需安装）" -ForegroundColor Cyan
Write-Host "    数据分析/表格: python -m pip install duckdb openpyxl pandas" -ForegroundColor Yellow
Write-Host "    统计建模/数据库连接: python -m pip install statsmodels sqlalchemy pymysql psycopg2-binary" -ForegroundColor Yellow
Write-Host "    xlsx 公式重算（Excel COM，推荐配合本机 Microsoft Excel）:" -ForegroundColor Yellow
Write-Host "        python -m pip install pywin32" -ForegroundColor Yellow
Write-Host "    PDF（reportlab / pdfplumber / pypdf；渲染检查可选 Poppler）:" -ForegroundColor Yellow
Write-Host "        python -m pip install reportlab pdfplumber pypdf" -ForegroundColor Yellow

Write-Host ""
Write-Host "==> 完成！" -ForegroundColor Cyan
Write-Host "    1) 重启 dsh web（或刷新页面后新建会话）" -ForegroundColor Green
Write-Host "    2) 新建会话时在预设选择器里选「数据分析模式」" -ForegroundColor Green
Write-Host "    3) 技能目录对所有会话实时可见" -ForegroundColor Green
