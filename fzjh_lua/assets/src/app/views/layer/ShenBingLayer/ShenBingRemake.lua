--
-- Author: Your Name
-- Date: 2018-09-03 16:31:23
--
local ShenBingDuanZao = require("app.models.ShenBing.DuanZao.ShenBingDuanZao")
local ForgeSkill = require("app.models.ShenBing.ForgeSkill.ForgeSkill")
local shenBingweaponChangeList = require("script.others.godweaponChange")
local godweapon = require("script.others.godweapon")
local ShenBingRemakeLayer = class("ShenBingRemakeLayer", cc.Layer)
-- 所有材料
local ShenBingMaterialList = {"镔铁", "精铜", "青金", "云钢", "铁精", "铜精", "百炼寒铁", "磁母",
                              "青云金铁", "赤日铁", "墨金", "寒铜金精"}
-- local ShenBingMaterialList={}

local npcText = {
    [1] = "干将：锻造之道，只在直中取，莫向曲中求。我可以将你手中的神兵重铸，敢问你打算重铸为哪一种神兵？",
    [2] = "莫邪：何意百炼刚，化为绕指柔。我可以将你手中的神兵重铸，敢问你打算重铸为哪一种神兵？"
}
local npcOutText = {
    [1] = {"YEL干将用手摩挲着手上的神兵，眼中满是欢喜和兴奋，他扭过头去对边上的莫邪叫了句：老婆子，来活了，帮我掠阵！",
           "YEL莫邪头也不抬，淡淡地回了一句：知道了。",
           "YEL很快，炉火就熊熊燃烧起来。随之而来的是一阵叮叮当当的敲打声，还夹杂着几声干将的大呼小叫。",
           "YEL也不知道过了多久，你只记得炉子燃了熄，熄了又燃，来回重复了好几次……",
           "YEL干将的脸色也是一会青，一会煞白，一会涨红，就像开了染色铺似的……",
           "YEL当你正暗暗担心起来时，四周突然安静下来。",
           "YEL干将把神兵塞到你手里，神兵似乎还冒着热气。",
           "YEL干将志得意满：“幸不辱命。”"},
    [2] = {"YEL莫邪打量着手上的神兵，眼中若有所思，她头也不抬对边上的干将说了句：来活了。语气不冷不热。",
           "YEL干将听了，敛容郑重说到：“放心吧，我帮你盯着，出不了事。”",
           "YEL莫邪手脚麻利地开始生起炉火。",
           "YEL很快，炉火就熊熊燃烧起来。随之而来的是一阵叮叮当当的敲打声。",
           "YEL也不知道过了多久，你只记得炉子燃了熄，熄了又燃，来回重复了好几次……",
           "YEL莫邪的脸色一直很平静，很难从她脸上看到一丝波动，也不知进展如何，是好是坏……",
           "YEL当你正暗暗担心起来时，四周突然安静下来。",
           "YEL“成了。”莫邪的声音还是那样不冷不热，但此时听来宛如天籁。"}
}

function ShenBingRemakeLayer:create()
    local layer = ShenBingRemakeLayer:new()
    layer:init()
    return layer
end

function ShenBingRemakeLayer:init()
    local UI = require("Layer/ShenBing/ShenBingRemake.lua").create()["root"]
    UI:addTo(self)
    Helper:convertUIByParent(self)

    self.allweaponType = {} -- 所有技艺
    self.weaponType = {} -- 所学技艺
end

function ShenBingRemakeLayer:initUI()
    local text = self._currWeapon.name .. "(" .. self._currWeapon.bType .. "，由" ..self._duanZaoItem.name .. "锻造)"
    self:setNameText(text)
    self.Panel_1.Text_NPC:setString(npcText[self._npcType])
    self.Text_money:setString("本次重铸需要" .. self._money .. "元宝")
    self:initShenBingTypeList(self.allweaponType, Helper:getNoColorStr(self._duanZaoItem.name), self._currWeapon.bType)

    self.Panel_Back:releaseFunc(function()
        self:hideLayer()
    end)

    self:initChangeDefaultShenBingBtnFunc()
end

function ShenBingRemakeLayer:setNameText(text)
    self.ShenBingName:setString(text)
end

