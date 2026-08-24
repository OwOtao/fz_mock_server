local EditorNpc = {}

-----------------------------------------------------------------------------------------------------------
-- @author ZhangShengTang
-- @time 2018/01/12 15:10:57
-- @desc 初始化技能
function EditorNpc:initSkills(npc)
    local prepare = {
        quanjiao1 = npc.quanjiao1 == nil and "jibenquanjiao" or npc.quanjiao1,
        quanjiao2 = npc.quanjiao2,
        neigong = npc.neigong == nil and "jibenneigong" or npc.neigong,
        qinggong = npc.qinggong == nil and "jibenqinggong" or npc.qinggong,
        zhaojia = npc.zhaojia == nil and "jibenzhaojia" or npc.zhaojia,
        jianfa = npc.jianfa == nil and "jibenjianfa" or npc.jianfa,
        daofa = npc.daofa == nil and "jibendaofa" or npc.daofa,
        gunfa = npc.gunfa == nil and "jibengunfa" or npc.gunfa,
        anqi = npc.anqi == nil and "jibenanqi" or npc.anqi,
        shuangchi = npc.shuangchi == nil and "jibenshuangchi" or npc.shuangchi,
        qinfa = npc.qinfa == nil and "jibenqinfa" or npc.qinfa
    }
    npc.skillPrepare = prepare

    local skills = {}
    --  初始化武功等级
    for k, skillId in pairs(prepare) do
        local skill = {
            id = skillId,
            exp = Skill:getExp(tonumber(npc.lv))
        }
        skills[skillId] = skill
        -- table.insert(skills, skill)
    end

    local prepareList = {"quanjiao", "neigong", "qinggong", "zhaojia", "jianfa", "daofa", "gunfa", "anqi", "shuangchi","qinfa"}

    -- 初始化基本类武功等级
    for k, v in pairs(prepareList) do
        local id = "jiben" .. v
        local skill = {
            id = id,
            exp = Skill:getExp(tonumber(npc.lv))
        }
        skills[id] = skill
    end

    npc.skills = createEncryptTable(skills)
end

-----------------------------------------------------------------------------------------------------------
-- @author ZhangShengTang
-- @time 2018/03/19 18:32:17
-- @desc 初始化物品
function EditorNpc:initItemsAndEquip(npc)
    local items = {}

    if MapIsEmpty(npc.items) ~= true then
        for i, item in ipairs(npc.items) do
            if item.itemId and item.count > 0 then
                table.insert(
                    items,
                    createEncryptTable(
                        {
                            id = Helper:getOnlyId(),
                            itemId = item.itemId,
                            count = item.count
                        }
                    )
                )
            end
        end
    end

    -- 身上穿戴的也要存入背包
    local equips = {}

    -- 武器
    if npc.weapon and #tostring(npc.weapon) > 0 then
		equips.weapon = {id = Helper:getOnlyId(), itemId = npc.weapon}
		npc.weapon = nil
    end
    -- 头帽
    if npc.head and #tostring(npc.head) > 0 then
		equips.head = {id = Helper:getOnlyId(), itemId = npc.head}
		npc.head = nil
    end
    -- 上装
    if npc.cloth and #tostring(npc.cloth) > 0 then
		equips.cloth = {id = Helper:getOnlyId(), itemId = npc.cloth}
		npc.cloth = nil
    end
    -- 腰带
    if npc.belt and #tostring(npc.belt) > 0 then
		equips.belt = {id = Helper:getOnlyId(), itemId = npc.belt}
		npc.belt = nil
    end
    -- 手部
    if npc.hand and #tostring(npc.hand) > 0 then
		equips.hand = {id = Helper:getOnlyId(), itemId = npc.hand}
		npc.hand = nil
    end
    -- 下装
    if npc.pants and #tostring(npc.pants) > 0 then
		equips.pants = {id = Helper:getOnlyId(), itemId = npc.pants}
		npc.pants = nil
    end
    -- 鞋子
    if npc.shoes and #tostring(npc.shoes) > 0 then
		equips.shoes = {id = Helper:getOnlyId(), itemId = npc.shoes}
		npc.shoes = nil
    end
    -- 戒指
    if npc.ring and #tostring(npc.ring) > 0 then
		equips.ring = {id = Helper:getOnlyId(), itemId = npc.ring}
		npc.ring = nil
    end
    -- 腰坠
    if npc.yaozhui and #tostring(npc.yaozhui) > 0 then
		equips.yaozhui = {id = Helper:getOnlyId(), itemId = npc.yaozhui}
		npc.yaozhui = nil
    end
    -- 项链
    if npc.necklace and #tostring(npc.necklace) > 0 then
		equips.necklace = {id = Helper:getOnlyId(), itemId = npc.necklace}
		npc.necklace = nil
    end

    npc.equips = equips

    for part, v in pairs(equips) do
        if not v or not v.itemId then
        else
			local item = {id = npc:getItemOnlyId(), count = 1, itemId = v.itemId}
            table.insert(items, createEncryptTable(item))
        end
	end
	
	npc.items = createEncryptTable(items)
