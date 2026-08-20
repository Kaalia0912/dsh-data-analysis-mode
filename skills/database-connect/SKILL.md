---
name: database-connect
description: 通过 SQLAlchemy 连接 MySQL / PostgreSQL 数据库并安全查询（原创技能，MIT）：连接串构造、凭据管理、read_sql 读取、只读规范。当任务需要连数据库取数、查询线上库或导出表时加载。
---

# database-connect — 数据库连接与查询

本技能定义通过 SQLAlchemy 连接 MySQL / PostgreSQL 的标准姿势，强调**安全与可复现**。

## 依赖

```bash
python -m pip install sqlalchemy pymysql psycopg2-binary
```

## 连接串

```python
from sqlalchemy import create_engine

# MySQL
engine = create_engine("mysql+pymysql://user:pass@host:3306/dbname?charset=utf8mb4")

# PostgreSQL
engine = create_engine("postgresql+psycopg2://user:pass@host:5432/dbname")
```

**凭据纪律（必须遵守）**：
- 不把密码硬编码进脚本/代码；从环境变量读：`os.environ["DB_PASSWORD"]`
- 不在对话中回显密码；日志/报告里绝不出现连接串明文
- 建议使用只读账号；确需写入时先向用户确认

## 安全查询

```python
import os, pandas as pd
from sqlalchemy import create_engine, text

engine = create_engine(
    f"mysql+pymysql://{os.environ['DB_USER']}:{os.environ['DB_PASSWORD']}@{os.environ['DB_HOST']}/dbname"
)

# 只读事务（推荐）
with engine.connect() as conn:
    df = pd.read_sql("SELECT * FROM orders LIMIT 100", conn)

# 参数化查询（禁止字符串拼接 SQL）
with engine.connect() as conn:
    df = pd.read_sql(text("SELECT * FROM orders WHERE region = :r LIMIT 50"), conn, params={"r": "华东"})
```

## 规范

- **先探查后取数**：`SHOW TABLES` / `SELECT COUNT(*)` / `DESCRIBE` 确认结构与规模，再决定全量或抽样
- **大表**：先 `LIMIT` 验证，再按需取列（`SELECT 需要的列`，不要 `SELECT *`）
- **索引意识**：`WHERE` 条件若慢，提示用户确认表索引；不在连接技能里做危险操作
- **编码**：MySQL 连接带 `charset=utf8mb4`，避免中文乱码
- **时区**：数据库时间默认 UTC 时注意 `datetime` 转换；读回后统一 `pd.to_datetime`

## 交付

- 查询脚本可复现：连接参数来自环境变量，查询语句与日期范围写明
- 结果给出口径说明（取数时间、过滤条件、表版本）
- 用完关闭连接（`engine.dispose()` 或 with 块自动释放）

## 检查清单

- [ ] 凭据来自环境变量，无明文密码
- [ ] SQL 参数化，无拼接注入风险
- [ ] 先探查后取数，大表有 LIMIT/列裁剪
- [ ] 结果附口径说明（取数时间、条件、表）
