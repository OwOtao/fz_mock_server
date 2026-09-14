# 放置江湖 Mock Server

本地 mock 服务端，用于离线运行与调试《放置江湖》客户端：完整复现 JM 加密协议、
账号/存档链路，并按抓包数据补齐业务接口。接口约定来自已逆向的客户端代码
（`BaseHttp.lua` / `GameChannelContext.lua` / `OnlineGameStrategy.lua`）与 HAR 抓包。

**规模**：路由表共 **283 个唯一接口**（292 处 `@route` 注册，9 处被后加载模块覆盖，
见 [已知限制](#已知限制)），分布在 12 个 handler 模块；服务端运行时代码零第三方依赖。

## 功能概览

| 模块 | 内容 |
|------|------|
| **协议加密** | JM 加密完整实现（AES-256-CBC），`JHHU02` / `FZJH03` / `FZJH02` / `FXXF03` 多密钥组，按魔数自动识别、按路径路由响应组 |
| **账号与存档** | 账号创建/登录、设备 UUID 持久化、存档上传下载、多存档切换、种子档导入、按 `userid` 分文件落盘 |
| **系统服务** | `get_game_config` / `exchange_publickey` / `get_version_info` / `get_uuid`、分区列表、埋点上报、屏蔽词与实名 |
| **更新代理** | `checkUpdate` / `getMd5List` 透传上游，双版本魔数（`JHHU01` 2.1.01 / `JHHU02` 2.1.02），支持热更 md5 覆盖 |
| **商城** | 限时礼包、武林卷轴、直购道具、藏衣阁/玄兵洞清单、活动积分兑换、黑市与锻造图谱 |
| **签到与活动** | 49 天赛季签到与补签、每日任务、20 项活动总表、限时历练、十周年登录奖励、天缘奇盒、易金圩市、通武积市 |
| **家园** | 多户型数据（从 `familytype.lua` 自动生成）、购房/换房、管家雇员、房间家具、多城市家具商店 |
| **家园调试面板** | `test_homeland/1..8`（忠诚度/删仆人/随机特性/删家园/仆人列表/地皮状态）、`make_servant_change`（闹事/离开/云游）、`set_auction_time`、`update_currency_by_type`（全局货币增删） |
| **拳脚** | 五分支数据、修行任务列表与周冷却、挂机/加速/完成结算、解锁标记 |
| **挑战副本** | 预览→确认扣费→续玩→离开，轶闻值恢复，普通通关与扫荡奖励（服务端随机），详见 [docs/challenge-map.md](docs/challenge-map.md) |
| **师门** | 师门建筑兴建/升级、日常任务流转、捐献与名位、师门建树、同门亲密度、门派指点 |
| **修炼** | 练功、修炼、心神系统、物品使用与成就解锁记录 |
| **挂机与竞技** | 挂机任务与押镖时间、比武场（观战/参战/结算）、排行榜与称号 |
| **邮件** | 管理员发信接口（`x-admin-token` 鉴权 + `request_id` 幂等）、深层 body 提取、奖励发放与领取 |

## 目录结构

```
fz_mock_server/
├── run.py                  # 启动入口（含优雅关闭）
├── server.py               # HTTP 服务器、路由注册与分发、在途请求跟踪
├── protocol.py             # 协议层：请求解析、响应构造、签名
├── config.py               # 全局配置（密钥、路径、开关）
├── jm_crypto.py            # JM 加密核心（pycryptodome 可选，否则纯 Python AES）
├── state.py                # 状态存储（账号、订单、邮件、活动、排行、比武…）
├── archive_store.py        # 存档文件管理（原子写 + Windows 重试）
├── lua_to_json.py          # 手写 Lua 表解析器（运行期读取客户端配置表）
├── unpack_update.py        # 热更包解包 / 单文件解密（需 pycryptodome）
├── stop.ps1                # 结束占用 8080 的进程并重启服务
├── server.log              # 运行日志（gitignore）
├── handlers/               # 接口处理器（12 个模块，共 292 处路由注册）
│   ├── system.py           #  26 账号、登录、存档上传下载/切换
│   ├── service.py          #  38 系统服务、更新代理、md5 覆盖、埋点上报
│   ├── basic.py            #  89 商城、签到、邮件、排行、比武、货币、神兵
│   ├── har_91.py           #  32 9-1 抓包接口、活动配置与状态行为
│   ├── practice.py         #  25 练功、修炼、心神、物品与成就
│   ├── homeland.py         #  27 家园、雇员、家具、调试面板
│   ├── teacher_build.py    #  22 师门建筑、任务、捐献、建树、指点
│   ├── fist.py             #  12 拳脚五分支与修行链路
│   ├── challenge_map.py    #  11 挑战副本与轶闻值恢复
│   ├── hangup.py           #   5 挂机任务与押镖
│   ├── daily_task.py       #   3 每日任务
│   ├── black_market.py     #   2 黑市
│   ├── challenge_rewards.py   # 挑战奖励掷点（无路由，被 challenge_map 调用）
│   ├── role_trait_data.py     # 角色特性表（由 scripts/gen/_gen_trait_data.py 生成，勿手改）
│   └── familytype_data.py     # 户型数据（由 scripts/gen/_extract_familytype.py 生成，勿手改）
├── tests/                  # 自足 unittest（无需服务、不碰 data/）
│   ├── test_*.py           # 12 个模块：状态/更新/抓包/拳脚/挑战/家园/口径审查
│   └── legacy/             #  6 个需本地 APK 的历史脚本（test_crypto / test_xxtea* / verify_key）
├── scripts/                # 开发与排查脚本（均非运行期依赖）
│   ├── audits/             #  13 覆盖率与一致性审查（离线可跑）
│   ├── har/                #  17 HAR 解密/查看/重放/密钥分析
│   ├── update/             #  35 热更 checkUpdate / getMd5List / 上游诊断
│   ├── verify/             #  11 针对运行中服务的端到端验证（会写 data/）
│   ├── probes/             #  10 一次性数据探针与查看器
│   └── gen/                #   3 由客户端资源生成 handlers 数据表
├── debug/                  # DebugLayer 补丁源码（getMd5List 覆盖源）
├── DebugLayer/             # DebugLayer 明文源（tools/encrypt_debug.py 的输入，未入 git）
├── patched/                # MainLayer.lua / MainLayer.2.1.02.lua 热更补丁
├── item_json/              # 客户端表导出的 JSON 参考数据（无运行期引用）
├── fzjh_lua/               # 客户端反编译 Lua 源码 + 协议字典（参考）
├── so/                     # HAR 抓包、解密产物、so 库与导出函数明细
├── tools/                  # 解密/推送/重加密工具 + Frida hook 与启动器
├── research/               # 密钥爆破、so 反汇编、样本
├── docs/                   # 密钥、原生分析、挑战副本、覆盖率审查与流程文档
├── archives/               # 早期布局遗留存档（当前配置不再读写）
├── data/                   # 运行期数据：state.json + archives/（gitignore）
└── .diagnostics/           # 调试期截图与上游样本（gitignore）
```

> 归类说明：**运行期模块平铺在根目录**（`server` / `config` / `handlers` 之间按顶层模块名
> 互相 import），开发脚本一律收进 `tests/` 与 `scripts/`。脚本内用 `__file__` 向上定位
> mock_server 根，因此既可在仓库根也可在任意 cwd 直接 `python scripts/<组>/<脚本>.py` 运行；
> 少数按 cwd 相对路径读文件的脚本（如 `scripts/audits/_check_routes.py`）仍需在
> `mock_server/` 下执行。

## 快速开始

### 环境要求

- Python 3.8+（开发环境为 3.12）
- **服务端本体零第三方依赖**（仅标准库）；装有 `pycryptodome` 时
  `jm_crypto` 会自动改用 C 实现加速，未安装则回退纯 Python AES
- 运行测试推荐 `pytest`，也可用标准库 `unittest`

### 启动服务

```bash
cd fz_mock_server
python run.py
```

服务默认监听 `0.0.0.0:8080`，日志同时输出到控制台和 `server.log`。
`stop.ps1` 可一键结束占用 8080 的进程并重启。

客户端侧需把 `config.DOMAIN` 改为模拟器可访问的宿主机地址，例如
`http://192.168.5.10:8080`。

### 运行测试

9 个 unittest 测试模块共 **209 个测试**，全部自起临时服务/内存状态，**不会碰 `data/` 里的真实存档**：

```bash
cd fz_mock_server
# 推荐：pytest 原生收集 unittest.TestCase
python -m pytest tests/test_state.py tests/test_update_proxy.py tests/test_har_91.py \
  tests/test_fist.py tests/test_challenge_entry.py tests/test_challenge_lifecycle.py \
  tests/test_challenge_rewards.py tests/test_homeland_return.py tests/test_homeland_debug.py -v

# 等价的标准库写法（无需 pytest）
python -m unittest tests.test_state tests.test_update_proxy tests.test_har_91 \
  tests.test_fist tests.test_challenge_entry tests.test_challenge_lifecycle \
  tests.test_challenge_rewards tests.test_homeland_return tests.test_homeland_debug -v

# 单模块直接运行（脚本自带 sys.path 处理，任意 cwd 均可）
python tests/test_state.py
```

注意事项：

- **请先停掉 `python run.py`**：`tests/test_update_proxy.py` 里的 `create_server(..., 0, ...)`
  会因为 `port or config.PORT` 落到 **8080**，与开发服务冲突。
- **不要执行不带文件名的裸 `python -m pytest`**：默认收集会连带拉起 `tests/legacy/` 下的
  `test_xxtea*.py` 与 `test_crypto.py`，它们需要本地 APK 且在导入期执行代码，会产生收集错误。
  （`tests/legacy/` 无 `__init__.py`，`python -m unittest discover -s tests` 不会递归进去。）
- 上述 9 个模块只用标准库，`pytest` 仅作为收集器（`python -m unittest` 是纯标准库等价写法）。

### 需要本地大文件的脚本

以下脚本依赖已被 `.gitignore` 排除或不在本机的文件，**开箱即跑会报错**，
需要自备 APK 后才能使用：

| 脚本 | 依赖 |
|------|------|
| `tests/legacy/test_crypto.py` | `tools/frida/fzjh_base.apk` |
| `tests/legacy/test_xxtea.py` / `test_xxtea_enc.py` / `test_xxtea_var.py` / `test_xxtea_var2.py` | 写死本机 APK 路径的 XXTEA 密钥爆破分析 |
| `tests/legacy/verify_key.py` | 同上；亦可不带文件直接解密密文 |
| `scripts/verify/verify_archive_flow.py` | `data/seed/RoleData.json`（种子档） |

### 端到端验证脚本

以下脚本针对**正在运行的 8080 服务**（`config.HOST` / `config.PORT`）发真实加密请求，
**会写入真实 `data/`**：每个脚本会新建测试账号（如 `92xxxxxxxx`、`93xxxxxxxx`、
`96xxxxxxxx`、`97xxxxxxxx`），不再使用时请手动清理 `data/archives/` 与 `data/state.json`。

```bash
python scripts/verify/test_client.py            # 模拟客户端全链路（账号/存档/邮件/比武）
python scripts/verify/verify_join_family.py     # 拜师与隐藏门派
python scripts/verify/verify_sect_guidance.py   # 师门指点
python scripts/verify/verify_teacher_build.py   # 师门任务与建筑兴建
python scripts/verify/verify_teacher_build_flow.py  # 师门任务流转 + 捐献/名位升级
python scripts/verify/verify_teacher_feat.py    # 师门建树
```

自带临时服务、不影响真实数据的专项验证：

```bash
python scripts/verify/_test_fist_e2e.py         # 拳脚系统端到端（临时服务 + 临时存档，端口 MOCK_FIST_E2E_PORT）
python scripts/verify/_test_shop_info_e2e.py    # 活动充值积分兑换
python scripts/verify/_test_zhao_upgrade_matters.py  # 续卷链路
```

## 配置说明

核心配置集中在 [config.py](config.py)：

| 配置项 | 说明 | 默认值 |
|--------|------|--------|
| `HOST` / `PORT` | 监听地址与端口 | `0.0.0.0:8080` |
| `DOMAIN` | 客户端访问的服务域名 | `http://192.168.5.10:8080` |
| `API_PREFIX` | 业务接口前缀 | `api/v5/` |
| `ENCRYPT_RESPONSE` | 是否整体加密响应（关闭便于调试） | `True` |
| `RESPONSE_GROUP` | 默认响应加密组 | `FZJH03` |
| `RESPONSE_GROUP_BY_PATH` | 按路径覆盖响应组的例外表 | 见 config.py |
| `T_TOKEN` | 响应签名 token（`get_token` 下发同值） | `mock_fzjh_token_2026` |
| `SKIP_SIGN_URLS` | 客户端不校验签名的接口白名单 | `get_time` / `get_token` / `report_cheat` / `getWebConfig` |
| `STATE_AUTOSAVE` | 状态自动落盘（`False` 则仅内存） | `True` |
| `SEED_IMPORT_ON_START` | 启动时导入种子档 | `True` |
| `SEED_ROLEDATA_PATH` | 种子档路径 | `data/seed/RoleData.json` |
| `ARCHIVES_DIR` | 存档目录 | `data/archives` |
| `ADMIN_API_TOKEN` | 管理员发信鉴权；**留空则不校验** | `""` |
| `MOCK_DEVICE_UUID` | `get_uuid` 返回的固定设备号 | `guanfangd0b80cf7aa09ea3538329b0d` |
| `MD5_OVERRIDE_ENABLED` | 是否用本地文件 md5 覆盖 `getMd5List` 清单 | `True` |
| `MD5_OVERRIDE_DIR` | 覆盖源目录 | `debug/` |
| `MD5_OVERRIDE_EXTRA_FILES` | 额外覆盖项（支持按版本取文件） | `MainLayer.lua` |
| `UPDATE_UPSTREAM_BASE` | 更新代理上游地址 | `http://update.xiaohoutiaotiao.com/v1` |
| `UPDATE_UPSTREAM_TIMEOUT` | 上游超时（秒） | `10` |
| `UPDATE_CIPHER_GROUPS` | 更新接口按版本使用的密钥组 | `JHHU01` / `JHHU02` |

### 环境变量

以下参数由环境变量注入（修改后需重启）：

| 变量 | 默认值 | 说明 |
|------|--------|------|
| `MOCK_SHUTDOWN_TIMEOUT` | `5.0` | 优雅关闭时等待在途请求的最长秒数 |
| `MOCK_ADMIN_API_TOKEN` | `""` | 同 `config.ADMIN_API_TOKEN` |
| `MOCK_DEVICE_UUID` | 见上 | 同 `config.MOCK_DEVICE_UUID` |
| `MOCK_UPDATE_UPSTREAM_BASE` | 见上 | 同 `config.UPDATE_UPSTREAM_BASE` |
| `MOCK_UPDATE_UPSTREAM_TIMEOUT` | `10` | 同 `config.UPDATE_UPSTREAM_TIMEOUT` |
| `MOCK_ANECDOTE_MAX` | `100` | 挑战副本轶闻值恢复上限 |
| `MOCK_ANECDOTE_RECOVER_SECONDS` | `600` | 每恢复 1 点轶闻值所需秒数 |
| `MOCK_CHALLENGE_SESSION_SECONDS` | `86400` | 挑战副本会话有效秒数 |
| `MOCK_FIST_E2E_PORT` | `18099` | `_test_fist_e2e.py` 使用的端口 |
| `ADB` | `D:\Program Files\platform-tools\adb.exe` | `tools/push_hotupdate.py` 使用的 adb 路径 |

运行时数据统一写入 `data/`（`state.json`、`archives/`），已被 `.gitignore` 忽略。

## 优雅关闭

`python run.py` 收到 `Ctrl+C`（SIGINT）、SIGTERM 或关闭窗口（SIGBREAK）时会优雅关闭：

1. 停止 accept 循环并关闭监听 socket，端口可立即重新绑定；
2. 等待在途请求处理完（最长 `MOCK_SHUTDOWN_TIMEOUT` 秒），超时则断开剩余连接；
3. 落盘登录/存档状态（`data/state.json` 与 `data/archives`）；
4. flush 并关闭日志文件句柄（`server.log`）。

关闭过程中再按一次 `Ctrl+C` 会立即强制退出。

## 加密协议

客户端与服务端通信采用 JM 加密，格式为 `hex(魔数 + AES-256-CBC 密文)`，
明文用 ASCII `'0'` 补齐到 16 字节块（块满补整块）。

密钥直接使用 32 字节 ASCII 字符串（**不做 hex 解码**），通过静态分析
`libcocos2dlua_arm64.so` 确认：

- `AES_set_decrypt_key(key_data, 256, schedule)` 直接使用 key 原始 ASCII 字节
- IV 为空时使用默认值 `34857d973953e44a`

当前实现 4 个密钥组（`config.KEY_GROUPS`）：`default`（`JHHU02`）、`FZJH03`、
`FZJH02`、`FXXF03`。请求侧按密文魔数自动识别密钥组并逐个尝试解密；响应侧由
`RESPONSE_GROUP_BY_PATH` 按路径路由，未命中时用 `RESPONSE_GROUP`。

响应签名头为 `signature = md5(time & nonce & 响应体密文 & T_TOKEN)`，
`SKIP_SIGN_URLS` 中的接口不签名。`gzip`/`zlib` 压缩体、UTF-16 编码体、
被 `Content-Type: form` 误标的整包密文均做了兼容处理。

密钥来源与推导过程见 [docs/native-crypto-analysis.md](docs/native-crypto-analysis.md)；
[docs/encryption-keys.md](docs/encryption-keys.md) 记录了密钥汇总与推导历史，
但其密钥总表已过期（见 [已知限制](#已知限制)），当前有效值以
[config.py](config.py) 的 `KEY_GROUPS` 与 `handlers/service.py` 的 `PUBLIC_KEYS` 为准。

## 开发约定

**新增接口**：在 `handlers/` 对应模块中用装饰器注册，随后在 `handlers/__init__.py`
中导入该模块（否则不会生效）：

```python
from protocol import build_response_body
from server import route

@route(["POST"], "my_api")
def my_api(ctx):
    return build_response_body({"ok": True})
```

`ctx` 提供 `method` / `path` / `query` / `headers`（小写键）/ `body`（已解密解析）/
`raw_body` / `encrypted` / `state` / `route` / `route_tail`。
返回 `build_response_body(...)` 同构 dict；返回 `None` 视为未处理（404）。
handler 抛异常会被捕获并返回 `errcode=500`，不会中断服务。

**调试开关**：`ADMIN_API_TOKEN` 留空时 `admin_send_email` 不校验鉴权，仅适合本地调试；
`config.ENCRYPT_RESPONSE = False` 可发明文响应便于抓包比对。

## 参考数据与文档

客户端与抓包参考：

- `fzjh_lua/`：客户端反编译 Lua 源码（4,372 个 `.lua`），含
  `protocol_inventory.json` / `protocol_inventory.csv`（676 个客户端接口清单）、
  [protocol_analysis.md](fzjh_lua/protocol_analysis.md)、
  [protocol_dictionary.md](fzjh_lua/protocol_dictionary.md)、
  [protocol_dictionary_deep.md](fzjh_lua/protocol_dictionary_deep.md)
- `so/`：5 份 `.har` 抓包、`libcocos2dlua_arm64.so`、
  [libcocos2dlua_arm64.md](so/libcocos2dlua_arm64.md)（34,620 行导出函数明细）、
  `har_decrypt_91/`（210 条）与 `har_decrypt_99/`（134 条）解密产物
- `item_json/`：`lua_to_json.py` 导出的物品/奖励/商城 JSON 参考数据
- [docs/research-assets.md](docs/research-assets.md)：工具、样本与大型本地制品的完整索引

各自目录下的分析文档：

- [docs/encryption-keys.md](docs/encryption-keys.md)：JM 密钥总表与来源
- [docs/native-crypto-analysis.md](docs/native-crypto-analysis.md)：so 逆向分析报告
- [docs/challenge-map.md](docs/challenge-map.md)：挑战副本规则、持久化与验证
- [docs/har91_coverage_audit.md](docs/har91_coverage_audit.md) /
  [docs/har99_coverage_audit.md](docs/har99_coverage_audit.md)：9-1 / 9-9 抓包接口覆盖率审查
- [docs/httpmanager_coverage_audit.md](docs/httpmanager_coverage_audit.md)：客户端 Http 层
  （`fzjh_lua/.../extends/Http/`）全量接口 vs 路由表覆盖比对，含 394 个未实现接口的家族清单与优先级建议
  （由 `scripts/audits/_audit_httpmanager_coverage.py` 生成，口径测试见 `tests/test_httpmanager_audit.py`）

## 工具

```bash
# 解密单条 JM 密文（默认 research/samples/test.md）
python tools/decrypt.py [密文hex或文件]

# 批量解密 APK 内 Lua
python tools/decrypt_fzjh_lua.py <apk> [outdir]
python tools/decrypt_fzjh_lua.py --single encrypted.lua -o decrypted.lua

# 按客户端版本加密并通过 adb 推送热更 Lua
python tools/push_hotupdate.py --list
python tools/push_hotupdate.py 2.1.02 --only debug --dry-run

# Lua 表 -> JSON（默认输出到 item_json/）
python lua_to_json.py

# 解包热更包 / 单文件解密（需 pycryptodome）
python unpack_update.py <input> [output]

# 通用 HAR 解密与覆盖率审查
python scripts/har/_har_tool.py decrypt <har_path> <out_dir>
python scripts/har/_har_tool.py audit <entries_dir>
```

`tools/frida/` 下是 Frida hook 脚本（`.js`）与启动器（`run_*.py`，7 个），用于 dump
密钥、AES 映射与 HTTP 密文。三点须知：

- 这些启动器**需要第三方 `frida` 包**，且脚本内 `import` 路径、`adb` 路径、
  APK 路径均为本机硬编码，换机器需先改路径；
- `tools/frida/` 下的 APK / SO / Frida server 均已被 `.gitignore` 排除，当前不存在；
- 不参与服务端运行，也不被任何测试引用。

`scripts/` 下共 89 个开发脚本（HAR 分析、密钥探针、覆盖率审查、上游连通性/耗时定位、
e2e 探针、数据表生成），**均不被服务端运行期引用**，按功能分为 6 个子目录：

| 子目录 | 用途 | 代表 |
|--------|------|------|
| `scripts/audits/` | 覆盖率与一致性审查（离线可跑） | `_audit_httpmanager_coverage.py`、`_check_dup_routes.py`、`_list_routes.py` |
| `scripts/har/` | HAR 解密/查看/重放/密钥分析 | `_har_tool.py`、`decrypt_har_91.py`、`_show_har_entry.py` |
| `scripts/update/` | 热更 `checkUpdate`/`getMd5List`/上游诊断 | `_probe_getmd5list.py`、`_verify_md5_override.py`、`_trace_proxy_path.py` |
| `scripts/verify/` | 针对运行中服务的端到端验证 | `test_client.py`、`verify_teacher_build.py` |
| `scripts/probes/` | 一次性数据探针与查看器 | `_peek_shoplist.py`、`_show.py`、`_grep.py` |
| `scripts/gen/` | 由客户端资源生成 handlers 数据表 | `_extract_familytype.py`、`_gen_trait_data.py` |

其中 `scripts/har/_har_tool.py` 是最通用的一员；会重写运行期模块的生成器在
`scripts/gen/`：`_extract_familytype.py`（→ `handlers/familytype_data.py`）与
`_gen_trait_data.py`（→ `handlers/role_trait_data.py`）。部分脚本写死了本机绝对路径。

`research/so_analysis/` 下的反汇编脚本需要第三方 `capstone` 与 `pyelftools`，
且都通过 `_paths.py` 指向 `research/binaries/libcocos2dlua_arm64_bootstrap.so`
（该目录被 `.gitignore` 排除，当前不存在），因此**开箱不可直接运行**。

## 已知限制

- **路由覆盖**：9 个接口模式被重复注册，后加载的模块生效，被覆盖的实现成为死代码
  （`get_history_notice`、`get_limit_package`、`get_ckitems_list`、`get_game_activity`、
  `get_spring_festival_list`、`get_spring_festival_status`、`get_login_reward_list`、
  `get_user_anecdote`、`challengemap_unfinished`）。
- **端口 0 不回退**：`create_server(host, 0)` 会因 `port or config.PORT` 落到 8080，
  需要临时端口的测试必须同时 `mock.patch.object(config, "PORT", 0)`。
- **存档根目录**：`archives/` 与根 `state.json` 是早期布局的遗留文件，
  当前配置实际读写 `data/` 下的同名路径。
- **`debug/` 与 `DebugLayer/` 内容重复**：两者 15 个同名文件字节完全相同，
  `DebugLayer/` 另多一个 `MainLayer.lua`。运行期只读 `debug/`
  （`config.MD5_OVERRIDE_DIR`，被 `tools/push_hotupdate.py` 引用），
  `DebugLayer/` 是 `tools/encrypt_debug.py` 的明文源且未入 git。合并需同时改
  `config.py`，当前保持两份并存。
- **开发服务与测试抢端口**：`test_update_proxy.py` 会绑定 8080（原因见上），
  跑测试前需停掉 `python run.py`。
- **`.gitignore` 覆盖范围有限**：被忽略的只有运行期数据（`data/`、`state.json`、
  `archives/`）、日志、`__pycache__` 与部分本地大文件。
  `fzjh_lua/`（4,372 个 `.lua`，约 137 MB）与 `so/`（5 份 HAR + so + 解密产物，
  约 81 MB）**仍被 Git 跟踪**，其中单个超 5 MB 的制品就有 6 个
  （`libcocos2dlua_arm64.so` 22.9 MB、两份 HAR 13.6 MB / 7.7 MB 等），
  因此仓库与 `.git/` 体积较大；`item_json/`、`debug/`、`patched/`、`tools/`
  同样在版本控制内。
- **文档与实际略有出入**：
  - [docs/research-assets.md](docs/research-assets.md) 提到的
    `research/binaries/`、`research/legacy/`、`research/updatePath_android_2.1.02/`
    在当前检出中并不存在（对应 `.gitignore` 规则保留）。
  - [docs/encryption-keys.md](docs/encryption-keys.md) 第 1 节的密钥总表是**旧的**，
    与 `config.KEY_GROUPS` 不一致（`FZJH03` / `FZJH02` / `FXXF03` 的 key 与 magic 均不同），
    文中却自称"已配置 / 已验证"且未提示密钥已轮换，引用的还是旧目录名 `mock_server/`。
    **以 [config.py](config.py) 与 `handlers/service.py` 的 `PUBLIC_KEYS` 为准**。
  - [docs/native-crypto-analysis.md](docs/native-crypto-analysis.md) 记录的 so SHA-256
    与当前 `so/libcocos2dlua_arm64.so` 不符（应以
    [so/libcocos2dlua_arm64.md](so/libcocos2dlua_arm64.md) 概要中的值为准），
    并引用了已不存在的 `research/binaries/` 与失效的本地 `file:///` 链接。
- **Mock 规则与正式服差异**：挑战副本的恢复节奏、会话时长、扫荡解锁门槛等
  是便于联调的本地设定，未验证为正式服规则；
  具体见 [docs/challenge-map.md](docs/challenge-map.md)。