end

-----------------------------------------------------------------------------------------------------------
-- @author ZhangShengTang
-- @time 2018/01/12 18:06:41
-- @desc 属性修正
function EditorNpc:initAttr(npc)
    npc.int = npc.sav
    npc.sav = nil

    -- 等级换算经验
    if npc.lv then
        npc.exp = User:getRole():getExp(tonumber(npc.lv))
    end

	local params = {lv = User:getRoleAttr("lv")}
    npc.age = Helper:GetValueFromScript(npc.age)				-- 年龄
	npc.looks = Helper:GetValueFromScript(npc.looks)			-- 容貌
	npc.jiaLi = Helper:GetValueFromScript(npc.jiaLi, params)	-- 加力
	npc.weapon = Helper:getRandomString(npc.weapon)					-- 武器
	npc.qi = Helper:GetValueFromScript(npc.qi, params)		-- 气血
	npc.neili = Helper:GetValueFromScript(npc.neili, params)	-- 内力
	npc.str = Helper:GetValueFromScript(npc.str, params)		-- 臂力
	npc.con = Helper:GetValueFromScript(npc.con, params)		-- 根骨
	npc.dex = Helper:GetValueFromScript(npc.dex, params)		-- 身法
	npc.int = Helper:GetValueFromScript(npc.int, params)		-- 悟性
	npc.lv = Helper:GetValueFromScript(npc.lv, params)		-- 等级
	npc.exp = Helper:GetValueFromScript(npc.exp, params)		-- 经验

	npc.quanjiao1 = Helper:getRandomString(npc.quanjiao1)			-- 拳脚
	npc.zhaojia = Helper:getRandomString(npc.zhaojia)				-- 招架
	npc.qingong = Helper:getRandomString(npc.qingong)				-- 轻功
	npc.neigong = Helper:getRandomString(npc.neigong)				-- 内功
	npc.jianfa = Helper:getRandomString(npc.jianfa)					-- 剑法
	npc.daofa = Helper:getRandomString(npc.daofa)					-- 刀法
	npc.anqi = Helper:getRandomString(npc.anqi)						-- 暗器
	npc.bianfa = Helper:getRandomString(npc.bianfa)					-- 鞭法
	npc.shuangchi = Helper:getRandomString(npc.shuangchi)					-- 双持
	npc.qinfa = Helper:getRandomString(npc.qinfa)					-- 琴法
    
    
	npc.jiaLi = tonumber( npc.jiali) == nil and 0 or npc.jiali
	npc.qiMax = tonumber(npc.qi) == nil and 100 or npc.qi
	npc.neiliMax = tonumber(npc.neili) == nil and 50 or npc.neili
end