function ShenBingRemakeLayer:showLayer()
    assert(self._currWeapon)

    self:initDuanZaoItem()
    self:initSpendMoney()
    self:initSkills()
    self:initUI()
    self:setVisible(true)
end

function ShenBingRemakeLayer:hideLayer()
    PopupLayerController:hideLayer("ShenBingRemakeLayer", function(layer)
        self:setVisible(false)
    end)
end

function ShenBingRemakeLayer:setCurrWeapon(weapon)
    self._currWeapon = weapon
end

function ShenBingRemakeLayer:setCanRemakeList(list)
    self._remakeList = list
end

function ShenBingRemakeLayer:setSpecialDuanZaoCaiLiaoList(list)
    self._specialDuanZaoCaiLiaoList = list
end

function ShenBingRemakeLayer:setNpcType(roleType)
    self._npcType = roleType
end

function ShenBingRemakeLayer:setRole(role)
    self._role = role
end

function ShenBingRemakeLayer:initSpendMoney()
    -- math.min(重铸次数*200+800,5000)，且重铸次数为0（即第一次重铸）时需要元宝数量强制设为0
    local remakeTimes = self._role:getInheritFlag("重铸次数")
    if remakeTimes == 0 then
        self._money = 0
    else
        self._money = math.min( remakeTimes * 200 + 800, 5000)
    end
end

function ShenBingRemakeLayer:initDuanZaoItem()
    local duanZaoItems = self._currWeapon.duanzaoitems
    self._duanZaoItem = self._role:getOneItemByKey(duanZaoItems.itemId)
end

function ShenBingRemakeLayer:checkTypeCanRemake(weaponType)
    if MapIsEmpty(self._remakeList) == false then
        for k, v in ipairs(self._remakeList) do
            if v == weaponType then
                return true
            end
        end
    end

    return false
end

function ShenBingRemakeLayer:checkIsSpecialDuanZaoCaiLiao(itemId)
    if MapIsEmpty(self._specialDuanZaoCaiLiaoList) == false then
        for id,v in pairs(self._specialDuanZaoCaiLiaoList) do
            if itemId == id then
                return false
            end
        end
    end

    return true
end

function ShenBingRemakeLayer:initChangeDefaultShenBingBtnFunc()
    self.Image_back_ChangeWeapon:releaseFunc(function()
        PopupLayerController:showLayer("ShenBingWareHouseLayer",function(layer)
            layer:setBackConditionFunc(function()
                local shenBing = self._role:getDefaultShenBing()
                if shenBing then
                    if self:checkTypeCanRemake(shenBing.type) == false then
                        PopText("当前类型神兵无法重铸")
                        return false
                    end

                    local duanZaoItems = shenBing.duanzaoitems
                    if self:checkIsSpecialDuanZaoCaiLiao(duanZaoItems.itemId) == false then
                        PopText("当前神兵材料无法重铸")
                        return false
                    end

                    self:setCurrWeapon(shenBing)
                    self:initDuanZaoItem()
                    local text = self._currWeapon.name .. "(" .. self._currWeapon.bType .. "，由" ..self._duanZaoItem.name .. "锻造)"
                    self:setNameText(text)
                    self:initShenBingTypeList(self.allweaponType, Helper:getNoColorStr(self._duanZaoItem.name), self._currWeapon.bType)
                    return true
                else
                    PopText("请设置默认神兵，否则无法进行操作！")
                    return false
                end
            end)
            layer:showUI()
        end)
    end)
end

