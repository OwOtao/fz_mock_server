cc.FileUtils:getInstance():setPopupNotify(false)
cc.FileUtils:getInstance():addSearchPath("src/")
cc.FileUtils:getInstance():addSearchPath("res/")

-- local breakSocketHandle,debugXpCall = require("LuaDebugjit")("localhost",7003)
-- cc.Director:getInstance():getScheduler():scheduleScriptFunc(function()
--     breakSocketHandle();
--  end,0.5,false)

require "config"
require "cocos.init"

if jit and jit.status() then
    print("close jit")
    jit.off()
end

-- 只在windows上开启debug.hook
if device.platform ~= "windows" then
    debug.sethook = nil
end

-- 重写error和assert，以支持协程中的报错
local oldError = error
function error(errmsg)
    if errmsg then
        print("error:" .. errmsg)
    end
    oldError(errmsg)
end

function assert(v, msg)
    if not v then
        error(msg)
    end
    return v
end

function __G__TRACKBACK__(errorMessage)
    print("----------------------------------------")
    print("LUA ERROR: " .. tostring(errorMessage) .. "\n")
    print(debug.traceback("", 2))
    print("----------------------------------------")
    -- debugXpCall();
end

local function main()
    require("app.MyApp"):create():run()
end

local status, msg = xpcall(main, __G__TRACKBACK__)
if not status then
    print(msg)
    print(debug.traceback())
end
00000000000000