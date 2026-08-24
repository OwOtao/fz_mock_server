# 放置江湖 客户端-服务端 协议分析报告

> 基于已解密的客户端 Lua 源码 (`fzjh_lua`) 自动提取。
> 提取时间: 2026-08-04 ｜ 客户端版本: 2.1.02

---

## 一、协议全景

客户端与服务端存在 **三条通信通道**, 分别服务不同业务:

| 通道 | 传输 | 编码 | 用途 | 关键源码 |
|------|------|------|------|---------|
| 主业务 HTTP | HTTP POST/GET | JSON + JM 加密 | 账号/角色/商店/任务/邮件等全部业务 | `app/extends/Http/` |
| 实时战斗网关 | WebSocket / TCP | JSON + 帧序列化 | PVP / 副本网络战斗 | `app/models/OnlineGame/`、`app/FightSystem/NetworkBattle/` |
| 热更下载 | HTTP | 明文 + 版本清单 | 更新 Lua/资源(含缺失的 net 模块) | `views/UpdateLayer.lua` |

---

## 二、主业务 HTTP 协议 (676 个方法)

### 2.1 协议形态

- 域名: `Game:getDomain() .. "api/v5/"` (BaseHttp.lua)
- 服务器发现: `getServerList` / `getServerList2` → `SwitchServerController`
- 请求: JSON 序列化 → `JM:stringEncrypt(data, version)` 加密 → POST body
- 响应: `JM:stringDecrypt` → `json.decode` → `{status, errcode, errmsg, data}`
- 加密版本: `GameChannelContext:getHttpEncryptVersion()` / `getEncryptVersion()` (多版本可切换)

### 2.2 协议清单(676 个, 完整清单见 protocol_inventory.json)

| 分类 | 数量 | 示例 |
|------|------|------|
| POST | 463 | `buyGoods`、`createRole`、`makeWeapon`、`checkLogin` |
| GET | 210 | `getTime`、`getStoreData`、`downloadUserData`、`getRankingList` |
| unknown | 3 | `async`(通用入口)、`getCheatType`(本地) |

URL 命名规则: `snake_case` 路径, 与方法名对应:
- `getTime` → `get_time`
- `createRole` → `create_role`
- `buyGoods` → `buy_goods/`
- `uploadUserData` → `upload_user_file_3`
- `getRankingList` → `get_rank_list_4`

### 2.3 关键协议示例

```lua
-- 登录
HttpManager:checkLogin(postData, func, ...)
  -> POST {DOMAIN}login  body=postData

-- 购买商品
HttpManager:buyGoods(id, itemId, count, trans_id, others, discount, ...)
  -> POST {DOMAIN}buy_goods_3/{id}  body={id, itemId, quantity, client_trans_id, discount}

-- 角色存档上传/下载
HttpManager:uploadUserData(uType, ...)   -> POST {DOMAIN}upload_user_file_3
HttpManager:downloadUserData(...)        -> GET  {DOMAIN}download_user_file_2

-- 服务器列表
HttpManager:getServerList2(...)          -> GET  {DOMAIN}get_server_list_2
```

---

## 三、实时战斗协议 (帧同步)

### 3.1 架构

网络战斗采用 **帧同步**(lockstep) 模型:
- 逻辑帧率 10 FPS (`LOGIC_FPS = 10`), 渲染帧率 30 FPS
- 客户端主机(host)上传逻辑帧, 服务端广播
- `Frame:serialize()` 序列化帧数据

### 3.2 OnlineGame 事件协议 (WebSocket)

```lua
-- 事件类型 (e 字段)
e=301  RPC 调用      {e, ni=networkId, fn=funcName, ps=args}
e=302  请求唯一Id    {e=302}
e=303  返回唯一Id    {EventType=303, OnlyId=xxx}
e=304  逻辑帧        {e=304, ni=network_id, frame=frame_data}

-- 连接: ws://{ip}:{port}/game  (NetworkingPeer.lua)
```

### 3.3 副本网络战斗 (app/models/net/* 缺失模块)

`MapNetBattle.lua` 调用但 **APK 内缺失** 的模块:

```lua
require("app.models.net.NetConf")    -- GATE_HOST / GATE_PORT 网关地址
require("app.models.net.NetNode")    -- 网关连接节点 (subid/secret/sconv 会话)
require("app.models.net.LoginNet")   -- 战斗登录

-- 网关消息 (request 协议名):
--  create_fight_room          创建战斗房间
--  notify_client_change_fight_scene  服务器通知开战
```

⚠️ **关键边界**: 这三个模块在 APK 中不存在, 属于热更下载。意味着:
1. 网关地址(GATE_HOST/PORT)不在静态包内
2. 战斗登录会话(subid/secret/sconv)生成规则不可见
3. 网关消息序列化格式需要抓包或热更文件才能确认

---

## 四、热更机制

- 启动时 `UpdateLayer` 检查更新
- 缺失的 `app/models/net/*` 模块通过热更获取
- 版本控制: 服务器下发版本清单, 客户端按需下载

---

## 五、倒推服务端可行性边界

| 能力 | 状态 | 说明 |
|------|------|------|
| 676 个 HTTP API 契约 | ✅ 已提取 | URL/方法/参数/响应结构 |
| 请求/响应加密 | ✅ 已破解 | AES-256-CBC + JM 多版本 |
| 错误模型 | ✅ 已提取 | status + errcode + errmsg |
| 服务器发现 | ✅ 已提取 | getServerList 接口 |
| PVP 帧同步事件 | ✅ 已提取 | e=301~304 事件格式 |
| 战斗网关地址/会话 | ❌ 缺失 | app/models/net/* 热更 |
| 服务端权威逻辑 | ❌ 不可见 | 需自研 |

**结论**: HTTP 业务协议可完整还原; 实时战斗的网关层因核心模块热更缺失, 需抓包辅助; 服务端结算/校验逻辑需基于客户端公式表重建。
