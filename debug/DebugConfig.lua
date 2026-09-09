local DebugConfig = {
    __roleType = 0
}

local normalUserGMConfig = {
    ["返回"]  = 1,
    ["玩家信息修改"]  = 1,
    ["武学相关"]  = 1,
    ["修改玩家武学"]  = 1,
    ["设置玩家技能经验"]  = 1,
    ["设置玩家技能等级"]  = 1,
    ["增加玩家技能经验"]  = 1,
    ["挑战副本"]  = 1,
    ["恢复轶闻值"]  = 1,
    ["武学突破"]  = 1,
    ["修改玩家主动技能"] = 1,
    ["指定武学增加经验值"] = 1,
    ["设置招式熟练度"] = 1,
    ["货币和服务器道具相关"] = 1,
    ["一键增加武学突破相关货币各1000"] = 1,
    ["一键增加招式突破相关道具各1000"] = 1,
    ["拳脚系统"]  = 1,
    ["增加固身元气点数"] = 1,
    ["新版练功相关"]  = 1,
    ["恢复指定心神值"]  = 1,
    ["回满心神值"]  = 1,
    ["修改物品"] = 1,
    ["清空背包物品"]  = 1,
    ["经脉系统"]  = 1,
    ["20250306隐脉功能测试"] = 1,
    ["清除隐脉数据(清除后重启)"] = 1,
    ["修改隐脉图等级(修改后重启)"] = 1,
    ["修改养真丹数量(负数为减)"] = 1,
    ["获取玄络(多个用#隔开)"] = 1,
    ["增加真气值100000"]  = 1,
    ["经脉重置"]  = 1,
    ["增加经脉经验 1000"]  = 1,
    ["经脉印记"]  = 1,
    ["获取所有经脉印记"]  = 1,
    ["清空经脉印记"]  = 1,
    ["游戏检测相关"]  = 0,
    ["重置玩家大侠成长之路进度"]  = 0,
    ["神兵模板"]  = 0,
    ["快速完成拳脚系统前置任务"]  = 0,
    ["添加拳脚系统开启标记"]  = 0,
    ["清楚拳脚系统开启标记"]  = 0,
    ["添加修行任务解锁标记"]  = 0,
    ["删除修行任务解锁标记"]  = 0,
    ["锻体经验调整"]  = 0,
    ["添加回复心神道具（包含4个系列）"]  = 0,
    ["游戏时间设定"]  = 0,
    ["新版战斗相关"]  = 0,
    ["自创武学相关"]  = 0,
    ["汇字天成令牌添加"]  = 0,
    ["梦境相关"]  = 0,
    ["南柯梦境相关"]  = 0,
    ["充值相关"]  = 0,
    ["充值"]  = 0,
    ["传承相关"]  = 0,
    ["师门版本"]  = 0,
    ["家园相关"]  = 0,
    ["进京赶考"]  = 0, 
    ["官员系统"]  = 0, 
    ["周年庆"]  = 0, 
    ["黑市商人"]  = 0, 
    ["冥币商人"]  = 0, 
    ["功绩相关"]  = 0, 
    ["银票商人"]  = 0, 
    ["周年礼券商人"]  = 0, 
    ["香囊商人"]  = 0, 
    ["续卷回收商人1"]  = 0, 
    ["续卷回收商人2"]  = 0, 
    ["选择信商人"]  = 0, 
    ["书籍系统"]  = 0, 
    ["副本功能"]  = 0, 
    ["拜访任务"]  = 0, 
    ["属性相关"]  = 0, 
    ["任务相关"]  = 0, 
    ["头衔相关"]  = 0, 
    ["拜年送礼"]  = 0, 
    ["七夕任活动"]  = 0, 
    ["内挂相关"]  = 0, 
    ["江湖历练"]  = 0, 
    ["走穴十四经"]  = 0, 
    ["H5开关"]  = 0, 
    ["存档保存方式相关"]  = 0, 
    ["技能武学相关"]  = 0, 
    ["记录系统"]  = 0, 
    ["拉吧活动"]  = 0, 
    ["特殊时间记录"]  = 0, 
    ["临时测试"]  = 0, 
    ["按键列表"]  = 0,
    ["修改人物属性"]  = 1,
    ["修改门派"] = 1,
    ["师门日常建设相关"] = 1,
    ["个人功绩修改"] = 1,
    ["贡献昌盛度修改"] = 1,
    ["门派昌盛度修改"] = 1,
    ["资历数量修改"] = 1,
}

local normalUserBtnConfig = {
    ["Button_gonggao"] = 1,
	["Button_gonggao_history"] = 0,
	["Button_fight"] = 0,
	["Button_GM"] = 0,
	["Button_newtest"] = 0,
	["Button_restartGame"] = 0,
	["Button_inherit"] = 0,
	["Button_key"] = 0,
	["Button_edit_attr"] = 0,
	["Button_debug_mode"] = 0,
	["Button_print_mode"] = 0,
    ["Button_newFuncTest"] = 0,
}

function DebugConfig:getBtnConfig()
    if self:checkIsAdminRole() then
        return
    end

    return normalUserBtnConfig
end

function DebugConfig:checkGMIsOpen(orderName)
    if self:checkIsAdminRole() then
        return true
    end

    self:__initGM()

    local isOpen = false
    if normalUserGMConfig[orderName] == 1 then
        isOpen = true
    end

    return isOpen
end

-- 1 内部账号 2 玩家账号
function DebugConfig:setRoleType(type) 
    self.__roleType = tonumber(type)
end

function DebugConfig:checkIsAdminRole()
    return self.__roleType == 1
end

function DebugConfig:__initGM()
    if self.__GMIsInit ~= true then
        self:__addMeridianGM()
        self:__addChangeFamilyId()
        self:__addRoleAttrGM()
        self.__GMIsInit = true
    end
end

function DebugConfig:__addMeridianGM()
    local Meridian = require("app.models.Meridian.Meridian")
    local meridians = Meridian:getImprinting()
    for k, v in pairs(meridians) do
        local GMName1 = "添加" .. v.name
        local GMName2 = "移除" .. v.name
        normalUserGMConfig[GMName1] = 1
        normalUserGMConfig[GMName2] = 1
    end
end

function DebugConfig:__addChangeFamilyId()
    local Family = require("app.models.family.Family")
    local familys = Family:getFamilys()
    local nameList = {}
    for k, v in pairs(familys) do
        if not nameList[v.name] then
            normalUserGMConfig[v.name] = 1
            nameList[v.name] = true
        end
    end
end

--经验、潜能、金钱、臂力、悟性、根骨、身法、正气值、容貌、疲倦值、精力
function DebugConfig:__addRoleAttrGM()
    local attrList = {"exp","pot","money","str","int","con","dex","zhengqi","looks","jing","pijuan"}
    for i = 1, #attrList, 1 do
        local name = User:getRole():getCHAttrName(attrList[i])
        normalUserGMConfig[name] = 1
    end
end

return DebugConfig