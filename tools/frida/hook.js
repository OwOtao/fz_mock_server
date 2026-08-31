// ============================================================
// FXXF01 / JM 密钥与密文观察脚本
//
// 你当前环境 (日志已确认):
//   Process.arch = x64
//   Houdini = true
//   APK native dir = lib/arm64-v8a  (经 Houdini 转译)
//
// 结论:
//   1) 不是"不支持 arm64", 而是模拟器不是原生 arm64
//   2) 在 x86_64+Houdini 上, 任何 native Interceptor.attach 都可能让广告线程崩
//   3) 本脚本默认 **纯 Java 模式**, 不 hook dlopen/native
//   4) 已验证 Java 层可解 FZJH03 / 可加密 JHHU02
//   5) FXXF01 密钥仍需 arm64 真机 native hook, 或等 cocos 真正起来后再抓
//
// 推荐用法 (模拟器):
//   1. 先手动打开 App, 尽量关掉/跳过广告
//   2. frida -U com.xhtt.app.fzjh -l hook.js
//   或 spawn:
//   frida -U -f com.xhtt.app.fzjh -l hook.js --no-pause
//
// 真机 arm64:
//   frida -U -f com.xhtt.app.fzjh -l hook.js --no-pause
//   然后: rpc.exports.setSafeMode(false); rpc.exports.hookNative();
// ============================================================
'use strict';

var SO_CANDIDATES = [
    'libcocos2dlua.so',
    'libcocos2dlua_arm64.so'
];

var OFF_ARM64 = {
    createAes: 0x6811ec,
    setKey: 0x6804b8,
    setIv: 0x6804cc,
    eswh: 0x680b40,
    dswh: 0x680cd4,
    getAesWithHead: 0x680f6c,
    addInfo: 0x652794,
    initLocalKey: 0x652d78,
    stringEncrypt: 0x653f44,
    stringDecrypt: 0x654a18
};

var TARGETS = {
    createAes: '_ZN3cpp3aes9createAesESsSsSsc',
    setKey: '_ZN3cpp3aes6setKeyESs',
    setIv: '_ZN3cpp3aes5setIvESs',
    eswh: '_ZN3cpp3aes4eswhERKSsS2_',
    dswh: '_ZN3cpp3aes4dswhERKSsS2_',
    getAesWithHead: '_ZN3cpp3aes14getAesWithHeadESs',
    addInfo: '_ZN2JM7addInfoESsSsSsc',
    initLocalKey: '_ZN2JM12initLocalKeyEv',
    stringEncrypt: '_ZN2JM13stringEncryptESsSs',
    stringDecrypt: '_ZN2JM13stringDecryptESs'
};

// null=自动: x64/Houdini => true
var SAFE_MODE = null;
var FORCE_NATIVE = false;
var ENABLE_DLOPEN_WATCH = false; // 模拟器默认关, 避免 Houdini 崩

var state = {
    envPrinted: false,
    javaHooked: false,
    nativeHooked: false,
    found: {},
    cipherLog: []
};

function log(msg) { console.log(msg); }

function arch() { return Process.arch; }
function isX64Host() { return arch() === 'x64' || arch() === 'ia32'; }

function hasHoudini() {
    try {
        var mods = Process.enumerateModules();
        for (var i = 0; i < mods.length; i++) {
            var n = (mods[i].name || '').toLowerCase();
            var p = (mods[i].path || '').toLowerCase();
            if (n.indexOf('houdini') !== -1 || p.indexOf('houdini') !== -1) return true;
            if (n.indexOf('libndk_translation') !== -1) return true;
        }
    } catch (e) {}
    return false;
}

function shouldUseSafeMode() {
    if (SAFE_MODE !== null) return !!SAFE_MODE;
    if (FORCE_NATIVE) return false;
    if (isX64Host()) return true;
    if (hasHoudini()) return true;
    return false;
}

