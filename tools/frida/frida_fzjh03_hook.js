'use strict';

var SO_SUFFIXES = ['libcocos2dlua.so', 'libcocos2dlua_arm64.so'];
var MAX_DUMP = 262144;
var OFFSETS = {
    createAes: 0x6811ec,
    setKey: 0x6804b8,
    setIv: 0x6804cc,
    eswh: 0x680b40,
    dswh: 0x680cd4,
    getAesWithHead: 0x680f6c
};
var SYMBOLS = {
    createAes: '_ZN3cpp3aes9createAesESsSsSsc',
    setKey: '_ZN3cpp3aes6setKeyESs',
    setIv: '_ZN3cpp3aes5setIvESs',
    eswh: '_ZN3cpp3aes4eswhERKSsS2_',
    dswh: '_ZN3cpp3aes4dswhERKSsS2_',
    getAesWithHead: '_ZN3cpp3aes14getAesWithHeadESs'
};
var hooked = false;

function out(type, data) {
    data = data || {};
    data.type = type;
    data.ts = Date.now();
    send(data);
}

function moduleInfo() {
    for (var i = 0; i < SO_SUFFIXES.length; i++) {
        var m = Process.findModuleByName(SO_SUFFIXES[i]);
        if (m) return m;
    }
    var all = Process.enumerateModules();
    for (var j = 0; j < all.length; j++) {
        if (all[j].name.indexOf('libcocos2dlua') !== -1) return all[j];
    }
    return null;
}

function bytesToHex(buf) {
    if (!buf) return '';
    var u8 = new Uint8Array(buf);
    var s = '';
    for (var i = 0; i < u8.length; i++) s += ('0' + u8[i].toString(16)).slice(-2);
    return s;
}

function b64(buf) {
    var u8 = new Uint8Array(buf);
    var alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
    var result = '';
    for (var i = 0; i < u8.length; i += 3) {
        var a = u8[i];
        var b = i + 1 < u8.length ? u8[i + 1] : 0;
        var c = i + 2 < u8.length ? u8[i + 2] : 0;
        result += alphabet[a >> 2];
        result += alphabet[((a & 3) << 4) | (b >> 4)];
        result += i + 1 < u8.length ? alphabet[((b & 15) << 2) | (c >> 6)] : '=';
        result += i + 2 < u8.length ? alphabet[c & 63] : '=';
    }
    return result;
}

function textPreview(buf) {
    var u8 = new Uint8Array(buf);
    var s = '';
    for (var i = 0; i < u8.length; i++) {
        var c = u8[i];
        s += c >= 0x20 && c <= 0x7e ? String.fromCharCode(c) : '.';
    }
    return s;
}

function readStdString(obj) {
    try {
        if (obj.isNull()) return null;
        var p = obj.readPointer();
        var len = obj.add(8).readU64().toNumber();
        if (len < 0 || len > MAX_DUMP) return null;
        if (len === 0) return new ArrayBuffer(0);
        var local = obj.add(16);
        if (p.compare(local) >= 0 && p.compare(obj.add(48)) < 0) return local.readByteArray(len);
        return p.readByteArray(len);
    } catch (e) {
        return null;
    }
}

function emitBuffer(tag, buf, meta) {
    if (!buf) return;
    var u8 = new Uint8Array(buf);
    var n = Math.min(u8.length, MAX_DUMP);
    var part = u8.slice(0, n).buffer;
    out('buffer', {
        tag: tag,
        len: u8.length,
        truncated: n !== u8.length,
        hex: bytesToHex(part),
        b64: b64(part),
        text: textPreview(part),
        meta: meta || {}
    });
}

function isFzjh03(buf) {
    if (!buf || buf.byteLength < 12) return false;
    var u8 = new Uint8Array(buf);
    var magic = [0x34, 0x36, 0x35, 0x61, 0x34, 0x61, 0x34, 0x38, 0x34, 0x38, 0x33, 0x30];
    for (var i = 0; i < magic.length; i++) if (u8[i] !== magic[i]) return false;
    return true;
}

