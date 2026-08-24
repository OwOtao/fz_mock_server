local SelfCreatedSkillConstants = require("app.models.SelfCreatedSkillSystem.SelfCreatedSkillConstants")
local newClass = require("third.class.NewClass")
local SkillCreator = require("app.models.SelfCreatedSkillSystem.SkillCreator")
local SelfCreatedSkill = require("app.models.SelfCreatedSkillSystem.SelfCreatedSkill.SelfCreatedSkill")
local SelfCreatedZhao = require("app.models.SelfCreatedSkillSystem.SelfCreatedZhao.SelfCreatedZhao")
local SelfCreatedSkillOld = require("app.models.SelfCreatedSkillSystem.SelfCreatedSkill.SelfCreatedSkillOld")
local SelfCreatedSkillModel = require("app.models.SelfCreatedSkillSystem.SelfCreatedSkillModel")
local SkillHelper = require("app.models.skill.SkillHelper")

local SelfCreatedSkillSystem = {
    __data = {
        createdBooks = {},
        createdSkillData = {},
        skillCreatorData = {}
    },
    --[[
        -已经创作的书籍
        createdBooks = 
        {
            {
                id          //数据id
                templateId  // 武学模板ID
                name // 武学名称
                colorId  // 武学颜色
                zhaos = {
                    {
                        index       // 招式位置(招式属于第几招)
                        name     	// 招式名称
                        colorId  	// 招式颜色
                        dscId     	// 招式描述
                        quality  	// 招式品质
                        useType    	// 招式使用类型(0. 被动   1主动)
                        templateId  // 招式模板ID

                        // 招式伤害特性槽
                        atkAffixs = {
                            id 		// 招式特性ID
                            needLv		// 特性出现等级
                            effectId	// 招式特性效果ID
                            value1	// 效果1
                            value2	// 效果2
                            value3	// 效果3
                        }   
                        defAffixs = {}   // 招式生存特性槽
                    }
                }
            }
        },

    
        --本地存档已经学会的书籍
		createdSkillData = {
			skillDataId = {
                id          //数据id
                templateId  // 武学模板ID
                name // 武学名称
                colorId  // 武学颜色
                exp // 经验值
                zhaos = {
                    {
                        index       // 招式位置(招式属于第几招)
                        name     	// 招式名称
                        colorId  	// 招式颜色
                        dscId     	// 招式描述
                        quality  	// 招式品质
                        useType    	// 招式使用类型(0. 被动   1主动)
                        templateId  // 招式模板ID

                        // 招式伤害特性槽
                        atkAffixs = {
                            id 		// 招式特性ID
                            needLv		// 特性出现等级
                            effectId	// 招式特性效果ID
                            value1	// 效果1
                            value2	// 效果2
                            value3	// 效果3
                        }   
                        defAffixs = {}   // 招式生存特性槽
                    }
                }
            }
			
		},
		--正在创作的书籍
		skillCreatorData = {
            id          //数据id
            templateId  // 武学模板ID
            zhaos = {
                {
                    index       // 招式位置(招式属于第几招)
                    quality  	// 招式品质
                    useType    	// 招式使用类型(0. 被动   1主动)
                    templateId  // 招式模板ID
					lv 			// 招式等级

                    // 招式伤害特性槽
                    atkAffixs = {
                        id 		// 招式特性ID
                        needLv		// 特性出现等级
                        effectId	// 招式特性效果ID
                        value1	// 效果1
                        value2	// 效果2
                        value3	// 效果3
                    }   
                    defAffixs = {}   // 招式生存特性槽
                }
            }
		}
    ]]
    __skillCreator = nil
}

function SelfCreatedSkillSystem:create()
    self.__model = SelfCreatedSkillModel
    local p = SelfCreatedSkillSystem.new()
    p.__isNotSerializable = true
    return p
end

function SelfCreatedSkillSystem:init(role)
    self:setRole(role)
    self.__propSystem:setRole(self.__role)
    self:setData(role.selfCreatedSkillData)
end

function SelfCreatedSkillSystem:setRole(role)
    self.__role = role
