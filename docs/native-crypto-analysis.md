# libcocos2dlua_arm64.so 逆向分析报告

> 目标：视频逆向靶场 native 库  
> 文件：`research/binaries/libcocos2dlua_arm64_bootstrap.so`  
> 分析方式：ELF 静态解析 + 动态符号导出 + 字符串/密钥常量交叉验证  
> 说明：业务功能在业务层多为“虚拟/可模拟”，但本 SO 本身是完整可运行的 Cocos2d-x Lua 引擎与业务加密实现。

---

## 1. 文件与 ELF 概览

| 项目 | 值 |
|---|---|
| 文件名 | `libcocos2dlua_arm64.so` |
| SONAME | `libcocos2dlua.so` |
| 大小 | 22,898,184 字节（约 21.8 MB） |
| SHA256 | `4c5da54736c03dd5937416dc8e740935d7d8082fbd46518251635555d3957a52` |
| 架构 | AArch64 / ELF64 / little-endian |
| 类型 | `ET_DYN`（共享库） |
| 入口点 | `0x4dc000`（`.text` 起始） |
| 是否 strip | 是（无常规 `.symtab` 调试符号，但保留大量 `.dynsym`） |
| 动态符号总数 | 40,988 |
| 导出符号总数 | 约 40,534 |
| **导出函数总数** | **34,580** |
| 导出对象 | 约 5,954 |
| 导入符号 | 454 |
| 重定位 | 73,954 |
| 字符串候选 | 100,001+ |

### 1.1 依赖库（DT_NEEDED）

- `libGLESv2.so`
- `liblog.so`
- `libandroid.so`
- `libOpenSLES.so`
- `libEGL.so`
- `libdl.so`
- `libstdc++.so`
- `libm.so`
- `libc.so`

> 未直接依赖外部 `libcrypto/libssl/libcurl`，OpenSSL 与 HTTP 相关能力被**静态编入**本 SO。

### 1.2 关键段布局

| 段名 | 地址 | 大小 | 说明 |
|---|---:|---:|---|
| `.dynsym` | `0x48220` | 983,784 | 动态符号表 |
| `.dynstr` | `0x138508` | 1,950,755 | 符号名字符串 |
| `.plt` | `0x4d9f00` | 7,088 | 过程链接表 |
| `.text` | `0x4dc000` | 13,232,644 | 主代码段（约 12.6MB） |
| `.rodata` | `0x117aa10` | 1,442,768 | 只读常量（密钥/魔数在此） |
| `.data.rel.ro` | `0x152a540` | 591,880 | 只读重定位数据 |
| `.got` | `0x15bafa8` | 73,816 | GOT |
| `.data` | `0x15cd000` | 101,952 | 可写数据 |
| `.bss` | `0x15e5e40` | 746,664 | 未初始化数据 |

---

## 2. 总体定性

这是一个 **Cocos2d-x + Lua 脚本引擎 + 业务加密 + 第三方库大杂烩** 的 Android arm64 动态库。

可拆成 4 层：

1. **引擎层**：Cocos2d-x 渲染/场景/UI/物理/音频  
2. **脚本层**：Lua 5.x + 大量 `lua_cocos2dx_*` 绑定  
3. **业务加密层（靶场核心）**：`JM` / `cpp::aes` / `YXHelper` / `HttpManager`  
4. **第三方库层**：OpenSSL、FreeType、Spine、Bullet、Chipmunk、libpng/jpeg/tiff、zlib、FlatBuffers、RapidJSON 等

包名线索：`com.xhtt.app.fzjh`（JNI 前缀），与“放置江湖”类靶场样本一致。

---

## 3. 导出函数统计（分类）

基于导出函数（`STT_FUNC` 且非 `SHN_UNDEF`）做前缀/关键词分类：

