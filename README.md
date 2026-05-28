# Opencodeai

中转群大佬的opencode ai


# opencode2api 服务部署说明

## 架构说明

> ⚠️ 注意：该二进制文件本身**不支持** `-password` 参数，直接使用会报错：
> ```
> flag provided but not defined: -password
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