end

function SelfCreatedSkillSystem:getRole()
    return self.__role
end

function SelfCreatedSkillSystem:downloadData(callback)
    self.__model:getCreateBooks(
        function(retData)
            self:setBooksData(retData)

            if callback then
                callback()
            end
        end
    )
end

function SelfCreatedSkillSystem:setData(data)
    self.__data.createdSkillData = data
end

function SelfCreatedSkillSystem:setBooksData(data)
    -- print("---------SelfCreatedSkillSystem:setBooksData-----------")
    -- Helper:print_lua_table(data)
    -- print("-----------------end--------------------")

    if MapIsEmpty(data.createdBooks) == false then
        for i = 1, #data.createdBooks do
            local book = data.createdBooks[i]
            if type(book.id) ~= "string" then
                book.id = tostring(book.id)
            end
        end
    end

    self.__data.skillCreatorData = Helper:getDef(data.creatingBook, {})
    self.__data.createdBooks = Helper:getDef(data.createdBooks, {})

    self:setSkillCreatorData(self.__data.skillCreatorData)

    --已创造未学习的书籍，也添加到Skill配置中
    for id, skillData in pairs(self.__data.createdBooks) do
        if not self.__data.createdSkillData[tostring(id)] then
            self:setSelfCreatedSkillDataToSkillConfig(skillData)
        end
    end
end

function SelfCreatedSkillSystem:setPropSystem(system)
    self.__propSystem = system
end

function SelfCreatedSkillSystem:getPropSystem()
    return self.__propSystem
end

function SelfCreatedSkillSystem:setSkillCreatorData(skillCreatorData)
    self.__skillCreator = SkillCreator:create(skillCreatorData)
end

function SelfCreatedSkillSystem:getSkillCreator()
    return self.__skillCreator
end

function SelfCreatedSkillSystem:deserializable()
    return {
        createdSkillData = self:getCreatedSkillData(),
        skillCreatorData = self:getSkillCreatorData(),
        createdBooks = self:getBooks()
    }
end

--获取已经自创的武学数据
function SelfCreatedSkillSystem:getCreatedSkillData()
    return self.__data.createdSkillData
end

--获取已经自创的武学书籍
function SelfCreatedSkillSystem:getBooks()
    return self.__data.createdBooks
end

--获取指定的武学书籍
function SelfCreatedSkillSystem:getBookById(bookId)
    for i, v in ipairs(self:getBooks()) do
        if v.id == bookId then
            return v
        end
    end
    assert(nil, "自创书籍不存在 bookId = " .. bookId)
end

--获取已经自创的武学数量
function SelfCreatedSkillSystem:getBookCount()
    return #self:getBooks()
end

-- 获取自创武学Id列表
function SelfCreatedSkillSystem:getSkillIdAndExpMap()
    local skillMap = {}
    if MapIsEmpty(self.__data.createdSkillData) == false then
        for id, skillData in pairs(self.__data.createdSkillData) do
            -- print("自创武学Id:", id)
            local skillId = SkillHelper:selfCreatedSkillDataIdToSkillId(self.__role:getAttr("userid"), id)
            skillMap[skillId] = {id = skillId, exp = skillData.exp}
        end
    end

    return skillMap
end

-- 自创武学增加经验值
-- skillId：武学id,需要转化为对应的数据id
function SelfCreatedSkillSystem:addSkillDataExp(skillId, exp)
    local skillDataId = SkillHelper:skillIdToSelfCreatedSkillDataId(skillId)

    local skillData = self.__data.createdSkillData[skillDataId]
    if not skillData then
        print("技能不存在 skillDataId = ", skillDataId)
        return
    end

    skillData["exp"] = skillData["exp"] + exp
end

-- 获取已经学习的武学列表
function SelfCreatedSkillSystem:getCreatedSkills()
    local retTb = {}
    if MapIsEmpty(self.__data.createdSkillData) == false then
        for id, skill in pairs(self.__data.createdSkillData) do
            retTb[id] = SelfCreatedSkill:create(skill)
        end
    end
    return retTb
