local DataBase = require("app.DataBase")
local User = require("app.models.user.User")

--记录角色属性变化值
local UserDataUpload =
{
}

--从Role 中获取属性变化表，为nil时创建空表
function UserDataUpload:getAttrChanges(role)
	local player = User:getRole()
	if player == nil then
		return nil
	end
	-- 判断是否为玩家角色
	if player.onlyId ~= role.onlyId then
		return nil
	end

	if role.attrChanges == nil then
		role.attrChanges = {}
	end
	return role.attrChanges
end

--添加数据变化值
function UserDataUpload:insertData(role, name, value)
	local attrChanges = self:getAttrChanges(role)
	if attrChanges == nil then
		return
	end

	local function lazyInit(name)
		if attrChanges[name] == nil then
			attrChanges[name] =
			{
				add = 0,
				sub = 0
			}
		end
		return attrChanges[name]
	end
	local tb = lazyInit(name)

	if value > 0 then
		tb.add = tb.add + value
	elseif value < 0 then
		tb.sub = tb.sub + value
	else
	end
end

function UserDataUpload:setData(role, name, value)
	if role == nil then
		return
	end

	local originValue = role:getAttr(name)
	if originValue == nil then
		originValue = 0
	end

	if type(value) ~= "number" then
		return
	end
	local v = value - originValue

	self:insertData(role, name, v)
end

return UserDataUpload0000