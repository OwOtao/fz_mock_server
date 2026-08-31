// ============================================================
// FXXF01 密钥捕获 Hook (Houdini 转译兼容版)
//
// 背景:
//   - 运行环境: x86_64 模拟器 (LDPlayer14) + Houdini 转译 ARM64 SO。
//   - Houdini 加载的 libcocos2dlua.so 不会出现在 Frida 模块列表,
//     因此不能用 Process.findModuleByName / Module.findExportByName。
//   - 本脚本沿用 fzjh_jm_spawn_hook.js 已验证的方案:
//     用 Process.enumerateRanges 按内存映射文件路径定位 SO 基址,
//     再加已静态验证的 ARM64 符号偏移插桩。
//
// 目标 (均为 libcocos2dlua_arm64.so 的 .dynsym 偏移):
//   JM::addInfo   = 0x652794  运行时注册密钥组 (magic,key,iv,tag)
//   JM::getKey    = 0x653c88  解密时按 magic 取 key/iv
//   cpp::aes::createAes = 0x6811ec  兜底捕获 (this,key,iv,tag)
//
// 关键: FXXF01 不在 initLocalKey 静态注册表, 由 getHttpHeaders 解析
//       get_game_config 响应头后调用 addInfo 动态注册。本 hook 捕获该过程。
//
// 用法:
//   python frida/run_frida_spawn.py   (把 HOOK_JS_PATH 指向本文件)
//   或 frida -U -f com.xhtt.app.fzjh -l frida/frida_hook_addinfo.js --no-pause
// ============================================================
'use strict';

var SO_NAME = 'libcocos2dlua.so';

// ARM64 符号偏移 (从 .dynsym 静态解析, 与 fzjh_jm_spawn_hook.js 同源)
var OFF_ADDINFO   = 0x652794;  // JM::addInfo(std::string, std::string, std::string, char)
var OFF_GETKEY    = 0x653c88;  // JM::getKey(unsigned char*, std::string&, std::string&)
var OFF_CREATEAES = 0x6811ec;  // cpp::aes::createAes(this, key, iv, tag)

var hooked = false;

function sendEvent(kind, details) {
    send({ kind: kind, details: details });
}

// ---- Houdini 兼容: 通过内存映射定位 SO 基址 ----
function findSoBase() {
    var ranges = Process.enumerateRanges('r--');
    for (var i = 0; i < ranges.length; i++) {
        var r = ranges[i];
        if (r.file !== null && r.file !== undefined &&
            r.file.path.indexOf(SO_NAME) !== -1) {
            // 取最低基址 (第一个可执行映射通常是 ELF 头所在)
            return r.base;
        }
    }
    return null;
}

// ---- 老版 libstdc++ std::string: +0 _M_p | +8 _M_string_length | +16 SSO buf ----
// (与 frida_getkeys.js 一致, 已在 Houdini 下验证可读出 FZJH03 key/iv)
function readStdString(obj) {
    try {
        if (obj === null || obj.isNull()) return null;
        var p = obj.readPointer();
        var len = obj.add(8).readU64().toNumber();
        if (len <= 0 || len > 0x40000000) return null;
        // SSO 防护: _M_p 指向对象内部 local buf(+16..+48) 时直接取对象内字节
        var objLo = obj.add(16);
        var objHi = obj.add(48);
        if (p.compare(objLo) >= 0 && p.compare(objHi) < 0) {
            return obj.add(16).readByteArray(len);
        }
        return p.readByteArray(len);
    } catch (e) {
        return null;
    }
}

function bufToHex(buf) {
    if (!buf) return '';
    var u8 = new Uint8Array(buf);
    var s = '';
    for (var i = 0; i < u8.length; i++) s += ('0' + u8[i].toString(16)).slice(-2);
    return s;
}

function bufToStr(buf) {
    if (!buf) return '';
    var u8 = new Uint8Array(buf);
    var s = '';
    for (var i = 0; i < u8.length; i++) {
        s += (u8[i] >= 32 && u8[i] < 127) ? String.fromCharCode(u8[i]) : '.';
    }
    return s;
}

function isFXXF(magicStr) {
    return magicStr && magicStr.indexOf('FXXF') === 0;
}

// ---- hook JM::addInfo(magic, key, iv, tag) ----
function hookAddInfo(base) {
    var target = base.add(OFF_ADDINFO);
    try { target.readU32(); } catch (e) {
        sendEvent('error', { stage: 'validate-addInfo', error: String(e), address: String(target) });
        return false;
    }
    Interceptor.attach(target, {
        onEnter: function (args) {
            // x0=magic(std::string), x1=key(std::string), x2=iv(std::string), w3=tag
            var magic = readStdString(args[0]);
            var key   = readStdString(args[1]);
            var iv    = readStdString(args[2]);
            var tag   = args[3].toInt32() & 0xFF;
            var magicStr = bufToStr(magic);

            sendEvent('jm-addInfo', {
                magic: magicStr,
                magic_hex: bufToHex(magic),
                key: bufToStr(key),
                key_hex: bufToHex(key),
                key_len: key ? key.byteLength : 0,
                iv: bufToStr(iv),
                iv_hex: bufToHex(iv),
                iv_len: iv ? iv.byteLength : 0,
                tag: tag,
                threadId: Process.getCurrentThreadId()
            });

            if (isFXXF(magicStr)) {
                console.log('\n********** FXXF KEY CAPTURED (addInfo) **********');
                console.log('  magic : ' + magicStr);
                console.log('  key   : ' + bufToStr(key) + '  (' + (key ? key.byteLength : 0) + 'B)');
                console.log('  key_hex: ' + bufToHex(key));
                console.log('  iv    : ' + bufToStr(iv) + '  (' + (iv ? iv.byteLength : 0) + 'B)');
                console.log('  tag   : ' + tag);
                console.log('*************************************************\n');
            }
        }
    });
    sendEvent('hooked', { func: 'JM::addInfo', address: String(target) });
    return true;
}

