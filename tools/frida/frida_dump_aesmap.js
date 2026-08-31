'use strict';

var SO_NAME = 'libcocos2dlua.so';
var AES_MAP_SYMBOL = '_ZN3cpp3aes6aesMapE';
var CREATE_AES_SYMBOL = '_ZN3cpp3aes9createAesESsSsSsc';
var MAX_NODES = 128;
var MAX_STRING = 1024;
var dumped = false;
var hooked = false;

function findModule() {
    try {
        return Process.findModuleByName(SO_NAME);
    } catch (e) {
        send({ type: 'moduleError', error: String(e) });
        return null;
    }
}

function findExport(module, name) {
    try {
        if (module && module.findExportByName) {
            var direct = module.findExportByName(name);
            if (direct) return direct;
        }
    } catch (e) {}
    try {
        var address = Module.findExportByName(SO_NAME, name);
        if (address) return address;
    } catch (e2) {}
    try {
        if (module) {
            var symbols = module.enumerateSymbols();
            for (var i = 0; i < symbols.length; i++) {
                if (symbols[i].name === name) return symbols[i].address;
            }
        }
    } catch (e3) {}
    return null;
}

function readMemory(address, size) {
    try { return address.readByteArray(size); } catch (e) { return null; }
}

function hex(data, limit) {
    if (!data) return '';
    var a = new Uint8Array(data);
    var n = Math.min(a.length, limit || a.length);
    var s = '';
    for (var i = 0; i < n; i++) s += ('0' + a[i].toString(16)).slice(-2);
    return s;
}

function readStdString(obj) {
    try {
        if (obj.isNull()) return null;
        var p = obj.readPointer();
        var len = obj.add(8).readU64().toNumber();
        if (len < 0 || len > MAX_STRING) return null;
        if (len === 0) return '';
        var local = obj.add(16);
        var localEnd = obj.add(48);
        var data = p.compare(local) >= 0 && p.compare(localEnd) < 0 ? local.readByteArray(len) : p.readByteArray(len);
        if (!data) return null;
        var bytes = new Uint8Array(data);
        var text = '';
        for (var i = 0; i < bytes.length; i++) {
            if (bytes[i] === 0) break;
            text += String.fromCharCode(bytes[i]);
        }
        return text;
    } catch (e) { return null; }
}

function isReadableString(s) {
    if (s === null || s.length === 0 || s.length > MAX_STRING) return false;
    var printable = 0;
    for (var i = 0; i < s.length; i++) {
        var c = s.charCodeAt(i);
        if (c >= 0x20 && c <= 0x7e) printable++;
    }
    return printable >= Math.max(4, s.length * 0.8);
}

function readAesObject(address) {
    var result = { address: String(address), memory: hex(readMemory(address, 128), 128), strings: [] };
    for (var off = 0; off <= 64; off += 8) {
        var s = readStdString(address.add(off));
        if (isReadableString(s)) result.strings.push({ offset: off, value: s });
    }
    return result;
}

function nodeValueOffset() {
    return 0x20;
}

function dumpMap(map, reason, module) {
    var mapAddress = map;
    var base = module ? module.base : ptr('0');
    var header = map;
    var root = header.add(8).readPointer();
    var left = header.add(16).readPointer();
    var right = header.add(24).readPointer();
    var count = header.add(32).readU64().toNumber();
    var result = {
        type: 'aesMap',
        reason: reason,
        base: String(base),
        map: String(map),
        header: String(header),
        root: String(root),
        left: String(left),
        right: String(right),
        count: count,
        nodes: []
    };
    if (count > MAX_NODES) count = MAX_NODES;
    var seen = {};
    var stack = [];
    if (!root.isNull()) stack.push(root);
    while (stack.length && result.nodes.length < count) {
        var node = stack.pop();
        var id = String(node);
        if (seen[id]) continue;
        seen[id] = true;
        try {
            var parent = node.add(8).readPointer();
            var nodeLeft = node.add(16).readPointer();
            var nodeRight = node.add(24).readPointer();
            if (!nodeLeft.isNull()) stack.push(nodeLeft);
            if (!nodeRight.isNull()) stack.push(nodeRight);
            var value = node.add(nodeValueOffset());
            var key = readStdString(value);
            var aes = value.add(32).readPointer();
            result.nodes.push({
                node: id,
                parent: String(parent),
                key: key,
                aes: readAesObject(aes),
                raw: hex(readMemory(value, 96), 96)
            });
        } catch (e) {
            result.nodes.push({ node: id, error: String(e) });
        }
    }
    send(result);
    dumped = true;
}

function installCreateHook(module, mapAddress) {
    if (hooked) return;
    var address = findExport(module, CREATE_AES_SYMBOL);
    if (!address) {
        send({ type: 'missingExport', symbol: CREATE_AES_SYMBOL });
        return;
    }
    send({ type: 'export', symbol: CREATE_AES_SYMBOL, address: String(address) });
    Interceptor.attach(address, {
        onLeave: function (retval) {
            send({ type: 'createAes', object: String(retval) });
            setTimeout(function () {
                try { dumpMap(mapAddress, 'createAes', module); } catch (e) { send({ type: 'error', error: String(e) }); }
            }, 50);
        }
    });
    hooked = true;
}

function install() {
    var module = findModule();
    if (!module) return false;
    var mapAddress = findExport(module, AES_MAP_SYMBOL);
    var createAddress = findExport(module, CREATE_AES_SYMBOL);
    send({
        type: 'module',
        name: module.name,
        base: String(module.base),
        size: module.size,
        arch: Process.arch,
        aesMap: mapAddress ? String(mapAddress) : null,
        createAes: createAddress ? String(createAddress) : null
    });
    if (!mapAddress) return false;
    installCreateHook(module, mapAddress);
    if (!dumped) dumpMap(mapAddress, 'initial', module);
    return true;
}

var attempts = 0;
var timer = setInterval(function () {
    attempts++;
    try {
        if (install()) clearInterval(timer);
    } catch (e) {
        send({ type: 'error', error: String(e) });
    }
    if (attempts >= 120) {
        clearInterval(timer);
        send({ type: 'timeout', seconds: 120 });
    }
}, 500);

send({ type: 'injected', pid: Process.id, arch: Process.arch, mapSymbol: AES_MAP_SYMBOL });
