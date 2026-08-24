local interface = require("third.class.interface")

local ISelfCreatedSkillPropSystem = {}

function ISelfCreatedSkillPropSystem:setRole(role)
end

function ISelfCreatedSkillPropSystem:getRole()
end

function ISelfCreatedSkillPropSystem:getPropList(propType,callback)
end

function ISelfCreatedSkillPropSystem:useCreateProp(propId,userLv,skillDataId,callback)
end

function ISelfCreatedSkillPropSystem:useImproveProp(propId,userLv,zhaoIndex,skillDataId,callback)
end

function ISelfCreatedSkillPropSystem:addProp(propId,count)
end

return interface("ISelfCreatedSkillPropSystem", ISelfCreatedSkillPropSystem)0000000000