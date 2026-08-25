local User = {
    role = nil -- 当前角色
}

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 初始化user
function User:init()
    self:load()
end

-- 设置角色
function User:setRole(role)
    self._role = role
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 获得用户id
function User:getUserId()
    local RoleData = DataBase:getRoleData()
    local userid = nil
    if type(RoleData) == "table" then
        userid = Helper:getDef(RoleData.userid, -1)
        if userid <= 0 then
            userid = -1
        end
    else
        userid = 0
    end
    return userid
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/01/16 11:57:57
-- @desc 获取账户ID
function User:getAccountId()
    local RoleData = DataBase:getRoleData()
    return Helper:getRange(Helper:getDef(RoleData.accountId, 0), 0)
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 载入
function User:load()
    self:loadRole()
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 保存
function User:save()
    if IS_ABLE_TO_SAVE_DATA == true then
        local role = User:getRole()
        if role and role.userid and role.userid > 0 then
            self:saveRole()
        end
    else
    end
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 载入角色
function User:loadRole()
    local Role = require("app.models.role.Role")
    self._role =
        createSafeTable(
        "player",
        Role.new(),
        function(role, valueName, valueFrom, valueTo)
            Collection:memoryCheat(role.userid, valueName, valueFrom, valueTo)
        end,
        {
            ["userid"] = true, -- 防止修改
            ["neili"] = true -- 防止修改
        }
    )

    local roleData = DataBase:getRoleData()

    Helper:tableCover(self._role, roleData)
    
    self._role.id = "wanjia"
    
    self._role:init()

    self._role:getSelfCreatedSkillSystem():updataSelfCreatedSkillMap()
    
    self:againstCheating()
    
    -- 数据修复
	print("repairUserData repairUserData repairUserData")
	self._role:repairUserData()

    local encryptMap = {
        -- "shenBingweapon",               -- add by XiaoZhiWei 2017/08/21 10:46:30 神兵属性
        "fenpeiList", -- add by XiaoZhiWei 2017/08/21 10:47:21 属性分配列表
        "inherit", -- add by XiaoZhiWei 2017/08/21 10:48:48 传承者属性
        -- "mapNpcAttrModify",             -- add by XiaoZhiWei 2017/08/21 10:49:52 佣兵属性
        "meridian.attrTotal", -- add by XiaoZhiWei 2017/08/21 10:51:13 经脉属性总和
        "meridian", -- add by XiaoZhiWei 2017/08/21 10:50:39 经脉
        "_roleBuff._buffs", -- add by XiaoZhiWei 2017/08/21 16:53:55 角色增益属性
        "_roleBuff._attrBuff", -- add by XiaoZhiWei 2017/08/21 16:53:55 角色增益属性
        "_roleBuff" -- add by XiaoZhiWei 2017/08/21 16:53:55 角色增益属性
    }

    for i, path in ipairs(encryptMap) do
        local parent, valueName = Helper:getLeaf(self._role, path)
        if type(parent[valueName]) == "table" then
            parent[valueName] = createSafeTable(
                "player." .. path,
                parent[valueName],
                function(tab, valueName, valueFrom, valueTo)
                    Collection:memoryCheat(User:getUserId(), valueName, valueFrom, valueTo)
                end
            )
        end
    end

    -- 修正一些问题
    self._role.Is_Lose = false

    -- 初始化角色teacherId属性
    local function initRoleTeacherId()
        local changeTab = {
            ["李教练"] = "lijiaolian",
            ["欧阳锋"] = "ouyangfeng",
            ["欧阳克"] = "ouyangke",
            ["巴天石"] = "batianshi",
            ["段正淳"] = "duanzhengchun",
            ["段思平"] = "duansiping",
            ["枯荣禅师"] = "kurongchanshi",
            ["静玄师太"] = "jingxuanshitai",
            ["纪晓芙"] = "jixiaofu",
            ["灭绝师太"] = "miejueshitai",
            ["周芷若"] = "zhouzhiruo",
            ["洪七公"] = "hongqigong",
            ["江上游"] = "jiangshangyou",
            ["梁长老"] = "liangzhanglao",
            ["乔峰"] = "qiaofeng",
            ["李莫愁"] = "limochou",
            ["林朝英"] = "linchaoying",
            ["陆无双"] = "luwushuang",
            ["小龙女"] = "xiaolongnv",
            ["杨过"] = "yangguo",
            ["封不平"] = "fengbuping",
            ["风清扬"] = "fengqingyang",
            ["高根明"] = "gaogenming",
            ["宁中则"] = "ningzhongze",
            ["岳不群"] = "yuebuqun",
            ["班淑娴"] = "banshuxian",
            ["高则成"] = "gaozecheng",
            ["何太冲"] = "hetaichong",
            ["何足道"] = "hezudao",
            ["西华子"] = "xihuazi",
            ["李秋水"] = "liqiushui",
            ["梅剑"] = "mejian",
            ["天山童姥"] = "tianshantonglao",
            ["虚竹"] = "xuzhu",
            ["韦一笑"] = "weiyixiao",
            ["谢逊"] = "xiexun",
            ["颜垣"] = "yanyuan",
            ["殷天正"] = "yintianzheng",
            ["张无忌"] = "zhangwuji",
            ["周颠"] = "zhoudian",
            ["葛伦布"] = "gelunbu",
            ["嘉木活佛"] = "jiamuhuofo",
            ["金轮法王"] = "jinlunfawang",
            ["鸠摩智"] = "jiumozhi",
            ["血刀老祖"] = "xuedaolaozu",
            ["阿朱"] = "azhu",
            ["包不同"] = "baobutong",
            ["慕容博"] = "morongbo",
            ["慕容复"] = "murongfu",
            ["丘处机"] = "qiuchuji",
            ["王重阳"] = "wangchongyang",
            ["尹志平"] = "yinzhiping",
            ["鲍大楚"] = "baodachu",
            ["东方不败"] = "dongfangbubai",
            -- ["任我行"] = "renwoxing",  -- add by XiaoZhiWei 2017/03/18 22:12:04
            ["向问天"] = "xiangwentian",
            ["澄观"] = "chengguan",
            ["达摩祖师"] = "damozushi",
            ["玄悲大师"] = "xuanbeidashi",
            ["玄慈大师"] = "xuancidashi",
            ["玄难大师"] = "xuannandashi",
            ["玄痛大师"] = "xuantongdashi",
            ["虚通"] = "xutong",
            ["唐不平"] = "tangbuping",
            ["唐老太太"] = "tanglaotaitai",
            ["唐亮"] = "tangliang",
            ["唐猛"] = "tangmeng",
            ["黄药师"] = "huangyaoshi",
            ["曲灵风"] = "qulingfeng",
            ["哑仆"] = "yapu",
            ["裘千仞"] = "qiuqianren",
            ["裘千丈"] = "qiuqianzhang",
            ["上官剑南"] = "shangguanjiannan",
            ["谷虚道长"] = "guxudaozhang",
            ["宋远桥"] = "songyuanqiao",
            ["张三丰"] = "zhangsanfeng",
            ["何铁手"] = "hetieshou",
            ["齐云敖"] = "qiyunao",
            ["沙千里"] = "shaqianli",
            ["苏星河"] = "suxinghe",
            ["逍遥子"] = "xiaoyaozi",
            ["薛慕华"] = "xuemuhua",
            ["采花子"] = "caihuazi",
            ["丁春秋"] = "dingchunqiu",
            ["摘星子"] = "zaixingzi"
        }
        -- teacherId未初始化,但teacherName 不为空时,设置teacherId
        if self._role:getAttr("teacherId") == nil and self._role:getAttr("teacherName") ~= nil then
            self._role:setAttr("teacherId", changeTab[self._role:getAttr("teacherName")])
        end
    end

    initRoleTeacherId()

    --版权问题替换相关师傅名字
    local function replaceName()
        local replaceName = {
            ["巴天石"] = "辛湛丘",
            ["段正淳"] = "段天遐",
            ["李莫愁"] = "李漠情",
            ["小龙女"] = "龙姑娘",
            ["杨过"] = "英俊男子",
            ["李秋水"] = "李绿芜",
            ["天山童姥"] = "鹤童鬼姥",
            ["尹志平"] = "武志辉",
            ["鲍大楚"] = "鲍长老",
            ["任我行"] = "聂焱然",
            ["达摩祖师"] = "年轻和尚",
            ["齐云敖"] = "汤庭",
            ["苏星河"] = "苏老者",
            ["逍遥子"] = "自逍遥",
            ["薛慕华"] = "薛神医",
            ["东方不败"] = "向阳生",
            ["杨莲亭"] = "严思齐",
            ["顾大年"] = "尔禹阳",
            ["虚竹子"] = "清竹子",
            ["慕容兴"] = "慕容业",
            ["崔志方"] = "林志强",
        }

        if self._role:getAttr("teacherName") ~= nil and replaceName[self._role:getAttr("teacherName")] ~= nil then
            self._role:setAttr("teacherName", replaceName[self._role:getAttr("teacherName")])
        end
    end

    replaceName()

    self._role:initMap()

    -- 初始化一些可以玩家角色有关的模块
    cc.exports.RewardManager = require("app.models.reward.RewardManager"):create()
    RewardManager:setRole(self._role)

    -- 初始化属性监控
    self._role:initAttrMonitor()

    local ChallengeMapSystem = require("app.models.ChallengeMap.ChallengeMapSystem")
    ChallengeMapSystem:getInstance():setRole(self._role)

    local QianNengDanUseRecord = require("app.models.Record.QianNengDanUseRecord.QianNengDanUseRecord")
    QianNengDanUseRecord:initBaseData(self._role)

    --称号转换
    local TitleHelper = require("app.models.role.titleSystem.TitleHelper")
    TitleHelper:changeTitle(self._role)
