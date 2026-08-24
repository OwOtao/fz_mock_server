--
-- Author: TanQinJian
-- Date: 2019-06-27 16:37:34
--
local ServantRewardLayer = class("ServantRewardLayer", cc.Layer)
local HomelandRoleUtil = require("app.models.HomelandModel.HomelandRoleUtil")
local treasureItems={}


local activity_conf = {
	start_time = "20200119",
	end_Time = "20200202",
	needBagSpace = 2,
	--isInActivity 是否在活动时间 canGetReward 是否可获取奖励
	condition = function ( self,isNeedPop,... ) 
		local isInActivity = true
		local canGetReward =0  -- 1 背包不足 2 已获取 3 可获取
		if isNeedPop==nil then 
			isNeedPop = true
		end
		if GetTime() < Helper:getTimeStampWithStringDate(self.start_time, 0) or 
		GetTime() > Helper:getTimeStampWithStringDate(self.end_Time, 0) then
			isInActivity = false
			return isInActivity,canGetReward
		end
		if isInActivity then 
			local role=User:getRole()
			if role:getDayFlag("新春仆人赏赐奖励") < 1 then 
				
				if role:getAttr("weight") - #role:getItems() >= self.needBagSpace then 
					canGetReward = 3
				else
					if isNeedPop then 
						PopText("背包空间不足，需空余出"..tostring(self.needBagSpace).."个位子才可进行赏赐。")
					end
					canGetReward = 1
				end
			else
				canGetReward = 2
			end
		end
		return isInActivity,canGetReward
	end,

	getReward = function ( self,... )
		local isInActivity,canGetReward = self:condition(false)
		if isInActivity and canGetReward == 3 then 
			local SFTokenCollection2019 = require("app.models.SpringFestival.2019.SFTokenCollection2019")
			SFTokenCollection2019:initConfig()
			local itemId = SFTokenCollection2019:randomToken()
		    SFTokenCollection2019:addToken(itemId,1)
		    User:getRole():setDayFlag("新春仆人赏赐奖励",User:getRole():getDayFlag("新春仆人赏赐奖励")+1)
		end
	end
}


function ServantRewardLayer:create()
	local p = ServantRewardLayer:new()
	p:init()
	return p
end

function ServantRewardLayer:init()
	self._UI = require("Layer/HomelandUI/ServantRewardUI.lua").create() ['root']
	self._UI:addTo(self)
	Helper:convertUIByParent(self)
	self.currCostYinPiao=0
	self.currTotalYinPiao=0
	self.currAddZhongCheng=0
	self.currNpc=nil
	self.currMap=nil
	self:setVisible(false)
	self.Button_back:releaseFunc(function()
		PopupLayerController:hideLayer("ServantRewardLayer",function ()
			self:setVisible(false)
		end)
	end)
end

function ServantRewardLayer:showLayer(npc,map)
	treasureItems={}
	self.currCostYinPiao=0
	self.currTotalYinPiao=0
	self.currAddZhongCheng=0
	self.currNpc=nil
	self.currMap=nil
	HttpManagerEx:viewCurrencyByType("yinpiao", User:getRole():getCurrencyVersion(), function(status, errcode, errmsg, data)
            if status == 200 and errcode == 0 then
                self.currTotalYinPiao = data.number
                self.currNpc=npc
                self.currMap=map
                self.currCostYinPiao,self.currAddZhongCheng = self:getRewardInfo(npc).yinPiaoCost,self:getRewardInfo(npc).addZhongcheng
                self:setVisible(true)
                self:getBaoWuItems()
				self.Text_title:setString("对"..npc.name.."进行赏赐")
				self:initBaoWuPanelInfo(npc,map)
				self:initYinPiaoPanelInfo(npc,map)
            else
                PopText(errmsg)
            end
    	end, IS_SHOW_WAITING)
end

