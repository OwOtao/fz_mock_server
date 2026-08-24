local WaitingLayer = require("app.views.layer.PopLayer.WaitingLayer")  

-- 服务器部分
--HttpManager = class("HttpManager", {})
local HttpManager = require("app.extends.Http") -- add by XiaoZhiWei 2018/05/07 17:01:49 http 请求逻辑部分代码

-- @desc: 异步执行请求函数
-- author:TangJian
-- time:2022-03-31 18:46:15
-- @funcName: 请求函数名
-- @args: 请求参数，用"callback"字符串替代原本回调所在的参数
-- @return:
-- @example:
-- local errcode, errmsg, data = HttpManagerEx:async("getTime", "callback", true, true)
-- print(data.time)
function HttpManager:async(funcName, ...)
    local AsyncFunction = require("third.async.AsyncFunction")
    return unpack(
        AsyncFunction:create(
            function(thread, args)
                local callbackIndex = nil
                for i, v in ipairs(args) do
                    if v == "callback" then
                        assert(callbackIndex == nil, "Only one callback function is allowed")
                        callbackIndex = i
                    end
                end
                assert(callbackIndex ~= nil, "callback is nil")

                local hasFinished = false
                local results = nil

                args[callbackIndex] = function(status, errcode, errmsg, data)
                    if status == 200 then
                        hasFinished = true
                        results = {errcode, errmsg, data}
                        local LogSystem = require("app.models.LogSystem.LogSystem")
                        LogSystem:log("http:", results)
                        return true
                    end
                end

                self[funcName](unpack(args))
                while hasFinished == false do
                    thread:yield()
                end
                thread:finish(results)
            end,
            {self, ...}
        ):await()
    )
end

-- 获取服务器时间
function HttpManager:getTime(func, isNeedWait, retryType, waitText)
    func = Helper:getDef(func, EMPTY_FUNC)

    local callback = self:createGetResponseFunction(func)

    if not waitText then
        waitText = "同步时间中,请稍后..."
    end

    -- 网络请求等待文本实例
    self:retryGetWithHeaderAndWaitText(waitText, DOMAIN.."get_time", "", nil, callback, isNeedWait, retryType)
end

function HttpManager:createRole(func, isNeedWait, retryType)
    func = Helper:getDef(func, EMPTY_FUNC)

    local callback = self:createGetResponseFunction(func)
    self:retryPostWithHeader(DOMAIN .. "create_role", "", nil, callback, isNeedWait, retryType, NEED_ENCRYPT)
end

-- 获取商品列表
function HttpManager:getStoreData(func, isNeedWait, retryType)
    func = Helper:getDef(func, EMPTY_FUNC)

    local callback = self:createGetResponseFunction(func)
    self:retryGetWithHeader(DOMAIN .. "get_store_list_4", "", nil, callback, isNeedWait, retryType)
end

-- 获取苹果商店列表
function HttpManager:getAppStoreData(func, isNeedWait, retryType)
    func = Helper:getDef(func, EMPTY_FUNC)

    local callback = self:createGetResponseFunction(func)
    self:retryGetWithHeader(DOMAIN .. "get_applestore_list", "", nil, callback, isNeedWait, retryType)
end

-- 判断玩家是否作弊
function HttpManager:getCheatType()
    if not self.checkCheatArray then
        self.checkCheatArray = {
            -- 模型
            [0] = require("app.models.task.tasks.task1"),
            [1] = require("app.models.task.tasks.task2"),
            [2] = require("app.models.task.tasks.task3"),
            [4] = require("app.models.task.tasks.task4"),
            [5] = require("app.models.task.tasks.task5"),
            [6] = require("app.models.task.tasks.task6"),
            [7] = require("app.models.task.tasks.task7"),
            [8] = require("app.models.task.tasks.task8"),
            [9] = require("app.models.task.tasks.task9"),
            [10] = require("app.models.task.tasks.task10"),
            [11] = require("app.models.task.tasks.task11"),
            [12] = require("app.models.task.tasks.task12"),
            [13] = require("app.models.task.tasks.task16"),
            [14] = require("app.models.task.BaseTask"),
            [15] = require("app.models.task.Task"),
            [16] = require("app.models.skill.Skill"),
            [17] = require("app.models.skill.BaseSkill"),
            [18] = require("app.models.role.Role"),
            [19] = require("app.models.map.Map"),
            [20] = require("app.models.map.BaseMap"),
            [21] = require("app.models.item.Item"),
            [22] = require("app.models.item.BaseItem"),
            --层
            [100] = require("app.views.layer.ControllLayer"),
            [101] = require("app.views.layer.TaskLayer.TaskLayer"),
            [102] = require("app.views.layer.StoreLayer.StoreLayer"),
            [103] = require("app.views.layer.SkillLayer.SkillInfoLayer"),
            [104] = require("app.views.layer.MapLayer.MapLayer"),
            [105] = require("app.views.layer.AttrLayer.AttrLayer"),
            [106] = require("app.views.layer.MainLayer"),
            [107] = require("app.views.layer.CreateRoleLayer"),
            [108] = require("app.views.StartGameLayer")

            --
            -- [200] = require("app.MyApp"),
        }
    end

    local cheatType = ""
    -- for i, v in pairs(self.checkCheatArray) do
    --     if not v.isEncrypted then
    --         cheatType = cheatType .. tostring(i) .. ","
    --     end
    -- end
    if cheatType == "" then
        cheatType = "3," -- 作弊类型为3
    end
    return string.sub(cheatType, 1, string.len(cheatType) - 1)
end

-- 上传用户存档
function HttpManager:uploadUserData(uType, func, isNeedWait, retryType, isNeedSave)
    --------------------
    func = Helper:getDef(func, EMPTY_FUNC)
    if isNeedSave ~= false then
        User:save() -- 保存一次数据,确保本次上传的数据是最新的
    end
    local userAttr = DataBase:getRoleData()
    if type(userAttr) ~= "table" then
        -- 本地没有用户数据的时候,需要模拟成功消息(否则有无法切换存档的情况)
        func(200, 0, "", [[{"errcode":0}]], true)
        return
    end

    local tempRole = Role:create(userAttr)
    tempRole:init()
    tempRole:repairUserData()
    tempRole:getSelfCreatedSkillSystem():updataSelfCreatedSkillMap()

    local PlayerRecord = require("app.models.role.RecordSystem.PlayerRecord")
    local recordInfo = PlayerRecord:getRecord(tempRole)

    MainLogSystem:log("存档上传：", recordInfo)

    -- 作弊类型
    local cheatType = self:getCheatType()
    if PRINT_MODE == 1 then
        print("cheatType = " .. tostring(cheatType))
    end

    -- 上传存档
    local url = "upload_user_file_3"
    url = url .. "/" .. tostring(uType) .. "/" .. tostring(cheatType)
    -- self:retryPost(url, JMForLua:encrypt(json.encode({userAttr})), func, isNeedWait, retryType)
    -- 包一层
    local reFunc = function(status, errcode, errmsg, data, isEncrypted)
        if status == 200 and errcode == 0 and data.primeryKey ~= nil then
            User:setRoleAttr("primeryKey", data.primeryKey)
        end
        return func(status, errcode, errmsg, data, isEncrypted)
    end

    local callback = self:createGetResponseFunction(reFunc)
    local waitText = self:getWaittingText("archive")

    self:retryPostWithHeaderAndWaitText(waitText, DOMAIN..url, {userAttr,recordInfo}, nil, callback, isNeedWait, retryType, NEED_ENCRYPT)
end

-- 上传用户存档不保存
function HttpManager:uploadUserDataWithoutSave(uType, func, isNeedWait, retryType)
    self:uploadUserData(uType, func, isNeedWait, retryType, false)
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/11/09 10:21:54
-- @desc 直接上传用户本地存档
function HttpManager:uploadLocalUserData(uType, func, isNeedWait, retryType)
    --------------------
    func = Helper:getDef(func, EMPTY_FUNC)
    local userAttr = DataBase:getRoleData()

    -- 作弊类型
    local cheatType = "3"
    if PRINT_MODE == 1 then
        print("cheatType = " .. tostring(cheatType))
    end

    -- 上传存档
    local url = "upload_user_file_5"
    url = url .. "/" .. tostring(uType) .. "/" .. tostring(cheatType)
    local callback = self:createGetResponseFunction(func)
    self:retryPostWithHeader(DOMAIN .. url, {userAttr}, nil, callback, isNeedWait, retryType, NEED_ENCRYPT)
end

-- 下载用户存档
function HttpManager:downloadUserData(func, isNeedWait, retryType)
    func = Helper:getDef(func, EMPTY_FUNC)
    func = self:createGetResponseFunction(func)
    self:retryGetWithHeader(DOMAIN .. "download_user_file_2", "", nil, func, isNeedWait, retryType)
end

-- 获取游戏内奖励 type : 1 广告 2 微信 3 月卡 ...
function HttpManager:getReward(type, func, isNeedWait, retryType)
    func = Helper:getDef(func, EMPTY_FUNC)
    if not type then
        if PRINT_MODE == 1 then
            print("获取游戏奖励 参数使用出错 getReward")
        end
        return
    end

    local callback = self:createGetResponseFunction(func)
    self:retryGetWithHeader(DOMAIN .. "get_reward/" .. tostring(type), "", nil, callback, isNeedWait, retryType)
end

-- 获取游戏内奖励 rType : 1 月卡 ...
-- homeland_open 家园是否开启，1开启，0未开启
function HttpManager:getReward2(rType, trans_id, homeland_open, func, isNeedWait, retryType)
    if rType == nil or trans_id == nil then
        if PRINT_MODE == 1 then
            print("获取游戏奖励 参数使用出错 getReward2")
        end
        return
    end
    func = Helper:getDef(func, EMPTY_FUNC)
    local callback = self:createGetResponseFunction(func)
    self:retryPostWithHeader(DOMAIN .. "get_reward_2/" .. tostring(rType), {trans_id = trans_id, is_homeland = homeland_open}, nil, callback, isNeedWait, retryType)
end

function HttpManager:updataUserName(name, func, isNeedWait, retryType)
    if not name then
        if PRINT_MODE == 1 then
            print("排行榜刷新玩家名字 参数使用出错 updataUserName")
        end
        return
    end
    func = Helper:getDef(func, EMPTY_FUNC)
    local callback = self:createGetResponseFunction(func)
    self:retryPostWithHeader(DOMAIN .. "update_username", {name = name}, nil, callback, isNeedWait, retryType)
end
-----------------------------------------------------------------------------------------------------------
-- 购买商品
function HttpManager:buyGoods(id, itemId, count, trans_id, others, discount, func, isNeedWait, retryType)
    if id == nil or itemId == nil or count == nil or trans_id == nil then
        if PRINT_MODE == 1 then
            print("购买商品 参数使用出错 buyGoods")
        end
        return
    end

    local data = {id = id, itemId = itemId, quantity = count, client_trans_id = trans_id, discount = discount}
    Helper:tableCover(data, others)
    func = Helper:getDef(func, EMPTY_FUNC)
    local callback = self:createGetResponseFunction(func)
    self:retryPostWithHeader(DOMAIN .. "buy_goods_3/" .. tostring(itemId), data, nil, callback, isNeedWait, retryType)
    -- self:retryPost("buy_goods", {id = id, quantity = count, client_trans_id = trans_id}, func, isNeedWait, retryType)
end

-- 获得商品信息
function HttpManager:getGoodsInfo(itemId, func, isNeedWait, retryType)
    if type(itemId) ~= "string" then
        if PRINT_MODE == 1 then
            print("获取商品信息，参数错误 getGoodsInfo")
        end
        return
    end
    func = Helper:getDef(func, EMPTY_FUNC)
    func = self:createGetResponseFunction(func)
    self:retryGetWithHeader(DOMAIN .. "get_goods/" .. tostring(itemId), {}, nil, func, isNeedWait, retryType)
end

-- 获得商品信息 mark 经脉印记相关
function HttpManager:getGoodsInfo_2(itemId, others, func, isNeedWait, retryType)
    if type(itemId) ~= "string" then
        if PRINT_MODE == 1 then
            print("获取商品信息，参数错误 getGoodsInfo_2")
        end
        return
    end
    func = Helper:getDef(func, EMPTY_FUNC)
    func = self:createGetResponseFunction(func)
    self:retryPostWithHeader(DOMAIN .. "get_goods_2/" .. tostring(itemId), others, nil, func, isNeedWait, retryType)
end

-- 校验购买是否成功
-- function HttpManager:checkTrans(trans_id, func, isNeedWait, retryType)
--     if trans_id == nil then
--         return
--     end
--     if func == nil then
--         func = function()
--         end
--     end
--     self:retryGet("check_fail_transaction/"..tostring(trans_id), "", func, isNeedWait, retryType)
-- end

-- 校验购买是否成功 transType 1 商店 2 月卡  4 论剑奖励
function HttpManager:checkTrans(transType, trans_id, func, isNeedWait, retryType)
    if transType == nil or trans_id == nil then
        if PRINT_MODE == 1 then
            print("校验是否购买成功 参数使用出错 checkTrans")
        end
        return
    end
    func = Helper:getDef(func, EMPTY_FUNC)
    local callback = self:createGetResponseFunction(func)
    self:retryPostWithHeader(DOMAIN .. "check_fail_transaction_2/" .. tostring(transType), json.encode({trans_id = trans_id}), nil, callback, isNeedWait, retryType)
end

function HttpManager:getYuanBao(func, isNeedWait, retryType)
    func = Helper:getDef(func, EMPTY_FUNC)
    func = self:createGetResponseFunction(func)
    self:retryGetWithHeader(DOMAIN .. "get_yuanbao", "", nil, func, isNeedWait, retryType)
end

function HttpManager:getRankingList(page, func, isNeedWait, retryType)
    if page == nil then
        return
    end
    func = Helper:getDef(func, EMPTY_FUNC)
    func = self:createGetResponseFunction(func)
    self:retryPostWithHeader(DOMAIN .. "get_rank_list_4", {page = page}, nil, func, isNeedWait, retryType)
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/08/09 11:55:31
-- @desc 获取单个排行榜的指定页码数据
function HttpManager:getBoard(ptype, page, func, isNeedWait, retryType)
    if page == nil or ptype == nil then
        return
    end
    func = Helper:getDef(func, EMPTY_FUNC)
    func = self:createGetResponseFunction(func)
    self:retryPostWithHeader(DOMAIN .. "get_board/" .. tostring(ptype), {page = page}, nil, func, isNeedWait, retryType)
end

-- 消耗元宝
function HttpManager:getRemoveYuanBao(num, trans_id, func, isNeedWait, retryType)
    if not num or type(num) ~= "number" or trans_id == nil then
        if PRINT_MODE == 1 then
            print("消耗元宝 参数使用出错 getRemoveYuanBao")
        end
        return
    end
    func = Helper:getDef(func, EMPTY_FUNC)
    func = self:createGetResponseFunction(func)
    self:retryGetWithHeader(DOMAIN .. "remove_yuanbao/" .. tostring(num) .. "/" .. tostring(trans_id), "", nil, func, isNeedWait, retryType)
end
-----------------------------------------------------------------------------------------------------------

-- 检查黑名单
function HttpManager:checkLogin(postData, func, isNeedWait, retryType)
    func = Helper:getDef(func, EMPTY_FUNC)
    local callback = self:createGetResponseFunction(func)
    self:retryPostWithHeader(DOMAIN .. "login", postData, nil, callback, isNeedWait, retryType)
end

-- 获取武器随机特效描述 （加工时使用）
function HttpManager:getRandomWeaponDesc(wType, func, isNeedWait, retryType)
    if wType == nil then
        if PRINT_MODE == 1 then
            print("获取武器随机特效 参数使用出错 getRandomWeaponDesc")
        end
        return
    end
    func = Helper:getDef(func, EMPTY_FUNC)
    func = self:createGetResponseFunction(func)
    self:retryGetWithHeader(DOMAIN .. "get_random_weapon_desc/" .. tostring(wType), "", nil, func, isNeedWait, retryType)
end

-- 打造武器
function HttpManager:makeWeapon(params, func, isNeedWait, retryType)
    if params == nil then
        if PRINT_MODE == 1 then
            print("打造武器 参数使用出错 makeWeapon")
        end
        return
    end
    func = Helper:getDef(func, EMPTY_FUNC)
    local callback = self:createGetResponseFunction(func)
    self:retryPostWithHeader(DOMAIN .. "make_weapon", params, nil, callback, isNeedWait, retryType)
end

-- 升级武器
function HttpManager:upgradeWeapon(params, func, isNeedWait, retryType)
    if params == nil then
        if PRINT_MODE == 1 then
            print("升级武器 参数使用错误 upgradeWeapon")
        end
        return
    end
    func = Helper:getDef(func, EMPTY_FUNC)
    local callback = self:createGetResponseFunction(func)
    self:retryPostWithHeader(DOMAIN .. "upgrade_weapon", params, nil, callback, isNeedWait, retryType)
end

-- 获取封藏神兵的数据
function HttpManager:getThrowWeaponData(func, isNeedWait, retryType)
    func = Helper:getDef(func, EMPTY_FUNC)
    func = self:createGetResponseFunction(func)
    self:retryGetWithHeader(DOMAIN .. "get_history_weapon", "", nil, func, isNeedWait, retryType)
end

-- 丢弃神兵的时候向服务器请求，保存数据
function HttpManager:throwShenBingWeapon(throwType, index, params, func, isNeedWait, retryType)
    if params == nil or throwType == nil then
        if PRINT_MODE == 1 then
            print("丢弃神兵 参数使用出错 throwShenBingWeapon")
        end
        return
    end
    if index == nil then
        index = 1
    end
    func = Helper:getDef(func, EMPTY_FUNC)
    local callback = self:createGetResponseFunction(func)
    self:retryPostWithHeader(DOMAIN .. "throw_weapon/" .. tostring(throwType) .. "/" .. tostring(index), params, nil, callback, isNeedWait, retryType)
end

-- 判断是否可以重命名
function HttpManager:getIsChangedName(func, isNeedWait, retryType)
    func = Helper:getDef(func, EMPTY_FUNC)
    func = self:createGetResponseFunction(func)
    self:retryGetWithHeader(DOMAIN .. "is_changed_name", "", nil, func, isNeedWait, retryType)
end
--获取切换列表
function HttpManager:getArchiveList(func, isNeedWait, retryType)
    func = Helper:getDef(func, EMPTY_FUNC)
    func = self:createGetResponseFunction(func)
    self:retryGetWithHeader(DOMAIN .. "get_archive_list", "", nil, func, isNeedWait, retryType)
end
-- 切换存档
function HttpManager:switchArchive(switchTo, callback, isNeedWait, retryType)
    if switchTo == nil then
        if PRINT_MODE == 1 then
            print("切换存档 参数使用出错 switchArchive")
        end
        return
    end
    callback = Helper:getDef(callback, EMPTY_FUNC)
    callback = self:createGetResponseFunction(callback)
    self:retryGetWithHeader(DOMAIN .. "switch_archive/" .. tostring(switchTo), "", nil, callback, isNeedWait, retryType)
end

-- 使用商城物品接口
function HttpManager:useShopGoods(itemId, func, isNeedWait, retryType)
    if itemId == nil then
        if PRINT_MODE == 1 then
            print("使用商城物品接口 参数使用出错  useShopGoods")
        end
        return
    end
    func = Helper:getDef(func, EMPTY_FUNC)
    func = self:createGetResponseFunction(func)
    self:retryGetWithHeader(DOMAIN .. "use_shop_goods/" .. tostring(itemId), "", nil, func, isNeedWait, retryType)
end

-- 测试购买月卡
function HttpManager:testYueKa(func, isNeedWait, retryType)
    func = Helper:getDef(func, EMPTY_FUNC)
    func = self:createGetResponseFunction(func)
    self:retryGetWithHeader(DOMAIN .. "test_yueka", "", nil, func, isNeedWait, retryType)
end

-- 月卡领取界面文本
--@homeland_open: 家园是否开启 1开启，0未开启
function HttpManager:getJhmsDesc(func, isNeedWait, retryType)
    func = Helper:getDef(func, EMPTY_FUNC)
    func = self:createGetResponseFunction(func)
    self:retryGetWithHeader(DOMAIN .. "get_jhms_desc", "", nil, func, isNeedWait, retryType)
end

-- 补领
function HttpManager:getJhmsReward(trans_id, homeland_open, days, func, isNeedWait, retryType)
    if trans_id == nil then
        if PRINT_MODE == 1 then
            print("补领 参数使用出错 getJhmsReward")
        end
        return
    end
    func = Helper:getDef(func, EMPTY_FUNC)
    local callback = self:createGetResponseFunction(func)
    self:retryPostWithHeader(DOMAIN .. "get_jhms_reward", {trans_id = trans_id, is_homeland = homeland_open, days = days}, nil, callback, isNeedWait, retryType)
end

-- 检查物品是否有效  原类型 现items={itemid,itemid}
function HttpManager:checkGoodsValid(itemIds, func, isNeedWait, retryType)
    if MapIsEmpty(itemIds) == nil then
        if PRINT_MODE == 1 then
            print("检查物品是否有效 参数使用出错 checkGoodsValid")
        end
        return
    end
    func = Helper:getDef(func, EMPTY_FUNC)
    func = self:createGetResponseFunction(func)
    self:retryPostWithHeader(DOMAIN .. "check_goods_valid", {itemIds = itemIds}, nil, func, isNeedWait, retryType)
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 提交作弊数据
function HttpManager:uploadCheat(cheat, func, isNeedWait, retryType)
    if cheat == nil then
        if PRINT_MODE == 1 then
            print("提交作弊数据 参数使用错误 uploadCheat")
        end
        return
    end
    func = Helper:getDef(func, EMPTY_FUNC)
    local callback = self:createGetResponseFunction(func)
    self:retryPostWithHeader(DOMAIN .. "report_cheat", cheat, nil, callback, isNeedWait, retryType)
end

--获取其他玩家数据
function HttpManager:getUserInfo(userID, userType, func, isNeedWait, retryType)
    if userID == nil or userType == nil then
        if PRINT_MODE == 1 then
            print("获取其他玩家数据 使用参数错误 getUserInfo")
        end
        return
    end
    func = Helper:getDef(func, EMPTY_FUNC)
    local callback = self:createGetResponseFunction(func)
    self:retryPostWithHeader(DOMAIN .. "get_user_info", {userid = userID, type = userType}, nil, callback, isNeedWait, retryType)
end

-----------------------------------------比武----------------------------------------------

-----获取人气榜 GET get_fight_board/{type} 1历史人气 2本周人气 3挑战记录
function HttpManager:getBiWuRankingList(typeNUm, func, isNeedWait, retryType)
    if type(typeNUm) ~= "number" then
        if PRINT_MODE == 1 then
            print("获取人气榜 使用参数错误 getBiWuRankingList")
        end
        return
    end
    func = self:createGetResponseFunction(func)
    self:retryGetWithHeader(DOMAIN .. "get_fight_board/" .. tostring(typeNUm), "", nil, func, isNeedWait, retryType)
end

--观战 POST watch_fight  将玩家加入到候选匹配队列（什么时候从队列移除，被挑战过，还是被打败。）
function HttpManager:sendBiWuWatch(func, isNeedWait, retryType)
    func = self:createGetResponseFunction(func)
    self:retryPostWithHeader(DOMAIN .. "watch_fight", nil, nil, func, isNeedWait, retryType, NEED_ENCRYPT)
end

--取消观战 POST unwatch_fight  {fid = ,unwatch_time = }
function HttpManager:sendBiWuUnWatch(params, func, isNeedWait, retryType)
    if MapIsEmpty(params) then
        if PRINT_MODE == 1 then
            print("取消观战  使用参数错误 sendBiWuUnWatch")
        end
        return
    end
    func = self:createGetResponseFunction(func)
    self:retryPostWithHeader(DOMAIN .. "unwatch_fight", params, nil, func, isNeedWait, retryType, NEED_ENCRYPT)
end

----获取对战结果列表 GET get_fight_msg
function HttpManager:getBiWuFighMessage(func, isNeedWait, retryType)
    func = self:createGetResponseFunction(func)
    self:retryGetWithHeader(DOMAIN .. "get_fight_msg2", "", nil, func, isNeedWait, retryType)
end

------上台挑战 POST join_fight
-- function HttpManager:sendBiWuJoinFight(role_lv,func, isNeedWait, retryType)
--     func = self:createGetResponseFunction(func)
--     self:retryPostWithHeader(DOMAIN.."join_fight", role_lv, nil, func, isNeedWait, retryType, NEED_ENCRYPT)
-- end
function HttpManager:sendBiWuJoinFight(func, isNeedWait, retryType)
    func = self:createGetResponseFunction(func)
    self:retryPostWithHeader(DOMAIN .. "join_fight2", "", nil, func, isNeedWait, retryType, NEED_ENCRYPT)
end

-----开始匹配对手 POST fight/{fight_type} 1挑衅，2邀战，3告辞
function HttpManager:sendBiWuFight(fight_type, params, func, isNeedWait, retryType)
    if MapIsEmpty(params) then
        if PRINT_MODE == 1 then
            print("匹配对手 使用参数错误 sendBiWuFight")
        end
        return
    end
    func = self:createGetResponseFunction(func)
    self:retryPostWithHeader(DOMAIN .. "fight2/" .. tostring(fight_type), params, nil, func, isNeedWait, retryType, NEED_ENCRYPT)
end

-----汇报战斗结果 POST report_fight_result    "win|lose|cancel 取消| run 逃跑"
function HttpManager:sendBiWuFightResult(params, func, isNeedWait, retryType)
    if MapIsEmpty(params) then
        if PRINT_MODE == 1 then
            print("汇报战斗结果 使用参数错误 sendBiWuFightResult")
        end
        return
    end
    func = self:createGetResponseFunction(func)
    self:retryPostWithHeader(DOMAIN .. "report_fight_result2", params, nil, func, isNeedWait, retryType, NEED_ENCRYPT)
end

