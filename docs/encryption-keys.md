# 放置江湖 通信加密 - 密钥总表 (key.md)

> 汇总所有已确认/候选的加密魔数、密钥(key)、初始化向量(IV)及来源。
> 结构与 `mock_server/config.py` 的 `KEY_GROUPS` 对齐。

---

## 1. 核心密钥组 (已配置 / 已验证)

对应 `mock_server/config.py::KEY_GROUPS`。

| 密钥组 | magic | key (ASCII 直接作 AES 密钥) | iv (16B ASCII) | 用途 / 状态 |
|---|---|---|---|---|
| `default` | `JHHU02` | `cbIhHHuYQIJ1JkwlLupIvNIvdQDfNxSF` | `PcIQIZifRalhZ88n` | Lua 脚本文件加解密；已实测 |
| `FZJH03` | `FZJH03` | `26549f871287ba9e838a057a7ffac1bc` | `PcIQIZifRalhZ88n` | HTTP 协议组（生产，来自 exchange_publickey）|
| `FZJH02` | `JHHU02` | `07818f3a34e8165227b0dc6b7e69ea57` | `PcIQIZifRalhZ88n` | 备用协议组 |
| `FXXF03` | `FXXF03` | `07818f3a34e8165227b0dc6b7e69ea57` | `PcIQIZifRalhZ88n` | 备用协议组（与 FZJH02 同 key）|

```
RESPONSE_GROUP = "FZJH03"
```

### 服务响应密钥组按路径映射 (config.RESPONSE_GROUP_BY_PATH)

| 路径 | 密钥组 |
|---|---|
| `api/service/get_game_config` | `default` |
| `api/service/exchange_publickey` | `default` |
| `api/service_android/get_version_info` | `FZJH03` |
| `api/service_android/report_ads_info` | `FZJH03` |

---

## 2. 运行时动态密钥（exchange_publickey 明文）

`/api/service/exchange_publickey` 实际响应解密后的公钥列表：

```json
[
  {"k": "07818f3a34e8165227b0dc6b7e69ea57", "h": "FZJH02"},
  {"k": "26549f871287ba9e838a057a7ffac1bc", "h": "FZJH03", "i": "PcIQIZifRalhZ88n"},
  {"k": "07818f3a34e8165227b0dc6b7e69ea57", "h": "FXXF03"}
]
```

说明：
- `h` = 协议 magic，`k` = key，`i` = iv。
- `FZJH03` 是带 iv 的唯一 HTTP 生产组（AES-256-CBC，key 直接用 32 字符 ASCII 字节）。

---

## 3. initLocalKey 静态密钥（AES-128 候选，32 字符 hex 串 → hex 解码 = 16B）

来源：静态分析 `libcocos2dlua_arm64.so` 的 `initLocalKey`。

| 名称 | 32 字符 hex 串 | 说明 |
|---|---|---|
| `FZJH01` | `ae9b363b80d5cc594973ecce1f4d546d` | hex 解码 16B → AES-128 |
| `JHHU01` | `9B5A96B0F4A1EC60DB88349E3B926765` | hex 解码 16B → AES-128 |
| `JHHU02` | `cbIhHHuYQIJ1JkwlLupIvNIvdQDfNxSF` | 非 hex，直接用 ASCII 32B |

---

## 4. FZJH03 测试(key 轮换调试样本, 非生产)

来源：`JM::test()` 内的两段 32 字符 hex key + 默认 IV。

| 名称 | key (ASCII 32B) | iv (16B) |
|---|---|---|
| `key1` | `93a503f7cfaa11563a3ee36544f47430` | `34857d973953e44a` |
| `key2` | `a3374f473ed08213a285e7090196a93d` | `34857d973953e44a` |

注意：这两把 key 是 JM::test() 的调试转储样本，不是真实生产 HTTP 密钥。
`FXXF01` 动态配置包无法用其解密。

---

## 5. rodata 候选密钥 (so 直接提取, 全 32B ASCII)

来源：`verify_key.py` `CANDIDATES` + `read_rodata.py` 地址。

| 名称 | 值 (32B) | 来源 |
|---|---|---|
| default ASCII | `cbIhHHuYQIJ1JkwlLupIvNIvdQDfNxSF` | initLocalKey / config |
| rodata_39a0 | `eirdOhIycKhV18r$3iqszOfgKTPUcEmj` | so rodata |
| rodata_39c0 | `jX4SM#xx4cMBZR!txR0ghhI&cq*P36Ih` | so rodata |
| rodata_3a00 | `SKMl^0SmirQ6Hcnh^1VwP1UBBzVz*M6Y` | so rodata |
| rodata_3a20_bin | `libcocos2dlua.so[0x1183a20:0x1183a40]` | APK 内二进制 |
| rodata_39e0_bin | `libcocos2dlua.so[0x11839e0:0x1183a00]` | APK 内二进制 |

---

## 6. IV 候选汇总

| 名称 | 值 (16B) |
|---|---|
| 默认 IV `def` | `34857d973953e44a` |
| 生产 IV `PcIQ` | `PcIQIZifRalhZ88n` |
| 全零 IV `zero` | `00` × 16 |
| 空串 IV | `20` × 16 (16 个空格) |

---

## 7. 签名 token / 盐

| 项 | 值 |
|---|---|
| `T_TOKEN`（mock）| `mock_fzjh_token_2026` |
| 请求签名 | `md5(time & nonce & request_body)` + 头 `sig` |
| 响应签名 | `md5(time & nonce & response & T_TOKEN)` |

签名白名单接口（不校验签名）：
`get_time`、`get_token`、`report_cheat`、`getWebConfig`。

---

## 8. 尚未提取的密钥

- **FXXF01 组**（`get_game_config` / `server_config_raw.bin` / `value.md`）：
  - 实时抓取 `https://android.fzjh.xiaohoutiaotiao.com/api/service/get_game_config` 返回 `FXXF01` 魔数。
  - 是 native 引导(bootstrap)密钥，未在已知 key 清单中；需 Frida 运行时 hook `createAes` 提取。

---

## 9. 格式约定

```
stringEncrypt(plain, version)
  = hex( magic(6B) + AES-256-CBC(plain) )
  明文用 ASCII '0' (0x30) 补齐到 16 字节块 (块满补整块)
  密文整体 hex 编码 (小写)

stringDecrypt(text)
  = 反序: 去魔数 → 截整块 → AES-CBC 解密 → rstrip(b"0")
```

关键约束（见项目 memory）：
- **密钥直接使用 32 字节 ASCII，不做 hex 解码**（AES-256-CBC）。
- FZJH03 magic 值为 `b"FZJH03"`。
- 解密后用 ASCII `'0'` (0x30) 填充被剥离。