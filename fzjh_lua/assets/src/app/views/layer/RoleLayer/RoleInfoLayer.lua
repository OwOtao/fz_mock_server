-- 观察人物界面,师门和副本都用该界面
local Resource = require("app.Resource")
-- local User = require("app.models.user.User")
-- local Role = require("app.models.role.Role")
-- local Task = require("app.models.task.Task")
-- local Npc = require("app.models.npc.Npc")
-- local Map = require("app.models.map.Map")
-- local Item = require("app.models.item.Item")
local RoleInfoLayer = class("RoleInfoLayer", require("app.views.base.BaseLayer"))

function RoleInfoLayer:create()
    local p = RoleInfoLayer:new()
    p:init()
    return p
end

function RoleInfoLayer:init()
    self._UI = require("Layer/RoleUI/RoleInfoUI.lua").create()["root"]
    self._UI:addTo(self)

    Helper:convertUI(self) -- 获得所有子节点

    self:initUI() -- 初始化UI

    self.Panel_back:releaseFunc(
        function()
            PopupLayerController:hideLayer(
                "RoleInfoLayer",
                function()
                    self:hide(true)
                end
            )
        end
    )

    self:hide() -- 隐藏自身
end

function RoleInfoLayer:initUI()
    self:initRichText()

    local headUI = require("app.views.ui.HeadView.HeadView"):create()

    headUI:setName("headView")

    headUI:setPosition(cc.p(self.Node_HeadPos:getPosition()))

    headUI:setLocalZOrder(1)

    headUI:setScale(0.8)

    self.Node_HeadPos:getParent():addChild(headUI)
end

function RoleInfoLayer:initRichText()
    if self.RichText_print then
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

    self.RichText_print:setLocalZOrder(0)
end

function RoleInfoLayer:setRoleDsc(dsc)
    -- add by tangjian, 临时解决 richText 问题
    self:initRichText()

    local textColor = cc.c3b(208, 208, 208)
    -- self.RichText_print:getRichText():removeAllElement()
    self.RichText_print:pushBackText(dsc, textColor, 255, Resource:getFontPath("default"), 42)

    self:delayFunc(
        0,
        function()
            self:setViewPage()
        end
    )
end

function RoleInfoLayer:setViewPage()
    local richText = self.RichText_print:getRichText()
    local height = richText:getNewContentSizeHeight()
    local x, y = self.Panel_dscArea:getPosition()
    local size = self.Panel_dscArea:getContentSize()
    local offsetY = height - size.height
    local sSize = self.ScrollView_view:getContentSize()

    if offsetY <= 0 then
        self.RichText_print:move(cc.p(100, 590))
        return
    end

    self.RichText_print:setTouchEnabled(false)
    self.ListView_bottom:setTouchEnabled(false)
    -- add by XiaoZhiWei 2017/05/19 11:39:23 字数超出,则变更为滚动
    if height > 1050 then
        height = 1050
        offsetY = 1050 - size.height
        self.RichText_print:setTouchEnabled(true)
        self:delayFunc(
            0.25,
            function()
                self.RichText_print:jumpToTop()
                self.Image_inherit:maxZ()
            end
        )
    end

    size.height = height
    sSize.height = sSize.height + offsetY
    self.RichText_print:setSize(size)

    self.RichText_print:move(cc.p(100, 590 - offsetY))
    self.ListView_bottom:move(cc.p(526, 590 - offsetY - 30))
    self.ScrollView_view:setInnerContainerSize(sSize)
end

function RoleInfoLayer:setInfo(data)
    print("data.species = " .. tostring(data.species))
    if data.species == "人" or data.species == nil then
        self:setRoleInfo(data)
    else
        self:setOtherInfo(data)
    end
end