-----汇报使用的卡牌ID   post  fid id card_id
function HttpManager:sendBiWuFightCardId(params, func, isNeedWait, retryType)
    if MapIsEmpty(params) then
        if PRINT_MODE == 1 then
            print("汇报使用的卡牌ID 使用参数错误 sendBiWuFightCardId")
        end
        return
    end
    func = self:createGetResponseFunction(func)
    self:retryPostWithHeader(DOMAIN .. "use_fight_card", params, nil, func, isNeedWait, retryType, NEED_ENCRYPT)
end

-- --get_fight_times   ---获取上台的剩余次数 GET
-- function HttpManager:getBiWuFightTimes(func, isNeedWait, retryType)
--     func = self:createGetResponseFunction(func)
--     self:retryGetWithHeader(DOMAIN.."get_fight_times", "", nil, func, isNeedWait, retryType)
-- end

--get_fight_times   ---获取上台的剩余次数 GET         新
function HttpManager:getBiWuFightTimes(func, isNeedWait, retryType)
    func = self:createGetResponseFunction(func)
    self:retryGetWithHeader(DOMAIN .. "get_fight_times2", "", nil, func, isNeedWait, retryType)
end

-------获取上台及挑战的需要消耗的元宝 GET  get_fight_yuanbao/{type} type 1上台 2挑战
function HttpManager:getBiWuFightYuanBao(type, func, isNeedWait, retryType)
    if not type then
        if PRINT_MODE == 1 then
            print("获取上台及挑战的需要消耗的元宝 使用参数错误 getBiWuFightYuanBao")
        end
        return
    end
    func = self:createGetResponseFunction(func)
    self:retryGetWithHeader(DOMAIN .. "get_fight_yuanbao/" .. type, "", nil, func, isNeedWait, retryType)
end
--get_chanllenge_msg  观战中的战斗信息
function HttpManager:getChanllengeMsg(func, isNeedWait, retryType)
    func = self:createGetResponseFunction(func)
    self:retryGetWithHeader(DOMAIN .. "get_chanllenge_msg", "", nil, func, isNeedWait, retryType)
end
---是否可以观战 can_watch_fight     errcode=0 可以观战    errcode=1 不可以观战
function HttpManager:getCanGuanZhan(func, isNeedWait, retryType)
    func = self:createGetResponseFunction(func)
    self:retryGetWithHeader(DOMAIN .. "can_watch_fight", "", nil, func, isNeedWait, retryType)
end
---GET 获取我的奖励列表  get_fight_reward_list
function HttpManager:getFightRewardList(func, isNeedWait, retryType)
    func = self:createGetResponseFunction(func)
    self:retryGetWithHeader(DOMAIN .. "get_fight_reward_list", "", nil, func, isNeedWait, retryType)
end

-- 领取自己的奖励  get_fight_reward
function HttpManager:getFightSelfReward(params, func, isNeedWait, retryType)
    if MapIsEmpty(params) then
        if PRINT_MODE == 1 then
            print("领取自己的奖励 使用参数错误 getFightSelfReward")
        end
        return
    end
    func = self:createGetResponseFunction(func)
    self:retryPostWithHeader(DOMAIN .. "get_fight_reward", params, "", func, isNeedWait, retryType, NEED_ENCRYPT)
end

---获取奖励预览列表 get_fight_reward_notice
function HttpManager:getFightWeekNotice(func, isNeedWait, retryType)
    func = self:createGetResponseFunction(func)
    self:retryGetWithHeader(DOMAIN .. "get_fight_reward_notice", "", nil, func, isNeedWait, retryType)
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 创建账户
function HttpManager:createAccount(userid, func, isNeedWait, retryType)
    func = self:createGetResponseFunction(func)
    self:retryPostWithHeader(DOMAIN .. "create_account", "", {userid = userid}, func, isNeedWait, retryType, NEED_ENCRYPT)
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 上传无用档案
function HttpManager:uploadUselessUserData(roleData, func, isNeedWait, retryType)
    local roleData = roleData
    
    func = self:createGetResponseFunction(func)
    self:retryPostWithHeader(DOMAIN .. "upload_user_file_4", {roleData, {}}, {userid = -1}, func, isNeedWait, retryType, NEED_ENCRYPT)
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 下载存档
function HttpManager:downloadUserDataTang(func, isNeedWait, retryType)
    func = self:createGetResponseFunction(func)
    self:retryGetWithHeader(DOMAIN .. "download_user_file_2", nil, nil, func, isNeedWait, retryType)
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 获得当前设备绑定的邮箱
function HttpManager:getEmailTang(func, isNeedWait, retryType)
    func = self:createGetResponseFunction(func)
    self:retryGetWithHeader(DOMAIN .. "get_email", "", nil, func, isNeedWait, retryType)
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 请求发送验证码到邮箱
function HttpManager:sendEmailTang(email, event_type, func, isNeedWait, retryType)
    func = self:createGetResponseFunction(func)
    self:retryPostWithHeader(DOMAIN .. "send_email", {email = email, event_type = event_type}, nil, func, isNeedWait, retryType, NEED_ENCRYPT)
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 登录设备
function HttpManager:loginDevice(email, verify_code, func, isNeedWait, retryType)
    func = self:createGetResponseFunction(func)
    self:retryPostWithHeader(DOMAIN .. "login_device", {verify_code = verify_code, email = email}, nil, func, isNeedWait, retryType, NEED_ENCRYPT)
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 登出设备
-- logout_device 登出设备
-- request
-- verify_code 验证码
-- {"verify_code":"", "email": ""}
-- response
-- {"errcode":0}
function HttpManager:logoutDevice(email, verify_code, callback, isNeedWait, retryType)
    callback = self:createGetResponseFunction(callback)
    if PRINT_MODE == 1 then
        print("type(callback) = " .. type(callback))
    end
    self:retryPostWithHeader(DOMAIN .. "logout_device", {verify_code = verify_code, email = email}, nil, callback, isNeedWait, retryType, NEED_ENCRYPT)
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 解除绑定
function HttpManager:logoutUnbindDevice(callback, isNeedWait, retryType)
    callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "logout_device", nil, {isBind = 0}, callback, isNeedWait, retryType, NEED_ENCRYPT)
end

--绑定邮箱
function HttpManager:bindDevice(emailAddr, code, func, isNeedWait, retryType)
    if emailAddr == nil or code == nil then
        if PRINT_MODE == 1 then
            print("绑定邮箱 参数使用错误 bindDevice")
        end
        return
    end
    func = Helper:getDef(func, EMPTY_FUNC)
    local callback = self:createGetResponseFunction(func)
    self:retryPostWithHeader(DOMAIN .. "bind_device", {email = emailAddr, verify_code = code}, nil, callback, isNeedWait, retryType)
end

-- add by XiaoZhiWei 2018/08/11 16:26:42  绑定邮箱新接口
-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2018/08/11 16:27:01
-- @params
-- @desc 获取绑定信息
function HttpManager:getBindInfo(callback, isNeedWait, retryType)
    callback = self:createGetResponseFunction(callback)
    self:retryGetWithHeader(DOMAIN .. "get_bind_info", "", nil, callback, isNeedWait, retryType)
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2018/08/11 16:28:39
-- @params
-- @desc 发送验证码
function HttpManager:sendVerifyCode(sendType, sendKey, eventType, callback, isNeedWait, retryType)
    callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "send_verify_code", {send_type = sendType, [sendType] = sendKey, event_type = eventType}, nil, callback, isNeedWait, retryType, NEED_ENCRYPT)
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2018/08/11 16:35:31
-- @params
-- @desc 绑定设备
function HttpManager:bindDevice2(sendType, sendKey, verifyCode, callback, isNeedWait, retryType)
    if sendType == nil or sendKey == nil or verifyCode == nil then
        if PRINT_MODE == 1 then
            print("绑定设备 参数使用错误 bindDevice2")
        end
        return
    end
    callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "bind_device_2", {send_type = sendType, [sendType] = sendKey, verify_code = verifyCode}, nil, callback, isNeedWait, retryType)
end

-- @desc 发送实名认证手机验证码
function HttpManager:sendPhoneVerifyCode(phone, callback, isNeedWait, retryType)
    callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "realname_send", {phone = phone}, nil, callback, isNeedWait, retryType, NEED_ENCRYPT)
end

-- @desc 实名认证信息绑定
function HttpManager:bindShiMingInfo(username, idcard, phone, code, callback, isNeedWait, retryType)
    if username == nil or idcard == nil or phone == nil or code == nil then
        if PRINT_MODE == 1 then
            print("绑定设备 参数使用错误 bindShiMingInfo")
            print("username, idcard, phone, code = ", username, idcard, phone, code)
        end
        return
    end
    callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "realname_auth", {username = username, idcard = idcard, phone = phone, code = code}, nil, callback, isNeedWait, retryType)
end

-- @desc 检查防沉迷充值上限
function HttpManager:checkPaySign(key, callback, isNeedWait, retryType)
    if key == nil then
        return
    end
    callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "check_pay_sign", {key = key}, nil, callback, isNeedWait, retryType)
end

--活动充值配合服务器处理
function HttpManager:checkActionPaySign(key, activityId, callback, isNeedWait, retryType)
    if key == nil or activityId == nil then
        return
    end
    callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "check_pay_sign", {key = key, activity_id = activityId}, nil, callback, isNeedWait, retryType)
end

-- @desc 上传当日游戏累计时间
function HttpManager:upDayGameTime(time, callback, isNeedWait, retryType)
    if type(time) ~= "number" then
        if PRINT_MODE == 1 then
            print("上传当日游戏累计时间 time", time)
        end
        return
    end
    callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "up_day_gametime", {time = time}, nil, callback, isNeedWait, retryType)
end
-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2018/08/11 16:59:39
-- @params
-- @desc 登录设备
function HttpManager:loginDevice2(sendType, sendKey, verifyCode, callback, isNeedWait, retryType)
    if sendType == nil or sendKey == nil or verifyCode == nil then
        if PRINT_MODE == 1 then
            print("绑定设备 参数使用错误 bindDevice2")
        end
        return
    end
    callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "login_device_2", {send_type = sendType, [sendType] = sendKey, verify_code = verifyCode}, nil, callback, isNeedWait, retryType)
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2018/08/11 16:52:27
-- @params
-- @desc 登出设备
function HttpManager:logoutDevice2(sendType, sendKey, verifyCode, callback, isNeedWait, retryType)
    if sendType == nil or sendKey == nil or verifyCode == nil then
        if PRINT_MODE == 1 then
            print("绑定设备 参数使用错误 bindDevice2")
        end
        return
    end
    callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "logout_device_2", {send_type = sendType, [sendType] = sendKey, verify_code = verifyCode}, nil, callback, isNeedWait, retryType)
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2018/08/13 23:15:14
-- @params
-- @desc 登出未绑定的设备
function HttpManager:logoutUnbindDevice2(callback, isNeedWait, retryType)
    callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "logout_device_2", nil, {isBind = 0}, callback, isNeedWait, retryType, NEED_ENCRYPT)
end

-- 获取服务器角色相关数据
function HttpManager:getGameUserInfo(noticeId, callback, isNeedWait, retryType)
    callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "get_game_user_info_2", {notice_version = noticeId}, nil, callback, isNeedWait, retryType, NEED_ENCRYPT)
end

-- 获取历史公告
function HttpManager:getHistoryNotice(callback, isNeedWait, retryType)
    callback = self:createGetResponseFunction(callback)
    self:retryGetWithHeader(DOMAIN .. "get_history_notice", nil, nil, callback, isNeedWait, retryType)
end

-- 领养传承人
function HttpManager:CreateHeir(heirName, callback, isNeedWait, retryType)
    callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "createNextRoleTask", {name = heirName}, nil, callback, isNeedWait, retryType, NEED_ENCRYPT)
end

--@desc: 传承
--@author:LvBin
--@time:2022-09-24 16:24:17
--@roleData: 传承后的角色数据
	--@userId:
	--@dataVer: 行为系统版本号
	--@callback:
	--@isNeedWait:
	--@retryType: 
--@return
function HttpManager:inherit(roleData, userId,dataVer, callback, isNeedWait, retryType)
    callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "finishNextRoleTask", {roleData = {roleData},dataVer = dataVer}, {userid = userId}, callback, isNeedWait, retryType, NEED_ENCRYPT)
end

-- 获取历代传承角色的属性
function HttpManager:getInheritHistoryRoleAttr(data, callback, isNeedWait, retryType)
    callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "get_chuanchen_user_info", data, nil, callback, isNeedWait, retryType, NEED_ENCRYPT)
end

-- 拜访任务
function HttpManager:isOpenVisitTask(callback, isNeedWait, retryType)
    callback = self:createGetResponseFunction(callback)
    self:retryGetWithHeader(DOMAIN .. "is_visitor_shop_open", nil, nil, callback, isNeedWait, retryType)
end

-- 获取黑市商人列表
function HttpManager:getMarketStoreList(callback, isNeedWait, retryType)
    callback = self:createGetResponseFunction(callback)
    self:retryGetWithHeader(DOMAIN .. "black_market_store", nil, nil, callback, isNeedWait, retryType)
end

-----------------------------------------------------------------------------------------------------------
-- @author LiJie
-- @time 2016/11/21 11:52:58
-- @desc 签到接口

--获取奖励列表
function HttpManager:getSignList(callback, isNeedWait, retryType)
    callback = self:createGetResponseFunction(callback)
    self:retryGetWithHeader(DOMAIN .. "get_sign_list", nil, nil, callback, isNeedWait, retryType)
end

--签到并获取奖励 getSignPrize
--@homeand_open: 家园是否开放
function HttpManager:getSignPrize(trans_id, stringDate, itemId, homeland_open, callback, isNeedWait, retryType)
    if trans_id == nil or stringDate == nil or itemId == nil then
        if PRINT_MODE == 1 then
            print("签到并获取奖励 使用参数错误 getSignPrize")
        end
        return
    end
    callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "get_sign_prize", {trans_id = trans_id, date = stringDate, item_id = itemId, is_homeland = homeland_open}, nil, callback, isNeedWait, retryType)
end

---获取累计奖励
function HttpManager:getSignHistoryPrize(trans_id, prizeId, callback, isNeedWait, retryType)
    if prizeId == nil or trans_id == nil then
        if PRINT_MODE == 1 then
            print("获取累计奖励 使用参数错误 getTotalSignPrize")
        end
        return
    end
    callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "get_sign_history_prize", {trans_id = trans_id, prize_id = prizeId}, nil, callback, isNeedWait, retryType)
end

-- 检查每日签到结果
function HttpManager:checkFailedNormalSign(trans_id, callback, isNeedWait, retryType)
    if trans_id == nil then
        if PRINT_MODE == 1 then
            print("参数错误")
        end
        return
    end
    callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "check_failed_normal_sign", {trans_id = trans_id}, nil, callback, isNeedWait, retryType)
end

-----------------------------------------------------------------------------------------------------------
-- 春节活动

--春节活动状态获取 ID 1. 首次充值 2. 累计充值 3. 收益加成 4. 吃吃吃 5. 限时礼包
function HttpManager:getNewYearFestivalState(id, callback, isNeedWait, retryType)
    callback = self:createGetResponseFunction(callback)
    self:retryGetWithHeader(DOMAIN .. "get_spring_festival_status/" .. id, nil, nil, callback, isNeedWait, retryType)
end

-- 获取限时礼包积分
function HttpManager:getXianShiPoint(callback, isNeedWait, retryType)
    callback = self:createGetResponseFunction(callback)
    self:retryGetWithHeader(DOMAIN .. "get_xianshilibao_gift_list_2", nil, nil, callback, isNeedWait, retryType)
end

-- 重置限时礼包积分
function HttpManager:resetXianShiPoint(callback, isNeedWait, retryType)
    callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "reset_xianshilibao_points", nil, nil, callback, isNeedWait, retryType)
end

-- -- 检查累计签到结果
-- function HttpManager:checkFailedNormalSign(trans_id, callback, isNeedWait, retryType)
--     if trans_id == nil then
--         print("参数错误")
--         return
--     end
--     callback = self:createGetResponseFunction(callback)
--     self:retryPostWithHeader(DOMAIN.."check_failed_history_sign", {trans_id = trans_id}, nil, callback, isNeedWait, retryType)
-- end

-- 测试活动数据
function HttpManager:testFastivalDate(productId, callback, isNeedWait, retryType)
    callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "init_test_festival_data", {key = productId}, nil, callback, isNeedWait, retryType)
end

--清除活动测试数据
function HttpManager:clearTestFestivalData(callback, isNeedWait, retryType)
    callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "clean_test_festival_data", nil, nil, callback, isNeedWait, retryType)
end

-- 通过交易类型以及订单业务信息,获取订单号
function HttpManager:getFestivalOrderId(orderType, orderInfo, callback, isNeedWait, retryType)
    callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "get_order_id/" .. orderType, orderInfo, nil, callback, isNeedWait, retryType)
end

-- 通过订单号 回滚校验订单状态 订单交易过程出现异常的情况
function HttpManager:rollBackOrderStatus(orderType, orderid, orderInfo, callback, isNeedWait, retryType) --type_id 1/2
    callback = self:createGetResponseFunction(callback)
    orderInfo.order_id = orderid
    self:retryPostWithHeader(DOMAIN .. "rollback_order_status/" .. orderType, orderInfo, nil, callback, isNeedWait, retryType)
end

--获取首充奖励列表
function HttpManager:getFirstFestivalGiftList(callback, isNeedWait, retryType)
    callback = self:createGetResponseFunction(callback)
    self:retryGetWithHeader(DOMAIN .. "get_first_festival_gift", nil, nil, callback, isNeedWait, retryType)
end

--领取首充奖励
function HttpManager:getFirstFestivalGift(orderid, callback, isNeedWait, retryType)
    callback = self:createGetResponseFunction(callback)
    if PRINT_MODE == 1 then
        print("领取首充奖励向服务器Pos的order_id:" .. orderid)
    end
    self:retryPostWithHeader(DOMAIN .. "receive_first_festival_gift", {order_id = orderid, key = 1}, nil, callback, isNeedWait, retryType)
end

--获取累计充值奖励状态列表
function HttpManager:getMultiFestivalGiftList(callback, isNeedWait, retryType)
    callback = self:createGetResponseFunction(callback)
    self:retryGetWithHeader(DOMAIN .. "get_multi_festival_gift_list", nil, nil, callback, isNeedWait, retryType)
end

--领取累计充值奖励
function HttpManager:getMultiFestivalGift(kry, orderid, itemId, callback, isNeedWait, retryType)
    callback = self:createGetResponseFunction(callback)
    if PRINT_MODE == 1 then
        print("领取充值奖励时传入参数 key:" .. kry .. " order_id:" .. orderid)
    end
    if itemId ~= nil then
        self:retryPostWithHeader(DOMAIN .. "receive_multi_festival_gift", {key = kry, order_id = orderid, item_id = itemId}, nil, callback, isNeedWait, retryType)
    else
        self:retryPostWithHeader(DOMAIN .. "receive_multi_festival_gift", {key = kry, order_id = orderid}, nil, callback, isNeedWait, retryType)
    end
end

-- 获取活动列表
function HttpManager:getSpringFestivalList(callback, isNeedWait, retryType)
    callback = self:createGetResponseFunction(callback)
    self:retryGetWithHeader(DOMAIN .. "get_spring_festival_list", nil, nil, callback, isNeedWait, retryType)
end

-- 制作组副本角色列表
function HttpManager:getZhiZuoZuRoleList(callback, isNeedWait, retryType)
    callback = self:createGetResponseFunction(callback)
    self:retryGetWithHeader(DOMAIN .. "get_npc_list", nil, nil, callback, isNeedWait, retryType)
end

-- 增加制作组某角色任务次数
function HttpManager:addZhiZuoZuNpcRecord(npcId, callback, isNeedWait, retryType)
    callback = self:createGetResponseFunction(callback)
    self:retryGetWithHeader(DOMAIN .. "add_npc_record/" .. npcId, nil, nil, callback, isNeedWait, retryType)
end

-- 获取制作组商人列表
function HttpManager:getMaskList(callback, isNeedWait, retryType)
    callback = self:createGetResponseFunction(callback)
    self:retryGetWithHeader(DOMAIN .. "get_mask_list", nil, nil, callback, isNeedWait, retryType)
end

--刷新制作组商人列表
function HttpManager:refreshMaskList(orderid, callback, isNeedWait, retryType)
    callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "refresh_mask_list", {order_id = orderid}, nil, callback, isNeedWait, retryType)
end

-- 购买面具
function HttpManager:buyMaskPiece(orderid, id, callback, isNeedWait, retryType)
    callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "buy_mask_piece_2", {order_id = orderid, id = id}, nil, callback, isNeedWait, retryType)
end

-- 获取指定用户活动总积分
function HttpManager:getDailyPoint(callback, isNeedWait, retryType)
    callback = self:createGetResponseFunction(callback)
    self:retryGetWithHeader(DOMAIN .. "get_daily_point", nil, nil, callback, isNeedWait, retryType)
end

-- 更新活动积分 {type_id为0时是放风筝活动，为1时是答题活动}
function HttpManager:updateDailyPoint(id, point, callback, isNeedWait, retryType)
    callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "update_daily_point/" .. id, {point = point}, nil, callback, isNeedWait, retryType)
end

-- 活动积分榜
function HttpManager:getDailyBoard(callback, isNeedWait, retryType)
    callback = self:createGetResponseFunction(callback)
    self:retryGetWithHeader(DOMAIN .. "get_daily_board", nil, nil, callback, isNeedWait, retryType)
end

--赛龙舟积分榜
function HttpManager:getLongZhouDailyBoard(type, callback, isNeedWait, retryType)
    callback = self:createGetResponseFunction(callback)
    self:retryGetWithHeader(DOMAIN .. "get_boat_board/" .. type, nil, nil, callback, isNeedWait, retryType)
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/03/09 10:16:00
-- @desc 获取OrderId
function HttpManager:getBuyOrderId(callback, isNeedWait, retryType)
    callback = self:createGetResponseFunction(callback)
    self:retryGetWithHeader(DOMAIN .. "get_buy_order_id", nil, nil, callback, isNeedWait, retryType)
end

--春分活动
function HttpManager:getAllTypePoint(callback, isNeedWait, retryType)
    callback = self:createGetResponseFunction(callback)
    self:retryGetWithHeader(DOMAIN .. "get_all_type_point", nil, nil, callback, isNeedWait, retryType)
end
-- function HttpManager:getDailyBoard(callback, isNeedWait, retryType)
--     callback = self:createGetResponseFunction(callback)
--     self:retryGetWithHeader(DOMAIN.."get_daily_board", nil, nil, callback, isNeedWait, retryType)
-- end
function HttpManager:getDailyNotice(callback, isNeedWait, retryType)
    callback = self:createGetResponseFunction(callback)
    self:retryGetWithHeader(DOMAIN .. "get_daily_Notice", nil, nil, callback, isNeedWait, retryType)
end
--获取春分奖励列表
function HttpManager:getDailyRewardList(callback, isNeedWait, retryType)
    callback = self:createGetResponseFunction(callback)
    self:retryGetWithHeader(DOMAIN .. "get_daily_reward_list", nil, nil, callback, isNeedWait, retryType)
end
--领取春分奖励
function HttpManager:getDailyReward(transid, callback, isNeedWait, retryType)
    callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "get_daily_reward", {trans_id = transid}, nil, callback, isNeedWait, retryType)
end
--重置领取状态
function HttpManager:rollDailyReward(callback, isNeedWait, retryType)
    callback = self:createGetResponseFunction(callback)
    self:retryGetWithHeader(DOMAIN .. "roll_daily_reward", nil, nil, callback, isNeedWait, retryType)
end

--获取是否有未查看的活动
function HttpManager:getEventList(type, callback, isNeedWait, retryType)
    callback = self:createGetResponseFunction(callback)
    self:retryGetWithHeader(DOMAIN .. "get_activity_list/" .. type, nil, nil, callback, isNeedWait, retryType)
