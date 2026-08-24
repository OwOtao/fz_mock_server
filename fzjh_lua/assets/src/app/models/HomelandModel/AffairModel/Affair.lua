--@RefType [src.app.views.layer.ShenBingLayer.CommonLayer.binding#binding]
local binding = require("app.views.layer.ShenBingLayer.CommonLayer.binding")

--@RefType [src.app.models.HomelandModel.HomelandDesc#HomelandDesc]
local HomelandDesc = require("app.models.HomelandModel.HomelandDesc")

--@RefType [src.app.models.HomelandModel.HomelandRoleUtil#HomelandRoleUtil]
local HomelandRoleUtil = require("app.models.HomelandModel.HomelandRoleUtil")

--@RefType [src.app.models.HomelandModel.AffairModel.AffairEvent#AffairEvent]
local AffairEvent = require("app.models.HomelandModel.AffairModel.AffairEvent")

local DiQiModel = require("app.models.HomelandModel.DiQiModel")

local payMethod = {yinpiao = "银票", yuanbao = "元宝"}

local AffairType = {
    register = 1, 
    operation = 2,
    message = 3
}

local Affair = {
    id = nil,
    affair_id = nil,
    biz_type = nil,
    from_id = nil,
    affair_val = {},
    count = nil,
    ui_state = 0, -- 给UI使用，0代表没有点中，1代表点中
    is_read = 0, -- 查看这条事务是否已读,
    is_handle = 0, -- 是否处理完成
    is_local = 0, -- 是否本地事务，1为本地事务，0为服务器下发
    --[[
        event = {
            --@desc 该字段在AffairEvent 类中注册处理

            handleEventConditon 对应handleEvent方法的处理前置条件
            handleEvent 对应btnName按钮的处理方法

            handleEventConditon1 对应handleEvent1方法的处理前置条件
            handleEvent1 对应btnName1 按钮的处理方法

        }
    ]]
    event = {}, -- 储存事件方法
    text = nil, -- 事务的描述
    btnName = nil, -- 按钮显示的名称
    btnName1 = nil, -- 按钮显示的名称
    titleName = nil, -- 事务按钮的名称
    type = nil -- 事务类型:1.欠薪名册，2.等待操作 3.消息通知
}

--[[
    {
		"id": 56,
		"biz_type": 1
		"affair_val": {
			"name": "房主的名字",
			"from_name": "求购者的名字",
			"currency": "yinpiao",
			"num": 10000,
			"dpId": ""
		},
		"from_id": "1008", -- 发送给你事务的玩家UID
		"expired_time": "2018-07-01 23:59:59", -- 过期时间
		"create_time": "2018-05-30 16:43:01", -- 创建时间
		"affair_id": 8, -- 事务类型子ID
		"count": ""
	}

]]
function Affair:create(data)
    local p = binding.bindable(Affair)
    p:init(data)
    return p
end

function Affair:initByConf()
    switch(
        self.affair_id,
        {
            --@desc 房屋升级
            [1] = self.upgradeHouse,
            --@desc 支付地税
            [2] = self.payLandTax,
            --@desc 仆人发薪
            [3] = self.paySalaryForPuRen,
            --@desc 门客发薪
            [4] = self.paySalaryForMenKe,
            --@desc 求购土地相关
            [5] = self.askToBuy,
            --@desc 拜访
            [6] = self.visited,
            --@desc 闯门
            [7] = self.intruded,
            --@desc 邀请函
            [8] = self.invitation,
            --@desc 仆人离开
            [9] = self.puRenLeave,
            --@desc 土地回收
            [10] = self.landRecycle,
            --@desc 土地转让
            [11] = self.transferLand,
            --@desc 仆人异常离开（eg:自动离开）
            [12] = self.abnormalLeave,
            -- 登门拜年
            [13] = self.newYearVisited,
            -- 门客出走提示 安闲而游
            [14] = self.menkeWarning
        },
        self
    )
end

--@desc: 初始化数据
--@author:Liang SongQiang
--@time:2018-08-08 16:00:25
--@data:
function Affair:init(data)
    for k, v in pairs(data) do
        self[k] = v
    end

    self:initByConf()
end

--@desc:求购时设置的参数
--@author:Liang SongQiang
--@time:2018-08-09 19:10:50
--@process_type: 1 求购成功 2、拒绝求购
function Affair:setProcessType(process_type)
    self.process_type = process_type
end

--@desc:
--@author:Liang SongQiang
--@time:2018-08-09 21:32:12
function Affair:setIsRead(state)
    self.is_read = state
end

function Affair:getIsRead()
    return self.is_read
end

function Affair:setUiState(state)
    self.ui_state = state
end

function Affair:setDealType(deal_type)
    if deal_type ~= "process" and deal_type ~= "read" then
        self.deal_type = "process"
    end

    self.deal_type = deal_type
end

function Affair:getDealType()
    return self.deal_type
end

--@desc: 获取描述文本
--@author:Liang SongQiang
--@time:2018-08-09 21:15:29
function Affair:getText()
    return self.text
end

function Affair:getType()
    return self.type
end

--@desc: 事务插入
--@author:Liang SongQiang
--@time:2018-08-08 15:59:21
--@callback: 回调函数
function Affair:push(callback)
    HttpManagerEx:pushAffair(
        self.push_data,
        function(status, errcode, errmsg, data)
            if status == 200 then
                if errcode == 0 then
                    callback(data)
                else
                    PopText(errmsg)
                    print("errmsg", errmsg, "errcode", errcode)
                end
            else
                print("errmsg", errmsg, "errcode", errcode)
            end
        end,
        IS_SHOW_WAITING
    )
end

--@desc: 查看事务触发事件
--@author:Liang SongQiang
--@time:2018-08-08 15:59:45
--@callback: 点击（阅读）事件触发
function Affair:clickEvent(callback)
    if self:getIsRead() == 0 then
        self:setIsRead(1)

        --@desc 本地事务无需通知服务器
        if self.is_local == 1 then
            callback()
        else
            self:setDealType("read")
            self:processEvent(callback)
        end
    else
        callback()
    end
end

--@desc: 事务处理触发事件
--@author:Liang SongQiang
--@time:2018-08-08 15:59:57
--@callback: 触发的事件
function Affair:processEvent(callback)
    HttpManagerEx:processRoomAffair(
        self.id,
        self.deal_type,
        self.process_type,
        function(status, errcode, errmsg, data)
            if status == 200 then
                if errcode == 0 then
                    if callback then
                        callback(data)
                    end

                    if self:getDealType() == "process" then
                        self.is_handle = 1
                    end
                else
                    print("errmsg", errmsg, "errcode", errcode)
                    PopText(errmsg)
                end
            else
                print("errmsg", errmsg, "errcode", errcode)
            end
        end,
        IS_SHOW_WAITING
    )
end

--@desc UI界面Button_3 的处理方法
function Affair:handleEvent()
    if self.event.handleEventConditon and not self.event.handleEventConditon() then
        return
    end

    if self.event.handleEvent then
        self:setDealType("process")
        self.event.handleEvent()
    end
end

--@desc UI界面Button_4 的处理方法
function Affair:handleEvent1()
    if self.event.handleEventConditon1 and not self.event.handleEventConditon1() then
        return
    end
    if self.event.handleEvent1 then
        self:setDealType("process")
        self.event.handleEvent1()
    end
end

--@desc: 数据绑定
--@author:Liang SongQiang
--@time:2018-08-09 14:48:17
--@attrName:属性名
--@func: 绑定的方法
function Affair:bindAttrUiWithFunc(attrName, func)
    return binding.watch(
        self,
        attrName,
        function(newValue, oldValue)
            return func(newValue, oldValue)
        end
    )
end

--@desc: 解除属性绑定
--@author:Liang SongQiang
--@time:2018-08-09 14:53:57
--@attrName: 属性名
function Affair:unBindAttr(attrName, tag)
    binding.unwatch(self, attrName, tostring(tag))
end

--@desc: 设置事务的处理执行条件
--@author:Liang SongQiang
--@time:2018-08-10 15:56:05
--@func: 执行条件函数
function Affair:setHandleCondition(func)
    if type(func) ~= "function" then
        assert(false, "Affair:setHandleCondition ，arg's type error,arg must function")
    end

    self.handleConditon = function(self)
        return func()
    end
end

function Affair:upgradeHouse()
    --[[
        'userid' => '1006',
        'affair_id' => 1,
        'affair_val' => ['content'=>'您的房屋可以改造了'],
        'biz_type' => 1,
        'from_id' => '',
        'expired_time' => date('2018-06-19 23:59:59'),
        'count' => '',
        'objId' => '房契id'
    ]]
    self.btnName = "扩建"
    self.titleName = "房屋扩建"
    self.type = AffairType.operation
    
    local text = "管家：#ch#，我们的房屋已经可以进行扩建了，不知您意下如何？"
    text = HomelandDesc:subChengHuText(text)
    
    self.text = text

    self.event = AffairEvent:UpgradeHouse(self)
end

--@desc: 缴纳地税
--@author:Liang SongQiang
--@time:2018-08-09 18:28:59
function Affair:payLandTax()
    self.btnName = "缴纳"
    self.titleName = "缴纳地税"
    self.type = AffairType.operation

    local transTime = tonumber(Helper:getDaysBetweenTwoDate2(Helper:date("%Y%m%d",self.affair_val.pay_time),Helper:date("%Y%m%d",GetTime())))

    local unit = Helper:getDef(payMethod[self.affair_val.pay_unit],"银票")
    local text =
        "管家：#ch#，咱这已是" ..
        transTime .. "天未缴地税了，如今已是欠下了" .. Helper:getDef(self.affair_val.pay_base,0) * transTime .. unit .."，若是连续15日未缴地税，这土地只怕要被收回了。"

    text = HomelandDesc:subChengHuText(text)

    self.text = text

    self.event = AffairEvent:payLandTax(self)
end

--@desc: 仆人发薪
--@author:Liang SongQiang
--@time:2018-08-09 18:25:20
function Affair:paySalaryForPuRen()
    local transTime = tonumber(Helper:getDaysBetweenTwoDate2(Helper:date("%Y%m%d",self.affair_val.pay_time),Helper:date("%Y%m%d",GetTime())))
    local cost = self.affair_val.pay_base
    local unit = self.affair_val.pay_unit
    local npcId = self.affair_val.rwId
    local maxPayTime = math.min(transTime,30)

    self.btnName = self.affair_val.name.."，欠薪"..cost * maxPayTime..payMethod[unit]

    self.titleName = "仆人薪资"
    self.type = AffairType.register
    self.select = true
    self.cost = cost * maxPayTime

    local text =
        "管家：#ch#，" ..
        self.affair_val.name ..
            "入住我们家已有" ..
                transTime .. "日了，薪资尚未发放，是否现在就发薪？现在发的话，需要发薪" .. cost * maxPayTime .. payMethod[unit] .. "（欠薪太多，会导致仆人闹事甚至离开）"
    text = HomelandDesc:subChengHuText(text)
    self.text = text
    self.event = AffairEvent:paySalaryForPuRen(self, maxPayTime)
end

--@desc: 门客发薪
--@author:Liang SongQiang
--@time:2018-08-09 18:31:09
function Affair:paySalaryForMenKe()
    local transTime = tonumber(Helper:getDaysBetweenTwoDate2(Helper:date("%Y%m%d",self.affair_val.pay_time),Helper:date("%Y%m%d",GetTime())))
    local cost = self.affair_val.pay_base
    local unit = self.affair_val.pay_unit
    local npcId = self.affair_val.rwId
    local maxPayTime = math.min(transTime,30)

    self.btnName = self.affair_val.name.."，欠薪"..cost * maxPayTime..payMethod[unit]
    self.titleName = "门客薪资"
    self.type = AffairType.register
    self.select = true
    self.cost = cost * maxPayTime

    local text =
        "管家：#ch#，" ..
        self.affair_val.name ..
            "入住我们家已有" ..
                transTime .. "日了，薪资尚未发放，是否现在就发薪？现在发的话，需要发薪" .. cost * maxPayTime .. payMethod[unit] .. "（欠薪太多，会导致仆人闹事甚至离开）"
    text = HomelandDesc:subChengHuText(text)
    self.text = text
    self.event = AffairEvent:paySalaryForPuRen(self, maxPayTime)
end

--@desc:求购
--@author:Liang SongQiang
--@time:2018-08-09 18:31:26
function Affair:askToBuy()
    --[[
        'userid' => '1006',  //被求购的名字
        'affair_id' => '5',
        'affair_val' => [
            'name'=>'被求购者的名字',
            'from_name' => '求购者的名字',
            'currency'=>'yinpiao',
            'number' => 10000,
            'dpId' => '',  //地皮id
            'location' => '',  //地皮位置
            'biz_type' => 1,
            'from_id' => '1008', //当前发起者的id
            'count' => '',
            'objId' => '地皮id'
    ]]
    if self.from_id == tostring(User:getUserId()) then
        local dp = DiQiModel:getDpInfoById(self.affair_val.dpId)
        switch(
            self.state,
            {
                [0] = function()
                    self.text = "管家：#ch#，您求购的" .. dp.name .. "，目前还没有回应。"
                    self.btnName = "取消"
                end,
                [1] = function()
                    self.text = "管家：#ch#，您之前求购的土地" .. dp.name .. "，已经求购成功了，这是地契，还请#ch#过目。（注意：求购成功7天后仍未领取的地契会被回收！）"
                    self.btnName = "领取地契"
                end,
                [2] = function()
                    self.text = "管家：#ch#，您之前求购的土地" .. dp.name .. "，对方似乎不想卖给您，钱已经退了回来。"
                    self.btnName = "领取银票"
                end
            }
        )
    else
        self.text = "管家：#ch#，" .. self.affair_val.from_name .. "出" .. self.affair_val.number .. "银票想要购买咱这块土地，您看，要不要答应？"
        self.btnName = "接受"
        self.btnName1 = "拒绝"
    end

    self.titleName = "求购信息"

    self.text = HomelandDesc:subChengHuText(self.text)

    self.type = AffairType.operation

    self.event = AffairEvent:askToBuy(self)
end

--@desc: 拜访
--@author:Liang SongQiang
--@time:2018-08-09 18:35:49
function Affair:visited()
    --[[
        'userid' => '1006',
        'affair_id' => '6',
        'affair_val' => [
            'from_name' => '过来拜访我的人的名字',
            ],
            'biz_type' => 2,
            'from_id' => '1008',
            'expired_time' => '2018-07-01 23:59:59',
            'count' => '',
            'objId' => '地皮id'
            
            ]]
    self.btnName = "删除"
    self.titleName = "拜 访"
    self.type = AffairType.message
    local text = "管家：#ch#，今日" .. self.affair_val.from_name .. "携邀请函来拜访了您。"
    self.text = HomelandDesc:subChengHuText(text)
    self.event = AffairEvent:showTypeEvent(self)
end

--@desc: 闯门
--@author:Liang SongQiang
--@time:2018-08-09 18:37:22
function Affair:intruded()
    -- pushData = {
    --     affair_id = 7,
    --     uid = map.uid,
    --     affair_val = {
    --         from_name = player:getAttr("name")
    --     },
    --     biz_type = AFFAIR_TYPE_SHOW,
    --     from_id = User:getUserId()
    --     -- expired_time = GetTime() + 3600 * 48,
    -- }

    self.btnName = "删除"
    self.titleName = "闯 门"
    self.type = AffairType.message

    local jobTypeName = HomelandRoleUtil:getCHAJobTypeName(self.affair_val.jobType)
    local text = "管家：#ch#，您不在家的时候，" .. self.affair_val.from_name .. "来闯门了。"
    self.text = HomelandDesc:subChengHuText(text)
    self.event = AffairEvent:showTypeEvent(self)
end

--@desc: 邀请函
--@author:Liang SongQiang
--@time:2018-08-09 18:41:54
function Affair:invitation()
    self.btnName = "拒绝"
    self.btnName1 = "接受"
    self.titleName = "邀请函"
    self.type = AffairType.operation
    self.text = "这是" .. self.affair_val.from_name .. "给你发的一份邀请函。"

    self.event = AffairEvent:invitation(self)
end

--@desc: 仆人离开
--@author:Liang SongQiang
--@time:2018-08-09 18:46:40
function Affair:puRenLeave()
    self.btnName = "删除"
    self.titleName = "仆人离开"
    self.type = AffairType.message
    local jobTypeName = HomelandRoleUtil:getCHAJobTypeName(self.affair_val.jobType)
    local text = "管家：#ch#，您的" .. jobTypeName .. self.affair_val.name .. "，因为您未及时发放薪水，已经离开了。"
    self.text = HomelandDesc:subChengHuText(text)
    self.event = AffairEvent:puRenLeave(self)
end

--@desc: 地皮回收
--@author:Liang SongQiang
--@time:2018-08-09 18:47:58
function Affair:landRecycle()
    self.btnName = "删除"
    self.titleName = "土地回收"
    self.type = AffairType.message
    local dp = DiQiModel:getDpInfoById(self.affair_val.dpId)
    local text = "管家：#ch#，由于您已15天未缴纳地税，您的土地" .. dp.name .. "已被官府收回了，我们搬至了" .. self.affair_val.location .."。"
    local locationStr=self.affair_val.location
    local refreshData={dpId="nil",location=locationStr}
    local FangQiModel = require("app.models.HomelandModel.FangQiModel")
    FangQiModel:updateInfo(refreshData)
    self.text = HomelandDesc:subChengHuText(text)

    self.event = AffairEvent:showTypeEvent(self)
end

--@desc: 土地转让成功
--@author:Liang SongQiang
--@time:2018-08-09 18:49:36
function Affair:transferLand()
    self.btnName = "删除"
    self.titleName = "转让成功"
    self.type = AffairType.message

    local dp = DiQiModel:getDpInfoById(self.affair_val.dpId)
    local text =
        "管家：#ch#，您已经答应了" ..
        self.affair_val.from_name ..
            "的" .. self.affair_val.number .. "银票出价请求，如今" .. dp.name .. "已经转让给" .. self.affair_val.from_name .. "了。"
    self.text = HomelandDesc:subChengHuText(text)
    self.event = AffairEvent:showTypeEvent(self)
end

--@desc: 仆人的异常离开
--@author:Liang SongQiang
--@time:2018-08-09 18:52:20
function Affair:abnormalLeave()
    if self.affair_val.number == 0 then
        self.btnName = "删除"
        self.text = "管家：您的门客" .. self.affair_val.name .. "因不耐寂寞，已是独自一人云游四方去了。"
    elseif self.affair_val.number > 0 then
        self.btnName = "领取"
        self.text =
            "管家：您的门客" ..
            self.affair_val.name ..
                "因不耐寂寞，已是独自一人云游四方去了，临走之际将" ..
                    self.affair_val.number .. "/" .. payMethod[self.affair_val.unit] .. "的薪资退还给了您。"
    else
        print("检查为什么返回的薪水为负数")
    end
    self.titleName = "仆人离开"
    self.type = AffairType.message
    self.event = AffairEvent:abnormalLeave(self)
end

--新春串门
--  --  {
    --     affair_id = 13,
    --     uid = map.uid,
    --     affair_val = {
    --         from_name = player:getAttr("name")
    --         gift_type = 1 or 2 or 3 or 5 ( 1 碎银红包 2 新春福袋 3普通奖励奖励 5奖励次数已满 无奖励)
    --         visit_time= 155555555
    --     },
    --     biz_type = AFFAIR_TYPE_SHOW,
    --     from_id = User:getUserId()
    --     -- expired_time = GetTime() + 3600 * 24,
    -- }
function Affair:newYearVisited()
    self.btnName = "领取礼品"
    self.titleName = "登门拜年"
    self.type = AffairType.message
    local levelWords={
        [0]="特意前来登门拜年，并在府中寒暄了片刻，甚是客气，老爷如若有意可前往拜年。",
        [1]="特意前来登门拜年，并留下一份厚礼。",
    }
    local visitTimeStr=""
    if Helper:diffWithDate(GetTime(), self.affair_val.visit_time) >= 1 then
        visitTimeStr=visitTimeStr.."昨天"
    else
        visitTimeStr=visitTimeStr.."今天"
    end
    local leaveStr=""
    if self.affair_val.gift_type then 
        if tonumber(self.affair_val.gift_type)~=1 and tonumber(self.affair_val.gift_type)~=2 then 
            leaveStr=leaveStr..levelWords[0]
            self.btnName ="删除"
        else
            leaveStr=leaveStr..levelWords[1]
        end
    end
    local text =
        "管家：#ch#，" ..
        self.affair_val.from_name ..visitTimeStr..leaveStr
    self.text = HomelandDesc:subChengHuText(text)
    self.event = AffairEvent:newYearVisited(self)
end

--@desc: 安闲而游
--  --  {
    --     affair_id = 14,
    --     uid = map.uid,
    --     affair_val = {
    --         rwId = "门客id"  --门客id
    --         name ="门客名字"
    --         rest_time = 10 --门客休息时间
    --     },
    -- }
function Affair:menkeWarning()
    self.btnName = "派遣"
    self.titleName = "安闲而游"
    self.type = AffairType.operation
    local menkeName =  self.affair_val.name
    local menkeRestTime = tonumber(Helper:getDaysBetweenTwoDate2(Helper:date("%Y%m%d",self.affair_val.rest_time),Helper:date("%Y%m%d",GetTime())))
    local text = "管家：#ch#，"..menkeName.."入住宅府已有"..menkeRestTime.."日，但近些时日"..menkeName.."似乎无事可做，此刻是否派遣"..menkeName.."去做一些事情？若是这般悠闲下去，"..menkeName.."恐怕会耐不住闲散，云游而去。"
    self.text = HomelandDesc:subChengHuText(text)
    self.event = AffairEvent:menkeWarning(self)
end

return Affair
0000000