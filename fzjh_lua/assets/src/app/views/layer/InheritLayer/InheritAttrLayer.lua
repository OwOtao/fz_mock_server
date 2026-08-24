local InheritAttrLayer = class("InheritAttrLayer", cc.Layer)

function InheritAttrLayer:create()
	local p = InheritAttrLayer:new()
	p:init()
	return p
end

function InheritAttrLayer:init()
	self._UI = require("Layer/InheritUI/InheritAttrUI.lua").create()['root']
	self._UI:addTo(self)

	Helper:convertUIByParent(self)

	self.rich_text = nil

	self:initRichText()

	self:schedule(
    	function(ft)
    		self:update(ft)
    	end, 0.1)

	local  inherit = User:getRoleAttr("inherit")

	-- 孤儿描述
	self.descText = ""

	self:setButton()
	self:refreshUI()
end

function InheritAttrLayer:initRichText()
	if self.rich_text ~= nil then
        self.rich_text:removeFromParent()
	end

	local x, y = self.ListView_desc:getPosition()
    local size = self.ListView_desc:getContentSize()

    self.rich_text = ExtRichTextScroll:create()

    self.ListView_desc:getParent():addChild(self.rich_text)
    self.rich_text:move(cc.p(x, y))
    self.rich_text:setSize(size)
    self.rich_text:setAnchorPoint(cc.p(0.5, 0.5))
    self.rich_text:setDirection(kCCScrollViewDirectionVertical)
    self.rich_text:getRichText():setVerticalSpace(20)
end

function InheritAttrLayer:show()
	self:setVisible(true)
end

-- 检测是否能传承
function InheritAttrLayer:checkCanInherit()
	local inherit = User:getRoleAttr("inherit")
	if inherit.physique < inherit.physiqueMax or inherit.noema < inherit.noemaMax or inherit.morality < inherit.moralityMax or inherit.temperament < inherit.temperamentMax then
		return false
	end
	if inherit.intimacy < 37 then
		return false
	end
	return true
end

