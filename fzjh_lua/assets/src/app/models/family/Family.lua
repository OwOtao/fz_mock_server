local familyMap = {}
local function initFamilyMap()
    local dataList = require("script.family.family")
    if not dataList.familys then
        if PRINT_MODE == 1 then
            print("门派初始化失败")
        end
        return
    end

    local aliasList = {}
    for k, v in pairs(dataList.familys) do
        local index = 1
        local npcList = {}
        while v["npc" .. index] ~= nil and string.len(tostring(v["npc" .. index])) >= 1 do
            table.insert(npcList, v["npc" .. index])
            index = index + 1
        end
        v.npcList = npcList

        familyMap[k] = Helper:tableCover(clone(require("app.models.family.BaseFamily")), v)
        familyMap[k].id = k

        table.insert(aliasList, {key = familyMap[k].name, value = familyMap[k]})
    end

    for k, v in pairs(aliasList) do
        familyMap[v.key] = v.value
    end
end
initFamilyMap() -- 初始化门派列表

local Family = {}

--@desc 服务器老存档存在旧门派id，需要做一个映射(PS.特别是论剑)
local changeFamilyNameMap = {
    ["xiaoyao"] = "tianshan",
    ["lingjiugong"] = "tianshan",
}

function Family:getFamily(id)
    local newid = changeFamilyNameMap[tostring(id)]

    if newid then
        id = newid
    end

    if familyMap[id] == nil then
        return nil
    end
    return assert(familyMap[id])
end

function Family:getFamilys()
    return familyMap
end

function Family:getFamilyMapIdAndRoomId()
    local role = User:getRole()

    local teacherId = User:getRoleAttr("teacherId")

    if teacherId == nil then
        return
    end

    local npc = Npc:getNpc(teacherId)

    local mapRoomTb = string.split(npc.mapRoom, ";")

    if MapIsEmpty(mapRoomTb) == nil then
        return
    end

    return mapRoomTb[1], mapRoomTb[2]
end

function Family:getFamilyMap()
    local role = User:getRole()

    local fbId, roomId = self:getFamilyMapIdAndRoomId()

    if fbId == nil or roomId == nil then
        print("副本ID 或 房间ID 为空")
        return
    end

    local map = role:getMapById(fbId)

    if MapIsEmpty(map) then
        print("没有找到该副本(" .. fbId .. ")")
        return
    end

    return map
end

function Family:getLowLevelShowNpcList()
    local LevelTeacherLayerInfo = require("script.others.masterShow")

    local npcList
    local levelFamilyShowInfo = LevelTeacherLayerInfo["Sheet1"]
    for k, v in pairs(levelFamilyShowInfo) do
        if v.family == User:getRole():getFamilyId() then
            npcList = v.showNpc
            break
        end
    end
    npcList = string.split(npcList, ";")
    if #npcList < 1 or npcList[1] == "" then
        print("策划资源中 未找到对应门派")
    end
    return npcList
end

function Family:getLowLevelShowTitleInfo()
    local LevelTeacherLayerInfo = require("script.others.masterShow")

    local iamgeInfo, textInfo, dscInfo
    local levelFamilyShowInfo = LevelTeacherLayerInfo["Sheet1"]
    for k, v in pairs(levelFamilyShowInfo) do
        if v.family == User:getRole():getFamilyId() then
            iamgeInfo = v.titleImg
            textInfo = v.text
            dscInfo = v.descri
            break
        end
    end
    if textInfo == nil or iamgeInfo == nil or dscInfo == nil then
        print("策划资源中 未找到对应门派相关资源")
    end
    return textInfo, iamgeInfo, dscInfo
end

return Family
000000