| 类别 | 数量 | 说明 |
|---|---:|---|
| cocos2d 核心 C++ | 12,130 | `_ZN7cocos2d...` |
| 其他未细分类函数 | 7,500 | STL/内部辅助/杂项 |
| Lua 绑定 | 4,758 | `lua_cocos2dx_*` / `tolua` / `luaval` |
| OpenSSL | 3,350 | `EVP_/AES_/RSA_/SHA/MD5/HMAC/...` |
| cocostudio | 2,080 | UI/动画编辑器运行时 |
| spine | 1,741 | 骨骼动画 |
| bullet | 1,267 | 3D 物理 |
| png/jpeg/tiff | 711 | 图像编解码 |
| chipmunk | 393 | 2D 物理 |
| freetype | 192 | 字体 |
| lua C API | 165 | `lua_` / `luaL_` / `luaopen_` |
| flatbuffers | 86 | 序列化 |
| zlib | 69 | 压缩 |
| rapidjson | 53 | JSON |
| **业务加密 JM 相关** | **38** | 靶场最有分析价值 |
| Java JNI 导出 | 46 | `Java_*` |
| JNI_OnLoad | 1 | 库加载入口 |

> 结论：导出面极大，真正值得优先分析的是 **JM / cpp::aes / YXHelper / 业务 JNI / HttpManager**，而不是 3 万多个引擎符号。

---

## 4. 靶场核心：加密与通信体系

### 4.1 架构关系

```
Lua 层
  JMForLua:encrypt/decrypt
      │
      ▼
Native JM 类
  JM::stringEncrypt / stringDecrypt / initLocalKey / addInfo / getKey
      │
      ▼
cpp::aes
  createAes / setKey / setIv / eswh / dswh / e / d
      │
      ▼
OpenSSL AES-CBC 原语
  AES_set_encrypt_key / AES_cbc_encrypt ...
```

HTTP 侧：

```
HttpManager::post/get
  -> 请求体 JM 加密
  -> 响应 getResponseStringWithDecryptAndUncompress
  -> JM::stringDecrypt + uncompress
签名侧：
  YXHelper::doMd5ForHttpRequest / JniNative.doMd5ForHttpRequest
```

### 4.2 核心业务导出函数（高价值）

#### A. `JM` 加密门面

| 地址 | 大小 | 符号 | 作用 |
|---:|---:|---|---|
| `0x652d78` | 2320 | `JM::initLocalKey` | 初始化本地密钥表（写入 FZJH/JHHU 等） |
| `0x652794` | 1508 | `JM::addInfo` | 向密钥 map 注入 head/key/iv/tag |
| `0x653c88` | 700 | `JM::getKey` | 按 head 取 key/iv |
| `0x653f44` | 1312 | `JM::stringEncrypt` | 字符串加密入口（带 version） |
| `0x654a18` | 272 | `JM::stringDecrypt(string)` | 字符串解密 |
| `0x654464` | 1460 | `JM::stringDecrypt(Data)` | 二进制 Data 解密 |
| `0x6538d0` | 656 | `JM::isEncrypted` | 判断是否加密数据 |
| `0x6526e4` | 176 | `JM::isUseXXTEA` | 是否走 XXTEA 旧协议 |
| `0x6536f4` | 252 | `JM::hexStringToBytes` | hex -> bytes |
| `0x6537f0` | 224 | `JM::bytesToHexString` | bytes -> hex |
| `0x654b28` | 1768 | `JM::test` | 调试/测试函数（含样例 key） |

#### B. `cpp::aes` AES 实现

