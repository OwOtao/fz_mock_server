-- 观察人物界面,师门和副本都用该界面
-- local Resource = require("app.Resource")
local JiangHuSanYouRoleInfoLayer = class("JiangHuSanYouRoleInfoLayer", require("app.views.base.BaseLayer"))

function JiangHuSanYouRoleInfoLayer:create()
    local p = JiangHuSanYouRoleInfoLayer:new()
    p:init()
    return p
end

function JiangHuSanYouRoleInfoLayer:init()
    self._UI = require("Layer/ActionUI/JiangHuSanYouRoleInfoUI.lua").create()['root']
    self._UI:addTo(self)

    Helper:convertUI(self) -- 获得所有子节点

    self:initUI() -- 初始化UI
    self:hide()
end

function JiangHuSanYouRoleInfoLayer:hideLayer()
    PopupLayerController:hideLayer("JiangHuSanYouRoleInfoLayer",function ( layer )
        layer:hide(true)
    end)
end

function JiangHuSanYouRoleInfoLayer:initUI()
    self:initRichText()
end

function JiangHuSanYouRoleInfoLayer:showLayer(data)
    self.Panel_back:releaseFunc(function()
        self:hideLayer()
    end)

    self:setRoleInfo(data)
    self:show(true)
end

function JiangHuSanYouRoleInfoLayer:initRichText()
    if self.RichText_print then
        if PRINT_MODE == 1 then
            print("进入人物界面，，，，4444444444444444444444，，，，，，，，，")
        end
        self.RichText_print:removeFromParent()
    end

    local x, y = self.Panel_dscArea:getPosition()
    local size = self.Panel_dscArea:getContentSize()

    self.RichText_print = ExtRichTextScroll:create()

    self.Panel_dscArea:getParent():addChild(self.RichText_print)
    self.RichText_print:move(cc.p(x, y))
    self.RichText_print:setSize(size)
    self.RichText_print:setDirection(kCCScrollViewDirectionVertical)
    self.RichText_print:getRichText():setVerticalSpace(10)
end

function JiangHuSanYouRoleInfoLayer:setRoleDsc(dsc)
    -- add by tangjian, 临时解决 richText 问题
    self:initRichText()

    local textColor = cc.c3b(208, 208, 208)
    self.RichText_print:getRichText():removeAllElement()
    self.RichText_print:pushBackText(dsc, textColor, 255, Resource:getFontPath("default"), 42)

    self:delayFunc(0.2, function()
        self:setViewPage()
    end)
end

function JiangHuSanYouRoleInfoLayer:setViewPage()
    if PRINT_MODE == 1 then
        print("进入人物界面，，，，，，，，，，，，，，，，，，，，，，")
    end
    local richText = self.RichText_print:getRichText()
    local height = richText:getNewContentSizeHeight()
    local x, y = self.Panel_dscArea:getPosition()
    local size = self.Panel_dscArea:getContentSize()
    local offsetY = height - size.height
    local sSize = self.ScrollView_view:getContentSize()

    self.Image_di:maxZ()
    self.Image_frame:maxZ()
    self.Image_head:maxZ()
    self.Image_inherit:maxZ()

    if offsetY <= 0 then
        self.RichText_print:move(cc.p(100, 590-300))
        size.height = size.height + 300
        self.RichText_print:setSize(size)
        return
    end


    self.RichText_print:setTouchEnabled(false)
    self.ListView_bottom:setTouchEnabled(false)
    -- add by XiaoZhiWei 2017/05/19 11:39:23 字数超出,则变更为滚动
    if height > 1050 then
        height = 1050
        offsetY = 1050 - size.height
        self.RichText_print:setTouchEnabled(true)
        self:delayFunc(0.25,function ()
            self.RichText_print:jumpToTop()
        end)
    end

    size.height = height
    sSize.height = sSize.height + offsetY
    self.RichText_print:setSize(size)

    self.RichText_print:move(cc.p(100, 590 - offsetY))
    self.ListView_bottom:move(cc.p(526, 590 - offsetY - 30))
    self.ScrollView_view:setInnerContainerSize(sSize)
end

--人物详细资料界面
function JiangHuSanYouRoleInfoLayer:setRoleInfo(data)
    self:reset()
    -- self.ListView_bottom:removeAllItems()
    local role = self:setRoleFromData(data)
    local inheritCount = role:getAttr("inheritCount")
    local title = switch(inheritCount, 
    {
        [1] = "HIB",
        [2] = "HIC",
        [3] = "HIG",
        [4] = "HIY",
        [5] = "HIW",
        [6] = "PNK",
        default = "DWT"
    })..tostring(role.name)

    self.Text_title:setString(role.name)
    self.Text_title:setTextHorizontalAlignment(0)


    -- -- 可装备的物品
    local itemList = assert(require("script.map.mapItemAttr"))
    local equipmentList = itemList["equipment"]
	local cl = "WHT"
    self.sex = "他"
    if data.sex == "男" then
        self.sex = "他"
    elseif data.sex == "女" then
        self.sex = "她"
    end
    
    local desc = data.story..cl..self.sex.."身上装备着：\n"

    local i = 1
    local equipment = data["equipment"..i]
    while equipment ~= nil do
    	desc = desc .. "	□" .. equipmentList[equipment].name .. cl .. "\n"
    	i = i + 1
    	equipment = data["equipment"..i]
    end
    
    self:setRoleDsc(desc)

    --头像
    self.Image_di:setVisible(true)
    self.Image_frame:setVisible(true)
    self.Image_head:setVisible(true)

    local present = require("app.presenters.HeadView.HVIPresent"):create(self.Image_head,{path = data.pic})
    present:showHead()

    self.Image_back:setVisible(true)

    local imagePath = "Image/UI/RoleUI/RoeBack.png"
    self.Image_back:loadTexture(imagePath)

    -- 设置图片大小
    local texture = cc.TextureCache:getInstance():getTextureForKey(imagePath);
    self.Image_back:setSize(texture:getContentSize())

    imagePath = role:getFaceFrame()
    self.Image_frame:loadTexture(imagePath)

     -- 设置图片大小
    local texture = cc.TextureCache:getInstance():getTextureForKey(imagePath);
    self.Image_frame:setSize(texture:getContentSize())

    -- self:playRoleSound(role)

    -- add by XiaoZhiWei 2017/05/15 18:18:18 传承图标设置
    local image = switch(inheritCount, 
    {
        [1] = "Image/UI/RankingUI/mingshizhihou.png",
        [2] = "Image/UI/RankingUI/jiaxueshenhou.png",
        [3] = "Image/UI/RankingUI/shenshixianhe.png",
        [4] = "Image/UI/RankingUI/mingshihaoting.png",
        [5] = "Image/UI/RankingUI/chuanshimingmen.png",
        default = ""
    })
    if image == "" then
        self.Image_inherit:setVisible(false)
    else
        self.Image_inherit:setVisible(true)
        self.Image_inherit:loadTexture(image)    
    end
end

--设置玩家资料属性
function JiangHuSanYouRoleInfoLayer:setRoleFromData(data)
    local role = Helper:tableCover(Role:create(), data)
    return role
end
--重置界面
function JiangHuSanYouRoleInfoLayer:reset()
    self.ListView_bottom:removeAllItems() -- 清除功能列表
    self.Text_title:setTextHorizontalAlignment(1)
    self.Image_di:setVisible(false)
    self.Image_frame:setVisible(false)
    self.Image_head:setVisible(false)
end

Helper:classDefNodeGetInstance(JiangHuSanYouRoleInfoLayer)

return JiangHuSanYouRoleInfoLayer
000