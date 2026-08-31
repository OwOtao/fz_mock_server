// ============================================================
// 放置江湖 Lua 解密 Hook 脚本
// 目标: 解密 assets 下所有 JHHU02 加密的 Lua 文件
//
// 策略:
//   1. hook cpp::aes::getAesWithHead (0x680f6c) 捕获游戏运行时解密结果
//   2. hook cpp::aes::setKey/setIv 提取密钥 IV (用于离线 fallback)
//   3. 暴露 rpc.exports.decrypt 供 PC 端主动批量解密
//
// 符号偏移 (arm64, 离线解析自 APK libcocos2dlua.so):
//   getAesWithHead = 0x680f6c  (_ZN3cpp3aes14getAesWithHeadESs)
//   setKey         = 0x6804b8  (_ZN3cpp3aes6setKeyESs)
//   setIv          = 0x6804cc  (_ZN3cpp3aes6setIvESs)
// ============================================================
'use strict';

var SO_NAME = 'libcocos2dlua.so';
var OFF_GET_AES = 0x680f6c;
var OFF_SET_KEY = 0x6804b8;
var OFF_SET_IV  = 0x6804cc;

var gBase = null;
var gHooked = false;
var gAesThis = null;      // 从游戏自然调用捕获的有效 cpp::aes 对象
var gKey = null;
var gIv = null;
var gAutoCaptureCount = 0;

// ---------- base64 (纯 JS) ----------
var B64 = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';

function b64encode(u8) {
    var s = '', n = 0, bits = 0;
    for (var i = 0; i < u8.length; i++) {
        n = (n << 8) | u8[i];
        bits += 8;
        while (bits >= 6) {
            bits -= 6;
            s += B64[(n >> bits) & 63];
        }
    }
    if (bits > 0) s += B64[(n << (6 - bits)) & 63];
    while (s.length % 4) s += '=';
    return s;
}

function b64decode(s) {
    s = s.replace(/=+$/, '');
    var out = [], n = 0, bits = 0;
    for (var i = 0; i < s.length; i++) {
        var v = B64.indexOf(s[i]);
        if (v < 0) continue;
        n = (n << 6) | v;
        bits += 6;
        if (bits >= 8) {
            bits -= 8;
            out.push((n >> bits) & 255);
        }
    }
    return new Uint8Array(out);
}

// ---------- std::string (libstdc++ arm64) ----------
// 布局: +0 _M_p (指针) | +8 _M_string_length | +16 capacity/本地缓冲
function readStdString(obj) {
    try {
        var p = obj.readPointer();
        var len = obj.add(8).readU64().toNumber();
        if (len <= 0 || len > 0x40000000) return null;
        return p.readByteArray(len);
    } catch (e) {
        return null;
    }
}

function makeStdString(u8) {
    var len = u8.length;
    var buf = Memory.alloc(len + 1);
    buf.writeByteArray(u8);
    var obj = Memory.alloc(48);
    obj.writePointer(buf);                 // +0 _M_p
    obj.add(8).writeU64(ptr(len));         // +8 length
    obj.add(16).writeU64(ptr(len + 1));    // +16 capacity
    obj.add(24).writeU64(ptr(0));          // +24 填充
    return obj;
}

// ---------- 定位 so 基地址 ----------
function findBase() {
    var ranges = Process.enumerateRanges('r--');
    for (var i = 0; i < ranges.length; i++) {
        var r = ranges[i];
        if (r.file && r.file.path.indexOf(SO_NAME) !== -1) {
            return r.base;
        }
    }
    return null;
}

// ---------- 挂钩 ----------
function installHooks() {
    if (gHooked) return true;
    var base = findBase();
    if (base === null) return false;
    gBase = base;

    // getAesWithHead(const std::string& data) -> std::string
    Interceptor.attach(base.add(OFF_GET_AES), {
        onEnter: function (args) {
            gAesThis = args[0];
            this.input = readStdString(args[1]);
        },
        onLeave: function (retval) {
            var out = readStdString(retval);
            if (this.input && out) {
                gAutoCaptureCount++;
                send({
                    type: 'decrypted',
                    input: b64encode(new Uint8Array(this.input)),
                    output: b64encode(new Uint8Array(out))
                });
            }
        }
    });

    // setKey(const std::string& key)
    Interceptor.attach(base.add(OFF_SET_KEY), {
        onEnter: function (args) {
            gAesThis = gAesThis || args[0];
            var k = readStdString(args[1]);
            if (k) {
                gKey = new Uint8Array(k);
                send({ type: 'key', key: b64encode(gKey) });
            }
        }
    });

    // setIv(const std::string& iv)
    Interceptor.attach(base.add(OFF_SET_IV), {
        onEnter: function (args) {
            var iv = readStdString(args[1]);
            if (iv) {
                gIv = new Uint8Array(iv);
                send({ type: 'iv', iv: b64encode(gIv) });
            }
        }
    });

    gHooked = true;
    send({ type: 'ready', base: String(base), offset: '0x680f6c' });
    return true;
}

// ---------- RPC: 主动解密 ----------
rpc.exports = {
    ready: function () {
        return gHooked && gAesThis !== null;
    },
    getKey: function () {
        return gKey ? b64encode(gKey) : null;
    },
    getIv: function () {
        return gIv ? b64encode(gIv) : null;
    },
    decrypt: function (encB64) {
        if (!gHooked || gAesThis === null) {
            return { ok: false, err: 'hook-not-ready' };
        }
        try {
            var enc = b64decode(encB64);
            var inObj = makeStdString(enc);
            var fn = new NativeFunction(gBase.add(OFF_GET_AES), 'pointer', ['pointer', 'pointer']);
            var outPtr = fn(gAesThis, inObj);
            var outBytes = readStdString(outPtr);
            if (outBytes === null) {
                return { ok: false, err: 'empty-output' };
            }
            return { ok: true, out: b64encode(new Uint8Array(outBytes)) };
        } catch (e) {
            return { ok: false, err: String(e) };
        }
    }
};

// ---------- 轮询等待 so 加载 ----------
var tries = 0;
var timer = setInterval(function () {
    tries++;
    try {
        if (installHooks()) clearInterval(timer);
    } catch (e) {
        send({ type: 'error', msg: String(e) });
    }
    if (tries >= 120) {
        clearInterval(timer);
        send({ type: 'timeout', msg: '120s 等待超时' });
    }
}, 500);

send({ type: 'injected', pid: Process.id, arch: Process.arch });