| 地址 | 大小 | 符号 | 作用 |
|---:|---:|---|---|
| `0x6811ec` | 600 | `cpp::aes::createAes` | 创建并登记 AES 对象（key, iv, tag） |
| `0x680f6c` | 64 | `cpp::aes::getAesWithHead` | 按 head/魔数取 AES 实例 |
| `0x6804b8` | 20 | `cpp::aes::setKey` | 设 key |
| `0x6804cc` | 24 | `cpp::aes::setIv` | 设 iv |
| `0x680538` | 8 | `cpp::aes::setTag` | 设 tag |
| `0x680b40` | 404 | `cpp::aes::eswh` | encrypt string with head |
| `0x680cd4` | 364 | `cpp::aes::dswh` | decrypt string with head |
| `0x6808c4` | 408 | `cpp::aes::ewh` | encrypt with head（缓冲版） |
| `0x680a5c` | 228 | `cpp::aes::dwh` | decrypt with head（缓冲版） |
| `0x68055c` | 436 | `cpp::aes::e` | 底层 encrypt 块 |
| `0x680710` | 436 | `cpp::aes::d` | 底层 decrypt 块 |

内部还存在 `std::map<std::string, cpp::aes*>` 作为密钥树/对象池。

#### C. XXTEA（旧协议/脚本兼容）

| 地址 | 大小 | 符号 |
|---:|---:|---|
| `0x8185d0` | 184 | `xxtea_encrypt` |
| `0x818688` | 184 | `xxtea_decrypt` |
| `0x703dbc` | 204 | `LuaStack::setXXTEAKeyAndSign` |
| `0x703ac0` | 64 | `LuaStack::cleanupXXTEAKeyAndSign` |
| `0x7052b0` | 1124 | `LuaStack::luaLoadBuffer`（加载时可能解密） |

#### D. 签名 / MD5

| 地址 | 大小 | 符号 |
|---:|---:|---|
| `0x621d9c` | 940 | `YXHelper::doMd5ForHttpRequest` |
| `0x622148` | 940 | `lua_myclass_YXHelper_doMd5ForHttpRequest` |
| `0x69d5d4` | 2036 | `Java_..._JniNative_doMd5ForHttpRequest` |
| `0x6224f4` | 1140 | `lua_myclass_YXHelper_getSigAndNouce` |

#### E. HTTP 管理

| 地址 | 大小 | 符号 |
|---:|---:|---|
| `0x64eea4` | 1140 | `HttpManager::post` |
| `0x64f318` | 896 | `HttpManager::get` |
| `0x64dd90` | 592 | `HttpManager::getResponseStringWithDecryptAndUncompress` |
| `0x64d920` | 604 | `HttpManager::getResponseString` |
| `0x64fa50` | 2052 | `HttpManager::retryPost` |
| `0x650254` | 1992 | `HttpManager::retryGet` |

### 4.3 静态密钥/魔数（rodata 实测命中）

| 偏移 | 内容 | 说明 |
|---|---|---|
| `0x117e3a0` | `FZJH01` | 本地 key 组 |
| `0x1183980` | `ae9b363b80d5cc594973ecce1f4d546d` | FZJH01 候选 key（hex 串） |
| `0x1183aa0` | `9B5A96B0F4A1EC60DB88349E3B926765` | JHHU01 候选 key |
| `0x1183ac0` | `cbIhHHuYQIJ1JkwlLupIvNIvdQDfNxSF` | 默认 AES-256 key（已验证可解 Lua） |
| `0x1183af0` | `JHHU01` | 魔数 |
| `0x1183af8` | `JHHU02` | 魔数（Lua 文件默认组） |
| `0x1183b00` | `PcIQIZifRalhZ88n` | 生产 IV |
| `0x1183b18` | `FXXF03` + 后续二进制/hex | 备用组 |
| `0x1183bf0` | `FZJH03` + `93a503f7...` / `a3374f47...` | 测试样例 key 区（`JM::test`） |
| `0x1185a48` | `34857d973953e44a` | 默认 IV 候选 |

协议特征（结合既有分析）：

- 输出形态：`hex( magic + AES-CBC(plaintext) )`
- 版本/魔数路由：`JHHU02` / `FZJH03` / `FXXF03` 等
- 旧链路：`version=1` 时走 XXTEA
- HTTP 在线主协议：`FZJH03`（运行时可由 `exchange_publickey` 下发动态 key）