// ---- hook JM::getKey(magic, out_key, out_iv) ----
function hookGetKey(base) {
    var target = base.add(OFF_GETKEY);
    try { target.readU32(); } catch (e) {
        sendEvent('error', { stage: 'validate-getKey', error: String(e), address: String(target) });
        return false;
    }
    Interceptor.attach(target, {
        onEnter: function (args) {
            // x0=magic(const char*), x1=out_key(std::string&), x2=out_iv(std::string&)
            this.magicPtr = args[0];
            this.keyOut = args[1];
            this.ivOut = args[2];
        },
        onLeave: function (retval) {
            try {
                var magic = this.magicPtr.readCString();
                if (magic && isFXXF(magic)) {
                    var key = readStdString(this.keyOut);
                    var iv = readStdString(this.ivOut);
                    console.log('\n********** FXXF getKey (decrypt path) **********');
                    console.log('  magic : ' + magic);
                    console.log('  key   : ' + bufToStr(key) + '  (' + (key ? key.byteLength : 0) + 'B)');
                    console.log('  iv    : ' + bufToStr(iv) + '  (' + (iv ? iv.byteLength : 0) + 'B)');
                    console.log('*************************************************\n');
                    sendEvent('jm-getKey-FXXF', {
                        magic: magic,
                        key: bufToStr(key), key_hex: bufToHex(key),
                        iv: bufToStr(iv), iv_hex: bufToHex(iv)
                    });
                }
            } catch (e) {}
        }
    });
    sendEvent('hooked', { func: 'JM::getKey', address: String(target) });
    return true;
}

// ---- 兜底: hook cpp::aes::createAes(this, key, iv, tag) ----
function hookCreateAes(base) {
    var target = base.add(OFF_CREATEAES);
    try { target.readU32(); } catch (e) {
        sendEvent('error', { stage: 'validate-createAes', error: String(e), address: String(target) });
        return false;
    }
    Interceptor.attach(target, {
        onEnter: function (args) {
            // 非静态成员: x0=this, x1=key(std::string), x2=iv(std::string), w3=tag
            var key = readStdString(args[1]);
            var iv  = readStdString(args[2]);
            var tag = args[3].toInt32() & 0xFF;
            sendEvent('aes-createAes', {
                this: String(args[0]),
                key: bufToStr(key), key_hex: bufToHex(key), key_len: key ? key.byteLength : 0,
                iv: bufToStr(iv), iv_hex: bufToHex(iv), iv_len: iv ? iv.byteLength : 0,
                tag: tag,
                threadId: Process.getCurrentThreadId()
            });
        }
    });
    sendEvent('hooked', { func: 'cpp::aes::createAes', address: String(target) });
    return true;
}

// ---- 安装所有 hook ----
function installHooks() {
    if (hooked) return true;
    var base = findSoBase();
    if (base === null) return false;

    sendEvent('so-found', { base: String(base), so: SO_NAME, arch: Process.arch });

    var ok1 = hookAddInfo(base);
    var ok2 = hookGetKey(base);
    var ok3 = hookCreateAes(base);

    if (ok1 || ok2 || ok3) {
        hooked = true;
        sendEvent('all-hooked', {
            processId: Process.id,
            architecture: Process.arch,
            soBase: String(base),
            addInfo: ok1, getKey: ok2, createAes: ok3
        });
        console.log('[+] Hooks installed. base=' + base +
                    ' addInfo=' + ok1 + ' getKey=' + ok2 + ' createAes=' + ok3);
        console.log('[*] 现在启动/登录游戏, 触发 get_game_config 以捕获 FXXF01 key...');
        return true;
    }
    return false;
}

// ---- 轮询等待 SO 加载 (Houdini 下 SO 加载较晚) ----
var attempts = 0;
var waitTimer = setInterval(function () {
    attempts++;
    try {
        if (installHooks()) {
            clearInterval(waitTimer);
        }
    } catch (e) {
        sendEvent('error', { stage: 'install-hooks', error: String(e) });
    }
    if (attempts >= 120) {
        clearInterval(waitTimer);
        sendEvent('timeout', { seconds: 120, module: SO_NAME });
    }
}, 1000);

sendEvent('injected', { processId: Process.id, waitingFor: SO_NAME });
