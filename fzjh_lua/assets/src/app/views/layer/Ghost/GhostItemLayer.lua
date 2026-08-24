local GhostItemLayer = class("GhostItemLayer", LayerEx)
local ghosts = require("app.models.Activities.ghosts")
function GhostItemLayer:create()
	local p = GhostItemLayer:new()
	p:init()
	return p
end

function GhostItemLayer:init()
	local UI = require("Layer/ghosts/GhostsItemUI.lua").create()['root']
	UI:addTo(self)
	Helper:convertUIByParent(self)
	local ControllLayer = require("app.views.layer.ControllLayer")
	self.controller = ControllLayer:getInstance()
	self:hide()	

end
function GhostItemLayer:setCancelButton()
	self.Button_cancel:releaseFunc(function()
		if self._cancelFunc then
			self._cancelFunc()
		end
		PopupLayerController:hideLayer("GhostItemLayer", function(layer)
			self:hide()	
		end)
	end)
end
function GhostItemLayer:setCancalCallFunc(func)
	if type(func) == "function" then
		self._cancelFunc = func
	end
end
function GhostItemLayer:showLayer(item,func)
	self:setCancelButton()
	local function checkItemIsGhostItem(item)
		local tab = {"zhongyuannuomi1","zhongyuuangouyuan1","zhongyuantaomujian1","zhongyuantaotongqian1"}
		for k,v in pairs(tab) do 
			if item.id == v then
				return true
			end
		end
		return false
	end
	if checkItemIsGhostItem(item) == true then
		self:setTitle(item)
		self:setPanelList(item,func)
	else
		self.Text_title:setString("道具异常")
	end
	self:show()
end
function GhostItemLayer:setTitle(item)
	local str = switch(item.id,{
		["zhongyuannuomi1"] = "你要把"..item.name.."撒向谁？",
		["zhongyuuangouyuan1"] = "你要向谁撒"..item.name.."？",
		["zhongyuantaomujian1"] = "你要用"..item.name.."砍谁？",
		["zhongyuantaotongqian1"] = "你要把"..item.name.."撒向谁？",
	})
	self.Text_title:setString(str)
end
function GhostItemLayer:setPanelList(item,func)
	local mapLayer = self.controller:getLayer("MapLayer")
	local roleList = Helper:getDef(mapLayer._currMap:getRoomRoleList(mapLayer._currRoom.id),{})
	local count = 0
	self.ListView_1:removeAllItems()
	for k,v in ipairs(roleList) do 
		local role = mapLayer._currMap:getRole(v)
		print("*********************************",role.canSee,"***********************************************************************")
		if role.type == "role" and role.isForbidden == false then
			count = count + 1
			self:createRoleButton(role,item,count,func)
		end
	end
end
function GhostItemLayer:createRoleButton(role,item,count,func)
	if not item or not role then
		return
	end
	count = Helper:getDef(count ,1)
	local button = self:createButton(item,role,func)
	local pos = nil
	if count %2 == 1 or self.panel == nil then
		self.panel = self.Panel_role:clone()
		self.ListView_1:pushBackCustomItem(self.panel)
		pos = cc.p(300,59)
	else
		pos = cc.p(700,59)
	end
	button:addTo(self.panel)
	button:setPosition(pos)
end
function GhostItemLayer:createButton(item,role,func)
	local button = self.Button:clone()
	Helper:convertUIByParent(button)
	button.Text:setString(role.name)
	button:releaseFunc(function()
		self:setButtonRleaseFunc(item,role,func)
	end)
	return button 
end
function GhostItemLayer:setButtonRleaseFunc(item,role,func)
	if item.id == "zhongyuannuomi1" then
		self:setHeiNuoMiCallFunc(item,role,func)
	elseif item.id == "zhongyuuangouyuan1" then
		self:setGouXueCallFunc(item,role,func)
	elseif item.id == "zhongyuantaomujian1" then
		self:setMuJianCallFunc(item,role,func)
	elseif item.id == "zhongyuantaotongqian1" then --zhongyuantaotongqian1
		self:setTongQianCallFUnc(item,role,func)
	end
end
--直接消失并调用奖励策略
function GhostItemLayer:removeGhostWithReward(role)
	local mapLayer = self.controller:getLayer("MapLayer")
	role.corpseReward = 1
	mapLayer._currMap:playerKillRole(mapLayer._currRoom.id, role,2)
	mapLayer:setNeedRefreshMap()
	ghosts:updateGhosts(mapLayer._currMap.id,mapLayer._currRoom.id,role)
