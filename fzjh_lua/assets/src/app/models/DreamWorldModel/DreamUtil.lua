local DreamUtil = {}

function DreamUtil:initDreamRoleWeaponSkill(role)
    --@desc 初始选择一个兵器武学进行准备
    local weaponSkillType = {
        "jianfa",
        "gunfa",
        "daofa",
        "anqi",
        "bianfa",
        "shuangchi",
        "qinfa"
    }
    local withoutBaseSkills = {}

    local randomSkillTypes = {}

    for _, preSkillType in ipairs(weaponSkillType) do
        if role:getPrepareSkillIdByType(preSkillType) == "jiben" .. preSkillType and role:getPrepareSkillIdByType(preSkillType) ~= nil then
            table.insert(withoutBaseSkills, preSkillType)
        else
            table.insert(randomSkillTypes,preSkillType)
        end
    end

    if MapIsEmpty(withoutBaseSkills) == false then
        for i, preSkillType in ipairs(withoutBaseSkills) do
            role:prepareSkill(preSkillType, nil)
        end
    end

    if MapIsEmpty(randomSkillTypes) == false then
        local index = math.random(1, #randomSkillTypes)
        local skillType = randomSkillTypes[index]

        for i = 1,#randomSkillTypes do 
            if i ~= index then
                role:prepareSkill(preSkillType, nil)
            end
        end
    end
    return role
end

--获取指定的武学列表
function DreamUtil:getSkillsByType(skills,retType)
    local retList = {}
    if MapIsEmpty(skills) or retType == nil then
        return retList
    end
    local qjList, bqList, qgList, ngList, zjList, zsList = {}, {}, {}, {}, {}, {}
    for k, v in pairs(skills) do
        local skill = Skill:getSkill(k)
        if skill.type == SKILL_TYPE_DUSHU or skill.type == SKILL_TYPE_SPECIAL or skill.type == SKILL_TYPE_HUIFU or skill.type == SKILL_TYPE_DUNDI or skill.type == SKILL_TYPE_ZHISHI then
            table.insert(zsList, k)
        elseif skill and skill.methods then
            for i, vtype in ipairs(skill.methods) do
				if vtype == SKILL_METHOD_TYPE_QUANJIAO then
					table.insert(qjList, k)
				elseif vtype == SKILL_METHOD_TYPE_NEIGONG then
					table.insert(ngList, k)
				elseif vtype == SKILL_METHOD_TYPE_QINGGONG then
					table.insert(qgList, k)
				elseif vtype == SKILL_METHOD_TYPE_ZHAOJIA then
					table.insert(zjList, k)
				else
					local temp = false
					for _,tempSkill in pairs(bqList) do
						if tempSkill.id == v.id then
							temp = true
						end
					end

					if temp == false then
						table.insert(bqList, k)
					end
				end
			end
        end
    end
    
    if retType == "quanjiao" then
        retList = qjList
    elseif retType == "bingqi" then
        retList = bqList
    elseif retType == "qinggong" then
        retList = qgList
    elseif retType == "neigong" then
        retList = ngList
    end

    return retList
end

return DreamUtil0000000000000000