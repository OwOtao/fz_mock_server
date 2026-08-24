local Loader = {
    _loaderFuncs = {}
}

local requireTab = {
    function()
        --@desc 日志系统
        cc.exports.MainLogSystem = require("app.models.LogSystem.LogSystem")

        cc.exports.Record = require("app.models.Record.Record")
    end,
    -- 内存检测工具
    function()
        cc.exports.MemoryDetection = require("app.MemoryDetection")
    end,
    -- 友盟sdk
    function()
        cc.exports.Mob = require("app.extends.MobClickForLua")
        Mob.setEncryptEnabled(true)
        -- 友盟统计数据加密
    end,
    -- CacheMap
    function()
        cc.exports.CacheMap = require("app.extends.CacheMap")
    end,
    --全局通用参数
    function()
        cc.exports.GameConst = require("app.models.game.GameConst")
    end,
    -- 声音
    function()
        cc.exports.Audio = require("app.controllers.Audio")
    end,
    function()
        cc.exports.Resource = require("app.Resource")
        cc.exports.Res = Resource
    end,
    function()
        -- MainPerformanceAnalysisSystem:hook()
        cc.exports.Skill = require("app.models.skill.Skill")
        Skill:init()
        -- MainPerformanceAnalysisSystem:unhook()
        -- MainPerformanceAnalysisSystem:printInfo("totalTime")
    end,
    --神兵文本
    function()
        cc.exports.ShenBingDesc = require("app.models.ShenBing.ShenBingDesc")
        ShenBingDesc:init()
    end,
    function()
        cc.exports.Item = require("app.models.item.Item")
    end,
    function()
        cc.exports.MonitorPool = require("app.models.MonitorPool.MonitorPool")
    end,
    function()
        --@RefType [src.app.models.OperationModel.OperationFactory#OperationFactory]
        cc.exports.OperationFactory = require("app.models.OperationModel.OperationFactory")
    end,
    -- 网络
    -- 角色类 add by TangJian 2017/03/13 17:37:16
    function()
        cc.exports.RoleBuff = require("app.models.role.RoleBuff")
        cc.exports.Role = require("app.models.role.Role")
    end,
    function()
        cc.exports.Npc = require("app.models.npc.Npc")
    end,
    function()
        cc.exports.ShenBingEffct = require("app.models.ShenBing.ShenBingEffct")
    end,
    function()
        -- -- 初始化挑战副本系统
        -- cc.exports.ChallengeMapSystem = reuqire("app.models.ChallengeMap.ChallengeMapSystem")

        cc.exports.Map = require("app.models.map.Map"):create()
        Map:init()
    end,
    function()
        cc.exports.MapPVP = require("app.models.map.MapPVP")
        cc.exports.MapPVPRoles = require("app.models.map.MapPVPRoles")
    end,
    -- 账户
    function()
        cc.exports.Account = require("app.models.account.Account")
    end,
    -- 交易校验
    function()
        cc.exports.TransCheck = require("app.models.transCheck.TransCheck")
    end,
    -- 订单相关
    function()
        cc.exports.Order = require("app.models.order.Order")
    end,
    -- app
    function()
        cc.exports.DataBase = require("app.DataBase")
    end,
    -- controllers
    function()
        cc.exports.Audio = require("app.controllers.Audio")
    end,
    -- 状态机
    function()
        cc.exports.StateMachine = require("app.extends.StateMachine")
    end,
    -- FunctionManager
    function()
        cc.exports.FunctionManager = require("app.extends.FunctionManager")
    end,
    -- models
    function()
        cc.exports.Family = require("app.models.family.Family")
    end,
    function()
        cc.exports.Formula = require("app.models.formula.Formula")
    end,
    function()
        cc.exports.Task = require("app.models.task.Task")
    end,
    function()
        cc.exports.Teacher = require("app.models.teacher.Teacher")
    end,
    function()
        cc.exports.FubenClient = require("app.models.FuBenClient.FubenClient")
    end,
    function()
        cc.exports.OfflineProfit = require("app.models.OfflineProfit.OfflineProfit")
        OfflineProfit:init()
    end,
    function()
        cc.exports.Statistics = require("app.models.statistics.Statistics")
    end,
    -- controller
    -- 服务器管理类
    function()
        cc.exports.SwitchServerController = require("app.models.server.SwitchServerController"):create()
    end,
    --------------view
    -- base
    -- 基本层
    function()
        cc.exports.LayerEx = require("app.views.base.LayerEx")
    end,
    function()
        cc.exports.BaseLayer = require("app.views.base.BaseLayer")
    end,
    function()
        cc.exports.BaseControllLayer = require("app.views.base.ControllLayer")
    end,
    function()
        cc.exports.PopupLayerController = require("app.views.base.PopupLayerController"):getInstance()
    end,
    -- layer
    function()
        cc.exports.MainControllLayer = require("app.views.layer.ControllLayer")
    end,
    -- 服务器切换 add by TangJian 2017/06/27 21:28:40
    function()
        cc.exports.SwitchServerLayer = require("app.views.layer.SwitchServerLayer.SwitchServerLayer")
    end,
    function()
        cc.exports.SwitchServerSelectStartLayer = require("app.views.layer.SwitchServerLayer.SwitchServerSelectStartLayer")
    end,
    function()
        cc.exports.SwitchServerEmailLayer = require("app.views.layer.SwitchServerLayer.SwitchServerEmailLayer")
    end,
    function()
        cc.exports.SwitchServerInheritRoleEntryGameLayer = require("app.views.layer.SwitchServerLayer.SwitchServerInheritRoleEntryGameLayer")
    end,
    -- 活动相关页面

    function()
        cc.exports.ConfirmLayer = require("app.views.layer.PopLayer.ConfirmLayer")
    end,
    -- 登出界面
    function()
        local logoutLayer = require("app.views.layer.EmailLayer.LogoutLayer")
        cc.exports.PopLogoutLayer = logoutLayer.pop

        local logoutLayerInMenu = require("app.views.layer.EmailLayer.LogoutLayerInMenu")
        cc.exports.PopLogoutLayerInMenu = logoutLayerInMenu.pop
    end,
    -- 元宝购买界面
    function()
        cc.exports.YuanBaoPayLayer = require("app.views.layer.PayLayer.YuanBaoPayLayer")
        cc.exports.PopYuanBaoBuyItemLayer = YuanBaoPayLayer.buyItem --(itemId, preBuyFunc, endBuyFunc)
    end,
    function()
        cc.exports.ForgeSkill = require("app.models.ShenBing.ForgeSkill.ForgeSkill")
    end,
    --@desc 毒药配方
    function()
        cc.exports.PoisonFormula = require("app.models.Poison.PoisonFormula")
    end,
    --@desc 奖励
    function()
        cc.exports.RewardManager2 = require("app.models.reward.RewardManager2")
    end,
    --成就
    function()
        cc.exports.AchievementSystem = require("app.models.AchievementSystem.AchievementSystem"):create()
    end,
    function()
        require("app.FightSystem.ResourceManager.AnimResManager")
        require("app.FightSystem.ResourceManager.AudioResManager")
        require("app.FightSystem.ResourceManager.AttackDamageDescManager")
        require("app.FightSystem.ResourceManager.AttackHitPosClassManager")
        require("app.FightSystem.Configuration.BuffConf")
        require("app.FightSystem.Configuration.ActiveSkillConf")
    end
}

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 包含
function Loader:require(func)
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 添加载入方法
function Loader:addLoaderFunc(key, func)
    if type(key) ~= "number" then
        return
    end
    self._loaderFuncs[key] = Helper:getDef(self._loaderFuncs[key], {})
    table.insert(self._loaderFuncs[key], func)
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2017/03/27 18:46:16
-- @desc 载入基本模块
function Loader:loadBase(func)
    AddLifeCycle = require("app.extends.LifeCycleSupport")

    -- 定义
    require("app.Definition")

    -- 断言是否为示例
    assertIsInstance = require("third.assertIsInstance.assertIsInstance")

    -- 调度器
    scheduler = require("app.controllers.scheduler")

    Helper = require("app.Helper")

    -- 日志系统
    LogSystem = require("app.models.LogSystem.LogSystem")

    -- 继承
    inherit = require("third.inherit.inherit")

    -- 可观察对象
    Observable = require("app.extends.observable.Observable")

    --全局策略
    GameChannelContext = require("app.models.GameChannels.GameChannelContext")

    Decorator = require("app.Decorator")
    require("app.extends.Extends")
    md5 = require("app.extends.md5")
    luaTableEncode, luaTableDecode, createTableToStringCoroutine = require("app.extends.tableToString")()
    JMForLua = require("app.extends.JMForLua")
    DataBase = require("app.DataBase")
    Collection = require("app.models.collection.Collection")
    WaitingLayer = require("app.views.layer.PopLayer.WaitingLayer")
    ButtonPopLayer = require("app.views.layer.PopLayer.ButtonPopLayer")
    User = require("app.models.user.User")
    --@RefType [src.app.extends.Http.HttpManager#HttpManager]
    HttpManagerEx = require("app.extends.Http.HttpManager")

    -- 全局协程池
    MainCoroutinePool = require("third.coroutine.CoroutinePool"):create()

    -- 阻塞协程池
    BlockCoroutinPool = require("third.coroutine.CoroutinePool"):create()

    --
    CoroutineStack = require("third.coroutine.CoroutineStack")

    MainCheatingAgainstSystem = require("app.extends.CheatingAgainstSystem"):create()

    if DEBUG_MODE == 1 then
        require("app.extends.PerformanceAnalysis")
    end
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 载入
function Loader:loadCustom(func)
    -- require
    for i, v in ipairs(requireTab) do
        self:addLoaderFunc(1, v)
    end

    -- 载入
    self:addLoaderFunc(
        1,
        function()
            -- models
            Collection:init()
            Statistics:init()
        end
    )

    local LoadingLayer = require("app.views.layer.LoadingLayer")
    LoadingLayer:getInstance():show(
        self._loaderFuncs,
        func,
        {
            {factor = 0.8, addCount = 0},
            {factor = 0.2, addCount = 80}
        }
    )

    local func = function()
        local count = 0
        for i, v in ipairs(requireTab) do
            if type(v) == "table" then
                v.init()
                count = count + v.needPercent
            else
            end
        end
        return count
    end

    LoadingLayer:getInstance():setTotalCount(func())
end

function Loader:success()
end

return Loader
00000