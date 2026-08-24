local GuoQingKuangHuanLayer = class("GuoQingKuangHuanLayer", LayerEx)

function GuoQingKuangHuanLayer:create()
	local p = GuoQingKuangHuanLayer:new()
	p:init()
	return p
end

function GuoQingKuangHuanLayer:init()
	local UI = require("Layer/ActionUI/GuoQingKuangHuanUI.lua").create()['root']
	UI:addTo(self)
	Helper:convertUIByParent(self)
    
    self.currType = nil --当前档位 1是一档，2是二挡

	self:setButtonCloseAndGoToPay()
    self:setChangeCurrTypeButton()
    self:setVisible(false)
end

--测试数据
local testList = {
    spend_yuanbao = 400,
    first_yuanbao = 100,
    second_yuanbao = 300,
    status = {
        ["1"] = 2,
        ["2"] = 1,
        ["3"] = 1,
        ["4"] = 2,
        ["5"] = 1,
        ["6"] = 1,
        ["7"] = 1,
        ["8"] = 0,
        ["9"] = 0,
        ["10"] = 0,
    },
    yuanbaoplan_reward = {
        first = {
            {
                itemId = "xinzhaoshimiji,2;dundifu,2;fenshenfu,2",
                name = "一重欢乐礼盒",
                timeText = "10月1号可领取",
                idNum = 1,
                image = "Image/UI/SignInUI/baoxiang-2.png",
            },
            {
                itemId = "xinzhaoshimiji,2;dundifu,2;fenshenfu,2",
                name = "一重欢乐礼盒",
                timeText = "10月1号可领取",
                idNum = 2,
                image = "Image/UI/SignInUI/baoxiang-5.png",
            },
            {
                itemId = "xinzhaoshimiji,2;dundifu,2;fenshenfu,2",
                name = "一重欢乐礼盒",
                timeText = "10月1号可领取",
                idNum = 3,
                image = "Image/UI/SignInUI/baoxiang-7.png",
            },
        },
            
        second = {
            {
                itemId = "xinzhaoshimiji,2;dundifu,2;fenshenfu,2",
                name = "一重欢乐礼盒",
                timeText = "10月1号可领取",
                idNum = 4,
                image = "Image/UI/SignInUI/baoxiang-2.png",
            },
            {
                itemId = "xinzhaoshimiji,2;dundifu,2;fenshenfu,2",
                name = "一重欢乐礼盒",
                timeText = "10月1号可领取",
                idNum = 5,
                image = "Image/UI/SignInUI/baoxiang-5.png",
            },
            {
                itemId = "xinzhaoshimiji,2;dundifu,2;fenshenfu,2",
                name = "一重欢乐礼盒",
                timeText = "10月1号可领取",
                idNum = 6,
                image = "Image/UI/SignInUI/baoxiang-7.png",
            },
            {
                itemId = "xinzhaoshimiji,2;dundifu,2;fenshenfu,2",
                name = "一重欢乐礼盒",
                timeText = "10月1号可领取",
                idNum = 7,
                image = "Image/UI/SignInUI/baoxiang-8.png",
            },
            {
                itemId = "xinzhaoshimiji,2;dundifu,2;fenshenfu,2",
                name = "一重欢乐礼盒",
                timeText = "10月1号可领取",
                idNum = 8,
                image = "Image/UI/SignInUI/baoxiang-9.png",
            },
            {
                itemId = "xinzhaoshimiji,2;dundifu,2;fenshenfu,2",
                name = "一重欢乐礼盒",
                timeText = "10月1号可领取",
                idNum = 9,
                image = "Image/UI/SignInUI/baoxiang-10.png",
            },
            {
                itemId = "xinzhaoshimiji,2;dundifu,2;fenshenfu,2",
                name = "一重欢乐礼盒",
                timeText = "10月1号可领取",
                idNum = 10,
                image = "Image/UI/SignInUI/baoxiang-11.png",
            },
        },
    }
}

function GuoQingKuangHuanLayer:showLayer(action)
    self.currType = 1
	self.actionId = action.activity_id

	local timeStartStr =Helper:getTimeStrCNFormat(action["start"])
    local timeEndStr = Helper:getTimeStrCNFormat(action["end"])

    local detail_desc_list = action.detail_desc

    local str = ""

    for i,desc in ipairs(detail_desc_list) do
        desc = string.gsub(desc,"#start#",timeStartStr)
        desc = string.gsub(desc,"#end#",timeEndStr)
        str = str .. desc .. "\n"
    end

	self:setDesc(str)
	self.Text_Name:setString(action.name)

	self:getNultiFestivalGiftList(true)
