# getMd5List 覆盖流程 vs `so/ProxyPin9-10_18_00_08.har`（2.1.02）

结论先行：**机制上 2.1.02 能覆盖本地 lua 的 md5（已用该抓包真实 body 端到端验证通过），但设备实测证明它没有保住修改过的 DebugLayer —— 17:58 官方整包 updatePackage 把 12 个 DebugLayer 文件全部写成 9 字节存根 `return {}`。**

## 1. 9-10 抓包事实（entry 14，GET http://update.xiaohoutiaotiao.com/v1/getMd5List）

| 项 | 值 |
| --- | --- |
| 请求头 | `ver=2.1.02`、`hotver=15427`、`uuid=guanfangd0b80cf7aa09ea3538329b0d`、`accept-encoding=identity` |
| 响应体 | 2281164 字节 hex 文本，md5 = `86960c85c233098d9dfd82db2cbfce13` |
| 密文布局 | `hex( JHHU02(6B) + AES-256-CBC )`，偏移 6，**固定 IV**，块对齐 OK |
| 解密密钥组 | 唯一能解出 JSON 的是 JHHU02：key=`cbIhHHuYQIJ1JkwlLupIvNIvdQDfNxSF`，iv=`PcIQIZifRalhZ88n`（= `config.KEY_GROUPS["default"]`） |
| 明文 | 1140573 字节，顶层 `errcode` + `data.{originalMd5List, deployMd5List}` |
| 清单规模 | original=10476、deploy=3767、交集=3512、仅 original=6964、仅 deploy=255 |

## 2. 与当前覆盖流程的逐条差异

| # | 抓包（2.1.02） | 当前实现 `handlers/service.py` | 影响 |
| --- | --- | --- | --- |
| 1 | 响应密文 `JHHU02` | `_update_cipher` 按密文魔数选组，JHHU02/JHHU01 都支持 | 一致，覆盖可生效 |
| 2 | 清单 md5 = **热更文件字节的 md5** | `_debug_file_md5` = `md5(path.read_bytes())`（不再二次加密） | 一致；已用 9-10 数据复核 |
| 3 | 两表：original=全量、deploy=3.7k | 两表都写、缺键补建 | 一致（26 项替换 = original 10 + deploy 16，其中 5 个是补建键） |
| 4 | 客户端只发 `ver/hotver/uuid/device/sig` | `_proxy_update_response` 原样转发 12 个头、不改写 hotver | 一致 |
| 5 | 响应约 2.23MB | `UPDATE_RESPONSE_LIMIT = 8MB`，超限走 502 | 一致（余量足够；若清单继续膨胀到 8MB 会整条链路失效） |
| 6 | — | 旧快照 `D:\DTest\ds\service.py`（根目录，12:05 保存）**仍是 JHHU01-only**、且用 `_jhhu01_cipher` 解密 | **若跑的是这份，2.1.02 必然覆盖不了**：魔数检查直接抛错，原样返回上游清单 |

## 3. 端到端验证（用 9-10 真实 body）

- 完整性校验通过（魔数 hex 前缀、hex 合法、块对齐、Content-Length 自洽）
- 解密 → 替换 → 按原组 JHHU02 重加密，输出仍是 JHHU02，条目数不丢（original 10476 / deploy 3767→3772）
- 本地 16 个覆盖键（`debug/` 15 个 + `patched/MainLayer.lua`）**全部存在于上游 originalMd5List**，无缺失键
- 覆盖后两表 16/16 都等于本地文件 md5；Content-Length/ETag 已重写

升级前 → 覆盖后（节选）：

