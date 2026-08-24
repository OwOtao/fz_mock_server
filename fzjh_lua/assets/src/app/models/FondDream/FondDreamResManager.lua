local DreamConst = require("app.models.DreamWorldModel.DreamConst")
--@desc 事件类型
local EVENT_TYPE = DreamConst.RoomEventType

local FondDreamResManager = {
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
    _drEquipment = {},
    _chessRes = {},
    _chessEventRes = {},
    _chessList = {},
    _drOpenBoxEvent = {},
    _drOpenBoxText = {},
    _drOpenBoxRewardEvent = {}
}

local function loadDrEvents()
    local drEvents = require("script.nanke.dreamworld.dreamevent")
    FondDreamResManager._drEvents = drEvents

    local event_list_by_type = FondDreamResManager._event_list_by_type

    local event_list_by_lv = FondDreamResManager._event_list_by_lv
    
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
    FondDreamResManager._drwx = drwx
    for k, v in pairs(drwx) do
        local groupId = v.groupId
        if FondDreamResManager._wxGroup[groupId] == nil then
            FondDreamResManager._wxGroup[groupId] = {}
        end

        table.insert(FondDreamResManager._wxGroup[groupId], v)
    end
end

local function loadDrdw()
    FondDreamResManager._drdw = require("script.dreamworld.drnpc.drdw")
end

local function loadDrName()
    FondDreamResManager._drName = require("script.dreamworld.drnpc.drname")
end

local function loadDrUnit()
    FondDreamResManager._drUnit = require("script.dreamworld.drnpc.drUnit")
end

local function loadDrTfNodeText()
    FondDreamResManager._tftexts = require("script.dreamworld.dreamtfnodetext")["tftexts"]
end

local function loadDrPj()
    FondDreamResManager._drPj = require("script.dreamworld.dreamsettlement")["pjqujian"]
end

local function loadDrFloorExp()
    FondDreamResManager._drFloorExp = require("script.nanke.dreamworld.dreamfloorexp")["Sheet1"]
end

local function loadDrRoleTab()
    local RoleSkillInfo = require("script.nanke.dreamworld.dreamskill")
    local dreamLeadrole = require("script.nanke.dreamworld.dreamLeadrole")
    local RoleAttrTab = dreamLeadrole["主角外部属性"]
    local RoleSkillTab = dreamLeadrole["主角门派"]
    local RoleUnlockSkillTab = dreamLeadrole["解锁主角门派"]
    local RoleFaceImag = dreamLeadrole["梦境样貌表"]
    local RoleNameTab = dreamLeadrole["主角姓名库"]

    local RoleSkillsTab = RoleSkillInfo["武学"]
    local RoleSkillsZhao = RoleSkillInfo["主动技能"]

    FondDreamResManager._roleAttrTab = RoleAttrTab
    FondDreamResManager._roleSkillTab = RoleSkillTab
    FondDreamResManager._roleUnlockSkillTab = RoleUnlockSkillTab
    FondDreamResManager._roleFaceImag = RoleFaceImag
    FondDreamResManager._roleNameTab = RoleNameTab

    FondDreamResManager._roleSkillsTab = RoleSkillsTab
    FondDreamResManager._roleSkillsZhao = RoleSkillsZhao
end

local function loadDrequipment()
    FondDreamResManager._drEquipment = require("script.map.mapItemAttr")["fondDrequipment"]
end

local function loadChessBoardRes()
    local chess = require("script.nanke.dreamworld.qipanbiao")
    local chessRes = chess["棋盘属性"]
    local chessEventRes = chess["副本模板"]
    FondDreamResManager._chessRes = chessRes
    FondDreamResManager._chessEventRes = chessEventRes
    for k,v in pairs(chessRes) do
        table.insert(FondDreamResManager._chessList,v)
    end
end

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
loadChessBoardRes()

function FondDreamResManager:getDrEvents()
    return self._drEvents
end

function FondDreamResManager:getEventListByType()
    return self._event_list_by_type
end

function FondDreamResManager:getEventListByLv()
    return self._event_list_by_lv
end

function FondDreamResManager:getDrWx()
    return self._drwx
end

function FondDreamResManager:getWxGroup()
    return self._wxGroup
end

function FondDreamResManager:getDrdw()
    return self._drdw
end

function FondDreamResManager:getDrName()
    return self._drName
end

function FondDreamResManager:getDrUnit()
    return self._drUnit
end

function FondDreamResManager:getDrTftexts()
    return self._tftexts
end

function FondDreamResManager:getDrPj()
    return self._drPj
end

function FondDreamResManager:getDrFloorExp()
    return self._drFloorExp
end

function FondDreamResManager:getRoleAttrTab()
    return self._roleAttrTab
end

function FondDreamResManager:getRoleSkillTab()
    return self._roleSkillTab
end

function FondDreamResManager:getRoleUnlockSkillTab()
    return self._roleUnlockSkillTab
end

function FondDreamResManager:getRoleFaceImag()
    return self._roleFaceImag
end

function FondDreamResManager:getRoleNameTab()
    return self._roleNameTab
end

function FondDreamResManager:getRoleSkillsTab(skillId)
    return self._roleSkillsTab[tostring(skillId)]
end

function FondDreamResManager:getRoleSkillsZhao(zhaoId)
    return self._roleSkillsZhao[tostring(zhaoId)]
end

function FondDreamResManager:getDrEquipment()
    return self._drEquipment
end

function FondDreamResManager:getChessInfo(chessId)
    return assert(self._chessRes[tostring(chessId)],"没有棋局属性信息 chessId = "..chessId)
end

function FondDreamResManager:getChessEventInfo(chessEventId)
   return assert(self._chessEventRes[tostring(chessEventId)],"没有棋局事件信息 chessEventId = "..chessEventId) 
end

function FondDreamResManager:getChessList()
    return self._chessList
end

return FondDreamResManager000000000