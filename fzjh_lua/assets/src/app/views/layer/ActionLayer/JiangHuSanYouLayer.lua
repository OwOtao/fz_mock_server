local JiangHuSanYouLayer = class("JiangHuSanYouLayer", LayerEx)
local RoleInfoLayer = require("app.views.layer.RoleLayer.RoleInfoLayer")
function JiangHuSanYouLayer:create()
	local p = JiangHuSanYouLayer:new()
	p:init()
	return p
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/01/09 16:03:50
-- @desc 首充页面测试方法
function JiangHuSanYouLayer:showLayer(data,canVote)
	-- local layer = self:getInstance()
	-- layer:initUI(data)
	self:initUI(data)
	self.canVote = canVote
end

function JiangHuSanYouLayer:init()
	local UI = require("Layer/ActionUI/JiangHuSanYouUI.lua").create()['root']
	UI:addTo(self)
	
	-- self:setVisible(false)
	Helper:convertUIByParent(self)
	self:__setRuleFunc()

end

function JiangHuSanYouLayer:initUI(data)
	self:show()

	self:createListViews(data)
	self:setBack()
end

function JiangHuSanYouLayer:setDesc(desc)
	self.Text_1:setString(desc)
end

function JiangHuSanYouLayer:hideLayer()
	PopupLayerController:hideLayer("JiangHuSanYouLayer",function ( layer )
		layer:hide()
	end)
end

function JiangHuSanYouLayer:setBack()
	self.Button_back:releaseFunc(function()
		self:hideLayer()
	end)
end

function JiangHuSanYouLayer:createListView(data)

	-- Helper:print_lua_table(data)
	if MapIsEmpty(data) then
		if PRINT_MODE ==1 then
			print("---------function RankingUI:createListView(data)-------空的")
		end
		return
	end

	local row = self:createPanel(data)
	if row ~= nil then
		self.ListView_ranking:pushBackCustomItem(row)
	end

end
----------创建list显示的一行数据
-- 创建一行记录信息
function JiangHuSanYouLayer:createPanel(userData)
	if MapIsEmpty(userData) then
		return nil
	end
	self.Panel_item:setTouchEnabled(true)
	local panel = self.Panel_item:clone()
	Helper:convertUI(panel)

	-- panel.Text_name:enableOutline(cc.c4b(0, 0, 0, 255), 5)
	-- panel.Text_renqizhi:enableOutline(cc.c4b(221, 215, 151, 255), 5)
	-- panel.Text_piaoshu:enableOutline(cc.c4b(0, 0, 0, 255), 5)

	local npcDatas = require("script.others.threefriends") ["Sheet1"]
    local npcData = npcDatas[userData.id]

	panel.Text_name:setString(npcData.name)
	panel.Text_renqizhi:setString(userData.rq)
	panel.Text_piaoshu:setString(userData.tp)

	local afterVoteCallback = function()
	    HttpManagerEx:getJhSanYouList(function(status, errcode, errmsg, data)
	    	if status == 200 and errcode == 0 then
		        self:createListViews(data.list)
		        self.canVote = data.canVote
			else
                PopText(errmsg)
            end
		 end,IS_SHOW_WAITING)
	end
	panel.Button_toupiao:releaseFunc(function()
		--假如江湖令大于0
		local role = User:getRole()
		local count1 = role:getItemCount("voteitem1")--物品的数量
		local count2 = role:getItemCount("voteitem2")
		local rwdTab = {["voteaward1"] = 1}--背包的内存
		if self.canVote == 1 then--今天投票没有超过20次 1可以投票 0不可以
            if count1 > 0 or count2 > 0 then 
            	if role:checkCanBuyTwoOrMoreThings(rwdTab) == true then
            		PopupLayerController:showLayer("JiangHuSanYouVoteLayer",function(layer)
			     		layer:test(userData,npcData.name,count1,count2,afterVoteCallback)--江湖令数量
			    	end)
            	else
            		-- PopText("背包已满,请空出一个背包格子")
            	end
            else
            	 PopText("你背包里没有江湖风云令或江湖扬名令,无法投票！")
            end
        else
        	PopText("你今天已经投了20票,请明天再来！")
        end 
	end)

    -------空的名字查看玩家资料
	panel.Text_name:setTouchEnabled(true)
	panel.Text_name:releaseFunc(function()
		PopupLayerController:showLayer("JiangHuSanYouRoleInfoLayer",function(layer)
     		layer:showLayer(npcData)
    	end)
	end)

	return panel
end

function JiangHuSanYouLayer:createListViews(list)
	if PRINT_MODE ==1 then
		-- print("---------function RankingUI:createListViews(data)-------")
		Helper:print_lua_table(list)
	end
	self.ListView_ranking:removeAllItems()
	for i,v in ipairs(list) do
		self:createListView(list[i])
	end
end

function JiangHuSanYouLayer:initRule(ruleInfo)
	self.__ruleInfo = ruleInfo
end

function JiangHuSanYouLayer:__setRuleFunc()
	self.Image_rule:releaseFunc(function()
        self:__showRule()
    end)
end

function JiangHuSanYouLayer:__showRule()
	PopupLayerController:showLayer("ActionRuleUI",function(layer)
        layer:showUI()
        layer:setTextTitle("活动规则")
        layer:showPanel_1(self.__ruleInfo)
        layer:setButtonBack(function()
            PopupLayerController:hideLayer("ActionRuleUI",function(layer)
                layer:hideUI()
            end)
        end)
    end)
end

Helper:classDefNodeGetInstance(JiangHuSanYouLayer)
return JiangHuSanYouLayer
000000000000