function ServantRewardLayer:initYinPiaoPanelInfo(npc,map)

	self.Panel_yinpiao.Text_title:setString("银票赏赐")
	self.Panel_yinpiao.Panel_info.Text_name:setString("银票")
	self.Panel_yinpiao.Panel_info.Text_num:setString("银票扣除："..tostring(self.currCostYinPiao))
	self.Panel_yinpiao.Panel_info.Text_info:setString("目前剩余银票："..tostring(self.currTotalYinPiao))
	self.Panel_yinpiao.Panel_info.Button_reward:releaseFunc(function ()
		self:rewardFunc(npc,map,"yinpiao",function()
			self.currTotalYinPiao = self.currTotalYinPiao - self.currCostYinPiao
			self.Panel_yinpiao.Panel_info.Text_info:setString("目前剩余银票："..tostring(self.currTotalYinPiao))
			PopText("赏赐成功，"..npc.name.."增加了"..tostring(math.floor(self.currAddZhongCheng)).."忠诚度。")
		end)
	end)
end

function ServantRewardLayer:initBaoWuPanelInfo(npc,map)
	self.Panel_daoju.Text_title:setString("珍宝赏赐")
	self.Panel_daoju.ListView_item:removeAllItems()
	if MapIsEmpty(treasureItems) then 
		self.Panel_daoju.Text_nothing:setVisible(true)
		return
	end
-- 	homebw1赠予可得50忠诚度
-- homebw2赠予可得35忠诚度
-- homebw3赠予可得25忠诚度
-- homebw4赠予可得15忠诚度
	local baowuAddZhongCheng={
		["homebw1"]=50,
		["homebw2"]=35,
		["homebw3"]=25,
		["homebw4"]=15,
	}
	self.Panel_daoju.Text_nothing:setVisible(false)
    for k,v in pairs(treasureItems) do
    	local panel = self.Panel_item:clone()
    	self.Panel_daoju.ListView_item:pushBackCustomItem(panel)
		Helper:convertUIByParent(panel)
		panel.Text_name:setString(v.name)
		panel.Text_num:setString("目前剩余："..tostring(v.count))
		panel.Text_zhongcheng:setString("赏赐此珍宝可增加"..tostring(baowuAddZhongCheng[v.itemId]).."点忠诚度")
		panel.Button_reward:releaseFunc(function ()
			self.currBaoWuAddZhongCheng=baowuAddZhongCheng[v.itemId]
			self.currBaoWuItemId=v.itemId
			if not self.currBaoWuAddZhongCheng then 
				print("baowuAddZhongCheng 该物品未添加",v.itemId)
				return
			end
			self:rewardFunc(npc,map,"baowu",function ()
				v.count = v.count-1
				if v.count < 1 then 
					table.remove(treasureItems,k)
				end
				PopText("赏赐成功，"..npc.name.."增加了"..baowuAddZhongCheng[v.itemId].."忠诚度。")
				User:getRole():addItemCount(v.itemId, -1)
				self:initBaoWuPanelInfo(self.currNpc,self.currMap)
			end)
		end)
    end
end

function ServantRewardLayer:getBaoWuItems()
	treasureItems={}
	local role=User:getRole()
	local items=role:getItems()
    for k,v in ipairs(items) do 
        local itemAttr = role:getOneItemByKey(v.itemId)
        if itemAttr.type == "珍宝" then 
        	local itemInfo={}
        	Helper:tableCover(itemInfo,v)
        	itemInfo.name = itemAttr.name
            table.insert(treasureItems,itemInfo)
        end
    end
end

