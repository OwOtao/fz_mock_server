local DengLuJiangLiLayer = class("DengLuJiangLiLayer", LayerEx)
function DengLuJiangLiLayer:create()
    local p = DengLuJiangLiLayer:new()
    p:init()
    return p
end
function DengLuJiangLiLayer:init()
    local UI = require("Layer/Dialog/DengLuJiangLiUI.lua").create()["root"]
    UI:addTo(self)
    Helper:convertUIByParent(self) -- 获得所有子节点
end

local filter = {
    ["meiyu"] = true,
    ["zjjifen"] = true,
    ["gongxiandian"] = true,
    ["yinpiao"] = true,
}

-- "item":{"exp":10000,"gold":888}
function DengLuJiangLiLayer:showlayer(dsc, items,callback)
    self:show()

    local text = self:getDesc(items)

    self.Text_Desc:setString(text)

    self.Button_1:setVisible(true)
    self.Button_1:releaseFunc(
        function()
            HttpManagerEx:getLoginYuanbao(
                function(status, errcode, errmsg, data)
                    if status == 200 then
                        if errcode == 0 then
                            if data.item then
                                local role = User:getRole()
                                --记录登陆领取时间和改变标记
                                role:setDayFlag("login_reward", 1)
                                role:setFlag("pop_login", GetTime())

                                for k, v in pairs(data.item) do
                                    if not filter[k] then
                                        role:addAttr(k, v)
                                    end
                                    PopText(role:getCHAttrName(k) .. " +" .. v)
                                end
                            end
                        else
                            print(errcode, errmsg)
                        end
                    else
                        PopText(errmsg)
                    end
                end,
                IS_SHOW_WAITING
            )

            if callback then
                callback()
            end
            self:hideLayer()
        end
    )
end

function DengLuJiangLiLayer:getDesc(items)
    local text = ""

    for name, value in pairs(items) do
        local dsc = ""

        dsc = User:getRole():getCHAttrName(name) .. " +" .. value .. "\n"

        text = text .. dsc
    end

    return text
end


function DengLuJiangLiLayer:hideLayer()
    PopupLayerController:hideLayer(
        "DengLuJiangLiLayer",
        function(layer)
            layer:hide()
        end
    )
end

Helper:classDefNodeGetInstance(DengLuJiangLiLayer)
return DengLuJiangLiLayer
000