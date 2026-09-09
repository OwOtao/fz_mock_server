local DebugHelper = {}

local DebugEvent = {
    LUN_JIAN_JIN_NANG_ID = "论剑指定锦囊",
    SHEN_SHU_VERSION = "神书版本",
    DOMAIN_PORT = "测试端口"
}

function DebugHelper:setLunJianJinNangId(id)
    self[DebugEvent.LUN_JIAN_JIN_NANG_ID] = id
end

function DebugHelper:getLunJianJinNangId()
    return self[DebugEvent.LUN_JIAN_JIN_NANG_ID]
end

function DebugHelper:setShenShuVersion(version)
    self[DebugEvent.SHEN_SHU_VERSION] = version
end

function DebugHelper:getShenShuVersion()
    return self[DebugEvent.SHEN_SHU_VERSION]
end

function DebugHelper:setTestPort(port)
    self[DebugEvent.DOMAIN_PORT] = port
end

function DebugHelper:getTestPort()
    return self[DebugEvent.DOMAIN_PORT]
end

return DebugHelper