---

## 5. JNI 导出函数（完整列表）

### 5.1 库入口

| 地址 | 大小 | 符号 |
|---:|---:|---|
| `0x6fd998` | 40 | `JNI_OnLoad` |
| `0x69bdc0` | 120 | `cocos_android_app_init(_JNIEnv*)` |

### 5.2 业务 JNI：`com.xhtt.app.fzjh.jni.JniNative`

| 地址 | 大小 | 符号 |
|---:|---:|---|
| `0x69be38` | 340 | `Java_com_xhtt_app_fzjh_jni_JniNative_CallFunc` |
| `0x69bf8c` | 1176 | `Java_com_xhtt_app_fzjh_jni_JniNative_Encrypt` |
| `0x69c424` | 708 | `Java_com_xhtt_app_fzjh_jni_JniNative_Decrypt` |
| `0x69cacc` | 152 | `Java_com_xhtt_app_fzjh_jni_JniNative_quickDecrypt` |
| `0x69c6e8` | 748 | `Java_com_xhtt_app_fzjh_jni_JniNative_GetUserValue` |
| `0x69c9d4` | 244 | `Java_com_xhtt_app_fzjh_jni_JniNative_UpdateManagerGetVersion` |
| `0x69cac8` | 4 | `Java_com_xhtt_app_fzjh_jni_JniNative_getWebTime`（空实现/桩） |
| `0x69cb64` | 1344 | `Java_com_xhtt_app_fzjh_jni_JniNative_initConfigData` |
| `0x69d0a4` | 248 | `Java_com_xhtt_app_fzjh_jni_JniNative_getServerHost` |
| `0x69d19c` | 708 | `Java_com_xhtt_app_fzjh_jni_JniNative_getStringProperty` |
| `0x69d460` | 364 | `Java_com_xhtt_app_fzjh_jni_JniNative_ss` |
| `0x69d5d4` | 2036 | `Java_com_xhtt_app_fzjh_jni_JniNative_doMd5ForHttpRequest` |

### 5.3 Cocos 标准 JNI：`org.cocos2dx.lib.*`（34 个）

- `Cocos2dxAccelerometer_onSensorChanged`
- `Cocos2dxActivity_getGLContextAttrs`
- `Cocos2dxBitmap_nativeInitBitmapDC`
- `Cocos2dxEditBoxHelper_editBoxEditingChanged/Begin/End`
- `Cocos2dxHelper_nativeSetApkPath/Context/AudioDeviceInfo/EditTextDialogResult`
- `Cocos2dxLuaJavaBridge_callLuaFunctionWithString/callLuaGlobalFunctionWithString/retain/release`
- `Cocos2dxRenderer_nativeInit/Render/OnPause/OnResume/Touches*/KeyEvent/...`
- `Cocos2dxVideoHelper_nativeExecuteVideoCallback`
- `Cocos2dxWebViewHelper_shouldStartLoading/didFinishLoading/didFailLoading/onJsCallback`
- `Java_org_cocos2dx_lua_AppActivity_nativeIsDebug`

---

## 6. Lua 绑定与注册入口

### 6.1 业务自定义注册

| 地址 | 大小 | 符号 |
|---:|---:|---|
| `0x620598` | 156 | `register_all_myclass` |
| `0x623a54` | 76 | `register_all_myclass_encrypt` |
| `0x6236c0` | 916 | `lua_register_myclass_encrypt_JM` |
| `0x61e2c0` | 808 | `lua_register_myclass_YXHelper` |
| `0x625118` | 92 | `register_all_myclass_Game` |
| `0x62aa8c` | 76 | `register_all_myclass_SdkMethod` |
| `0x626160` | 84 | `register_all_myclass_manual` |
| `0x633ce0` | 108 | `register_all_myclass_spine38` |

### 6.2 引擎模块注册（节选）

