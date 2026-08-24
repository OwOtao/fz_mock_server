local VisitTaskLayer = class("VisitTaskLayer", cc.Layer)
local visitTaskInfo=require("app.models.task.visitTask.VisitTask")
local Item = require("app.models.item.Item")
local taskRewardType={
    ["pot"]="潜能",
    ["money"]="碎银",
    ["exp"]="经验",
}

function VisitTaskLayer:create()
    local p = VisitTaskLayer:new()
    p:init()
    return p
end

function VisitTaskLayer:init()
    self._UI = require("Layer/VisitTaskUI/VisitTaskUI.lua").create()['root']
    self._UI:addTo(self)

    Helper:convertUI(self) -- 获得所有子节点
    self:setVisible(true)


    self.Panel_back:releaseFunc(function()
        --self:hide()
    end)

    self.Image_back:releaseFunc(function()
    	--self:hide()
    end)

    self.Button_1:releaseFunc(function()
        local visitTask = self.task

        local role = User:getRole()

        if role:getTimeLimitFlag(visitTask.flag) == 0 then
            RichPrint("main",self.npc.name .. "：如若少侠有要事在身，在下先行告退，他日再登门拜访。")
            visitTaskInfo:removeVisitNPC()
            self:hideLayer()
            return
        end

        if visitTask.type == "任务型" then
            visitTaskInfo:ok("任务",visitTask,self.npc.name)
            self:hideLayer()
        elseif visitTask.type == "免费型" then
            visitTaskInfo:ok("免费",visitTask,self.npc.name)
            self:hideLayer()
        elseif visitTaskInfo:chekcCanBuy("元宝",visitTask) then
            if visitTaskInfo:checkCanGetReward(visitTask) then
                PopYuanBaoBuyItemLayer(visitTask.id, function(eventType)
                    if eventType == "success" then
                        visitTaskInfo:ok("元宝",visitTask,self.npc.name)
                        self:hideLayer()
                    end
                end)
            end
        end
    end)

    self.Button_2:releaseFunc(function()
        local visitTask = self.task

        local role = User:getRole()

        if role:getTimeLimitFlag(visitTask.flag) == 0 then
            RichPrint("main",self.npc.name .. "：如若少侠有要事在身，在下先行告退，他日再登门拜访。")
            visitTaskInfo:removeVisitNPC()
            self:hideLayer()
            return
        end

        if visitTask.type == "免费型" then
            if visitTaskInfo:checkCanGetReward(visitTask) then
                visitTaskInfo:ok("免费",visitTask,self.npc.name)
                self:hideLayer()
            end
        elseif visitTask.type == "任务型" then
        	visitTaskInfo:ok("任务",visitTask,self.npc.name)
            self:hideLayer()
        elseif visitTaskInfo:chekcCanBuy("碎银",visitTask) then
            if visitTaskInfo:checkCanGetReward(visitTask) then
                visitTaskInfo:ok("碎银",visitTask,self.npc.name)
                self:hideLayer()
            end
        end
    end)

    self.Button_3:releaseFunc(function()
        local role = User:getRole()
        if role:getTimeLimitFlag(self.task.flag) == 0 then
            RichPrint("main",self.npc.name .. "：如若少侠有要事在身，在下先行告退，他日再登门拜访。")
            visitTaskInfo:removeVisitNPC()
            self:hideLayer()
            return
        end

        visitTaskInfo:cancel(self.task,self.npc.name)
        self:hideLayer()
    end)
end


function VisitTaskLayer:initRichText()
    if self.RichText then
        self.RichText:removeFromParent()
    end

    if self.SpendRichText then
        self.SpendRichText:removeFromParent()
    end

    local x, y = self.ListView_listArea:getPosition()
    local size = self.ListView_listArea:getContentSize()

    self.RichText = ExtRichTextScroll:create()

    self.ListView_listArea:getParent():addChild(self.RichText)
    self.RichText:move(cc.p(x, y))
    self.RichText:setSize(size)
    self.RichText:setAnchorPoint(cc.p(0.5, 0.5))
    self.RichText:setDirection(kCCScrollViewDirectionVertical)
    self.RichText:getRichText():setVerticalSpace(20)

    x, y = self.Text_spend:getPosition()
    size = self.Text_spend:getContentSize()

    self.SpendRichText = ExtRichTextScroll:create()

    self.Text_spend:getParent():addChild(self.SpendRichText)
    self.SpendRichText:move(cc.p(x, y))
    self.SpendRichText:setSize(size)
    self.SpendRichText:setAnchorPoint(cc.p(0.5, 0.5))
    self.SpendRichText:setDirection(kCCScrollViewDirectionVertical)
    self.SpendRichText:getRichText():setVerticalSpace(20)
end

function VisitTaskLayer:hideLayer()
    PopupLayerController:hideLayer("VisitTaskLayer",function (layer)
        layer:hide()
    end)
end

function VisitTaskLayer:showLayer(visitTask,npc)
    if MapIsEmpty(visitTask) or MapIsEmpty(npc) then
        self:hideLayer()
        return 
    end
    self.task = visitTask

    self.npc = npc

    self:resetContent()
    
    self:setTask(visitTask)
    self:show()
end

