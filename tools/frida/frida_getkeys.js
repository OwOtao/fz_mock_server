// ============================================================
// 放置江湖 JM 加密密钥/格式提取 Hook
//
// 目标:
//   1. hook cpp::aes::createAes -> 捕获分组密钥 key/iv (含 FZJH03 HTTP 组)
//   2. hook cpp::aes::eswh/dswh -> 捕获加密/解密输入输出, 确认格式
//   3. hook cpp::aes::setKey/setIv -> 兜底捕获全局 key/iv
//
// 关键修正(已静态验证):
//   * createAes 是非静态成员函数: this=x0, key=x1, iv=x2, tag=w3
//     (汇编 0x6811ec 使用 x0/x1/x2/w3 四个寄存器位, 确认有 this)
//   * STL 为老版 libstdc++(无 __cxx11): std::string 布局 _M_p@+0, len@+8
//     (从 string 构造函数 0x115be98 字段写入验证)
//   * 符号优先用 frida 动态枚举(_ZN3cpp3aes*), 找不到回退 arm64 偏移表
//
// 偏移(arm64, 解析自 .dynsym, getAesWithHead=0x680f6c 与旧脚本一致):
//   createAes     = 0x6811ec   setKey = 0x6804b8  setIv = 0x6804cc
//   eswh          = 0x680b40   dswh   = 0x680cd4  getAesWithHead = 0x680f6c
// ============================================================
'use strict';

var SO_NAME = 'libcocos2dlua.so';

// 符号名 -> 优先动态枚举定位
var SYMBOLS = {
    createAes:      '_ZN3cpp3aes9createAesESsSsSsc',
    setKey:         '_ZN3cpp3aes6setKeyESs',
    setIv:          '_ZN3cpp3aes5setIvESs',
    eswh:           '_ZN3cpp3aes4eswhERKSsS2_',
    dswh:           '_ZN3cpp3aes4dswhERKSsS2_',
    getAesWithHead: '_ZN3cpp3aes14getAesWithHeadESs',
};

// arm64 偏移兜底表
var OFF_ARM64 = {
    createAes: 0x6811ec,
    setKey:    0x6804b8,
    setIv:     0x6804cc,
    eswh:      0x680b40,
    dswh:      0x680cd4,
    getAesWithHead: 0x680f6c,
};

var B64 = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';

function b64encode(u8) {
    var s = '', n = 0, bits = 0;
    for (var i = 0; i < u8.length; i++) {
        n = (n << 8) | u8[i];
        bits += 8;
        while (bits >= 6) { bits -= 6; s += B64[(n >> bits) & 63]; }
    }
    if (bits > 0) s += B64[(n << (6 - bits)) & 63];
    while (s.length % 4) s += '=';
    return s;
}

function toStr(buf) {
    var u8 = new Uint8Array(buf);
    var s = '';
    for (var i = 0; i < u8.length; i++) s += String.fromCharCode(u8[i]);
    return s;
}

// libstdc++(旧版) std::string: +0 _M_p | +8 _M_string_length | +16 union
function readStdString(obj) {
    try {
        if (obj.isNull()) return null;
        var p = obj.readPointer();
        var len = obj.add(8).readU64().toNumber();
        if (len <= 0 || len > 0x40000000) return null;
        // SSO 防护: _M_p 指向对象内部 local buf(+16) 时直接取对象内字节
        var objLo = obj.add(16);
        var objHi = obj.add(48);
        if (p.compare(objLo) >= 0 && p.compare(objHi) < 0) {
            return obj.add(16).readByteArray(len);
        }
        return p.readByteArray(len);
    } catch (e) { return null; }
}

function dump(tag, buf) {
    if (!buf) { send({ type: 'log', msg: tag + ' = (empty)' }); return; }
    var u8 = new Uint8Array(buf);
    var head = u8.slice(0, 64);
    var hex = '';
    for (var i = 0; i < head.length; i++) {
        var h = head[i].toString(16);
        if (h.length < 2) h = '0' + h;
        hex += h;
    }
    send({
        type: 'dump', ts: Date.now(), tag: tag, len: u8.length,
        b64: b64encode(u8),
        hex_head: hex,
        text_head: toStr(head).replace(/[^\x20-\x7e]/g, '.'),
    });
}

