local RoleFunctionButton = {}

--@RefType [src.app.views.layer.RoleLayer.RoleResConf#RoleResConf]
local RoleResConf = require("app.views.layer.RoleLayer.RoleResConf")

local special_name = {
    ["房屋事务"] = true,
    ["遣散"] = true,
}

function RoleFunctionButton:create()
	local button = Resource:getUIByName("Button_3_0")
	Helper:convertUIByParent(button)
	button.Text_buttonName:enableOutline(cc.c4b(0, 0, 0, 255), 5)
	return button
end


function RoleFunctionButton:createRed()
	local button = Resource:getUIByName("Button_webItem")
	Helper:convertUIByParent(button)
    button.Text_buttonName:enableOutline(cc.c4b(0, 0, 0, 255), 5)
    return button
end


function RoleFunctionButton:createFunction(name,func)
    local btn

    if special_name[name] then
        btn = self:createRed()
    else
        btn = self:create()
    end

    btn.Text_buttonName:setString(name)

    func = Helper:getDef(func,EMPTY_FUNC)

    btn:releaseFunc(function ()
        func()
    end)

    return btn
end

return  RoleFunctionButton0000000