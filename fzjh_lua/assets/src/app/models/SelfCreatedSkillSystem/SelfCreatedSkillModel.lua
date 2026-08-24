local SelfCreatedSkillModel = {}

-- 获取所有书籍
function SelfCreatedSkillModel:getCreateBooks(callback)
    HttpManagerEx:getCreateBooks(function(status, errcode, errmsg, data)
        if status == 200 then
            if errcode == 0 then
                if callback then
                    callback(data)
                end
            else
                PopText(errmsg)
            end
        else
            PopText(errmsg)
        end
    end,IS_SHOW_WAITING)
end

-- 创作招式
function SelfCreatedSkillModel:createZhao(zhaoType,userLv,tujianLv,callback)
    HttpManagerEx:createZhao(zhaoType,userLv,tujianLv,function(status, errcode, errmsg, data)
        if status == 200 then
            if errcode == 0 then
                if MapIsEmpty(data.createdBooks) == false then
                    for i = 1, #data.createdBooks do
                        local book = data.createdBooks[i]
                        book.id = tostring(book.id)
                    end
                end

                if MapIsEmpty(data.point) == false then
                    local points = data.point
                    if points.liquan and tonumber(points.liquan) > 0 then
                        PopText("新春礼券+"..tostring(points.liquan))
                    end
                    if points.daily_point and tonumber(points.daily_point) > 0 then
                        PopText("积分+"..tostring(points.daily_point))
                    end
                end

                if callback then
                    callback(data)
                end
            elseif errcode == 9 then
                print("创作cd中")
            elseif errcode == 10 then
                PopText("今日创作书籍已达上限")
            else
                PopText(errmsg)
            end
        else
            PopText(errmsg)
        end
    end,IS_SHOW_WAITING)
end

-- 书籍创作完成
function SelfCreatedSkillModel:completeBook(skillName,callback)
    HttpManagerEx:completeBook(skillName,function(status, errcode, errmsg, data)
        if status == 200 then
            if errcode == 0 then

                if MapIsEmpty(data.createdBooks) == false then
                    for i = 1, #data.createdBooks do
                        local book = data.createdBooks[i]
                        book.id = tostring(book.id)
                    end
                end

                if callback then
                    callback(data.createdBooks[1])
                end
            elseif errcode == 6 then
                --@desc 重名
                PopText(errmsg)
            else
                PopText(errmsg)
            end
        else
            PopText(errmsg)
        end
    end,IS_SHOW_WAITING)
end

-- 获取招式颜色列表
function SelfCreatedSkillModel:getZhaoColors(callback)
    HttpManagerEx:getZhaoColors(function(status, errcode, errmsg, data)
        if status == 200 then
            if errcode == 0 then
                if callback then
                    callback(data.lists)
                end
            else
                PopText(errmsg)
            end
        else
            PopText(errmsg)
        end
    end,IS_SHOW_WAITING)
end

-- 解锁招式颜色
function SelfCreatedSkillModel:unlockZhaoColor(colorId,callback)
    HttpManagerEx:unlockZhaoColor(colorId,function(status, errcode, errmsg, data)
        print("--------------------SelfCreatedSkillModel:unlockZhaoColor-------------colorId = ",colorId)
        Helper:print_lua_table(data)
        print("-----------------------------end-------------------------------")
        if status == 200 then
            if errcode == 0 then
                if callback then
                    callback(data.lists)
                end
            else
                PopText(errmsg)
            end
        else
            PopText(errmsg)
        end
    end,IS_SHOW_WAITING)
end

-- 获取招式描述列表
function SelfCreatedSkillModel:getZhaoDscs(templateId,callback)
    HttpManagerEx:getZhaoDscs(templateId,function(status, errcode, errmsg, data)
        print("--------------------SelfCreatedSkillModel:getZhaoDscs-------------")
        Helper:print_lua_table(data)
        print("-----------------------------end-------------------------------")
        if status == 200 then
            if errcode == 0 then
                if callback then
                    callback(data.lists)
                end
            else
                PopText(errmsg)
            end
        else
            PopText(errmsg)
        end
    end,IS_SHOW_WAITING)
end