end
function HttpManager:delActivityCache(callback, isNeedWait, retryType)
    callback = self:createGetResponseFunction(callback)
    self:retryGetWithHeader(DOMAIN .. "del_activity_cache", nil, nil, callback, isNeedWait, retryType)
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 师门商人部分接口

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/03/27 11:52:58
-- @desc 获取贡献点
--[[
    response
    {"errcode":0,'data':{"dev_point":dev_point}}
]]
function HttpManager:getDevotePoint(callback, isNeedWait, retryType)
    callback = self:createGetResponseFunction(callback)
    self:retryGetWithHeader(DOMAIN .. "get_devote_point", nil, nil, callback, isNeedWait, retryType)
    -- callback(200, 0, "", Helper:getDef({dev_point = 100000000}, {}), true)
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/03/27 11:58:29
-- @desc 请安获得贡献点
--[[add_devote_point/ptype
1是请安 2是每日挑战任务  3是飞贼任务
get方式
response
{"errcode":0,"msg":‘获得贡献点’}
  {"errcode":1,"errmsg":‘获取贡献点失败’}
{"errcode":2,"msg":‘类型参数为空’}
  {"errcode":3,"errmsg":‘已达到当日贡献点获取上限’}
  {"errcode":4,"errmsg":‘类型错误’}
]]
function HttpManager:addDevotePoint(ptype, point, callback, isNeedWait, retryType)
    if ptype == nil then
        return
    end
    callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "add_devote_point", {type = ptype, point = point}, nil, callback, isNeedWait, retryType)
    -- callback(200, 0, "msg = 获得1000贡献点", Helper:getDef({}, {}), true)
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/03/27 11:59:58
-- @desc 获取残本列表
--[[get_devote_list
get方式
response
 {"errcode":0,"data":  [{"id":3147,"itemId":"leidongjiutian","itype":4,"inde":0,"name":"雷动九天","price":280,"number":1,"dsc1":"特殊技能","dsc2":"","share":null,"icon":null,"strong":1},  {"id":3152,"itemId":"liumaishenjian","itype":4,"inde":0,"name":"六脉神剑","price":187,"number":1,"dsc1":"特殊技能","dsc2":"","share":null,"icon":null,"strong":2}
  ]}
]]
function HttpManager:getDevoteList(dtype, menpai, callback, isNeedWait, retryType)
    if PRINT_MODE == 1 then
        print("HttpManager:getDevoteList(dtype, menpai, callback,isNeedWait,retryType)", dtype, menpai)
    end
    if dtype == nil or menpai == nil then
        return
    end
    callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "get_devote_list", {type = dtype, menpai = menpai}, nil, callback, isNeedWait, retryType)
    --     callback(200, 0, "", Helper:getDef(
    -- {
    --     { count = 1, itemId = "huakaibingdicanye", id = 711, status = 0},
    --     { count = 1, itemId = "tiyunzongcanye", id = 712, status = 0},
    -- }, {}), true)
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/03/28 15:00:25
-- @desc 元宝刷新贡献商人物品列表
--[[
{"errcode":0,'data':[{"id":3147,"itemId":"leidongjiutian","itype":4,"inde":0,"name":"雷动九天","price":280,"number":1,"dsc1":"特殊技能","dsc2":"","share":null,"icon":null,"strong":1},  {"id":3152,"itemId":"liumaishenjian","itype":4,"inde":0,"name":"六脉神剑","price":187,"number":1,"dsc1":"特殊技能","dsc2":"","share":null,"icon":null,"strong":2}
  ]}
{"errcode":2,'errmsg' :'没有足够的元宝'}
{"errcode":3,'errmsg' : '消耗元宝操作失败'}
{"errcode":4,'errmsg' : '刷新残本列表失败'}
]]
function HttpManager:getDevoteListByYuanbao(dtype, orderid, menpai, callback, isNeedWait, retryType)
    if dtype == nil or orderid == nil or menpai == nil then
        return
    end
    callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "get_devote_list_by_yuanbao", {order_id = orderid, type = dtype, menpai = menpai}, nil, callback, isNeedWait, retryType)
    -- callback(200, 0, "", Helper:getDef(
    -- {
    --     { count = 1, itemId = "huakaibingdicanye", id = 711, status = 0},
    --     { count = 1, itemId = "tiyunzongcanye", id = 712, status = 0},
    -- }, {}), true)
    -- self:retryGetWithHeader(DOMAIN.."get_devote_list_by_yuanbao",nil, nil, callback, isNeedWait, retryType)
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/03/27 12:07:44
-- @desc 更新门派贡献点
--[[
update_menpai_gongxiangdian
post方法
REQUEST
{
    "order_id": ORDERID, #call get_buy_order_id
    "points": 10|-10

}
RESPONSE
{"errcode": 0}]]
function HttpManager:updateMenpaiGongxiangdian(orderid, itemId, points, info, callback, isNeedWait, retryType)
    if orderid == nil or itemId == nil or points == nil or MapIsEmpty(info) == true then
        return
    end
    callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "update_menpai_gongxiangdian", {order_id = orderid, itemId = itemId, points = points, orderInfo = info}, nil, callback, isNeedWait, retryType)
    -- callback(200, 0, "", Helper:getDef({}, {}), true)
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- NPC商人商品列表
function HttpManager:getChapmanItemList(npcId, callback, isNeedWait, retryType)
    callback = self:createGetResponseFunction(callback)
    self:retryGetWithHeader(DOMAIN .. "trader_store/" .. npcId, nil, nil, callback, isNeedWait, retryType)
end

-- NPC商人商品购买
function HttpManager:buyChapmanItem(npcId, itemId, transid, voucherNum, callback, isNeedWait, retryType)
    callback = self:createGetResponseFunction(callback)
    voucherNum = Helper:getDef(math.abs(voucherNum), 0)
    self:retryPostWithHeader(DOMAIN .. "buy_trader_goods", {npc_id = npcId, itemId = itemId, client_trans_id = transid, voucher_num = voucherNum}, nil, callback, isNeedWait, retryType)
end

-- NPC商人商品购买次数增加
function HttpManager:addChapmanItemCount(npcId, itemId, callback, isNeedWait, retryType)
    callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "del_buy_npc_time", {npc_id = npcId, itemId = itemId}, nil, callback, isNeedWait, retryType)
end

-- 清明活动
-- 添加冥币 id 1抓鬼 2生死簿 3奈何桥
function HttpManager:addDeadCurrency(id, number, isNeed, callback, isNeedWait, retryType)
    callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "add_user_mingbi", {type = id, number = number, isNeed = isNeed}, nil, callback, isNeedWait, retryType)
end

-- 获取冥币商品列表
function HttpManager:getDeadCurrencyGoodsList(callback, isNeedWait, retryType)
    callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "get_mingbi_list", nil, nil, callback, isNeedWait, retryType)
end

-- 冥币购买商品
function HttpManager:buyDeadCurrencyGoods(orderid, id, callback, isNeedWait, retryType)
    callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "buy_mingbi_goods", {order_id = orderid, id = id}, nil, callback, isNeedWait, retryType)
end
function HttpManager:getHelpDocument(callback, isNeedWait, retryType)
    callback = self:createGetResponseFunction(callback)
    self:retryGetWithHeader(DOMAIN .. "get_help_document", nil, nil, callback, isNeedWait, retryType)
end

--4399签到
function HttpManager:getVoucherPrize(voucherId, activityId, callback, isNeedWait, retryType)
    callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "get_voucher_prize_2", {voucher = voucherId, activity_id = activityId}, nil, callback, isNeedWait, retryType)
end

--测试接口不提交正式服
function HttpManager:cleanVoucherRecord(callback, isNeedWait, retryType)
    callback = self:createGetResponseFunction(callback)
    self:retryGetWithHeader(DOMAIN .. "clean_voucher_record_2", nil, nil, callback, isNeedWait, retryType)
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 进京赶考相关接口

-- 检测能否参加进京赶考 考试 0 乡试 1 省试 2 殿试
function HttpManager:checkCanExam(id, callback, isNeedWait, retryType)
    callback = self:createGetResponseFunction(callback)
    self:retryGetWithHeader(DOMAIN .. "check_whether_exam/" .. id, nil, nil, callback, isNeedWait, retryType)
end

-- 上传进京赶考分数 0 乡试 1 省试 2 殿试
-- “type”:1或2
-- “rightCount”:省试 的答对题目，殿试的时候传0
-- “point”:考试的分数
-- “time”:考试用时
-- “skillExp”: 读书识字等级
-- “cheat”:省试的时候为0为作弊没被抓，1为作弊被抓；殿试的时候传0（没作弊选项）
function HttpManager:updateExamPoint(id, rightCount, point, time, skillExp, cheat, callback, isNeedWait, retryType)
    callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "upload_exam_point", {type = id, rightCount = rightCount, point = point, time = time, skillExp = skillExp, cheat = cheat}, nil, callback, isNeedWait, retryType)
end

-- 获取进京赶考分数和当前排名 1 省试 2 殿试
function HttpManager:getExamPoint(id, callback, isNeedWait, retryType)
    callback = self:createGetResponseFunction(callback)
    self:retryGetWithHeader(DOMAIN .. "get_exam_point/" .. id, nil, nil, callback, isNeedWait, retryType)
end

-- 结算奖励 1 省试 2殿试
function HttpManager:generateExamReward(id, callback, isNeedWait, retryType)
    callback = self:createGetResponseFunction(callback)
    self:retryGetWithHeader(DOMAIN .. "crontab_gen_exam_reward/" .. id, nil, nil, callback, isNeedWait, retryType)
end

-- 获得奖励 1省试 2殿试
function HttpManager:getExamReward(id, orderid, callback, isNeedWait, retryType)
    callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "get_exam_reward", {trans_id = orderid, type = id}, nil, callback, isNeedWait, retryType)
end

-- 删除用户排名奖励
-- 结算奖励
function HttpManager:delUserRankReward(callback, isNeedWait, retryType)
    callback = self:createGetResponseFunction(callback)
    self:retryGetWithHeader(DOMAIN .. "delete_user_point_rank", nil, nil, callback, isNeedWait, retryType)
end

-- 删除用户分数
function HttpManager:delUserPoint(callback, isNeedWait, retryType)
    callback = self:createGetResponseFunction(callback)
    self:retryGetWithHeader(DOMAIN .. "delete_user_point", nil, nil, callback, isNeedWait, retryType)
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 官职系统相关
-- 获取当前是否拥有官职 每次进游戏时调用
function HttpManager:getUserOfficial(callback, isNeedWait, retryType)
    callback = self:createGetResponseFunction(callback)
    self:retryGetWithHeader(DOMAIN .. "get_user_guanzhi", nil, nil, callback, isNeedWait, retryType)
end

-----------------------------------------------------------------------------------------------------------
-- @author ZhangShengTang
-- @time 2017/08/09 16:26:08
-- @desc 获得服务器称号
function HttpManager:getChenHao(callback, isNeedWait, retryType)
    callback = self:createGetResponseFunction(callback)
    self:retryGetWithHeader(DOMAIN .. "get_user_designation", nil, nil, callback, isNeedWait, retryType)
end

-----------------------------------------------------------------------------------------------------------
-- @author ZhangShengTang
-- @time 2017/08/09 14:11:39
-- @desc 领取俸禄
function HttpManager:getFenLu(callback, isNeedWait, retryType)
    callback = self:createGetResponseFunction(callback)
    self:retryGetWithHeader(DOMAIN .. "get_guanzhi_fenlu", nil, nil, callback, isNeedWait, retryType)
end

-- 上传政绩
function HttpManager:uploadOfficialAchievement(zhengji, guanzhi, callback, isNeedWait, retryType)
    callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "upload_zhengji", {zhengji = zhengji, guanzhi = guanzhi}, nil, callback, isNeedWait, retryType)
end

-- 辞官
function HttpManager:officialResignation(callback, isNeedWait, retryType)
    callback = self:createGetResponseFunction(callback)
    self:retryGetWithHeader(DOMAIN .. "delete_my_guanzhi", nil, nil, callback, isNeedWait, retryType)
end

-- 删除辞官7天内不能再考试
function HttpManager:delOfficialLimit(callback, isNeedWait, retryType)
    callback = self:createGetResponseFunction(callback)
    self:retryGetWithHeader(DOMAIN .. "delete_ciguan_redis", nil, nil, callback, isNeedWait, retryType)
end

-- 删除经京赶考 和官员记录 所有
function HttpManager:delExamAllData(callback, isNeedWait, retryType)
    callback = self:createGetResponseFunction(callback)
    self:retryGetWithHeader(DOMAIN .. "delete_all_data", nil, nil, callback, isNeedWait, retryType)
end

-- 每周结算政绩 测试用
function HttpManager:calaOfficialAchievement(callback, isNeedWait, retryType)
    callback = self:createGetResponseFunction(callback)
    self:retryGetWithHeader(DOMAIN .. "crontab_count_zhengji", nil, nil, callback, isNeedWait, retryType)
end

-- --端午活动
-- function HttpManager:getDailyRewardList(callback,isNeedWait,retryType)
--     callback = self:createGetResponseFunction(callback)
--     self:retryGetWithHeader(DOMAIN.."get_daily_reward_list", nil, nil, callback, isNeedWait, retryType)
-- end
--获取端午活动个人积分
function HttpManager:getPersonalBoatScore(familyId, callback, isNeedWait, retryType)
    callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "personal_boat_msg", {menpai = familyId}, nil, callback, isNeedWait, retryType)
end
--端午活动积分排行榜
function HttpManager:getAllFamilyScore(callback, isNeedWait, retryType)
    callback = self:createGetResponseFunction(callback)
    self:retryGetWithHeader(DOMAIN .. "all_menpai_top", nil, nil, callback, isNeedWait, retryType)
end
--获取端午奖励列表
function HttpManager:getBoatRewardList(callback, isNeedWait, retryType)
    callback = self:createGetResponseFunction(callback)
    self:retryGetWithHeader(DOMAIN .. "can_get_duanwu_reward", nil, nil, callback, isNeedWait, retryType)
end
--领取端午奖励
function HttpManager:getBoatReward(transid, itype, callback, isNeedWait, retryType)
    callback = self:createGetResponseFunction(callback)
    print("transid====================================:", transid)
    self:retryPostWithHeader(DOMAIN .. "get_boat_reward", {trans_id = transid, type = itype}, nil, callback, isNeedWait, retryType)
end
--获取端午活动奖励列表内容
function HttpManager:getDuanwuRewardNotice(type, callback, isNeedWait, retryType)
    callback = self:createGetResponseFunction(callback)
    self:retryGetWithHeader(DOMAIN .. "get_duanwu_reward_notice/" .. type, nil, nil, callback, isNeedWait, retryType)
end
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 赛龙舟
-- 检测是否可参加赛龙舟
function HttpManager:checkCanJoinDragonBoat(callback, isNeedWait, retryType)
    callback = self:createGetResponseFunction(callback)
    self:retryGetWithHeader(DOMAIN .. "check_can_play_boat", nil, nil, callback, isNeedWait, retryType)
end

-- 上传积分
function HttpManager:updateDragonBoatPoint(menpai, point, time, callback, isNeedWait, retryType)
    callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "update_boat_point", {menpai = menpai, point = point, time = time}, nil, callback, isNeedWait, retryType)
end

--测试端午活动接口
function HttpManager:resetDuanWuReward(callback, isNeedWait, retryType)
    callback = self:createGetResponseFunction(callback)
    self:retryGetWithHeader(DOMAIN .. "test_reset_my_reward", nil, nil, callback, isNeedWait, retryType)
end

--
function HttpManager:getRankingListByOne(id, callback, isNeedWait, retryType)
    callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "get_board/" .. id, nil, nil, callback, isNeedWait, retryType)
end

--江湖三友的进入接口
function HttpManager:getJhSanYouList(callback, isNeedWait, retryType)
    callback = self:createGetResponseFunction(callback)
    self:retryGetWithHeader(DOMAIN .. "get_jhsanyou_list", nil, nil, callback, isNeedWait, retryType)
end

--江湖三友投票的接口
function HttpManager:voteToJhsanyou(type, id, callback, isNeedWait, retryType)
    callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "vote_to_jhsanyou", {itype = type, npcId = id}, nil, callback, isNeedWait, retryType)
end

--清除江湖好友的投票次数
function HttpManager:clearApiData(str, callback, isNeedWait, retryType)
    callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "clear_api_data", {act = str}, nil, callback, isNeedWait, retryType)
end
-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/06/20 16:57:17
-- @desc 周年庆获取积分兑换列表
function HttpManager:getShopInfo(shopId, callback, isNeedWait, retryType)
    callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "get_shop_info", {shop_id = shopId}, nil, callback, isNeedWait, retryType)
end

-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/06/20 17:00:59
-- @desc 积分兑换
-- itemId，client_trans_id， shop_id
-- tab = {
--     itemId = ,
--     client_trans_id =
--     shop_id =
-- }
function HttpManager:shopExchangeGoods(tab, callback, isNeedWait, retryType)
    callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "shop_exchange_goods", tab, nil, callback, isNeedWait, retryType)
end

-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/06/20 17:03:47
-- @desc 积分兑换回滚

function HttpManager:rollBackExchage(transid, callback, isNeedWait, retryType)
    callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "roll_back_exchange", {client_trans_id = transid}, nil, callback, isNeedWait, retryType)
end

-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/06/21 17:57:09
-- @desc 周年庆活动积分上传
-- local tab = {
--    shop_id = "zhounianqin1",
--    number = 10 --增加的积分值
-- }
function HttpManager:addCurrency(tab, callback, isNeedWait, retryType)
    callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "add_currency", tab, nil, callback, isNeedWait, retryType)
end

-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/06/26 12:05:11
-- @desc 清除兑换次数,测试使用
function HttpManager:clearShopRecord(shopId, callback, isNeedWait, retryType)
    callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "clear_my_shop_record", {shop_id = shopId}, nil, callback, isNeedWait, retryType)
end

-- 添加活动积分
function HttpManager:addActivityPoint(point, activityId, callback, isNeedWait, retryType)
    callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "add_currency", {number = point, shop_id = activityId}, nil, callback, isNeedWait, retryType)
end

-- 重置活动积分
function HttpManager:clearPointRecord(activityId, callback, isNeedWait, retryType)
    callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "clear_my_shop_record", {shop_id = activityId}, nil, callback, isNeedWait, retryType)
end

-- 增加活动记录
--[[
    stat_data =
    {
         # id 方式名称 调息情况,统计香薰炉使用情况,统计真气丹&经脉丹&醒身丸使用情况
        {"act": "keyao", "id":"tiaoxi", "t": UNIXTIME}
        #id 统计玩家治疗暗疾小游戏过关的情况, 1通过完成小游戏过关, 2通过服用春元丹过关,3通过服用安神丹过关,4找师傅解决
        {"act": "game", "id":1, "t": UNIXTIME}
    }
]]
function HttpManager:addRecordCount(stat_data, callback, isNeedWait, retryType)
    callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "upload_fzjh_stat", {stat_data = stat_data}, nil, callback, isNeedWait, retryType)
end
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2017/06/27 22:05:19
-- @desc 获取服务器列表
function HttpManager:getServerList(callback, isNeedWait, retryType)
    callback = self:createGetResponseFunction(callback)
    self:retryGetWithHeader(DOMAIN .. "get_partition_list", "", nil, callback, isNeedWait, retryType)
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2017/06/28 22:53:21
-- @desc 继承角色
function HttpManager:migrateToNewPackage(email, code, callback, isNeedWait, retryType)
    callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "migrate_to_new_package", {email = email, verify_code = code}, nil, callback, isNeedWait, retryType)
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2017/06/28 22:56:43
-- @desc 切换分区
function HttpManager:switchServer(id, callback, isNeedWait, retryType)
    callback = self:createGetResponseFunction(callback)
    self:retryGetWithHeader(DOMAIN .. "switch_partition/" .. id, "", nil, callback, isNeedWait, retryType)
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2017/06/27 22:05:19
-- @desc 获取服务器列表
function HttpManager:getServerList2(callback, isNeedWait, retryType)
    callback = self:createGetResponseFunction(callback)
    self:retryGetWithHeader(DOMAIN .. "get_partition_list2", "", nil, callback, isNeedWait, retryType)
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2017/06/28 22:56:43
-- @desc 切换分区
function HttpManager:switchServer2(id, callback, isNeedWait, retryType)
    callback = self:createGetResponseFunction(callback)
    self:retryGetWithHeader(DOMAIN .. "switch_partition2/" .. id, "", nil, callback, isNeedWait, retryType)
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2017/06/28 22:53:21
-- @desc 继承角色
function HttpManager:migrateToNewPackage2(email, code, serverId, callback, isNeedWait, retryType)
    callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "migrate_to_new_package2", {email = email, verify_code = code, serverId = serverId}, nil, callback, isNeedWait, retryType)
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2017/06/29 17:45:21
-- @desc 清除分区记录
function HttpManager:partitionClear(callback, isNeedWait, retryType)
    callback = self:createGetResponseFunction(callback)
    self:retryGetWithHeader(DOMAIN .. "partition_clear", "", nil, callback, isNeedWait, retryType)
end

-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/06/30 09:59:06
-- @desc 测试接口。充值当天 充值特惠活动
function HttpManager:testReceiveAnniversaryReward(date, callback, isNeedWait, retryType)
    callback = self:createGetResponseFunction(callback)
    self:retryGetWithHeader(DOMAIN .. "test_receive_anniversary_reward/" .. tostring(date), nil, nil, callback, isNeedWait, retryType)
end

-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/06/30 10:01:32
-- @desc 测试接口 重置测试数据 充值特惠活动
function HttpManager:resetAnniversaryRewardList(callback, isNeedWait, retryType)
    callback = self:createGetResponseFunction(callback)
    self:retryGetWithHeader(DOMAIN .. "reset_anniversary_reward_list", nil, nil, callback, isNeedWait, retryType)
end

-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/06/30 10:03:48
-- @desc 获取奖励列表 充值特惠活动
function HttpManager:getAnniversaryRewardList(callback, isNeedWait, retryType)
    callback = self:createGetResponseFunction(callback)
    self:retryGetWithHeader(DOMAIN .. "get_anniversary_reward_list", nil, nil, callback, isNeedWait, retryType)
end
-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/06/30 10:05:17
-- @desc 领取奖励 充值特惠活动
function HttpManager:getAnniversaryReward(rewardList, callback, isNeedWait, retryType)
    callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "get_anniversary_reward", {list = rewardList}, nil, callback, isNeedWait, retryType)
end

--充值抽奖领周边
function HttpManager:getUserUploadInfo(callback, isNeedWait, retryType)
    callback = self:createGetResponseFunction(callback)
    self:retryGetWithHeader(DOMAIN .. "get_user_upload_info", nil, nil, callback, isNeedWait, retryType)
end
-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/07/04 15:31:53
-- @desc 上传信息
function HttpManager:saveUserInfo(phoneStr, addrStr, nameStr, qqStr, callback, isNeedWait, retryType)
    callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "save_user_info", {phone = phoneStr, address = addrStr, name = nameStr, qq = qqStr}, nil, callback, isNeedWait, retryType)
end
-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/07/04 15:32:07
-- @desc 测试接口 充值
function HttpManager:addMoneyCeiling(money, callback, isNeedWait, retryType)
    callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "add_money_ceiling", {number = money}, nil, callback, isNeedWait, retryType)
end
--师门任务指派的师门玩家列表
function HttpManager:getTeacherTaskPointList(posList, callback, isNeedWait, retryType)
    if not posList then
        return
    end
    callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "get_same_menpai_user_list", posList, nil, callback, isNeedWait, retryType)
end
--上传一个指派记录
function HttpManager:addTeacherTaskRecord(posList, callback, isNeedWait, retryType)
    if not posList then
        return
    end
    Helper:print_lua_table(posList)
    callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "add_zhipai_task_record", posList, nil, callback, isNeedWait, retryType)
end

--获取指派任务历史记录
function HttpManager:getTeacherTaskRecord(callback, isNeedWait, retryType)
    callback = self:createGetResponseFunction(callback)
    self:retryGetWithHeader(DOMAIN .. "get_zhipai_task_record", nil, nil, callback, isNeedWait, retryType)
end
--领取指派任务奖励
function HttpManager:getTeacherTaskRewaard(rewardId, callback, isNeedWait, retryType)
    callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "get_zhipai_task_reward", {reward_id = rewardId}, nil, callback, isNeedWait, retryType)
end
--刷新任务列表扣除元宝
function HttpManager:refreshTeacherTaskList(count, callback, isNeedWait, retryType)
    callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "fresh_task_by_yuanbao", {yuanbao = count}, nil, callback, isNeedWait, retryType)
end
--师门任务测试接口
function HttpManager:resetTeacherTask(type, callback, isNeedWait, retryType)
    callback = self:createGetResponseFunction(callback)
    self:retryGetWithHeader(DOMAIN .. "test_reset_task/" .. type, nil, nil, callback, isNeedWait, retryType)
end

-----------------------------------------------------------------------------------------------------------
--[[ 七夕活动相关接口 ]]
--获取最近祈福过的人
function HttpManager:getWishList2(callback, isNeedWait, retryType)
    callback = self:createGetResponseFunction(callback)
    self:retryGetWithHeader(DOMAIN .. "get_wish_list/2", nil, nil, callback, isNeedWait, retryType)
end

--获取我的祈愿
function HttpManager:getWishList1(callback, isNeedWait, retryType)
    callback = self:createGetResponseFunction(callback)
    self:retryGetWithHeader(DOMAIN .. "get_wish_list/1", nil, nil, callback, isNeedWait, retryType)
end

--上传祈福数据
function HttpManager:uploadWishData(wishVal, wishType, wishId, callback, isNeedWait, retryType)
    callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "upload_wish_data", {wish_val = wishVal, wish_type = wishType, wish_id = wishId}, nil, callback, isNeedWait, retryType)
end

--祝福
function HttpManager:recordWishedData(recordId, wishUserId, callback, isNeedWait, retryType)
    callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "record_wished_data", {record_id = recordId, wish_userid = wishUserId}, nil, callback, isNeedWait, retryType)
end

--获取自己有的奖励信息来判断背包是否足够
function HttpManager:getSeventhReward1(callback, isNeedWait, retryType)
    callback = self:createGetResponseFunction(callback)
    self:retryGetWithHeader(DOMAIN .. "get_seventh_reward/1", nil, nil, callback, isNeedWait, retryType)
end

--领取七日奖励
function HttpManager:getSeventhReward2(callback, isNeedWait, retryType)
    callback = self:createGetResponseFunction(callback)
    self:retryGetWithHeader(DOMAIN .. "get_seventh_reward/2", nil, nil, callback, isNeedWait, retryType)
end

--应缘
function HttpManager:findRoommate(roommateId, roomId, callback, isNeedWait, retryType)
    callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "find_roommate", {roommate_id = roommateId, room_id = roomId}, nil, callback, isNeedWait, retryType)
end

--测试用 清除七夕每日祈福限制
function HttpManager:TestWish1(callback, isNeedWait, retryType)
    callback = self:createGetResponseFunction(callback)
    self:retryGetWithHeader(DOMAIN .. "test_wish/1", nil, nil, callback, isNeedWait, retryType)
end

--测试用 清除七夕祝福同一条记录
function HttpManager:TestWish3(callback, isNeedWait, retryType)
    callback = self:createGetResponseFunction(callback)
    self:retryGetWithHeader(DOMAIN .. "test_wish/3", nil, nil, callback, isNeedWait, retryType)
end

--测试用 清除应缘记录
function HttpManager:TestWish4(callback, isNeedWait, retryType)
    callback = self:createGetResponseFunction(callback)
    self:retryGetWithHeader(DOMAIN .. "test_wish/4", nil, nil, callback, isNeedWait, retryType)
end

--测试用 清除个人祈福应缘记录
function HttpManager:TestWish5(callback, isNeedWait, retryType)
    callback = self:createGetResponseFunction(callback)
    self:retryGetWithHeader(DOMAIN .. "test_wish/5", nil, nil, callback, isNeedWait, retryType)
