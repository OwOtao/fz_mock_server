local NewClass = require("third.class.NewClass")
local ISelfCreatedSkillPropSystem = require("app.models.SelfCreatedSkillSystem.ISelfCreatedSkillPropSystem")
local SelfCreatedSkillManager = require("app.models.SelfCreatedSkillSystem.SelfCreatedSkillManager.SelfCreatedSkillManager")

local SelfCreatedSkillPropSystem = {}

function SelfCreatedSkillPropSystem:create()
    return SelfCreatedSkillPropSystem.new()
end

function SelfCreatedSkillPropSystem:setRole(role)
    self.__role = role
end

function SelfCreatedSkillPropSystem:getRole()
    return self.__role
end

--@desc 获取道具列表
--@propType:  1创作道具   2改良道具
function SelfCreatedSkillPropSystem:getPropList(propType,callback)
    HttpManagerEx:getPropList(propType,function(status, errcode, errmsg, data)
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

--@desc 使用创作道具
function SelfCreatedSkillPropSystem:useCreateProp(propId,userLv,skillId,callback)
    HttpManagerEx:useCreateProp(propId,userLv,skillId,function(status, errcode, errmsg, data)
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

--@desc 使用改良道具
function SelfCreatedSkillPropSystem:useImproveProp(propId,userLv,zhaoIndex,skillDataId,callback)
    HttpManagerEx:useImproveProp(propId,userLv,zhaoIndex,skillDataId,function(status, errcode, errmsg, data)
        if status == 200 then
            if errcode == 0 then
				callback(true,data)
            else
				callback(false,errmsg)
            end
        else
			callback(false,errmsg)
        end
    end,IS_SHOW_WAITING)
end

--@desc 添加道具
function SelfCreatedSkillPropSystem:addProp(propId,count)
end

return NewClass("SelfCreatedSkillPropSystem", { ISelfCreatedSkillPropSystem }, SelfCreatedSkillPropSystem)0000000000