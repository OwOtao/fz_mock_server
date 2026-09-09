# -*- coding: utf-8 -*-
"""
放置江湖 本地 mock 服务端 - 配置
================================
所有可调参数集中在此, 客户端(游戏)与协议相关的约定均来自
已逆向的 BaseHttp.lua / GameChannelContext.lua / OnlineGameStrategy.lua。
"""

# ---------------------------------------------------------------------------
# 服务监听
# ---------------------------------------------------------------------------
HOST = "0.0.0.0"
PORT = 8080

# 客户端 Game:getDomain() 会指向的域名(完整 = DOMAIN .. API_PREFIX .. url)
# 模拟器通过此 IP 访问宿主机
DOMAIN = "http://192.168.5.10:8080"
API_PREFIX = "api/v5/"

# 响应加密(整体加密)。置 False 可发明文便于调试
ENCRYPT_RESPONSE = True

# 签名白名单: 与 BaseHttp.lua SKIP_URL 一致, 这些接口客户端不校验签名
SKIP_SIGN_URLS = ["get_time", "get_token", "report_cheat", "getWebConfig"]

# 客户端校验响应签名的 token: 由 get_token 下发给客户端,
# 服务端签名与客户端校验必须使用同一个值
T_TOKEN = "mock_fzjh_token_2026"

# 存档/账号落盘路径。None 表示仅内存; 运行时数据统一写入 mock_server/data
import os as _os
_ROOT = _os.path.dirname(_os.path.abspath(__file__))
DATA_DIR = _os.path.join(_ROOT, "data")
STATE_JSON_PATH = _os.path.join(DATA_DIR, "state.json")
STATE_AUTOSAVE = True
# 真实 RoleData 按 userid 分文件落盘
ARCHIVES_DIR = _os.path.join(DATA_DIR, "archives")
# 启动时可导入的种子档(真实本地 RoleData.json); 仅在对应 userid 文件不存在时导入
SEED_ROLEDATA_PATH = _os.path.join(DATA_DIR, "seed", "RoleData.json")
SEED_IMPORT_ON_START = True
# 后续注册账号扩展预留: 新注册默认空号(不克隆种子档)
REGISTER_CLONE_SEED = False

# ---------------------------------------------------------------------------
# getMd5List 覆盖开关 (热更新文件 md5 清单)
# ---------------------------------------------------------------------------
# False: 原样转发上游响应(原逻辑)。
# True : 先解密上游 getMd5List 响应, 把 debug 目录里同名文件的 md5 替换进去
#        (只替换清单里已有的键, 不新增), 再按同一格式加密返回给客户端。
MD5_OVERRIDE_ENABLED = True
# 本地文件目录(相对路径直接接到下面的键名前缀后)
MD5_OVERRIDE_DIR = _os.path.join(_ROOT, "debug")
# 清单里的键名前缀: debug 目录对应 src/app/views/layer/DebugLayer/xxx.lua
MD5_OVERRIDE_KEY_PREFIX = "src/app/views/layer/DebugLayer"
# 额外需要覆盖 md5 的热更文件: {清单键名: 本地明文路径(相对本目录)}
# 例: 打过补丁的 MainLayer.lua(无条件显示调试按钮); 不覆盖的话客户端更新检查会换回官方版本
MD5_OVERRIDE_EXTRA_FILES = {
    "src/app/views/layer/MainLayer.lua": "patched/MainLayer.lua",
}
# 上游 2.1.01 响应/热更文件用的 JM 组: JHHU01
#   key 为 32 字节 ASCII(AES-256), IV 固定 16 字节, 明文用 ASCII '0' 补齐到 16 字节倍数。
# 注意: 清单里的 md5 是"加密后 hex 文本"的 md5, 不是明文源码的 md5。
UPDATE_JHHU01_MAGIC = b"JHHU01"
UPDATE_JHHU01_KEY = b"9B5A96B0F4A1EC60DB88349E3B926765"
UPDATE_JHHU01_IV = b"34857d973953e44a"
ADMIN_API_TOKEN = _os.getenv("MOCK_ADMIN_API_TOKEN", "")
MOCK_DEVICE_UUID = _os.getenv(
    "MOCK_DEVICE_UUID",
    "guanfangd0b80cf7aa09ea3538329b0d",
)
UPDATE_UPSTREAM_BASE = _os.getenv("MOCK_UPDATE_UPSTREAM_BASE", "http://update.xiaohoutiaotiao.com/v1")
UPDATE_UPSTREAM_TIMEOUT = float(_os.getenv("MOCK_UPDATE_UPSTREAM_TIMEOUT", "10"))

# ---------------------------------------------------------------------------
# JM 加密密钥组
# ---------------------------------------------------------------------------
# 客户端 JM:stringEncrypt(data, version) / JM:stringDecrypt(data):
#   version == nil    -> 默认组 (lua 文件加密/解密, 已实测)
#   version == FZJH03 -> HTTP 协议组 (OnlineGameStrategy:getHttpEncryptVersion())
#
# 格式: hex( 魔数 + AES-256-CBC 密文 ), 明文用 ASCII '0' 补齐到 16 字节块。
#
# 密钥使用方式 (静态分析 libcocos2dlua_arm64.so 确认):
#   - AES_set_decrypt_key(key_data, 256, schedule) 直接使用 key 字符串的
#     原始 ASCII 字节作为 32 字节 AES-256 密钥, 不做 hex 解码。
#   - IV 为空时, getIv() 返回默认 IV "34857d973953e44a" (16 ASCII 字节)。
#   - FZJH03 生产 key/IV 来自 exchange_publickey 实际响应。
#   - FZJH03 magic 为 "FZJH03"。
KEY_GROUPS = {
    "default": {
        "magic": b"JHHU02",
        "key":   b"cbIhHHuYQIJ1JkwlLupIvNIvdQDfNxSF",
        "iv":    b"PcIQIZifRalhZ88n",
    },
    "FZJH03": {
        "magic": b"FZJH03",
        "key":   b"880e42c8075b8f400cd72f21451c0866",
        "iv":    b"PcIQIZifRalhZ88n",
    },
    "FZJH02": {
        "magic": b"FZJH02",
        "key":   b"0228482afef78be8b948ad8b08b24da7",
        "iv":    b"34857d973953e44a",
    },
    "FXXF03": {
        "magic": b"FXXF03",
        "key":   b"0228482afef78be8b948ad8b08b24da7",
        "iv":    b"PcIQIZifRalhZ88n",
    },
}

# 服务端应答 HTTP 加密请求时使用的密钥组。
RESPONSE_GROUP = "FZJH03"

RESPONSE_GROUP_BY_PATH = {
    "api/service/get_game_config": "default",
    "api/service/exchange_publickey": "default",
    "api/service_android/get_uuid": "default",
    "api/service_android/update_uuid": "default",
    "api/service_android/get_version_info": "FZJH03",
    "api/service_android/report_ads_info": "FZJH03",
    "v1/checkUpdate": "default",
    "v1/getMd5List": "default",
}