function printEnv() {
    if (state.envPrinted) return;
    state.envPrinted = true;
    var safe = shouldUseSafeMode();
    log('============================================================');
    log('[*] JM/FXXF01 hunter');
    log('[*] Process.arch = ' + arch());
    log('[*] pointerSize  = ' + Process.pointerSize);
    log('[*] Houdini      = ' + hasHoudini());
    log('[*] SAFE_MODE    = ' + safe + (SAFE_MODE === null ? ' (auto)' : ' (manual)'));
    log('[*] DLOPEN_WATCH = ' + ENABLE_DLOPEN_WATCH);
    if (isX64Host() || hasHoudini()) {
        log('[!] 当前为 x86_64 + ARM 转译环境');
        log('[!] 默认只做 Java hook, 不 attach native / dlopen');
        log('[!] 抓 FXXF01 native 密钥请换 arm64 真机');
        log('[!] 已从日志确认:');
        log('    - JniNative.Decrypt(FZJH03...) 可解 JSON');
        log('    - JniNative.Encrypt(..., JHHU02) 可加密');
        log('    - libcocos2dlua 在广告阶段常未加载就崩');
    } else if (arch() === 'arm64') {
        log('[+] 原生 arm64, 可用 rpc.exports.hookNative()');
    }
    log('============================================================');
}

function hasMarker(s) {
    if (!s) return false;
    s = String(s);
    return /FXXF0[1-4]|FZJH0[1-3]|JHHU0[12]/i.test(s);
}

function hasFxxf01(s) {
    return !!(s && String(s).indexOf('FXXF01') !== -1);
}

function magicOfHex(hex) {
    if (!hex) return null;
    var h = String(hex).replace(/\s+/g, '').toLowerCase();
    if (h.length < 12) return null;
    // 前 6 字节 ascii
    try {
        var out = '';
        for (var i = 0; i < 12; i += 2) {
            out += String.fromCharCode(parseInt(h.substr(i, 2), 16));
        }
        return out;
    } catch (e) {
        return null;
    }
}

function saveCipher(tag, hex, plain) {
    var item = {
        tag: tag,
        magic: magicOfHex(hex),
        hexHead: hex ? String(hex).slice(0, 64) : null,
        hexLen: hex ? String(hex).length : 0,
        plainHead: plain ? String(plain).slice(0, 160) : null
    };
    state.cipherLog.push(item);
    log('[CAP] ' + tag +
        ' magic=' + item.magic +
        ' hexLen=' + item.hexLen +
        ' plain=' + (item.plainHead || ''));
    if (item.magic === 'FXXF01' || hasFxxf01(hex) || hasFxxf01(plain)) {
        log('[!!!] 捕获到 FXXF01 相关数据 (仍缺 native key/iv 才能本地复现解密)');
    }
}

