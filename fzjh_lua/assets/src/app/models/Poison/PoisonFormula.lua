local PoisonFormula = {}
local pfList = require("script.others.poisonformula")["peifang"]

local BookLiterary = require("app.models.book.BookLiterary")

--@desc 已学会的配方
local userPoisonFormula = {}

--@desc 建立通过书籍ID进行索引的表
local formulaByBook = {}

--@desc 建立通过技能ID进行索引的表
local formulaBySkill = {}

--@desc: 解锁配方
--@author:Liang SongQiang
--@time:2018-01-14 21:25:57
--@formulaId:
function PoisonFormula:unlockPoisonFormula(formulaId)
    local needSkillId = pfList[formulaId]["belong"]
    local needLv = pfList[formulaId]["level"]
    --@RefType [app.models.role.Role#Role]
    local role = User:getRole()

    --@desc 技能解锁
    if pfList[formulaId]["type"] == 1 then
        local lv = role:getSkillLv(needSkillId)

        if lv >= needLv and not userPoisonFormula[formulaId] then
            userPoisonFormula[formulaId] = true
        end
    elseif pfList[formulaId]["type"] == 0 then
        local literaryBox = role:getAttr("literaryBox")
        if not MapIsEmpty(literaryBox) then
            for _, book in ipairs(literaryBox) do
                local itemAttr = role:getOneItemByKey(book.itemId)
                if itemAttr and itemAttr.type == "毒术书籍" and itemAttr.id == needSkillId then
                    local bookLv = role:getLiteraryLvByExp(book.exp)
                    if bookLv >= needLv then
                        userPoisonFormula[formulaId] = true
                    end
                end
            end
        end
    end
    return userPoisonFormula[formulaId]
end

--@desc: 通过请教解锁配方
--@author:Liang SongQiang
--@time:2018-01-15 14:25:44
--@skillId: 技能ID
function PoisonFormula:unlockPoisonFormulaBySkillLvUp(skillId)
    --@RefType [app.models.role.Role#Role]
    local role = User:getRole()

    local roleSkill = role:getSkill(skillId)
    if roleSkill == nil then
        assert(false, "你没有学会该技能啊！！")
    end

    local pfListBySkillId = formulaBySkill[skillId]
    if not MapIsEmpty(pfListBySkillId) then
        for _, pf in ipairs(pfListBySkillId) do
            --@desc 如果有表示已学过
            if not userPoisonFormula[pf.id] then
                local roleLv = role:getSkillLv(skillId)
                if roleLv >= pf.level then
                    print(roleLv,pf.level)
                    userPoisonFormula[pf.id] = true
                    RichPrint("main", "YEL经过多日来的钻研，你对"..tostring(Skill:getSkill(skillId).name).."YEL的掌握愈发纯熟，从而学到了新的毒药配方："..pf.name.."！")
                end
            end
        end
    end
end

--@desc: 通过书籍解锁毒药配方
--@author:Liang SongQiang
--@time:2018-01-15 11:38:26
--@preLv: 升级前等级
--@afterLv: 升级后等级
--@bookId: 书籍ID
function PoisonFormula:unlockPoisonFormulaByBookLvUp(preLv, afterLv, bookId)
    assert(type(preLv) == "number" and type(afterLv) == "number", "args type is error")

    if afterLv - preLv <= 0 then
        return
    end

    local pfListByBookId = formulaByBook[bookId]

    --@desc 如果长时间离线阅读，可能同时解锁多个配方，所以记录名字列表
    local pfNameList = {}
    if not MapIsEmpty(pfListByBookId) then
        for _, pf in ipairs(pfListByBookId) do
            --@desc 如果有表示已学过
            if not userPoisonFormula[pf.id] then
                if pf.level >= preLv and pf.level <= afterLv then
                    userPoisonFormula[pf.id] = true
                    --@desc 记录学习名字
                    table.insert(pfNameList, pf.name)
                end
            end
        end
    end

    if not MapIsEmpty(pfNameList) then
        local nameStr = ""
        for i, name in ipairs(pfNameList) do
            nameStr = nameStr .. name
            if i ~= #pfNameList then
                nameStr = nameStr .. ","
            end
        end
        local str =
            "YEL随着多日来的研读和揣摩，你对【" ..
            BookLiterary:getLiteraryById(bookId).name .. "YEL】的认识达到了一个新的高度，从而学到了新的毒药配方：" .. nameStr .. "！"
        RichPrint("main", str)
    end
end

--@desc: 获取用户已解锁的所有毒药配方
--@author:Liang SongQiang
--@time:2018-01-15 10:56:53
function PoisonFormula:getUserPoisonFormula()
    return userPoisonFormula
end

--@desc: 通过配方Id获得配方
--@author:Liang SongQiang
--@time:2018-01-15 11:09:39
--@formulaId:
function PoisonFormula:getUserPoisonFormulaByFId(formulaId)
    return userPoisonFormula[formulaId]
end

function PoisonFormula:init()
    for id, pf in pairs(pfList) do
        if pf.type == 0 then
            if formulaByBook[pf.belong] == nil then
                formulaByBook[pf.belong] = {}
            end
            table.insert(formulaByBook[pf.belong], pf)
        elseif pf.type == 1 then
            if formulaBySkill[pf.belong] == nil then
                formulaBySkill[pf.belong] = {}
            end
            table.insert(formulaBySkill[pf.belong], pf)
        end
        self:unlockPoisonFormula(id)
    end
end

return PoisonFormula
00000