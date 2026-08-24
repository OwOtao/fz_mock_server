local XingZhenRewardLayer = class("XingZhenRewardLayer", cc.Layer)
local XingZhen = require("app.models.XingZhenEffects.XingZhenEffects")

--百分比为1 数值2 空白0
local effectType = {
	{"后天臂力变化", 1},
	{"后天身法变化",1},
	{"现有精力",1},
	{"年龄",2},
	{"内力上限（不超过上限）",2},
	{"容貌",2},
	-- {"年龄",2},
	-- {"下次冲穴概率",1},
	-- {"下次淬炼概率",1},
	-- {"购物时价格（商城除外）",1},
	-- {"战斗中无法使用主动技能",0},
	-- {"打坐回复速度",1},
	-- {"体力上限",2},
	-- {"真气",2},
	-- {"内力上限（不超过上限）",1},
	-- {"精力回复速度",1},
	-- {"战斗中自己播放动画速度",1},
	-- {"气血上限不受伤害",0},
	-- {"无法进行挂机",0},
	-- {"侠义正气",2},
	-- {"生命上限",1},
	-- {"潜能",2},
	-- {"经脉经验",2}
}

function XingZhenRewardLayer:create()
	local p = XingZhenRewardLayer:new()
	p:init()
	return p
end

--几种行针方法
local xingZhenList = {}

function XingZhenRewardLayer:init()
	self._UI = require("Layer/ZouXueShiSiJingUI/ZouXueDialogUI.lua").create()["root"]
    self._UI:addTo(self)
    Helper:convertUIByParent(self)	
end

function XingZhenRewardLayer:initUI(func)
	local npcDatas = require("script.others.zouxuejing")
    local npcEffect = npcDatas.effect

	local role = User:getRole()
	local effectData = XingZhen:getXingZhen("行针走穴Effects")
	local effectDataCD = XingZhen:getXingZhen("行针走穴EffectsCD")
	local effectDataValues = XingZhen:getXingZhen("行针走穴EffectsValues")

	self.effects = self:sameAdd(Helper:getDef(effectData,{}))
	self.effectsCD = self:sameAdd(Helper:getDef(effectDataCD,{}))
	-- self.effects = self:sameAdd((effectData.effects))
	-- self.badeffects = self:sameAdd((effectData.badeffects))

	self.ListView_1:removeAllItems()
	for k,v in pairs(self.effects) do
		local panel =self:clonePanel(self.Panel_item)--克隆一个条目

		local effectData = npcEffect[v]--拿到效果的一条数据
		panel.Text_name:setString(effectData.describe)

		-- if effectData.time > 0 then
		-- 	panel.Text_time:setVisible(true)
		-- 	local a,b,c = Helper:sec2timeDsc(effectData.time)
		-- 	local cdTimetext = a.."小时"..b.."分钟"
		-- 	panel.Text_time:setString("效果剩余"..cdTimetext)
		-- else
		-- 	panel.Text_time:setVisible(false)
		-- end

		if self.effectsCD[k].before ~= 0 then
			local cdTime = self.effectsCD[k].after - GetTime()
			if cdTime > 0 then
				local a,b,c = Helper:sec2timeDsc(cdTime)
				local cdTimetext = a.."小时"..b.."分钟"..c.."秒"
				panel.Text_time:setString("效果剩余"..cdTimetext)
			else
				panel.Text_time:setString("效果持续时间已结束")
			end
		else
			panel.Text_time:setVisible(false)
		end

		self.ListView_1:pushBackCustomItem(panel)--添加一个条目
	end
	if func then
		func()
	end
end

function XingZhenRewardLayer:sameAdd(effects)
	local t = effects
    local n = {}
    for k, v in pairs(t) do
        if n[k] == nil then
            n[k] =  v
        else
			n[k] = n[k] + v
        end
    end
    return n
end

function XingZhenRewardLayer:showLayer(zhenfaData,num,func)
	local npcDatas = require("script.others.zouxuejing")
	if num == 1 then--判断1是试针散装的效果界面，还是行针或是通针的效果界面
		self.Text_name:setString("试针效果")
		-- local xueweis = string.split(zhenfaData.xuewei,";")
		local xueweistring = ""
		for i,v in pairs(zhenfaData) do
			local xueWeiName = npcDatas.xuewei[v].name
			xueweistring = xueWeiName .. "," .. xueweistring
		end
		xueweistring = string.sub(xueweistring, 1, string.len(xueweistring) - 1)--去除最后一个逗号
		self.Text_text:setString("当前插针的穴位:\n"..xueweistring)
	else
		self.Text_name:setString(zhenfaData.name)
		self.Text_text:setString(zhenfaData.text2)
	end
	
	-- self:delayFunc(1, function()
		self:schedule(function(ft)--每帧调用
			self:update(ft)
		end,1)
	-- end)
	
	self:initUI(func)
	self.Panel_back:releaseFunc(function()
		self:hide()
	end)
	self:show()
end


function XingZhenRewardLayer:clonePanel(panel)
	if panel == nil then
		return
	end
	local row = panel:clone() 
	Helper:convertUI(row)
	return row
end

function XingZhenRewardLayer:update()
	local items = self.ListView_1:getItems()
	local removeIndexs = {}
	for index = 1, #items do
		local panel = self.ListView_1:getItem(index - 1)
		if panel ~= nil then
			if self.effectsCD[index].before ~= 0 then
				local cdTime = self.effectsCD[index].after - GetTime()
				if cdTime > 0 then
					local a,b,c = Helper:sec2timeDsc(cdTime)
					local cdTimetext = a.."小时"..b.."分钟"..c.."秒"

					panel.Text_time:setString("效果剩余"..cdTimetext)
				else
					-- table.insert(removeIndexs, index)--把cd到的移除
					panel.Text_time:setString("效果持续时间已结束")
				end
			end
		end
	end
end

Helper:classDefNodeGetInstance(XingZhenRewardLayer)

return XingZhenRewardLayer000000000000