-- 获得相关锻造材料所学的锻造技艺
function ShenBingRemakeLayer:initSkills()
    local pfSkill = ForgeSkill:getUserFoegeKnowledge() -- 获得已拥有的锻造知识点
    local knowledgeIdList = {}
    for forgeId, knowledges in pairs(pfSkill) do
        for k, knowledge in pairs(knowledges) do
            table.insert(knowledgeIdList, knowledge)
        end
    end
    local unpfSkill = ForgeSkill:getUserForgeUnLearnKnowledge() -- 获得未拥有的锻造知识点
    local unknowledgeIdList = {}
    for forgeId, knowledges in pairs(unpfSkill) do
        for k, knowledge in pairs(knowledges) do
            table.insert(unknowledgeIdList, knowledge)
        end
    end

    local allknowledgeList = ShenBingDesc:getTextMapAttr("knowledgeList")

    if type(allknowledgeList) ~= "table" then
        print("getTextMapAttr  knowledgeList 此接口返回不为table ！")
    end
    for id, knowledgeList in pairs(allknowledgeList) do
        self.weaponType[id] = {}
        self.allweaponType[id] = {}
        -- 遍历每一行数据中的知识点
        for index, allknowledgeid in pairs(knowledgeList.knowledgeAll) do
            for i, knowledgeid in pairs(knowledgeIdList) do
                --	用已拥有锻造知识id 匹配 锻造对应的 全部知识点  得到index 获得对应武器 (只获取一条)
                if knowledgeid == allknowledgeid then
                    table.insert(self.weaponType[id], knowledgeList.weaponAll[index])
                    table.insert(self.allweaponType[id], knowledgeList.weaponAll[index])
                end
            end
        end

        for index, allknowledgeid in pairs(knowledgeList.knowledgeAll) do
            for i, knowledgeid in pairs(unknowledgeIdList) do
                --	用已拥有锻造知识id 匹配 锻造对应的 全部知识点  得到index 获得对应武器 (只获取一条)
                if knowledgeid == allknowledgeid then
                    table.insert(self.allweaponType[id], knowledgeList.weaponAll[index])
                end
            end
        end
    end
end

-- 根据材料锻造技艺重铸同类别神兵(--list 当前所有材料可锻造技艺  --materialType 锻造材料  --shenbingType 当前神兵类型)
function ShenBingRemakeLayer:initShenBingTypeList(list, materialType, shenbingType)
    self.ListView_ShenBingType:removeAllItems()
    local typeIndex
    for i, v in pairs(ShenBingMaterialList) do
        if v and materialType and v == materialType then
            typeIndex = i
            break
        end
    end

    for materialIndex, shenbingTypeList in pairs(list) do
        if typeIndex and materialIndex == typeIndex and type(shenbingTypeList) == "table" then
            for i, v in pairs(shenbingTypeList) do
                if v == shenbingType then
                else

                    if self:checkShenBingType(shenbingType, v) == true then
                        local item = self.Panel_type:clone()
                        Helper:convertUIByParent(item)
                        item.Type_name:setString(v)
                        local isCanMake = false

                        if self.weaponType[typeIndex] then
                            for k, duanzaotype in pairs(self.weaponType[typeIndex]) do
                                if duanzaotype and v == duanzaotype then
                                    isCanMake = true
                                end
                            end
                        end
                        item:releaseFunc(function()
                            if isCanMake == true then
                                self.Panel_warning:setVisible(true)
                                self.Panel_warning.Text_warning1:setString(
                                    "你确定花费" .. self._money .. "元宝将" .. shenbingType .. "重铸为" .. v ..
                                        "？")
                                self.Panel_warning.Panel_confirm:releaseFunc(function()
                                    self:changeShenBingInfo(shenbingType, v)
                                    self.Panel_warning:setVisible(false)
                                end)
                                self.Panel_warning.Panel_cancel:releaseFunc(function()
                                    self.Panel_warning:setVisible(false)
                                end)
                            else
                                PopText("你尚未习得此类神兵的锻造技艺！")
                            end

                        end)
                        self.ListView_ShenBingType:pushBackCustomItem(item)
                        self.ListView_ShenBingType:setVisible(true)
                        print("可重铸")
                    end
                end
            end
            break
        end
    end
    self.ListView_ShenBingType:jumpToTop()
end

---检查同类型神兵(现有神兵类型 所选重铸后神兵类型)
function ShenBingRemakeLayer:checkShenBingType(ShenbingType1, ShenbingType2)
    local type1, type2
    for id, changeData in pairs(shenBingweaponChangeList["chongzhu"]) do
        if changeData["type2"] == ShenbingType1 then
            type1 = changeData["type1"]
        end
        if changeData["type2"] == ShenbingType2 then
            type2 = changeData["type1"]
        end
    end

    if type1 ~= nil and type2 ~= nil and type1 == type2 then
        print("type1..type2" .. type1 .. type2)
        return true
    end
    return false
end