end

--梦回七夕奖励,七夕情缘奖励等活动任务人数统计     --增加每日论剑的统计   add_record/lunjian_级别_是否传承
function HttpManager:resetActiveTask(type, callback, isNeedWait, retryType)
    callback = self:createGetResponseFunction(callback)
    self:retryGetWithHeader(DOMAIN .. "add_record/" .. type, nil, nil, callback, isNeedWait, retryType)
end

-- @author GaoHanZheng
-- @time 2017/08/24 17:02:56
-- @desc 七夕消耗活动
--获取消耗列表信息
function HttpManager:getYuanBaoCostGiftList(callback, isNeedWait, retryType)
    callback = self:createGetResponseFunction(callback)
    self:retryGetWithHeader(DOMAIN .. "get_yuanbao_plan_gift_list", nil, nil, callback, isNeedWait, retryType)
end

--领取消耗奖励
function HttpManager:receiveYuanBaoPlanGift(num, callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "receive_yuanbao_plan_gift", {reward_lv = num}, nil, callback, isNeedWait, retryType)
end

--测试接口
function HttpManager:testWish(num, callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryGetWithHeader(DOMAIN .. "test_wish/" .. tostring(num), nil, nil, callback, isNeedWait, retryType)
end

--统计接口 type可以是字符串，lunghunshi
function HttpManager:countSingleRecordWithType(type, callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryGetWithHeader(DOMAIN .. "count_single_record/" .. tostring(type), nil, nil, callback, isNeedWait, retryType)
end
-----------------------------------------------------------------------------------------------------------
--中元节
function HttpManager:getPlayGhost(callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryGetWithHeader(DOMAIN .. "get_random_userdata", nil, nil, callback, isNeedWait, retryType)
end
--中元节送礼
-- function HttpManager:addCurrencyByType(list,callback, isNeedWait, retryType)
--     if type(list) ~= "table" then
--         return
--     end
--     local callback = self:createGetResponseFunction(callback)
--     self:retryPostWithHeader(DOMAIN.."update_currency_by_type", {currency = list,action = "add"}, nil, callback, isNeedWait, retryType)
-- end

-- 查看 美誉,冥币等数量
-- type [meiyu,gongxiandian,mingbi,baoyu]
function HttpManager:viewCurrencyByType(currency_type, callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "view_currency_by_type", {currency_type = currency_type}, nil, callback, isNeedWait, retryType)
end

--中元节活动
--增加冥币
function HttpManager:addCurrencyByType(num, callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "add_currency_by_type", {currency = {mingbi = num}}, nil, callback, isNeedWait, retryType)
end

--鬼差任务参加次数
function HttpManager:joinGhostTimes(callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryGetWithHeader(DOMAIN .. "count_single_record/join_ghost", nil, nil, callback, isNeedWait, retryType)
end

--鬼差任务完成次数
function HttpManager:finishGhostTimes(callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryGetWithHeader(DOMAIN .. "count_single_record/finish_ghost", nil, nil, callback, isNeedWait, retryType)
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/08/31 19:39:57
-- @desc 货币扣除接口
-- action add/remove
-- cType meiyu/gongxiandian/mingbi/baoyu/yinpiao/spcl
-- count 数量 必须是数字类型
function HttpManager:updateCurrencyByType(action, cType, count, addType, callback, isNeedWait, retryType)
    if action == nil or cType == nil or type(count) ~= "number" then
        return
    end
    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "update_currency_by_type", {action = action, currency = {[cType] = count}, addType = addType}, nil, callback, isNeedWait, retryType)
end

--同时增加扣除多种货币
function HttpManager:updateCurrencyByTable(action, list, addType, callback, isNeedWait, retryType)
    if action == nil or type(list) ~= "table" then
        return
    end
    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "update_currency_by_type", {action = action, currency = list, addType = addType}, nil, callback, isNeedWait, retryType)
end

--___________________________________________________________________________________________________________
--师门任务商人
--获取商店列表
function HttpManager:getTeacherTaskShop(getType, familyId, callback, isNeedWait, retryType)
    callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "get_teacher_shop", {type = getType, menpai = familyId}, nil, callback, isNeedWait, retryType)
end

--购买
function HttpManager:buyTeacherTaskShopItem(id, callback, isNeedWait, retryType)
    callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "buy_teacher_good", {rid = id}, nil, callback, isNeedWait, retryType)
end

-----------------------------------------------------------------------------------------------------------
--调查问卷

--@desc: 添加单条记录
--@author:Liang Songqiang
--@time:2017-09-15 16:38:58
--@type: 记录
function HttpManager:addSingleRecord(type, callback, isNeedWait, retryType)
    callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "addSingleRecord", type, nil, callback, isNeedWait, retryType)
end

--@desc: 添加多条记录
--@author:Liang Songqiang
--@time:2017-09-15 16:39:25
--@type: 记录数组
function HttpManager:countMultiRecord(type, callback, isNeedWait, retryType)
    callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "count_multi_record", type, nil, callback, isNeedWait, retryType)
end

-----------------------------------------------------------------------------------------------------------
--内挂

--@desc: 上传内挂数据
--@author:Liang Songqiang
--@time:2017-10-20 15:33:24
--@type: 标识
--@data: 记录数组
function HttpManager:uploadClientData(type, data, callback, isNeedWait, retryType)
    callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "upload_client_data", {type = type, data = data}, nil, callback, isNeedWait, retryType)
end

--@desc: 查询数据
--@author:Liang Songqiang
--@time:2017-10-20 16:35:30
--@type: 查询标识
--@limit: 查询条数
--@return
function HttpManager:getClientData(tb, callback, isNeedWait, retryType)
    callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "get_client_data", {type = tb.type, offset = Helper:getDef(tb.offset, "0"), count = Helper:getDef(tb.count, "200")}, nil, callback, isNeedWait, retryType)
end

--@desc: 删除数据库对应标识的数据
--@author:Liang Songqiang
--@time:2017-10-23 15:20:41
--@type: 删除标识
function HttpManager:delAllData(type, callback, isNeedWait, retryType)
    callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "del_all_data", {type = type}, nil, callback, isNeedWait, retryType)
end

--比武新增
--汇报当前下台状态，服务器结算本日最大人气    get_out_fight_stage
function HttpManager:getBiWuFightEnd(func, isNeedWait, retryType)
    func = self:createGetResponseFunction(func)
    self:retryGetWithHeader(DOMAIN .. "get_out_fight_stage", "", nil, func, isNeedWait, retryType)
end

-- --增加每日论剑的统计   add_record/lunjian_级别_是否传承
-- function HttpManager:getBiWuFightEnd(role_lv,func, isNeedWait, retryType)
--     func = self:createGetResponseFunction(func)
--     self:retryGetWithHeader(DOMAIN.."add_record/lunjian"..tostring(role_lv), "", nil, func, isNeedWait, retryType)
-- end

function HttpManager:getActionState(id, postList, callback, isNeedWait, retryType) --postList 里面的信息不确定，由id确定，具体post数据与服务器协商
    callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "get_game_activity/" .. id, postList, nil, callback, isNeedWait, retryType)
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- add by XiaoZhiWei 2017/11/14 20:13:11 ios新版(fzjh)用户取消充值后汇报状态
function HttpManager:updateOrderState(callback, isNeedWait, retryType)
    callback = Helper:getDef(callback, EMPTY_FUNC)
    callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(string.gsub(DOMAIN, "api/v5/", "api/service/") .. "update_order_state", {cancel_flag = 1, channel = Game:getChannelId()}, nil, callback, isNeedWait, retryType)
end

--新版限时礼包，获取礼包内容
function HttpManager:getXianShiGiftBag(itemId, callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryGetWithHeader(DOMAIN .. "get_limit_package/" .. itemId, nil, nil, callback, isNeedWait, retryType)
end

-- add by XiaoZhiWei 2018/01/19 14:31:35 获取token
function HttpManager:getToken(callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryGetWithHeader(DOMAIN .. "get_token", nil, nil, callback, isNeedWait, retryType)
end
--清除每日孝敬次数
function HttpManager:resetDailyRecord(callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryGetWithHeader(DOMAIN .. "resetDailyRecord/1", nil, nil, callback, isNeedWait, retryType)
end

--@desc 神兵淬炼接口
--@wid: 武器ID
--@itemId: 淬炼物品ID
--@results: 淬炼结果 {itemId = {sucNum = 成功次数,defNum = 失败次数},itemId2 = {sucNum = 成功次数,defNum = 失败次数}}
function HttpManager:incrWeaponCuilianNum(wid, results, cuilianCount, callback, isNeedWait, retryType)
    if wid == nil or results == nil then
        if PRINT_MODE == 1 then
            print("wid 或者 results 为空")
        end
        return
    end

    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "incr_weapon_cuilian_num", {wid = wid, results = results, sum = cuilianCount}, nil, callback, isNeedWait, retryType)
end

--@desc: 筛除单条数据
--@id:筛除单条数据标识   id 在get_client_data  中以数组的key的形式传回
--@state: 状态
--@return
function HttpManager:updateDataState(tb, callback, isNeedWait, retryType)
    callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "update_data_state", {id = tb.id, state = Helper:getDef(tb.state, "0")}, nil, callback, isNeedWait, retryType)
end

--@desc 获取淬炼次数
function HttpManager:getWeaponCuilianNum(wid, itemId, callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "get_weapon_cuilian_num", {wid = wid, itemId = itemId}, nil, callback, isNeedWait, retryType)
end

--限时主动任务 师门孝敬（腊八施粥）
-- get方法
-- respect_teacher
-- {"errcode":0,"data":{"add_point":3000,"total_count":6}}
-- {"errcode":1,"errmsg":"你今天已经孝敬过师傅了"}
-- {"errcode":1,"errmsg":"已达累计上限"}
-- {"errcode":1,"errmsg":"现在不是活动时间"}
-- {"errcode":1,"errmsg":"出错"}
function HttpManager:respectTeacher(callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryGetWithHeader(DOMAIN .. "respect_teacher", nil, nil, callback, isNeedWait, retryType)
end
--清除每日孝敬次数
function HttpManager:resetDailyRecord(callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryGetWithHeader(DOMAIN .. "resetDailyRecord/1", nil, nil, callback, isNeedWait, retryType)
end

-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2018/01/23 16:09:54
-- @desc 清除统计数据
function HttpManager:deleteClientData(delType, callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "del_data_by_type", {type = delType}, nil, callback, isNeedWait, retryType)
end

-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2018/02/07 18:13:07
-- @desc 2018春节每日充值和累充接口

--获取奖励信息
function HttpManager:getSpendPlanGiftList(actionId, callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryGetWithHeader(DOMAIN .. "get_spend_plan_gift_list/" .. actionId, nil, nil, callback, isNeedWait, retryType)
end

--领取消耗奖励
function HttpManager:receiveSpendPlanGiftList(actionId, num, callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "receive_spend_plan_gift_list/" .. actionId, {reward_lv = num}, nil, callback, isNeedWait, retryType)
end

--获取活动充值信息
function HttpManager:getActionSpendInfo(actionId, callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryGetWithHeader(DOMAIN .. "get_spend_info/" .. actionId, nil, nil, callback, isNeedWait, retryType)
end

--测试接口
--重置充值领取
function HttpManager:resetSpendPlanGiftList(flag, callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryGetWithHeader(DOMAIN .. "test_spend_plan/" .. flag .. "/reset", nil, nil, callback, isNeedWait, retryType)
end

-- 新春登陆送元宝活动
-- 获取活动信息info
-- get
function HttpManager:getLoginRewardInfo(callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryGetWithHeader(DOMAIN .. "get_login_reward_info", nil, nil, callback, isNeedWait, retryType)
end
-- 获取领取元宝
-- get
function HttpManager:getLoginYuanbao(callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryGetWithHeader(DOMAIN .. "get_login_yuanbao", nil, nil, callback, isNeedWait, retryType)
end
--清除今天领取次数
function HttpManager:deleteLoginYuanbaoCache(callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryGetWithHeader(DOMAIN .. "delete_login_yuanbao_cache", nil, nil, callback, isNeedWait, retryType)
end

--增加充值额度
function HttpManager:addSpendPlanGiftList(flag, actionType, num, callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryGetWithHeader(DOMAIN .. "test_spend_plan/" .. flag .. "/" .. actionType .. "/" .. num, nil, nil, callback, isNeedWait, retryType)
end

--获取累计充值抽奖列表
--is_refresh : Y OR N
function HttpManager:getPayLotteryGiftList(is_refresh, callback, isNeedWait, retryType)
    callback = self:createGetResponseFunction(callback)
    is_refresh = Helper:getDef(is_refresh, "N")
    self:retryPostWithHeader(DOMAIN .. "get_lottery_list", {is_refresh = is_refresh}, nil, callback, isNeedWait, retryType)
end

--获取累计充值抽奖奖励
function HttpManager:getPayLotteryGift(order_id, callback, isNeedWait, retryType)
    print("获取累计充值抽奖奖励", "order_id =", order_id)
    callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "do_lottery", {order_id = order_id}, nil, callback, isNeedWait, retryType)
end

-- add by XiaoZhiWei 2018/02/10 20:24:53 获取分享链接
function HttpManager:getShareLink(callback, isNeedWait, retryType)
    if DEBUG_MODE == 1 then
        callback(200, 0, "", {url = "http://192.168.1.44:1700/index.html"}, true)
        return
    end
    callback = self:createGetResponseFunction(callback)
    self:retryGetWithHeader(DOMAIN .. "get_share_link", nil, nil, callback, isNeedWait, retryType)
end

-- add by XiaoZhiWei 2018/02/10 20:24:53 玩家分享后发送商城礼物
function HttpManager:doShare(callback, isNeedWait, retryType)
    if DEBUG_MODE == 1 then
        callback(200, 0, "", {items = {xiyanshui = 1}}, true)
        return
    end
    callback = self:createGetResponseFunction(callback)
    self:retryGetWithHeader(DOMAIN .. "do_share", nil, nil, callback, isNeedWait, retryType)
end

--@desc 入库
function HttpManager:bePutCkItems(itemData, ckName, ver, callback, isNeedWait, retryType)
    local itemId = itemData.itemId
    local info = itemData.info
    local count = Helper:getDef(itemData.count, 1)
    callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "beput_ckitems", {itemId = itemId, total = count, info = info, ckname = ckName, ver = ver}, nil, callback, isNeedWait, retryType)
end

--@desc 出库
function HttpManager:outGoingCkItems(itemData, ckName, ver, callback, isNeedWait, retryType)
    local itemId = itemData.itemId
    local count = Helper:getDef(itemData.count, 1)
    callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "outgoing_ckitems", {itemId = itemId, count = count, ckname = ckName, ver = ver}, nil, callback, isNeedWait, retryType)
end

--@desc 获取仓库清单
function HttpManager:getCkItemsList(ckName, localVer, callback, isNeedWait, retryType)
    callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "get_ckitems_list", {ckname = ckName, ver = localVer}, nil, callback, isNeedWait, retryType)
end

-- --@desc: 获取对方仓储ID
-- function HttpManager:getCkitemsListByUid(ckName,uid,callback, isNeedWait, retryType)
--     callback = self:createGetResponseFunction(callback)
--     self:retryPostWithHeader(DOMAIN.."get_ckitems_list_by_uid", {ckname = ckName,uid = uid}, nil, callback, isNeedWait, retryType)
-- end

--@desc 清空仓库
function HttpManager:delCkItems(ckName, callback, isNeedWait, retryType)
    callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "del_ckitems", {ckname = ckName}, nil, callback, isNeedWait, retryType)
end

-- 新npc商人接口 （多币种购买商人）
-- 新NPC商人商品列表
function HttpManager:getNewNpcChapmanItemList(npcId, callback, isNeedWait, retryType)
    callback = self:createGetResponseFunction(callback)
    self:retryGetWithHeader(DOMAIN .. "get_npc_store_list/" .. npcId, nil, nil, callback, isNeedWait, retryType)
end

-- 新NPC商人商品购买
-- couponsId 打折时，优惠券的id
function HttpManager:buyNewNpcChapmanItem(npcId, itemId, transid, couponsId, callback, isNeedWait, retryType)
    callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "buy_npc_goods", {client_trans_id = transid, itemId = itemId, npc_id = npcId, couponsId = couponsId}, nil, callback, isNeedWait, retryType)
end

-------------------------------- 家园相关 --------------------------------------------------
-- 银票兑换
-- type （1是小额碎银兑换，2是大额碎银兑换，3是元宝兑换）
function HttpManager:exchangeYinPiao(number, type, callback, isNeedWait, retryType)
    callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "exchange_yinpiao", {number = number, type = type}, nil, callback, isNeedWait, retryType)
end

--房屋改名
function HttpManager:renameHome(mid, new_name, point, callback, isNeedWait, retryType)
    callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "rename_home", {mid = mid, new_name = new_name, point = point}, nil, callback, isNeedWait, retryType)
end

function HttpManager:getLocationMap(loc_mark, callback, isNeedWait, retryType)
    callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "get_location_map", {loc_mark = loc_mark}, nil, callback, isNeedWait, retryType)
end

--@desc 获取购房列表
--@npcId: 售卖NPC的ID
--@is_refresh: "Y" OR "N"
function HttpManager:getHouseStoreList(npcId, is_refresh, callback, isNeedWait, retryType)
    callback = self:createGetResponseFunction(callback)

    is_refresh = is_refresh or "N"

    self:retryPostWithHeader(DOMAIN .. "get_house_store_list", {npcId = npcId, is_refresh = is_refresh}, nil, callback, isNeedWait, retryType)
end

--@desc 购房
function HttpManager:buyHomeland(npcId, fqId, callback, isNeedWait, retryType)
    callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "buy_homeland", {npcId = npcId, fqId = fqId}, nil, callback, isNeedWait, retryType)
end

--@desc 获取购地列表
function HttpManager:getLandStoreList(fbId, npcId, callback, isNeedWait, retryType)
    callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "get_land_store_list", {fbId = fbId, npcId = npcId}, nil, callback, isNeedWait, retryType)
end

--@desc 地皮竞价
function HttpManager:biddingLand(dpId, npcId, price, callback, isNeedWait, retryType)
    callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "bidding_land", {dpId = dpId, npcId = npcId, price = price}, nil, callback, isNeedWait, retryType)
end

--@desc 地皮领取
function HttpManager:getbiddingLand(dpId, callback, isNeedWait, retryType)
    callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "get_bidding_land", {dpId = dpId}, nil, callback, isNeedWait, retryType)
end

--@desc 地皮查询
function HttpManager:querybiddingInfo(callback, isNeedWait, retryType)
    callback = self:createGetResponseFunction(callback)
    self:retryGetWithHeader(DOMAIN .. "query_bidding_info", nil, nil, callback, isNeedWait, retryType)
end

--@desc 地皮搬入
function HttpManager:moveHomeland(dpId, mid, callback, isNeedWait, retryType)
    callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "move_home_land", {dpId = dpId, mid = mid}, nil, callback, isNeedWait, retryType)
end

--@RefType  获取竞价返回的银票
function HttpManager:getBiddingReturnPoint(dpId, callback, isNeedWait, retryType)
    callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "get_bidding_return_point", {dpId = dpId}, nil, callback, isNeedWait, retryType)
end

--@desc: 放入家具
--@author:Liang SongQiang
--@time:2018-06-01 16:37:17
--@mid:
--@roomId:
--@furnitureId:
--extra 附加属性 extra
function HttpManager:putinFurniture(mid, roomId, furnitureId, extra, localVer, callback, isNeedWait, retryType)
    callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "putin_furniture", {mid = mid, fjId = roomId, jjId = furnitureId, extra = extra, ver = localVer}, nil, callback, isNeedWait, retryType)
end

function HttpManager:removeFurniture(mid, fid, localVer, callback, isNeedWait, retryType)
    callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "remove_furniture", {mid = mid, fid = fid, ver = localVer}, nil, callback, isNeedWait, retryType)
end

-------------------------------------------------------------------------------------------------------------------------------
--------------------- 全副本相关接口
-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2018/05/09 17:56:14
-- @params mapId 玩家副本主键值,又服务器下发
-- @desc 获取玩家副本信息
function HttpManager:getUserMap(mapId, userid, localVer, callback, isNeedWait, retryType)
    callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "get_user_map", {mid = mapId, userid = Helper:getDef(userid, User:getUserId()), ver = localVer}, nil, callback, isNeedWait, retryType)
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2018/05/09 17:58:54
-- @params mapId 公共地图Id
-- @desc 获取公共地图信息
function HttpManager:getCommonFuben(mapId, callback, isNeedWait, retryType)
    callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "get_common_fuben", {fbId = mapId}, nil, callback, isNeedWait, retryType)
end

---------------------------------------------家园系统---------------------------------------------

-- 客户端上传雇佣列表生成数据给服务器保存，分为普通获取还是刷元宝获取
--管家，仆人，门客雇佣列表都可以用这个接口，管家和门客列表上传对应的npcId,因为仆人雇佣在管家身上，所以可以上传一个管家id
-- 'type' => 1|2 , //type为1是普通生成保存，2是花费元宝生成保存
function HttpManager:saveEmployeeList(type, npcId, list, callback, isNeedWait, retryType)
    callback = self:createGetResponseFunction(callback)
    -- print("saveEmployeeList——>")
    -- print("npcId = ",npcId)
    -- Helper:print_lua_table(list)
    self:retryPostWithHeader(DOMAIN .. "save_employee_list", {type = type, npcId = npcId, list = list}, nil, callback, isNeedWait, retryType)
end

-- get_employee_list/{npcId}
--获取客雇佣列表
function HttpManager:getEmployList(npcId, mid, callback, isNeedWait, retryType)
    -- print("get_employee_list——>",npcId)
    callback = self:createGetResponseFunction(callback)
    self:retryGetWithHeader(DOMAIN .. "get_employee_list/" .. npcId .. "/" .. mid, nil, nil, callback, isNeedWait, retryType)
end

-- add_employee
-- post方法
-- request：
-- {
-- 'hid' ：如果是初始管家的雇佣，设置为0，如果是列表上的雇佣，设置为列表上对应条目的id值(用id索引：获取雇佣列表数据的时候,服务器会设置的一个条目id)
-- 'objId' :客户端生成的对象id，管家id为gj_userid,仆人和门客的id为客户端自主生成
-- 'mid' ：地图id,
-- 'rid' ： 房间id,
--  'npcId'： 售卖雇佣信息的npcid，初始管家没有售卖的npcid，设置为0，其它情况设置为对应的npcid,
-- push_data: 初始管家的数据还有副本产出的仆人，门客
--}
--雇佣管家或仆人或门客，通过这个接口把决定雇佣的人物数据上传服务器
function HttpManager:addEmployee(hid, objId, mid, npcId, push_data, callback, isNeedWait, retryType)
    callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "add_employee", {hid = hid, objId = objId, mid = mid, npcId = npcId, push_data = push_data}, nil, callback, isNeedWait, retryType)
end

--获取管家，仆人，门客的信息
function HttpManager:getEmployRoleData(objId, mid, callback, isNeedWait, retryType)
    callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "get_employee_data", {objId = objId, mid = mid}, nil, callback, isNeedWait, retryType)
end

--增加忠诚接口
--zc_type:chat(闲聊)、give(闲聊)、spent(花费银票增加忠诚度)、free(任何条件)
function HttpManager:updateEmployRoleData(objId, mid, zc_type, zc_val, currency, callback, isNeedWait, retryType)
    callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "update_employee_data", {objId = objId, mid = mid, zc_type = zc_type, zc_val = zc_val, currency = currency}, nil, callback, isNeedWait, retryType)
end

--解雇管家，仆人，门客,删除对应数据
function HttpManager:deleteEmployee(objId, mid, callback, isNeedWait, retryType)
    callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "delete_employee", {objId = objId, mid = mid}, nil, callback, isNeedWait, retryType)
end

--房屋改造
--attr 改造房间的数据
--upload 和其它房间的关系{{fjid,down},{fjid,up}}
--point = 花费金额
function HttpManager:transformRoom(fjId, mid, attr, point, upload, callback, isNeedWait, retryType)
    callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "transform_room", {fjId = fjId, mid = mid, attr = attr, upload = upload, point = point}, nil, callback, isNeedWait, retryType)
end

--房屋扩建
--attr 改造房间的数据
--upload 和其它房间的关系{{fjid,down},{fjid,up}}
--point = 花费金额
function HttpManager:roomExtension(mid, attr, point, upload, callback, isNeedWait, retryType)
    callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "extension_room", {mid = mid, attr = attr, upload = upload, point = point}, nil, callback, isNeedWait, retryType)
end

--房屋还原
function HttpManager:restoreUserMap(mid, callback, isNeedWait, retryType)
    callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "restore_user_map", {mid = mid}, nil, callback, isNeedWait, retryType)
end

-- --房间拆除
-- --mid 副本id
-- --fj_update 要拆的房间fjId表
-- --pr_update 更新的仆人属性表
-- --jj_update 要移除的家具id表
-- --upload 和其它房间产生关系[['fj402_1','left'], ['fj402_2','left'], ['fj402_3','left']]
-- function HttpManager:roomRemove(mid,fj_update,pr_update,jj_update,upload,callback,isNeedWait, retryType)
--     callback = self:createGetResponseFunction(callback)
--     self:retryPostWithHeader(DOMAIN.."remove_room",{mid = mid,fj_update = fj_update,pr_update = pr_update,jj_update = jj_update,upload = upload},nil,callback, isNeedWait, retryType)
-- end

