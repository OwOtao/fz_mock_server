# 放置江湖 Mock Server

本地 mock 服务端，用于模拟《放置江湖》游戏后端接口，便于离线调试与协议逆向分析。所有接口约定均来自已逆向的客户端代码（`BaseHttp.lua` / `GameChannelContext.lua` / `OnlineGameStrategy.lua`）及抓包数据。

## 功能概览

- **协议加密**：完整实现 JM 加密（AES-256-CBC），支持 `JHHU02` / `FZJH03` / `FZJH02` / `FXXF03` 多组密钥，按路径路由不同加密组
- **账号系统**：账号创建、登录、种子档导入、设备 UUID 持久化
- **存档管理**：角色数据按 `userid` 分文件落盘，支持重启恢复
- **商城系统**：限时礼包、武林卷轴、直购道具，支持购买与元宝扣减
- **签到系统**：49 天赛季制签到、元宝补签、累计奖励领取
- **家园系统**：多户型数据（从 `familytype.lua` 自动提取）、管家、房间布局
- **拳脚系统**：五分支数据、修行任务列表与周冷却、挂机/加速/完成结算、解锁标记
- **活动系统**：20 项活动总表、限时历练、十周年登录奖励、天缘奇盒、易金圩市、通武积市等
- **远端仓储**：藏衣阁/玄兵洞清单、MD5 版本冲突、入库出库与客户端数据分页
- **更新代理**：`checkUpdate` / `getMd5List` 透传至上游更新服务器
- **邮件系统**：管理员邮件发送、深层 body 提取

## 目录结构

```
mock_server/
├── run.py                  # 启动入口
├── server.py               # HTTP 服务器（BaseHTTPRequestHandler）
├── protocol.py             # 协议层：加解密、签名、响应构建
├── config.py               # 全局配置（密钥、路径、开关）
├── state.py                # 状态存储（账号、存档、活动数据）
├── jm_crypto.py            # JM 加密核心实现
├── archive_store.py        # 存档文件管理
├── handlers/               # 接口处理器（按模块拆分）
│   ├── system.py           # 账号、登录、创建
│   ├── service.py          # 服务接口、更新代理、UUID
│   ├── basic.py            # 商城、签到、活动、神兵、仓库
│   ├── homeland.py         # 家园
│   ├── practice.py         # 修炼
│   ├── daily_task.py       # 每日任务
│   ├── hangup.py           # 挂机
│   ├── fist.py             # 拳脚（五分支/修行任务/加速结算）
│   ├── teacher_build.py    # 师门
│   ├── black_market.py     # 黑市
│   ├── familytype_data.py  # 户型数据（自动生成）
│   └── har_91.py           # 9 月 1 日抓包接口、活动配置与状态行为
├── item_json/              # 物品数据（JSON）
├── fzjh_lua/               # 客户端反编译 Lua 源码（参考）
├── so/                     # 抓包数据（.har）与 so 库
├── tools/                  # 解密入口、Frida 工具及本地分析依赖
├── research/               # 密码/SO 分析、样本与更新包快照
├── docs/                   # 密钥和逆向分析文档
├── test_state.py           # 状态与接口测试
├── test_update_proxy.py    # 更新代理测试
├── test_har_91.py          # 9 月 1 日抓包接口回归测试
├── test_crypto.py          # 加密测试
└── verify_archive_flow.py  # 存档流程验证
```

## 快速开始

### 环境要求

- Python 3.8+
- 无第三方依赖（仅使用标准库）

### 启动服务

```bash
cd mock_server
python run.py
```

服务默认监听 `0.0.0.0:8080`，日志同时输出到控制台和 `server.log`。

### 运行测试

```bash
python -m pytest test_state.py test_update_proxy.py test_har_91.py test_fist.py -v
# 或
python -m unittest test_state test_update_proxy test_har_91 test_fist -v
```

拳脚系统的端到端验证（自起临时服务与临时存档，不影响 `data/` 里的真实存档）：

```bash
python _test_fist_e2e.py
```

## 配置说明

核心配置集中在 [config.py](config.py)：

| 配置项 | 说明 | 默认值 |
|--------|------|--------|
| `HOST` / `PORT` | 监听地址与端口 | `0.0.0.0:8080` |
| `DOMAIN` | 客户端访问的服务域名 | `http://10.10.16.55:8080` |
| `ENCRYPT_RESPONSE` | 是否加密响应（关闭便于调试） | `True` |
| `RESPONSE_GROUP` | 默认响应加密组 | `FZJH03` |
| `STATE_AUTOSAVE` | 状态自动落盘 | `True` |
| `SEED_IMPORT_ON_START` | 启动时导入种子档 | `True` |
| `UPDATE_UPSTREAM_BASE` | 更新代理上游地址 | `http://update.xiaohoutiaotiao.com/v1` |
| `MOCK_SHUTDOWN_TIMEOUT` | 优雅关闭时等待在途请求的最长秒数（环境变量，非 config.py） | `5.0` |

运行时数据统一写入 `mock_server/data/` 目录（`state.json`、`archives/`、`seed/`），已在 `.gitignore` 中忽略。

## 优雅关闭

`python run.py` 收到 `Ctrl+C`（SIGINT）、SIGTERM 或关闭窗口（SIGBREAK）时会优雅关闭：

1. 停止 accept 循环并关闭监听 socket，端口可立即重新绑定；
2. 等待在途请求处理完（最长 `MOCK_SHUTDOWN_TIMEOUT` 秒），超时则断开剩余连接；
3. 落盘登录/存档状态（`state.json` 与 `data/archives`）；
4. flush 并关闭日志文件句柄（`server.log`）。

关闭过程中再按一次 `Ctrl+C` 会立即强制退出。

## 加密协议

客户端与服务端通信采用 JM 加密，格式为 `hex(魔数 + AES-256-CBC 密文)`，明文用 ASCII `'0'` 补齐到 16 字节块。

密钥直接使用 32 字节 ASCII 字符串（**不做 hex 解码**），通过静态分析 `libcocos2dlua_arm64.so` 确认：

- `AES_set_decrypt_key(key_data, 256, schedule)` 直接使用 key 原始 ASCII 字节
- IV 为空时使用默认值 `34857d973953e44a`

不同接口使用不同密钥组，由 `RESPONSE_GROUP_BY_PATH` 按路径路由。

## 参考数据

- `fzjh_lua/`：客户端反编译 Lua 源码，包含 UI、地图、技能、商城等完整逻辑
- `so/ProxyPin*.har`：抓包数据，用于协议分析
- `item_json/`：物品、奖励、商城数据
- `docs/research-assets.md`：工具、样本和大型本地制品的完整索引
