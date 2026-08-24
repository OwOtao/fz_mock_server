local InheritLayer = class("InheritLayer", cc.Layer)

function InheritLayer:create()
	local p = InheritLayer:new()
	p:init()
	return p
end

function InheritLayer:init()
	self._UI = require("Layer/InheritUI/InheritUI.lua").create()['root']
	self._UI:addTo(self)

	Helper:convertUIByParent(self)
end

function InheritLayer:showDesc()
	self.Button_1:setVisible(User:getRoleAttr("isHaveOrphan"))
	if User:getRoleAttr("isHaveOrphan") then
		if User:getRoleAttr("inherit").isSetSex==false then
			self:setInheritSex()
		elseif User:getRoleAttr("inherit").isSetName==false then 
			self:setInheritName()
		end
	else
		local role = User:getRole()
		local count = role:getAttr("inheritCount")
		local lv = role:GetInheritNeedExpLv()
		if count == 0 then
			self.Text_desc:setString("少林寺的小和尚似乎有事找你，去看一看吧。")
		elseif count >= 1 then
			self.Text_desc:setString("幽冥教在牛家村孤家集草菅人命，还望少侠能主持公道，牛家村的张大牛可以带你去孤家集。")
		end
	end
end

function InheritLayer:setInheritName()
	local he = User:getRole():getHeOrHer(User:getRoleAttr("inherit").sex)
	self.Text_desc:setString("孩子对你感恩戴德，将你视为恩人。经询问得知，" .. he .. "尚未取名，" .. "你打算给"..he.."起一个名字。")
	self:setButton("setName")
end

function InheritLayer:setInheritSex()
	self.Text_desc:setString("你把孩子带回家，给其治伤、沐浴，发现这孩子原来是一个")
	self:setButton("setSex")
end

function InheritLayer:setButton(type)
	local btnType=type or "setSex"
	if btnType=="setName" then 
		self.Button_1:setVisible(true)
		self.Button_2:setVisible(false)

		self.Button_1.Text_button_1_Name:setString("取名")
		self.Button_1:loadTextureNormal("Image/UI/TaskUI/anniu.png",0)
		self.Button_1:releaseFunc(
			function()
				PopupLayerController:showLayer("InheritSetNameLayer", function(layer)
					layer:setInheritLayer(self)
					layer:show()
				end)
			end)

	elseif btnType=="setSex" then
		self.Button_1:setVisible(true)
		self.Button_2:setVisible(true)
		self.Button_1:loadTextureNormal("Image/UI/MapUI/anniu08.png",0)
		self.Button_2:loadTextureNormal("Image/UI/MapUI/anniulan.png",0)
		self.Button_1:setSize({width = 324, height = 118})
		self.Button_2:setSize({width = 324, height = 118})

		self.Button_2.Text_button_2_Name:setString("男孩")
		self.Button_2:releaseFunc(
			function()
				User:getRoleAttr("inherit").isSetSex=true
				User:getRoleAttr("inherit").sex="男"
				if User:getRoleAttr("sex")=="女" then 
					local inheritDesc=User:getRoleAttr("inherit").desc
					inheritDesc = string.gsub(inheritDesc, "她", "他")
					User:getRoleAttr("inherit").desc=inheritDesc
				end
				self:setInheritName()
			end)

		self.Button_1.Text_button_1_Name:setString("女孩")
		self.Button_1:releaseFunc(
			function()
				User:getRoleAttr("inherit").isSetSex=true
				User:getRoleAttr("inherit").sex="女"
				if User:getRoleAttr("sex")=="男" then 
					local inheritDesc=User:getRoleAttr("inherit").desc
					inheritDesc = string.gsub(inheritDesc, "他", "她")
					User:getRoleAttr("inherit").desc=inheritDesc
				end
				self:setInheritName()
			end)
	end

end

Helper:classDefNodeGetInstance(InheritLayer)

return InheritLayer0000000000000