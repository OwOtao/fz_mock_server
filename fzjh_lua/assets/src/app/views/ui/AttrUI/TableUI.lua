local Item = require("app.models.item.Item")
local TableUI = class("TableUI", cc.Layer)

function TableUI:create()
    local p = TableUI:new()
    p:init()
    return p
end

local tbs = {
    _AttrLayer = "roleAttr",
    _JiangHuLayer = "jianghuAttr",
    _BagLayer = "bag"
}

function TableUI:init()
    self._round = require("Layer/AttrUI/TableUI.lua").create()["root"]
    self._round:addTo(self)

    Helper:convertUI(self) -- 获得所有子节点
end

function TableUI:updateSkin(skin_config)
    if skin_config.AttrTabpic then
        self.Sprite_table:setTexture(skin_config.AttrTabpic)
    end

    if skin_config.Attrclickpic then
        for _, v in pairs(tbs) do
            local node = self["Image_" .. v]
            node:setScale9Enabled(true)
            node:setCapInsets({x = -48, y = 7, width = 120, height = 11})
            node:loadTexture(skin_config.Attrclickpic, 0)
        end
    end
end

local lightColor = cc.c4b(0, 179, 230, 255)
local darkColor = cc.c4b(208, 208, 208, 255)

function TableUI:showImage(image, anim, posX, posY)
    local actionTag = image:getActionTagByName("move")
    image:stopActionByTag(actionTag)
    if anim then
        image:setOpacity(0)
        image:move(cc.p(posX, posY + 10))
        local action =
            cc.Sequence:create(
            cc.Spawn:create(cc.MoveTo:create(UI_ANIM_DURATION, cc.p(posX, posY)), cc.FadeIn:create(UI_ANIM_DURATION)),
            cc.CallFunc:create(
                function()
                    -- self:show()
                end
            )
        )
        action:setTag(actionTag)
        image:runAction(action)
    else
        image:move(cc.p(posX, posY))
        image:resumeSelfAndChildren()
    end
end

function TableUI:hideImage(image, anim)
end

function TableUI:darkTable(name)
end
function TableUI:lightTable(name)
    for k, v in pairs(tbs) do
        if k == name then
            self["Image_" .. v]:setVisible(true)
            self["Text_" .. v]:setTextColor(lightColor)
            local posX, posY = self["Text_" .. v]:getPositionX(), self["Text_" .. v]:getPositionY()
            self:showImage(self["Image_" .. v], true, posX, posY)
        else
            self["Text_" .. v]:setTextColor(darkColor)
            self["Image_" .. v]:setVisible(false)
        end
    end
end

function TableUI:onResume()
end

function TableUI:getUINode(name)
    return self[name]
end

return TableUI
0000000000000000