function InheritAttrLayer:setButton()
	-- 读书
	self.Button_read:releaseFunc(function()
		Audio:playEffect("xiaoAnNiu")
		local inherit = User:getRoleAttr("inherit")
		if self:checkCanInherit() then
		 	PopText("你的继承人 " .. inherit.name .. " 在同辈中已经出类拔萃，无需过度培养了。")
		elseif User:getRoleAttr("jing") < 10 then
			PopText("精力不足")
		elseif inherit.endurance >= 10 then
			local r = math.random(1,6)
			local str = ""
			local sex = "它"
			if inherit.sex == "男" then
				sex = "他"
			elseif inherit.sex == "女" then
				sex = "她"
			end
			local bookName =
			{
				[1] = "《论语》",
				[2] = "《道德经》",
				[3] = "《诗经》",
			}
			local val = 0
			if inherit.sex == "男" then
				if inherit.type == 4 then
					val = val + 2
				elseif inherit.type == 1 then
					val = val + 1
				end
			elseif inherit.sex == "女" then
				if inherit.type ~= 4 then
					val = val + 1
				end
			end

			-- 随机属性加成
			if r == 1 then
				val = val + 6
				str = "WHT你教这孩子" .. bookName[math.random(1,3)].. "，" .. sex .. "似乎一头雾水，并没有多少进展。"
				if inherit.morality < 100 then
					str = str .. "HIW德行 + " .. val .. "WHT"
				end
				str = self:addIntimacy(1, str)

			elseif r == 2 then
				val = val + 7
				str = "WHT你教这孩子" .. bookName[math.random(1,3)].. "，" .. sex .. "似乎一头雾水，并没有多少进展。"
				if inherit.morality < 100 then
					str = str .. "HIW德行 + " .. val .. "WHT"
				end
				str = self:addIntimacy(1, str)

			elseif r == 3 then
				val = val + 12
				str = "WHT你教这孩子" .. bookName[math.random(1,3)] .. "，" .. sex .. "频频点头，看来似乎领悟的不错。"
				if inherit.morality < 100 then
					str = str .. "HIW德行 + " .. val .. "WHT"
				end
				str = self:addIntimacy(1, str)

			elseif r == 4 then
				val = val + 13
				str = "WHT你教这孩子" .. bookName[math.random(1,3)] .. "，" .. sex .. "频频点头，看来似乎领悟的不错。"
				if inherit.morality < 100 then
					str = str .. "HIW德行 + " .. val .. "WHT"
				end
				str = self:addIntimacy(1, str)

			elseif r == 5 then
				val = val + 18
				str = "WHT你教这孩子" .. bookName[math.random(1,3)] .. "，" .. sex .. "举一反三，甚有天分。"
				if inherit.morality < 100 then
					str = str .. "HIW德行 + " .. val .. "WHT"
				end
				str = self:addIntimacy(2, str)

			elseif r == 6 then
				val = val + 19
				str = "WHT你教这孩子" .. bookName[math.random(1,3)] .. "，" .. sex .. "举一反三，甚有天分。"
				if inherit.morality < 100 then
					str = str .. "HIW德行 + " .. val .. "WHT"
				end
				str = self:addIntimacy(2, str)

			end
			inherit.addAttr = inherit.addAttr + val
			inherit.morality = inherit.morality + val
			if inherit.morality > 100 then
				inherit.morality = 100
			end
			inherit.endurance = inherit.endurance - 10
			User:addRoleAttr("jing", -10)
			RichPrint("main", str)

			-- 检测事件触发
			self:checkOpenEvent()
		else
			PopText("太累了，先休息下吧")
		end
	end)

	-- 练功
	self.Button_liangong:releaseFunc(function()
		Audio:playEffect("xiaoAnNiu")
		local inherit = User:getRoleAttr("inherit")
		if self:checkCanInherit() then
		 	PopText("你的继承人 " .. inherit.name .. " 在同辈中已经出类拔萃，无需过度培养了。")
		elseif User:getRoleAttr("jing") < 10 then
			PopText("精力不足")
		elseif inherit.endurance >= 10 then
			local r = math.random(1,6)
			local str = ""
			local sex = "它"
			if inherit.sex == "男" then
				sex = "他"
			elseif inherit.sex == "女" then
				sex = "她"
			end
			local wugongName =
			{
				[1] = "扎马步",
				[2] = "打坐",
				[3] = "些防身术",
			}
			local val = 0
			if inherit.sex == "男" then
				if inherit.type == 1 or inherit.type == 3 then
					val = val + 1
				end
			elseif inherit.sex == "女" then
				if inherit.type == 1 or inherit.type == 4 then
					val = val + 1
				end
			end

			-- 随机属性加成
			if r == 1 then
				val = val + 6
				str = "RED你教这孩子" .. wugongName[math.random(1,3)] .. "，" .. sex .. "似乎未得要领，并没有多少进展。"
				if inherit.physique < 100 then
					str = str .. "HIW体魄 + " .. val .. "RED"
				end
				str = self:addIntimacy(1, str)

			elseif r == 2 then
				val = val + 7
				str = "RED你教这孩子" .. wugongName[math.random(1,3)] .. "，" .. sex .. "似乎未得要领，并没有多少进展。"
				if inherit.physique < 100 then
					str = str .. "HIW体魄 + " .. val .. "RED"
				end
				str = self:addIntimacy(1, str)

			elseif r == 3 then
				val = val + 12
				str = "RED你教这孩子" .. wugongName[math.random(1,3)] .. "，" .. sex .. "学的有模有样，看来似乎领悟的不错。"
				if inherit.physique < 100 then
					str = str .. "HIW体魄 + " .. val .. "RED"
				end
				str = self:addIntimacy(1, str)

			elseif r == 4 then
				val = val + 13
				str = "RED你教这孩子" .. wugongName[math.random(1,3)] .. "，" .. sex .. "学的有模有样，看来似乎领悟的不错。"
				if inherit.physique < 100 then
					str = str .. "HIW体魄 + " .. val .. "RED"
				end
				str = self:addIntimacy(1, str)

			elseif r == 5 then
				val = val + 18
				str = "RED你教这孩子" .. wugongName[math.random(1,3)] .. "，" .. sex .. "颇有兴趣，进步很快。"
				if inherit.physique < 100 then
					str = str .. "HIW体魄 + " .. val .. "RED"
				end
				str = self:addIntimacy(2, str)

			elseif r == 6 then
				val = val + 19
				str = "RED你教这孩子" .. wugongName[math.random(1,3)] .. "，" .. sex .. "颇有兴趣，进步很快。"
				if inherit.physique < 100 then
					str = str .. "HIW体魄 + " .. val .. "RED"
				end
				str = self:addIntimacy(2, str)

			end
			inherit.addAttr = inherit.addAttr + val
			inherit.physique = inherit.physique + val
			if inherit.physique > 100 then
				inherit.physique = 100
			end
			inherit.endurance = inherit.endurance - 10
			User:addRoleAttr("jing", -10)
			RichPrint("main", str)

			-- 检测事件触发
			self:checkOpenEvent()
		else
			PopText("太累了，先休息下吧")
		end
	end)

	-- 奏乐
	self.Button_music:releaseFunc(function()
		Audio:playEffect("xiaoAnNiu")
		local inherit = User:getRoleAttr("inherit")
		if self:checkCanInherit() then
		 	PopText("你的继承人 " .. inherit.name .. " 在同辈中已经出类拔萃，无需过度培养了。")
		elseif User:getRoleAttr("jing") < 10 then
			PopText("精力不足")
		elseif inherit.endurance >= 10 then
			local r = math.random(1,6)
			local str = ""
			local sex = "它"
			if inherit.sex == "男" then
				sex = "他"
			elseif inherit.sex == "女" then
				sex = "她"
			end
			local musicName =
			{
				[1] = "《十面埋伏》",
				[2] = "《高山流水》",
				[3] = "《侠客江湖旅》",
			}
			local val = 0
			if inherit.sex == "男" then
			elseif inherit.sex == "女" then
				if inherit.type == 2 or inherit.type == 3 then
					val = val + 1
				end
			end

			-- 随机属性加成
			if r == 1 then
				val = val + 6
				str = "你教这孩子演奏一曲" .. musicName[math.random(1,3)] .. "，" .. sex .. "看起来无甚乐感，一直发出刺耳的杂音。"
				if inherit.temperament < 100 then
					str = str .. "HIW气质 + " .. val .. "NOR"
				end
				str = self:addIntimacy(1, str)

			elseif r == 2 then
				val = val + 7
				str = "你教这孩子演奏一曲" .. musicName[math.random(1,3)] .. "，" .. sex .. "看起来无甚乐感，一直发出刺耳的杂音。"
				if inherit.temperament < 100 then
					str = str .. "HIW气质 + " .. val .. "NOR"
				end
				str = self:addIntimacy(1, str)

			elseif r == 3 then
				val = val + 12
				str = "你教这孩子演奏一曲" .. musicName[math.random(1,3)] .. "，" .. sex .. "看起来领悟得不错，偶尔能演奏一段完整的曲子。"
				if inherit.temperament < 100 then
					str = str .. "HIW气质 + " .. val .. "NOR"
				end
				str = self:addIntimacy(1, str)

			elseif r == 4 then
				val = val + 13
				str = "你教这孩子演奏一曲" .. musicName[math.random(1,3)] .. "，" .. sex .. "看起来领悟得不错，偶尔能演奏一段完整的曲子。"
				if inherit.temperament < 100 then
					str = str .. "HIW气质 + " .. val .. "NOR"
				end
				str = self:addIntimacy(1, str)

			elseif r == 5 then
				val = val + 18
				str = "你教这孩子演奏一曲" .. musicName[math.random(1,3)] .. "，" .. sex .. "学得很快，不一会便能演奏完整的曲子了。"
				if inherit.temperament < 100 then
					str = str .. "HIW气质 + " .. val .. "NOR"
				end
				str = self:addIntimacy(2, str)

			elseif r == 6 then
				val = val + 19
				str = "你教这孩子演奏一曲" .. musicName[math.random(1,3)] .. "，" .. sex .. "学得很快，不一会便能演奏完整的曲子了。"
				if inherit.temperament < 100 then
					str = str .. "HIW气质 + " .. val .. "NOR"
				end
				str = self:addIntimacy(2, str)

			end
			inherit.addAttr = inherit.addAttr + val
			inherit.temperament = inherit.temperament + val
			if inherit.temperament > 100 then
				inherit.temperament = 100
			end
			inherit.endurance = inherit.endurance - 10
			User:addRoleAttr("jing", -10)
			RichPrint("main", str)

			-- 检测事件触发
			self:checkOpenEvent()
		else
			PopText("太累了，先休息下吧")
		end
	end)

	-- 下棋
	self.Button_chess:releaseFunc(function()
		Audio:playEffect("xiaoAnNiu")
		local inherit = User:getRoleAttr("inherit")
		if self:checkCanInherit() then
		 	PopText("你的继承人 " .. inherit.name .. " 在同辈中已经出类拔萃，无需过度培养了。")
		elseif User:getRoleAttr("jing") < 10 then
			PopText("精力不足")
		elseif inherit.endurance >= 10 then
			local r = math.random(1,6)
			local str = ""
			local sex = "它"
			if inherit.sex == "男" then
				sex = "他"
			elseif inherit.sex == "女" then
				sex = "她"
			end
			local val = 0
			if inherit.sex == "男" then
				if inherit.type == 2 then
					val = val + 2
				elseif inherit.type == 3 then
					val = val + 1
				end
			elseif inherit.sex == "女" then
				if inherit.type == 4 then
					val = val + 1
				end
			end

			-- 随机属性加成
			if r == 1 then
				val = val + 6
				str = "DEO你教这孩子下棋，" .. sex .. "看起来无甚兴趣，直打哈欠。"
				if inherit.noema < 100 then
					str = str .. "HIW心智 + " .. val .. "DEO"
				end
				str = self:addIntimacy(1, str)

			elseif r == 2 then
				val = val + 7
				str = "DEO你教这孩子下棋，" .. sex .. "看起来无甚兴趣，直打哈欠。"
				if inherit.noema < 100 then
					str = str .. "HIW心智 + " .. val .. "DEO"
				end
				str = self:addIntimacy(1, str)

			elseif r == 3 then
				val = val + 12
				str = "DEO你教这孩子下棋，" .. sex .. "看起来领悟得不错，落子有模有样。"
				if inherit.noema < 100 then
					str = str .. "HIW心智 + " .. val .. "DEO"
				end
				str = self:addIntimacy(1, str)

			elseif r == 4 then
				val = val + 13
				str = "DEO你教这孩子下棋，" .. sex .. "看起来领悟得不错，落子有模有样。"
				if inherit.noema < 100 then
					str = str .. "HIW心智 + " .. val .. "DEO"
				end
				str = self:addIntimacy(1, str)

			elseif r == 5 then
				val = val + 18
				str = "DEO你教这孩子下棋，" .. sex .. "似乎饶有兴致，落子颇有见解，常能出其不意。"
				if inherit.noema < 100 then
					str = str .. "HIW心智 + " .. val .. "DEO"
				end
				str = self:addIntimacy(2, str)

			elseif r == 6 then
				val = val + 19
				str = "DEO你教这孩子下棋，" .. sex .. "似乎饶有兴致，落子颇有见解，常能出其不意。"
				if inherit.noema < 100 then
					str = str .. "HIW心智 + " .. val .. "DEO"
				end
				str = self:addIntimacy(2, str)

			end
			inherit.addAttr = inherit.addAttr + val
			inherit.noema = inherit.noema + val
			if inherit.noema > 100 then
				inherit.noema = 100
			end
			inherit.endurance = inherit.endurance - 10
			User:addRoleAttr("jing", -10)
			RichPrint("main", str)

			-- 检测事件触发
			self:checkOpenEvent()
		else
			PopText("太累了，先休息下吧")
		end
	end)

	self.Button_1:releaseFunc(function()
		Audio:playEffect("xiaoAnNiu")
		local flag = self:checkCanInherit()
		if flag then
			-- 判断神兵在不在身上
			-- local shenBingweapon = User:getRoleAttr("shenBingweapon")
			-- if shenBingweapon.status == "1" or (shenBingweapon.status == "2" and User:getRole():getItemCount("神兵") <= 0) then
			-- 	PopText("先把神兵找回来吧！")
			-- 	return
			-- end
			-- 完成剧情直接进入传承确认界面
			if User:getRoleAttr("inherit").isFinish then
				PopupLayerController:showLayer("InheritConfirmLayer", function(layer)
					layer:show()
					layer:showDesc()	
				end)
				return
			end

			-- 进入传承剧情
			local TeacherAnimationLayer = require("app.views.layer.TeacherLayer.TeacherAnimationLayer")
			local teacherAnimationLayer = TeacherAnimationLayer:getInstance()
			teacherAnimationLayer:setVisible(false)

			local role = User:getRole():createInheritRole()
			local text =
			{
				[1] =
				{
					[1] = "六年来，",
					[2] = role:getAttr("name") .. "一直跟在你身边学艺，",
					[3] = "耳濡目染你的行事作风，",
					[4] = "你觉得" .. role:getAttr("name") .. "现在已经较为符合你继承人的标准了，",
					[5] = "只是近日" .. role:getAttr("name") .. "得知".. role:getHeOrHer(role:getAttr("sex")) .. "的父母实为死于幽冥教之手，",
					[6] = "于是便四处打探仇人的藏身之处。",
					[7] = "这天，",
					[8] = role:getAttr("name") .. "终于找到了他仇人的所在。",
				},
				[2] =
				{
					[1] = "六年来，",
					[2] = role:getAttr("name") .. "一直跟在你身边学艺，",
					[3] = "耳濡目染你的行事作风，",
					[4] = "你觉得" .. role:getAttr("name") .. "现在已经较为符合你继承人的标准了，",
					[5] = "只是近日" .. role:getAttr("name") .. "得知" .. role:getHeOrHer(role:getAttr("sex")) .. "的父母实为死于幽冥教之手，",
					[6] = "练功变得急于求成。",
					[7] = "这天终于在打坐运功时走火入魔。",
				},
				[3] =
				{
					[1] = "六年来，",
					[2] = role:getAttr("name") .. "一直跟在你身边学艺，",
					[3] = "耳濡目染你的行事作风，",
					[4] = "你觉得" .. role:getAttr("name") .. "现在已经较为符合你继承人的标准了，",
					[5] = "只是近日" .. role:getAttr("name") .. "得知" .. role:getHeOrHer(role:getAttr("sex")) .. "的父母实为死于幽冥教之手，",
					[6] = "练功变得急于求成。",
					[7] = "这天，",
					[8] = "终于在打坐运功时走火入魔。",
				},
			}
			local zhengqi =  User:getRoleAttr("inherit").zhengqi
			local mapRoom, index
			if zhengqi >= -18 and zhengqi <= -10 then
				index = 1
				mapRoom = "fb01_40"
			elseif zhengqi >= -9 and zhengqi <= 9 then
				index = 2
				mapRoom = "fb01_41"
			elseif zhengqi >= 10 and zhengqi <= 18 then
				index = 3
				mapRoom = "fb01_42"
			end
			teacherAnimationLayer:createTextFromArray(text[index])
			teacherAnimationLayer:show(
				function()

					local map = User:getRole():getMapByIndex(1)
					local maplayer = MainControllLayer:getLayer("MapLayer")
					MainControllLayer:pushLayer("MapLayer")

					maplayer:setMap(map)
					maplayer:replaceRoom(mapRoom)
					maplayer:setTotalMapHide()
					MessageCenter:notify("EnterMap",{map=map})
					

					-- local titleLayer = MainControllLayer:getLayer("TitleLayer")
					-- titleLayer:hide(true)

					local InheritMapRoleLayer = MainControllLayer:getLayer("InheritMapRoleLayer")
					InheritMapRoleLayer:onResume()
					InheritMapRoleLayer:show(role)
					InheritMapRoleLayer:maxZ()

					local layer = MainControllLayer:getLayer("PrintLayer")
					layer:show(true)
					layer:setLocalZOrder(10)
				end)
		else
			local inherit = User:getRoleAttr("inherit")
			if inherit.physique < inherit.physiqueMax or inherit.noema < inherit.noemaMax or inherit.morality < inherit.moralityMax or inherit.temperament < inherit.temperamentMax then
				PopText("你的继承人各方面还不成熟，无法完成传承的大任")
			elseif inherit.intimacy < 37 then
				PopText("这孩子对你们的关系似乎仍有所保留")
			end
		end
	end)
