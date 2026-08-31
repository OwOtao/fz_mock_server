// ============================================================
// 放置江湖 (FZJH) 协议抓包 Hook 脚本 v3
// 同时挂钩: C++ 层 JM::stringEncrypt/Decrypt + Lua 桥接层
//
// 符号 (arm64, 虚拟地址, 离线解析自 APK):
//   C++ 层:
//     _ZN2JM13stringEncryptESsSs  = 0x653f44  (JM::stringEncrypt)
//     _ZN2JM13stringDecryptESs    = 0x654a18  (JM::stringDecrypt)
//   Lua 桥接层:
//     lua_myclass_encrypt_JM_stringEncrypt = 0x622c20
//     lua_myclass_encrypt_JM_stringDecrypt = 0x623440
//
// 真实地址 = so基地址 + 虚拟地址
// ============================================================
'use strict';

var SO_NAME = 'libcocos2dlua.so';
var SYMS = {
    enc_cpp: 0x653f44,     // JM::stringEncrypt(std::string, std::string)
    dec_cpp: 0x654a18,     // JM::stringDecrypt(std::string)
    enc_lua: 0x622c20,     // lua_myclass_encrypt_JM_stringEncrypt
    dec_lua: 0x623440      // lua_myclass_encrypt_JM_stringDecrypt
};
var HOOKED = false;
var MAX_PRINT = 800;

function trunc(s) {
    if (s === null || s === undefined) return String(s);
    s = String(s);
    return s.length > MAX_PRINT ? s.substring(0, MAX_PRINT) + '...[+' + (s.length - MAX_PRINT) + ' chars]' : s;
}

function findSoBase() {
    var ranges = Process.enumerateRanges('r--');
    for (var i = 0; i < ranges.length; i++) {
        var r = ranges[i];
        if (r.file && r.file.path.indexOf(SO_NAME) !== -1) {
            return r.base;
        }
    }
    return null;
}

function doHook() {
    var base = findSoBase();
    if (!base) return false;
    if (HOOKED) return true;
    console.log('[HOOK] ' + SO_NAME + ' base = ' + base);

    // ============ C++ 层 ============
    // JM::stringEncrypt(std::string data, std::string version)
    // arm64 thiscall: x0=this, x1=data, x2=version
    Interceptor.attach(base.add(SYMS.enc_cpp), {
        onEnter: function(args) {
            try {
                this.plain = args[1].readUtf8String();
                this.ver = args[2].readUtf8String();
            } catch (e) { this.plain = null; }
        },
        onLeave: function(ret) {
            try {
                if (this.plain !== null && this.plain !== undefined) {
                    console.log('[REQ] ver=' + this.ver + ' plain=' + trunc(this.plain));
                }
            } catch (e) {}
        }
    });
    console.log('[HOOK] C++ stringEncrypt @ ' + base.add(SYMS.enc_cpp));

    // JM::stringDecrypt(std::string str)
    Interceptor.attach(base.add(SYMS.dec_cpp), {
        onEnter: function(args) {
            try { this.cipher = args[1].readUtf8String(); } catch (e) { this.cipher = null; }
        },
        onLeave: function(ret) {
            try {
                var out = ret.readUtf8String();
                if (out) console.log('[RSP] plain=' + trunc(out));
            } catch (e) {}
        }
    });
    console.log('[HOOK] C++ stringDecrypt @ ' + base.add(SYMS.dec_cpp));

    // ============ Lua 桥接层 ============
    // lua_myclass_encrypt_JM_stringEncrypt(lua_State* L)
    // 参数在 Lua 栈: arg1=str, arg2=version (lua_tostring 读取)
    Interceptor.attach(base.add(SYMS.enc_lua), {
        onEnter: function(args) {
            try {
                var L = args[0];
                // Lua 栈: index 1 = data, index 2 = version
                var lua_tolstring = new NativeFunction(
                    Module.findExportByName('libc.so', 'lua_tolstring') ||
                    Module.findExportByName(SO_NAME, 'lua_tolstring'), 'pointer', ['pointer', 'int', 'pointer']);
                if (lua_tolstring) {
                    var p1 = lua_tolstring(L, 1, ptr(0));
                    var p2 = lua_tolstring(L, 2, ptr(0));
                    if (!p1.isNull()) {
                        this.lua_plain = p1.readUtf8String();
                        this.lua_ver = p2.isNull() ? '?' : p2.readUtf8String();
                    }
                }
            } catch (e) { this.lua_plain = null; }
        },
        onLeave: function(ret) {
            try {
                if (this.lua_plain !== null && this.lua_plain !== undefined) {
                    console.log('[REQ-LUA] ver=' + this.lua_ver + ' plain=' + trunc(this.lua_plain));
                }
            } catch (e) {}
        }
    });
    console.log('[HOOK] Lua stringEncrypt @ ' + base.add(SYMS.enc_lua));

    // lua_myclass_encrypt_JM_stringDecrypt(lua_State* L)
    Interceptor.attach(base.add(SYMS.dec_lua), {
        onEnter: function(args) {
            try {
                var L = args[0];
                var lua_tolstring = new NativeFunction(
                    Module.findExportByName('libc.so', 'lua_tolstring') ||
                    Module.findExportByName(SO_NAME, 'lua_tolstring'), 'pointer', ['pointer', 'int', 'pointer']);
                if (lua_tolstring) {
                    var p1 = lua_tolstring(L, 1, ptr(0));
                    if (!p1.isNull()) this.lua_cipher = p1.readUtf8String();
                }
            } catch (e) { this.lua_cipher = null; }
        },
        onLeave: function(ret) {
            try {
                // 返回值是明文 (lua 栈顶或返回指针)
                if (this.lua_cipher) {
                    console.log('[RSP-LUA] cipher_len=' + this.lua_cipher.length);
                }
            } catch (e) {}
        }
    });
    console.log('[HOOK] Lua stringDecrypt @ ' + base.add(SYMS.dec_lua));

    HOOKED = true;
    return true;
}

console.log('[START] 等待 ' + SO_NAME + ' 加载...');
var tries = 0;
var timer = setInterval(function() {
    tries++;
    try {
        if (doHook()) {
            clearInterval(timer);
            console.log('[HOOK] 全部挂钩完成 (C++ + Lua), 开始抓包');
        }
    } catch (e) {
        console.log('[ERR] ' + e);
    }
    if (tries >= 90) {
        clearInterval(timer);
        console.log('[HOOK] 90s 超时');
    }
}, 1000);