-- 设置拜访任务界面
function VisitTaskLayer:setTask(visitTask)
    local npc = self.npc

    self:setTitleText(npc.name.."来拜访你")
    self:setNpcText(npc.name)  
    self:setRichText(visitTask.mainText)

    self:setRewardText(visitTask)
    self:setSpendText(visitTask)
end

--设置标题文本
function VisitTaskLayer:setTitleText(text)
    if not text then 
        self.Text_title:setVisible(false)
    else
	   self.Text_title:setString(text)
    end
end

--设置NPC名字
function VisitTaskLayer:setNpcText(text)
    if not text then 
        self.Text_npc_name:setVisible(false)
    else
        self.Text_npc_name:setString(text)
    end
end

--设置RichText文本
function VisitTaskLayer:setRichText(text)
    self:initRichText()
    local textColor = cc.c3b(208, 208, 208)
    if not text or text=="" then 
        self.RichText:pushBackText("我看你筋骨惊奇，这儿有一本放置江湖武功秘籍，我十块钱卖与你，以后拯救江湖的任务就交给你了。", textColor, 255, Resource:getFontPath("default"), 48)
    else
        self.RichText:pushBackText(text, textColor, 255, Resource:getFontPath("default"), 48)
    end
end


--设置消耗显示文本
function VisitTaskLayer:setSpendText(visitTask)
    --type 1--消费型  2--任务型 3--免费型
    local type_yuanbao,type_suiyin,num_yuanbao,num_suiyin
    local spendMoneys=string.split(visitTask.spendType,";")
    for i,v in pairs(spendMoneys) do  
        local type_money=string.split(spendMoneys[i],",")
        if type_money[1]=="money" then 
            type_suiyin=true
            num_suiyin=type_money[2]
            self.taskMoney=num_suiyin
        elseif type_money[1]=="yuanbao" then 
            type_yuanbao=true
            num_yuanbao=type_money[2]
        end
    end
    if visitTask.type == "免费型" then
        self.Text_spend:setString("")
        self.Text_spend_1:setString("")
        self.Text_discount:setVisible(false)

        self.Text_button_1_Name:setString("欣然接受")
        self.Button_1:setVisible(true)
        self.Button_2:setVisible(false)

        self.Button_3:setPosition(540, 750)
    elseif visitTask.type == "任务型" then
        self.Text_spend:setString("")
        self.Text_spend_1:setString("")
        self.Text_discount:setVisible(false)

        self.Text_button_1_Name:setString("接受")
        self.Button_1:setVisible(true)
        self.Button_2:setVisible(false)

        self.Button_3:setPosition(540, 750)
    else
        if type_yuanbao then 
            self.Text_spend:setVisible(true)
            self.Text_spend:setString("折后消耗" .. num_yuanbao .. "元宝")            
        end

        if visitTask.discount ~= nil and visitTask.discount ~= 10  then
            self.Text_discount:setVisible(true)
            self.Text_discount:setString("(" .. visitTask.discount .. "折)")
        else
            self.Text_discount:setVisible(false)
        end

        -- 是否可以消耗碎银获得奖励
        if type_suiyin then
            self.Text_spend_1:setPosition(540, 650)
            self.Text_spend_1:setVisible(true)
            self.Text_spend_1:setString("消耗" .. num_suiyin .. "碎银")
            if type_yuanbao~=true then 
                self.Text_spend_1:setPosition(540, 900)
                self.Button_1:setVisible(false)
                self.Button_2:setPosition(540, 1000)
                self.Text_spend:setVisible(false)
                self.Button_3:setPosition(540, 750)
                self.Text_discount:setVisible(false)
            end
        else
            self.Button_3:setPosition(540, 750)
            self.Button_2:setVisible(false)
            self.Text_spend_1:setVisible(false)
        end
    end


end

-- 设置可获得奖励文本
function VisitTaskLayer:setRewardText(visitTask)
    if visitTask.type=="任务型" then 
        self.Text_reward:setVisible(false)
        return 
    end
    local taskReward
    if visitTask.reward then 
        taskReward=string.split(visitTask.reward, ",")
    end
    local rewardName=""
    if taskReward[1] and taskReward[1] ~="" then    
        if taskReward[1] == "pot" or taskReward[1] == "money" or taskReward[1] == "exp" then
            rewardName=taskRewardType[taskReward[1]]
        else
            local item = Item:getOneItemByKey(taskReward[1]) 
            rewardName = item.name .. " X"
        end
        self.Text_reward:setVisible(true)
        self.Text_reward:setString("可获得" .. rewardName .. " " .. tostring(taskReward[2]))
    end
    
end

--重置界面内容
function VisitTaskLayer:resetContent()
    self.Button_2:setVisible(true)
    self.Text_spend_1:setVisible(true)
    self.Text_discount:setVisible(true)

    self.Text_button_1_Name:setString("给予元宝")
    self.Text_button_2_Name:setString("给予碎银")

    self.Button_1:setVisible(true)
    self.Button_2:setVisible(true)

    self.Button_1:setPosition(540, 1000)
    self.Button_2:setPosition(540, 750)
    self.Button_3:setPosition(540, 500)
end

Helper:classDefNodeGetInstance(VisitTaskLayer)

return VisitTaskLayer0000000000