local changeWeapon = {
    id = "", -- 必须唯一
    -- name = "",		-- 名字 
    type = "", -- 武器类型
    bType = "",
    wpType = "神兵", -- 类型 (用于区分神兵和普通兵器)
    damage = 0, -- 伤害值
    yindu = 0, -- 硬度值
    rendu = 0, -- 韧度值
    weight = 0, -- 重量值
    effctNum = 0, -- 特性值 (计算得出,到达一定值可开启特效)
    type2 = 0
    -- wanhaodu = 100,	-- 完好度 (损坏完好度为0, 修理后耐久度修复,完好度根据计算得出)
    -- effct1 = "",		-- 特效1
    -- effct2 = "",		-- 特效2
    -- effct3 = "",		-- 特效3 (暂定三个特效,特效效果读取资源配置表)
    -- cuilianitems = {},  -- 加工使用的物品列表 {itemid = count}
    -- useNeiLi = 0,		-- 注入的内力值
    -- desc = "",			-- 武器的描述,在第一次载入的时候计算生成(生成规则查看策划案)
    -- equipDescId = "",	--装备描述与拖下描述 的Id
    -- getoffDesc = "", 		-- 拖下描述
    -- weaponLookId = "",
    -- status = 0, 		-- 铸造状态 0 铸造中,1 铸造完成未取名,2 铸造完成已取名
    -- canEquip = 1 ,		-- 可装备
    -- cuilianCount = 0  ,  -- 淬炼成功次数
    -- cuilianFailedCount = 0  , -- 淬炼失败次数
    -- --- 预备属性 (不知要以后会不会要用,建议保存记录到本地,并且定期上传至服务器)
    -- duanzaoitems = {},	-- 锻造使用的物品列表 {itemid = count}
    -- cuilian = {}	-- 淬炼统计,列表,每次淬炼记录一条 {xlType = "欧冶子", itemid = "", cost = 500, result = "success"}

}

-- 将自己神兵的当前硬度、当前韧性、当前重量、一共淬炼次数、初始伤害力、初始特性值读取出					