function ServantRewardLayer:rewardFunc(npc,map,rewardType,func)
	if MapIsEmpty(npc) or MapIsEmpty(map) then 
		print("仆人赏赐界面 仆人参数不对")
		return 
	end
	local isInActivity,canGetReward = activity_conf:condition()
	if isInActivity and canGetReward == 1 then 
		return
	end
	local HomelandDesc = require("app.models.HomelandModel.HomelandDesc")
	local text = ""
	
    local conf_cn = {
        ["ssyjf"] = "新春礼券",  --双十一
        ["znqjf"] = "小年礼券",
		["daily_point"] = "积分"
    }
    if rewardType == "yinpiao" then 
    	text = HomelandDesc:getGrowthText(self.currAddZhongCheng,npc.name)

	    HttpManagerEx:updateEmployRoleData(npc.id,map.mid,"give",self.currAddZhongCheng,self:getRewardInfo(npc).yinPiaoCost,function(status, errcode, errmsg, data)
	        if status == 200 then
	            if errcode == 0 then
	                --Helper:print_lua_table(data)
	                HomelandRoleUtil:setHomeLandRoleData(npc.jobType,data.defaultZhongCheng)
	                HomelandRoleUtil:updateFidelity(data.defaultZhongCheng,npc)
	                HomelandRoleUtil:DeblockRoleTrait(npc,data.trait)
	                --仆人特性
	                HomelandRoleUtil:getItemInReward(npc,map)

	                local rewardText = HomelandDesc:getAwardText(npc)

	                text = rewardText.."\n"..text
	                RichPrint("main",text)
	                if MapIsEmpty(data.activity) == false then
	                    for k,v in pairs(data.activity) do
	                        if v > 0 then
	                            PopText(conf_cn[k].." +"..v)
	                        end
	                    end
	                end
	                --活动奖励
	                activity_conf:getReward()

	                if func then 
	                	func()
	                end
	            elseif errcode == 2 then
	                PopText("你今日已经赏赐够多了，还是明日再说吧")
	            else
	                PopText(errmsg)
	            end  
	        else
	            PopText(errmsg)
	        end
	    end, IS_SHOW_WAITING)
	elseif rewardType == "baowu" then
		text = HomelandDesc:getGrowthText(self.currBaoWuAddZhongCheng,npc.name)
		local function getBwReward()
			HttpManagerEx:useHomeBw(self.currBaoWuAddZhongCheng,npc.id,map.mid,self.currBaoWuItemId,function(status, errcode, errmsg, data)
		        if status == 200 then
		            if errcode == 0 then
		            	print("---------宝物id：",self.currBaoWuItemId)
		                --Helper:print_lua_table(data)
		                HomelandRoleUtil:setHomeLandRoleData(npc.jobType,data.defaultZhongCheng)
		                HomelandRoleUtil:updateFidelity(data.defaultZhongCheng,npc)
		                HomelandRoleUtil:DeblockRoleTrait(npc,data.trait)
		                --仆人特性
		                HomelandRoleUtil:getItemInReward(npc,map)

		                local rewardText = HomelandDesc:getAwardText(npc)

		                text = rewardText.."\n"..text
		                RichPrint("main",text)
		                if MapIsEmpty(data.activity) == false then
		                    for k,v in pairs(data.activity) do
		                        if v > 0 then
		                            PopText(conf_cn[k].." +"..v)
		                        end
		                    end
		                end
		                --活动奖励
		                activity_conf:getReward()

		                if data.defaultZhongCheng>=4000 then 
		                	PopText("当前忠诚度已达到上限")
		                end
		                if func then 
		                	func()
		                end
		            elseif errcode == 1 then
		                PopText("需拥有珍宝才能赏赐")
		            elseif errcode == 2 then
		                PopText("当前忠诚度已达到上限")
		            elseif errcode == 3 then
		                PopText("你今日已经赏赐够多了，还是明日再说吧")
		            else
		                PopText(errmsg)
		            end
		        else
		            PopText(errmsg)
		        end
		    end, IS_SHOW_WAITING)
		end

		getBwReward()
	end
end


function ServantRewardLayer:getRewardInfo(npc)
	local objId = npc.id
        
	local characterId = npc.character

    local jobType = npc.jobType
    
    local characterFactor = HomelandRoleUtil:getCharacterFactor(jobType)
    local characterAttr = HomelandRoleUtil:getCharacterAttr(characterId)

    local rewardjiage = characterFactor.rewardjiage1
    
	local rewardjiagexishu = characterAttr.rewardjiage

    local rewardzhongcheng = characterFactor.rewardzhongcheng1
    
	local rewardzhongcheng1 = characterAttr.rewardzhongcheng

	local value = rewardjiage*rewardjiagexishu --赏赐数值

    local addzhongcheng = rewardzhongcheng*rewardzhongcheng1  -- 每次赏赐获得的忠诚度
    addzhongcheng = addzhongcheng + npc:getBuffAttr("fidelityAddByReward")

	local servantRewardConstans = TableProxy:createEncryptedTableRecursive({
		yinPiaoCost = value,
		addZhongcheng = addzhongcheng,
	})

    return servantRewardConstans
end

Helper:classDefNodeGetInstance(ServantRewardLayer)
return ServantRewardLayer000000