--人物详细资料界面
function RoleInfoLayer:setRoleInfo(data)
    self:reset()
    self.ListView_bottom:removeAllItems()
    local role = self:setRoleFromData(data)
    local inheritCount = role:getAttr("inheritCount")
    local title =
        switch(
        inheritCount,
        {
            [1] = "HIB",
            [2] = "HIC",
            [3] = "HIG",
            [4] = "HIY",
            [5] = "HIW",
            default = "DWT"
        }
    ) .. tostring(role.name)

    self.Text_title:setString(title)
    self.Text_title:setTextHorizontalAlignment(0)
    self:setRoleDsc(role:getRoleInfoDsc(role))
    if User:getRoleAttr("onlyId") == role:getAttr("onlyId") then
        if PRINT_MODE == 1 then
        end
        self.Text_id:setVisible(true)
        self.Text_id:setString("ID：" .. tostring(role:getAttr("userid")))
    else
        self.Text_id:setVisible(false)
    end

    local headView = self.Panel_attr:getChildByName("headView")

    headView:setVisible(true)
    
    --@RefType [src.app.presenters.HeadView.HeadViewPresenter#HeadViewPresenter]
    local headViewPresenter = require("app.presenters.HeadView.HeadViewPresenter"):create(role, headView)

    self.Image_back:setVisible(true)

    local imagePath = role:getFaceInfoFrame()
    self.Image_back:loadTexture(imagePath)

    self:playRoleSound(role)

    -- add by XiaoZhiWei 2017/05/15 18:18:18 传承图标设置
    local image =
        switch(
        inheritCount,
        {
            [1] = "Image/UI/RankingUI/mingshizhihou.png",
            [2] = "Image/UI/RankingUI/jiaxueshenhou.png",
            [3] = "Image/UI/RankingUI/shenshixianhe.png",
            [4] = "Image/UI/RankingUI/mingshihaoting.png",
            [5] = "Image/UI/RankingUI/chuanshimingmen.png",
            default = ""
        }
    )
    if image == "" then
        self.Image_inherit:setVisible(false)
    else
        self.Image_inherit:setVisible(true)
        self.Image_inherit:loadTexture(image)
    end
end

--其他单位资料界面
function RoleInfoLayer:setOtherInfo(data)
    self:reset()
    self.ListView_bottom:removeAllItems()
    local unit = self:setRoleFromData(data)
    local title = unit.name

    self.Text_title:setString(title)
    self.Text_title:setTextHorizontalAlignment(0)
    self:setRoleDsc("\n" .. unit.dsc)

end

--设置玩家资料属性
function RoleInfoLayer:setRoleFromData(data)
    local role = Helper:tableCover(Role.new(), data)
    role:init()
    role:initMap()
    
    return role
end

function RoleInfoLayer:playRoleSound(role)
    local age, sex, zhengQi = role:getAttr("age"), role:getAttr("sex"), role:getFinalAttr("zhengqi")
    local effectName = ""

    if sex == "男" then
        if age < 15 then
            effectName = "nianShaoNormalNan"
        elseif age < 30 then
            if zhengQi >= 0 then
                effectName = "nianQingZhengNan"
            else
                effectName = "nianQingXieNan"
            end
        elseif age < 50 then
            if zhengQi >= 0 then
                effectName = "chengShuZhengNan"
            else
                effectName = "chengShuXieNan"
            end
        elseif age >= 50 then
            if zhengQi >= 0 then
                effectName = "nianLaoZhengNan"
            else
                effectName = "nianLaoXieNan"
            end
        end
    elseif sex == "女" then
        if age < 15 then
            effectName = "nianShaoNormalNv"
        elseif age < 50 then
            if zhengQi >= 0 then
                effectName = "nianQingZhengNv"
            else
                effectName = "nianQingXieNv"
            end
        elseif age >= 50 then
            if zhengQi >= 0 then
                effectName = "nianZhangZhengNv"
            else
                effectName = "nianZhangXieNv"
            end
        end
    else
        -- effectName = "nianShaoNormalNv"
    end

    -- if zhengQi == 0 then
    -- 	if sex == "男" then
    -- 		effectName = "nianShaoNormalNan"
    -- 	elseif sex == "女" then
    -- 		effectName = "nianShaoNormalNv"
    -- 	else
    -- 		effectName = "nianShaoNormalNv"
    -- 	end
    -- elseif zhengQi > 0 then
    -- 	if sex == "男" then
    -- 		if age < 15 then
    -- 			effectName = "nianShaoNormalNan"
    -- 		elseif age < 30 then
    -- 			effectName = "nianQingZhengNan"
    -- 		elseif age < 50 then
    -- 			effectName = "chengShuZhengNan"
    -- 		elseif age >= 50 then
    -- 			effectName = "nianLaoZhengNan"
    -- 		end
    -- 	else
    -- 		if age < 15 then
    -- 			effectName = "nianShaoNormalNv"
    -- 		elseif age < 30 then
    -- 			effectName = "nianQingZhengNv"
    -- 		elseif age < 50 then
    -- 			effectName = "nianQingZhengNv"
    -- 		elseif age >= 50 then
    -- 			effectName = "nianZhangZhengNv"
    -- 		end
    -- 	end
    -- else
    -- 	if sex == "男" then
    -- 		if age < 15 then
    -- 			effectName = "nianShaoNormalNan"
    -- 		elseif age < 30 then
    -- 			effectName = "nianQingXieNan"
    -- 		elseif age < 50 then
    -- 			effectName = "chengShuXieNan"
    -- 		elseif age >= 50 then
    -- 			effectName = "nianLaoXieNan"
    -- 		end
    -- 	else
    -- 		if age < 15 then
    -- 			effectName = "nianShaoNormalNv"
    -- 		elseif age < 30 then
    -- 			effectName = "nianQingXieNv"
    -- 		elseif age < 50 then
    -- 			effectName = "nianQingXieNv"
    -- 		elseif age >= 50 then
    -- 			effectName = "nianZhangXieNv"
    -- 		end
    -- 	end
    -- end

    Audio:playEffect(effectName)
end

--重置界面
function RoleInfoLayer:reset()
    self.ListView_bottom:removeAllItems() -- 清除功能列表
    self.Text_title:setTextHorizontalAlignment(1)

    self.Panel_attr:getChildByName("headView"):setVisible(false)
end

Helper:classDefNodeGetInstance(RoleInfoLayer)

return RoleInfoLayer
00000000000