function resolve(module, name, fallback) {
    try {
        var syms = module.enumerateSymbols();
        for (var i = 0; i < syms.length; i++) {
            if (syms[i].name === name) return syms[i].address;
        }
    } catch (e) {}
    return module.base.add(fallback);
}

function hookNative(module) {
    var createAes = resolve(module, SYMBOLS.createAes, OFFSETS.createAes);
    var setKey = resolve(module, SYMBOLS.setKey, OFFSETS.setKey);
    var setIv = resolve(module, SYMBOLS.setIv, OFFSETS.setIv);
    var eswh = resolve(module, SYMBOLS.eswh, OFFSETS.eswh);
    var dswh = resolve(module, SYMBOLS.dswh, OFFSETS.dswh);
    var getAesWithHead = resolve(module, SYMBOLS.getAesWithHead, OFFSETS.getAesWithHead);

    Interceptor.attach(createAes, {
        onEnter: function (args) {
            emitBuffer('createAes.key', readStdString(args[1]), { tag: args[3].toInt32() });
            emitBuffer('createAes.iv', readStdString(args[2]), { tag: args[3].toInt32() });
        }
    });
    Interceptor.attach(setKey, { onEnter: function (args) { emitBuffer('setKey', readStdString(args[1])); } });
    Interceptor.attach(setIv, { onEnter: function (args) { emitBuffer('setIv', readStdString(args[1])); } });

    Interceptor.attach(eswh, {
        onEnter: function (args) {
            this.a = readStdString(args[1]);
            this.b = readStdString(args[2]);
        },
        onLeave: function (retval) {
            emitBuffer('eswh.input', this.a);
            emitBuffer('eswh.input2', this.b);
            emitBuffer('eswh.output', readStdString(retval));
        }
    });
    Interceptor.attach(dswh, {
        onEnter: function (args) {
            this.a = readStdString(args[1]);
            this.b = readStdString(args[2]);
        },
        onLeave: function (retval) {
            emitBuffer('dswh.input', this.a);
            emitBuffer('dswh.input2', this.b);
            emitBuffer('dswh.output', readStdString(retval));
        }
    });
    Interceptor.attach(getAesWithHead, {
        onEnter: function (args) { this.input = readStdString(args[1]); },
        onLeave: function (retval) {
            if (this.input && this.input.byteLength > 6) emitBuffer('getAesWithHead.output', readStdString(retval));
        }
    });
    out('native_ready', { module: module.name, base: String(module.base) });
}

function hookIo(name, fdIndex, bufIndex, lenIndex, resultFromReturn) {
    var fn = Module.findGlobalExportByName(name);
    if (!fn) return;
    Interceptor.attach(fn, {
        onEnter: function (args) {
            this.fd = args[fdIndex].toInt32();
            this.buf = args[bufIndex];
            this.requested = args[lenIndex].toInt32();
        },
        onLeave: function (retval) {
            var n = resultFromReturn ? retval.toInt32() : this.requested;
            if (n <= 12 || n > MAX_DUMP) return;
            try {
                var data = this.buf.readByteArray(n);
                if (isFzjh03(data)) emitBuffer(name, data, { fd: this.fd, direction: name === 'recv' || name === 'read' ? 'in' : 'out' });
            } catch (e) {}
        }
    });
    out('io_ready', { name: name, address: String(fn) });
}

function install() {
    if (hooked) return;
    var module = moduleInfo();
    if (!module) return;
    hooked = true;
    hookNative(module);
    hookIo('send', 0, 1, 2, true);
    hookIo('recv', 0, 1, 2, true);
    hookIo('write', 0, 1, 2, true);
    hookIo('read', 0, 1, 2, true);
    out('started', { pid: Process.id, arch: Process.arch });
}

var timer = setInterval(function () {
    try { install(); } catch (e) { out('error', { message: String(e) }); }
}, 500);

setTimeout(function () { clearInterval(timer); if (!hooked) out('timeout', {}); }, 120000);
