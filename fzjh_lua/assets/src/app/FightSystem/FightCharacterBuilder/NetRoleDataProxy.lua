--[[
    author:Seven
    time:2023-04-13 11:37:27
    desc:
]] local newClass = require("third.class.NewClass")

local NetRoleDataProxy = {}

function NetRoleDataProxy:create()
    return NetRoleDataProxy.new()
end

function NetRoleDataProxy:ctor()
    self.__role = User:getRole()

    self._roleData = {}

    self:__visitoRoleData()
end

function NetRoleDataProxy:__initData(data)
    self._roleData.id = data.userid .. ""
    self._roleData.userid = data.userid
    self._roleData.name = data.name
    self._roleData.sex = data.sex
    self._roleData.age = data.age
    self._roleData.looks = data.looks
    self._roleData.luck = data.luck
    self._roleData.tili = data.tili
    self._roleData.tiliMax = data.tiliMax
    self._roleData.str = data.str
    self._roleData.int = data.int
    self._roleData.con = data.con
    self._roleData.dex = data.dex
    self._roleData.secStr = data.secStr
    self._roleData.secInt = data.secInt
    self._roleData.secCon = data.secCon
    self._roleData.secDex = data.secDex
    self._roleData.currStr = data.currStr
    self._roleData.currInt = data.currInt
    self._roleData.currCon = data.currCon
    self._roleData.currDex = data.currDex
    self._roleData.jiaLi = data.jiaLi
    self._roleData.fenpei = data.fenpei
    self._roleData.fenpeiList = data.fenpeiList
    self._roleData.jing = data.jing
    self._roleData.qi = data.qi
    self._roleData.qiMax = data.qiMax
    self._roleData.qiPercent = data.qiPercent
    self._roleData.neili = data.neili
    self._roleData.neiliMax = data.neiliMax
    self._roleData.exp = data.exp
    self._roleData.pot = data.pot
    self._roleData.money = data.money
    self._roleData.gold = data.gold
    self._roleData.lv = data.lv
    self._roleData.weight = data.weight
    self._roleData.ckLimit = data.ckLimit
    self._roleData.zhengqi = data.zhengqi
    self._roleData.kill = data.kill
    self._roleData.yueli = data.yueli
    self._roleData.killPlayer = data.killPlayer
    self._roleData.weiwang = data.weiwang
    self._roleData.dead = data.dead
    self._roleData.meili = data.meili
    self._roleData.deadReason = data.deadReason
    self._roleData.jindu = data.jindu
    self._roleData.lunhui = data.lunhui
    self._roleData.mengjing = data.mengjing
    self._roleData.panshi = data.panshi
    self._roleData.guanqiaLimit = data.guanqiaLimit
    self._roleData.species = data.species
    self._roleData.dsc = data.dsc
    self._roleData.inheritCount = data.inheritCount
    self._roleData.title_type = data.title_type
    self._roleData.title_id = data.title_id
    self._roleData.inherit = data.inherit
    self._roleData.family = data.family
    self._roleData.teacherName = data.teacherName
    self._roleData.teacherId = data.teacherId
    self._roleData.skills = data.skills -- 角色的所有技能
    self._roleData.skillPrepare = data.skillPrepare -- 角色当前准备的技能列表
    self._roleData.activeZhaos = data.activeZhaos -- 角色学会的所有主动招式
    self._roleData.preparedActiveZhao = data.preparedActiveZhao -- 角色准备的主动招式（有兵器和拳脚之分）
    self._roleData.preparedZhaos = data.preparedZhaos -- 暂时没用到
    self._roleData.equips = data.equips
    self._roleData.portrait = data.portrait
    self._roleData.prepareWeapon = data.prepareWeapon
    self._roleData.meridian = data.meridian
    -- 经脉经验
    self._roleData.meridianExp = data.meridianExp
    -- 真气值
    self._roleData.breathVal = data.breathVal
    -- 经脉印记
    self._roleData.m_meridianImprintings = data.m_meridianImprintings
    -- 左右互搏熟练度
    self._roleData.leftRightFightExp = data.leftRightFightExp
    self._roleData.borderVer = data.borderVer
    self._roleData.borderShowList = clone(data.borderShowList)

    self._roleData.items = {}
    self._roleData.shenBingItems = {}

    local shenbings = {}
    local itemIsAdd = {}
    for i, item in ipairs(data.items) do
        if not itemIsAdd[item.id] and item.type == "神兵" then
            table.insert(shenbings, item)
            itemIsAdd[item.id] = true
            table.insert(self._roleData.items, item)
        end

        if not itemIsAdd[item.id] and data.prepareWeapon and data.prepareWeapon.id == item.id then
            itemIsAdd[item.id] = true
            table.insert(self._roleData.items, item)
        end
    end

    for __, shenbing in ipairs(shenbings) do
        for i, v in ipairs(data.shenBingItems) do
            if v.id == shenbing.itemId then
                table.insert(self._roleData.shenBingItems, v)
            end
        end
    end

    for k, v in pairs(data.equips) do
        for i, item in ipairs(data.items) do
            if not itemIsAdd[item.id]and item.id == v.id then
                itemIsAdd[item.id] = true
                table.insert(self._roleData.items, item)
            end
        end 
    end


    -- 易容术数据
    self._roleData.polymorph = data.polymorph
    self._roleData.poison = data.poison
    self._roleData.xingzhen = data.xingzhen
    self._roleData.AsleepBuff = data.AsleepBuff -- 入梦buff
    self._roleData._roleBuff = data._roleBuff
    self._roleData.officialType = data.officialType -- 官职类型
    self._roleData.officialAchievement = data.officialAchievement -- 政绩
    self._roleData.titles = data.titles -- 额外称号
    self._roleData.yueKaValid = data.yueKaValid -- 是否拥有月卡
    self._roleData.appearance = data.appearance
    -- 自创武学系统
    self._roleData.selfCreatedSkillData = data.selfCreatedSkillData
    -- @desc 武学突破数据
    self._roleData.skillBreakData = data.skillBreakData
    -- @desc 招式突破数据
    self._roleData.zhaoBreakData = data.zhaoBreakData
    -- 新的主动技能准备表
    if data._activeZhaoPrepareMap then
        self._roleData._activeZhaoPrepareMap = data._activeZhaoPrepareMap
    end
end

function NetRoleDataProxy:__visitoRoleData()
    self.__role:updateActiveZhaoStatus()
    -- 拳脚系统pvp数据初始化
    local fistFootSystem = self.__role:getFistFootSystem()
    local fistFootSystemPVPInfo = fistFootSystem:serializationForPVP()
    self._roleData.fistFootSystemPVPInfo = fistFootSystemPVPInfo

    -- 师门系统pvp数据初始化
    local teacherBuildSystem = self.__role:getTeacherBuildSystem()
	local teacherBuildSystemPVPInfo = teacherBuildSystem:serializationForPVP()
	self._roleData.teacherBuildSystemPVPInfo = teacherBuildSystemPVPInfo
    
    self.__role:roleSaveDataVisitor(self)
end

function NetRoleDataProxy:visitRoleData(data)
    self:__initData(data)
end

function NetRoleDataProxy:getRoleData()
    return self._roleData
end

return newClass("NetRoleDataProxy", {}, NetRoleDataProxy)
0