end
--进入战斗，在func中处理role的状态
function GhostItemLayer:entryFight(text,func,role)
	-- if func then
	-- 	func(role)
	-- end

	text = string.gsub(text,"$N",role.name)
	local mapLayer = self.controller:getLayer("MapLayer")
	self:createFight(role,User:getRole(),function()
		ghosts:updateGhosts(mapLayer._currMap.id,mapLayer._currRoom.id,role)
	end,function()
		print("与恶鬼战斗失败")
	end,text,func)
end
-- function GhostItemLayer:subRoleAttr(role,name,value)
-- 	local player = role
-- 	if not role or type(name) ~= "string" or type(tonumber(value)) ~= "number" then
-- 		return
-- 	end
-- 	local currQi = math.ceil(tonumber(player:getAttr(name))/tonumber(value))
-- 	player:addAttr("name",0 - currQi)
-- end
function GhostItemLayer:subPlayerQiAttr()
	local player = User:getRole()
	local subQi = math.ceil(tonumber(player:getAttr("qiMax"))/10)
	local currQi = player:getAttr("qi")
	User:getRole():addAttr("qi",0 - subQi)
	if currQi - subQi <= 0 then
		local MapRoleLayer = self.controller:getLayer("MapRoleLayer")
		MapRoleLayer:exitMap()
	else
		PopText("气血-"..tostring(subQi))
	end
end
function GhostItemLayer:getItemToPLayerText(role,item)
	local text = {
		["zhongyuannuomi1"] = "CYN你对着$N撒了一把黑糯米，$N摘下了面具，对着你破口大骂，你这才明白$S原来是个正常人。",
		["zhongyuuangouyuan1"] = "CYN你对着$N撒了一盆黑狗血，$N摘下了面具，对着你破口大骂，你这才明白$S原来是个正常人。",
		["zhongyuantaomujian1"] = "CYN你拿着桃木剑对着$N一阵乱砍，$N摘下了面具，对着你破口大骂，你这才明白$S原来是个正常人。",
		["zhongyuantaotongqian1"] = "CYN你对着$N撒了一把古铜钱，$N摘下了面具，对着你破口大骂，你这才明白$S原来是个正常人。",
	}
	local itemText = ""
	if text[item.id] then
		itemText = text[item.id]
	end
	itemText = string.gsub(itemText,"$N",role.name)
	if role.sex == "男" then
		itemText = string.gsub(itemText,"$S","他")
	elseif role.sex == "女" then
		itemText = string.gsub(itemText,"$S","她")
	end
	return itemText
