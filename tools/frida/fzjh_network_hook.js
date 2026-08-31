// 放置江湖纯 Frida 网络 Hook
// 不依赖 Lua、Cocos 或 JM 符号；只挂钩 libc 网络函数。
'use strict';

var MAX_BYTES = 1024;
var sockets = {};

function emit(tag, text) {
    send('[' + tag + '] ' + text);
}

function ntohs(v) {
    return ((v & 0xff) << 8) | ((v >> 8) & 0xff);
}

function endpoint(addr) {
    try {
        var family = addr.readU16();
        if (family === 2) { // AF_INET
            var port = ntohs(addr.add(2).readU16());
            var b = addr.add(4).readByteArray(4);
            var a = new Uint8Array(b);
            return a[0] + '.' + a[1] + '.' + a[2] + '.' + a[3] + ':' + port;
        }
        return 'family=' + family;
    } catch (e) {
        return 'unreadable sockaddr';
    }
}

function redact(text) {
    // 避免在控制台落盘输出密码、token、session 等敏感值。
    return text
        .replace(/("?(?:password|passwd|pwd|token|access_token|session|sid)"?\s*[:=]\s*["']?)([^,"'&\s}]+)/ig, '$1<redacted>')
        .replace(/(password|passwd|pwd|token|access_token|session|sid)=([^&\s]+)/ig, '$1=<redacted>');
}

function preview(buf, length) {
    try {
        var n = Math.min(length, MAX_BYTES);
        var raw = buf.readByteArray(n);
        var bytes = new Uint8Array(raw);
        var printable = true;
        for (var i = 0; i < bytes.length; i++) {
            var c = bytes[i];
            if ((c < 0x09 || (c > 0x0d && c < 0x20)) || c === 0x7f) {
                printable = false;
                break;
            }
        }
        if (printable) {
            return 'text=' + redact(buf.readUtf8String(n));
        }
        var hex = [];
        for (var j = 0; j < Math.min(bytes.length, 128); j++) {
            hex.push(('0' + bytes[j].toString(16)).slice(-2));
        }
        return 'hex=' + hex.join(' ') + (length > 128 ? ' ...' : '');
    } catch (e) {
        return 'unreadable buffer: ' + e;
    }
}

function hook(name, callbacks) {
    var address = Module.findGlobalExportByName(name);
    if (address === null) {
        emit('WARN', name + ' not found');
        return;
    }
    Interceptor.attach(address, callbacks);
    emit('HOOK', name + ' @ ' + address);
}

hook('connect', {
    onEnter: function (args) {
        this.fd = args[0].toInt32();
        this.remote = endpoint(args[1]);
    },
    onLeave: function (retval) {
        if (retval.toInt32() === 0 || retval.toInt32() === -1) {
            sockets[this.fd] = this.remote;
            emit('CONNECT', 'fd=' + this.fd + ' target=' + this.remote + ' result=' + retval.toInt32());
        }
    }
});

function hookIO(name, tag) {
    hook(name, {
        onEnter: function (args) {
            this.fd = args[0].toInt32();
            this.buf = args[1];
            this.requested = args[2].toInt32();
        },
        onLeave: function (retval) {
            var n = retval.toInt32();
            if (n > 0) {
                var target = sockets[this.fd] || 'unknown';
                emit(tag, 'fd=' + this.fd + ' target=' + target + ' bytes=' + n + ' ' + preview(this.buf, n));
            }
        }
    });
}

hookIO('send', 'SEND');
hookIO('recv', 'RECV');
hookIO('write', 'WRITE');
hookIO('read', 'READ');

emit('START', '纯 Frida 网络 Hook 已加载，敏感凭据将自动脱敏。');
