local LoginPopLayer = class("LoginPopLayer", LayerEx)

function LoginPopLayer:create()
    local p = LoginPopLayer:new()
    p:init()
    return p
end

function LoginPopLayer:init()
    local UI = require("Layer/Dialog/LoginPopUI.lua").create()["root"]
    UI:addTo(self)
    Helper:convertUIByParent(self) -- 获得所有子节点
end

function LoginPopLayer:hideLayer()
    PopupLayerController:hideLayer(
        "LoginPopLayer",
        function(layer)
            layer:hide()
        end
    )
end

function LoginPopLayer:showLayer(conf, callback)
    callback = callback or EMPTY_FUNC

    if conf ~= nil then
        self:showDialog(conf, callback)
    else
        callback()
        self:hideLayer()
        return
    end

end

function LoginPopLayer:showDialog(conf, callback)

    if conf.img ~= nil then
        self.Image_back:loadTexture(conf.img, 0)
    else
        self.Image_back:loadTexture("Image/UI/MainUI/loginReward.png", 0)
    end

    if conf.btnImg ~= nil then
        self.Button_Yes:loadTextureNormal(conf.btnImg,0)
    else
        self.Button_Yes:loadTextureNormal("Image/UI/MapUI/anniu05.png")
    end

    self.Button_Yes.Text_name:setString(conf.btnName or "确定")

    self.Text_Desc:setString(conf.desc or "")

    self.Button_Yes:releaseFunc(
        function()
            if conf.btnFunc then
                conf.btnFunc()
            end

            callback()

            self:hideLayer()
        end
    )

    self:show()
end

Helper:classDefNodeGetInstance(LoginPopLayer)
return LoginPopLayer
0