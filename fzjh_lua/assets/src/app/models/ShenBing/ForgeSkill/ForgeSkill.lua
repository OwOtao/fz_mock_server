local ForgeSkill = {}
local godweapon = require("script.others.godweapon")
local poison = require("script.others.poison")
local poisonformula = require("script.others.poisonformula")
local IS_NEW_AAAA = true

function ForgeSkill:getForgeKnowledge(bookId)
	for k,book in pairs(godweapon["forgeKnowledges"]) do 
		if book.atlasid == bookId then
			return string.split(book.atlasknowledge,";")
		end
	end
	return nil
end


-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2018/01/09 14:47:36
-- @desc 初始化锻造配方
function ForgeSkill:initForgeKnowledge()
	local ForgeKnowledge = {}
	assert(godweapon and godweapon["forgeKnowledges"],type(godweapon)..","..type(godweapon["forgeKnowledges"]))
	for k,book in pairs(godweapon["forgeKnowledges"]) do 
		if type(book) == "table" then
			if type(book.atlasid) == "string" and type(book.atlasknowledge) == "string" then
				-- ForgeKnowledge[book.atlasid] = 
				local knowledgeTab = clone(book)
				knowledgeTab.atlasknowledge = string.split(knowledgeTab.atlasknowledge,";")
				ForgeKnowledge[book.atlasid] = knowledgeTab

				if IS_NEW_AAAA == true then
					local list = string.split(knowledgeTab.level, ";")
					if #list ~= #knowledgeTab.atlasknowledge then
						assert(nil, "表格填写错误，请检查锻造配方表中，知识以及对应解锁等级数量填写不一致。 图谱ID: "..tostring(book.atlasid))
					end

				 	knowledgeTab.zhishiAndLevel = Helper:getDef(knowledgeTab.zhishiAndLevel, {})
					for i,v in ipairs(knowledgeTab.atlasknowledge) do
						knowledgeTab.zhishiAndLevel[v] = list[i]	
					end
					ForgeKnowledge[book.atlasid] = knowledgeTab
				end
			end
		end
	end
	return ForgeKnowledge
end

local pfSkill = {}
-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2018/01/09 14:58:41
-- @desc 获取玩家已经学习的锻造知识
function ForgeSkill:getUserFoegeKnowledge()
	return pfSkill
end



local unpfSkill = {} -- 未解锁知识技艺列表


-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2018/01/26 21:35:21
-- @desc 获取未解锁的锻造知识
function ForgeSkill:getUserForgeUnLearnKnowledge()
	return unpfSkill
end

-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2018/01/26 00:58:30
-- @desc 判断书籍的等级是否达到解锁条件
function ForgeSkill:checkCanGetFoegeKnowledge(currLv,afterLv,skillId)
	if afterLv == currLv then
		return
	end
	local forgeSkill = self:getFoegeKnowledgeInfo()[skillId]
	-- add by XiaoZhiWei 2018/07/04 08:58:30 做一个结果检查
	if MapIsEmpty(forgeSkill) == true then
		return
	end
	if IS_NEW_AAAA == true then
		local list = unpfSkill[skillId]
		--@desc 列表为空的情况
		if not list then
			return
		end
		pfSkill[skillId] = Helper:getDef(pfSkill[skillId], {})
		local needLog = false
		for i = #list, 1, -1 do
			local v = list[i]
			if currLv < tonumber(forgeSkill.zhishiAndLevel[v]) and afterLv >= tonumber(forgeSkill.zhishiAndLevel[v]) then
				table.insert(pfSkill[skillId], v)
				table.remove(unpfSkill[skillId], i)
				-- 提示信息应该要发生改变
				needLog = true
			end
		end
		if needLog == true then
			str = "HIC经过你的不懈努力，你对"..forgeSkill.atlasname.."图谱所记载的知识了解得更深了，你获得了其中的新技艺。"
			RichPrint("main",str)
		end

	else
		if currLv < tonumber(forgeSkill.level) and afterLv >= tonumber(forgeSkill.level) then
			pfSkill[skillId] = forgeSkill.atlasknowledge
			str = "HIC经过你的不懈努力，你对"..forgeSkill.atlasname.."图谱所记载的知识了解得更深了，你获得了其中的新技艺。"
			RichPrint("main",str)
		end
	end