end

function InheritAttrLayer:update(ft)
	self:recovery()
	self:refreshUI()
end

function InheritAttrLayer:refreshUI()
	local inherit = User:getRoleAttr("inherit")

	self:setSex(inherit.sex)
	self:setName(inherit.name)
	self:setEndurance(inherit.endurance, inherit.enduranceMax)
	self:setPhysique(inherit.physique, inherit.physiqueMax)
	self:setNoema(inherit.noema, inherit.noemaMax)
	self:setMorality(inherit.morality, inherit.moralityMax)
	self:setTemperament(inherit.temperament, inherit.temperamentMax)
	self:setAge()
	self:setDesc()
	self:setIntimacyDesc()
	self:setJing(User:getRoleAttr("jing"), User:getRole():getJingMax())
end

-- 更换头像
function InheritAttrLayer:setHeadImg()
	local inherit = User:getRoleAttr("inherit")

	if inherit.sex == "男" then
		if inherit.type == 1 then
			self.Image_head:loadTexture(Resource:getImgPath("nan_head32"))
		elseif inherit.type == 2 then
			self.Image_head:loadTexture(Resource:getImgPath("nan_head33"))
		elseif inherit.type == 3 then
			self.Image_head:loadTexture(Resource:getImgPath("nan_head34"))
		elseif inherit.type == 4 then
			self.Image_head:loadTexture(Resource:getImgPath("nan_head35"))
		end
	elseif inherit.sex == "女" then
		if inherit.type == 1 then
			self.Image_head:loadTexture(Resource:getImgPath("nv_head32"))
		elseif inherit.type == 2 then
			self.Image_head:loadTexture(Resource:getImgPath("nv_head33"))
		elseif inherit.type == 3 then
			self.Image_head:loadTexture(Resource:getImgPath("nv_head34"))
		elseif inherit.type == 4 then
			self.Image_head:loadTexture(Resource:getImgPath("nv_head35"))
		end
	end