--@desc: 更新家园相关数据
--@author:Liang SongQiang
--@time:2018-09-26 10:28:02
--@mid:用户mid
--@cost:{value = xxx,unit = "yinpiao "}
--@fj_update: {roomid = {xx = xx,xx = xx},roomid = {xx = xx,xx = xx}}
--@pr_update: {rwId = {xx = xx,xx = xx},rwId = {xxx = xxx}}
--@jj_update: {id = {xx = xx},id={xx = xx}} (家具的id 为数据的索引id)
function HttpManager:updateHomeAttr(mid, fj_update, pr_update, jj_update, cost, callback, isNeedWait, retryType)
    callback = self:createGetResponseFunction(callback)

    fj_update = fj_update or {}
    pr_update = pr_update or {}
    jj_update = jj_update or {}

    if cost == nil then
        cost = {
            value = 0,
            unit = "yinpiao"
        }
    end

    self:retryPostWithHeader(DOMAIN .. "update_home_attr", {mid = mid, fj_update = fj_update, pr_update = pr_update, jj_update = jj_update, cost = cost}, nil, callback, isNeedWait, retryType)
end

--获取房屋事物的列表
--type  1 房屋事务 /3邀请函
--limit 每次获取事务的上限，由本地决定
function HttpManager:getAffairList(bizType, mid, limit, callback, isNeedWait, retryType)
    callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "get_affair_list/" .. limit, {biz_type = bizType, mid = mid}, nil, callback, isNeedWait, retryType)
end

--添加房屋事物
function HttpManager:pushAffair(affairTb, callback, isNeedWait, retryType)
    callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "push_affair", affairTb, nil, callback, isNeedWait, retryType)
end

--.处理房屋事物
--aid  每条事务有一个唯一的id 服务器下发的
--deal_type process处理/read已读
--process_type 求购 (1 同意 ,2 拒绝)
function HttpManager:processRoomAffair(aid, deal_type, process_type, callback, isNeedWait, retryType)
    callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "process_affair", {aid = aid, deal_type = deal_type, process_type = process_type}, nil, callback, isNeedWait, retryType)
end

--@desc: 处理发薪事务
--@author:LvBin
--@time:2022-06-16 11:58:56
--@aids: 发薪事务id数组
	--@callback:
	--@isNeedWait:
	--@retryType: 
--@return
function HttpManager:processPayAffairs(aids, callback, isNeedWait, retryType)
    callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "process_pay_affairs", {aids = aids}, nil, callback, isNeedWait, retryType)
end

--整个房屋升级，和房间升级不一样
function HttpManager:upgrandeUserMap(mid, new_fqId, yinpiao_num, callback, isNeedWait, retryType)
    callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "upgrande_user_map", {mid = mid, new_fqId = new_fqId, yinpiao_num = yinpiao_num}, nil, callback, isNeedWait, retryType)
end

--@desc: 获取指定UID的仓库信息
--@author:Liang SongQiang
--@time:2018-06-11 22:20:40
function HttpManager:getCkItemsListByUid(uid, ckname, callback, isNeedWait, retryType)
    callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "get_ckitems_list_by_uid", {uid = uid, ckname = ckname}, nil, callback, isNeedWait, retryType)
end

--@desc: 修改房间的相关属性
--@author:Liang SongQiang
--@time:2018-06-11 23:10:56
--@fjId:房间ID
--@mid:房契Mid
--@attr: 需要修改的属性
function HttpManager:revampRoomAttr(fjId, mid, attr, callback, isNeedWait, retryType)
    callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "revamp_room_attr", {fjId = fjId, mid = mid, attr = attr}, nil, callback, isNeedWait, retryType)
end

--@desc: 获取欠了多少管理费
--@author:Liang SongQiang
--@time:2018-06-12 19:33:41
--@npcId:地皮ID
function HttpManager:getManagePayment(dpId, callback, isNeedWait, retryType)
    callback = self:createGetResponseFunction(callback)
    self:retryGetWithHeader(DOMAIN .. "get_manage_payment/" .. dpId, nil, nil, callback, isNeedWait, retryType)
end

--@desc:上传特殊家具的一些属性（目前只有悬兵洞、藏衣阁使用）
--@author:Liang SongQiang
--@time:2018-06-13 16:04:50
--@mid:玩家房间ID
--@attr: table
function HttpManager:uploadFurnitureExtra(mid, attr, callback, isNeedWait, retryType)
    callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "upload_furniture_extra", {mid = mid, attr = attr}, nil, callback, isNeedWait, retryType)
end

--@desc 回收地皮
function HttpManager:recycleLand(dpId, callback, isNeedWait, retryType)
    callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "recycle_land", {dpId = dpId}, nil, callback, isNeedWait, retryType)
end

--更新人物的所有属性
-- {'mid' => 45,
--     'up_data' => [
--       ['rwId' => 'puren3343',fjId = '', 'extra' => ['ease' => 0]],
--       ['rwId' => 'gj_1006', 'extra' => ['ease' => 0]]
--     ]}
function HttpManager:updateEmployeeExtra(mid, up_data, callback, isNeedWait, retryType)
    callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "update_employee_extra", {mid = mid, up_data = up_data}, nil, callback, isNeedWait, retryType)
end

--增加人物忠诚度、删除所有人物
--1是一键增加副本内所有角色的忠诚度 loayl，2是一键删除副本内所有角色,3,一键解锁所有仆人特性（随机）4,一键删除所有家园数据
-- 7 地皮的缴费状态 datime ,8地皮的回收状态 datime
function HttpManager:testHomeland(type, tb, callback, isNeedWait, retryType)
    callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "test_homeland/" .. type, tb, nil, callback, isNeedWait, retryType)
end

--@desc: 测试接口，设置地皮过期时间
--@author:Liang SongQiang
--@time:2018-09-10 11:18:15
--@time: 剩余时间
function HttpManager:setAuctionTime(time, callback, isNeedWait, retryType)
    callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "set_auction_time", {time = time}, nil, callback, isNeedWait, retryType)
end

--@desc:上传副本的额外属性。
--@author:Liang SongQiang
--@time:2018-06-25 18:06:53
--@point: 需要的扣除元宝
function HttpManager:uploadMapExtra(mid, attr, point, callback, isNeedWait, retryType)
    if not point then
        point = 0
    end
    callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "upload_map_extra", {mid = mid, attr = attr, point = point}, nil, callback, isNeedWait, retryType)
end

--@desc 获取当前小村庄的地皮列表，mapIndex为副本索引
function HttpManager:getLocationMax(mapIndex, callback, isNeedWait, retryType)
    callback = self:createGetResponseFunction(callback)
    self:retryGetWithHeader(DOMAIN .. "get_location_max/" .. mapIndex, nil, nil, callback, isNeedWait, retryType)
end

--@desc 提交身世奖励
-- type : 1/2/3，//1薪资减半，2  n天无需发薪水，3 武功技能等级增加
-- objId: 人物id
-- mid: 副本id
-- up_data: //1传’’, 2传 天数， 3传要更新的武功数组 [‘武功1’ => ‘武功值1’, ‘武功2’ =>’武功值2’]
function HttpManager:getShenShiReward(type, objId, mid, up_data, callback, isNeedWait, retryType)
    callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "get_shenshi_reward", {type = type, objId = objId, mid = mid, up_data = up_data}, nil, callback, isNeedWait, retryType)
end

--兑换好运积分
--itemId 参与兑换的物品id
function HttpManager:exchangeLuckyPoint(itemId, callback, isNeedWait, retryType)
    callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "exchange_lucky_point", {itemId = itemId}, nil, callback, isNeedWait, retryType)
end

--@desc: 获取自己的房间信息
--@author:Liang SongQiang
--@time:2018-09-03 18:31:30
--@mid:用户地图ID
--@roomType:房间类型
function HttpManager:getAllRooms(mid, roomType, callback, isNeedWait, retryType)
    callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "get_all_rooms", {mid = mid, room_type = roomType}, nil, callback, isNeedWait, retryType)
end

--获取指定职业的仆人数据
-- jobType 职业
function HttpManager:getAllPersons(mid, jobType, callback, isNeedWait, retryType)
    callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "get_all_persons", {mid = mid, job = jobType}, nil, callback, isNeedWait, retryType)
end

--获取好运来兑换商品和相关信息
function HttpManager:getLuckyGoods(refresh, callback, isNeedWait, retryType)
    callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "get_lucky_goods", {is_refresh = refresh}, nil, callback, isNeedWait, retryType)
end

--购买好运积分
--num 购买的个数
--type yuanbao/lucky_point  用元宝还是好运积分购买
function HttpManager:buyLuckyGoods(itemId, id, callback, isNeedWait, retryType)
    callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "buy_lucky_goods", {itemId = itemId, id = id}, nil, callback, isNeedWait, retryType)
end

function HttpManager:getQiXiRecord(callback, isNeedWait, retryType)
    callback = self:createGetResponseFunction(callback)
    self:retryGetWithHeader(DOMAIN .. "get_qixi_record", nil, nil, callback, isNeedWait, retryType)
end

--@desc: 上传七夕数据
--@author:Liang SongQiang
--@time:2018-08-13 23:40:51
--@str: 要上传的字符串{type = "day;leftNpc;rightNpc;level;textKey;createTime"}
function HttpManager:addQiXiRecord(uploadStr, callback, isNeedWait, retryType)
    callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "add_qixi_record", {type = uploadStr}, nil, callback, isNeedWait, retryType)
end

--@desc: 测试接口，删除所有数据
--@author:Liang SongQiang
--@time:2018-08-14 01:42:29
function HttpManager:allQiXiDelete(callback, isNeedWait, retryType)
    callback = self:createGetResponseFunction(callback)
    self:retryGetWithHeader(DOMAIN .. "all_qixi_delete", nil, nil, callback, isNeedWait, retryType)
end

--@desc 测试接口
function HttpManager:testModifyQiXiCtime(daynum, callback, isNeedWait, retryType)
    if daynum == nil then
        daynum = 0
    end
    callback = self:createGetResponseFunction(callback)
    self:retryGetWithHeader(DOMAIN .. "modify_qixi_ctime/" .. daynum, nil, nil, callback, isNeedWait, retryType)
end

--获取家园当前仆人数量和房间数量
--mid 副本id
--actionType 1 获取房间数量， 2 获取仆人数量 3 获取房间总量和仆人数量
function HttpManager:getPuRenNumAndRoomNum(mid, actionType, callback, isNeedWait, retryType)
    callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "get_all_numrsper", {mid = mid, actionType = actionType}, nil, callback, isNeedWait, retryType)
end

--快速进入闹事
-- 1、mid
-- 2、rwId 不可管家类仆人
-- 3、time 整数 ，单位：秒 ，推迟时间
-- 4、type ：niaoshi /leave
function HttpManager:setPuRenStatus(mid, rwId, type, time, callback, isNeedWait, retryType)
    callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "make_servant_change", {mid = mid, rwId = rwId, type = type, time = time}, nil, callback, isNeedWait, retryType)
end

--@desc: 储物箱售卖商人
--@author:Liang SongQiang
--@time:2018-10-10 15:19:28
--@baseId:npc商人的baseId
function HttpManager:getStorageBox(baseId, callback, isNeedWait, retryType)
    if baseId == nil then
        return
    end
    callback = self:createGetResponseFunction(callback)
    self:retryGetWithHeader(DOMAIN .. "get_storage_box/" .. baseId, nil, nil, callback, isNeedWait, retryType)
end

--@desc: 购买储物箱
--@author:Liang SongQiang
--@time:2018-10-15 10:06:21
--@npcId:商人npcId
--@itemId:购买的储物箱ID
--@transid:凭证ID
--@fid:需替换的储物箱ID
function HttpManager:buyStorageBox(npcId, itemId, transid, fid, callback, isNeedWait, retryType)
    callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "buy_storage_box", {client_trans_id = transid, itemId = itemId, npc_id = npcId, fid = fid}, nil, callback, isNeedWait, retryType)
end

--@desc: 家园开启
--@author:Liang SongQiang
--@time:2018-10-17 09:45:13
function HttpManager:getHomeSwitch(callback, isNeedWait, retryType)
    callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "get_home_switch", {}, nil, callback, isNeedWait, retryType)
end

--@desc: 获取房契信息
--@author:Liang SongQiang
--@time:2018-10-20 11:15:56
function HttpManager:getHouseInfo(callback, isNeedWait, retryType)
    callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "get_house_info", nil, nil, callback, isNeedWait, retryType)
end

--@desc: 补领地契
--@author:Liang SongQiang
--@time:2018-10-22 14:17:38
function HttpManager:getLandInfo(callback, isNeedWait, retryType)
    callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "get_land_info", nil, nil, callback, isNeedWait, retryType)
end

--@desc: 获取双十一优惠券
function HttpManager:getDiscountCoupon(awardList, callback, isNeedWait, retryType)
    callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "get_discount_coupon", awardList, nil, callback, isNeedWait, retryType)
end

--@desc: 江湖名士充值加送次数与截止时间获取
function HttpManager:getActionTime(callback, isNeedWait, retryType)
    callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "get_yueka_times", nil, nil, callback, isNeedWait, retryType)
end

--@desc: 江湖名士充值加送领取奖励
function HttpManager:getActionAward(callback, isNeedWait, retryType)
    callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "give_yueka_days", nil, nil, callback, isNeedWait, retryType)
end

--@desc 新型累积充值商品列表
function HttpManager:getNewDailyList(activity_id, callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "get_newdaily_lists", {activity_id = activity_id}, nil, callback, isNeedWait, retryType)
end

--新型累积充值领取奖励
function HttpManager:receiveNewDailyReward(activity_id, type, callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "get_newdaily_award", {activity_id = activity_id, type = type}, nil, callback, isNeedWait, retryType)
end

--检查服务器记录的物品能否使用,防止用户恶意刷取物品，如果能够使用，则直接消耗
function HttpManager:checkItemIsCanUse(itemId, number, callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "employ_materials", {itemId = itemId, number = number}, nil, callback, isNeedWait, retryType)
end

-- 获取这类行动次数
-- action = JingMaiChongZhu(经脉重筑) \ refreshFuben(副本重置)
function HttpManager:getActionTimes(action, callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "get_config_times", {com_config = action}, nil, callback, isNeedWait, retryType)
end

-- 确认提交本次行动  新增 提交次数 quantity
function HttpManager:submitAction(action, quantity, callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "remove_config_point", {com_config = action, quantity = quantity}, nil, callback, isNeedWait, retryType)
end

--获取江湖怪客奖励
--isMenKe 1 是门客,0 不是  --guaikeLv 怪客等级
function HttpManager:getGuaikeReward(isMenKe, menKeId, mid, guaikeLv, callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "get_guaike_reward", {isMenKe = isMenKe, menKeId = menKeId, mid = mid, guaikeLv = guaikeLv}, nil, callback, isNeedWait, retryType)
end

--新春串门管家摆放礼物
--  gift_type  礼物类型  objId 管家id
function HttpManager:addLandGift(gift_type, objId, callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "add_land_gift", {gifTypt = gift_type, objId = objId}, nil, callback, isNeedWait, retryType)
end

--新春红包
--  type 0 元宝 1 贡献点 2 师门声望
function HttpManager:getMenPaiHongBao(type, callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "get_menpai_hongbao", {type = type}, nil, callback, isNeedWait, retryType)
end

--积分兑换物品快捷键
-- itemid --物品id
function HttpManager:testExchangeGoods(itemId, num, callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "test_exchange_goods", {itemId = itemId, num = num}, nil, callback, isNeedWait, retryType)
end

--物品检测接口
function HttpManager:detectionGoods(itemId, callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "detection_goods", {itemId = itemId}, nil, callback, isNeedWait, retryType)
end

--是否新包检测
function HttpManager:getWebConfig(callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryGetWithHeader(DOMAIN .. "getWebConfig", nil, nil, callback, isNeedWait, retryType)
end

--@desc: 获取家园消耗
--@author:Liang SongQiang
--@time:2019-03-07 10:48:45
function HttpManager:getHomelandCost(mid, callback, isNeedWait, retryType)
    callback = self:createGetResponseFunction(callback)
    self:retryGetWithHeader(DOMAIN .. "get_homeland_cost/" .. mid, nil, nil, callback, isNeedWait, retryType)
end

--临时活动需消耗元宝次数
--type 活动类型
function HttpManager:getEquinoxTimes(type, callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "get_equinox_times", {type = type}, nil, callback, isNeedWait, retryType)
end

--临时活动元宝扣除数量
--type 活动类型
function HttpManager:removeEquinoxPoint(type, callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "remove_equinox_point", {type = type}, nil, callback, isNeedWait, retryType)
end

--获取洗髓相关信息请求
function HttpManager:getAttributeTimes(callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "get_attribute_times", nil, nil, callback, isNeedWait, retryType)
end

--洗髓扣除元宝相关处理
function HttpManager:removeAttributePoint(callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "remove_attribute_point", nil, nil, callback, isNeedWait, retryType)
end

--@desc: 获取师门团体信息
--@author:Liang SongQiang
--@time:2019-01-18 10:18:11
--@userId: 用户ID
--@teacherId: 师傅ID
--@menpai: 门派ID
--@isCache: 0-客户端没有缓存，1-客户端有缓存
function HttpManager:getUserGroup(userId, teacherId, menpai, isCache, callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "get_user_group", {userid = userId, tid = teacherId, menpai = menpai, isCache = isCache}, nil, callback, isNeedWait, retryType)
end

--@desc: 获取舍友亲密度
--@author:Liang SongQiang
--@time:2019-02-15 16:59:51
--@user_id:舍友ID
function HttpManager:getUserIntimacy(userId, callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "get_user_intimacy", {to_uid = userId}, nil, callback, isNeedWait, retryType)
end

--@desc: 更新用户亲密度
--@author:Liang SongQiang
--@time:2019-04-24 10:37:59
--@userId:用户ID
--@intimacy:亲密度
--@event:事件
function HttpManager:updateUserIntimacy(userId, intimacy, event, callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "update_user_intimacy", {to_uid = userId, intimacy = intimacy, event = event}, nil, callback, isNeedWait, retryType)
end

--@desc: 获取所有舍友的亲密度
--@author:Liang SongQiang
--@time:2019-04-24 12:06:07
function HttpManager:getAllIntimacy(callback, isNeedWait, retryType)
    callback = self:createGetResponseFunction(callback)
    self:retryGetWithHeader(DOMAIN .. "get_all_intimacy", nil, nil, callback, isNeedWait, retryType)
end

--@desc: 获取玩家进境排行
--@author:Liang SongQiang
--@time:2019-02-15 16:11:14
function HttpManager:getGroupRank(callback, isNeedWait, retryType)
    callback = self:createGetResponseFunction(callback)
    self:retryGetWithHeader(DOMAIN .. "get_group_rank", nil, nil, callback, isNeedWait, retryType)
end

--@desc 退出师门小团队
function HttpManager:removeManpaiTeam(callback, isNeedWait, retryType)
    callback = self:createGetResponseFunction(callback)
    self:retryGetWithHeader(DOMAIN .. "test_remove_menpai_team", nil, nil, callback, isNeedWait, retryType)
end

--@desc:送礼
--@author:Liang SongQiang
--@time:2019-02-15 16:08:42
--@user_id:用户ID
--@itemId:物品ID
--@send_type:送礼行为类型
function HttpManager:sendGift(userId, itemId, itemCount, addIntimacy, addPrestige, callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "send_gift", {to_uid = userId, num = itemCount, gift = itemId, addIntimacy = addIntimacy, addPrestige = addPrestige}, nil, callback, isNeedWait, retryType)
end

--@desc: 收礼
--@author:Liang SongQiang
--@time:2019-02-15 16:10:13
--@user_id: 给你送礼的玩家id
function HttpManager:getGift(userId, callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "get_gift", {from_uid = userId}, nil, callback, isNeedWait, retryType)
end

--@desc: 检查舍友是否有给你送礼
--@author:Liang SongQiang
--@time:2019-04-23 16:18:49
--@userId:玩家id
function HttpManager:checkHasGift(userId, callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "check_has_gift", {from_uid = userId}, nil, callback, isNeedWait, retryType)
end

--添加门派声望
--number 增加数量
--event  添加途径
function HttpManager:addUserPrestige(addPrestige, event, callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "add_user_prestige", {addPrestige = addPrestige, event = event}, nil, callback, isNeedWait, retryType)
end

--获取门派声望相关信息
function HttpManager:getUserPrestige(callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "get_user_prestige", nil, nil, callback, isNeedWait, retryType)
end
--@desc:新副本重置
--@author:Liang SongQiang
--@time:2019-05-10 09:52:18
--@mapList: 重置副本列表
function HttpManager:refreshFubenByYuanBao(mapList, callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "refresh_fuben_by_yuanbao", {map_list = mapList}, nil, callback, isNeedWait, retryType)
end

--获取声望商人列表
--is_refresh Y: 表示刷新 N: 默认获取
function HttpManager:getPrestigeGoods(npcid, is_refresh, callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "get_prestige_goods", {npc_id = npcid, is_refresh = is_refresh}, nil, callback, isNeedWait, retryType)
end

--购买声望商人物品
function HttpManager:buyPrestigeGoods(itemId, trans_id, npc_id, callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "buy_prestige_goods", {itemId = itemId, client_trans_id = trans_id, npc_id = npc_id}, nil, callback, isNeedWait, retryType)
end

--刷新声望
function HttpManager:updateUserPrestige(callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "update_user_prestige", nil, nil, callback, isNeedWait, retryType)
end

--测试添加唯一头衔
function HttpManager:setSoleTitle(callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryGetWithHeader(DOMAIN .. "set_sole_title", nil, nil, callback, isNeedWait, retryType)
end

--仆人宝物奖励
-- zc_val 忠诚度 prId--仆人id  bwid--宝物id
function HttpManager:useHomeBw(zc_val, prId, mid, bwid, callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "use_homebw", {zc_val = zc_val, prId = prId, mid = mid, bwid = bwid}, nil, callback, isNeedWait, retryType)
end

--@desc: 网络属性变更接口（各种货币及服务器相关的属性）
--@author:Liang SongQiang
--@time:2019-07-22 10:28:25
--@currency_tb: 属性列表
--@eventType: 事件
--@params: 附加参数（挂机事件上传的是任务持续时间）
function HttpManager:addCurrencyNumber(currency_tb, eventType, params, callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "add_currency_number", {currency = currency_tb, addType = eventType, params = params}, nil, callback, isNeedWait, retryType)
end

--七夕情书相关接口
--获取七夕排行榜数据
function HttpManager:getQiXiRankBoard(callback, isNeedWait, retryType)
    callback = self:createGetResponseFunction(callback)
    self:retryGetWithHeader(DOMAIN .. "get_qixi_board", nil, nil, callback, isNeedWait, retryType)
end

--领取七夕情书排行奖励
--type 1:每日排行奖励   2:总排行奖励
function HttpManager:getQiXiRankBoatReward(transid, type, callback, isNeedWait, retryType)
    callback = self:createGetResponseFunction(callback)
    print("transid====================================:", transid)
    self:retryPostWithHeader(DOMAIN .. "get_qixi_reward", {trans_id = transid, type = type}, nil, callback, isNeedWait, retryType)
end

--获取任务详情
--actionId 活动id  例如七夕情书 QiXiLoveLetter
function HttpManager:getQiXiTaskInFo(actionId, callback, isNeedWait, retryType)
    callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "get_qixi_task_info", {actionId = actionId}, nil, callback, isNeedWait, retryType)
end

--开启任务
--actionId 活动id  例如七夕情书 QiXiLoveLetter
function HttpManager:TakeQiXiTask(actionId, callback, isNeedWait, retryType)
    callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "take_qixi_task", {actionId = actionId}, nil, callback, isNeedWait, retryType)
end

--提交任务
--actionId 活动id  例如七夕情书 QiXiLoveLetter
function HttpManager:FinishQiXiTask(actionId, callback, isNeedWait, retryType)
    callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "finish_qixi_task", {actionId = actionId}, nil, callback, isNeedWait, retryType)
end

--@desc: 充值测试接口
--@author:Liang SongQiang
--@time:2019-08-29 15:44:40
--@rechargeType:type：
--[[
    1：充值6元元宝
    2：充值18元元宝
    3：充值60元元宝
    4：充值168元元宝
    5：充值江湖名士
]]
function HttpManager:testChongzhi(rechargeType, callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryGetWithHeader(DOMAIN .. "test_chongzhi/" .. rechargeType, "", nil, callback, isNeedWait, retryType)
end

--@desc: 获取副本开放状态
--@author:Seven_L
--@time:2020-01-09 15:05:05
--@mapId:副本id
function HttpManager:getConfigFuben(mapId, callback, isNeedWait, retryType)
    callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "get_config_fuben", {fbId = mapId}, nil, callback, isNeedWait, retryType)
end

function HttpManager:getDiyGoods(isRefresh, callback, isNeedWait, retryType)
    callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "get_diy_goods", {is_refresh = isRefresh}, nil, callback, isNeedWait, retryType)
end

function HttpManager:getDiyInfos(callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryGetWithHeader(DOMAIN .. "get_diy_infos", nil, nil, callback, isNeedWait, retryType)
end

function HttpManager:buyDiyGoods(callback, isNeedWait, retryType)
    callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "buy_diy_goods", nil, nil, callback, isNeedWait, retryType)
end

--修复摆放礼品宝物添加缓存 bwid 宝物id number 宝物数量
function HttpManager:addHomeBw(bwId, number, callback, isNeedWait, retryType)
    callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "add_homebw", {bwid = bwId, number = number}, nil, callback, isNeedWait, retryType)
end

--获取活动日历
function HttpManager:getActivityCalendar(callback, isNeedWait, retryType)
    callback = self:createGetResponseFunction(callback)
    self:retryGetWithHeader(DOMAIN .. "get_activity_calendar", nil, nil, callback, isNeedWait, retryType)
end

--获取大侠成长之路相关信息
--requirement table {"servant","lunjian"}
function HttpManager:getGrowthInfo(requirement, callback, isNeedWait, retryType)
    callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "get_growth_info", {requirement = requirement}, nil, callback, isNeedWait, retryType)
end

--周年庆积分 仅用于周年庆
function HttpManager:addZhounianJifen(addType, number, callback, isNeedWait, retryType)
    callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "add_zhounian_jifen", {addType = addType, number = number}, nil, callback, isNeedWait, retryType)
end