end

-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2018/01/10 10:28:27
-- @desc 生成玩家已经学习的锻造知识
function ForgeSkill:initUserFoegeKnowledge()
	local role = User:getRole()
	local forgeSkill = self:getFoegeKnowledgeInfo()
	local literaryBox = role:getAttr("literaryBox")
	if MapIsEmpty(literaryBox) == false then
		for k,book in ipairs(literaryBox) do 
			local itemAttr = role:getOneItemByKey(book.itemId)
			if itemAttr ~= nil and itemAttr.type == "锻造图谱" then
				assert(forgeSkill[book.itemId])
				local currLv = role:getLiteraryLv(book.itemId)
				unpfSkill[book.itemId] = Helper:getDef(unpfSkill[book.itemId], {})

				if IS_NEW_AAAA == true then
					-- 初始化解锁和未解锁知识技艺表
					for k,v in pairs(forgeSkill[book.itemId].atlasknowledge) do
						local zhishilevel = forgeSkill[book.itemId]["zhishiAndLevel"][v]
						if currLv >= tonumber(zhishilevel) then
							pfSkill[book.itemId] = Helper:getDef(pfSkill[book.itemId], {})
							table.insert(pfSkill[book.itemId], v)
						else
							table.insert(unpfSkill[book.itemId], v)
						end
					end
				else
					if currLv >= tonumber(forgeSkill[book.itemId].level) then
						pfSkill[book.itemId] = forgeSkill[book.itemId].atlasknowledge
					end
				end
			end
		end
	end

	-- print("-----------------------------------------------")
	-- Helper:print_lua_table(pfSkill)
	-- print("------------------------------------------------")
	-- Helper:print_lua_table(unpfSkill)
	-- -- return pfSkill
end

-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2018/01/10 10:35:29
-- @desc 新学习锻造知识
function ForgeSkill:addUserFoegeKnowledge(bookId)
	local forgeSkill = self:getFoegeKnowledgeInfo()
	if unpfSkill[bookId] == nil then
		unpfSkill[bookId] = forgeSkill[bookId].atlasknowledge
		pfSkill[bookId] = {}
	end


	local list = unpfSkill[bookId]





	pfSkill[bookId] = Helper:getDef(pfSkill[bookId], {})

	if IS_NEW_AAAA == true then
		local needLog = false
		for i = #list, 1, -1 do
			local v = list[i]
			if 1 == tonumber(forgeSkill[bookId].zhishiAndLevel[v]) then
				table.insert(pfSkill[bookId], v)
				table.remove(unpfSkill[bookId], i)
				-- 提示信息应该要发生改变
				needLog = true
			end
		end
		if needLog == true then
			local str = "HIC经过你的不懈努力，你对"..forgeSkill[bookId].atlasname.."图谱所记载的知识了解得更深了，你获得了其中的新技艺。"
			RichPrint("main",str)
		end
	else
		if forgeSkill[bookId].level == 1 then
			pfSkill[bookId] = forgeSkill[bookId].atlasknowledge
			local str = "HIC经过你的不懈努力，你对"..forgeSkill[bookId].atlasname.."图谱所记载的知识了解得更深了，你获得了其中的新技艺。"
			RichPrint("main",str)
		end
	end
end
-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2018/01/09 15:00:30
-- @desc 从本地读取锻造知识配置表
function ForgeSkill:getFoegeKnowledgeInfo()
	local forgeSkill = DataBase:getLuaTable("ForgeSkill")
	if forgeSkill == nil then
		forgeSkill = {}
	end
	return Helper:getDef(forgeSkill.forge,{})
end



-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2018/01/09 14:58:14
-- @desc 初始化
function ForgeSkill:init()
	local ForgeKnowledge = self:initForgeKnowledge()
	local tab = {
		forge = ForgeKnowledge,
	}
	DataBase:setLuaTable("ForgeSkill",tab)	
    ForgeSkill:initUserFoegeKnowledge() 
end


function ForgeSkill:clear( )
	pfSkill = {}
	unpfSkill = {}
end
return ForgeSkill00000