end

function GuoQingKuangHuanLayer:hideLayer()
    PopupLayerController:hideLayer("GuoQingKuangHuanLayer",function(layer)
            layer:hide()
        end
    )
end

function GuoQingKuangHuanLayer:setDesc(desc)
    local richText = self:getChildByTag(10001)
	if richText == nil then
		local x, y = self.Text_5:getPosition()
		local size = self.Text_5:getContentSize()
        richText = ExtRichTextScroll:create()
		richText:setSize(size)
		richText:setAnchorPoint(0.5,0.5)
        richText:move(cc.p(x, y))
        richText:setTag(10001)
        self:addChild(richText)
        richText:setDirection(kCCScrollViewDirectionVertical)
    else
        richText:getRichText():removeAllElement()
    end
    richText:pushBackText(desc, cc.c3b(208, 208, 208), 255, Resource:getFontPath("default"), 42)
end

-- @desc 设置关闭按钮和去充值
function GuoQingKuangHuanLayer:setButtonCloseAndGoToPay()
	self.Button_back:releaseFunc(function()
		self:hideLayer()
	end)
	self.Button_toPay:releaseFunc(function()
		MainControllLayer:pushLayer("StoreLayer")
		local StoreLayer=MainControllLayer:getLayer("StoreLayer")
		StoreLayer:showWithAction(function()
			self:getNultiFestivalGiftList()
			self:show()
            -- self.currType = 1
		end)
		self:hideLayer()
	end)
end

-- @desc 初始化界面
function GuoQingKuangHuanLayer:getNultiFestivalGiftList(isShow)--初始化界面
    print("self.actionId = ",self.actionId)
	HttpManagerEx:getSpendPlanGiftList(self.actionId,function (status, errcode, errmsg, data, isEncrypted)
        if status == 200 and errcode == 0 then
            local list = Helper:getDef(data,{})

            if DEBUG_MODE == 1 then
                Helper:print_lua_table(list)
            end

            self:setLoadingBar(list)
            self:showPanelList(list)
            self:setButtonName(list)

            if isShow == true then
                self:show()
            end
        else
            PopText(errmsg)
        end
    end,IS_SHOW_WAITING)
end

function GuoQingKuangHuanLayer:showPanelList(list)
    local role = User:getRole()
    if MapIsEmpty(list) then
        return
    end
    local list_data = {}

    if self.currType == 1 then
        list_data = list.yuanbaoplan_reward.first
    else
        list_data = list.yuanbaoplan_reward.second
    end
    if MapIsEmpty(list_data) then
        return
    end
    self.ListView_Items:removeAllItems()
    for index, item_data in ipairs(list_data) do
        local panel = self:createPanelItem()
       
        self.ListView_Items:pushBackCustomItem(panel)

        panel.Image_2:loadTexture(item_data.image,0)
        panel.Text_Title:setString(item_data.name)
        panel.Text_time:setString(item_data.timeText)

        local itemStr = item_data.itemId
        local itemList = string.split(itemStr,";")
        local checkData = {}
        for i,v in ipairs(itemList) do
            if v then
                local tem = string.split(v,",")
                local itemId = tem[1]
                local itemCount = tem[2]
                checkData[itemId] = tonumber(itemCount)
            end
        end

        local ShowDetailFunc = function()
            local showTextList = self:createShowTextList(checkData)

            PopupLayerController:showLayer("ShowDetailListLayer",function (layer )
                layer:showLayer("打开【"..item_data.name.."】可获得以下道具：",showTextList)
            end)
        end
        panel.Text_Title:releaseFunc(function ()
            ShowDetailFunc()
        end)
        panel.Image_2:releaseFunc(function ()
            ShowDetailFunc()
        end)

        local buttonName = ""
        
        if list.status[tostring(item_data.idNum)] == 0 then
            panel.Button_lingqu:setEnabled(false)
            panel.Button_lingqu.Text_buttonName:setString("未解锁")
        elseif list.status[tostring(item_data.idNum)] == 1 then
            panel.Button_lingqu:setEnabled(true)
            panel.Button_lingqu.Text_buttonName:setString("领取")
            panel.Button_lingqu:releaseFunc(function()
                self:receiveReward(checkData,item_data)
            end)
        elseif list.status[tostring(item_data.idNum)] == 2 then
            panel.Button_lingqu:setEnabled(false)
            panel.Button_lingqu.Text_buttonName:setString("已领取")
        else
            print("ChongGuangDuiHuanLayer:showPanelList(list) 未知状态 item_data.status = ",item_data.status)
            return 
        end
    end