-- function HttpManager:getDreamWorld(callback, isNeedWait, retryType)
--     local callback = self:createGetResponseFunction(callback)
--     self:retryGetWithHeader(DOMAIN.."get_dream_world",nil, nil, callback, isNeedWait, retryType)
-- end

--@desc 获取梦呓商品列表
function HttpManager:getDreamGoods(callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryGetWithHeader(DOMAIN .. "get_dream_goods", nil, nil, callback, isNeedWait, retryType)
end

--@desc 购买梦呓商品
--@onlyId: 商品唯一id
--@period: 商品期数,服务器用于校验
function HttpManager:buyDreamGood(onlyId, period, callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "buy_dream_goods", {onlyId = onlyId, period = period}, nil, callback, isNeedWait, retryType)
end

--@desc: 获取传承前学习的其它门派技能
--@author:Liang SongQiang
--@time:2019-10-14 16:48:43
--@inheritIndex:传承的代数
function HttpManager:getOtherSkills(inheritIndex, callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "get_other_skills", {inheritIndex = inheritIndex}, nil, callback, isNeedWait, retryType)
end

--@desc: 从前辈处学习技能
--@author:Liang SongQiang
--@time:2019-10-14 17:29:10
function HttpManager:studyOtherSkill(userid, skillid, callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "study_other_skill", {userid = userid, skill = skillid}, nil, callback, isNeedWait, retryType)
end

--@desc: 测试接口，添加技能
--@author:Seven
--@time:2020-08-20 15:25:06
--@userid: 传承id或当前id
--@skillid: 技能id
function HttpManager:testOtherSkill(userid, skillid, callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "test_other_skill", {userid = userid, skill = skillid}, nil, callback, isNeedWait, retryType)
end

--上传梦境人物数据
function HttpManager:uploadDreamRoleData(dreamRoleData, callback, isNeedWait, retryType)
    if not dreamRoleData then
        return
    end
    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "upload_dream_role", {roleAttr = dreamRoleData}, nil, callback, isNeedWait, retryType)
end

--获取梦境人物数据
function HttpManager:getDreamRoleData(callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryGetWithHeader(DOMAIN .. "get_dream_role", nil, nil, callback, isNeedWait, retryType)
end

--获取服务器奖励
--params 参数列表 {rewardType = 1,...}
--rewardType 1为奖励组随机奖励，rewardType 2为梦境结算奖励 ，rewardType 3指定奖励, rewardType 4武学奖励
function HttpManager:getWebReward(params, callback, isNeedWait, retryType)
    if not params then
        return
    end

    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "get_web_reward", params, nil, callback, isNeedWait, retryType)
end

--日志记录
--addType  日志类型 零 物品变化
--logData  table {[itemid]=1,[itemid]=1}
--logOrigin 获得途径
function HttpManager:reportGainLog(logData, callback, isNeedWait, retryType)
    callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "report_gain_log", {log_data = logData}, nil, callback, isNeedWait, retryType)
end

--@desc: 日志上传
--@author:Seven
--@time:2023-06-27 22:17:03
--@_type: 类型，新增需通知服务器
--@_logdata: object
function HttpManager:uploadAcquisitionLog(_logs, callback, isNeedWait, retryType)
    callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "upload_acquisition_log", _logs, nil, callback, isNeedWait, retryType)
end

--[[上传事件记录  参数 params = 
    {
        {
            type = "unlockTalent", --事件类型
            id = "", --解锁的天赋id
            count = 1,--数量
            currency = "dreamCoins", --消耗的货币
            cost = 100 --花费的金额
        }
    }
]]
function HttpManager:uploadEventRecord(params, callback, isNeedWait, retryType)
    callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "upload_event_record", {params = params}, nil, callback, isNeedWait, retryType)
end

-- 获取事件记录
function HttpManager:getEventRecord(callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryGetWithHeader(DOMAIN .. "get_event_record", nil, nil, callback, isNeedWait, retryType)
end

-- 结算事件
function HttpManager:submitEventRecord(callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryGetWithHeader(DOMAIN .. "submit_event_record", nil, nil, callback, isNeedWait, retryType)
end

--@desc: 楼层结算
--@author:Seven
--@time:2020-09-01 10:30:44
function HttpManager:dreamFloorComplete(roleAttr, callback, isNeedWait, retryType)
    callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "dream_floor_complete", {roleAttr = roleAttr}, nil, callback, isNeedWait, retryType)
end

--@desc: 梦境楼层结算
--@author:Seven
--@time:2020-09-01 10:48:03
function HttpManager:dreamWorldComplete(uploadParams, callback, isNeedWait, retryType)
    callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "dreamworld_complete", {roleAttr = uploadParams.roleAttr, rewardParams = uploadParams.rewardParams}, nil, callback, isNeedWait, retryType)
end

--@desc 检查是否有过期的梦境数据
function HttpManager:checkDreamRoleDataIsOverdue(userData, callback, isNeedWait, retryType)
    callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "settle_overdue_dream", {userData}, nil, callback, isNeedWait, retryType)
end

--刷新成就解锁
function HttpManager:updateUnlockRecord(events, callback, isNeedWait, retryType)
    callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "update_unlock_record", {events = events}, nil, callback, isNeedWait, retryType)
end