function findBase() {
    var ranges = Process.enumerateRanges('r--');
    for (var i = 0; i < ranges.length; i++) {
        if (ranges[i].file && ranges[i].file.path.indexOf(SO_NAME) !== -1)
            return ranges[i].base;
    }
    return null;
}

// 优先按符号名解析偏移, 失败回退 arm64 表
function resolveOffsets(base) {
    var offs = {};
    var mod = Process.findModuleByName(SO_NAME);
    if (mod) {
        try {
            var syms = mod.enumerateSymbols();
            for (var i = 0; i < syms.length; i++) {
                var s = syms[i];
                for (var k in SYMBOLS) {
                    if (s.name === SYMBOLS[k]) offs[k] = s.address.sub(base);
                }
            }
        } catch (e) {
            send({ type: 'log', msg: 'enumerateSymbols error: ' + e });
        }
    }
    if (Process.arch === 'arm64') {
        for (var k2 in OFF_ARM64) {
            if (!offs[k2]) offs[k2] = ptr(OFF_ARM64[k2]);
        }
    }
    return offs;
}

function installHooks() {
    var base = findBase();
    if (!base) return false;
    var offs = resolveOffsets(base);
    var missing = [];
    for (var k in SYMBOLS) if (!offs[k]) missing.push(k);
    send({ type: 'ready', base: String(base), arch: Process.arch,
           missing: missing, offs: {
               createAes: offs.createAes ? String(offs.createAes) : null,
               eswh: offs.eswh ? String(offs.eswh) : null } });

    // createAes(this, key, iv, tag) -> cpp::aes*   ★ 成员函数!
    if (offs.createAes) {
        Interceptor.attach(base.add(offs.createAes), {
            onEnter: function (args) {
                dump('createAes.key', readStdString(args[1]));
                dump('createAes.iv', readStdString(args[2]));
                send({ type: 'log', msg: 'createAes.tag = ' + args[3].toInt32() });
            }
        });
    }

    // setKey/setIv (全局兜底, 成员函数: 参数在 args[1])
    if (offs.setKey) {
        Interceptor.attach(base.add(offs.setKey), {
            onEnter: function (args) { dump('setKey', readStdString(args[1])); }
        });
    }
    if (offs.setIv) {
        Interceptor.attach(base.add(offs.setIv), {
            onEnter: function (args) { dump('setIv', readStdString(args[1])); }
        });
    }

    // eswh(this, const string& a, const string& b) -> string
    if (offs.eswh) {
        Interceptor.attach(base.add(offs.eswh), {
            onEnter: function (args) {
                this.in1 = readStdString(args[1]);
                this.in2 = readStdString(args[2]);
            },
            onLeave: function (retval) {
                dump('eswh.in(明文)', this.in1);
                dump('eswh.in2', this.in2);
                dump('eswh.out(密文文本)', readStdString(retval));
            }
        });
    }

    // dswh(this, const string& a, const string& b) -> string
    if (offs.dswh) {
        Interceptor.attach(base.add(offs.dswh), {
            onEnter: function (args) {
                this.in1 = readStdString(args[1]);
                this.in2 = readStdString(args[2]);
            },
            onLeave: function (retval) {
                dump('dswh.in(密文文本)', this.in1);
                dump('dswh.in2', this.in2);
                dump('dswh.out(明文)', readStdString(retval));
            }
        });
    }

    // getAesWithHead(this, data) -> string (lua 文件解密, 会高频触发)
    if (offs.getAesWithHead) {
        Interceptor.attach(base.add(offs.getAesWithHead), {
            onEnter: function (args) {
                var d = readStdString(args[1]);
                if (d && d.length > 6) { this.in = d; }
            },
            onLeave: function (retval) {
                if (this.in) dump('getAesWithHead', readStdString(retval));
            }
        });
    }

    send({ type: 'log', msg: 'hooks installed, 请操作游戏触发 HTTP 请求(登录/进服)' });
    return true;
}

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
        send({ type: 'timeout', msg: '120s 等待 so 加载超时' });
    }
}, 500);

send({ type: 'injected', pid: Process.id, arch: Process.arch });
