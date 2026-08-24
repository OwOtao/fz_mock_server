local CAN_DEBLOCK_TEXING = false --是否能解锁特性

local HomelandRoleUtil = {}
local familylist = requireWithEncrypt("script.others.familylist")
local familyspecial = requireWithEncrypt("script.others.familyspecial")


local roleTypeList = familylist["人物类型"]
local texingMap = familyspecial["trait"]
local characterList = familyspecial["character"]
local characterFactorList = familyspecial["career"]

local roleMobanList = familylist["人物模板设计"]

local function initRoleMobanList()
    for k,v in pairs(roleMobanList) do
        roleMobanList[k] = createEncryptTable(v)
    end
end

initRoleMobanList()

--@desc:获取管家忠诚度描述
function HomelandRoleUtil:getGuanJiaFidelity(fidelity)
    if fidelity == nil then
        return ""
    end
    --具体规则待给出
    local list = {
        "WHT对主人恭敬有加NOR",
        "HIC对主人忠于职守NOR",
        "HIC对主人尽职尽责NOR",
        "GRN对主人忠心耿耿NOR",
        "GRN对主人忠心不二NOR",
        "YEL对主人赴汤蹈火NOR",
        "YEL与主人生死与共NOR",
    }

    local lv = self:getFidelityLv(fidelity) --忠诚度等级
    return list[lv]
end

--获取忠诚度等级
function HomelandRoleUtil:getFidelityLv(fidelity)
    if fidelity == nil then
        return
    end
    local lv = 0

    local list = {
        {value = 0, lv = 1},
        {value = 200, lv = 2},
        {value = 500, lv = 3},
        {value = 800, lv = 4},
        {value = 1200, lv = 5},
        {value = 1800, lv = 6},
        {value = 2700, lv = 7}
    }
    for i, v in ipairs(list) do
        if fidelity >= v.value then
            lv = v.lv
        else
            break
        end
    end
    return lv
end

--获取对应等级所需的忠诚度
function HomelandRoleUtil:getFidelityByLv(lv)
    if lv == nil then
        return
    end

    if lv > 7 then
        return 4000
    end

    local value = 0

    local list = {
        {value = 0, lv = 1},
        {value = 200, lv = 2},
        {value = 500, lv = 3},
        {value = 800, lv = 4},
        {value = 1200, lv = 5},
        {value = 1800, lv = 6},
        {value = 2700, lv = 7}
    }
    for i, v in ipairs(list) do
        if lv == v.lv then
            value = v.value
            break
        end
    end
    return value
end