end

-- 通过武学id获取指定武学数据
function SelfCreatedSkillSystem:getCreatedSkillBySkillId(skillId)
    local skillDataId = SkillHelper:skillIdToSelfCreatedSkillDataId(skillId)
    return self:getCreatedSkillBySkillDataId(skillDataId)
end

-- 通过武学数据id获取指定武学数据
function SelfCreatedSkillSystem:getCreatedSkillBySkillDataId(skillDataId)
    local skillData = self.__data.createdSkillData[skillDataId]

    return SelfCreatedSkill:create(skillData)
end

-- 通过武学数据id获取指定武学数据招式
function SelfCreatedSkillSystem:getZhaoBySkillDataId(skillDataId, zhaoIndex)
    local skill = self:getCreatedSkillBySkillDataId(skillDataId)
    local zhao = skill:getZhaoByIndex(zhaoIndex)

    return zhao
end

-- 获取兼容老的武学结构的自创武学
function SelfCreatedSkillSystem:getOldSkill(skillData)
    local oldSkill = SelfCreatedSkillOld:create(skillData, self.__role)
    return oldSkill
end

--获取正在创建的武学数据
function SelfCreatedSkillSystem:getSkillCreatorData()
    return self.__skillCreator:getSkillCreatorData()
end

--@desc 刷新正在创建的武学数据
function SelfCreatedSkillSystem:updataSkillCreatorData()
    self.__data.skillCreatorData = self:getSkillCreatorData()
end

--@desc 技能创建完成
function SelfCreatedSkillSystem:completeSkillCreate(skillName, callback)
    self.__model:completeBook(
        skillName,
        function(skillBook)
            self:addSelfCreatedBook(skillBook)
            self:setSelfCreatedSkillDataToSkillConfig(skillBook)

            self.__data.skillCreatorData = {}
            self.__skillCreator = SkillCreator:create(self.__data.skillCreatorData)

            if callback then
                callback()
            end
        end
    )
end

--@desc 添加自创书籍
function SelfCreatedSkillSystem:addSelfCreatedBook(skillBook)
    table.insert(self:getBooks(), skillBook)
end

function SelfCreatedSkillSystem:deleteSelfCreatedBook(skillBookId)
    local booksCount = self:getBookCount()
    if booksCount <= 0 then
        return true
    end

    local books = self:getBooks()

    for i = booksCount, 1, -1 do
        local book = books[i]
        if book.id == skillBookId then
            table.remove(books, i)
            return true
        end
    end

    return false
end

--@desc 学习书籍
function SelfCreatedSkillSystem:learnSkillBookBySkillId(skillId, callback)
    local skill = self.__role:getSkill(skillId)

    if skill ~= nil then
        PopText("您已学习过该武学。")
        return
    end

    local skillBookId = SkillHelper:skillIdToSelfCreatedSkillDataId(skillId)

    self.__model:learnSkillBook(
        skillBookId,
        function(skillData)
            local exp = 1
            self:addSelfCreatedSkillData(skillBookId, skillData, exp)

            if callback then
                callback()
            end
        end
    )
end

--@desc: 删除已完成的书籍
--@author:Seven
--@time:2021-02-05 11:07:40
--@skillId: 技能书籍对应的武学id
function SelfCreatedSkillSystem:deleteCompletedBookBySkillId(skillId, callback)
    local booksCount = self:getBookCount()
    if booksCount <= 0 then
        callback(2)
    end

    local skillBookId = SkillHelper:skillIdToSelfCreatedSkillDataId(skillId)

    local skillBook = self:getBookById(skillBookId)

    self.__model:deleteCompletedBook(
        skillBookId,
        function(result, skillBookId)
            if result == 0 then
                if self:deleteSelfCreatedBook(skillBookId) == true then
                    callback(result, skillBook)
                end
            else
                callback(result)
            end
        end
    )
end

