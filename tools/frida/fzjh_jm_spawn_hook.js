// 放置江湖：JM::stringEncrypt Hook（供 spawn-gating 启动器加载）
// Houdini 环境下 libcocos2dlua.so 不会出现在 Frida 的模块列表，
// 因此通过内存映射定位 so 基址，再加已验证的符号虚拟偏移。
'use strict';

var SO_NAME = 'libcocos2dlua.so';
var STRING_ENCRYPT_OFFSET = 0x653f44; // _ZN2JM13stringEncryptESsSs
var hooked = false;
var callCount = 0;

// 默认仅记录调用元数据，避免把账号、密码、token 写入日志。
// 仅在已获授权的测试数据场景下，由启动器传入 capturePreview=true 开启预览。
var capturePreview = (typeof options !== 'undefined' && options.capturePreview === true);
var MAX_PREVIEW = 256;

function sendEvent(kind, details) {
    send({ kind: kind, details: details });
}

function findSoBase() {
    var ranges = Process.enumerateRanges('r--');
    for (var i = 0; i < ranges.length; i++) {
        var r = ranges[i];
        if (r.file !== null && r.file !== undefined && r.file.path.indexOf(SO_NAME) !== -1) {
            return r.base;
        }
    }
    return null;
}

function safePreview(value) {
    try {
        if (value === null || value === undefined) return null;
        var text = String(value);
        // 即使预览开启，也屏蔽常见凭据字段。
        text = text.replace(/("?(?:password|passwd|pwd|token|access_token|session|sid)"?\s*[:=]\s*["']?)([^,"'&\s}]+)/ig, '$1<redacted>');
        return text.length > MAX_PREVIEW ? text.substring(0, MAX_PREVIEW) + '…' : text;
    } catch (e) {
        return '<unreadable>';
    }
}

function installHook() {
    if (hooked) return true;

    var base = findSoBase();
    if (base === null) return false;

    var target = base.add(STRING_ENCRYPT_OFFSET);
    try {
        // 验证目标地址可读，避免在错误映射上插桩。
        target.readU32();
    } catch (e) {
        sendEvent('error', { stage: 'validate-target', error: String(e), address: String(target) });
        return false;
    }

    Interceptor.attach(target, {
        onEnter: function (args) {
            callCount++;
            var event = {
                count: callCount,
                threadId: Process.getCurrentThreadId(),
                address: String(target),
                dataPointer: String(args[1]),
                versionPointer: String(args[2]),
                backtrace: Thread.backtrace(this.context, Backtracer.ACCURATE)
                    .slice(0, 8)
                    .map(DebugSymbol.fromAddress)
                    .join('\n')
            };

            // 仅当显式开启且读取安全时提供预览。ARM64 std::string 的布局
            // 在 Houdini 下不保证适用于直接 CString 读取，因此读取失败会被忽略。
            if (capturePreview) {
                try { event.preview = safePreview(args[1].readUtf8String()); } catch (e) {}
            }
            sendEvent('jm-stringEncrypt', event);
        }
    });

    hooked = true;
    sendEvent('hooked', {
        processId: Process.id,
        architecture: Process.arch,
        soBase: String(base),
        offset: '0x' + STRING_ENCRYPT_OFFSET.toString(16),
        address: String(target),
        capturePreview: capturePreview
    });
    return true;
}

var attempts = 0;
var waitTimer = setInterval(function () {
    attempts++;
    try {
        if (installHook()) {
            clearInterval(waitTimer);
        }
    } catch (e) {
        sendEvent('error', { stage: 'install-hook', error: String(e) });
    }

    if (attempts >= 120) {
        clearInterval(waitTimer);
        sendEvent('timeout', { seconds: 120, module: SO_NAME });
    }
}, 1000);

sendEvent('injected', { processId: Process.id, waitingFor: SO_NAME });
