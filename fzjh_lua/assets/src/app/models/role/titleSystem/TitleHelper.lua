local TitleHelper = {}
local RoleTitleConst = require("app.models.role.titleSystem.RoleTitleConst")
local RoleTitleResManager = require("app.models.role.titleSystem.RoleTitleResManager")

function TitleHelper:changeTitle(role)
    self:__changeExtraTitle(role)
    self:__changeToBasicTitle(role)
end

function TitleHelper:doInheritTitle(role)
    self:deleteNoInheritTitle(role)

    local defaultTitleId = role:getTitleSystem():getDefaultBasicId()
    role:useBasicTitle(defaultTitleId)
end

function TitleHelper:deleteNoInheritTitle(role)
    local group = RoleTitleResManager:getBasicTitleGroup(RoleTitleConst.BasicTitleType.Family)
    local titleList = group:getTitleIdList()
    for __, titleId in ipairs(titleList) do
        if role:hasBasicTitle(titleId) then
            role:deleteBasicTitle(titleId)
        end
    end

    local group = RoleTitleResManager:getBasicTitleGroup(RoleTitleConst.BasicTitleType.JiangHu)
    local titleList = group:getTitleIdList()
    for __, titleId in ipairs(titleList) do
        if role:hasBasicTitle(titleId) then
            role:deleteBasicTitle(titleId)
        end
    end

    local group = RoleTitleResManager:getBasicTitleGroup(RoleTitleConst.BasicTitleType.Seclusion)
    local titleList = group:getTitleIdList()
    for __, titleId in ipairs(titleList) do
        if role:hasBasicTitle(titleId) then
            role:deleteBasicTitle(titleId)
        end
    end

    local group = RoleTitleResManager:getBasicTitleGroup(RoleTitleConst.BasicTitleType.YouXia)
    local titleList = group:getTitleIdList()
    for __, titleId in ipairs(titleList) do
        if role:hasBasicTitle(titleId) then
            role:deleteBasicTitle(titleId)
        end
    end

    local group = RoleTitleResManager:getBasicTitleGroup(RoleTitleConst.BasicTitleType.Official)
    local titleList = group:getTitleIdList()
    for __, titleId in ipairs(titleList) do
        if role:hasBasicTitle(titleId) then
            role:deleteBasicTitle(titleId)
        end
    end

    local group = RoleTitleResManager:getBasicTitleGroup(RoleTitleConst.BasicTitleType.Prestige)
    local titleList = group:getTitleIdList()
    for __, titleId in ipairs(titleList) do
        if role:hasBasicTitle(titleId) then
            role:deleteBasicTitle(titleId)
        end
    end

    local group = RoleTitleResManager:getBasicTitleGroup(RoleTitleConst.BasicTitleType.TeacherTraining)
    local titleList = group:getTitleIdList()
    for __, titleId in ipairs(titleList) do
        if role:hasBasicTitle(titleId) then
            role:deleteBasicTitle(titleId)
        end
    end
end

