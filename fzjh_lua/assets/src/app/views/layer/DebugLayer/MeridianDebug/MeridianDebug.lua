local MeridianDebug = {}

local jsonString = cc.FileUtils:getInstance():getStringFromFile("src/app/views/layer/DebugLayer/MeridianDebug/MeridianDebugConfig.json")

local config = json.decode(jsonString)

function MeridianDebug:getConfigAttr(name)
    return config[name]
end

function MeridianDebug:getOldMeridianImpritingDataBefor20250121FromConfig()
    local list = config["befor20250121MeridianImpritinsData"]

    local data = {}

    for i, v in ipairs(list) do
        table.insert(data, {imprintingId = v})
    end

    return data
end

function MeridianDebug:resetMerianImprintingsBefore20250121(role)
    local data = self:getOldMeridianImpritingDataBefor20250121FromConfig()

    role.meridianImprinting = data

    role.m_meridianImprintings = Role.m_meridianImprintings

    role:reInitMeridianSystem()
end

return MeridianDebug
00000