function savePair(tag, key, iv, extra) {
    var id = tag + '|' + key + '|' + iv + '|' + (extra || '');
    if (state.found[id]) return;
    state.found[id] = true;
    log('');
    log('============================================================');
    log('[!!!] 密钥候选: ' + tag);
    if (extra) log('[!!!] extra = ' + extra);
    if (key != null) log('[!!!] key = ' + key);
    if (iv != null) log('[!!!] iv  = ' + iv);
    if (hasFxxf01(key) || hasFxxf01(iv) || hasFxxf01(extra) ||
        String(extra || '').indexOf('FXXF01') !== -1) {
        log('[!!!] **** FXXF01 相关, 请保存 ****');
        log("KEY_GROUPS['FXXF01'] = {");
        log("    'magic': b'FXXF01',");
        if (key != null) log("    'key':   b'" + String(key).replace(/\\/g, '\\\\').replace(/'/g, "\\'") + "',");
        if (iv != null) log("    'iv':    b'" + String(iv).replace(/\\/g, '\\\\').replace(/'/g, "\\'") + "',");
        log('}');
    }
    log('============================================================');
    log('');
}

function findCocosModule() {
    var i, m, all;
    for (i = 0; i < SO_CANDIDATES.length; i++) {
        m = Process.findModuleByName(SO_CANDIDATES[i]);
        if (m) return m;
    }
    try {
        all = Process.enumerateModules();
        for (i = 0; i < all.length; i++) {
            if ((all[i].name || '').indexOf('libcocos2dlua') !== -1) return all[i];
            if ((all[i].path || '').indexOf('libcocos2dlua') !== -1) return all[i];
        }
    } catch (e) {}
    return null;
}

function listInterestingModules() {
    try {
        var all = Process.enumerateModules();
        var hits = [];
        for (var i = 0; i < all.length; i++) {
            var n = (all[i].name || '').toLowerCase();
            var p = (all[i].path || '').toLowerCase();
            if (n.indexOf('cocos') !== -1 || n.indexOf('houdini') !== -1 ||
                p.indexOf('xhtt') !== -1 || p.indexOf('fzjh') !== -1 ||
                n.indexOf('encrypt') !== -1) {
                hits.push(all[i].name + ' @ ' + all[i].base + ' | ' + all[i].path);
            }
        }
        if (hits.length) {
            log('[*] modules:');
            for (var j = 0; j < hits.length; j++) log('    ' + hits[j]);
        } else {
            log('[*] no cocos/houdini/xhtt modules yet');
        }
    } catch (e) {
        log('[-] list modules: ' + e);
    }
}

function javaStr(o) {
    if (o === null || o === undefined) return null;
    try { return String(o); } catch (e) { return null; }
}

function hookJava() {
    if (state.javaHooked) return true;
    if (typeof Java === 'undefined' || !Java.available) {
        log('[-] Java unavailable');
        return false;
    }

    Java.perform(function () {
        log('[*] Java.perform ready');

        // ---- JniNative ----
        var clsName = 'com.xhtt.app.fzjh.jni.JniNative';
        try {
            var C = Java.use(clsName);
            log('[+] Java class: ' + clsName);

            function hookM(name, handler) {
                try {
                    var ovs = C[name].overloads;
                    for (var i = 0; i < ovs.length; i++) {
                        (function (ov) {
                            ov.implementation = function () {
                                return handler.call(this, ov, arguments);
                            };
                        })(ovs[i]);
                    }
                    log('[+] hooked ' + clsName + '.' + name + ' x' + ovs.length);
                    return true;
                } catch (e) {
                    log('[*] skip ' + name + ': ' + e);
                    return false;
                }
            }

            hookM('Decrypt', function (ov, args) {
                var cipher = javaStr(args[0]);
                var magic = magicOfHex(cipher);
                log('[Java→] Decrypt magic=' + magic + ' len=' + (cipher ? cipher.length : 0));
                if (cipher) log('[Java→] Decrypt.head=' + cipher.slice(0, 80));
                var ret = ov.apply(this, args);
                var plain = javaStr(ret);
                if (plain) log('[Java←] Decrypt => ' + plain.slice(0, 220));
                saveCipher('JniNative.Decrypt', cipher, plain);
                // 若返回里还嵌套 FXXF01 hex, 也提示
                if (plain && hasFxxf01(plain)) {
                    log('[!!!] Decrypt 明文中含 FXXF01 字符串, 可能是二次封装');
                }
                return ret;
            });

            hookM('Encrypt', function (ov, args) {
                var plain = javaStr(args[0]);
                var group = args.length > 1 ? javaStr(args[1]) : null;
                log('[Java→] Encrypt group=' + group + ' plainHead=' + (plain ? plain.slice(0, 100) : null));
                if (group) log('[!!!] Encrypt 显式密钥组 = ' + group);
                if (hasMarker(group)) savePair('JniNative.Encrypt.group', null, null, 'group=' + group);
                var ret = ov.apply(this, args);
                var cipher = javaStr(ret);
                if (cipher) {
                    log('[Java←] Encrypt magic=' + magicOfHex(cipher) + ' head=' + cipher.slice(0, 80));
                }
                saveCipher('JniNative.Encrypt', cipher, plain);
                return ret;
            });

            hookM('quickDecrypt', function (ov, args) {
                var cipher = javaStr(args[0]);
                log('[Java→] quickDecrypt head=' + (cipher ? cipher.slice(0, 80) : null));
                var ret = ov.apply(this, args);
                var plain = javaStr(ret);
                log('[Java←] quickDecrypt => ' + (plain ? plain.slice(0, 200) : null));
                saveCipher('JniNative.quickDecrypt', cipher, plain);
                return ret;
            });

            hookM('doMd5ForHttpRequest', function (ov, args) {
                var a = [];
                for (var i = 0; i < args.length; i++) a.push(javaStr(args[i]));
                var ret = ov.apply(this, args);
                log('[Java] doMd5ForHttpRequest(' + a.join(' | ') + ') => ' + javaStr(ret));
                return ret;
            });

            hookM('initConfigData', function (ov, args) {
                var a = [];
                for (var i = 0; i < args.length; i++) a.push(javaStr(args[i]));
                var ret = ov.apply(this, args);
                log('[Java] initConfigData(' + a.join(' | ') + ') => ' + javaStr(ret));
                return ret;
            });

            hookM('getServerHost', function (ov, args) {
                var ret = ov.apply(this, args);
                log('[Java] getServerHost => ' + javaStr(ret));
                return ret;
            });

            hookM('getStringProperty', function (ov, args) {
                var k = javaStr(args[0]);
                var ret = ov.apply(this, args);
                log('[Java] getStringProperty(' + k + ') => ' + javaStr(ret));
                return ret;
            });

            hookM('GetUserValue', function (ov, args) {
                var k = javaStr(args[0]);
                var ret = ov.apply(this, args);
                log('[Java] GetUserValue(' + k + ') => ' + javaStr(ret));
                return ret;
            });

            hookM('a', function (ov, args) {
                // 从日志看 a(json) 内部会调 Encrypt(..., JHHU02)
                var input = javaStr(args[0]);
                log('[Java→] a() inputHead=' + (input ? input.slice(0, 120) : null));
                var ret = ov.apply(this, args);
                var out = javaStr(ret);
                log('[Java←] a() => ' + (out ? out.slice(0, 100) : null));
                if (out && /^[0-9a-fA-F]+$/.test(out)) saveCipher('JniNative.a', out, input);
                return ret;
            });

            hookM('CallFunc', function (ov, args) {
                var a = [];
                for (var i = 0; i < args.length; i++) a.push(javaStr(args[i]));
                log('[Java→] CallFunc(' + a.join(' | ') + ')');
                var ret = ov.apply(this, args);
                log('[Java←] CallFunc => ' + javaStr(ret));
                return ret;
            });

            hookM('ss', function (ov, args) {
                log('[Java] ss(' + javaStr(args[0]) + ')');
                return ov.apply(this, args);
            });

            hookM('UpdateManagerGetVersion', function (ov, args) {
                var ret = ov.apply(this, args);
                log('[Java] UpdateManagerGetVersion => ' + javaStr(ret));
                return ret;
            });

            hookM('getWebTime', function (ov, args) {
                var ret = ov.apply(this, args);
                log('[Java] getWebTime => ' + javaStr(ret));
                return ret;
            });

        } catch (eCls) {
            log('[-] JniNative 未找到: ' + eCls);
            log('[*] 尝试 rpc.exports.listClasses("JniNative")');
        }

        // ---- loadLibrary: 只观察, 不在回调里 attach native ----
        try {
            var System = Java.use('java.lang.System');
            var loadL = System.loadLibrary.overload('java.lang.String');
            loadL.implementation = function (lib) {
                log('[Java] System.loadLibrary: ' + lib);
                var ret = loadL.call(this, lib);
                if (String(lib).indexOf('cocos2dlua') !== -1) {
                    log('[!!!] cocos2dlua 已加载 (Java 层)');
                    setTimeout(function () {
                        listInterestingModules();
                        // 安全模式不自动 native hook
                        if (!shouldUseSafeMode()) maybeHookNative('after-loadLibrary');
                        else log('[*] SAFE_MODE: 仅记录, 不 native hook. 真机可 rpc.exports.hookNative()');
                    }, 300);
                }
                return ret;
            };
            log('[+] hooked System.loadLibrary');
        } catch (e1) {
            log('[*] System.loadLibrary hook fail: ' + e1);
        }

        try {
            var Runtime = Java.use('java.lang.Runtime');
            var load0 = Runtime.loadLibrary0.overload('java.lang.ClassLoader', 'java.lang.String');
            load0.implementation = function (cl, lib) {
                log('[Java] Runtime.loadLibrary0: ' + lib);
                var ret = load0.call(this, cl, lib);
                if (String(lib).indexOf('cocos2dlua') !== -1) {
                    log('[!!!] cocos2dlua via Runtime.loadLibrary0');
                    setTimeout(function () {
                        listInterestingModules();
                        if (!shouldUseSafeMode()) maybeHookNative('after-loadLibrary0');
                    }, 300);
                }
                return ret;
            };
            log('[+] hooked Runtime.loadLibrary0');
        } catch (e2) {
            log('[*] Runtime.loadLibrary0 hook fail: ' + e2);
        }

        // ---- 可选: 通用 JSON 字符串里搜 FXXF01 ----
        try {
            var StringCls = Java.use('java.lang.String');
            // 太重, 默认不 hook String.<init>
        } catch (e3) {}

        state.javaHooked = true;
        log('[+] Java hook 完成 (pure-java / SAFE_MODE=' + shouldUseSafeMode() + ')');
        log('[*] 关注 Decrypt 的 magic: FZJH03=线上, JHHU02=本地, FXXF01=引导配置');
    });
    return true;
}

// ---------------- Native (仅 arm64 / 手动开启) ----------------
function readStdString(obj) {
    try {
        if (!obj || obj.isNull()) return null;
        var p = obj.readPointer();
        var len = obj.add(8).readU64().toNumber();
        if (len < 0 || len > 0x100000) return null;
        if (len === 0) return new ArrayBuffer(0);
        var local = obj.add(16);
        if (p.compare(local) >= 0 && p.compare(obj.add(48)) < 0) return local.readByteArray(len);
        return p.readByteArray(len);
    } catch (e) {
        return null;
    }
}

function textOf(buf) {
    if (!buf) return '';
    var u8 = new Uint8Array(buf);
    var s = '';
    for (var i = 0; i < u8.length; i++) s += String.fromCharCode(u8[i]);
    return s;
}

function resolveAddr(mod, symbol, offline) {
    try {
        var exp = Module.findExportByName(mod.name, symbol);
        if (exp) return { addr: exp, how: 'export' };
    } catch (e0) {}
    try {
        var exp2 = Module.findExportByName(null, symbol);
        if (exp2) return { addr: exp2, how: 'export-global' };
    } catch (e1) {}
    if (arch() === 'arm64' && offline != null) {
        return { addr: mod.base.add(offline), how: 'arm64-offset' };
    }
    return null;
}

function installNativeHooks(mod) {
    if (state.nativeHooked) return true;
    if (shouldUseSafeMode() && !FORCE_NATIVE) {
        log('[!] SAFE_MODE: 拒绝 native hook (防 Houdini 崩)');
        return false;
    }
    if (isX64Host() && !FORCE_NATIVE) {
        log('[!] x64 host 拒绝 native hook, 除非 FORCE_NATIVE');
        return false;
    }

    log('[+] native hook on ' + mod.name + ' @ ' + mod.base);
    var ok = 0;
    function one(key, symbol, offline, handlers) {
        var r = resolveAddr(mod, symbol, offline);
        if (!r) {
            log('[-] resolve fail ' + key);
            return;
        }
        try {
            Interceptor.attach(r.addr, handlers);
            ok++;
            log('[+] Hook ' + key + ' @ ' + r.addr + ' via ' + r.how);
        } catch (e) {
            log('[-] Hook fail ' + key + ': ' + e);
        }
    }

    one('createAes', TARGETS.createAes, OFF_ARM64.createAes, {
        onEnter: function (args) {
            var key = textOf(readStdString(args[1]));
            var iv = textOf(readStdString(args[2]));
            var tag = 0;
            try { tag = args[3].toInt32(); } catch (e) {}
            log('[N] createAes tag=' + tag + ' key=' + key + ' iv=' + iv);
            savePair('createAes', key, iv, 'tag=' + tag);
        }
    });

    one('addInfo', TARGETS.addInfo, OFF_ARM64.addInfo, {
        onEnter: function (args) {
            var pairs = [
                [textOf(readStdString(args[1])), textOf(readStdString(args[2])), textOf(readStdString(args[3]))],
                [textOf(readStdString(args[0])), textOf(readStdString(args[1])), textOf(readStdString(args[2]))]
            ];
            for (var i = 0; i < pairs.length; i++) {
                var head = pairs[i][0], key = pairs[i][1], iv = pairs[i][2];
                if (head && head.length <= 16 && key && key.length >= 16) {
                    log('[N] addInfo head=' + head + ' key=' + key + ' iv=' + iv);
                    savePair('addInfo', key, iv, 'head=' + head);
                    break;
                }
            }
        }
    });

    one('setKey', TARGETS.setKey, OFF_ARM64.setKey, {
        onEnter: function (args) {
            var key = textOf(readStdString(args[1]));
            if (key) {
                log('[N] setKey ' + key);
                savePair('setKey', key, null, null);
            }
        }
    });

    one('setIv', TARGETS.setIv, OFF_ARM64.setIv, {
        onEnter: function (args) {
            var iv = textOf(readStdString(args[1]));
            if (iv) {
                log('[N] setIv ' + iv);
                savePair('setIv', null, iv, null);
            }
        }
    });

    one('stringDecrypt', TARGETS.stringDecrypt, OFF_ARM64.stringDecrypt, {
        onEnter: function (args) {
            this.c = textOf(readStdString(args[1])) || textOf(readStdString(args[0]));
        },
        onLeave: function (retval) {
            if (hasFxxf01(this.c)) {
                var out = textOf(readStdString(retval));
                log('[N] stringDecrypt FXXF01 cipherHead=' + (this.c || '').slice(0, 80));
                log('[N] plainHead=' + (out || '').slice(0, 200));
            }
        }
    });

    state.nativeHooked = ok > 0;
    log('[*] native hooks installed: ' + ok);
    return state.nativeHooked;
}

function maybeHookNative(reason) {
    var mod = findCocosModule();
    if (!mod) {
        log('[*] [' + reason + '] cocos SO not found');
        return false;
    }
    log('[+] [' + reason + '] found ' + mod.name + ' @ ' + mod.base);
    return installNativeHooks(mod);
}

function pollForSoSoft() {
    // 只轮询打印, 不做 native attach
    var tries = 0;
    var timer = setInterval(function () {
        tries++;
        var mod = findCocosModule();
        if (mod) {
            log('[+] cocos SO appeared: ' + mod.name + ' @ ' + mod.base);
            listInterestingModules();
            if (!shouldUseSafeMode()) maybeHookNative('poll');
            else log('[*] SAFE_MODE: SO 已出现但未 native hook。真机执行 rpc.exports.hookNative()');
            clearInterval(timer);
            return;
        }
        if (tries === 1 || tries % 30 === 0) {
            log('[*] wait cocos SO ... #' + tries + ' (java-only, no native attach)');
        }
        if (tries > 150) {
            log('[-] cocos SO 仍未加载。你上次日志也显示广告阶段就崩了, 尚未 loadLibrary(cocos2dlua)');
            listInterestingModules();
            clearInterval(timer);
        }
    }, 300);
}

rpc.exports = {
    setSafeMode: function (v) {
        SAFE_MODE = !!v;
        log('[*] SAFE_MODE => ' + SAFE_MODE);
        return SAFE_MODE;
    },
    setForceNative: function (v) {
        FORCE_NATIVE = !!v;
        log('[*] FORCE_NATIVE => ' + FORCE_NATIVE);
        return FORCE_NATIVE;
    },
    setDlopenWatch: function (v) {
        ENABLE_DLOPEN_WATCH = !!v;
        log('[*] ENABLE_DLOPEN_WATCH => ' + ENABLE_DLOPEN_WATCH);
        return ENABLE_DLOPEN_WATCH;
    },
    hookNative: function () {
        FORCE_NATIVE = true;
        SAFE_MODE = false;
        return maybeHookNative('rpc');
    },
    env: function () {
        printEnv();
        listInterestingModules();
        var mod = findCocosModule();
        return {
            arch: arch(),
            houdini: hasHoudini(),
            safe: shouldUseSafeMode(),
            so: mod ? mod.name : null,
            cipherCount: state.cipherLog.length,
            foundKeys: Object.keys(state.found).length
        };
    },
    ciphers: function () {
        return state.cipherLog.slice(-50);
    },
    listClasses: function (keyword) {
        var out = [];
        if (typeof Java === 'undefined' || !Java.available) return ['Java unavailable'];
        Java.perform(function () {
            Java.enumerateLoadedClasses({
                onMatch: function (name) {
                    if (!keyword || name.toLowerCase().indexOf(String(keyword).toLowerCase()) !== -1) {
                        out.push(name);
                    }
                },
                onComplete: function () {}
            });
        });
        out.sort();
        for (var i = 0; i < Math.min(out.length, 100); i++) log('  ' + out[i]);
        log('[*] matched ' + out.length);
        return out.slice(0, 300);
    }
};

function main() {
    printEnv();
    listInterestingModules();

    try { hookJava(); } catch (e) { log('[-] hookJava: ' + e); }

    // 明确: 默认不 watch dlopen, 避免 Houdini 崩
    if (ENABLE_DLOPEN_WATCH && !shouldUseSafeMode()) {
        log('[*] dlopen watch enabled');
    } else {
        log('[*] dlopen/native watch disabled (SAFE_MODE/java-only)');
    }

    pollForSoSoft();

    log('[*] ready.');
    log('[*] 模拟器建议: 先手动进游戏, 再 attach; 或 spawn 后尽快跳过广告');
    log('[*] 控制台: rpc.exports.env() / rpc.exports.ciphers() / rpc.exports.listClasses("Jni")');
    log('[*] 真机抓 FXXF01: rpc.exports.setSafeMode(false); rpc.exports.hookNative()');
}

setImmediate(main);