local cloneNpc
function EditorNpc:testInit(npc)
    assert(npc, "initNpcEquipsAndItems(npc) -> 数据异常,副本NPC不存在")

	if cloneNpc == nil then
		cloneNpc = Role:create()
	end
	cloneNpc.items = {}

	-- 初始化物品列表
    if MapIsEmpty(npc.items) ~= true then
        for i, item in ipairs(npc.items) do
            if item.itemId and item.count > 0 then
                table.insert(
                    cloneNpc.items,
                    createEncryptTable(
                        {
                            id = cloneNpc:getItemOnlyId(),
                            itemId = item.itemId,
                            count = item.count
                        }
                    )
                )
            end
        end
    end

	for i=1,10 do
		local items = npc["item"..i]
		local itemId, count
		if items and type(items) == "string" then
			local start = string.find(items, ",")
			if start then
				itemId = string.sub(items, 0 , start)
				count = tonumber(string.sub(items, start + 1, #items))
			else
				itemId = items
				count = 1
			end
		end
		if itemId then
			-- add by XiaoZhiWei 2017/08/09 17:39:31 书页类型会直接添加到书箱,所以需要用插入
			local item = {id = cloneNpc:getItemOnlyId(), count = count , itemId = itemId}
			table.insert(cloneNpc.items, cloneNpc:createSafeItem(item))
		else
			break
		end
	end


	-- 身上穿戴的也要存入背包
	local equips = {}

	-- 武器
	if npc.weapon and #tostring(npc.weapon) > 0 then
		equips.weapon = {id = Helper:getOnlyId(), itemId = npc.weapon}
	end
	-- 头帽
	if npc.head and #tostring(npc.head) > 0 then
		equips.head = {id = Helper:getOnlyId(), itemId = npc.head}
	end
	-- 上装
	if npc.cloth and #tostring(npc.cloth) > 0 then
		equips.cloth = {id = Helper:getOnlyId(), itemId = npc.cloth}
	end
	-- 腰带
	if npc.belt and #tostring(npc.belt) > 0 then
		equips.belt = {id = Helper:getOnlyId(), itemId = npc.belt}
	end
	-- 手部
	if npc.hand and #tostring(npc.hand) > 0 then
		equips.hand = {id = Helper:getOnlyId(), itemId = npc.hand}
	end
	-- 下装
	if npc.pants and #tostring(npc.pants) > 0 then
		equips.pants = {id = Helper:getOnlyId(), itemId = npc.pants}
	end
	-- 鞋子
	if npc.shoes and #tostring(npc.shoes) > 0 then
		equips.shoes = {id = Helper:getOnlyId(), itemId = npc.shoes}
	end
	-- 戒指
	if npc.ring and #tostring(npc.ring) > 0 then
		equips.ring = {id = Helper:getOnlyId(), itemId = npc.ring}
	end
	-- 腰坠
	if npc.yaozhui and #tostring(npc.yaozhui) > 0 then
		equips.yaozhui = {id = Helper:getOnlyId(), itemId = npc.yaozhui}
	end
	-- 项链
	if npc.necklace and #tostring(npc.necklace) > 0 then
		equips.necklace = {id = Helper:getOnlyId(), itemId = npc.necklace}
	end


	npc.equips = equips

	for part,v in pairs(equips) do
		if not v or not v.itemId then
		else
			local item = {id = cloneNpc:getItemOnlyId(), count = 1 , itemId = v.itemId}
			table.insert(cloneNpc.items, cloneNpc:createSafeItem(item))
			-- cloneNpc:addItemCount(v.itemId, 1)
		end
	end

	npc.items = cloneNpc.items
	-- 武功初始化
	local prepare =
	{
		quanjiao1 = npc.quanjiao1 == nil and "jibenquanjiao" or npc.quanjiao1,
		quanjiao2 = npc.quanjiao2,
		neigong = npc.neigong == nil and "jibenneigong" or npc.neigong,
		qinggong = npc.qinggong == nil and "jibenqinggong" or npc.qinggong,
		zhaojia = npc.zhaojia == nil and "jibenzhaojia" or npc.zhaojia,
		jianfa = npc.jianfa == nil and "jibenjianfa" or npc.jianfa,
		daofa = npc.daofa == nil and "jibendaofa" or npc.daofa,
		gunfa = npc.gunfa == nil and "jibengunfa" or npc.gunfa,
		anqi = npc.anqi == nil and "jibenanqi" or npc.anqi,
		shuangchi = npc.shuangchi == nil and "jibenshuangchi" or npc.shuangchi,
		qinfa = npc.qinfa == nil and "jibenqinfa" or npc.qinfa,
	}
	npc.skillPrepare = prepare


	local skills = {}
	--  初始化武功等级
	for k,skillId in pairs(prepare) do
		local skill =
		{
			id = skillId,
			exp = Skill:getExp(tonumber(npc.lv))
		}
		skills[skillId] = skill
		-- table.insert(skills, skill)
	end

	local prepareList = {"quanjiao", "neigong", "qinggong", "zhaojia", "jianfa", "daofa", "gunfa", "anqi", "shuangchi", "qinfa"}

	-- 初始化基本类武功等级
	for k,v in pairs(prepareList) do
		local id = "jiben"..v
		local skill =
		{
			id = id,
			exp = Skill:getExp(tonumber(npc.lv))
		}
		skills[id] = skill
	end

	npc.skills = skills

	npc.jiaLi = npc.jiali == nil and 0 or npc.jiali
	npc.qiMax = npc.qi == nil and 100 or npc.qi
	npc.neiliMax = npc.neili == nil and 50 or npc.neili
end


return  EditorNpc00000000000000