function TitleHelper:__changeExtraTitle(role)
    if role:getInheritFlag("已转换称号相关结构") == 0 then
        --称号添加id
        if role:getAttr("extraTitle") and role:getAttr("extraTitle") ~= 0 then --修改前是一对一
           local currTitleTab = role:getAttr("extraTitle")
           if MapIsEmpty(currTitleTab) then
           else
               for k, v in pairs(currTitleTab) do
                   for index, title in pairs(v) do
                       local titleID = 1
                       if title.id then
                       else
                           title.id = titleID
                       end
                       titleID = titleID + 1
                   end
               end
           end
       end

       if role:getAttr("title_id") == 0 then
           --根据所选择的称号类型选择称号
           local TitleTab = {}
            --门派称号、江湖称号(正气值)
           if role.title_type == 1 or role.title_type == 2 then
               local chengHaoList = role:getConditionMatchNormalChengHaoList()
               local maxLv = -1
               local titleId
               for i, v in ipairs(chengHaoList) do
                   if v.titletype == role.title_type then
                       if maxLv < tonumber(v.lv) then
                           maxLv = tonumber(v.lv)
                           titleId = v.id
                       end
                   end
               end

               if titleId then
                   role:setAttr("title_id", titleId)
               end
           elseif role.title_type == 3 then --月卡称号
               -- 	月卡用户
               if role:yueKaIsValid() == true then
                   role:setAttr("title_id", 1)
               end
           elseif role.title_type == 4 then
               TitleTab = role:getConditionMatchOfficialChengHaoList(role:getAttr("officialType"), role:getAttr("officialAchievement"))
           elseif role.title_type == 5 then
               -- 周年庆称号
               role:setAttr("title_id", 1)
           elseif role.title_type == 6 then
               -- 佳人头衔
               role:setAttr("title_id", 1)
           elseif role.title_type == 7 then
               --七夕情缘奖励称号
               role:setAttr("title_id", 1)
           elseif role.title_type == 8 then
               --七夕情缘奖励称号
               role:setAttr("title_id", 1)
           elseif role.title_type == 9 then
               --七夕情缘奖励称号
               role:setAttr("title_id", 1)
           elseif role.title_type == 10 then
               --七夕情缘奖励称号
               role:setAttr("title_id", 1)
           elseif role.title_type > 100 and role.title_type < 300 then
               --声望称号
               role:setAttr("title_id", role.title_type - 100)
               role:setAttr("title_type", 16)
           elseif not MapIsEmpty(role:getAttr("extraTitle")) and role:getAttr("extraTitle")[tostring(role.title_type)] ~= nil then
               TitleTab = role:getAttr("extraTitle")[tostring(role.title_type)]
           end

           if MapIsEmpty(TitleTab) and role.title_id == 0 then
               local currId = 160
               if role.sex == "女" then
                   currId = 161
               end
               TitleTab = {{title = "WHT【普通百姓】", id = currId}}
           end
           
           if role.title_id == 0 then
               role:setAttr("title_id", TitleTab[#TitleTab].id)
           end
       end

       local extraTitleList = role:getAttr("extraTitle")
       if MapIsEmpty(extraTitleList) == false then
           local newExtraTitle = {}

           for titleType, titleList in pairs(extraTitleList) do
               if newExtraTitle[tostring(titleType)] == nil then
                   newExtraTitle[tostring(titleType)] = {}
               end
               for i, titleData in ipairs(titleList) do
                   if tonumber(titleType) == RoleTitleConst.BasicTitleType.Prestige then
                       local titleTab = string.split(titleData.title, ";")

                       for k, prestigeId in ipairs(titleTab) do
                           if prestigeId and prestigeId ~= "" then
                               table.insert(newExtraTitle[tostring(titleType)], prestigeId)
                           end
                       end
                   else
                       table.insert(newExtraTitle[tostring(titleType)], titleData.id)
                   end
               end
           end

           role:setExtraTitle(newExtraTitle)

           --@desc 转换完成删除历史数据
           role:setAttr("extraTitle", nil)
       end

       role:setInheritFlag("已转换称号相关结构", 1)
   end
end

function TitleHelper:__changeToBasicTitle(role)
    local function addBasicTitle(basicTitleId)
        if not basicTitleId then
            return
        end
    
        basicTitleId = tostring(basicTitleId)

        local basicTitleData = role:getBasicTitleData()
        local basicTitleList = basicTitleData.titleList

        if table.indexof(basicTitleList, basicTitleId) == false then
            table.insert(basicTitleList, basicTitleId)
        end
    end

    if role:getInheritFlag("已转换称号相关结构") == 1 then
        if role:getFlag("初心未泯") ~= 0 then
            local basicTitleId = RoleTitleConst.SpecialBasicTitleId.Anniversary
			addBasicTitle(basicTitleId)
		end

        if role:getFlag("七夕情缘奖励") == 1 then
            local basicTitleId = RoleTitleConst.SpecialBasicTitleId.QiXi1
			addBasicTitle(basicTitleId)
        elseif role:getFlag("七夕情缘奖励") == 2 then
            local basicTitleId = RoleTitleConst.SpecialBasicTitleId.QiXi2
			addBasicTitle(basicTitleId)
        elseif role:getFlag("七夕情缘奖励") == 3 then
            local basicTitleId = RoleTitleConst.SpecialBasicTitleId.QiXi3
			addBasicTitle(basicTitleId)
        elseif role:getFlag("七夕情缘奖励") == 4 then
            local basicTitleId = RoleTitleConst.SpecialBasicTitleId.QiXi4
			addBasicTitle(basicTitleId)
		end

        local normalChengHaoList = role:getConditionMatchNormalChengHaoList()
        for i, v in ipairs(normalChengHaoList) do
            addBasicTitle(v.basicTitleId)
        end

        local officialChengHaoList = role:getConditionMatchOfficialChengHaoList(role:getAttr("officialType"), role:getAttr("officialAchievement"))
        for i, v in ipairs(officialChengHaoList) do
            addBasicTitle(v.basicTitleId)
        end

        local extraTitle = role:getExtraTitle()
        for titleType, titles in pairs(extraTitle) do
            local _titleType = tonumber(titleType)
            if not MapIsEmpty(titles) then
                for i, id in ipairs(titles) do
                    local basicTitleId = RoleTitleResManager:getChangeTitleBasicTitleId(_titleType, tonumber(id))
                    addBasicTitle(basicTitleId)
                end
            end
        end

        local basicTitleData = role:getBasicTitleData()

        if basicTitleData.titleId == nil then
            local title_type = tonumber(role:getAttr("title_type"))
            local title_id = tonumber(role:getAttr("title_id"))

            local basicTitleId = RoleTitleResManager:getChangeTitleBasicTitleId(title_type, title_id)

            if basicTitleId then
                addBasicTitle(basicTitleId)

                basicTitleData.titleId = basicTitleId
            end
        end

        role:setInheritFlag("已转换称号相关结构", 2)
    end
end

return TitleHelper0000000000