Java.perform(() => {
    console.log("\n====== 环境信息 ======");
    console.log(` 进程架构: ${Process.arch}`);
    console.log(` 当前线程ID: ${Process.getCurrentThreadId()}`);

    const Build = Java.use("android.os.Build");

    console.log("\n====== 模块信息 ======");
    const libhoudini = Module.findBaseAddress("libcocos2dlua_arm64.so");
    if (!libhoudini) {
        console.error("[!] libhoudini.so 未加载");
        return;
    }
    console.log(` libhoudini.so 基址: ${libhoudini}`);

    console.log("\n====== NativeBridgeItf 符号信息 ======");
    const NativeBridgeItf = Module.findExportByName("libhoudini.so", "NativeBridgeItf");
    if (!NativeBridgeItf) {
        console.error("[!] 找不到 NativeBridgeItf 符号");
        return;
    }
    console.log(` NativeBridgeItf 符号地址: ${NativeBridgeItf}`);
    console.log(` NativeBridgeItf 符号地址 偏移寻址 : ${libhoudini.add(0x0701D00)}`);

    console.log("\n====== 结构体指针信息 ======");
    const callbacks = NativeBridgeItf.readInt();
    console.log(` version: ${callbacks}`);

    const padding = NativeBridgeItf.add(0x4).readInt();
    console.log(` padding: ${padding}`);

    const initialize = NativeBridgeItf.add(0x8).readPointer();
    console.log(` initialize addr: ${initialize}`);

    const loadLibrary = NativeBridgeItf.add(0x10).readPointer();
    console.log(` loadLibrary addr: ${loadLibrary}`);

    const getTrampoline = NativeBridgeItf.add(0x18).readPointer();
    console.log(` getTrampoline addr: ${getTrampoline}`);

    const isSupported = NativeBridgeItf.add(0x20).readPointer();
    console.log(` isSupported addr: ${isSupported}`);

    const getAppEnv = NativeBridgeItf.add(0x28).readPointer();
    console.log(` getAppEnv addr: ${getAppEnv}`);

    const isCompatibleWith = NativeBridgeItf.add(0x30).readPointer();
    console.log(` isCompatibleWith addr: ${isCompatibleWith}`);

    const getSignalHandler = NativeBridgeItf.add(0x38).readPointer();
    console.log(` getSignalHandler addr: ${getSignalHandler}`);

    const unloadLibrary = NativeBridgeItf.add(0x40).readPointer();
    console.log(` unloadLibrary addr: ${unloadLibrary}`);

    const getError = NativeBridgeItf.add(0x48).readPointer();
    console.log(` getError addr: ${getError}`);

    const isPathSupported = NativeBridgeItf.add(0x50).readPointer();
    console.log(` isPathSupported addr: ${isPathSupported}`);

    const unused_initAnonymousNamespace = NativeBridgeItf.add(0x58).readPointer();
    console.log(` unused_initAnonymousNamespace addr: ${unused_initAnonymousNamespace}`);

    const createNamespace = NativeBridgeItf.add(0x60).readPointer();
    console.log(` createNamespace addr: ${createNamespace}`);

    const linkNamespaces = NativeBridgeItf.add(0x68).readPointer();
    console.log(` linkNamespaces addr: ${linkNamespaces}`);

    const loadLibraryExt = NativeBridgeItf.add(0x70).readPointer();
    console.log(` loadLibraryExt addr: ${loadLibraryExt}`);

    const getVendorNamespace = NativeBridgeItf.add(0x78).readPointer();
    console.log(` getVendorNamespace addr: ${getVendorNamespace}`);

    const getExportedNamespace = NativeBridgeItf.add(0x80).readPointer();
    console.log(` getExportedNamespace addr: ${getExportedNamespace}`);

    const preZygoteFork = NativeBridgeItf.add(0x88).readPointer();
    console.log(` preZygoteFork addr: ${preZygoteFork}`);

    Interceptor.attach(loadLibraryExt, {
        onEnter: function(args) {
            // 根据实际函数原型判断参数，这里假设第一个参数为要加载的库路径
            var libName = Memory.readCString(args[0]);
            console.log(" loadLibraryExt called with library name: " + libName);
        },
        onLeave: function(retval) {
            console.log(" loadLibraryExt returned: " + retval);
        }
    });

});