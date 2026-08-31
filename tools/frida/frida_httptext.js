// ============================================================
// 放置江湖 HTTP 密文抓取 (libc 层, 兼容 x86_64 转译环境)
// ============================================================
// 只 hook libc 的 send/write, 过滤 JM 加密的 HTTP body。
// JM 密文特征: 纯 hex 文本, 以 "4a4848553032" (JHHU02 的 hex) 开头。
// 输出: 完整密文文本, 供本地 verify_key.py 用候选密钥解密验证。
'use strict';

var MAX_PRINT = 8192;   // 密文最长打印长度

function emit(tag, text) {
    send('[' + tag + '] ' + text);
}

function isJMHex(buf, n) {
    // 检查前 6 字节是否为 hex('JHHU02') = 4a4848553032
    try {
        var head = buf.readByteArray(Math.min(12, n));
        var u8 = new Uint8Array(head);
        var hex = '4a4848553032';
        if (u8.length < 12) return false;
        for (var i = 0; i < 12; i++) {
            var c = ('0' + u8[i].toString(16)).slice(-2);
            if (c !== hex[i]) return false;
        }
        return true;
    } catch (e) { return false; }
}

function dumpBody(buf, n) {
    var m = Math.min(n, MAX_PRINT);
    try {
        var txt = buf.readUtf8String(m);
        // 打印密文(纯 hex 文本)
        emit('BODY', txt);
        if (n > MAX_PRINT) emit('BODY_TRUNCATED', 'total=' + n);
    } catch (e) {
        emit('BODY_UNREADABLE', 'len=' + n + ' err=' + e);
    }
}

function hookIO(name, tag) {
    var address = Module.findGlobalExportByName(name);
    if (address === null) { emit('WARN', name + ' not found'); return; }
    Interceptor.attach(address, {
        onEnter: function (args) {
            this.fd = args[0].toInt32();
            this.buf = args[1];
            this.len = args[2].toInt32();
        },
        onLeave: function (retval) {
            var n = retval.toInt32();
            if (n > 12 && n < 100000 && isJMHex(this.buf, n)) {
                emit('HIT', name + ' fd=' + this.fd + ' bytes=' + n);
                dumpBody(this.buf, n);
            }
        }
    });
    emit('HOOK', name + ' @ ' + address);
}

hookIO('send', 'SEND');
hookIO('write', 'WRITE');
emit('START', 'HTTP 密文抓取已加载, 请操作游戏触发请求');