end

-- 孤儿描述
function InheritAttrLayer:setDesc()
	local inherit = User:getRoleAttr("inherit")

	if inherit.sex == "男" then
		if inherit.type == 1 then
			self.Text_character:setString("【性格】憨厚")
			self.Text_hobby:setString("【爱好】吃")
		elseif inherit.type == 2 then
			self.Text_character:setString("【性格】孤僻")
			self.Text_hobby:setString("【爱好】不详")
		elseif inherit.type == 3 then
			self.Text_character:setString("【性格】活泼")
			self.Text_hobby:setString("【爱好】恶作剧")
		elseif inherit.type == 4 then
			self.Text_character:setString("【性格】内敛")
			self.Text_hobby:setString("【爱好】读书")
		end
	elseif inherit.sex == "女" then
		if inherit.type == 1 then
			self.Text_character:setString("【性格】活泼")
			self.Text_hobby:setString("【爱好】帮助他人")
		elseif inherit.type == 2 then
			self.Text_character:setString("【性格】内敛")
			self.Text_hobby:setString("【爱好】音律")
		elseif inherit.type == 3 then
			self.Text_character:setString("【性格】腼腆")
			self.Text_hobby:setString("【爱好】刺绣")
		elseif inherit.type == 4 then
			self.Text_character:setString("【性格】好强")
			self.Text_hobby:setString("【爱好】当孩子王")
		end
	end

	if self.descText ~= inherit.desc then
		self.descText = inherit.desc
		self:initRichText()

		local textColor = cc.c3b(208, 208, 208)
   		 self.rich_text:pushBackText(self.descText, textColor, 255, Resource:getFontPath("default"), 36)
	end

	if self:checkCanInherit() then
		self.Text_state:setColor({r = 51, g = 153, b = 51})
		self.Text_state:setString("可传承")
	else
		self.Text_state:setColor({r = 219, g = 57, b = 57})
		self.Text_state:setString("不可传承")
	end