-- 由(目标硬度max-目标硬度min)*((当前硬度-当前硬度min)/(当前硬度max-当前硬度min))+目标硬度min计算出转换后神兵的硬度				
-- 韧性、重量用同样的公式计算，重量min全部为0
-- 再由淬炼次数*伤害力加成+自己神兵的初始伤害力计算出转换后的神兵伤害	
-- 伤害力计算
-- 如果当前兵器伤害力<460，则用：当前伤害力-(淬炼成功次数*当前兵器伤害力加成)+(淬炼成功次数*目标兵器伤害力加成）
-- 如果兵器伤害力>=460,且目标兵器的伤害力加成>=当前兵器伤害力加成，则新神兵伤害力为460
-- 如果兵器伤害力>=460,且目标兵器的伤害力加成<当前兵器伤害力加成
-- 则，读取当前神兵锻造材料，读取玩家锻造之术等级。
-- 新初始伤害力=math.min(math.floor(锻造技术等级/50+(当前神兵锻造材料熔炼最大值*0.5+淬炼成功次数/2)*3/20+5),100)*1.2+当前神兵材料初始伤害力；
-- 之后由新初始伤害力+淬炼成功次数*新神兵的伤害力成长值得到最终伤害
-- 伤害最大值为460
-- 特性值计算
-- 如果当前兵器特性值<300，则用：当前特性值-(淬炼成功次数*当前兵器特性值加成)+(淬炼成功次数*目标兵器特性值加成）
-- 如果兵器特性值>=300,且目标兵器的特性值加成>=当前兵器特性值加成，则新神兵的特性值为300
-- 如果兵器特性值>=300,且目标兵器的特性值加成<当前兵器特性值加成，则计算读取神兵锻造材料
-- 转换后的最终特性值=（当前神兵锻造材料的初始特性值+2）+锻造次数*目标神兵特性值成长
-- 特性最大值为300
-- ["1"]={
-- ["tenacityMax"]=150,
-- ["specialAdd"]=1.03, --特性值加成
-- ["weightMax"]=25,    --重量
-- ["hardnessMin"]=30,  --硬度
-- ["tenacityMin"]=30,  --韧性
-- ["hurtAdd"]=1.03,    --伤害力加成
-- ["hardnessMax"]=150, 
-- ["type"]=[[长剑]],
-- ["id"]=1}
---神兵type2属性转换


-------神兵重铸  --自身当前神兵类型  --重铸后类型
function ShenBingRemakeLayer:changeShenBingInfo(beforeShenbingType, afterShenbingType)
    local shenBingweapon = self._currWeapon

    ---当前神兵锻造材料熔炼最大值 初始伤害力 初始特性值
    local ronglianmax, Forgingdamage, Forgingcharacteristics = 0, 0, 0
    local itemFurnaceInfoMap = godweapon["itemOfFurnaceInfo"]
    
    for index, typeInfo in pairs(itemFurnaceInfoMap) do
        if shenBingweapon.typeDesc == typeInfo["Forgingdsc"] then
            ronglianmax = typeInfo["ronglianmax"]
            Forgingdamage = typeInfo["Forgingdamage"]
            Forgingcharacteristics = typeInfo["Forgingcharacteristics"]
            break
        end
    end

    local beforeShenbingData = {} -- 当前神兵类型数据
    for id, changeData in pairs(shenBingweaponChangeList["chongzhu"]) do
        if beforeShenbingType ~= "" and changeData["type2"] == beforeShenbingType then
            beforeShenbingData = changeData
        end
    end

    for id, changeData in pairs(shenBingweaponChangeList["chongzhu"]) do
        if afterShenbingType ~= "" and changeData["type2"] == afterShenbingType then
            changeWeapon.rendu = (changeData["tenacityMax"] - changeData["tenacityMin"]) *
                                     (math.max((shenBingweapon.rendu - beforeShenbingData["tenacityMin"]), 0) /
                                         (beforeShenbingData["tenacityMax"] - beforeShenbingData["tenacityMin"])) +
                                     changeData["tenacityMin"]
            changeWeapon.yindu = (changeData["hardnessMax"] - changeData["hardnessMin"]) *
                                     (math.max((shenBingweapon.yindu - beforeShenbingData["hardnessMin"]), 0) /
                                         (beforeShenbingData["hardnessMax"] - beforeShenbingData["hardnessMin"])) +
                                     changeData["hardnessMin"]
            changeWeapon.weight = changeData["weightMax"] *
                                      (shenBingweapon.weight / beforeShenbingData["weightMax"])
            if changeWeapon.rendu > changeData["tenacityMax"] then
                changeWeapon.rendu = changeData["tenacityMax"]
            end
            if changeWeapon.yindu > changeData["hardnessMax"] then
                changeWeapon.yindu = changeData["hardnessMax"]
            end
            if changeWeapon.weight > changeData["weightMax"] then
                changeWeapon.weight = changeData["weightMax"]
            end
            changeWeapon.type = changeData["type1"]
            changeWeapon.bType = changeData["type2"]
            if shenBingweapon.damage < 460 and shenBingweapon.damage >= 0 then
                changeWeapon.damage = shenBingweapon.damage -
                                          (shenBingweapon.cuilianCount * beforeShenbingData["hurtAdd"]) +
                                          (shenBingweapon.cuilianCount * changeData["hurtAdd"])
            elseif shenBingweapon.damage >= 460 and changeData["hurtAdd"] >= beforeShenbingData["hurtAdd"] then
                changeWeapon.damage = 460
            elseif shenBingweapon.damage >= 460 and changeData["hurtAdd"] < beforeShenbingData["hurtAdd"] then
                changeWeapon.damage = math.min(math.floor(
                    self._role:getSkillLv("duanzaozhishu") / 50 +
                        (ronglianmax * 0.5 + shenBingweapon.cuilianCount / 2) * 3 / 20 + 5), 100) * 1.2 +
                                          Forgingdamage + shenBingweapon.cuilianCount * changeData["hurtAdd"]
            end
            if shenBingweapon.effctNum < 300 and shenBingweapon.effctNum >= 0 then
                changeWeapon.effctNum = shenBingweapon.effctNum -
                                            (shenBingweapon.cuilianCount * beforeShenbingData["specialAdd"]) +
                                            (shenBingweapon.cuilianCount * changeData["specialAdd"])
            elseif shenBingweapon.effctNum >= 300 and changeData["specialAdd"] >= beforeShenbingData["specialAdd"] then
                changeWeapon.effctNum = 300
            elseif shenBingweapon.effctNum >= 300 and changeData["specialAdd"] < beforeShenbingData["specialAdd"] then
                changeWeapon.effctNum = Forgingcharacteristics + 2 + shenBingweapon.cuilianCount *
                                            changeData["specialAdd"]
            end
            if changeWeapon.effctNum >= 300 then
                changeWeapon.effctNum = 300
            end
            if changeWeapon.damage >= 460 then
                changeWeapon.damage = 460
            end
            local localEffct = {
                [1] = "nil",
                [2] = "nil",
                [3] = "nil"
            }
            for i, list in pairs(godweapon["weaponSpecials"]) do
                if list.weapontype == changeWeapon.bType and changeWeapon.effctNum >= list.specialget then
                    localEffct[list.specialget / 100 + 1] = list.specialid
                end
            end
            changeWeapon.effct1 = localEffct[1]
            changeWeapon.effct2 = localEffct[2]
            changeWeapon.effct3 = localEffct[3]
        end
    end
    if changeWeapon.effctNum < 0 then
        changeWeapon.effctNum = 0
    end
    if changeWeapon.damage < 0 then
        changeWeapon.damage = 0
    end

    changeWeapon.id = shenBingweapon.id

    for k ,v in pairs(itemFurnaceInfoMap) do
        if v.itemid == self._duanZaoItem.id and v.forgingweapon == changeWeapon.bType then
            changeWeapon.typeDesc = v.Forgingdsc
        end
    end

    do
        local info = inherit({},changeWeapon)
        if info.effct1 == "nil" then
            info.effct1 = nil
        end
        if info.effct2 == "nil" then
            info.effct2 = nil
        end
        if info.effct3 == "nil" then
            info.effct3 = nil
        end

        info.weaponLookId = shenBingweapon.weaponLookId

        local desc = ShenBingDesc:getShenBingDesc(info, true)
        changeWeapon.desc = desc
    end

    local remakeTimes = self._role:getInheritFlag("重铸次数")
    local function successFunc()
        shenBingweapon.bType = changeWeapon.bType
        shenBingweapon:initShenbingType2()
        ShenBingDuanZao:updateShenBingInfo(changeWeapon, self._role)
        self._role:setInheritFlag("重铸次数", remakeTimes + 1)
        self:playRemake(shenBingweapon)
    end

    if remakeTimes < 1 then
        successFunc()
    else
        local itemId = "shenbingchongzhu" .. tostring(remakeTimes)
        if remakeTimes > 21 then
            itemId = "shenbingchongzhu21"
        end

        HttpManagerEx:getGoodsInfo(itemId, function(status, errcode, errmsg, data)
            if status == 200 then
                if errcode == 0 then
                    if type(data) == "table" and _G.next(data) then
                        local item = data
                        TransCheck:buyItem(item, function(eventType)
                            if eventType == "success" then
                                successFunc()
                            else
                                PopText("支付出错，神兵重铸失败！")
                            end
                        end)
                    else
                        PopText("神兵重铸失败！数据出错.")
                    end
                else
                    PopText("神兵重铸失败！数据出错..")
                end
            else
                PopText("网络请求出错,请换个网络环境再试!")
            end
        end, IS_SHOW_WAITING)
    end
end

function ShenBingRemakeLayer:playRemake(shenBingweapon)
    self:hideLayer()

    Audio:pauseMusic()

    self.musicId = Audio:playEffect("DuanDa", true)

    PopupLayerController:showLayer("GlobalShadeLayer", function(layer)
        layer:setPopText("神兵重铸中，少侠稍安勿躁！")
        layer:showLayer()
    end)

    for k, _text in pairs(npcOutText[self._npcType]) do
        self:delayFunc((k - 1) * 2, function()
            RichPrint("main",_text)

            if k == #npcOutText[self._npcType] then
                if self.musicId then
                    Audio:stopEffect(self.musicId)
                    self.musicId = nil
                end
                Audio:resumeMusic()
                PopText("神兵重铸成功！")
                PopupLayerController:hideLayer("GlobalShadeLayer", nil, 0.1)
                PopText("获得神兵" .. shenBingweapon.name .. "(" .. shenBingweapon.bType .. ")")
            end
        end)
    end
end

Helper:classDefNodeGetInstance(ShenBingRemakeLayer)
return ShenBingRemakeLayer
00000000000000