--@desc: 根据人物获取忠诚度等级
--@author:Liang SongQiang
--@time:2018-06-08 20:00:42
--@map:[src.app.models.map.BaseMap#BaseMap]
--@roleId: 人物ID
function HomelandRoleUtil:getFidelityLvByRoleId(map, roleId)
    local role = map:getRole(roleId)
    return self:getFidelityLv(role.defaultZhongCheng)
end

--忠诚度增长
--参数:增长忠诚度
function HomelandRoleUtil:updateFidelity(fidelity,currRole)
    if fidelity == nil or currRole == nil then
        return
    end
    currRole.defaultZhongCheng = fidelity

    self:setHomeLandRoleData(currRole.jobType,fidelity)
end

--解锁人物特性
function HomelandRoleUtil:DeblockRoleTrait(role,traits)
    if MapIsEmpty(traits) then
        return
    end
    for k, v in pairs(traits) do
        role[k] = v
    end
end


--@desc 更新人物功能
function HomelandRoleUtil:updateRoleFunc(role,map)
    --@RefType [src.app.models.HomelandModel.HomelandRoleModel.HomelandRoleTemplate#HomelandRoleTemplate]
    local HomelandRoleTemplate = require("app.models.HomelandModel.HomelandRoleModel.HomelandRoleTemplate")
    HomelandRoleTemplate:unlockRoleFunc(role,map)
    if not self:checkRoleIsInRightRoom(role,map ) then
        HomelandRoleTemplate:closeSpecialFunc(role)
    end  
    HomelandRoleTemplate:initByStatus(role)
end



--获取人物类型配表
--type 人物类型
function HomelandRoleUtil:getRoleTypeData(type)
    for k, v in pairs(roleTypeList) do
        if v.peopletYpe == type then
            return v
        end
    end
end

function HomelandRoleUtil:getRandomCharacterId()
    local dsc = ""
    local xinggeList = {
        "xingge001",
        "xingge002",
        "xingge003",
        "xingge004",
        "xingge005",
        "xingge006",
        "xingge007",
        "xingge008",
        "xingge009",
        "xingge010",
    }
    local characterId = xinggeList[math.random(1, #xinggeList)]
    return characterId
end
--获取职业对应的agelist,sexlist,texinglist,looklist
function HomelandRoleUtil:getAttrList(type)
	local data = self:getRoleTypeData(type)
	local agelist,sexlist,texinglist ,looklist,lifelist= {},{},{},{},{}

	if data then
		agelist = string.split(data.ages,";")
		sexlist = string.split(data.sexs,";")
		texinglist = string.split(data.specialrand,";")
		looklist = string.split(data.looks,";")
        lifelist = string.split(data.randlife,";")
	end
	return agelist,sexlist,texinglist,looklist,lifelist
end

-- 获取符合特点值要求的特点
-- value 特点值
function HomelandRoleUtil:getTexingList(value)
	local list = {}
	for k,v in pairs(texingMap) do
		if v.Characteristicneed and v.Characteristicneed <= value then
			table.insert(list,v.Characteristicid)
		end	
	end
	return list
end

--获取特点资源配表
function HomelandRoleUtil:getTexingMap(trait)
    if trait == nil then
        return
    end

    return texingMap[trait]
end

--@desc:获取管家初始特点个数
-- 5%概率出现1个初始特点，5%*5%出现2个初始特点，5%*5%*5%出现三个初始特点。
function HomelandRoleUtil:getTexingCount()
	local count = 0
	if 125 >= math.random(1,1000000) then
		count = 3
	elseif 25 >= math.random(1,10000) then
		count = 2
	elseif 5 >= math.random(1,100) then
		count = 1
	end
	return count
end

--获取人物性格资源配表
function HomelandRoleUtil:getCharacterAttr(characterId)
    if characterId == nil then
        return
    end

    local attr = characterList[characterId]

    if DEBUG_MODE == 1  then
        assert(attr,"getCharacterAttr is nil , characterId :".. characterId)
    end

    return characterList[characterId]
end

--获取人物性格系数表
function HomelandRoleUtil:getCharacterFactor(jobType)
    for k, v in pairs(characterFactorList) do
        if v.charactertype == jobType then
            return v
        end
    end

    if DEBUG_MODE == 1 then
        assert(false,"getCharacterFactor is nil , jobType :"..jobType)
    end
end

--生成人物描述
function HomelandRoleUtil:createRoleDsc(role)
    local roleDsc = ""
    local jobstr = self:getCHAJobTypeName(role.jobType)
    local characterStr = self:getCHAXingGeName(role.character)
    local fidelityStr = self:getGuanJiaFidelity(role.defaultZhongCheng)

    local namestr = "他"
    if role.sex == "女" then
        namestr = "她"
    end
    roleDsc = namestr .. "是一名" .. jobstr .. "，" .. characterStr .. "，" .. fidelityStr .. "。"

    return roleDsc
end

--初始化人物
function HomelandRoleUtil:initHomelandMapRole(roleinfo,map)
	local roleAttr = {}
	if roleinfo.job then
        roleinfo.jobType = roleinfo.job
    end 
    local roleAttr = table.mergeMap(roleinfo, self:getMobanRoleAttr(roleinfo.modal))
    local role = clone(roleAttr)
    role.canSee = true
    role.type = "role"
    role.id = role.rwId
    role.dsc = self:createRoleDsc(role)
    role.cType = self:getCHAJobTypeName(role.jobType)

    self:initMapRoleNameByJobtypeAndZcLv(role)
    
    -- Npc:initRoleWithRandomAttr(role)
    -- Map:initNpcEquipsAndItems(role)
    -- Map:initNpcActiveZhao(role)
    Npc:initNpc(role)

    role = Helper:tableCover(Role:create(), role)

    role:updateRoleBuff()

    --@desc 2019-03-18 11:30:14 去除服务器技能数据。
    -- self:initSkillLv(role)

    local HomelandRoleTemplate = require("app.models.HomelandModel.HomelandRoleModel.HomelandRoleTemplate")
    HomelandRoleTemplate:initRoleConditions(role, map)

    return role
end

--根据模版id获取人物模版数据
function HomelandRoleUtil:getMobanRoleAttr(mobanId)
    for k, v in pairs(roleMobanList) do
        if v.mobanid == mobanId then
            return v
        end
    end
end

--获取职业中文名
function HomelandRoleUtil:getCHAJobTypeName(jobType)
    if not jobType then
        return ""
    end
    local resultTab = {
        huyuan001 = "护院",
        shutong001 = "书童",
        xiunv001 = "绣女",
        laonong001 = "老农",
        chuzi001 = "厨子",
        tiejiang001 = "铁匠",
        puren001 = "仆人",
        peilian001 = "陪练",
        guanjia001 = "管家",
        menke001 = "门客"
    }
    return Helper:getDef(resultTab[jobType], "")
end

--获取性格中文名
function HomelandRoleUtil:getCHAXingGeName(xingGe)
    if not xingGe then
        return ""
    end
    local tabs = {
        xingge001 = "沉默寡言",
        xingge002 = "内向害羞",
        xingge003 = "细心谨慎",
        xingge004 = "老实巴交",
        xingge005 = "老成练达",
        xingge006 = "热心耿直",
        xingge007 = "稳重踏实",
        xingge008 = "多愁善感",
        xingge009 = "开朗健谈",
        xingge010 = "活泼诙谐"
    }
    return Helper:getDef(tabs[xingGe], "")
end

--设置保存的人物忠诚度
--jobtype 职业
function HomelandRoleUtil:setHomeLandRoleData(jobtype, fidelity)
    print("jobtype = ", jobtype)
    print("defaultZhongCheng = ", fidelity)

    local role = User:getRole()

    local homeLandRoleData = role:getAttr("homeLandRoleData")
    if MapIsEmpty(homeLandRoleData) or homeLandRoleData[jobtype] == nil then
        return
    end

    homeLandRoleData[jobtype].defaultZhongCheng = fidelity
end

--@desc: 闯门进入后 仆人门客的处理
--@author:Liang SongQiang
--@time:2018-06-19 01:34:03
--@map:[src.app.models.map.BaseMap#BaseMap]
--@npc: [src.app.models.role.Role#Role]
function HomelandRoleUtil:aftIntrude(map, npc)

    --仆人特性
    local odds = math.random( 1,100 )
    if npc:getBuffAttr("passiveFight") > 0 and npc:getBuffAttr("passiveFight") >= (odds/100) then
        return
    end

    local handlerMap = {
        ["仆人"] = function(npc)
            local rand = math.random(1, 100)

            if rand <= 60 then
                npc.fightMark = true
            end
        end,
        ["门客"] = function(npc)
            npc.fightMark = true
        end,
        ["护院"] = function(npc)
            npc.fightMark = true
        end
    }

    local cType

    if npc.cType ~= "门客" and npc.cType ~= "护院" then
        cType = "仆人"
    else
        cType = npc.cType
    end

    if handlerMap[cType] then
        handlerMap[cType](npc)
    else
        assert(false, "此处有bug")
    end
end

--根据房间类型获取人物类型资源配表
function HomelandRoleUtil:getRoleTypeDataByRoomType(roomType)
    for k, v in pairs(roleTypeList) do
        if v.roomtyPe == roomType then
            return v
        end
    end
end

--修改任务属性
function HomelandRoleUtil:updataRoleAttr(mid, up_data)
    HttpManagerEx:updateEmployeeExtra(
        mid,
        up_data,
        function(status, errcode, errmsg, data)
            if status == 200 then
                if errcode == 0 then
                else
                    PopText(errmsg)
                end
            else
                PopText(errmsg)
            end
        end,
        IS_SHOW_WAITING
    )
end

--[[extra = {
    naoshi = 0 正常 ，1闹事 
    都为1处于闹事状态
}]]
--获取人物当前状态
function HomelandRoleUtil:getRoleCurrStatus(role)
    assert(role, "HomelandRoleUtil:getRoleCurrStatus 参数出错")
    local currStatus = ""
    local extra = role.extra
    if extra == nil then
        return "正常"
    end
    if extra.naoshi == 1 then
        currStatus = "闹事"
    else
        currStatus = "正常"
    end
    return currStatus
end

--判断当前副本是否有管家
function HomelandRoleUtil:currMapHaveGj(map)
    assert(map, "HomelandRoleUtil:currMapHaveGj 参数出错")
    local gjCount = map:getPersonTypeCount("guanjia001")

    if gjCount > 0 then
        return true
    end
    return false
end

--@desc: 更新仆人数量
--@author:Liang SongQiang
--@time:2018-06-21 11:40:48
function HomelandRoleUtil:updateServantCount(map)
    local role = User:getRole()
    local fq = role:getHomelandAttr("fq")

    if not fq then
        if DEBUG_MODE == 1 then
            assert(false, "没有房契，不应该调用这个接口（HomelandRoleUtil:updateServantCount），检查代码")
        end
        return
    end

    local servantCount = 0
    for k, v in pairs(map:getRoles()) do
        if v.type == "role" and v.jobType ~= nil and v.jobType ~= "" then
            servantCount = servantCount + 1
        end
    end

    local roleservantCount = role:getHomelandAttr("prnum")
    if roleservantCount ~= servantCount then
        role:setHomelandAttr("prnum",servantCount)
    end
end

--@desc: 增加仆人数量
--@author:Liang SongQiang
--@time:2018-06-21 11:44:24
function HomelandRoleUtil:addServantCount(num)
    --@RefType [src.app.models.role.Role#Role]
    local role = User:getRole()

    local fq = role:getHomelandAttr("fq")

    if not fq then
        if DEBUG_MODE == 1 then
            assert(false, "没有房契，不应该调用这个接口（HomelandRoleUtil:updateServantCount），检查代码")
        end
        return
    end

    local prNum = role:getHomelandAttr("prnum") + num

    role:setHomelandAttr("prnum",prNum)
end

--@desc: 判断人物是否在对应房间，如果不是，则关闭所有功能
--@author:Liang SongQiang
--@time:2018-06-21 17:47:48
--@map: [src.app.models.map.BaseMap#BaseMap]
function HomelandRoleUtil:roleIsInCurrRoom(map,role)
    local res = self:getRoleTypeData(role.jobType)

    local roomTypeList = string.split(res.roomtyPe or "",";")
    if MapIsEmpty(roomTypeList) then
        return true
    end

    if role.jobType == "guanjia001" then
        return true
    end

    local currRoom = map:getRoomAttr(role.fjId)
    
    local currRoomType = currRoom.roomType

    local isRight = false

    for i,r_room_type in ipairs(roomTypeList) do
        if currRoomType == r_room_type then
            isRight = true
        end
    end

    return isRight
end


--@desc 记录需保留的仆人信息
function HomelandRoleUtil:recordEmployData(objId, employData)
    --保存雇佣人物的忠诚度和名字
    --@RefType [src.app.models.role.Role#Role]
    local role = User:getRole()

    local roleData = Helper:getDef(role:getAttr("homeLandRoleData"), {})

    local tb = {
        ["shutong001"] = {
            readTime = 0
        },
        ["guanjia001"] = {},
        ["tiejiang001"] = {}
    }

    if not tb[employData.jobType] then
        return
    end

    roleData[employData.jobType] = {
        id = objId,
        name = employData.name,
        defaultZhongCheng = employData.defaultZhongCheng
    }

    for k, v in pairs(tb[employData.jobType]) do
        roleData[employData.jobType][k] = v
    end

    role:setAttr("homeLandRoleData", roleData)
end

--@desc: 删除人物时清除人物记录信息。
--@author:Liang SongQiang
--@time:2018-06-25 15:51:30
function HomelandRoleUtil:clearEmployData(objId, jobType)
    --保存雇佣人物的忠诚度和名字
    --@RefType [src.app.models.role.Role#Role]
    local role = User:getRole()

    local roleData = role:getAttr("homeLandRoleData")

    if MapIsEmpty(roleData) then
        return
    end

    if roleData[jobType] and roleData[jobType].id == objId then
        roleData[jobType] = nil
    end

    if jobType == "tiejiang001" then
        role:setInheritFlag("铁匠入驻玄兵洞",2)
    end
    role:setAttr("homeLandRoleData", roleData)
end

-- --@desc: 判断铁匠是否需要入驻神兵界面
-- --@author:Liang SongQiang
-- --@time:2018-06-25 16:03:05
-- function HomelandRoleUtil:tieJiangInShenBingMain(role, map)
--     if not map:isUserMap() then
--         return
--     end

--     --@RefType [src.app.models.role.Role#Role]
--     local player = User:getRole()

--     if player:getInheritFlag("可进入苏州水底") ~= 1 or player:getInheritFlag("开始神兵任务") < 2 then
--         return
--     end

--     if role.jobType ~= "tiejiang001" then
--         return
--     end

--     local lv = self:getFidelityLv(role.defaultZhongCheng)
--     if lv < 7 then
--         return
--     end

--     local h_role_data = player:getAttr("homeLandRoleData")

--     if MapIsEmpty(h_role_data) or h_role_data["tiejiang001"] == nil or player:getInheritFlag("铁匠入驻玄兵洞") == 1 then
--         return
--     end

--     local random = math.random(0, 100)

--     if random <= 30 then
--         local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")

--         --@RefType [src.app.views.layer.DialogLayer.DialogALayer#DialogALayer]
--         local dialog = DialogALayer:getInstance()

--         dialog:show(role.name.."：听说您寻得个玄兵古洞，那里非常适合锻造兵器，不知可否让我驻入其中")

--         dialog:setWeChatVisible(false)
--         dialog:setBack(false)

--         dialog:setButton1("确定",function ()
--             player:setInheritFlag("铁匠入驻玄兵洞",1)
--             player:setAttr("homeLandRoleData",h_role_data)
--             RichPrint("main","你让"..role.name.."入驻了玄兵古洞，原来的铁匠已经去往苏州城铁匠铺了。")
--         end)

-- 		dialog:setButton2("取消", function()
-- 			dialog:hide()
-- 		end)
--     end
-- end

--@desc:检查人物是不是在对应房间，如果不是，不允许进行特殊操作 
--@author:Liang SongQiang
--@time:2018-06-28 22:29:59
--@role:[src.app.models.role.Role#Role]
--@map:[src.app.models.map.BaseMap#BaseMap]
--@roomId: 房间ID
function HomelandRoleUtil:checkRoleInRoomAction(role,map)
    local HomelandRoleTemplate = require("app.models.HomelandModel.HomelandRoleModel.HomelandRoleTemplate")
    
    if self:checkRoleIsInRightRoom(role,map) then
        self:updateRoleFunc(role,map)
        return
    end

    HomelandRoleTemplate:closeSpecialFunc(role)
end

function HomelandRoleUtil:checkRoleIsInRightRoom( role,map )
    local res = self:getRoleTypeData(role.jobType)

    if not res.roomtyPe then
        return true
    end

    local currRoom = map:getRoomById(role.fjId)
    if currRoom.roomType ~= res.roomtyPe then
        return false
    end

    return true
end


--根据职业和忠诚度等级初始化人物名字
function HomelandRoleUtil:initMapRoleNameByJobtypeAndZcLv(role)
       --初始化管家name
    switch(role.cType,{
        ["管家"] = function()
            role.realName = role.name
            role.name = Helper:getXingByName(role.name).."管家"
        end,

        default = function()
            local lv = self:getFidelityLv(role.defaultZhongCheng)
            role.realName = role.name
            role.name = role.cType

            if lv >=6 then
                role.name = role.realName
                role.realName = nil
            end
        end,
    })

end

--获取人物随机身世
function HomelandRoleUtil:getMapRoleRandomShenShi(trimShenshiList,jobType)
    assert(jobType,"HomelandRoleUtil:getMapRoleRandomShenShi")

    local currCanSelectShenShiList = self:getRandLifeListByJobType(jobType)
    local shenShiId = ""
    local tab = {}
    local tab1 = {}
    if MapIsEmpty(trimShenshiList) then
        shenShiId = currCanSelectShenShiList[math.random( 1,#currCanSelectShenShiList)]
        return shenShiId 
    end

    for i,v in ipairs(trimShenshiList) do
        for index ,ssid  in ipairs(currCanSelectShenShiList) do 
            if v == ssid then
                table.insert(tab,ssid)
            end
        end
    end
    if MapIsEmpty(tab) then
        shenShiId = currCanSelectShenShiList[math.random( 1,#currCanSelectShenShiList)]
        return shenShiId
    end

    for i,v in ipairs(tab) do 
        tab1[v] = true
    end

    local currCanSelect = clone(currCanSelectShenShiList) 

    for i = #currCanSelect,1,-1 do
        if tab1[currCanSelect[i]] == true then
            table.remove(currCanSelect,i)
        end
    end

    if MapIsEmpty(currCanSelect) then
        if DEBUG_MODE == 1 then
            assert(false,"HomelandRoleUtil:getMapRoleRandomShenShi 策划身世资源不够，无法随机获取不同的身世")
        end

        return false
    end

    shenShiId = currCanSelect[math.random( 1,#currCanSelect)]

    return shenShiId
end

--初始化上传服务器的人物技能
function HomelandRoleUtil:getUploadWebRoleSkillArray(modal)
    assert(modal,"HomelandRoleUtil:initUploadWebRoleSkill 检查参数")
    local role = self:getMobanRoleAttr(modal)
    local tab = {}

    for i = 1,20 do
		if role["skill"..i] and role["skillLv"..i] then
            local skillName = role["skill"..i]
            print("skillName = ",skillName)
            local skillLv = role["skillLv"..i]
            
            tab[skillName] = skillLv
		end
	end

    return tab
end

--获取人物忠诚成长度和离开天数
function HomelandRoleUtil:getSpeedZhongChengAndLeaveDay(jobType,character)
    assert(jobType and character,"HomelandRoleUtil:getSpeedZhongCheng 检查参数")
    local characterFactorList = self:getCharacterFactor(jobType)

    if characterFactorList == nil then
        assert(false,"没有找到职业对应的性格系数，检查资源familyspecial[\"career\"] 职业:"..jobType)
    end
    
    local dailyupZhongcheng = characterFactorList.Dailyup1
    local leaveDay = characterFactorList.leave1

    local characterAttr = self:getCharacterAttr(character)

    if characterAttr == nil then
        assert(false,"没有找到职业对应的性格系数，检查资源familyspecial[\"character\"] 性格:"..character)
    end

    local dailyupZhongcheng1 = characterAttr.Dailyup
    local leaveDayFactor = characterAttr.leave

    local speedZhongCheng = dailyupZhongcheng*dailyupZhongcheng1
    local leave_day = leaveDay*leaveDayFactor

    return speedZhongCheng ,leave_day
end



--初始化技能等级
function HomelandRoleUtil:initSkillLv(role)
    local temp = role.mobanSkill
    if MapIsEmpty(temp) then
        return
    end
    local count = 1 

    for k, v in pairs(temp) do
        role["skill"..tostring(count)] = k
        role["skillLv"..tostring(count)] = v + self:getAddSkillLvBuff(role,k)
        count = count +1
    end

   
end

--获取提升技能等级buff
function HomelandRoleUtil:getAddSkillLvBuff(npc,skillName)
    local skillNameList = {
        jibenquanjiao = "jibenquanjiaoLv",
        jibenjianfa = "jibenjianfaLv",
        jibendaofa = "jibendaofaLv",
        jibenanqi = "jibenanqiLv",
        jibengunfa = "jibengunfaLv",
        jibenbianfa = "jibenbianfaLv",
    }
    if skillNameList[skillName] == nil then
        return 0
    end

    local addLv = npc:getBuffAttr(skillNameList[skillName])
    
    return addLv
end

--判断是否完成身世事件
function HomelandRoleUtil:isFinishLiftEvent(role)
    local extra = role.extra
    if MapIsEmpty(extra) then
        return false
    end
    local shenshiStatus = extra.shenshi_status

    if shenshiStatus and shenshiStatus == 3 then
        return true
    end

    return false
end

--根据职业获取对应的身世列表
function HomelandRoleUtil:getRandLifeListByJobType(jobType)
    assert(jobType,"HomelandRoleUtil:getRandLifeListByJobType 检查参数")

    local data = self:getRoleTypeData(jobType)
	local lifelist= {}

	if MapIsEmpty(data) then
        return lifelist
    end

    lifelist = string.split(data.randlife,";")
	
	return lifelist
end

--获得赏赐时概率获得的道具
function HomelandRoleUtil:getItemInReward(npc,map)
    if npc == nil then
        return
    end
    
    local role = User:getRole()
    
    local odds = npc:getBuffAttr("shangciItemProbobility")
    if odds < math.random( 1,100)/100 then
        return
    end
    
    local rewardList = {
        {   
            id = "dundifu",
            count = 1 
        },
        {   
            id = "fenshenfu",
            count = 1 
        },
        {   
            id = "jingxinwan",
            count = 2 
        },
    }

    local resultReward =  rewardList[math.random(1,#rewardList)]
    local itemId = resultReward.id
    local count = resultReward.count
    
    --判断背包空间
    if not role:checkCanBuyTwoOrMoreThings({[itemId] = count}) then
        local currRoomId = map:getCurrRoomId()
        map:dropItem(currRoomId,itemId,count)
        map.__MapLayer:delayRefreshMap()
        return
    end

    local itemAttr = Item:getOneItemByKey(itemId)

    role:addItemCount(itemId,count)
    PopText("获得"..itemAttr.name.."X"..count)
end

--@desc: NPC雇佣
--@author:Liang SongQiang
--@time:2018-07-25 20:50:58
--@employData:
--@callback: 
function HomelandRoleUtil:employeNpc( employData,callback )
    local hid = employData.hid
    local objId = employData.objId
    local mid = employData.mid
    local npcId = employData.npcId
    local push_data = employData.push_data
    HttpManagerEx:addEmployee(hid,objId,mid,npcId,push_data,function(status, errcode, errmsg, data)
        print("status = ",status)
        print("errcode = ",errcode)
        if status == 200 then
            if errcode == 0 then
                callback(data)
            else
                PopText(errmsg)
            end
        else
            PopText(errmsg)
        end
    end, IS_SHOW_WAITING)
end


--@desc: 开启仆人的相关按钮功能
--@author:Liang SongQiang
--@time:2018-08-06 16:30:37
--@role:对应处理的人物
--@resultName: 条件结果名
function HomelandRoleUtil:openRoleBtnFunc( role,resultName )
    --@RefType [src.app.models.HomelandModel.CRFactory#CRFactory]
    local CRFactory = require("app.models.HomelandModel.CRFactory")

    CRFactory:openOrCloseBtnFunc(role,resultName,"open")
end

--@desc: 关闭仆人的相关按钮功能
--@author:Liang SongQiang
--@time:2018-08-06 16:29:46
--@role:需要处理的人物
--@resultName: 条件结果名
function HomelandRoleUtil:closeRoleBtnFunc( role,resultName )
    --@RefType [src.app.models.HomelandModel.CRFactory#CRFactory]
    local CRFactory = require("app.models.HomelandModel.CRFactory")

    CRFactory:openOrCloseBtnFunc(role,resultName,"close")
end

--@RefType 创建人物描述界面展示的数据结构
--@role: [src.app.models.role.Role#Role]
function HomelandRoleUtil:createShowRoleInfo(role)
    local result = {}

    local qi = {
        panel_type = 1,
        title = "『气血』",
        desc = tostring(math.floor(role:getAttr("qi")) .. "/" .. math.floor(role:getCurrQiMax())),
        tips = "气血是健康的指标，气血越多，持续作战能力越强。"
    }

    table.insert(result, qi)

    local neili = {
        panel_type = 1,
        title = "『内力』",
        desc = tostring(math.floor(role:getAttr("neili")) .. "/" .. math.floor(role:getFinalAttr("neiliMax"))),
        tips = "内力是武功造诣的体现。内力越多，持续作战的能力越强。"
    }

    table.insert(result, neili)


    local currLv = self:getFidelityLv(role.defaultZhongCheng)
    local nextLvValue = self:getFidelityByLv(currLv + 1)
    local zc = {
        panel_type = 2,
        title = "『忠诚度』",
        desc = HomelandRoleUtil:getGuanJiaFidelity(role.defaultZhongCheng),
        value = "（"..math.floor(role.defaultZhongCheng) .. "/" .. tostring(nextLvValue).."）",
        tips = "忠诚度影响仆人的方方面面，忠诚度越高，仆人越能胜任其所从事的职业。\n忠诚度每日会自动增长。与仆人互动也会增加仆人的忠诚度。"
    }
    
    table.insert(result, zc)
    
    local xingge = {
        panel_type = 1,
        title = "『性格特征』",
        desc = HomelandRoleUtil:getCHAXingGeName(role.character),
        tips = "不同性格的仆人在与主人互动时拥有不同的表现。\n人物性格还会对忠诚度的增加产生一定影响。"
    }

    table.insert(result, xingge)

    local traits = {
        panel_type = 3,
        title = "『人物特点』",
        desc_list = {},
        tips = "人物特点影响仆人的属性，并对其从事的职业产生一定影响。\n人物特点在忠诚度等级提高时有几率获得。\n最多只会有三个特点。"
    }

    for i = 1, 3 do
        local trait = self:getTexingMap(role["trait" .. i])

        if trait then
            table.insert(traits.desc_list, trait.CharacteristicName)
        end
    end

    if not MapIsEmpty(traits.desc_list) then
        table.insert(result, traits)
    end

    local skillIngoreType = {
        ["xiunv001"] = true,
        ["laonong001"] = true,
        ["shutong001"] = true,
        ["tiejiang001"] = true,
    }

    if skillIngoreType[role.jobType] ~= true then
        local skills = {
            panel_type = 1,
            title = "『使用武学』",
            desc = "",
            tips = "与不速之客战斗时所使用的武学。"
        }

        local tab = {}
        local temp = {}
        local text = ""
        for i = 1, 20 do
            if role["skill" .. i] and not string.find(role["skill" .. i], "jiben") and temp[role["skill" .. i]] ~= true then
                table.insert(tab, role["skill" .. i])
                temp[role["skill" .. i]] = true
            end
        end
        if not MapIsEmpty(tab) then
            local skillsList = require("script.skill.skill").skills
            for i = 1, #tab do
                if skillsList[tab[i]] then
                    if i > 1 then
                        text = text .. "、" .. skillsList[tab[i]].name
                    else
                        text = skillsList[tab[i]].name
                    end
                end
            end
        end

        if text ~= "" then
            skills.desc = text
            table.insert(result, skills)
        end
    end

    if role.jobType ~= "guanjia001" then
        local price_tb = {
            panel_type = 1,
            title = "『雇佣价格』",
            desc = "",
            tips = "请留意管家处的房屋事务、及时支付薪水。如果欠薪达到一定天数，仆人也许会离你而去。"
        }
        local jobType = role.jobType
        local price = ""
        local price_unit = ""
        if role.pay_base then
            price = role.pay_base.val
            price_unit = role.pay_base.unit
        else
            price = role.price / 14
            price_unit = role.price_unit
        end
        local temp = {
            yuanbao = "元宝",
            yinpiao = "银票"
        }

        local priceStr = ""
        if price and temp[price_unit] then
            priceStr = priceStr .. math.floor(price) .. temp[price_unit] .. "/天"
        end

        price_tb.desc = priceStr

        table.insert(result, price_tb)

        local HomelandDesc = require("app.models.HomelandModel.HomelandDesc")
        local roleLife = {
            panel_type = 1,
            title = "『身世信息』",
            desc = HomelandDesc:getShenShiInFo(role),
            tips = "仆人的出身、背景。也许他（她）是一个有故事的人。"
        }

        table.insert(result, roleLife)
    end

    return result
end

--@desc 仆人离开或遣散时要做的处理
function HomelandRoleUtil:deleteRole(role)
    --@desc 清除身世任务
    --@RefType [src.app.models.HomelandModel.MapMeetModel.ShenShiTask#ShenShiTask]
    local ShenShiTask = require("app.models.HomelandModel.MapMeetModel.ShenShiTask")
    if ShenShiTask:checkCurrTaskNpc(role.id) then
        ShenShiTask:clearTask()
    end
    
    --@desc 副本门客招募时会带上传承标记，删除人物时需清除。
    local inheritFlag = role.extra.inheritFlag
    if inheritFlag then
        User:getRole():setInheritFlag(inheritFlag, nil)
    end

    --@desc 如果是门客，需清除当前门客生成的派遣任务列表
    local DispatchTaskUtils = require("app.models.HomelandModel.DispatchTaskModel.DispatchTaskUtils")
    DispatchTaskUtils:clearNpcDispatchTaskList(role.id)
end

--@desc: 解雇
--@author:Liang SongQiang
--@time:2018-09-29 11:23:55
--@map:[src.app.models.map.BaseMap#BaseMap]
--@role: [src.app.models.role.Role#Role]
function HomelandRoleUtil:firedRole( map,role,func)
    local PuRenModel = require("app.models.HomelandModel.HomelandRoleModel.PuRenModel")
    local HomelandDesc = require("app.models.HomelandModel.HomelandDesc")
    local rid = PuRenModel:getPuRenRoomId(map,role.id)
    local prName = role.realName or role.name
    if map:checkRoleIsInRoom(rid,role.id) == false then 
        if role.cType == "门客" then
            PopText("管家："..prName.."目前不在府上，"..HomelandDesc:subChengHuText("#ch#").."可待其归来之时再做决定。")
        else
            PopText("管家："..prName.."目前不在府上")
        end
        return
    end
    local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")
    local dialog = DialogALayer:getInstance()
    dialog:show("你确定要遣散"..prName.."（"..role.cType.."）吗？")
    dialog:setButton1("确定", function()
        HttpManagerEx:deleteEmployee(role.id,map.mid,function(status, errcode, errmsg, data)
            if status == 200 and errcode == 0 then
                self:deleteRole(role)
                map:addPersonJobCount(role.job,-1)
                local HomelandUtil = require("app.models.HomelandModel.HomelandUtil")
                HomelandUtil:updateRoleFlag(map)

                map:removeRoomRole(rid, role.id)
                local mapRoles = map:getRoles()
                --同时把副本人物数据删除
                mapRoles[role.id] = nil

                local text = HomelandDesc:getFiredText(role)
                RichPrint("main",text)

                PuRenModel:updateMapPuRenInfo("reduced", map, role.id, rid)

                self:updateRoleBindingFj(map,rid)

                map.__MapLayer:delayRefreshMap()

                if func then 
                    func()
                end
            else
                PopText(errmsg)
            end
        end,IS_SHOW_WAITING)
    end)
    dialog:setButton2("取消", function()
        dialog:hide()
    end)
end

--更新非当前房间人物的绑定房间
function HomelandRoleUtil:updateRoleBindingFj(map,roomId)
    if not roomId then
        return
    end
    local HomelandRoomUtil = require("app.models.HomelandModel.HomelandRoomUtil")
    local mapRole = map:getRoles()
    local currFjId = roomId
    local currRoom = map:getRoomById(currFjId)
    local currRoomType = currRoom.roomType
    local up_data = {}
    local roleTypeAttr = self:getRoleTypeDataByRoomType(currRoomType)
	if roleTypeAttr == nil then
		return
	end
	local peopletYpe = roleTypeAttr.peopletYpe

    for npcId,npc in pairs(mapRole) do
        if npc.fjId ~= currFjId and npc.type == "role" and npc.jobType == peopletYpe then
            if HomelandRoomUtil:checkRoomRolesIsLimet(currFjId,map) == false then
                local isRight = self:roleIsInCurrRoom(map,npc)
                if isRight == false then
                    map:removeRoomRole(npc.fjId,npcId,false)
                    table.insert( up_data,{rwId = npcId,fjId = currFjId,extra = {}})
                    npc.fjId = currFjId
                    map:addRoomRole(currFjId,npcId)
                    local PuRenModel = require("app.models.HomelandModel.HomelandRoleModel.PuRenModel")
                    PuRenModel:updateMapPuRenInfo("changeRoom", map, npcId, currFjId)

                    local text = "YEL"..npc.cType..(npc.realName or npc.name).."入驻了"..currRoom.name.."。NOR"
                    RichPrint("main",text)
                    
                    npc.conditionAndResults = {}
                    local HomelandRoleTemplate = require("app.models.HomelandModel.HomelandRoleModel.HomelandRoleTemplate")
                    HomelandRoleTemplate:initRoleConditions(npc, map)
                end
            end
        end
    end

    if MapIsEmpty(up_data) then
		return
	end

    self:updataRoleAttr(map.mid,up_data)
end


--根据人物职业生成objId
function HomelandRoleUtil:createObjId(jobType)
	local objId = ""

	if jobType == "guanjia001" then
		objId = "guanjia1001"
		return objId
	end
	
	local role = User:getRole()
	local MaxId = tonumber(role:getHomelandAttr("prIdIndex"))
    
    if MaxId == 0 then
        MaxId = 1000
    end

	objId = "pr_"..tonumber(MaxId)+1

	return objId
end

--免费增加忠诚度
function HomelandRoleUtil:addFidelityFree(role, map, addZc)
    HttpManagerEx:updateEmployRoleData(
        role.id,
        map.mid,
        "free",
        addZc,
        0,
        function(status, errcode, errmsg, data)
            if status == 200 then
                if errcode == 0 then
                    self:updateFidelity(data.defaultZhongCheng,role)
                    if data.level_up then
                        self:DeblockRoleTrait(role,data.trait)
                    end
                else
                    PopText(errmsg)
                end
            else
                PopText(errmsg)
            end
        end,
        IS_SHOW_WAITING
    )
end

return HomelandRoleUtil000000000