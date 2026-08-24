local MenKeModel = {}

local HomelandRoleUtil = require("app.models.HomelandModel.HomelandRoleUtil")
local GuanJiaModel = require("app.models.HomelandModel.HomelandRoleModel.GuanJiaModel")
local familylist = requireWithEncrypt("script.others.familylist")
local roleMobanList = familylist["人物模板设计"]
local EmployeeMenkeConditionList = familylist["高级门客招募需求"]

--获取随机生成的门客信息
--参数2:模板随机列表
--参数3:特点值
function MenKeModel:getRandomMenKeResult(shenShi)
    local menkeData = {}
    local name = ""
    local sex = "男"
    local age = 0
    local looks = 0
   	local defaultZhongCheng = 0
    local speedZhongCheng = 0
	local price = 0
    local price_unit = "yinpiao"

    local character = "" --性格id
    local traitVal = 0
    local jobType = "menke001"
	local modal = "" --武功信息
    local mobanSkill = {}
    local leave_day = 0
    local agelist,sexlist,texinglist,looklist,lifelist = HomelandRoleUtil:getAttrList(jobType)
    if agelist then
        age = math.random(agelist[1],agelist[2])
    end
    if sexlist then
        local random = math.random(1,#sexlist)
        sex = sexlist[random]
    end
    if looklist then
        looks = math.random(looklist[1],looklist[2])
    end

    name = GuanJiaModel:getGjRandomName(sex)

    traitVal = self:getTraitVal()
    
    local conformList =  HomelandRoleUtil:getTexingList(traitVal) --符合特点值要求的特点列表
    local finalList = {}   --最终符合要求的特性列表
    if texinglist and conformList then
        for k,v in pairs(texinglist) do
            for ker,value in pairs(conformList) do
                if v == value then
                    table.insert(finalList,v)
                end
            end
        end
        print("------------------finalList--------------------")
        Helper:print_lua_table(finalList)
        print("------------------finalList--------------------end")
        local list = finalList
        local count = HomelandRoleUtil:getTexingCount()
        local index
        if not MapIsEmpty(list) then
            if count == 0 then
            elseif count == 1 then
                index = math.random(1,#list) 
                menkeData["trait1"] = list[index]
            elseif count == 2 then
                for i =1 ,2 do
                    index = math.random(1,#list)
                    menkeData["trait"..i] = list[index]
                    table.remove( list,index)
                end
            elseif count == 3 then
                for i =1 ,3 do
                    index = math.random(1,#list)
                    menkeData["trait"..i] = list[index]
                    table.remove( list,index)
                end
            end
        end
    end
    
    character = HomelandRoleUtil:getRandomCharacterId()

    modal = self:getMenkeMobanId()
    print("modal = ",modal)
    mobanSkill = HomelandRoleUtil:getUploadWebRoleSkillArray(modal)

    --日薪在90~180银票中随机；雇佣时需要先支付日薪*14的银票；
    price = math.random(90,180)*14

    local leaveDay = HomelandRoleUtil:getCharacterFactor(jobType).leave1
	local leaveDayFactor = HomelandRoleUtil:getCharacterAttr(character).leave
    local dailyupZhongcheng = HomelandRoleUtil:getCharacterFactor(jobType).Dailyup1
	local dailyupZhongcheng1 = HomelandRoleUtil:getCharacterAttr(character).Dailyup

    speedZhongCheng = dailyupZhongcheng*dailyupZhongcheng1
    
    leave_day = leaveDay*leaveDayFactor

    defaultZhongCheng = math.random(1,100)

    menkeData.name = name
    menkeData.jobType = jobType
    menkeData.sex = sex
    menkeData.age = age
    menkeData.looks = looks
    menkeData.shenShi = shenShi
    menkeData.character = character
    menkeData.defaultZhongCheng = defaultZhongCheng
    menkeData.speedZhongCheng = speedZhongCheng
    menkeData.price = price
    menkeData.price_unit = price_unit
    menkeData.traitVal = traitVal
    menkeData.modal = modal
    menkeData.leave_day = leave_day
    menkeData.mobanSkill = mobanSkill

    return menkeData
end

--生成招募门客数据列表
function MenKeModel:initEmployListInLocal()
    local employListData = {}
    local cacheList = {} --缓存刚刚刷新到的身世
    for i = 1 ,3 do
        local shenShi = HomelandRoleUtil:getMapRoleRandomShenShi(self._lifeTrim,"menke001")
        assert(shenShi,"MenKeModel:getProfessionList 检查为什么修剪过了还是随不到身世")
        local menkeData = self:getRandomMenKeResult(shenShi)
        
        --已经生成的身世也要加入这个列表，不能再生成
        table.insert(self._lifeTrim, shenShi)
        cacheList[shenShi] = true
        table.insert(employListData,menkeData)
    end

    --清除缓存的身世
    for i = #self._lifeTrim,1,-1 do
        if cacheList[self._lifeTrim[i]] == true then
            cacheList[self._lifeTrim[i]] = nil
            table.remove( self._lifeTrim, i )
        end
    end

    return employListData
end

--获取门客模版Id
function MenKeModel:getMenkeMobanId()
   
    local weightList = {[1] = 75,[2] = 20,[3] = 5}

    if DEBUG_MODE == 1 then
        weightList[1] = 1
        weightList[2] = 1
        weightList[3] = 98
    end

    local weight = Helper:RandomByWeight(weightList)

    local mobanId = switch(weight,{
        [1] = function () return "moban0"..math.random(67,75) end,
        [2] = function () return "moban0"..math.random(76,85) end,
        [3] = function () 
            local randomNum = math.random(86,115)
            if DEBUG_MODE == 1 then
                randomNum = math.random(111,115)
            end
            return randomNum > 99 and "moban"..randomNum or "moban0"..randomNum 
        end,
    })

    return mobanId
end

--获得特性值
function MenKeModel:getTraitVal()
    local weightList = {[1] = 25,[2] = 35,[3] = 28,[4] = 11,[5] = 1,}

    local weight = Helper:RandomByWeight(weightList)

    local traitVal = switch(weight,{
        [1] = math.random(1,99),
        [2] = math.random(100,199),
        [3] = math.random(200,299), 
        [4] = math.random(300,499),
        [5] = 500,
    })

    return traitVal
end



--@desc: 设置需要裁剪的数据
--@life_trims: 需要裁剪的数据
function MenKeModel:setlifeTrims( life_trims )
    self._lifeTrim = life_trims
end

--@desc: 需要招募仆人的用户地图id
--@mid: 用户地图id
function MenKeModel:setMid( mid )
    self._mid = mid
end

--@desc: 设置招募npc的Id
--@npcId:招募npc的ID 
function MenKeModel:setNpcId(npcId)
    self._npcId = npcId
end

function MenKeModel:getNpcId()
    return self._npcId
end

--@desc: 获取列表
function MenKeModel:getList()
    return self._list
end

function MenKeModel:pop( index )
    if MapIsEmpty(self._list) then
        return
    end

    table.remove(self._list,index)
end

function MenKeModel:push( data )
    if MapIsEmpty(self._list) then
        self._list = {}
    end

    table.insert( self._list,data)
end

function MenKeModel:clear()
    self._npcId = nil
    self._list = {}
    self._mid = nil
    self._lifeTrim = {}
end

--@desc: 刷新列表
--@needCost:是否需要花费金钱
--@callback: 回调函数
function MenKeModel:refresh(needCost,callback)
    local save_type = 1

    if needCost == 2 then
        save_type = 2
    end
    
    local list = self:initEmployListInLocal()
    
    HttpManagerEx:saveEmployeeList(save_type,self._npcId,list,function(status, errcode, errmsg, data)
        if status == 200 then
            if errcode == 0 then
                if callback then
                    self._list = {}
                    for i = 1,#data do
                        if data[i].state == 0 then
                            table.insert(self._list,data[i])
                        end
                    end
                    callback(true)
                    
                    User:getRole():addItemCount("menkecard1",-1)
                    local itemAttr = Item:getOneItemByKey("menkecard1")
                    PopText("您消耗了 " .. itemAttr.name .. " X1")
                end
            else
                PopText(errmsg)
            end
        else
            PopText(errmsg)
        end
    end, IS_SHOW_WAITING)
end

--@desc: 生成仆人招募列表
--@callback: 生成成功后的回调函数
function MenKeModel:initEmployList(callback)
    HttpManagerEx:getEmployList(self._npcId,self._mid,function(status, errcode, errmsg, data)
        if status == 200 then
            if errcode == 0 then
                self:setlifeTrims(data.shenshi)

                if not MapIsEmpty(data.list) then
                    self._list ={}
                    for i = 1,#data.list do
                        if data.list[i].state == 0 then
                            table.insert(self._list,data.list[i])
                        end
                    end
                    
                    if #self._list == 0 then
                        callback(false,"你今天已经招募了一名门客，请明日再来。")
                    elseif #self._list > 0 then
                        callback(true)
                    else
                        assert(false,"MenKeModel:initEmployList  有bug")
                    end
                    
                else
                    local role = User:getRole()
                    local items =
                        role:getItems(function(item)
                            return item.itemId == "menkecard1"
                        end
                    )
                    
                    if #items < 1 then
                        PopText("需要拥有沧浪帖！")
                        return 
                    end

                    self:refresh(1,callback)
                end
            else
                PopText(errmsg)
            end
        else
            PopText(errmsg)
        end
    end, IS_SHOW_WAITING)
end

function MenKeModel:getDsc()
    local dsc = "近日来，很多人到我这来登记，想应募门客之职。他们当中不少人可是身怀绝技的，可谓卧虎藏龙。敢问可有心仪人选吗？"
    return dsc
end

function MenKeModel:getSexDsc(sex)
	local sexDsc = "他"
	if sex == "女" then
		sexDsc = "她"
	end
	return sexDsc
end

function MenKeModel:employeeNpc(index,callback)
    local npc = self._list[index]
    if MapIsEmpty(npc) then
        print("没有NPC信息,"..index)
        Helper:print_lua_table(self._list)
        return
    end

	local jobType = npc.jobType
	local name = npc.name
	local unit = npc.price_unit
    local price = npc.price
    local hid = npc.hid or 0

    local sexDsc = self:getSexDsc(npc.sex)

	local chineseJob = HomelandRoleUtil:getCHAJobTypeName(jobType)


    PopupLayerController:showLayer("PopConfirmLayer",function (layer)
        layer:showRefreshPannel()
        local temp = {
            yuanbao = "元宝",
            yinpiao = "银票"
        }
        local text = "雇佣"..name.."首次需支付"..price..temp[unit].."，之后每7天需要发一次薪，"..name.."的日薪是"..(price/14)..temp[unit].."。请问是否要雇佣？"

        if unit == "yinpiao" then
            HttpManagerEx:viewCurrencyByType("yinpiao", User:getRole():getCurrencyVersion(),function(status, errcode, errmsg, data)
                if status == 200 then
                    if errcode == 0 then
                        layer:setDesc2("当前拥有银票:"..data.number,"YEL")
                    else
                    PopText(errmsg)
                    end
                else
                    PopText(errmsg)
                end
            end, IS_SHOW_WAITING)
        elseif  unit == "yuanbao" then
            HttpManagerEx:getYuanBao(function(status, errcode, errmsg, data)
                if status == 200 then
                    if errcode == 0 then
                        layer:setDesc2("当前拥有元宝:"..data.yuanbao,"YEL") 
                    else
                        PopText(errmsg)
                    end
                end
            end) 
        else
            assert(false,"GuanJiaModel:employeeNpc  购买单位出错")
        end
        
        layer:setDsc(text)
        layer:setButtonNameAndCallFunc(
            "确定",
            function()
                local ret,msg1,msg2 = self:checkCanEmployeeNpc(npc)
                msg1 = msg1 or ""
                msg2 = msg2 or ""
                if ret == false then
                    if callback then
                        callback()
                    end
                    PopText("对方拒绝了你招募！")
                    RichPrint("main","WHT"..npc.name.."："..msg1.."NOR")
                    RichPrint("main",msg2)
                    return 
                end

                local objId = HomelandRoleUtil:createObjId(jobType)

                local mid = User:getRole():getHouseId()

                local push_data = {}
                if hid == 0 then
                    push_data = npc
                end

                print("hid = ",hid,"objId = ",objId,"mid = ",mid)
                HttpManagerEx:addEmployee(hid,objId,mid,self._npcId,push_data,function(status, errcode, errmsg, data)
                    if status == 200 and errcode == 0 then
                        local successText = "你花了"..price..temp[unit].."雇佣"..name.."成为你的门客".."，"..sexDsc.."将作为"..chineseJob.."为你服务，请善待"..sexDsc.."，及时发薪。"
                        local text1 = "HIC你决定招募"..name.."作为你的门客，并将你的选择告诉了另外两位候选人。NOR"
                        local text2 = self:getExtraText(index)

                        RichPrint("main",successText)
                        RichPrint("main",text1)
                        RichPrint("main",text2)

                        local currMap = User:getRole():getCurrMap()
                        local fjId = data.fjId
                        if currMap:getMapType() == MAP_TYPE.MYHOME then	
                            local role = clone(data)
                            
                            role = HomelandRoleUtil:initHomelandMapRole(role,currMap)
                            role.id = data.rwId
                            currMap:createRole(role)
                            currMap:addRoomRole(fjId,objId)

                            currMap:addPersonJobCount(jobType,1)

                            local HomelandUtil = require("app.models.HomelandModel.HomelandUtil")
                            HomelandUtil:updateRoleFlag(currMap)

                            currMap.__MapLayer:delayRefreshMap()
                        else
                            local role = User:getRole()
                            local mid = role:getHouseId()
                            role:setMapWithId("user_fb_" .. mid, nil)
                        end
                        
                        HomelandRoleUtil:addServantCount(1)
                    
                        local rwId = data.rwId
                        local id_index = string.split(rwId,"_")[2]

                        User:getRole():setHomelandAttr("prIdIndex",tonumber(id_index))
                    
                        -- 需要服务器把雇佣成功的数据下发
                        HomelandRoleUtil:recordEmployData(data.rwId,data)

                        self:pop(index)
                    
                        if callback then
                            callback()
                        end
                    else
                        print("errcode : ",errcode)
                        PopText(errmsg)
                    end
                end, IS_SHOW_WAITING)
            end
        )

        layer:setCanelButtonNameAndCallFunc("取消")
    end)
end

--获得雇佣成功时额外输出的文本
function MenKeModel:getExtraText(index)
    local name = ""
    for i ,v in ipairs(self._list) do
        if i ~= index then
            name = name == "" and v.name or name.."、".. v.name
        end
    end
    local text = "WHT"..name.."向你拱拱手，悻悻地离开了。NOR"

    return text
end

--检查玩家属性能否雇佣这个npc
function MenKeModel:checkCanEmployeeNpc(npc)
    if npc == nil then
        assert(false,"没有NPC信息")
    end
    local mobanId = npc.modal
    if mobanId == nil then
        assert(false,"NPC没有模版信息")
    end

    local conditionAttr = self:getConditionAttr(mobanId)
    
    local ZhengshenDemand = conditionAttr.ZhengshenDemand --侠义值要求
    local LevelDemand = conditionAttr.LevelDemand --等级要求
    local GongfuDemand = conditionAttr.GongfuDemand --武功要求
    local MoneyDemand = conditionAttr.MoneyDemand --金钱要求

    local RefuseText1 = conditionAttr.RefuseText1   --侠义值不符拒绝文本
    local ExplainText1 = conditionAttr.ExplainText1 -- 侠义值不符解释文本
    local RefuseText2 = conditionAttr.RefuseText2   -- 等级不符拒绝文本
    local ExplainText2 = conditionAttr.ExplainText2 -- 等级不符解释文本
    local RefuseText3 = conditionAttr.RefuseText3   -- 武功不符拒绝文本
    local ExplainText3 = conditionAttr.ExplainText3 -- 武功不符解释文本
    local RefuseText4 = conditionAttr.RefuseText4   -- 金钱不符拒绝文本
    local ExplainText4 = conditionAttr.ExplainText4 -- 金钱不符解释文本

    local role = User:getRole()
    local zhengqi = role:getAttr("zhengqi")
    local lv = role:getAttr("lv")
    local kongfu = role:getKongfu()
    local money = role:getAttr("money")

    if ZhengshenDemand ~= 0 then
        local zsDemandArr = string.split(ZhengshenDemand,";")
        local arg1 = tonumber(zsDemandArr[1])
        local arg2 = tonumber(zsDemandArr[2])
        if DEBUG_MODE == 1 then
            if arg1 == nil or arg2 == nil then
                assert(false,"MenKeModel:checkCanEmployeeNpc  资源表侠义值参数不符合规则")
            end
        end
        if (arg1 ~= 0 and zhengqi <= arg1) or (arg2 ~= 0 and zhengqi >= arg2) then
            return false,RefuseText1,ExplainText1
        end
    end
    if LevelDemand ~= 0 and lv <= LevelDemand then
        return false,RefuseText2,ExplainText2
    end
    if GongfuDemand ~= 0 and kongfu <= GongfuDemand then
        return false,RefuseText3,ExplainText3
    end
    if MoneyDemand ~= 0 and money <= MoneyDemand then
        return false,RefuseText4,ExplainText4
    end

    return true
end

--根据模版id获得高级门客招募需求资源配表
function MenKeModel:getConditionAttr(mobanId)
    for k,v in pairs(EmployeeMenkeConditionList) do
        if v.mobanid == mobanId then
            return v
        end
    end
end

return MenKeModel00000000