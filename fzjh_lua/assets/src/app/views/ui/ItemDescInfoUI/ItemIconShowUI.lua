local ItemIconShowUI = class("ItemIconShowUI", cc.Layer)

function ItemIconShowUI:create()
	local p = ItemIconShowUI:new()
	p:init()
	return p
end

function ItemIconShowUI:init()
	self._ui = require("Layer/Dialog/ItemIconShowUI.lua").create()['root']
	self._ui:addTo(self)

	Helper:convertUIByParent(self) -- 获得所有子节点
    self.PageView_1:removeAllPages()
    self.PageView_1:setTouchEnabled(false)
end

function ItemIconShowUI:showUI()
    self:show()
end

function ItemIconShowUI:hideUI()
    self.PageView_1:removeAllPages()
    self:hide()
end

function ItemIconShowUI:setTextName(str)
    self.Text_name:setString(str)
end

function ItemIconShowUI:setButtonLeftVisible(visible)
    self.Button_left:setVisible(visible)
end 

function ItemIconShowUI:setButtonLeftFunc(func)
    self.Button_left:releaseFunc(function()
        if func then
            func()
        end
    end)
end

function ItemIconShowUI:setButtonRightVisible(visible)
    self.Button_right:setVisible(visible)
end 

function ItemIconShowUI:setButtonRightFunc(func)
    self.Button_right:releaseFunc(function()
        if func then
            func()
        end
    end)
end

function ItemIconShowUI:setButtonBackFunc(func)
    self.Button_back:releaseFunc(function()
        if func then
            func()
        end
    end)
end

function ItemIconShowUI:addPage(node)
    self.PageView_1:addPage(node)
end

function ItemIconShowUI:clearPage()
    self.PageView_1:removeAllPages()
end

function ItemIconShowUI:scrollToPage(pageIndex)
    self.PageView_1:scrollToPage(pageIndex)
end

function ItemIconShowUI:initPageNode(node, nodeInfo)
    node.Text_name:setString(nodeInfo.name)
    node.Text_desc:setString(nodeInfo.dsc)
    
    if nodeInfo.isMask then
        node.Image_kuang.Image_icon:setVisible(false)
        local headUI = require("app.views.ui.HeadView.HeadView"):create()
        headUI:setPosition(cc.p(393.96, 762.92))
        node:addChild(headUI)

        headUI:setImageBackgroud(nodeInfo.imgBg)

        if nodeInfo.anim and nodeInfo.animFolderPath then
            headUI:setHeadImageVisible(false)
            headUI:showTheHeadAnim(nodeInfo.anim,nodeInfo.animFolderPath)
            headUI:setHeadAnimVisible(true)
        else
            headUI:setHeadImageVisible(true)
            headUI:setHeadImage(nodeInfo.icon)
            headUI:setHeadAnimVisible(false)
        end

        if nodeInfo.effect then
            headUI:setHeadEffectVisible(true)
            headUI:playEffect(nodeInfo.effect)
        else
            headUI:setHeadEffectVisible(false)
        end
    else
        node.Image_kuang.Image_icon:setVisible(true)
        node.Image_kuang.Image_icon:loadTexture(nodeInfo.texture)
    end
end

function ItemIconShowUI:clonePageNode()
    local panel = self.Panel_1:clone()
    Helper:convertUIByParent(panel)
    return panel
end


return ItemIconShowUI0000000