| 清单键（尾名） | 本地文件 md5 | 上游 original | 上游 deploy | 覆盖后 |
| --- | --- | --- | --- | --- |
| DebugLayer.lua | 4f19fe6a | 438a9ecd | 2d5e3665(存根) | 4f19fe6a |
| GMLayer.lua | 4e14d277 | 765476fc | 2d5e3665 | 4e14d277 |
| TestLayer.lua | 99095949 | f0cdad98 | 2d5e3665 | 99095949 |
| MainLayer.lua | 3933b688 | a03eb5c6 | 无 | 3933b688 |
| DebugConfig.lua | 33297f8f | 33297f8f（本来就同） | 无 | 33297f8f |

## 4. 为什么设备上还是被还原了

设备（emulator-5558, root）实测：

```
/data/data/com.xhtt.app.fzjh/files/updatePath_android_2.1.02/
  app.lst                      {"version":15427}     写入时间 2026-09-10 17:58
  updatePackage                294505945 字节        17:58
  src/app/views/layer/DebugLayer/{DebugLayer,AnimTestLayer,GMLayer,TestLayer,...}.lua
                               全部 9 字节 = b"return {}"  md5=2d5e3665   17:58
```

- 官方 2.1.02 热更包里 DebugLayer 本来就是 12 个 9 字节存根（`research/updatePath_android_2.1.02` 同样如此），即**官方用存根关掉调试层**。
- 时间线：`17:42–17:46` mock 正常覆盖（server.log: 替换 26/28 项，magic=JHHU02）→ 之后 server.log 再无任何请求 → `17:57–17:58` 设备写出整包 `updatePackage` 并铺开文件树，DebugLayer 全被写成存根。
- 也就是说：**getMd5List 的覆盖只影响"客户端认为哪个文件需要更新"，挡不住 `checkUpdate` 返回整包后的实际下载/铺开**。9-10 抓包里 entry 1/47/53 就是客户端按 `checkUpdate.data.cdn` 去 cdn1 取 `updatePackage` 的证据。
- 覆盖生效的那几轮（17:39/17:42/17:46，客户端拿到的清单里本地 md5 已就位）也不能阻止这一次整包落盘：整包是"文件系统级写入"，不是按 md5 清单逐文件校验下载。

## 5. 结论：2.1.02 能不能覆盖到我修改的 lua 文件 md5

- **能**（机制层面，已用 9-10 抓包端到端验证）：只要跑的是 `mock_server/handlers/service.py` 这一版（按魔数选组），2.1.02 的 JHHU02 清单会被解密、16 个本地键全部命中并被改成本地文件 md5，再按 JHHU02 重新加密返回。
- **不能只靠它保住文件**（实测层面）：官方 2.1.02 的整包/热更文件会把这 12 个 DebugLayer 覆盖成 `return {}` 存根。要真正保住，还需要：
  1. `checkUpdate` 让客户端维持当前 `hotver`（不触发整包下载），或
  2. 在整包铺开后重新注入本地 lua（脚本/二次推送），或
  3. 把要保留的文件键同时放进 `deployMd5List`（现已做）**并且**确认客户端不会用本地缓存的旧 md5 映射再拉一遍（`UpdateManager:saveFileNameAndMd5Map/loadFileNameAndMd5Map` 会把映射落盘）。
- 另有一处必须确认：**别跑根目录那份 `D:\DTest\ds\service.py`**。它是 JHHU01-only 的旧快照，对 2.1.02（JHHU02）会解密失败并原样返回上游清单 —— 那种情况下覆盖一定不生效。

## 6. 复核脚本

```
cd mock_server
python scripts/update/_analyze_md5_har_910.py        # 抓包 → 覆盖链路逐项核查
python scripts/update/_compare_md5_har_versions.py   # 9-1(2.1.01)/9-9/9-10 两表语义与命中面对比
python scripts/update/_analyze_pkg_vs_upstream.py    # 官方 2.1.02 包 vs 上游清单 (证明 DebugLayer 是存根)
python scripts/update/_probe_device_update_tree.py   # 设备热更目录现状 (只读)
python scripts/update/_verify_md5_override.py        # 覆盖/完整性/兼容性断言 (全部通过)
```
