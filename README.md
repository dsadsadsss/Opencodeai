# Opencodeai

中转群大佬的opencode ai


# opencode2api 服务部署说明

## 启动参数

> ```
> -password  -port
> ```

因此采用了更稳定的代理方案：

## 服务架构

| 组件 | 说明 |
|------|------|
| 后端 `opencode2api` | 跑在本机 `8001` 端口 |
| 前端 `8000` | 增加密码代理 |
| 管理页面 `/api/config`、`/api/stats` | 需要登录验证 |
| `/health` 和 `/v1/*` | 保持免登录，避免 OpenClaw fallback API 调用被密码拦住 |
| OpenClaw 的 `opencode-ds` provider | 已改为直连本机后端：`http://127.0.0.1:8001/v1` |

## 登录信息

## 配置说明

### 推理力度映射

| 请求值 | 映射值 |
|--------|--------|
| `low` | `high` |
| `medium` | `high` |
| `xhigh` | `max` |

> ☑️ **强制禁用思考模式**（可选）— 勾选后移除所有推理内容

### 模型映射

| 别名（请求名） | 实际模型（上游名） |
|---------------|------------------|
| `claude-haiku-4-5-20` | `mimo-v2.5-free` |
| `claude-opus-4-7` | `mimo-v2.5-free` |
| `claude-sonnet-4-6` | `mimo-v2.5-free` |