- `register_all_cocos2dx` @ `0x7c6b78`
- `register_all_cocos2dx_manual` @ `0x7fe1b0`
- `register_ui_module` / `register_network_module` / `register_spine_module`
- `register_physics3d_module` / `register_audioengine_module`
- `register_cocostudio_module` / `register_extension_module`

### 6.3 Lua C API（部分）

- `luaL_loadbuffer` / `luaL_loadbufferx`
- `luaL_register`
- 完整 `lua_*` / `luaL_*` / `luaopen_*` 约 165 个

---

## 7. 引擎与第三方库导出面

本 SO 导出面过大，以下是“库级”判断，不逐条罗列 3 万函数：

1. **Cocos2d-x 全量**：Node/Scene/Sprite/Action/Event/Renderer/UI  
2. **Lua 引擎栈**：`LuaEngine` / `LuaStack` / `ScriptHandlerMgr`  
3. **OpenSSL 静态内嵌**：对称（AES/DES/Camellia/Blowfish/CAST）、非对称（RSA/EC/DH/DSA）、摘要（MD5/SHA/HMAC）、TLS/CMS/X509  
4. **物理**：Bullet3D + Chipmunk2D  
5. **动画/字体/图像**：Spine、FreeType、libpng、libjpeg、libtiff  
6. **网络下载**：`cocos2d::network::HttpClient` + 自定义 `HttpManager/Downloader`  
7. **序列化**：FlatBuffers、RapidJSON  

完整导出函数清单已落盘：

- 全量导出函数：`research/so_analysis/so_exports_funcs.txt`（34,580 行）
- 聚焦导出（加密/JNI/OpenSSL 等）：`research/so_analysis/so_exports_focus.txt`（2,137 行）
- JSON 汇总：`research/so_analysis/so_exports_full.json`

---

## 8. 启动与调用链（分析视角）

1. `System.loadLibrary("cocos2dlua")`
2. `JNI_OnLoad` 注册/初始化
3. `cocos_android_app_init` / `AppDelegate::applicationDidFinishLaunching`
4. 创建 `LuaEngine` / `LuaStack`
5. `register_all_*` 批量注册绑定
6. `JM::initLocalKey` 建立本地密钥表
7. Lua 业务通过 `JM:stringEncrypt/Decrypt` 与 `YXHelper:doMd5ForHttpRequest` 走通信
8. Java 侧也可直接调用 `JniNative.Encrypt/Decrypt/doMd5...`

---

## 9. 靶场分析价值点

### 9.1 为什么有分析意义

- **不是空壳 SO**：完整引擎 + 真实加密实现  
- **业务加密可静态落地**：`JM`/`cpp::aes` 符号清晰，未重度混淆  
- **密钥材料部分裸露在 rodata**：适合教学“常量定位 → 算法还原 → 协议复现”  
- **多层协议共存**：XXTEA 旧协议 + AES 新协议 + 动态 publickey 轮换  
- **跨语言入口齐全**：Lua / JNI / C++ 三端都能验证

### 9.2 建议的逆向路线（教学向）

1. **入口**：`JNI_OnLoad`、`register_all_myclass_encrypt`  
2. **密钥表**：`JM::initLocalKey` + rodata 常量交叉  
3. **算法核心**：`cpp::aes::createAes/eswh/dswh`  
4. **协议封包**：`JM::stringEncrypt` 输出 hex+magic  
5. **HTTP 联调**：`HttpManager::getResponseStringWithDecryptAndUncompress`  
6. **动态验证**：Frida hook `createAes/setKey/setIv/eswh/dswh`  
7. **复现**：用 mock server 按 `FZJH03/JHHU02` 组回放

### 9.3 Hook 优先地址

