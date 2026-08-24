local BaseFamily = {
    id = "youxia",
    name = "武当派",
    dsc = "你到了武当山最为宏大的紫霄宫。殿宇依山而筑，高低错落有致。周围古木森林，翠竹成林，景色清幽。这里是武当师徒的主要活动场所。",
    litteDesc = "仙山有神功，\n太极并屠龙。",
    task = "无",
    --　门派任务
    defaultTeacher = "谷虚道长",
    familySkill = "daoxuexinfa",
    npcs = {},
    npcList = {
        -- 角色列表
        "谷虚道长",
        "宋远桥",
        "张三丰"
    },
    eventList = {
        -- 事件列表
        {
            name = "请\n教",
            functionId = FAMLIY_FUNCTION_ID_CONSULT
        },
        {
            name = "技\n能",
            functionId = FAMLIY_FUNCTION_ID_MYSKILL
        },
        {
            name = "守\n山\n门"
        },
        {
            name = "磕\n头",
            functionId = FAMLIY_FUNCTION_ID_KOWTOW
        }
    }
}

function BaseFamily:getId()
    return self.id
end

function BaseFamily:getName()
    return self.name
end

function BaseFamily:getDsc()
    return self.dsc
end

function BaseFamily:getFamilyType()
    return self.familytype
end

function BaseFamily:getFamilySkill()
    return self.familySkill
end

function BaseFamily:getNpcList()
    return self.npcList
end

function BaseFamily:getEventList()
    return self.eventList
end

function BaseFamily:getDefaultTeacher()
    return self.defaultTeacher
end

function BaseFamily:getFamilyAttr(name)
    if not name then
        return
    end
    local attr = self[name]
    if not attr then
        if PRINT_MODE == 1 then
            print("没有这个家族属性" .. name)
        end
        return
    end
    return attr
end

return BaseFamily
000