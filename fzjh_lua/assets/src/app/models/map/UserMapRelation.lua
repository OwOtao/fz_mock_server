local UserMapRelation = {}

--@desc 城市和城市郊外的映射
local cityFbIdRelation = {
    [1] = "fb10",
    [2] = "fb10",
    [3] = "fb10",
    [4] = "fb10",
    [5] = "fb15",
    [6] = "fb15",
    [7] = "fb15",
    [8] = "fb15",
    [9] = "fb20",
    [10] = "fb20",
    [11] = "fb20",
    [12] = "fb20",
    [13] = "fb25",
    [14] = "fb25",
    [15] = "fb25",
    [16] = "fb25"
}

local cityAreaRelation = {
    [1] = "扬州城外",
    [2] = "扬州郊外",
    [3] = "扬州外城",
    [4] = "扬州城郊",
    [5] = "苏州城外",
    [6] = "苏州郊外",
    [7] = "苏州外城",
    [8] = "苏州城郊",
    [9] = "襄阳城外",
    [10] = "襄阳郊外",
    [11] = "襄阳外城",
    [12] = "襄阳城郊",
    [13] = "长安城外",
    [14] = "长安郊外",
    [15] = "长安外城",
    [16] = "长安城郊"
}

local cityDirRelation = {
    [1] = "东郊",
    [2] = "西郊",
    [3] = "南郊",
    [4] = "北郊",
    [5] = "东面",
    [6] = "西面",
    [7] = "南面",
    [8] = "北面",
    [9] = "东南",
    [10] = "东北",
    [11] = "西南",
    [12] = "西北",
    [13] = "东部",
    [14] = "西部",
    [15] = "南部",
    [16] = "北部",
    [17] = "东南郊",
    [18] = "东北郊",
    [19] = "西南郊",
    [20] = "西北郊"
}

local villageRelation = {
    [1] = "白头村",
    [2] = "莲花村",
    [3] = "日暮村",
    [4] = "金刀村",
    [5] = "飞来村",
    [6] = "三水村",
    [7] = "海棠村",
    [8] = "石湖村",
    [9] = "白云村",
    [10] = "芦苇村",
    [11] = "东林村",
    [12] = "泗水村",
    [13] = "清水村",
    [14] = "渔歌村",
    [15] = "大兴村",
    [16] = "青山村",
    [17] = "十里村",
    [18] = "瑶歌村",
    [19] = "玉带村",
    [20] = "杏花村",
    [21] = "云梦村",
    [22] = "云来村",
    [23] = "长乐村",
    [24] = "丰乐村",
    [25] = "龙泉村",
    [26] = "莫愁村"
}

local villageAreaRelation = {
    [1] = "村头",
    [2] = "村尾",
    [3] = "东村头",
    [4] = "西村头",
    [5] = "南村头",
    [6] = "北村头",
    [7] = "东村尾",
    [8] = "西村尾",
    [9] = "南村尾",
    [10] = "北村尾",
    [11] = "东村",
    [12] = "西村",
    [13] = "南村",
    [14] = "北村",
    [15] = "东村口",
    [16] = "西村口",
    [17] = "南村口",
    [18] = "北村口",
    [19] = "东南村口",
    [20] = "东北村口"
}


local villageMapId = {
    [1] = "fb206",
    [5] = "fb206",
    [9] = "fb206",
    [13] = "fb206",
    [17] = "fb206",
    [22] = "fb206",
    [25] = "fb206",
    [2] = "fb207",
    [6] = "fb207",
    [10] = "fb207",
    [14] = "fb207",
    [18] = "fb207",
    [21] = "fb207",
    [26] = "fb207",
    [3] = "fb208",
    [7] = "fb208",
    [11] = "fb208",
    [15] = "fb208",
    [19] = "fb208",
    [23] = "fb208",
    [4] = "fb209",
    [8] = "fb209",
    [12] = "fb209",
    [16] = "fb209",
    [20] = "fb209",
    [24] = "fb209"
}


--@desc 创建地址层级联系，顺序数组
local relationList = {}
local function initRelationMap()
    table.insert(relationList, cityAreaRelation)
    table.insert(relationList, cityDirRelation)
    table.insert(relationList, villageRelation)
    table.insert(relationList, villageAreaRelation)
end

initRelationMap()

function UserMapRelation:getLocationRelationMap()
    return relationList
end

--@desc: 根据村庄的索引获得副本模板ID 
--@author:Liang SongQiang
--@time:2018-07-02 21:19:25
--@index:索引值
function UserMapRelation:getVillageFbId( index )
    local fbId = villageMapId[index]

    if fbId == nil then
        assert(false,"索引值出错，UserMapRelation:getVillageFbId ："..index)
    end

    return fbId
end


--@desc: 根据地址的索引方向获取对应副本的ID
--@author:Liang SongQiang
--@time:2018-06-30 19:47:01
function UserMapRelation:getFbIdByCityDir(index)
    local fbId = cityFbIdRelation[index]

    if fbId == nil then
        assert(false, "getFbIdByCityDir index：" .. index)
    end
    return fbId
end

--@desc: 根据地址的索引
--@author:Liang SongQiang
--@time:2018-06-30 19:48:12
function UserMapRelation:getCityAreaName(index)
    local areaName = cityAreaRelation[index]

    if areaName == nil then
        assert(false, "getCityAreaName index：" .. index)
    end

    return areaName
end

--@desc 获取城市区域对应的方向
function UserMapRelation:getCityDirName(index)
    local dirName = cityDirRelation[index]

    if dirName == nil then
        assert(false, "getCityDirName index：" .. index)
    end

    return dirName
end

--@desc 获取村庄名
function UserMapRelation:getVillageName(index)
    local villageName = villageRelation[index]

    if villageName == nil then
        assert(false, "getVillageName index：" .. index)
    end

    return villageName
end

--@desc 获取村庄内区域的名称
function UserMapRelation:getVillageAreaName(index)
    local villageAreaName = villageAreaRelation[index]

    if villageAreaName == nil then
        assert(false, "getVillageAreaName index：" .. index)
    end

    return villageAreaName
end

--@desc:获取city的范围
--@author:Liang SongQiang
--@time:2018-07-02 14:42:30
--@startIndex:开始索引
--@endIndex: 结束索引
function UserMapRelation:getCityArea(startIndex, endIndex)
    local list = {}

    for i=startIndex,endIndex do
        table.insert( list,cityAreaRelation[i])
    end

    if MapIsEmpty(list) then
        assert(false,"检查传值："..startIndex.."，"..endIndex)
    end

    return list
end


return UserMapRelation
0000000