function HttpManager:getDreamRewardSkill(callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryGetWithHeader(DOMAIN .. "get_dream_reward_skill", nil, nil, callback, isNeedWait, retryType)
end

--获取元旦登录奖励活动信息
function HttpManager:getLoginYuandanInfo(callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryGetWithHeader(DOMAIN .. "get_login_yuandan_info", nil, nil, callback, isNeedWait, retryType)
end

--领取元旦登录奖励
function HttpManager:setLoginYuandanReward(rewardId, callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "set_login_yuandan_reward", {rewardId = rewardId}, nil, callback, isNeedWait, retryType)
end

--获取腊八元宝抽奖活动信息
function HttpManager:getYuanbaoLotteryList(callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryGetWithHeader(DOMAIN .. "get_yuanbao_lottery_list", nil, nil, callback, isNeedWait, retryType)
end

--领取腊八元宝抽奖
function HttpManager:doYuanbaoLottery(callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryGetWithHeader(DOMAIN .. "do_yuanbao_lottery", nil, nil, callback, isNeedWait, retryType)
end

--@desc: 异人录活动信息
--@author:Seven
--@time:2021-01-27 22:47:46
function HttpManager:getMingRenLotteryList(callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryGetWithHeader(DOMAIN .. "get_mingren_lottery_list", nil, nil, callback, isNeedWait, retryType)
end

--@desc: 异人录活动抽奖
--@author:Seven
--@time:2021-01-27 22:48:14
function HttpManager:doMingRenLottery(times, callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryGetWithHeader(DOMAIN .. "do_mingren_lottery/" .. times, nil, nil, callback, isNeedWait, retryType)
end

--@desc: 江湖名武录活动信息
--@author:Seven
--@time:2021-02-24 10:22:43
function HttpManager:getMingWuLotteryList(callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryGetWithHeader(DOMAIN .. "get_mingwu_lottery_list", nil, nil, callback, isNeedWait, retryType)
end

--@desc: 江湖名武录抽奖
--@author:Seven
--@time:2021-02-24 10:23:07
function HttpManager:doMingWuLottery(times, callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryGetWithHeader(DOMAIN .. "do_mingwu_lottery/" .. times, nil, nil, callback, isNeedWait, retryType)
end

--江湖珍品阁活动信息
function HttpManager:getZhenPinGeLotteryList(activity_id, callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryGetWithHeader(DOMAIN .. "get_zhenpinge_lottery_list/" .. activity_id, nil, nil, callback, isNeedWait, retryType)
end

--江湖珍品阁抽奖
function HttpManager:doZhenPinGeLottery(activity_id, times, callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "do_zhenpinge_lottery", {times = times, activity_id = activity_id}, nil, callback, isNeedWait, retryType)
end

--江湖珍品阁兑换
function HttpManager:exchangeZhenPinGeGoods(activity_id, id, num, dataVer, callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "exchange_zhenpinge_goods", {id = id, activity_id = activity_id, dataVer = dataVer, num = num}, nil, callback, isNeedWait, retryType)
end

function HttpManager:bfmingtieExchangeSpcl(callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryGetWithHeader(DOMAIN .. "bfmingtie_exchange_spcl", nil, nil, callback, isNeedWait, retryType)
end

-------------------------------------------------------------------------------------------------------------------------------
-- 获取所有书籍
function HttpManager:getCreateBooks(callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryGetWithHeader(DOMAIN .. "get_books", nil, nil, callback, isNeedWait, retryType)
end

-- 使用创作道具
function HttpManager:useCreateProp(propId, userLv, skillId, callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "use_create_prop", {prop = propId, lv = userLv, skillId = skillId}, nil, callback, isNeedWait, retryType)
end

-- 使用改良道具
function HttpManager:useImproveProp(propId, userLv, zhaoIndex, skillId, callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "use_improve_prop", {prop = propId, lv = userLv, zhaoIndex = zhaoIndex, skillId = skillId}, nil, callback, isNeedWait, retryType)
end

-- 添加道具
function HttpManager:addProp(propId, count, callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "add_prop", {prop = propId, count = count}, nil, callback, isNeedWait, retryType)
end

-- 获取道具列表
--@propType:  1创作道具   2改良道具
function HttpManager:getPropList(propType, callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryGetWithHeader(DOMAIN .. "get_propList/" .. tostring(propType), nil, nil, callback, isNeedWait, retryType)
end

-- 创作招式
function HttpManager:createZhao(zhaoType, userLv, tujianLv, callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "create_zhao", {methods = zhaoType, lv = userLv, maps = tujianLv}, nil, callback, isNeedWait, retryType)
end

-- 删除书籍数据
--@action: 1删除当前正在创建的书籍,2删除已经创建完的书籍,3全删除
function HttpManager:testDeleteBook(action, callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "test_delete_book", {action = action}, nil, callback, isNeedWait, retryType)
end

function HttpManager:deleteCompletedBook(skillId, callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "delete_book", {skillId = skillId}, nil, callback, isNeedWait, retryType)
end

-- 书籍创作完成
function HttpManager:completeBook(skillName, callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "complete_book", {skillName = skillName}, nil, callback, isNeedWait, retryType)
end

-- 获取招式颜色列表
function HttpManager:getZhaoColors(callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryGetWithHeader(DOMAIN .. "get_zhaoColors", nil, nil, callback, isNeedWait, retryType)
end

-- 解锁招式颜色
function HttpManager:unlockZhaoColor(colorId, callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "unlock_zhaoColor", {colorId = colorId}, nil, callback, isNeedWait, retryType)
end

-- 获取招式描述列表
function HttpManager:getZhaoDscs(templateId, callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "get_zhaoDscs", {templateId = templateId}, nil, callback, isNeedWait, retryType)
end

-- 解锁招式系列描述
function HttpManager:unlockZhaoDsc(xiLieId, templateId, callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "unlock_zhaoDsc_xiLie", {xiLieId = xiLieId, templateId = templateId}, nil, callback, isNeedWait, retryType)
end

-- 获取武学名字词缀列表
function HttpManager:getSkillNameAffixs(callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryGetWithHeader(DOMAIN .. "get_skillName_affixs", nil, nil, callback, isNeedWait, retryType)
end

-- 解锁词缀
function HttpManager:unlockSkillNameAffixs(nameAffixsId, callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "unlock_skillName_affixs", {affixsId = nameAffixsId}, nil, callback, isNeedWait, retryType)
end

-- 设置招式属性
function HttpManager:setZhaoAttr(params, callback, isNeedWait, retryType)
    Helper:print_lua_table(params)
    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "set_zhao_attr", params, nil, callback, isNeedWait, retryType)
end

-- 获取创建招式成功率
function HttpManager:getZhaoSuccessRate(userLv, callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "get_successRate", {lv = userLv}, nil, callback, isNeedWait, retryType)
end

--@desc 学习自创武学书籍
function HttpManager:learnSkillBook(skillId, callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "learn_book", {skillId = skillId}, nil, callback, isNeedWait, retryType)
end

function HttpManager:acceptTask(task_id, extra_data, callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "accept_task", {task_id = task_id, extra = extra_data}, nil, callback, isNeedWait, retryType)
end

function HttpManager:finishTask(task_id, extra_data, callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "finish_task", {task_id = task_id, extra = extra_data}, nil, callback, isNeedWait, retryType)
end

function HttpManager:resetTask(task_id, callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "reset_task", {task_id = task_id}, nil, callback, isNeedWait, retryType)
end

function HttpManager:submitTask(task_id, callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "submit_task", {task_id = task_id}, nil, callback, isNeedWait, retryType)
end

function HttpManager:getTaskInfo(task_id, callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "get_task_info", {task_id = task_id}, nil, callback, isNeedWait, retryType)
end

function HttpManager:testUpdateTask(task_id, updateInfo, callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "test_update_task", {task_id = task_id, data = updateInfo}, nil, callback, isNeedWait, retryType)
end

function HttpManager:testClearBook(skill_id, callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "test_clear_book", {skill_id = skill_id}, nil, callback, isNeedWait, retryType)
end

-- 清除每日创作上限缓存
function HttpManager:deleteCreateBookDayLimit(callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryGetWithHeader(DOMAIN .. "delete_book_dayLimit", nil, nil, callback, isNeedWait, retryType)
end

function HttpManager:testAddZhaoNum(skill_id, num, callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "test_add_zhaoNum", {skillId = skill_id, number = num}, nil, callback, isNeedWait, retryType)
end

--获取每日任务活动相关信息
function HttpManager:getDailyTaskList(callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryGetWithHeader(DOMAIN .. "get_daily_task_list", nil, nil, callback, isNeedWait, retryType)
end
--获取每日任务活动对应奖励
function HttpManager:getDailyTaskReward(grade, callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "get_daily_task_reward", {grade = grade}, nil, callback, isNeedWait, retryType)
end
--添加每日活动积分
function HttpManager:addDailyTaskPoint(task_id, callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "add_daily_task_point", {task_id = task_id}, nil, callback, isNeedWait, retryType)
end

--获取登录活动信息
--activity_id 活动id
function HttpManager:getLoginRewardList(activity_id, callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryGetWithHeader(DOMAIN .. "get_login_reward_list/" .. activity_id, nil, nil, callback, isNeedWait, retryType)
end

--获取登录活动奖励
--activity_id 活动id rid 对应奖励id
function HttpManager:getLoginReward(activity_id, rid, callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "get_login_reward", {activity_id = activity_id, rid = rid}, nil, callback, isNeedWait, retryType)
end

function HttpManager:getFundActivityInfo(actionId, callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryGetWithHeader(DOMAIN .. "get_login_reward_list/" .. actionId, nil, nil, callback, isNeedWait, retryType)
end

function HttpManager:getFundReward(actionId, rid, callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "get_login_reward", {activity_id = actionId, rid = rid}, nil, callback, isNeedWait, retryType)
end

function HttpManager:setProductMark(actionId, key, callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "set_product_mark", {activity_id = actionId, key = key}, nil, callback, isNeedWait, retryType)
end

function HttpManager:getSpringNewReward(callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryGetWithHeader(DOMAIN .. "get_spring_new_reward", nil, nil, callback, isNeedWait, retryType)
end

function HttpManager:receiveSpringNewReward(rid, callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryGetWithHeader(DOMAIN .. "receive_spring_new_reward/" .. rid, nil, nil, callback, isNeedWait, retryType)
end

------------------------------------------------------------------------------------------------------------------
------------------江湖情报相关

-- 获取情报数据
function HttpManager:getIntelligenceData(callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryGetWithHeader(DOMAIN .. "get_intelligence_data", nil, nil, callback, isNeedWait, retryType)
end

-- 上传今日情报数据
function HttpManager:uploadIntelligenceData(params, callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "upload_intelligence_data", params, nil, callback, isNeedWait, retryType)
end

-- 购买情报
function HttpManager:buyIntelligence(callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryGetWithHeader(DOMAIN .. "buy_day_intelligence", nil, nil, callback, isNeedWait, retryType)
end

-- 获取技巧类情报列表
function HttpManager:getTechniqueList(callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryGetWithHeader(DOMAIN .. "get_technique_list", nil, nil, callback, isNeedWait, retryType)
end

-- 阅读情报
function HttpManager:readIntelligence(id, type, callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "read_intelligence", {intelligence_id = id, intelligence_type = type}, nil, callback, isNeedWait, retryType)
end

-- 删除今日已购买情报
function HttpManager:deleteDayIntelligence(callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryGetWithHeader(DOMAIN .. "delete_day_intelligence", nil, nil, callback, isNeedWait, retryType)
end

-- 删除购买过的情报
function HttpManager:deleteIntelligence(type, callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "delete_bought_intelligence", {type = type}, nil, callback, isNeedWait, retryType)
end

function HttpManager:getSpendRewardList(actionId, callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryGetWithHeader(DOMAIN .. "get_spend_reward_list/" .. actionId, nil, nil, callback, isNeedWait, retryType)
end

function HttpManager:getSpendReward(actionId, rid, dataVer, callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "get_spend_reward", {activity_id = actionId, rid = rid, dataVer = dataVer}, nil, callback, isNeedWait, retryType)
end

--[[
    @desc: 检测字符串是否包含屏蔽词
]]
function HttpManager:containsBlockedWord(str, callback, isNeedWait, retryType)
    callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "contains_blocked_word", {s = str}, nil, callback, isNeedWait, retryType)
end

--获取答题状态
function HttpManager:getAnswerStatus(activityId, callback, isNeedWait, retryType)
    callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "get_answer_status", {activity_id = activityId}, nil, callback, isNeedWait, retryType)
end

--设置答题状态  type 1 通过答题 2 领取奖励 pass_num  正确答题数
function HttpManager:setAnswerStatus(activityId, type, passNum, callback, isNeedWait, retryType)
    callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "set_answer_status", {activity_id = activityId, type = type, pass_num = passNum}, nil, callback, isNeedWait, retryType)
end

------------------------------------------------------------------------------------------------------------------
------------------江湖邮箱功能
--@desc 获取邮件
function HttpManager:getEmails(callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryGetWithHeader(DOMAIN .. "get_email_info", nil, nil, callback, isNeedWait, retryType)
end

--@desc 阅读邮件
function HttpManager:readEmail(id, callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "read_email", {id = id}, nil, callback, isNeedWait, retryType)
end

--@desc 删除邮件
function HttpManager:deleteEmail(id, callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryGetWithHeader(DOMAIN .. "delete_email/" .. id, nil, nil, callback, isNeedWait, retryType)
end

--@desc 领取邮件奖励
function HttpManager:getEmailReward(id, retrievables, dataVer, callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "get_email_reward", {id = id, retrievables = retrievables,dataVer = dataVer}, nil, callback, isNeedWait, retryType)
end

--@desc 获取所有邮件奖励列表
function HttpManager:getAllEmailRewardList(callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryGetWithHeader(DOMAIN .. "get_email_rewards_list", nil, nil, callback, isNeedWait, retryType)
end

--@desc 领取所有邮件奖励
function HttpManager:getAllEmailReward(retrievables, dataVer, callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "get_all_email_rewards", {retrievables = retrievables, dataVer = dataVer}, nil, callback, isNeedWait, retryType)
end

--@desc 删除所有处理过的邮件
function HttpManager:deleteIsFinishEmails(callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryGetWithHeader(DOMAIN .. "delete_processed_emails", nil, nil, callback, isNeedWait, retryType)
end

--@desc 面具升级
function HttpManager:maskUpgrade(params, callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "mask_upgrade", {params = params}, nil, callback, isNeedWait, retryType)
end

--获取江湖夺宝
function HttpManager:getLotteryTreasureList(activity_id, callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryGetWithHeader(DOMAIN .. "get_lottery_treasure_list/" .. activity_id, nil, nil, callback, isNeedWait, retryType)
end

--江湖夺宝抽奖
function HttpManager:lotteryTreasureResult(activity_id, callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "lottery_treasure_result", {activity_id = activity_id}, nil, callback, isNeedWait, retryType)
end

--江湖夺宝领奖
function HttpManager:lotteryTreasureReward(activity_id, rid, is_email, dataVer, callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "lottery_treasure_reward", {activity_id = activity_id, rid = rid, is_email = is_email, dataVer = dataVer}, nil, callback, isNeedWait, retryType)
end

--江湖夺宝兑换列表
function HttpManager:getLotteryTreasureExchangeShop(activity_id, callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "get_lottery_treasure_exchange_shop", {activity_id = activity_id}, nil, callback, isNeedWait, retryType)
end

--江湖夺宝兑换
function HttpManager:lotteryTreasureExchangeGoods(activity_id, goods_id, callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "lottery_treasure_exchange_goods", {activity_id = activity_id, goods_id = goods_id}, nil, callback, isNeedWait, retryType)
end

--江湖夺宝购买抽奖货币
function HttpManager:buyLotteryTreasureCurrency(activity_id, number, callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "buy_lottery_treasure_currency", {activity_id = activity_id, number = number}, nil, callback, isNeedWait, retryType)
end

------------------------------------------------------------------------------------------------------------------

--添加分级引导任务点数
function HttpManager:addGuideTaskPoint(taskId, point, callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "add_guide_task_point", {task_id = taskId, point = point}, nil, callback, isNeedWait, retryType)
end

--获取分级引导总点数
function HttpManager:getGuideTaskPoint(callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryGetWithHeader(DOMAIN .. "get_guide_task_point", nil, nil, callback, isNeedWait, retryType)
end

--获取记录武学
function HttpManager:getRecordSkills(callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryGetWithHeader(DOMAIN .. "get_record_skills", nil, nil, callback, isNeedWait, retryType)
end

--记录武学 (skill_type 1:江湖武学，2:门派武学，3:武学技能书)
function HttpManager:recordSkill(skill_id, skill_type, callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "record_skill", {skill_id = skill_id, skill_type = skill_type}, nil, callback, isNeedWait, retryType)
end

--学习武学
function HttpManager:learnSkill(skill_id, callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "learn_skill", {skill_id = skill_id}, nil, callback, isNeedWait, retryType)
end

-- 安卓获取UUID
function HttpManager:getAndroidUUID(callback, isNeedWait, retryType)
    callback = Helper:getDef(callback, EMPTY_FUNC)
    callback = self:createGetResponseFunction(callback)
    self:retryGetWithHeader(string.gsub(DOMAIN, "api/v5/", "api/service_android/") .. "get_uuid", nil, nil, callback, isNeedWait, retryType)
end

-------------------------------------------------------------------------------
--南柯一梦相关接口

--@desc 检查是否有过期的南柯梦境
function HttpManager:checkFondDreamRoleDataIsOverdue(userData, callback, isNeedWait, retryType)
    callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "settle_overdue_fond_dream", {userData}, nil, callback, isNeedWait, retryType)
end

--获取南柯梦境人物数据
function HttpManager:getFondDreamRoleData(callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryGetWithHeader(DOMAIN .. "get_fond_dream_role", nil, nil, callback, isNeedWait, retryType)
end

--上传南柯梦境人物数据
function HttpManager:uploadFondDreamRoleData(dreamRoleData, callback, isNeedWait, retryType)
    if not dreamRoleData then
        return
    end
    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "upload_fond_dream_role", {roleAttr = dreamRoleData}, nil, callback, isNeedWait, retryType)
end

--@desc: 南柯梦境楼层结算
function HttpManager:fondDreamFloorComplete(roleAttr, callback, isNeedWait, retryType)
    callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "fond_dream_floor_complete", {roleAttr = roleAttr}, nil, callback, isNeedWait, retryType)
end

--@desc: 南柯梦境楼层结算
function HttpManager:fondDreamWorldComplete(uploadParams, callback, isNeedWait, retryType)
    callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "fond_dreamworld_complete", {roleAttr = uploadParams.roleAttr, rewardParams = uploadParams.rewardParams}, nil, callback, isNeedWait, retryType)
end

--南柯梦境获取服务器奖励
--params 参数列表 {rewardType = 1,...}
--rewardType 1为奖励组随机奖励，rewardType 2为南柯梦境结算奖励 ，rewardType 3指定奖励, rewardType 4武学奖励
function HttpManager:getFondWebReward(params, callback, isNeedWait, retryType)
    if not params then
        return
    end

    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "get_fond_dream_reward", params, nil, callback, isNeedWait, retryType)
end

function HttpManager:deleteFondDreamRoleData(callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryGetWithHeader(DOMAIN .. "delete_fond_dream_role", nil, nil, callback, isNeedWait, retryType)
end

--获取彩蛋副本挑战相关信息
function HttpManager:getEggChallengeInfo(callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryGetWithHeader(DOMAIN .. "get_egg_challenge_info", nil, nil, callback, isNeedWait, retryType)
end

--添加彩蛋副本npc挑战次数
function HttpManager:addEggChallengeTimes(npcId, callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "add_egg_challenge_times", {npc_id = npcId}, nil, callback, isNeedWait, retryType)
end

--获取新版天缘奇盒列表
function HttpManager:getLuckBoxList(activity_id, menpai, is_refresh, callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "get_luck_box_list", {activity_id = activity_id, menpai = menpai, is_refresh = is_refresh}, nil, callback, isNeedWait, retryType)
end

--购买天缘奇盒奖励
function HttpManager:buyLuckBoxGood(activity_id, rid, dataVer, callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "buy_luck_box_good", {activity_id = activity_id, rid = rid, dataVer = dataVer}, nil, callback, isNeedWait, retryType)
end

--领取天缘奇盒奖励
function HttpManager:getLuckBoxGood(activity_id, rid, dataVer, callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "get_luck_box_good", {activity_id = activity_id, rid = rid, dataVer = dataVer}, nil, callback, isNeedWait, retryType)
end

--获取香囊密阁相关数据
function HttpManager:getSachetAtticList(actionId, callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryGetWithHeader(DOMAIN .. "get_sachet_attic_list/" .. actionId, nil, nil, callback, isNeedWait, retryType)
end

--兑换香囊密阁
function HttpManager:exchangeAwardToSachet(activity_id, reward_id, callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "exchange_award_to_sachet", {activity_id = activity_id, reward_id = reward_id}, nil, callback, isNeedWait, retryType)
end
--江湖秘宝特殊礼包购买
function HttpManager:buySpendReward(activity_id, rid, callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "buy_spend_reward", {activity_id = activity_id, rid = rid}, nil, callback, isNeedWait, retryType)
end

function HttpManager:startHangUpTask(version, taskId, extraData, callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "start_hang_up_task", {version = version, task_id = taskId, extra = extraData}, nil, callback, isNeedWait, retryType)
end

function HttpManager:stopHangUpTask(version, taskId, extraData, reward, callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "stop_hang_up_task", {version = version, task_id = taskId, extra = extraData, reward = reward}, nil, callback, isNeedWait, retryType)
end

--@desc 挂机中当前雅士生效时间段
function HttpManager:getHangUpYashiTime(version, callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "get_hangUp_yashi_time", {version = version}, nil, callback, isNeedWait, retryType)
end

--@desc 检查是否拥有雅士
function HttpManager:getYaShiExpiredTime(callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryGetWithHeader(DOMAIN .. "check_has_yashi", nil, nil, callback, isNeedWait, retryType)
end

function HttpManager:recordClickTask(taskId, reward, extra, callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "record_click_task", {task_id = taskId, reward = reward, extra = extra}, nil, callback, isNeedWait, retryType)
end

--@desc 测试用:更新雅士数据
function HttpManager:testSetUpdateYaShiTime(create_time, expired_time, callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "test_update_yashi", {data = {create_time = create_time, expired_time = expired_time}}, nil, callback, isNeedWait, retryType)
end

--@desc 测试用:修改挂机数据
--@version: 版本号
--@data: 要修改的挂机数据
function HttpManager:testSetUpdateHangTask(version, data, callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "test_update_hang_task", {version = version, data = data}, nil, callback, isNeedWait, retryType)
end

--@desc: 查看挂机信息
--@author:Seven
--@time:2021-09-27 16:43:47
--@version: 挂机版本号
function HttpManager:testGetHangTask(version, callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "test_get_hang_task", {version = version}, nil, callback, isNeedWait, retryType)
end

--获取叠金充值信息
function HttpManager:getTotalSpendDetail(activity_id, callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryGetWithHeader(DOMAIN .. "get_total_spend_detail/" .. activity_id, nil, nil, callback, isNeedWait, retryType)
end

--获取叠金奖励
function HttpManager:getTotalSpendAward(activity_id, award_id, callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "get_total_spend_award", {activity_id = activity_id, award_id = award_id}, nil, callback, isNeedWait, retryType)
end

--背包扩容接口
--type 1 背包 2 仓库  level 当前等级
function HttpManager:upgradeUserBag(type, level, callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "upgrade_user_bag", {type = type, level = level}, nil, callback, isNeedWait, retryType)
end

--事件记录
--event_type 事件类型
--envet_param 事件参数（可以不传）
--user_attr 玩家存档
function HttpManager:addIncidentLog(event_type, envet_param, user_attr, callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "add_incident_log", {event_type = event_type, envet_param = envet_param, user_attr = user_attr}, nil, callback, isNeedWait, retryType)
end

--武学突破道具获取
function HttpManager:martialUpgradeAddCurrency(type, callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "martial_upgrade_add_currency", {type = type}, nil, callback, isNeedWait, retryType)
end

--获取年兽活动相关信息
function HttpManager:getExpelRewardList(callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryGetWithHeader(DOMAIN .. "get_expel_reward_list", nil, nil, callback, isNeedWait, retryType)
end

--驱赶年兽接口
--times 驱赶次数
function HttpManager:expelNian(times, dataVer, callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "expel_nian", {times = times, dataVer = dataVer}, nil, callback, isNeedWait, retryType)
end

--获取年兽奖励接口
-- rid 奖励id
function HttpManager:getExpelReward(rid,dataVer, callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "get_expel_reward", {rid = rid, dataVer = dataVer}, nil, callback, isNeedWait, retryType)
end

-------------------------------------------------------------------------------
--挑战副本相关

--@desc 获取轶闻值
function HttpManager:getAnecdote(callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryGetWithHeader(DOMAIN .. "get_user_anecdote", nil, nil, callback, isNeedWait, retryType)
end

--@desc 恢复轶闻值
function HttpManager:revertAnecdote(callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryGetWithHeader(DOMAIN .. "test_revert_anecdote", nil, nil, callback, isNeedWait, retryType)
end

--@desc: 获取节日副本详情
--@author:LvBin
--@time:2022-08-25 17:52:18
--@groupId:
	--@callback:
	--@isNeedWait:
	--@retryType: 
--@return
function HttpManager:getFestivalMapInfo(groupId,callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "get_festivalmap_info", {groupId = groupId}, nil, callback, isNeedWait, retryType)
end

--@desc: 判断是否有未完成的挑战副本进度
--@author:LvBin
--@time:2022-02-15 16:15:15
--@callback:
--@isNeedWait:
--@retryType:
--@return
function HttpManager:isChallengeMapReconnection(callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryGetWithHeader(DOMAIN .. "challengemap_unfinished", nil, nil, callback, isNeedWait, retryType)
end

--@desc: 进入未完成副本
--@author:LvBin
--@time:2022-02-15 20:02:26
--@callback:
--@isNeedWait:
--@retryType:
--@return
function HttpManager:reEnterChallengemap(callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryGetWithHeader(DOMAIN .. "reenter_challengemap", nil, nil, callback, isNeedWait, retryType)
end

--@desc 该接口至是获取了进入副本的相关信息，并未真正进入副本
function HttpManager:enterChallengeMap(mapId, callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "challengemap_enter", {map_id = mapId}, nil, callback, isNeedWait, retryType)
end

--@desc: 挑战副本能否快速通关
--@author:LvBin
--@time:2022-06-16 10:11:03
--@mapId:
	--@callback:
	--@isNeedWait:
	--@retryType: 
--@return
function HttpManager:challengeMapIsCustoms(mapId, callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "challengemap_is_customs", {map_id = mapId}, nil, callback, isNeedWait, retryType)
end

--@desc 确认扣除挑战副本资源,进入副本
function HttpManager:challengeMapConfirmConsume(mapId, consume_map, callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "challengemap_confirm_consume", {map_id = mapId, consume_map = consume_map}, nil, callback, isNeedWait, retryType)
end

--@desc 请求挑战副本结算
function HttpManager:challengeMapFinish(mapId, finishType, callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "challengemap_finish", {map_id = mapId,finish_type = finishType}, nil, callback, isNeedWait, retryType)
end

--@desc 领取奖励，并记录
function HttpManager:challengeMapGetAward(mapId, type, award_list, finishType, callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "challengemap_award", {map_id = mapId, type = type, award_list = award_list, finish_type = finishType}, nil, callback, isNeedWait, retryType)
end

--@desc: 挑战副本离开(用于未通关退出挑战副本，通知服务器结束这次挑战副本记录)
--@author:LvBin
--@time:2022-02-15 16:32:43
--@type: 1主动退出/2失败退出/3重连退出
--@callback:
--@isNeedWait:
--@retryType:
--@return
function HttpManager:challengeMapLeave(type, callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "challengemap_leave", {type = type}, nil, callback, isNeedWait, retryType)
end

-------------------------------------------------------------------------------
--武学突破

--@desc: 获取武学突破相关货币数量
--@author:LvBin
--@time:2022-01-15 17:17:23
--@callback:
--@isNeedWait:
--@retryType:
--@return
function HttpManager:getSkillBreakCurrency(callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryGetWithHeader(DOMAIN .. "get_martial_upgrade_currency", nil, nil, callback, isNeedWait, retryType)
end

--@desc: 武学突破
--@author:LvBin
--@time:2022-01-17 11:37:06
--@id:  突破id
--@callback:
--@isNeedWait:
--@retryType:
--@return
function HttpManager:skillBreakThrough(id, skillId, callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "martial_upgrade", {id = id, martial_id = skillId}, nil, callback, isNeedWait, retryType)
end

--@desc: 测试接口  增加武学突破相关货币各1000
--@author:LvBin
--@time:2022-01-17 11:38:08
--@callback:
--@isNeedWait:
--@retryType:
--@return
function HttpManager:testAddMartialCurrency(callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryGetWithHeader(DOMAIN .. "test_add_martial_currency", nil, nil, callback, isNeedWait, retryType)
end

--@desc: 招式突破
--@author:LvBin
--@time:2022-01-23 13:06:58
--@id:
--@callback:
--@isNeedWait:
--@retryType:
--@return
function HttpManager:zhaoBreakThrough(id, zhaoId, callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "zhao_upgrade", {id = id, zhao_id = zhaoId}, nil, callback, isNeedWait, retryType)
end

--@desc: 获取招式突破相关道具数量列表
--@author:LvBin
--@time:2022-01-23 13:29:41
--@callback:
--@isNeedWait:
--@retryType:
--@return
function HttpManager:getZhaoBreakThroughItems(callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryGetWithHeader(DOMAIN .. "get_zhao_upgrade_matters", nil, nil, callback, isNeedWait, retryType)
end

--@desc: 测试接口  增加招式突破相关道具各1000
--@author:LvBin
--@time:2022-01-23 13:26:20
--@callback:
--@isNeedWait:
--@retryType:
--@return
function HttpManager:testAddZhaoBreItems(callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryGetWithHeader(DOMAIN .. "test_add_zhao_currency", nil, nil, callback, isNeedWait, retryType)
end

------------------------------------------------------------------------------------------------------------------------------------
--洗髓日志记录
function HttpManager:uploadWashAttributeRecord(record, callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "upload_wash_attribute_record", {record = record}, nil, callback, isNeedWait, retryType)
end

--获取续卷商人列表
--type  1 获取 2 刷新
function HttpManager:mattersShopInfo(type, callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "matters_shop_info", {type = type}, nil, callback, isNeedWait, retryType)
end

--购买续卷商人商品
--goodsKey 商品id
function HttpManager:buyMatters(goodsKey, callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "buy_matters", {goodsKey = goodsKey}, nil, callback, isNeedWait, retryType)
end

--特殊物品兑换特殊物品
--兑换物品 exchangeItems {{ id = "xx"， num = 1}}
--目标物品 targetItems {{ id = "xx"， num = 1}}
function HttpManager:specialItemExchange(exchangeItems, targetItems, callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "special_item_exchange", {exchangeItems = exchangeItems, targetItems = targetItems}, nil, callback, isNeedWait, retryType)
end

--@desc: pvp战斗人物数据校验
--@author:LvBin
--@time:2022-03-04 09:57:27
--@roleDatas:
--@callback:
--@isNeedWait:
--@retryType:
--@return
function HttpManager:pvpRoleDataVerify(roleDatas, callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "pvp_roleData_verify", {roleDatas = roleDatas}, nil, callback, isNeedWait, retryType)
end

--获取历练任务活动相关
-- actionId 活动id
function HttpManager:getTrainingTaskList(actionId, taskList, callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "get_training_task_list", {activity_id = actionId, taskList = taskList}, nil, callback, isNeedWait, retryType)
end

-- 刷新历练任务
-- actionId 活动id
function HttpManager:refreshTrainingTaskList(actionId, taskList, callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "refresh_training_task_list", {activity_id = actionId, taskList = taskList}, nil, callback, isNeedWait, retryType)
end

-- 增加历练任务积分
-- taskid 任务id
function HttpManager:addTrainingTaskPoint(taskId, taskList, callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "add_training_task_point", {tid = taskId, taskList = taskList}, nil, callback, isNeedWait, retryType)
end

-- 领取历练任务奖励
-- activity_id 活动id
-- rid 奖励id
function HttpManager:getTrainingTaskReward(activity_id, rid, dataVer, callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "get_training_task_reward", {activity_id = activity_id, rid = rid, dataVer = dataVer}, nil, callback, isNeedWait, retryType)
end

--获取皮肤列表
function HttpManager:getUiThemeList(callback,isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryGetWithHeader(DOMAIN.."get_ui_theme_list",nil,nil,callback,isNeedWait,retryType)
end

--购买皮肤
--uiId 皮肤id
function HttpManager:buyUiTheme(uiId, callback,isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryGetWithHeader(DOMAIN.."buy_ui_theme/"..uiId,nil,nil,callback,isNeedWait,retryType)
end

--使用皮肤
--uiId 皮肤id
function HttpManager:useUiTheme(uiId, callback,isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryGetWithHeader(DOMAIN.."use_ui_theme/"..uiId,nil,nil,callback,isNeedWait,retryType)
end

--@desc: 获取练武场相关信息
--@author:LvBin
--@time:2022-12-16 18:21:07
--@skillData: 武学id和等级数据
	--@zhaoData: 招式id和等级数据
	--@callback:
	--@isNeedWait:
	--@retryType: 
--@return
function HttpManager:getPracticeSkillRewardList(activityId, skillData,zhaoData,callback,isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN.."get_practice_skill_reward_list",{activityId = activityId, skillData = skillData,zhaoData = zhaoData},nil,callback,isNeedWait,retryType)
end

-- 获取练武场对应奖励
-- rid 奖励id
-- is_email 是否邮箱发放 0.前端直接发放，1.邮件发送
function HttpManager:getPracticeSkillReward(activityId, rid,is_email,dataVer,callback,isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN.."get_practice_skill_reward",{activityId = activityId, rid = rid,is_email = is_email,dataVer = dataVer},nil,callback,isNeedWait,retryType)
end

function HttpManager:unlockPracticeSkillPayReward(activityId, jackpotId, callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "unlock_practice_skill_reward", {activityId = activityId, jackpotId = jackpotId}, nil, callback, isNeedWait, retryType)
end


--获取千杯不醉活动相关信息
function HttpManager:getToastRewardList(callback,isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryGetWithHeader(DOMAIN.."get_toast_reward_list",nil,nil,callback,isNeedWait,retryType)
end

--驱赶千杯不醉接口
--times 敬酒次数
function HttpManager:toastQian(times,callback,isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryGetWithHeader(DOMAIN.."toast_qian/"..tostring(times),nil,nil,callback,isNeedWait,retryType)
end

--获取千杯不醉奖励接口
-- rid 奖励id
function HttpManager:getToastReward(rid, dataVer, callback,isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN.."get_toast_reward",{dataVer = dataVer, rid = rid},nil,callback,isNeedWait,retryType)
end

--[[
    @desc: 获得练功状态
    author:TangJian
    time:2022-03-30 17:36:30
    --@callback:
	--@isNeedWait:
	--@retryType: 
    @return:
]]
function HttpManager:getLianGongState(dataVer, codeVer, callback)
    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "getLianGongState", {dataVer = dataVer, codeVer = codeVer}, nil, callback, true, true)
end

--[[
    @desc: 开始练功
    author:TangJian
    time:2022-03-30 17:39:05
    --@dataVer: 存档版本
	--@codeVer: 功能版本
	--@actionData: 行为数据
	--@callback:
	--@isNeedWait:
	--@retryType: 
    @return:
    @post:
    {
        requestId = requestId, 
        dataVer = dataVer, 
        codeVer = codeVer, 
        actionData = 
        {
            xinShenCost = 心神消耗值,
            startTime = 开始时间,
        }
    }
]]
function HttpManager:lianGongStart(requestId, dataVer, codeVer, actionData, time, callback)
    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "lianGongStart", {requestId = requestId, dataVer = dataVer, codeVer = codeVer, actionData = actionData, time = time}, nil, callback, true, true)
end

--[[
    @desc: 
    author:TangJian
    time:2022-03-30 17:39:55
    --@dataVer: 存档版本
	--@codeVer: 功能版本
	--@actionData: 行为数据
	--@callback:
	--@isNeedWait:
	--@retryType: 
    @return:
    @post:
    {
        requestId = requestId, 
        dataVer = dataVer, 
        codeVer = codeVer, 
        actionData = actionData
        time = 当前时间
    }
]]
function HttpManager:lianGongFinish(requestId, dataVer, codeVer, actionData, time, callback)
    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "lianGongFinish", {requestId = requestId, dataVer = dataVer, codeVer = codeVer, actionData = actionData, time = time}, nil, callback, true, true)
end

--[[
    @desc: 行功散
    author:TangJian
    time:2022-04-01 16:26:05
    --@dataVer: 存档版本
	--@codeVer: 功能版本
	--@callback: 
    @return:
]]
function HttpManager:lianGongUseXingGongSan(requestId, dataVer, codeVer, time, callback)
    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "lianGongUseXingGongSan", {requestId = requestId, dataVer = dataVer, codeVer = codeVer, actionData = "", time = time}, nil, callback, true, true)
end

--[[
    @desc: 获得练功数据
    author:TangJian
    time:2022-04-01 16:26:43
    --@dataVer: 存档版本
	--@codeVer: 功能版本
	--@callback: 
    @return:
    @recv:
    {
        errcode = 0,
        data = 
        {
            startAction = 
            {
                data = 
                {
                    ver = 0,
                    skillId = self.__skillId,
                    xinshen = self.__xinshen,
                    startTime = GetTime(),
                    duration = self:calLianGongTime(),
                    selectJing = self:getSelectJing(),
                    selectLv = self:getSelectLv(),
                    xinShenCost = self:getCostXinShen(),
                    useXgsCount = 0,
                    variates = self:getVariates()
                },
                dataVer = 1, -- 数据版本
                codeVer = 2 -- 代码版本
            },
            useXgsCount = 999, -- 使用行功散数量
        }
    }
]]
function HttpManager:getLianGongData(dataVer, codeVer, callback)
    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "getLianGongData", {dataVer = dataVer, codeVer = codeVer}, nil, callback, true, true)
end

--[[
    @desc: 获得修炼状态
    author:TangJian
    time:2022-03-30 17:36:30
    --@callback:
	--@isNeedWait:
	--@retryType: 
    @return:
]]
function HttpManager:getXiuLianState(dataVer, codeVer, callback)
    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "getXiuLianState", {dataVer = dataVer, codeVer = codeVer}, nil, callback, true, true)
end

--[[
    @desc: 开始修炼
    author:TangJian
    time:2022-03-30 17:39:05
    --@dataVer: 存档版本
	--@codeVer: 功能版本
	--@actionData: 行为数据
	--@callback:
	--@isNeedWait:
	--@retryType: 
    @return:
]]
function HttpManager:xiuLianStart(requestId, dataVer, codeVer, actionData, time, callback)
    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "xiuLianStart", {requestId = requestId, dataVer = dataVer, codeVer = codeVer, actionData = actionData, time = time}, nil, callback, true, true)
end

--[[
    @desc: 
    author:TangJian
    time:2022-03-30 17:39:55
    --@dataVer: 存档版本
	--@codeVer: 功能版本
	--@actionData: 行为数据
	--@callback:
	--@isNeedWait:
	--@retryType: 
    @return:
]]
function HttpManager:xiuLianFinish(requestId, dataVer, codeVer, actionData, time, callback)
    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "xiuLianFinish", {requestId = requestId, dataVer = dataVer, codeVer = codeVer, actionData = actionData, time = time}, nil, callback, true, true)
end

--[[
    @desc: 行功散
    author:TangJian
    time:2022-04-01 16:26:05
    --@dataVer: 存档版本
	--@codeVer: 功能版本
	--@callback: 
    @return:
]]
function HttpManager:xiuLianUseXingGongSan(requestId, dataVer, codeVer, time, callback)
    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "xiuLianUseXingGongSan", {requestId = requestId, dataVer = dataVer, codeVer = codeVer, actionData = "", time = time}, nil, callback, true, true)
end

--[[
    @desc: 获得修炼数据
    author:TangJian
    time:2022-04-01 16:26:43
    --@dataVer: 存档版本
	--@codeVer: 功能版本
	--@callback: 
    @return:
]]
function HttpManager:getXiuLianData(dataVer, codeVer, callback)
    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "getXiuLianData", {dataVer = dataVer, codeVer = codeVer}, nil, callback, true, true)
end

--[[
    @desc: 获取当前心神值和心神最大值
    author:TangJian
    time:2022-04-08 17:18:59
    --@dataVer:
	--@codeVer:
	--@callback: 
    @return:
    @recv: 
    {
        curr = 当前值，
        max = 最大值
    }
]]
function HttpManager:getXinShenValue(dataVer, codeVer, callback)
    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "getXinShenValue", {dataVer = dataVer, codeVer = codeVer}, nil, callback, true, true)
end

--[[
    @desc: 升级心神等级
    author:TangJian
    time:2022-04-08 17:19:20
    --@dataVer:
	--@codeVer:
	--@callback: 
    @return:
    @recv: 
    {
        curr = 当前值，
        max = 最大值
    }
]]
function HttpManager:upgradeXinShenLevel(requestId, dataVer, codeVer, time, callback)
    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "upgradeXinShenLevel", {requestId = requestId, dataVer = dataVer, codeVer = codeVer, actionData = "", time = time}, nil, callback, true, true)
end

--[[
    @desc: 
    author:TangJian
    time:2022-04-11 15:52:13
    --@dataVer:
	--@codeVer:
	--@callback: 
    @return:
    @recv: 
    {
        level = 当前心神等级
    }
]]
function HttpManager:getXinShenLevel(dataVer, codeVer, callback)
    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "getXinShenLevel", {dataVer = dataVer, codeVer = codeVer}, nil, callback, true, true)
end

--[[
    @desc: 
    author:TangJian
    time:2022-04-12 18:59:09
    --@dataVer:
	--@codeVer:
	--@callback: 
    @return:
    @recv: 
    {
        time = time
    }
]]
function HttpManager:getXinShenRecoverStartTime(dataVer, codeVer, callback)
    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "getXinShenRecoverStartTime", {dataVer = dataVer, codeVer = codeVer}, nil, callback, true, true)
end

function HttpManager:recoverXinShenValue(value, dataVer, codeVer, time, callback)
    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "recoverXinShenValue", {dataVer = dataVer, codeVer = codeVer, value = value, actionData="", time=time}, nil, callback, true, true)
end

function HttpManager:getLianGongTiLi(dataVer, codeVer, callback)
    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "get_liangong_tili", {dataVer = dataVer, codeVer = codeVer}, nil, callback, true, true)
end

function HttpManager:testAddLianGongTiLi(count, dataVer, codeVer, callback)
    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "test_add_liangong_tili", {count = count, dataVer = dataVer, codeVer = codeVer}, nil, callback, true, true)
end

--@desc: 获取地仓府库活动详情
--@author:LvBin
--@time:2022-06-10 14:40:13
--@callback:
	--@isNeedWait:
	--@retryType: 
--@return
function HttpManager:getWareHouseActivityInfo(callback,isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryGetWithHeader(DOMAIN.."get_treasury_info",nil,nil,callback,isNeedWait,retryType)
end

--@desc: 地仓府库抽奖
--@author:LvBin
--@time:2022-06-10 14:40:59
--@index: 抽的是第几个格子
	--@callback:
	--@isNeedWait:
	--@retryType: 
--@return
function HttpManager:WareHouseDrawLucky(index,callback,isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN.."treasury_lottery",{index = index},nil,callback,isNeedWait,retryType)
end

--@desc: 领取地仓府库奖励
--@author:LvBin
--@time:2022-06-10 14:42:54
--@rewardType: 1,固定进度奖励;2,随机奖池奖励
	--@awardId: 奖励id
    --@getType: 1,本地直接领取;2服务器领取,3,背包不够,邮件发放
    --@dataVer: 行为系统数据版本号
	--@callback:
	--@isNeedWait:
	--@retryType: 
--@return
function HttpManager:getWareHouseAward(rewardType,awardId,getType,dataVer,callback,isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN.."get_treasury_reward",{rewardType = rewardType,awardId = awardId,getType = getType,dataVer = dataVer},nil,callback,isNeedWait,retryType)
end

--@desc: 进入地仓府库下一层
--@author:LvBin
--@time:2022-06-10 14:45:27
--@callback:
	--@isNeedWait:
	--@retryType: 
--@return
function HttpManager:enterWareHouseNextFloor(callback,isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryGetWithHeader(DOMAIN.."enter_next_treasury",nil,nil,callback,isNeedWait,retryType)
end

--[[
    @desc: 获取服务器物品数目
    author:TangJian
    time:2022-06-11 15:42:32
    --@itemId: 物品id
	--@dataVer: 数据版本
	--@codeVer: 代码版本
	--@callback: 
    @return:
]]
function HttpManager:getItemCount(itemId, dataVer, codeVer, callback)
    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "getItemCount", {dataVer = dataVer, codeVer = codeVer, itemId = itemId}, nil, callback, true, true)
end

--[[
    @desc: 添加服务器物品
    author:TangJian
    time:2022-06-11 15:35:51
    --@itemId: 物品Id
	--@count: 物品数目
	--@dataVer: 数据版本
	--@codeVer: 代码版本
	--@callback: 
    @return:
]]
function HttpManager:addItemCount(itemId, count, dataVer, codeVer, callback)
    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "addItemCount", {dataVer = dataVer, codeVer = codeVer, itemId = itemId, count = count}, nil, callback, true, true)
end

--[[
    @desc: 使用服务器物品
    author:TangJian
    time:2022-06-11 15:35:41
    --@itemId:
	--@dataVer:
	--@codeVer:
	--@callback: 
    @return:
]]
function HttpManager:useItem(itemId, dataVer, codeVer, callback)
    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "useItem", {dataVer = dataVer, codeVer = codeVer, itemId = itemId}, nil, callback, true, true)
end

--[[
    @desc: 获取服务器物品列表
    author:TangJian
    time:2022-06-11 15:35:08
    --@callback: 
    @return:
]]
function HttpManager:getItemMap(callback)
    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "getItemMap", {}, nil, callback, true, true)
end

-- 刷新物品表缓存
function HttpManager:refreshItemMapCache(dataVer, codeVer, callback)
    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "refreshItemMapCache", {dataVer = dataVer, codeVer = codeVer}, nil, callback, true, true)
end

--获取周年登录信息
function HttpManager:getAnniversaryLoginList(callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryGetWithHeader(DOMAIN .. "get_anniversary_login_list", nil, nil, callback, isNeedWait, retryType)
end

--获取周年登录奖励
function HttpManager:getAnniversaryLoginReward(rid, is_enough, dataVer, callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "get_anniversary_login_reward", {rid = rid, is_enough = is_enough, dataVer = dataVer}, nil, callback, isNeedWait, retryType)
end

function HttpManager:getViewingHall(callback,isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryGetWithHeader(DOMAIN.."get_viewing_hall",nil,nil,callback,isNeedWait,retryType)
end

--获取观影堂奖励
--id 奖励id
--is_free 0:免费，1:消耗观影券
--is_email 0:背包存放，1:邮件发送
function HttpManager:getViewingReward(id, is_free, is_email, callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "get_viewing_reward", {id = id, is_free = is_free, is_email = is_email}, nil, callback, isNeedWait, retryType)
end

--铁匠铺
function HttpManager:getSmithyInfo(callback,isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryGetWithHeader(DOMAIN.."get_smithy_info",nil,nil,callback,isNeedWait,retryType)
end

--获取铁匠铺奖励
--rid 奖励id
--is_email 0:背包存放，1:邮件发送
function HttpManager:getSmithyReward(rid, is_email, callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "get_smithy_reward", {rid = rid, is_email = is_email}, nil, callback, isNeedWait, retryType)
end

function HttpManager:uploadWeaponRepairLog(logData, callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "upload_weapon_repair_log", logData, nil, callback, isNeedWait, retryType)
end

--优化版香囊密阁获取信息
function HttpManager:getSachetAtticNewList(activity_id, callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryGetWithHeader(DOMAIN .. "get_sachet_attic_new_list/"..tostring(activity_id), nil, nil, callback, isNeedWait, retryType)
end

--优化版香囊密阁获取奖励
function HttpManager:exchangeAwardToSachetNew(activity_id, reward_id, is_email, dataVer, callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "exchange_award_to_sachet_new", {activity_id = activity_id, is_email = is_email, reward_id = reward_id, dataVer = dataVer}, nil, callback, isNeedWait, retryType)
end

--醒梦堂
function HttpManager:getWakingDreamInfo(callback,isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryGetWithHeader(DOMAIN.."get_waking_dream_info",nil,nil,callback,isNeedWait,retryType)
end

--获取醒梦堂奖励
--rid 奖励id
--is_email 0:背包存放，1:邮件发送
function HttpManager:getWakingDreamReward(rid, is_email, dataVer, callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "get_waking_dream_reward", {rid = rid, is_email = is_email, dataVer = dataVer}, nil, callback, isNeedWait, retryType)
end

--醒梦堂解锁奖池
--jackpotId 奖池id
function HttpManager:unlockWakingDreamPayReward(jackpotId, callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "unlock_waking_dream_pay_reward", {jackpotId = jackpotId}, nil, callback, isNeedWait, retryType)
end

--日掷斗金
function HttpManager:getYuanbaoConsumptionInfo(callback,isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryGetWithHeader(DOMAIN.."get_yuanbao_consumption_info",nil,nil,callback,isNeedWait,retryType)
end

--获取日掷斗金奖励
--rid 奖励id
--is_email 0:背包存放，1:邮件发送
function HttpManager:getYuanbaoConsumptionReward(rid, is_email, callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "get_yuanbao_consumption_reward", {rid = rid, is_email = is_email}, nil, callback, isNeedWait, retryType)
end

--丹青阁
function HttpManager:getDanQingPavilionInfo(callback,isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryGetWithHeader(DOMAIN.."get_danqing_pavilion_info",nil,nil,callback,isNeedWait,retryType)
end

--兑换丹青阁奖励
function HttpManager:exchangeDanQingPavilionItem(id, rid, dataVer, callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "exchange_danqing_pavilion_item", {id = id, rid = rid, dataVer = dataVer}, nil, callback, isNeedWait, retryType)
end

--获取丹青阁奖励
--id 奖励id
function HttpManager:getDanQingPavilionReward(id, dataVer, callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "get_danqing_pavilion_reward", {id = id, dataVer = dataVer}, nil, callback, isNeedWait, retryType)
end

--获取历史存档神兵数据
function HttpManager:getUserShenBings(callback,isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryGetWithHeader(DOMAIN.."get_user_shenbings",nil,nil,callback,isNeedWait,retryType)
end

-----------------------------------------------------------------------------------------------------------
--@desc: 完成拳脚系统前置任务,创建拳脚系统信息
--@author:LvBin
--@time:2022-09-17 19:05:40
function HttpManager:createFistInfo(dataVer,codeVer,callback,isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN.."create_fist_info",{dataVer = dataVer, codeVer = codeVer},nil,callback,isNeedWait,retryType)
end

--@desc: 获取拳脚系统数据
--@author:LvBin
--@time:2022-09-19 20:10:49
function HttpManager:getFistFootInFo(dataVer,codeVer,callback,isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN.."get_fist_info",{dataVer = dataVer, codeVer = codeVer},nil,callback,isNeedWait,retryType)
end

--@desc: 开始修行任务
--@author:LvBin
--@time:2022-09-19 20:17:52
--@taskId:任务id
function HttpManager:startFistTask(taskId,dataVer,codeVer,callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "start_fist_task", {taskId = taskId,dataVer = dataVer, codeVer = codeVer}, nil, callback, isNeedWait, retryType)
end

function HttpManager:stopFistTask(taskId, dataVer,codeVer,callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "stop_fist_task", {taskId = taskId,dataVer = dataVer, codeVer = codeVer}, nil, callback, isNeedWait, retryType)
end

function HttpManager:finishFistTask(taskId, bagEnough, dataVer,codeVer,callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "finish_fist_task", {taskId = taskId,bagEnough = bagEnough,dataVer = dataVer, codeVer = codeVer}, nil, callback, isNeedWait, retryType)
end

function HttpManager:speedUpFistTask(taskId,cost, dataVer,codeVer,callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "expedite_fist_task", {taskId = taskId,cost = cost,dataVer = dataVer, codeVer = codeVer}, nil, callback, isNeedWait, retryType)
end

function HttpManager:upgradeTechnique(techniqueId, dataVer,codeVer,callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "upgrade_technique", {techniqueId = techniqueId,dataVer = dataVer, codeVer = codeVer}, nil, callback, isNeedWait, retryType)
end

function HttpManager:extractCharacter(techniqueId, dataVer,codeVer,callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "grasp_technique_feature", {techniqueId = techniqueId,dataVer = dataVer, codeVer = codeVer}, nil, callback, isNeedWait, retryType)
end

function HttpManager:replaceCharacter(techniqueId, dataVer,codeVer,callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "replace_technique_feature", {techniqueId = techniqueId,dataVer = dataVer, codeVer = codeVer}, nil, callback, isNeedWait, retryType)
end

function HttpManager:resetTalentPage(talentPageId, dataVer,codeVer,callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "reset_fist_technique", {techniquePageId = talentPageId,dataVer = dataVer, codeVer = codeVer}, nil, callback, isNeedWait, retryType)
end

function HttpManager:getTalentPageInfo(dataVer, codeVer,callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "get_talent_info", {dataVer = dataVer, codeVer = codeVer}, nil, callback, isNeedWait, retryType)
end

function HttpManager:getCharacterPoolInfo(poolId, dataVer, codeVer,callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "get_characterPool_info", {papool = poolId,dataVer = dataVer, codeVer = codeVer}, nil, callback, isNeedWait, retryType)
end

function HttpManager:updataFistFlag(addFlags,deleteFlags, dataVer, codeVer,callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "updata_fist_flag", {addFlags = addFlags,deleteFlags = deleteFlags,dataVer = dataVer, codeVer = codeVer}, nil, callback, isNeedWait, retryType)
end

function HttpManager:getFistTasks(dataVer, codeVer,callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "get_fist_tasks", {dataVer = dataVer, codeVer = codeVer}, nil, callback, isNeedWait, retryType)
end



--@desc: 设置拳脚系统分支经验
--@author:LvBin
--@time:2022-09-23 15:36:05
--@branchId:
--@branchExp:
--@return
function HttpManager:testSetFistBranchExp(branchId,branchExp, dataVer,codeVer,callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "test_set_fist_branch_level", {branchExp = branchExp,branchId = branchId,dataVer = dataVer, codeVer = codeVer}, nil, callback, isNeedWait, retryType)
end

--设置潜思经验
function HttpManager:testSetFistReflectExp(exp,dataVer,codeVer,callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "test_set_fist_reflect_level", {exp = exp,dataVer = dataVer, codeVer = codeVer}, nil, callback, isNeedWait, retryType)
end

--设置技巧等级
function HttpManager:testSetFistTechniqueLevel(techniqueId,level,dataVer,codeVer,callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "test_set_fist_technique_level", {techniqueId = techniqueId,level = level,dataVer = dataVer, codeVer = codeVer}, nil, callback, isNeedWait, retryType)
end

--添加感悟点数
function HttpManager:testAddFeelPoint(number,dataVer,codeVer,callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "test_add_fist_feel_point", {number = number,dataVer = dataVer, codeVer = codeVer}, nil, callback, isNeedWait, retryType)
end

--@desc: 添加技巧心得页
--@author:Seven
--@time:2023-01-09 11:05:16
function HttpManager:testAddTalentPage(dataVer,codeVer,callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "test_add_talent_page", {dataVer = dataVer, codeVer = codeVer}, nil, callback, isNeedWait, retryType)
end

--@desc: 切换技巧心得
--@author:Seven
--@time:2023-01-09 10:46:32
--@return:
function HttpManager:switchTalentPage(pageNum, codeVer, dataVer, callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "switch_talent_page", {pageIndex = pageNum, dataVer = dataVer, codeVer = codeVer}, nil, callback, isNeedWait, retryType)
end

-----------------------------------------------------------------------------------------------------------

--武门试炼
function HttpManager:getWuMenTrialInfo(dataVer, callback,isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN.."get_wumen_trial_info",{dataVer = dataVer},nil,callback,isNeedWait,retryType)
end

function HttpManager:getWuMenTrialReward(id, dataVer, callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "get_wumen_trial_reward", {id = id,dataVer = dataVer}, nil, callback, isNeedWait, retryType)
end

-----------------------------------------------------------------------------------------------------------
--@desc: 获取招式对练详情
--@author:LvBin
--@time:2022-11-07 18:24:14
--@npcId: 对练的npcId
	--@callback:
	--@isNeedWait:
	--@retryType: 
--@return
function HttpManager:getZhaoPracticeInfo(npcId , mid,callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "get_zhao_practiceInfo", {npcId = npcId,mid = mid}, nil, callback, isNeedWait, retryType)
end

--@desc: 对练
--@author:LvBin
--@time:2022-11-07 18:25:24
--@npcId: 对练的npcId
--@zhaoId: 对练的招式id
	--@type: 对练类型，1.普通对练 2.加速对练
	--@callback:
	--@isNeedWait:
	--@retryType: 
--@return
function HttpManager:zhaoPractice(npcId , mid, zhaoId, type, price, callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "zhao_practice", {npcId = npcId,mid = mid,zhaoId = zhaoId,type = type,price = price}, nil, callback, isNeedWait, retryType)
end

--@desc: 赠与残页
--@author:LvBin
--@time:2022-11-07 18:25:56
--@npcId: 赠与残页的npcId
	--@zhaoId: 残页对应的招式id
	--@callback:
	--@isNeedWait:
	--@retryType: 
--@return
function HttpManager:giftZhaoPage(npcId , mid, zhaoId, callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "gift_zhao_page", {npcId = npcId,mid = mid,zhaoId = zhaoId}, nil, callback, isNeedWait, retryType)
end

--@desc: 遗忘残页
--@author:LvBin
--@time:2022-11-07 18:27:23
--@npcId: 遗忘残页的npcId
	--@zhaoId: 残页对应的招式id
	--@callback:
	--@isNeedWait:
	--@retryType: 
--@return
function HttpManager:forgetZhaoPage(npcId , mid, zhaoId, callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "forget_zhao_page", {npcId = npcId, mid = mid, zhaoId = zhaoId}, nil, callback, isNeedWait, retryType)
end

--获取招财进宝相关数据
function HttpManager:getZhaoCaiJinBaoInfo(activity_id, callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryGetWithHeader(DOMAIN .. "get_zhaocaijinbao_info/" .. activity_id, nil, nil, callback, isNeedWait, retryType)
end

--领取招财进宝奖励
function HttpManager:getZhaoCaiJinBaoReward(activity_id, id, reward_id, is_email, dataVer, callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "get_zhaocaijinbao_reward", {id = id, activity_id = activity_id, reward_id = reward_id, dataVer = dataVer, is_email = is_email}, nil, callback, isNeedWait, retryType)
end

--购买黑商商品
function HttpManager:buyBlackGoods(goodsInfo , client_trans_id, mark, callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "buy_black_goods", {goodsInfo = goodsInfo, client_trans_id = client_trans_id, mark = mark}, nil, callback, isNeedWait, retryType)
end


--获取藏经阁列表
function HttpManager:getSutraPavilionList(activity_id, is_refresh, levelType, callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "get_sutra_pavilion_list", {activity_id = activity_id, is_refresh = is_refresh, levelType = levelType}, nil, callback, isNeedWait, retryType)
end

--购买藏经阁奖励
function HttpManager:buySutraPavilionGoods(activity_id, id, callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "buy_sutra_pavilion_goods", {activity_id = activity_id, id = id}, nil, callback, isNeedWait, retryType)
end

--易金圩市
function HttpManager:getCuiLianCaiLiaoStoreList(activity_id, callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryGetWithHeader(DOMAIN .. "get_cuiLianCaiLiao_store_list/"..activity_id, nil, nil, callback, isNeedWait, retryType)
end

---------------------------------------------------------------------------------------------------
--@desc: 获取师门建设数据
--@author:LvBin
--@time:2023-08-18 15:13:17
--@return
function HttpManager:getTeacherBuildInFo(familyId,callback,isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN.."get_teacherBuild_info",{familyId = familyId},nil,callback,isNeedWait,retryType)
end

--@desc: 开始师门建设任务
--@author:LvBin
--@time:2023-08-18 15:29:29
--@taskId:
--@return
function HttpManager:startTeacherBuildTask(taskId,familyId,callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "start_teacherBuild_task", {taskId = taskId,familyId = familyId}, nil, callback, isNeedWait, retryType)
end

--@desc: 停止师门建设任务
--@author:LvBin
--@time:2023-08-18 15:33:48
--@taskId:
--@return
function HttpManager:stopTeacherBuildTask(taskId,familyId,callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "stop_teacherBuild_task", {taskId = taskId,familyId = familyId}, nil, callback, isNeedWait, retryType)
end

--@desc: 完成师门建设任务
--@author:LvBin
--@time:2023-08-18 15:35:14
--@taskId:
--@return
function HttpManager:finishTeacherBuildTask(taskId, familyId ,callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "finish_teacherBuild_task", {taskId = taskId,familyId = familyId}, nil, callback, isNeedWait, retryType)
end

--@desc: 加速师门建设任务
--@author:LvBin
--@time:2023-08-18 15:42:24
--@taskId:
--@cost:
--@return
function HttpManager:speedUpTeacherBuildTask(taskId,cost,familyId,callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "speedUp_teacherBuild_task", {taskId = taskId,cost = cost,familyId = familyId}, nil, callback, isNeedWait, retryType)
end

--@desc: 获取师门建设任务列表
--@author:LvBin
--@time:2023-08-19 11:42:24
--@familyId: 师门id
--@return
function HttpManager:getTeacherBuildTasks(familyId,callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "get_teacherBuild_tasks",{familyId = familyId}, nil, callback, isNeedWait, retryType)
end

--@desc: 更新师门建设日常任务标记
--@author:LvBin
--@time:2023-08-21 17:48:29
--@addFlags:
--@deleteFlags:
--@return
function HttpManager:updataTeacherBuildFlag(addFlags,deleteFlags,familyId,callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "updata_teacherBuild_flag", {addFlags = addFlags,deleteFlags = deleteFlags,familyId = familyId}, nil, callback, isNeedWait, retryType)
end

--@desc: 获取师门建筑数据
--@author:LvBin
--@time:2023-10-11 11:03:03
--@familyId:
	--@callback:
	--@isNeedWait:
	--@retryType: 
--@return
function HttpManager:getTeacherBuildData(familyId,callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "get_teacherBuild_list",{familyId = familyId}, nil, callback, isNeedWait, retryType)
end

--@desc: 获取师门建筑材料信息
--@author:LvBin
--@time:2023-10-11 11:12:25
--@familyId:
	--@callback:
	--@isNeedWait:
	--@retryType: 
--@return
function HttpManager:getTeacherBuildItems(familyId,callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "get_teacherBuild_items",{familyId = familyId}, nil, callback, isNeedWait, retryType)
end

--@desc: 兴建师门建筑
--@author:LvBin
--@time:2023-10-13 17:41:44
--@buildTypeId:
	--@familyId:
	--@callback:
	--@isNeedWait:
	--@retryType: 
--@return
function HttpManager:buildTeacherBuild(buildTypeId,familyId,callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "build_teacherBuild",{buildTypeId = buildTypeId,familyId = familyId}, nil, callback, isNeedWait, retryType)
end

--@desc: 获取建筑捐献信息
--@author:LvBin
--@time:2023-10-11 11:15:10
--@buildTypeId:
	--@familyId:
	--@callback:
	--@isNeedWait:
	--@retryType: 
--@return
function HttpManager:getTeacherBuildDonateInfo(buildTypeId,familyId,callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "get_teacherBuild_donateInfo",{buildTypeId = buildTypeId,familyId = familyId}, nil, callback, isNeedWait, retryType)
end

--@desc: 捐献建筑材料
--@author:LvBin
--@time:2023-10-11 11:16:01
--@buildTypeId:
	--@familyId:
	--@donateId:
	--@callback:
	--@isNeedWait:
	--@retryType: 
--@return
function HttpManager:donateTeacherBuild(buildTypeId,donateId,donateState,familyId,callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "donate_teacherBuild",{buildTypeId = buildTypeId,familyId = familyId,donateId = donateId,donateState = donateState}, nil, callback, isNeedWait, retryType)
end

--@desc: 师门建筑开放等级升级
--@author:LvBin
--@time:2023-10-11 11:16:28
--@buildTypeId:
	--@familyId:
	--@callback:
	--@isNeedWait:
	--@retryType: 
--@return
function HttpManager:upgradeTeacherBuild(buildTypeId,familyId,callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "upgrade_teacherBuild",{buildTypeId = buildTypeId,familyId = familyId}, nil, callback, isNeedWait, retryType)
end

--@desc: 获取师门名绩数据
--@author:LvBin
--@time:2024-03-11 17:15:11
--@familyId:
	--@callback:
	--@isNeedWait:
	--@retryType: 
--@return
function HttpManager:getTeacherFeatData(familyId,callback,isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN.."get_teacherFeat_info",{familyId = familyId},nil,callback,isNeedWait,retryType)
end

--@desc: 领取师门名绩奖励
--@author:LvBin
--@time:2024-03-12 16:09:25
--@familyId: 师门id
--@featId: 师门建树配置id
--@dataVer: 数据版本号
--@return
function HttpManager:getTeacherFeatReward(familyId,featId,dataVer,callback,isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN.."get_teacherFeat_reward",{familyId = familyId,featId = featId,dataVer = dataVer},nil,callback,isNeedWait,retryType)
end

--@desc: 师门建设测试接口
--@author:LvBin
--@time:2023-08-23 21:20:32
--@return
function HttpManager:testTeacherBuildAction(type,number,callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "test_sect_build_action", {type = type,number = number}, nil, callback, isNeedWait, retryType)
end

--@desc: 测试接口，修改建筑经验
--@author:LvBin
--@time:2023-10-20 10:19:49
--@familyId:
	--@buildTypeId:
	--@number:
	--@callback:
	--@isNeedWait:
	--@retryType: 
--@return
function HttpManager:testUpdateBuildingDegree(familyId,buildTypeId,number,callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "test_update_building_degree", {familyId = familyId,buildTypeId = buildTypeId,number = number}, nil, callback, isNeedWait, retryType)
end

--领取藏经阁奖励
function HttpManager:getSutraPavilionGoods(activity_id, id, is_email, dataVer, callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "get_sutra_pavilion_goods", {activity_id = activity_id, id = id, dataVer = dataVer, is_email = is_email}, nil, callback, isNeedWait, retryType)
end

--易金圩市购买礼包
function HttpManager:buyCuiLianCaiLiaoStoreGoods(activity_id, id, currencyId, callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "buy_cuiLianCaiLiao_store_goods", {activity_id = activity_id, id = id, currencyId = currencyId}, nil, callback, isNeedWait, retryType)
end

--易金圩市获取礼包奖励
function HttpManager:getCuiLianCaiLiaoStoreReward(activity_id, id, is_email, dataVer, callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "get_cuiLianCaiLiao_store_reward", {id = id, activity_id = activity_id, dataVer = dataVer, is_email = is_email}, nil, callback, isNeedWait, retryType)
end

--易金圩市兑换积分
function HttpManager:exchangeCuiLianCaiLiaoStoreIntegral(activity_id, id, number, callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "exchange_cuiLianCaiLiao_store_integral", {id = id, activity_id = activity_id, number = number}, nil, callback, isNeedWait, retryType)
end

-- 客户端环境信息上传
function HttpManager:uploadClientEnvMessage(env, callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "upload_client_error_message", env, nil, callback, isNeedWait, retryType)
end

-- 叛师接口
-- familyId 当前门派
-- newFamilyId  叛师后门派
function HttpManager:TransferHomegateGroup(familyId, newFamilyId, callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "transfer_homegate_group", {familyId = familyId, newFamilyId = newFamilyId}, nil, callback, isNeedWait, retryType)
end

--测试接口
--快捷指定解锁某技巧特性
function HttpManager:testUpdateTechniqueFeature(techniqueId, characterId, dataVer,codeVer,callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "test_update_technique_feature", {techniqueId = techniqueId, characterId = characterId, dataVer = dataVer, codeVer = codeVer}, nil, callback, isNeedWait, retryType)
end

-- 功绩商店
-- familyId 当前门派
-- isRefresh 是否刷新
function HttpManager:getSectMeritStore(familyId, isRefresh, callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "get_sect_merit_store", {familyId = familyId, isRefresh = isRefresh}, nil, callback, isNeedWait, retryType)
end

-- 功绩商店购买
-- familyId 当前门派
-- id 商品id
function HttpManager:buyMeritGoods(familyId, id, callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "buy_merit_goods", {familyId = familyId, id = id}, nil, callback, isNeedWait, retryType)
end

-- 功绩商店领取
-- familyId 当前门派
-- id 商品id
-- isSent 邮箱发放（1：邮件发送，0：未发送）
function HttpManager:getMeritGoods(familyId, id, dataVer, isSent, callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "get_merit_goods", {familyId = familyId, id = id, dataVer = dataVer, isSent = isSent}, nil, callback, isNeedWait, retryType)
end

--@desc: 获取散人装备武学心法限制条件数据
--@author:LvBin
--@time:2023-11-10 11:56:39
--@familyId:
	--@callback:
	--@isNeedWait:
	--@retryType: 
--@return
function HttpManager:getYouXiaMcmrestrictUpgradeCondition(familyId, callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "get_youxia_upgradeCondition", {familyId = familyId}, nil, callback, isNeedWait, retryType)
end

--@desc: 散人升级装备武学心法限制
--@author:LvBin
--@time:2023-11-10 11:57:20
--@familyId:
	--@callback:
	--@isNeedWait:
	--@retryType: 
--@return
function HttpManager:youxiaUpgradeMcmrestrict(familyId, callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "youxia_upgrade_condition", {familyId = familyId}, nil, callback, isNeedWait, retryType)
end

--@desc: 删除散人心法
--@author:LvBin
--@time:2023-12-16 15:57:20
function HttpManager:deleteYouXiaMcmrestrict(callback, isNeedWait, retryType)
    callback = self:createGetResponseFunction(callback)
    self:retryGetWithHeader(DOMAIN .. "delete_youxia_upgradeCondition", nil, nil, callback, isNeedWait, retryType)
end

-- 修改角色门派，保留师门建筑等数据
-- familyId 门派id
function HttpManager:testUpdateUserFamily(familyId, callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "test_update_user_family", {familyId = familyId}, nil, callback, isNeedWait, retryType)
end

--@desc: 获取账号注销网址
--@author:LvBin
--@time:2024-01-06 16:14:17
--@callback:
	--@isNeedWait:
	--@retryType: 
--@return
function HttpManager:getLogoutAccountUrl(callback, isNeedWait, retryType)
    callback = self:createGetResponseFunction(callback)
    self:retryGetWithHeader(DOMAIN .. "get_logoutAccount_url", nil, nil, callback, isNeedWait, retryType, NEED_ENCRYPT)
end

--师门建筑兑换商店获取
function HttpManager:getSectExchangeStore(familyId, callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "get_sect_exchangeStore", {familyId = familyId}, nil, callback, isNeedWait, retryType)
end

--师门建筑兑换商店购买
function HttpManager:buySectExchangeGoods(familyId, id, callback, isNeedWait, retryType)
    local callback = self:createGetResponseFunction(callback)
    self:retryPostWithHeader(DOMAIN .. "buy_sect_exchangeGoods", {familyId = familyId, id = id}, nil, callback, isNeedWait, retryType)
end

--@desc: 删除美容丸初始化测试接口
--@author:Seven
--@time:2024-01-25 17:46:04
function HttpManager:testDeleteMeiRongWanInit(callback, isNeedWait, retryType)
    callback = self:createGetResponseFunction(callback)
    self:retryGetWithHeader(DOMAIN .. "test_delete_initial_meirongwan", nil, nil, callback, isNeedWait, retryType, NEED_ENCRYPT)
end

-----------------------------------------------------------------------------------------------------------

return HttpManager
0000000000000