| 目的 | 地址 | 符号 |
|---|---|---|
| 抓 key/iv | `0x6811ec` | `cpp::aes::createAes` |
| 抓加密输入输出 | `0x680b40` | `cpp::aes::eswh` |
| 抓解密输入输出 | `0x680cd4` | `cpp::aes::dswh` |
| 抓协议版本路由 | `0x653f44` | `JM::stringEncrypt` |
| 抓本地密钥初始化 | `0x652d78` | `JM::initLocalKey` |
| 抓请求签名 | `0x621d9c` | `YXHelper::doMd5ForHttpRequest` |
| 抓 JNI 加解密 | `0x69bf8c` / `0x69c424` | `JniNative_Encrypt/Decrypt` |

---

## 10. 导出函数清单（按分析优先级）

> 下面给出**最有价值的导出函数清单**。  
> 全量 34,580 个函数见 `so_exports_funcs.txt`。

### 10.1 业务加密 / 通信 / 签名（建议全部精读）

```
0x00652d78   2320  JM::initLocalKey
0x00652794   1508  JM::addInfo
0x00653c88    700  JM::getKey
0x00653f44   1312  JM::stringEncrypt
0x00654a18    272  JM::stringDecrypt(string)
0x00654464   1460  JM::stringDecrypt(Data)
0x006538d0    656  JM::isEncrypted
0x006526e4    176  JM::isUseXXTEA
0x006536f4    252  JM::hexStringToBytes
0x006537f0    224  JM::bytesToHexString
0x00654b28   1768  JM::test
0x006811ec    600  cpp::aes::createAes
0x00680f6c     64  cpp::aes::getAesWithHead
0x006804b8     20  cpp::aes::setKey
0x006804cc     24  cpp::aes::setIv
0x00680b40    404  cpp::aes::eswh
0x00680cd4    364  cpp::aes::dswh
0x006808c4    408  cpp::aes::ewh
0x00680a5c    228  cpp::aes::dwh
0x0068055c    436  cpp::aes::e
0x00680710    436  cpp::aes::d
0x008185d0    184  xxtea_encrypt
0x00818688    184  xxtea_decrypt
0x00621d9c    940  YXHelper::doMd5ForHttpRequest
0x0064eea4   1140  HttpManager::post
0x0064f318    896  HttpManager::get
0x0064dd90    592  HttpManager::getResponseStringWithDecryptAndUncompress
```

### 10.2 全部业务 JNI 导出（12）

见第 5.2 节完整表。

### 10.3 全部 Java 导出（46）

见第 5.2 + 5.3 节。

### 10.4 全量导出函数

- 文件：[`so_exports_funcs.txt`](file:///d:/DTest/ds/so_exports_funcs.txt)
- 格式：`地址  大小  符号名`
- 数量：**34,580**

---

## 11. 结论

1. `libcocos2dlua_arm64.so` 是靶场的 **native 核心**：引擎 + Lua + 加密 + 网络都在这里。  
2. 导出函数极多（**34,580**），但靶场价值高度集中在：  
   - `JM::*`  
   - `cpp::aes::*`  
   - `YXHelper::*`  
   - `Java_com_xhtt_app_fzjh_jni_JniNative_*`  
   - `HttpManager::*`  
3. 加密主链路可确认：  
   - 现代：`AES-CBC + magic/head + hex`  
   - 历史：`XXTEA`  
   - 签名：`MD5`（`doMd5ForHttpRequest`）  
4. rodata 中已直接可见多组密钥/魔数常量，适合做“静态还原 + 动态 hook 交叉验证”教学。  
5. 对视频靶场而言，业务功能可以是虚拟的，但本 SO 的实现细节是真实且可复现的，分析价值很高。

---

## 12. 附件

| 文件 | 内容 |
|---|---|
| `so_exports_funcs.txt` | 全部导出函数 |
| `so_exports_focus.txt` | 加密/JNI/OpenSSL 等聚焦导出 |
| `so_exports_full.json` | 结构化统计与关键词映射 |
| `key.md` | 已整理密钥总表 |
| `_so_analyze_exports.py` | 本次导出解析脚本 |

---

*报告生成自本地静态分析，导出计数以 `.dynsym` 为准。*