end

function User:againstCheating()
    -----------------------------------------------------------------------------------------------------------
    -- @author XiaoZhiWei
    -- @time 2017/08/21 10:33:41
    -- @desc 角色创建安全的列表table
    local function roleCreateSafeTable(key, tab)
        assert(key, "key is nil")

        return createSafeTable(
            key,
            tab,
            function(tab, valueName, valueFrom, valueTo)
                Collection:memoryCheat(User:getUserId(), valueName, valueFrom, valueTo)
            end
        )
    end

    local role = User:getRole()

    -- add by XiaoZhiWei 2017/08/21 16:54:55 防作弊属性列表 注: 如果父节点和子节点都需要防范,需要先防子节点,再防父节点(填写先后顺序规则)
    local encryptlist = {
        ["items"] = "itemId", -- add by XiaoZhiWei 2017/08/21 10:45:11 背包
        ["ckitems"] = "itemId", -- add by XiaoZhiWei 2017/08/21 10:45:25 仓库
        ["shuxiang"] = "itemId", -- add by XiaoZhiWei 2017/08/21 10:45:34 书箱
        ["decorative"] = "itemId", -- add by XiaoZhiWei 2017/09/08 11:11:48 装饰箱
        ["zhaoShuXiang"] = "itemId", -- add by XiaoZhiWei 2017/08/21 10:45:41 招式书箱(残页)
        ["literaryBox"] = "itemId", -- add by XiaoZhiWei 2017/08/21 10:45:50 百家典籍书箱(藏书)
        ["skills"] = "id", -- add by XiaoZhiWei 2017/08/21 10:46:47 技能列表
        ["activeZhaos"] = "id", -- add by XiaoZhiWei 2017/08/21 10:47:05 招式列表
        ["inheritHistory"] = "", -- add by XiaoZhiWei 2017/08/21 10:49:06 历任传承人
        ["blackMarket"] = "", -- add by XiaoZhiWei 2017/08/21 10:49:33 黑市商人
        -- "mapNpcAttrModify.activeZhaos", -- add by XiaoZhiWei 2017/08/21 12:13:51 佣兵招式属性
        ["teacherTask"] = "" -- add by XiaoZhiWei 2017/08/21 10:50:25 师门任务
    }

    local count = 5
    local addList = {}

    for path, key in pairs(encryptlist) do
        local parent, valueName = Helper:getLeaf(role, path)
        if type(parent[valueName]) == "table" then
            for k, v in pairs(parent[valueName]) do
                if type(v) == "table" then
                    table.insert(addList, {parent = parent, valueName = valueName, path = path, key = key, v = v, k = k})
                end
            end
        else
        end
    end

    for i = 1, #addList, count do
        for index = i, i + count - 1 do
            if index > #addList then
                break
            end
            local params = addList[index]
            local parent, valueName, path, key, k, v = params.parent, params.valueName, params.path, params.key, params.k, params.v
            parent[valueName][k] = roleCreateSafeTable("player." .. path .. (key == "" and "" or tostring(v[key])), v)
        end
    end

    -- for path, key in pairs(encryptlist) do
    --     local parent, valueName = Helper:getLeaf(role, path)
    --     if type(parent[valueName]) == "table" then
    --         for k, v in pairs(parent[valueName]) do
    --             if type(v) == "table" then
    --                 parent[valueName][k] = roleCreateSafeTable("player." .. path .. (key == "" and "" or tostring(v[key])), v)
    --             end
    --         end
    --     else
    --     end
    -- end

    -- add by XiaoZhiWei 2017/08/25 11:24:04 检查存档数据是否异常
    --[[
        可能异常点
        1:每格物品数量不可能超过99个
        2:技能等级不可能超过1010级 (限制为1000级)
    ]]
    --需检测itemid
    local unusualItems = {
        ["fengrusongcanye"] = 0,
        ["anjincanye"] = 0,
        ["tianshifucanye"] = 0,
        ["suqinbeijiancanye"] = 0
    }
    -- add by XiaoZhiWei 2017/08/25 11:40:15 背包
    local items = role:getItems()
    for k, item in pairs(items) do
        if item.count > 99 then
            Collection:memoryCheat(User:getUserId(), "player.items." .. tostring(item.itemId), 0, item.count)
        end
    end

    -- add by XiaoZhiWei 2017/08/25 11:40:15 仓库
    local ckItems = role:getckItems()
    for k, item in pairs(ckItems) do
        if item.count > 99 then
            Collection:memoryCheat(User:getUserId(), "player.ckItems." .. tostring(item.itemId), 0, item.count)
        end
    end

    -- add by XiaoZhiWei 2017/08/25 11:40:15 技能
    local skills = role:getSkills()
    local SkillHelper = require("app.models.skill.SkillHelper")
    for skillId, skill in pairs(skills) do
        local limitLv = SkillHelper:getSkillLvLimit(role, skillId)
        local maxExp = SkillHelper:getExp(skillId, limitLv)
        if skill.exp > maxExp + 1 then
            Collection:memoryCheat(User:getUserId(), "player.skills." .. tostring(skillId), skill.exp, maxExp)
        end
    end

    -- 神兵加密
    role:setShenBingItems(role.shenBingItems)
    -- 标记值加密
    role:encryptedRoleFlag()