end

-- 检测事件能否开启
function InheritAttrLayer:checkOpenEvent()
	local inherit = User:getRoleAttr("inherit")
	local n = math.ceil(inherit.intimacy / 4)
	if n == 0 then
		n = 1
	end
	if n > inherit.eventCount then
		PopupLayerController:showLayer("InheritEventLayer", function(layer)
			layer:setText(inherit.eventCount)
			layer:show()
		end)
	end
end

-- 增加亲密度
function InheritAttrLayer:addIntimacy(intimacy, str)
	local inherit = User:getRoleAttr("inherit")
	if inherit.physique < inherit.physiqueMax or inherit.noema < inherit.noemaMax or inherit.morality < inherit.moralityMax or inherit.temperament < inherit.temperamentMax then
	else
		intimacy = 2
	end
	if intimacy == 1 then
		str = str .. " 你们的关系似乎变得亲近了一些。"
	elseif intimacy == 2 then
		str = str .. " 你们的关系似乎有了显著的改变。"
	end
	inherit.intimacy = inherit.intimacy + intimacy
	if inherit.intimacy < 0 then
		inherit.intimacy = 0
	elseif inherit.intimacy > 37 then
		inherit.intimacy = 37
	end

	return str
end

-- 设置亲密度描述
function InheritAttrLayer:setIntimacyDesc()
	local desc =
	{
		"不理不睬",
		"爱答不理",
		"平淡无奇",
		"若即若离",
		"和睦相处",
		"相得甚欢",
		"形影不离",
		"推心置腹",
		"休戚与共",
		"情同骨肉",
	}
	local inherit = User:getRoleAttr("inherit")
	local n = math.ceil(inherit.intimacy / 4)
	if n == 0 then
		n = 1
	end
	self.Text_intimacy:setString("【亲近度】" .. desc[n])
