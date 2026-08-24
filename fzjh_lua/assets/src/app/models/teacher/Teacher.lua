local Family = require("app.models.family.Family")

local Teacher = 
{
	selectTeachers = -- 门派选择结构
	{
		-- {
		-- 	type = "门派类型",
		-- 	name = "名门正派",
		-- 	nameColor = cc.c4b(58, 222, 91, 255),
		-- 	dsc = "替天行道，\n正气长存。",
		-- 	familys = 
		-- 	{
		-- 		-- {path = ""},
		-- 		-- {path = ""},
		-- 		-- {path = ""},
		-- 		-- {path = ""}
		-- 	}
		-- },
		-- {
		-- 	type = "门派类型",
		-- 	name = "江湖邪派",
		-- 	nameColor = cc.c4b(231, 54, 57, 255),
		-- 	dsc = "天下武林，\n唯我独尊。",
		-- 	familys = 
		-- 	{
		-- 		-- {path = ""},
		-- 		-- {path = ""}
		-- 	}
		-- },
		-- {
		-- 	type = "门派类型",
		-- 	name = "中立门派",
		-- 	nameColor = cc.c4b(218, 187, 59, 255),
		-- 	dsc = "美酒武功，\n我自逍遥。",
		-- 	familys = 
		-- 	{
		-- 		-- {path = ""},
		-- 		-- {path = ""}
		-- 	}
		-- }
	}
}

function Teacher:getSelectTeachers()
	return self.selectTeachers
end

function Teacher:initTeachers()
	local dataList = require("script.family.family")
	if not dataList["门派类型"] then
		if PRINT_MODE == 1 then
			print("门派类型初始化失败")
		end
		return
	end

	for k,data in pairs(dataList["门派类型"]) do
		data.type = "门派类型"
		data.familys = self:initFamilys(data.familys, data.nameColor)
		table.insert(self.selectTeachers, data)
	end
end

function Teacher:initFamilys(familys, nameColor)
	if not familys or type(familys) ~= "string" then
		return 
	end
	if PRINT_MODE == 1 then
		print("familys = "..tostring(familys))
	end
	local list = string.split(familys, ";")
	local rList = {}
	for i,v in ipairs(list) do
		local family = Family:getFamily(v)
		family.type = "门派"
		family.nameColor = nameColor
		table.insert(rList, family)
	end
	return rList
end

Teacher:initTeachers()

function Teacher:getFamilys(name)
	if not name then
		return nil
	end
	local menPai = self:getSelectTeachers()
	for k,v in pairs(menPai) do
		if v.name == name then
			return v.familys
		end
	end
	return nil
end

local salesList = {
    ["liuxiran"] = true,
    ["huayan"] = true,
    ["xuqianmo"] = true,
    ["hemingqing"] = true,
    ["gaochang"] = true,
    ["qinji"] = true,
    ["xiaoyan"] = true,
    ["zhongque"] = true,
    ["yuzhen"] = true,
    ["mingchangge"] = true,
    ["xumi"] = true,
    ["luoqiansang"] = true,
    ["qinhongyan"] = true,
    ["moli"] = true,
    ["sufu"] = true,
    ["duyan"] = true,
    ["murongjie"] = true,
    ["quandayou"] = true,
    ["tangshiba"] = true,
    ["yanfeng"] = true,
    ["shilong"] = true,
    ["qinming"] = true,
    ["miaoyan"] = true,
    ["jiangyi"] = true,
    ["liboyong"] = true,
    ["heishishangren"] = true,
	["xiu"] = true,
	["yaobuyi"] = true,
}
function Teacher:getTeacherSalers()
	return salesList
end

return Teacher0000000000000000