--@desc 添加自创武学
function SelfCreatedSkillSystem:addSelfCreatedSkillData(skillDataId, skillData, exp)
    skillDataId = tostring(skillDataId)
    skillData.id = tostring(skillData.id)

    if not self.__data.createdSkillData[skillDataId] then
        skillData.exp = exp
        self.__data.createdSkillData[skillDataId] = skillData

        self:setSelfCreatedSkillDataToSkillConfig(skillData)
    else
        print("技能数据已存在  skillDataId = ", skillDataId)
    end
end

--@desc 创建招式
function SelfCreatedSkillSystem:createZhao(secondType, callback)
    local userLv = self:getRole():getLv()
    local tujianIndex = SelfCreatedSkillConstants.SkillThirdTuJianIndex[secondType]
    local TuJianUtil = require("app.models.TuJian.TuJianUtil")
    local tujianLv = TuJianUtil:getSkillTypeScoreLevel(tujianIndex, self:getRole())
    self.__model:createZhao(
        secondType,
        userLv,
        tujianLv,
        function(data)
            print("-----------------SelfCreatedSkillSystem:createZhao-----------")
            Helper:print_lua_table(data)
            print("----------------------end---------------")
            local ret = data.result
            local data = data.zhaoData
            local zhaoData = data.zhaos
            local msg = ""
            if ret == true then
                msg = "你成功的创出一招「&name」，并把它记录在了纸上。"
            else
                msg = "你没能成功创作出招式，只能望着空白的纸发呆。"
            end

            self.__skillCreator:setPropId(nil)

            if ret == true then
                self.__skillCreator:createZhao(data)
            end

            self:updataSkillCreatorData()

            if callback then
                callback(ret, msg, zhaoData)
            end
        end
    )
end

--@desc 获取招式颜色列表
function SelfCreatedSkillSystem:getZhaoSuccessRate(callback)
    local userLv = self:getRole():getLv()
    self.__model:getZhaoSuccessRate(userLv, callback)
end

--@desc 设置招式名称
function SelfCreatedSkillSystem:setZhaoName(zhaoCreator, name)
    zhaoCreator:setZhaoName(name)

    self:updataSkillCreatorData()
end

function SelfCreatedSkillSystem:getSelfCreatingZhao(zhaoIndex)
    local skill = self:getSelfCreatingSkill()
    local zhao = skill:getZhaoByIndex(zhaoIndex)

    return zhao
end

--@desc 获取当前正在创建的武学
function SelfCreatedSkillSystem:getSelfCreatingSkill()
    local skill = SelfCreatedSkill:create(self:getSkillCreatorData())

    return skill
end

--@desc 判断当前是否正在创建武学
function SelfCreatedSkillSystem:checkIsCreating()
    local zhaos = self:getSkillCreatorData().zhaos
    if MapIsEmpty(zhaos) then
        return false
    end

    return true
end

--@desc 刷新武学配置中自创武学数据
function SelfCreatedSkillSystem:updataSelfCreatedSkillMap()
    for id, skillData in pairs(self.__data.createdSkillData) do
        self:setSelfCreatedSkillDataToSkillConfig(skillData)
    end
end

--@desc 刷新武学配置中指定自创武学数据
--skillId:武学id
function SelfCreatedSkillSystem:updataSelfCreatedSkillDataInSkillConfig(skillId)
    local skillDataId = SkillHelper:skillIdToSelfCreatedSkillDataId(skillId)
    local skillData = self.__data.createdSkillData[skillDataId]
    self:setSelfCreatedSkillDataToSkillConfig(skillData)
end

--@desc 自创武学数据加入武学配置中
function SelfCreatedSkillSystem:setSelfCreatedSkillDataToSkillConfig(skillData)
    local skill = SelfCreatedSkillOld:create(skillData, self.__role)
    Skill:setSkillNewData(skill.id, skill)
end

--@desc 获取招式颜色列表
function SelfCreatedSkillSystem:getZhaoColors(callback)
    self.__model:getZhaoColors(callback)
end

--@desc 获取招式描述列表
function SelfCreatedSkillSystem:getZhaoDscs(zhaoTemplateId, callback)
    self.__model:getZhaoDscs(zhaoTemplateId, callback)