end

function User:roleIsValid()
    local role = self._role
    role.userid = tonumber(role.userid)
    if role and role.userid and role.userid > 0 then
        return true
    end
    return false
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 保存角色
function User:saveRole()
    -- self:setRoleAttr("kongfu", self._role:getKongfu())
    local roleData = self._role:trimRoleData()

    if IS_ABLE_TO_SAVE_DATA == true then
        DataBase:setRoleData(roleData)
        self._saveRoleCoroutine = nil -- 保存存档后，清空当前正在保存的协程
    end
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/11/29 01:06:20
-- @desc 单步保存角色
function User:saveRoleStep()
    if self._saveRoleCoroutine == nil then
        self._saveRoleCoroutine = self:createSaveRoleCoroutine()
    end

    coroutine.resume(self._saveRoleCoroutine)
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/11/29 00:58:02
-- @desc 角色保存协程
function User:createSaveRoleCoroutine()
    return coroutine.create(
        function()
            local needCallTimes = 5
            while true do
                if self:roleIsValid() then
                    local beginTime = GetLocalTime()
                    print("开始保存玩家数据：")
                    local index = 0
                    local setDataCoroutine = DataBase:createSetDataCoroutine()
                    coroutine.yield()
                    self._role.saveDataTime = GetTime()
                    coroutine.yield()
                    local roleData = createSafeTable("__SAVE_TRIM_DATA__",self._role:trimRoleData())
                    coroutine.yield()
                    roleData = clone(roleData)
                    coroutine.yield()

                    while true do
                        local isBreak = false
                        for i = 1, needCallTimes do
                            local a1, finished = coroutine.resume(setDataCoroutine, "RoleData", roleData)
                            if finished == true then
                                isBreak = true
                                break
                            else
                                index = index + 1
                            end
                        end
                        if isBreak then
                            break
                        else
                            coroutine.yield()
                        end
                    end
                    print("存档保存时间戳(User:createSaveRoleCoroutine) = ", GetLocalTime() - beginTime, index)
                else
                    coroutine.yield()
                end
            end
        end
    )
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 重置角色
function User:reset()
    self:resetRole()
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/11/29 03:10:43
-- @desc 角色刷新方法
function User:update()
    if self:roleIsValid() == false then
        return
    end
    self._role:update()
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 删除存档
function User:deleteRole()
    DataBase:resetRoleData()
    self._role = nil
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 重置角色数据
function User:resetRole()
    DataBase:resetRoleData()
    User:loadRole()
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 得到当前角色
--@return [src.app.models.role.Role#Role]
function User:getRole()
    return self._role
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 设置当前角色属性
function User:setRoleAttr(...)
    if self._role then
        return self._role:setAttr(...)
    end
    assert("当前无角色")
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 得到当前角色属性
function User:getRoleAttr(...)
    if self._role then
        return self._role:getAttr(...)
    end
    assert("当前无角色")
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 增加当前角色属性
function User:addRoleAttr(...)
    if self._role then
        return self._role:addAttr(...)
    end
    assert("当前无角色")
end

function User:setNaturalAttr(name , value)
    if self._role then
        return self._role:setNaturalAttr(name,value)
    end
    assert("当前无角色")
end

return User
0000