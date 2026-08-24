local User = require("app.models.user.User")

local Role = require("app.models.role.Role")

local BaseNpc = 
{
	name = "神秘人",

	isNpc = true,
	
	skillList =
	{
		-- taijishengong =
		-- {
		-- 	id = "taijishengong",
		-- 	exp = 1000
		-- }
	},
	skillPrepare = -- 准备中的技能
	{
	},
	apprenticeCondition = 	--拜师条件
	{
		-- {
		-- 	type = "技能",
		-- 	name = "hamagong",
		-- 	cond = "大于",
		-- 	value = 100,
		-- 	failed = "我不收你为徒"
		-- },
		-- {}
	}, 
}

function BaseNpc:create()
	local p = Helper:tableCover(Role:create(), BaseNpc)
	p.onlyId = Helper:getOnlyId()
	return p
end

-- 暂时只有一个功能，死亡后重置相貌
function BaseNpc:dead()
	-- 死亡后重置相貌
end

return BaseNpc000000000000000