end

-- 计算年龄
function InheritAttrLayer:setAge()
	local inherit = User:getRoleAttr("inherit")
	local age = math.floor(inherit.addAttr/65) + 8
	if age > 14 then
		age = 14
	end
	self.Text_age:setString("【年龄】" .. Helper:numberCast(age) .. "岁")
end

--计算疲劳恢复
function InheritAttrLayer:recovery()
	local inherit = User:getRoleAttr("inherit")
	local currTime = GetTime()
	local role = User:getRole()
	local startTime = role:getFlag("传承疲劳值恢复时间")

	if startTime == 0 then
		startTime = currTime
		role:setFlag("传承疲劳值恢复时间", currTime)
	end

	local intervalTime = currTime - startTime
	local interval = 720

	if intervalTime > interval then
		inherit.endurance = inherit.endurance +  math.floor(intervalTime/interval)

		if inherit.endurance >= inherit.enduranceMax then
			--疲劳值已满
			inherit.endurance = inherit.enduranceMax
			role:setFlag("传承疲劳值恢复时间", currTime)
		else
			--当前时间减去不足720秒的剩余时间
			role:setFlag("传承疲劳值恢复时间", currTime - ( (intervalTime/interval) - math.floor(intervalTime/interval) ) )
		end
	end
end

		-- physique = 0,			-- 体魄
		-- physiqueMax = 100,		-- 体魄最大值
		-- noema = 0,				-- 心智
		-- noemaMax = 100,			-- 心智最大值
		-- morality = 0,			-- 德行
		-- moralityMax = 100,		-- 德行最大值
		-- temperament = 0,			-- 气质
		-- temperamentMax = 100,	-- 气质最大值
