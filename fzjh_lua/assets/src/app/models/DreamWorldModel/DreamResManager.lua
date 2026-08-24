local DreamConst = require("app.models.DreamWorldModel.DreamConst")
--@desc 事件类型
local EVENT_TYPE = DreamConst.RoomEventType

local DreamResManager = {
    _drSpecialNpc = {},
    _drEvents = {},
    _event_list_by_type = {},
    _event_list_by_lv = {},
    _drwx = {},
    _wxGroup = {},
    _drdw = {},
    _drName = {},
    _drUnit = {},
    _tftexts = {},
    _drPj = {},
    _drFloorExp = {},
    _roleAttrTab = {},
    _roleSkillTab = {},
    _roleUnlockSkillTab = {},
    _roleNameTab = {},
    _roleSkillsTab = {},
    _roleSkillsZhao = {},
    _roleFaceImag = {},
    _drEquipment = {}
}

local function loadDrSpecialNpc()
    DreamResManager._drSpecialNpc = require("script.dreamworld.dreamspecialnpc")
end

local function loadDrEvents()
    local drEvents = require("script.dreamworld.dreamevent")
    DreamResManager._drEvents = drEvents

    local event_list_by_type = DreamResManager._event_list_by_type

    local event_list_by_lv = DreamResManager._event_list_by_lv
    
    local tbList = {
        ["boss类型"] = EVENT_TYPE.BOSS,
        ["商品类型"] = EVENT_TYPE.SHOP,
        ["初始类型"] = EVENT_TYPE.DEFAULT,
        ["隐藏类型"] = EVENT_TYPE.HIDE,
        ["秘宝类型"] = EVENT_TYPE.TREASURE,
        ["任务类型"] = EVENT_TYPE.TASKS,
        ["战斗类型"] = EVENT_TYPE.FIGHT,
        -- ["陷阱类型"] = EVENT_TYPE.TRAP,
        ["空房类型"] = EVENT_TYPE.EMPTY,
        ["前置类型"] = EVENT_TYPE.BOSSPRE,
        ["出口类型"] = EVENT_TYPE.EXIT
    }

    for tbName, eventType in pairs(tbList) do
        local events = drEvents[tbName]

        event_list_by_type[tostring(eventType)] = {}
        event_list_by_lv[tostring(eventType)] = {}

        for k, v in pairs(events) do
            table.insert(event_list_by_type[tostring(eventType)], v)

            if event_list_by_lv[tostring(eventType)][tostring(v.lv)] == nil then
                event_list_by_lv[tostring(eventType)][tostring(v.lv)] = {}
            end

            table.insert(event_list_by_lv[tostring(eventType)][tostring(v.lv)], v)
        end
    end
end

local function loadWxGroup()
    local drwx = require("script.dreamworld.drnpc.drwx")
    DreamResManager._drwx = drwx
    for k, v in pairs(drwx) do
        local groupId = v.groupId
        if DreamResManager._wxGroup[groupId] == nil then
            DreamResManager._wxGroup[groupId] = {}
        end

        table.insert(DreamResManager._wxGroup[groupId], v)
    end
end

local function loadDrdw()
    DreamResManager._drdw = require("script.dreamworld.drnpc.drdw")
end

local function loadDrName()
    DreamResManager._drName = require("script.dreamworld.drnpc.drname")
end

local function loadDrUnit()
    DreamResManager._drUnit = require("script.dreamworld.drnpc.drUnit")
end

local function loadDrTfNodeText()
    DreamResManager._tftexts = require("script.dreamworld.dreamtfnodetext")["tftexts"]
end

local function loadDrPj()
    DreamResManager._drPj = require("script.dreamworld.dreamsettlement")["pjqujian"]
end

local function loadDrFloorExp()
    DreamResManager._drFloorExp = require("script.dreamworld.dreamfloorexp")["Sheet1"]
end

local function loadDrRoleTab()
    local RoleSkillInfo = require("script.dreamworld.dreamskill")
    local dreamLeadrole = require("script.dreamworld.dreamLeadrole")
    local RoleAttrTab = dreamLeadrole["主角外部属性"]
    local RoleSkillTab = dreamLeadrole["主角门派"]
    local RoleUnlockSkillTab = dreamLeadrole["解锁主角门派"]
    local RoleFaceImag = dreamLeadrole["梦境样貌表"]
    local RoleNameTab = dreamLeadrole["主角姓名库"]

    local RoleSkillsTab = RoleSkillInfo["武学"]
    local RoleSkillsZhao = RoleSkillInfo["主动技能"]

    DreamResManager._roleAttrTab = RoleAttrTab
    DreamResManager._roleSkillTab = RoleSkillTab
    DreamResManager._roleUnlockSkillTab = RoleUnlockSkillTab
    DreamResManager._roleFaceImag = RoleFaceImag
    DreamResManager._roleNameTab = RoleNameTab

    DreamResManager._roleSkillsTab = RoleSkillsTab
    DreamResManager._roleSkillsZhao = RoleSkillsZhao
end

local function loadDrequipment()
    DreamResManager._drEquipment = require("script.map.mapItemAttr")["drequipment"]
end

loadDrSpecialNpc()
loadDrEvents()
loadWxGroup()
loadDrdw()
loadDrName()
loadDrUnit()
loadDrTfNodeText()
loadDrPj()
loadDrFloorExp()
loadDrRoleTab()
loadDrequipment()

function DreamResManager:getDrSpecialNpc()
    return self._drSpecialNpc
end

function DreamResManager:getDrEvents()
    return self._drEvents
end

function DreamResManager:getEventListByType()
    return self._event_list_by_type
end

function DreamResManager:getEventListByLv()
    return self._event_list_by_lv
end

function DreamResManager:getDrWx()
    return self._drwx
end

function DreamResManager:getWxGroup()
    return self._wxGroup
end

function DreamResManager:getDrdw()
    return self._drdw
end

function DreamResManager:getDrName()
    return self._drName
end

function DreamResManager:getDrUnit()
    return self._drUnit
end

function DreamResManager:getDrTftexts()
    return self._tftexts
end

function DreamResManager:getDrPj()
    return self._drPj
end

function DreamResManager:getDrFloorExp()
    return self._drFloorExp
end

function DreamResManager:getRoleAttrTab()
    return self._roleAttrTab
end

function DreamResManager:getRoleSkillTab()
    return self._roleSkillTab
end

function DreamResManager:getRoleUnlockSkillTab()
    return self._roleUnlockSkillTab
end

function DreamResManager:getRoleFaceImag()
    return self._roleFaceImag
end

function DreamResManager:getRoleNameTab()
    return self._roleNameTab
end

function DreamResManager:getRoleSkillsTab(skillId)
    return self._roleSkillsTab[tostring(skillId)]
end

function DreamResManager:getRoleSkillsZhao(zhaoId)
    return self._roleSkillsZhao[tostring(zhaoId)]
end

function DreamResManager:getDrEquipment()
    return self._drEquipment
end

return DreamResManager00