-- 解锁招式系列描述
function SelfCreatedSkillModel:unlockZhaoDsc(xiLieId,zhaoTemplateId,callback)
    HttpManagerEx:unlockZhaoDsc(xiLieId,zhaoTemplateId,function(status, errcode, errmsg,data)
        print("--------------------SelfCreatedSkillModel:unlockZhaoDsc-------------")
        Helper:print_lua_table(data)
        print("-----------------------------end-------------------------------")
        if status == 200 then
            if errcode == 0 then
                if callback then
                    callback(data.lists)
                end
            else
                PopText(errmsg)
            end
        else
            PopText(errmsg)
        end
    end,IS_SHOW_WAITING)
end

-- 获取武学名字词缀列表
function SelfCreatedSkillModel:getSkillNameAffixs(callback)
    HttpManagerEx:getSkillNameAffixs(function(status, errcode, errmsg, data)
        print("--------------------SelfCreatedSkillModel:getSkillNameAffixs-------------")
        Helper:print_lua_table(data)
        print("-----------------------------end-------------------------------")
        if status == 200 then
            if errcode == 0 then
                if callback then
                    callback(data.lists)
                end
            else
                PopText(errmsg)
            end
        else
            PopText(errmsg)
        end
    end,IS_SHOW_WAITING)
end

-- 解锁词缀
function SelfCreatedSkillModel:unlockSkillNameAffixs(nameAffixsId,callback)
    HttpManagerEx:unlockSkillNameAffixs(nameAffixsId,function(status, errcode, errmsg, data)
        print("--------------------SelfCreatedSkillModel:unlockSkillNameAffixs-------------")
        print("status, errcode nameAffixsId = ",status, errcode,nameAffixsId)
        Helper:print_lua_table(data)
        print("-----------------------------end-------------------------------")
        if status == 200 then
            if errcode == 0 then
                if callback then
                    callback(data.lists)
                end
            else
                PopText(errmsg)
            end
        else
            PopText(errmsg)
        end
    end,IS_SHOW_WAITING)
end

-- 设置招式属性
function SelfCreatedSkillModel:setZhaoAttr(params,callback)
    HttpManagerEx:setZhaoAttr(params,function(status, errcode, errmsg, data)
        if status == 200 then
            if errcode == 0 then
                if callback then
                    callback(data)
                end
            else
                PopText(errmsg)
            end
        else
            PopText(errmsg)
        end
    end,IS_SHOW_WAITING)
end

-- 获取创建招式成功率
function SelfCreatedSkillModel:getZhaoSuccessRate(userLv,callback)
    HttpManagerEx:getZhaoSuccessRate(userLv,function(status, errcode, errmsg, data)
        print("--------------------SelfCreatedSkillModel:getZhaoSuccessRate-------------")
        Helper:print_lua_table(data)
        print("-----------------------------end-------------------------------")
        if status == 200 then
            if errcode == 0 then
                if callback then
                    callback(data.successRate)
                end
            else
                PopText(errmsg)
            end
        else
            PopText(errmsg)
        end
    end,IS_SHOW_WAITING)
end

--@desc 学习书籍
function SelfCreatedSkillModel:learnSkillBook(skillId,callback)
    HttpManagerEx:learnSkillBook(skillId,function(status, errcode, errmsg, data)
        print("--------------------SelfCreatedSkillModel:learnSkillBook-------------")
        print("status, errcode, = ",status, errcode)
        Helper:print_lua_table(data)
        print("-----------------------------end-------------------------------")
        if status == 200 then
            if errcode == 0 or errcode == 6 then
                local skill_data = data.createdBooks[1]

                skill_data.id = tostring(skill_data.id)

                if callback then
                    callback(skill_data)
                end
            else
                PopText(errmsg)
            end
        else
            PopText(errmsg)
        end
    end,IS_SHOW_WAITING)
end

function SelfCreatedSkillModel:deleteCompletedBook(skillBookId, callback)
    HttpManagerEx:deleteCompletedBook(
        skillBookId,
        function(status, errcode, errmsg, data)
            if status == 200 then
                if errcode == 0 then
                    callback(errcode, tostring(data.skillId))
                elseif errcode == 1 or errcode == 2 then
                    callback(errcode)
                else
                    PopText(errmsg)
                    return true
                end
            else
                PopText(errmsg)
                return false
            end
        end,
        IS_SHOW_WAITING
    )
end


return SelfCreatedSkillModel0000000000