end

function GuoQingKuangHuanLayer:createPanelItem()
    local panel = self.Panel_Item:clone()

    Helper:convertUIByParent(panel)

    panel.Button_lingqu.Text_buttonName:enableOutline({r = 0, g = 0, b = 0, a = 255}, 5)
    return panel
end

-- @desc 设置充值进度条
function GuoQingKuangHuanLayer:setLoadingBar(data)
	if MapIsEmpty(data) == true then
		return
	end

	local currNum = data.spend_yuanbao --当前消费金额
    local limitNum = 0 --当前档位所需金额

    if self.currType == 1 then
        limitNum = data.first_yuanbao
    else
        limitNum = data.second_yuanbao
    end

    self.LoadingBar.Text_TotalDayName:setString(currNum.."/"..limitNum)
	self.LoadingBar:setPercent((currNum/limitNum)*100)

    self.Text_name_0:setString("累计充值达到"..limitNum.."元即可获得以上奖励")
end

function GuoQingKuangHuanLayer:receiveReward(checkData,item_data)
    if MapIsEmpty(checkData) then
        return
    end
    local role = User:getRole()

    --@desc 判断背包
    if role:checkCanBuyTwoOrMoreThings(checkData) == false then
        return
    end

    print("self.actionId,item_data.idNum = ",self.actionId,item_data.idNum)
	HttpManagerEx:receiveSpendPlanGiftList(self.actionId,item_data.idNum,function(status, errcode, errmsg, data, isEncrypted)
        if status == 200 and errcode == 0 then
            for itemId,itemCount in pairs(checkData) do
                role:addItemCount(itemId, itemCount)

				local itemAttr = role:getOneItemByKey(itemId)
				if MapIsEmpty(itemAttr) == false then
					PopText(tostring(itemAttr.name).." + "..tostring(itemCount))
				end
            end

            self:getNultiFestivalGiftList()
        else
            print("status = ",status,"errcode =",errcode)
            PopText(errmsg)
        end
    end,IS_SHOW_WAITING)
end

function GuoQingKuangHuanLayer:setButtonName(data)
    if self.currType == 1 then
        if data.spend_yuanbao >= data.second_yuanbao then --充值金额达到需求，不再显示
            self.Image_27:setVisible(false)
            local isShowHD = false
            for i, v in ipairs(data.yuanbaoplan_reward.second) do
                if data.status[tostring(v.idNum)] == 1 then  --有奖励未领取
                    isShowHD = true
                    break
                end
            end
            if isShowHD == true then
                self.Image_hongdian:setVisible(true)
            else
                self.Image_hongdian:setVisible(false)
            end
        else
            self.Image_27:setVisible(true)
        end
        self.Button_close.Text_buttonName:setString("盛兴礼盒")
    else
        self.Image_27:setVisible(false)
        self.Image_hongdian:setVisible(false)
        self.Button_close.Text_buttonName:setString("泰安礼盒")
    end
end

function GuoQingKuangHuanLayer:createShowTextList(checkData)
    local showTextList = {}
    if not MapIsEmpty(checkData) then
        for itemId,itemCount in pairs(checkData) do
            local item = Item:getOneItemByKey(itemId)
            local itemName = item:getNcname(item.name)
            local text = itemName.."X"..tostring(itemCount)

            table.insert( showTextList, text )
        end
    end
    return showTextList
end

--切换档位按钮
function GuoQingKuangHuanLayer:setChangeCurrTypeButton()
    self.Button_close:releaseFunc(function()
        if self.currType == 1 then
            self.currType = 2
            self:getNultiFestivalGiftList()
        else
            self.currType = 1
            self:getNultiFestivalGiftList()
        end
    end)
end

Helper:classDefNodeGetInstance(GuoQingKuangHuanLayer)

return GuoQingKuangHuanLayer000000