end

--@desc 获取武学名字词缀列表
function SelfCreatedSkillSystem:getSkillNameAffixs(callback)
    self.__model:getSkillNameAffixs(callback)
end

--@desc 设置招式属性
function SelfCreatedSkillSystem:setZhaoAttr(params, callback)
    self.__model:setZhaoAttr(params, callback)
end

--@desc 解锁招式颜色
function SelfCreatedSkillSystem:unlockZhaoColor(colorId, callback)
    self.__model:unlockZhaoColor(colorId, callback)
end

--@desc 解锁招式系列描述
function SelfCreatedSkillSystem:unlockZhaoDsc(xiLieId, zhaoTemplateId, callback)
    self.__model:unlockZhaoDsc(xiLieId, zhaoTemplateId, callback)
end

--@desc 解锁武学名字后缀
function SelfCreatedSkillSystem:unlockSkillNameAffixs(nameAffixsId, callback)
    self.__model:unlockSkillNameAffixs(nameAffixsId, callback)
end

--@desc 获取创作道具列表
function SelfCreatedSkillSystem:getCreatePropList(callback)
    self.__propSystem:getPropList(1, callback)
end

--@desc 获取改良道具列表
function SelfCreatedSkillSystem:getImprovedPropList(callback)
    self.__propSystem:getPropList(2, callback)
end

--@desc 使用创作道具
function SelfCreatedSkillSystem:useCreateProp(propId, callback)
    local userLv = self:getRole():getLv()
    local skillDataId = self:getSelfCreatingSkill():getId()
    self.__propSystem:useCreateProp(propId, userLv, skillDataId, callback)
end

--@desc 使用改良道具
function SelfCreatedSkillSystem:useImproveProp(propId, zhaoIndex, skillDataId, callback)
    local userLv = self:getRole():getLv()
    self.__propSystem:useImproveProp(propId, userLv, zhaoIndex, skillDataId, callback)
end

--@desc 使用改良道具
function SelfCreatedSkillSystem:addProp(propId, count)
    self.__propSystem:addProp(propId, count)
end

function SelfCreatedSkillSystem:deleteZhao(zhaoIndex)
    self.__skillCreator:deleteZhao(zhaoIndex)
end

function SelfCreatedSkillSystem:updataZhao(zhaoIndex, newZhaoData)
    self.__skillCreator:updataZhao(zhaoIndex, newZhaoData)
end

function SelfCreatedSkillSystem:openSystem()
    self:getRole():setInheritFlag("开启神功系统", 1)
end

function SelfCreatedSkillSystem:closeSystem()
    self:getRole():setInheritFlag("开启神功系统", nil)
end

function SelfCreatedSkillSystem:isOpenSystem()
    return self:getRole():getInheritFlag("开启神功系统") == 1
end

function SelfCreatedSkillSystem:deleteSelfCreatedSkillData()
    if MapIsEmpty(self.__data.createdSkillData) == false then
        for k, v in pairs(self.__data.createdSkillData) do
            self.__data.createdSkillData[k] = nil
        end
    end
end

function SelfCreatedSkillSystem:getBookCountByType(firstType)
    local count = 0

    for i, v in ipairs(self:getBooks()) do
        local skill = SelfCreatedSkill:create(v)
        if skill:getFirstType() == firstType then
            count = count + 1
        end
    end

    return count
end

function SelfCreatedSkillSystem:deleteSelfCreatedSkillDataBySkillId(skillId)
    local skillDataId = SkillHelper:skillIdToSelfCreatedSkillDataId(skillId)

    if self.__data.createdSkillData[skillDataId] then
        self.__data.createdSkillData[skillDataId] = nil
        return true
    end

    return false
end

function SelfCreatedSkillSystem:repairRoleSelfCreatedSkillId()
    SkillHelper:changeRoleSelfCreatedSkillId(self.__role)
    self:updataSelfCreatedSkillMap()
end

return newClass("SelfCreatedSkillSystem", {}, SelfCreatedSkillSystem)
000000000