end
function GhostItemLayer:setHeiNuoMiCallFunc(item,role,func)
	local level = ghosts:getDemonlevel(role.baseId)
	local mapLayer = self.controller:getLayer("MapLayer")
	print("………………………………………………………………………………………………",level,"^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^")
	local level_5 = {
		[1] = {
			text = "HIM$N被你的黑糯米撒中，身上冒出丝丝黑烟，竟是消失了。",
			func = function()
				self:removeGhostWithReward(role)
			end
		},
		[2] = {
			-- text = ,
			func = function()
				--血量减少50%进入战斗
				self:entryFight("HIM你冲着$N撒了一把黑糯米，\n$N被黑糯米撒到身上冒出黑烟，\n$N大叫着直接扑了上来！",function(currRole)
					currRole:setAttr("qi",tonumber(currRole:getFinalAttr("qi"))/2)
				end,role)
			end
		},
	}
	local level_1_4 = {
		[1] = {
			-- text = "HIM$N被你的黑糯米撒中，勃然大怒，直接扑向了你。",
			func = function ()
				--进入战斗
				self:entryFight("HIM$N被你的黑糯米撒中，\n勃然大怒，\n直接扑向了你。",function(currRole)
				end,role)
			end
		},
		[2] = {
			text = "HIM你冲着$N撒了一把黑糯米，$N尖叫一声，然后攻击了你，你被其抓伤，血流了一地。",
			func = function ()
				--气血减少最大值的10%
				self:subPlayerQiAttr()
			end
		},
	}
	local other = {
		[1] = {
			text = "YEL$N：有病吧你！乱撒什么玩意！",
			func = function()

			end
		},
		[2] = {
			text = "你对着$N撒了一把黑糯米，什么事情都没发生。",
			func = function()

			end
		},
		[3] = {
			text = "你冲着$N撒了一把黑糯米，$N勃然大怒，无奈之下你花了500两才达成和解。",
			func = function()
				PopText("碎银减少"..tostring(500))
				User:getRole():addAttr("money",-500)
			end
		},
		[4] = {
			text = "你冲着$N撒了一把黑糯米，$N大怒之下，追着你跑了好几里，还好你轻功了得方才逃过一劫。",
			func = function()
				--退出副本
				local MapRoleLayer = self.controller:getLayer("MapRoleLayer")
				MapRoleLayer:exitMap()
			end
		}
	}
	local random = nil
	local text = nil
	local itemFunc = nil 
	if level == 5 then
		random = math.random(1,#level_5)
		if level_5[random].text ~= nil then
			text = string.gsub(level_5[random].text,"$N",role.name)
		end
		if level_5[random].func then
			itemFunc = level_5[random].func
		end
	elseif level >= 1 and level <= 4 then
		random = math.random(1,#level_1_4)
		if level_1_4[random].text ~= nil then
			text = string.gsub(level_1_4[random].text,"$N",role.name)
		end
		if level_1_4[random].func then
			itemFunc = level_1_4[random].func
		end
	else
		if level == 7 and role.canSeeInheritHistory == false then
			text = self:getItemToPLayerText(role,item)
			itemFunc = function()
				role.canSeeInheritHistory = true
				role.words = string.split("快走快走，别让我看见你。;自从戴了这个面具以来，就经常被人当成鬼，气死我了。",";")
			end
		else
			random = math.random(1,#other)
			if other[random].text ~= nil then
				text = string.gsub(other[random].text,"$N",role.name)
			end
			if other[random].func then
				itemFunc = other[random].func
			end
		end
	end
	if text ~= nil then
		RichPrint("main",text)
	end
	if itemFunc then
		itemFunc()
	end
	User:getRole():addItemCount(item.id,-1)
	if func then
		func()
	end
	PopupLayerController:hideLayer("GhostItemLayer", function(layer)
		self:hide()	
	end)
end
--狗血
function GhostItemLayer:setGouXueCallFunc(item,role,func)
	local level = ghosts:getDemonlevel(role.baseId)
	local mapLayer = self.controller:getLayer("MapLayer")
	local level_4_5 = {
		[1] = {
			text = "HIM$N被你的黑狗血撒中，身上冒出丝丝黑烟，竟是消失了。",
			func = function()
				self:removeGhostWithReward(role)
			end
		},
		[2] = {
			-- text = "HIM你冲着$N撒了一盆黑狗血，$N被黑狗血撒到身上冒出黑烟，$N大叫着直接扑了上来！",
			func = function()
				--血量减少50%进入战斗
				self:entryFight("HIM你冲着$N撒了一盆黑狗血，\n$N被黑狗血撒到身上冒出黑烟，\n$N大叫着直接扑了上来！",function(currRole)
					currRole:setAttr("qi",tonumber(currRole:getFinalAttr("qi"))/2)
				end,role)
			end
		},
	}
	local level_1_3 = {
		[1] = {
			-- text = "HIM$N被你的黑狗血撒中，勃然大怒，直接扑向了你。",
			func = function ()
				--进入战斗
				self:entryFight("HIM$N被你的黑狗血撒中，\n勃然大怒，\n直接扑向了你。",function(currRole)
					-- currRole:setAttr(tonumber(currRole:getAttr("qiMax"))/2)
				end,role)
			end
		},
		[2] = {
			text = "HIM你冲着$N撒了一把黑狗血，$N尖叫一声，然后攻击了你，你被其抓伤，血流了一地。",
			func = function ()
				--气血减少最大值的10%
				self:subPlayerQiAttr()
			end
		},
	}
	local other = {
		[1] = {
			text = "YEL$N：有病吧你！乱撒什么玩意！",
			func = function()

			end
		},
		[2] = {
			text = "你对着$N撒了一把黑狗血，什么事情都没发生。",
			func = function()

			end
		},
		[3] = {
			text = "你冲着$N撒了一把黑狗血，$N勃然大怒，无奈之下你花了500两才达成和解。",
			func = function()
				PopText("碎银减少"..tostring(500))
				User:getRole():addAttr("money",-500)
			end
		},
		[4] = {
			text = "你冲着$N撒了一盆黑狗血，$N大怒之下，追着你跑了好几里，还好你轻功了得方才逃过一劫。",
			func = function()
				--退出副本
				local MapRoleLayer = self.controller:getLayer("MapRoleLayer")
				MapRoleLayer:exitMap()
			end
		}
	}
	local random = nil
	local text = nil
	local itemFunc = nil 
	if level >= 4 and level <= 5 then
		random = math.random(1,#level_4_5)
		if level_4_5[random].text ~= nil then
			text = string.gsub(level_4_5[random].text,"$N",role.name)
		end
		if level_4_5[random].func then
			itemFunc = level_4_5[random].func
		end
	elseif level >= 1 and level <= 3 then
		random = math.random(1,#level_1_3)
		if level_1_3[random].text ~= nil then
			text = string.gsub(level_1_3[random].text,"$N",role.name)
		end
		if level_1_3[random].func then
			itemFunc = level_1_3[random].func
		end
	else
		if level == 7 and role.canSeeInheritHistory == false then
			text = self:getItemToPLayerText(role,item)
			itemFunc = function()
				role.canSeeInheritHistory = true
				role.words = string.split("快走快走，别让我看见你。;自从戴了这个面具以来，就经常被人当成鬼，气死我了。",";")
			end
		else
			random = math.random(1,#other)
			if other[random].text ~= nil then
				text = string.gsub(other[random].text,"$N",role.name)
			end
			if other[random].func then
				itemFunc = other[random].func
			end
		end
	end
	if text ~= nil then
		RichPrint("main",text)
	end
	User:getRole():addItemCount(item.id,-1)
	if func then
		func()
	end
	if itemFunc then
		itemFunc()
	end
	PopupLayerController:hideLayer("GhostItemLayer", function(layer)
		self:hide()	
	end)
end
--桃木剑
function GhostItemLayer:setMuJianCallFunc(item,role,func)
	local level = ghosts:getDemonlevel(role.baseId)
	local mapLayer = self.controller:getLayer("MapLayer")
	local level_3_5 = {
		[1] = {
			text = "HIM$N被你的桃木剑砍中，身上冒出丝丝黑烟，竟是消失了。",
			func = function()
				self:removeGhostWithReward(role)
			end
		},
		[2] = {
			func = function()
				--血量减少50%进入战斗
				self:entryFight("HIM你冲着$N一阵乱砍，\n$N被桃木剑砍到身上冒出黑烟，\n$N大叫着直接扑了上来！",function(currRole)
					currRole:setAttr("qi",tonumber(currRole:getFinalAttr("qi"))/2)
				end,role)
			end
		},
	}
	local level_1_2 = {
		[1] = {
			func = function ()
				--进入战斗
				self:entryFight("HIM$N被你的桃木剑砍中，\n勃然大怒，\n直接扑向了你。",function(currRole)
					-- currRole:setAttr(tonumber(currRole:getAttr("qiMax"))/2)
				end,role)
			end
		},
		[2] = {
			text = "HIM你冲着$N一阵乱砍，$N怒吼了一声，然后攻击了你，你被其抓伤，血流了一地。",
			func = function ()
				--气血减少最大值的10%
				self:subPlayerQiAttr()
			end
		},
	}
	local other = {
		[1] = {
			text = "YEL$N：有病吧你！乱砍什么玩意！",
			func = function()

			end
		},
		[2] = {
			text = "你对着$N一阵乱砍，什么事情都没发生",
			func = function()

			end
		},
		[3] = {
			text = "冲着$N一阵乱砍，$N勃然大怒，无奈之下你花了500两才达成和解。",
			func = function()
				PopText("碎银减少"..tostring(500))
				User:getRole():addAttr("money",-500)
			end
		},
		[4] = {
			text = "你冲着$N一阵乱砍，$N大怒之下，追着你跑了好几里，还好你轻功了得方才逃过一劫。",
			func = function()
				--退出副本
				local MapRoleLayer = self.controller:getLayer("MapRoleLayer")
				MapRoleLayer:exitMap()
			end
		}
	}
	local random = nil
	local text = nil
	local itemFunc = nil 
	if level >= 3 and level <= 5 then
		random = math.random(1,#level_3_5)
		if level_3_5[random].text ~= nil then
			text = string.gsub(level_3_5[random].text,"$N",role.name)
		end
		if level_3_5[random].func then
			itemFunc = level_3_5[random].func
		end
	elseif level >= 1 and level <= 2 then
		random = math.random(1,#level_1_2)
		if level_1_2[random].text  ~= nil then
			text = string.gsub(level_1_2[random].text,"$N",role.name)
		end
		if level_1_2[random].func then
			itemFunc = level_1_2[random].func
		end
	else
		if level == 7 and role.canSeeInheritHistory == false then
			text = self:getItemToPLayerText(role,item)
			itemFunc = function()
				role.canSeeInheritHistory = true
				role.words = string.split("快走快走，别让我看见你。;自从戴了这个面具以来，就经常被人当成鬼，气死我了。",";")
			end
		else
			random = math.random(1,#other)
			if other[random].text ~= nil then
				text = string.gsub(other[random].text,"$N",role.name)
			end
			if other[random].func then
				itemFunc = other[random].func
			end
		end
	end
	if text ~= nil then
		RichPrint("main",text)
	end
	User:getRole():addItemCount(item.id,-1)
	if itemFunc then
		itemFunc()
	end
	if func then
		func()
	end
	PopupLayerController:hideLayer("GhostItemLayer", function(layer)
		self:hide()	
	end)
end

--铜钱
function GhostItemLayer:setTongQianCallFUnc(item,role,func)
	local level = ghosts:getDemonlevel(role.baseId)
	local mapLayer = self.controller:getLayer("MapLayer")
	local level_5 = {
		[1] = {
			text = "HIM$N被你的古铜钱撒中，身上冒出丝丝黑烟，竟是消失了。",
			func = function()
				self:removeGhostWithReward(role)
			end
		},
		[2] = {
			-- text = "HIM你冲着$N撒了一把古铜钱，$N被古铜钱撒到身上冒出黑烟，$N大叫着直接扑了上来！",
			func = function()
				--血量减少50%进入战斗
				self:entryFight("HIM你冲着$N撒了一把古铜钱，\n$N被古铜钱撒到身上冒出黑烟，\n$N大叫着直接扑了上来！",function(currRole)
					currRole:setAttr("qi",tonumber(currRole:getFinalAttr("qi"))/2)
				end,role)
			end
		},
	}
	local level_1_4 = {
		[1] = {
			-- text = "HIM$N被你的古铜钱撒中，勃然大怒，直接扑向了你。直接攻击",
			func = function ()
				--进入战斗

				self:entryFight("HIM你冲着$N撒了一把古铜钱，\n$N被古铜钱撒到身上冒出丝丝黑烟，\n$N直接扑向了你。",function(currRole)
					currRole:setAttr("qi",tonumber(currRole:getFinalAttr("qi"))*0.8)
				end,role)
			end
		}
	}
	local other = {
		[1] = {
			text = "YEL$N：有病吧你！乱撒什么玩意！",
			func = function()

			end
		},
		[2] = {
			text = "你对着$N撒了一把古铜钱，什么事情都没发生。",
			func = function()

			end
		},
		[3] = {
			text = "你冲着$N撒了一把古铜钱，$N勃然大怒，无奈之下你花了500两才达成和解。",
			func = function()
				PopText("碎银减少"..tostring(500))
				User:getRole():addAttr("money",-500)
			end
		},
		[4] = {
			text = "你冲着$N撒了一把古铜钱，$N大怒之下，追着你跑了好几里，还好你轻功了得方才逃过一劫。",
			func = function ()
				--退出副本
				local MapRoleLayer = self.controller:getLayer("MapRoleLayer")
				MapRoleLayer:exitMap()
			end
		}
	}
	local random = nil
	local text = nil
	local itemFunc = nil 
	if level >= 2 and level <= 5 then
		random = math.random(1,#level_5)
		if level_5[random].text ~= nil then
			text = string.gsub(level_5[random].text,"$N",role.name)
		end
		if level_5[random].func then
			itemFunc = level_5[random].func
		end
	elseif level == 1 then
		random = math.random(1,#level_1_4)
		if level_1_4[random].text ~= nil then
			text = string.gsub(level_1_4[random].text,"$N",role.name)
		end
		if level_1_4[random].func then
			itemFunc = level_1_4[random].func
		end
	else
		if level == 7 and role.canSeeInheritHistory == false then
			text = self:getItemToPLayerText(role,item)
			itemFunc = function()
				role.canSeeInheritHistory = true
				role.words = string.split("快走快走，别让我看见你。;自从戴了这个面具以来，就经常被人当成鬼，气死我了。",";")
			end
		else
			random = math.random(1,#other)
			if other[random].text ~= nil then
				text = string.gsub(other[random].text,"$N",role.name)
			end
			if other[random].func then
				itemFunc = other[random].func
			end
		end
	end
	if text ~= nil then
		RichPrint("main",text)
	end
	User:getRole():addItemCount(item.id,-1)
	if itemFunc then
		itemFunc()
	end
	if func then
		func()
	end
	PopupLayerController:hideLayer("GhostItemLayer", function(layer)
		self:hide()	
	end)
end

function GhostItemLayer:createFight(role,player,winFunc,loseFunc,text,func)
    local mapLayer = self.controller:getLayer("MapLayer")
    local currRole = role
		local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")
		local dialog = DialogALayer:getInstance()
		dialog:hide()
		dialog:show("RED"..text)
		dialog:setBack(false)
		dialog:setButton1("迎战", function()
			Audio:playEffect("jiaoHu")
			if TANGJIAN_TEST_ENABLE then
				local currMap = player:getCurrMap()
				self.mapLayer = mapLayer
                role:initNpcAttr() -- NPC状态初始化
                if func then
                	func(role)
                end
				currMap:afterFightWithShaSi(player, role, function(winTeamId)
					-- 战斗胜利条件结果
                    if winTeamId == 1 then
                        PopText("你决斗战胜了" .. role:getName())

                        -- 玩家操作默认
                        role:setFlag("是否死亡", true)
                        currMap:dowithRoleOperation({
                            operation = "杀死",
                            result = "成功",
                            player = player,
                            currRole = role,
                            currMap = currMap,
                            currRoomId = self.mapLayer._currRoom.id
                        })
                        currMap:doConditionAndResult(role.conditionAndResults,
                        {
                            conditionType = "杀死",
                            result = "成功",
                            currRole = role,
                            currRoomId = self.mapLayer._currRoom.id,
                            mapLayer = self.mapLayer
                        })
                        if winFunc then
                        	winFunc()
                        end
                        currMap:doRoomConditionAndResult(self.mapLayer._currRoom.id) -- 刷新房间条件结果
                        mapLayer:delayRefreshMap()
                    elseif winTeamId == 2 then
                        PopText("你被" .. role:getName() .. "打败了")

                        if User:getRole():getFlag("佣兵模式") == "开启" then
                            currMap:doConditionAndResult(role.conditionAndResults,
                            {
                                conditionType = "杀死",
                                result = "失败",
                                currRole = role,
                                currRoomId = self.mapLayer._currRoom.id,
                                mapLayer = self.mapLayer
                            })
                            currMap:doRoomConditionAndResult(self.mapLayer._currRoom.id)-- 刷新房间条件结果
                        else
							mapLayer.TotalMapBtn_IsInit = false
							mapLayer:quit()
						end
						if loseFunc then
							loseFunc()
						end
					elseif winTeamId == 3 then -- add by XiaoZhiWei 2017/09/06 14:37:56 逃跑的情况
					else
                    end
				end)
            else

			 -- 	local FightLayer = require("app.views.layer.WordFightLayer")
		  --       local fightLayer = FightLayer:getInstance()
		  --       fightLayer:show(true, "杀死")
		  --       fightLayer:startFight({ player }, { currRole },
		  --           function(winTeamId)
		  --           	if winTeamId == 1 then
	   --                      self:dowithRoleOperation({
	   --                          operation = "杀死",
	   --                          result = "成功",
	   --                          player = player,
	   --                          currRole = currRole,
	   --                          currMap = self,
	   --                          currRoomId = environment.currRoomId
	   --                      })

	   --                      currRole:setFlag("是否死亡", true)

	   --                      self:doConditionAndResult(currRole.conditionAndResults,
	   --                          {
	   --                              conditionType = "杀死",
	   --                              result = "成功",
	   --                              currRole = currRole,
		  --                           player = player,
		  --                           currMap = self,
	   --                         		currRoomId = environment.currRoomId
	   --                          })


	   --                      -- 刷新房间条件结果
	   --             			self:doRoomConditionAndResult(environment.currRoomId)
    --                    		self.__MapLayer:delayRefreshMap()
	   --             		elseif winTeamId == 2 then
				-- 			self.__MapLayer.TotalMapBtn_IsInit = false
				-- 			self.__MapLayer:quit()
	   --             			-- self.__MapLayer.ControllLayer:popLayer()

		  --           	end
				-- end, true)
			end
		end)
		dialog:setButton2()
end
Helper:classDefNodeGetInstance(GhostItemLayer)

return GhostItemLayer0000000000000