--姓名
function InheritAttrLayer:setName(name)
	self.Text_name:setString("【继承人】" .. name)
end

--性别
function InheritAttrLayer:setSex(sex)
	self.Text_sex:setString("【性别】" .. sex)
end

--疲劳
function InheritAttrLayer:setEndurance(endurance, enduranceMax)
	self.Text_endurance:setString("【疲   劳】" .. endurance .. "/" .. enduranceMax)
end

--体魄
function InheritAttrLayer:setPhysique(physique, physiqueMax)
	self.Text_physique:setString("【体魄】" .. physique .. "/" .. physiqueMax)
end

--心智
function InheritAttrLayer:setNoema(noema, noemaMax)
	self.Text_noema:setString("【心智】" .. noema .. "/" .. noemaMax)
end

--德行
function InheritAttrLayer:setMorality(morality, moralityMax)
	self.Text_morality:setString("【德行】" .. morality .. "/" .. moralityMax)
end

--气质
function InheritAttrLayer:setTemperament(temperament, temperamentMax)
	self.Text_temperament:setString("【气质】" .. temperament .. "/" .. temperamentMax)
end

-- 精力
function InheritAttrLayer:setJing(jing, jingMax)
	self.Text_jing:setString("『精力』" .. math.floor(jing) .. "/" .. math.floor(jingMax))
end

Helper:classDefNodeGetInstance(InheritAttrLayer)

return InheritAttrLayer0000000000