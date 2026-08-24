local YongBingInfoLayer = class("YongBingInfoLayer", require("app.views.base.BaseLayer"))

function YongBingInfoLayer:create()
    local p = YongBingInfoLayer:new()
    p:init()
    return p
end

function YongBingInfoLayer:init()
    self._UI = require("Layer/YongBingUI/XiangXiUI.lua").create()['root']
    self._UI:addTo(self)

    Helper:convertUI(self)-- 获得所有子节点

    self.Panel_back:releaseFunc(function()
    	PopupLayerController:hideLayer("YongBingInfoLayer", function(layer)
    		self:hide(true)
    	end)
        
    end)

    self:hide()-- 隐藏自身

    self.__currRole = nil -- add by XiaoZhiWei 2017/05/24 15:49:25 记录当前角色
end

function YongBingInfoLayer:showRoleInfo(role)
	if User:getRole():getCurrMap():getYongBingId() == role.id then
		self:setTextTital("人物属性")
		self:setTextQiXue(role:getAttr("qi"), role:getCurrQiMax())
		self:setTextNeiLi(role:getAttr("neili"), role:getFinalAttr("neiliMax"))
	else
		self:setTextTital("人物介绍")
		self:setTextQiMax(role:getCurrQiMax())
		self:setTextNeiLiMax(role:getFinalAttr("neiliMax"))
	end
	self:setTextName(role:getAttr("name"))
	self:setTextGongJi(role:getAtk())
	self:setTextShangHai(role:getPowerDamage())
	self:setTextFangYu(role:getDef())
	self:setTextFangHu(role:getFangHu())
	self:setTextDuoShan(role:getDodge())
	self:setSkillList(role:getSkills(), User:getRole():getMapNpcMaxZhaoLv(role.AttrModifyId))
	self:setButtonMiaoShu()
	self:show(true)
	self.__currRole = role
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/04/26 11:23:04
-- @desc 设置名字
function YongBingInfoLayer:setTextName(name)
	name = Helper:getDef(name, "无名小辈")
	self.Text_name:setString(name)
end

function YongBingInfoLayer:setTextTital(tital)
	tital = Helper:getDef(tital, "人物属性")
	self.Text_renwushuxing:setString(tital)
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/04/26 00:24:13
-- @desc 设置气血值
function YongBingInfoLayer:setTextQiXue(qi, qiMax)
	qi = Helper:mathFloor(Helper:getDef(qi, 0))
	qiMax = Helper:mathFloor(Helper:getDef(qiMax, 0))
	self.Text_qixue:setString("『气血』"..qi.."/"..qiMax)
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/04/26 00:24:26
-- @desc 设置内力值
function YongBingInfoLayer:setTextNeiLi(neili, neiliMax)
	neili = Helper:mathFloor(Helper:getDef(neili, 0))
	neiliMax = Helper:mathFloor(Helper:getDef(neiliMax, 0))
	self.Text_neili:setString("『内力』"..neili.."/"..neiliMax)
end

function YongBingInfoLayer:setTextQiMax(qiMax)
	qiMax = Helper:mathFloor(Helper:getDef(qiMax, 0))
	self.Text_qixue:setString("『气血』   "..qiMax)
end

function YongBingInfoLayer:setTextNeiLiMax(neiliMax)
	neiliMax = Helper:mathFloor(Helper:getDef(neiliMax, 0))
	self.Text_neili:setString("『内力』   "..neiliMax)
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/04/26 02:01:26
-- @desc 设置攻击力
function YongBingInfoLayer:setTextGongJi(atk)
	atk = Helper:mathFloor(Helper:getDef(atk, 0))
	self.Text_gongji:setString("『攻击力』"..atk)
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/04/26 02:03:15
-- @desc 设置伤害力
function YongBingInfoLayer:setTextShangHai(shanghai)
	shanghai = Helper:mathFloor(Helper:getDef(shanghai, 0))
	self.Text_shanghai:setString("『伤害力』"..shanghai)
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/04/26 02:03:58
-- @desc 设置防御力
function YongBingInfoLayer:setTextFangYu(fangyu)
	fangyu = Helper:mathFloor(Helper:getDef(fangyu, 0))
	self.Text_fangyu:setString("『防御力』"..fangyu)
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/04/26 02:05:05
-- @desc 设置防护力
function YongBingInfoLayer:setTextFangHu(fanghu)
	fanghu = Helper:mathFloor(Helper:getDef(fanghu, 0))
	self.Text_fanghu:setString("『防护力』"..fanghu)
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/04/26 02:05:49
-- @desc 设置闪躲力
function YongBingInfoLayer:setTextDuoShan(shanduo)
	shanduo = Helper:mathFloor(Helper:getDef(shanduo, 0))
	self.Text_duoshan:setString("『闪躲力』"..shanduo)
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/04/26 02:07:15
-- @desc 设置技能
function YongBingInfoLayer:setSkillList(skillList, lv)
	skillList = Helper:getDef(skillList, {})
	lv = Helper:mathFloor(Helper:getDef(lv, 0))
	local listLength = #self.ListView_list:getItems()
	if listLength > #skillList then
	else
		listLength = #skillList
	end
	local item, skill
	-- for i=1,listLength do
	-- 	if i > #skillList then
	-- 		self.ListView_list:removeLastItem()
	-- 	else
	-- 		skill = Skill:getSkill(skillList[i])
	-- 		item = self.ListView_list:getItem(i-1)
	-- 		if item ~= nil then
	-- 		else
	-- 			item = self:cloneSkillItem()
	-- 		end
	-- 		item:setString("羽仙决 "..lv.."重")
	-- 		self.ListView_list:pushBackCustomItem(item)
	-- 	end
	-- end

	item = self.ListView_list:getItem(0)
	if item ~= nil then
	else
		item = self:cloneSkillItem()
		self.ListView_list:pushBackCustomItem(item)
	end
	item:setString("羽仙决 "..lv.."重")
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/04/26 02:15:33
-- @desc 克隆技能栏目
function YongBingInfoLayer:cloneSkillItem()
	local item = self.Text_skill:clone()
	item:setVisible(true)
	return item
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/04/26 02:37:17
-- @desc 设置描述按钮
function YongBingInfoLayer:setButtonMiaoShu()
	self.Button_DecorativeBox:releaseFunc(function()
		PopupLayerController:showLayer("RoleObserveLayer", function(layer)
			layer.mapLayer = MainControllLayer:getLayer("MapLayer")
	        if User:getRole():getFlag("佣兵模式") == "开启" then
				layer:showLayer(User:getRole():getCurrMap():getYongBingRole(),"MAP")
	        	-- layer:setMapRole(User:getRole():getCurrMap():getYongBingRole())
	        else
				layer:showLayer(self.__currRole,"MAP")
	        	-- layer:setMapRole(self.__currRole)
	        end

	        layer:maxZ() -- add by XiaoZhiWei 2017/05/18 18:07:06 getInstance 会将界面盖掉,所以需要设置到最上级
		end)
        PopupLayerController:hideLayer("YongBingInfoLayer", function(layer)
    		self:hide(true)
    	end)
	end)
end

Helper:classDefNodeGetInstance(YongBingInfoLayer)
return YongBingInfoLayer
00000