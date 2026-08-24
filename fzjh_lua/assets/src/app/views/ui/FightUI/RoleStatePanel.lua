local RoleStatePanelActiveZhaoReadyItem = require("app.views.ui.FightUI.RoleStatePanelActiveZhaoReadyItem")

local RoleStatePanel = {}

local oldPrint = print

local function print(...)
    if PRINT_MODE == 1 then
        oldPrint(...)
    else
    end
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2016/11/14 11:07:55
-- @desc 创建左边角色状态栏
function RoleStatePanel:createLeftRoleStatePanel()
    local p = Resource:getUIByName("ListView_RoleFightStateLeft")
    Helper:convertUIByParent(p)
    p = Helper:tableCover(p, clone(RoleStatePanel))
    p:init(1)
    return p
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2016/11/14 11:07:58
-- @desc 创建右边角色状态栏
function RoleStatePanel:createRightRoleStatePanel()
    local p = Resource:getUIByName("ListView_RoleFightStateRight")
    Helper:convertUIByParent(p)
    p = Helper:tableCover(p, clone(RoleStatePanel))
    p:init(-1)
    return p
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2016/11/14 11:08:06
-- @desc 初始化
function RoleStatePanel:init(direction)
    -- 成员变量定义 add by TangJian 2017/02/21 20:05:05
    self._effects = {}
    self._direction = 1
    
    self:setDirection(direction)
    
    
    -- 增加一个新的UI, 用来放玩家的增益状态图标
    -- self._buffIconArea = ccui.Widget:create()
    self._buffIconArea = ccui.Layout:create()
    -- self._buffIconArea:setBackGroundColorType(1)
    -- self._buffIconArea:setBackGroundColor(cc.c3b(255, 0, 0))
    self:addChild(self._buffIconArea)
    
    -- ui初始化 add by TangJian 2017/02/21 20:05:07
    self.Image_qiFrame.Text_qi:setTextColor(cc.c4b(255, 255, 255))
    -- 气血文字描边
    self.Image_qiFrame.Text_qi:enableOutline(cc.c4b(0, 0, 0), 3)
    
    -- 内力文字描边
    self.Image_neiliFrame.Text_neili:setTextColor(cc.c4b(255, 255, 255))
    self.Image_neiliFrame.Text_neili:enableOutline(cc.c4b(0, 0, 0), 3)
    
    -- -- 气血条动画开启
    self.Image_qiFrame.LoadingBar_qi:setAnimEnable(true)
    self.Image_qiFrame.LoadingBar_qiMax:setAnimEnable(true)
    
    -- 内力条动画开启
    self.Image_neiliFrame.LoadingBar_neili:setAnimEnable(true)
    self.Image_neiliFrame.LoadingBar_neiliMax:setAnimEnable(true)
    
    local effects =
        {
            {
                tag = "毒d",
                isBuff = true
            },
            {
                tag = "毒d",
                isBuff = false
            },
            {
                tag = "毒d",
                isBuff = false
            },
            {
                tag = "毒d",
                isBuff = false
            },
            {
                tag = "毒d",
                isBuff = false
            },
            {
                tag = "毒d",
                isBuff = false
            },
            {
                tag = "毒d",
                isBuff = false
            },
            {
                tag = "毒d",
                isBuff = false
            },
            {
                tag = "毒d",
                isBuff = false
            },
            {
                tag = "毒d",
                isBuff = false
            },
        }
    
    
    
    self:initActiveZhaoReadyArea()
    self:setScrollBarEnabled(false)

-- self:setEffects(effects)
-- 体力条动画开启
-- self.LoadingBar_tili:setAnimEnable(true)
-- self.LoadingBar_tili_back = self.LoadingBar_tili:clone()
-- self.LoadingBar_tili:addChild(self.LoadingBar_tili_back)
-- self.LoadingBar_tili_back:setColor(cc.c3b(255, 0, 0))
-- self.LoadingBar_tili_back:setPositionY(self.LoadingBar_tili_back:getSize().height / 2)
-- self.LoadingBar_tili_back:setZ(-1)
-- self.LoadingBar_tili_back:setAnimEnable(true)
-- self.LoadingBar_tili_back:runAction(cc.RepeatForever:create(cc.Blink:create(1, 10)))
-- self.LoadingBar_tili:runAction(cc.RepeatForever:create(cc.Blink:create(1, 10)))
-- self.LoadingBar_tili_back:runAction(cc.RepeatForever:create(cc.Blink:create(1, 10)))
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2016/11/14 11:08:23
-- @desc 设置名称
function RoleStatePanel:setName(name)
    self.Text_name:setString(name)
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2017/02/25 11:54:35
-- @desc 设置方向
function RoleStatePanel:setDirection(direction)
    direction = switch(direction, {[1] = 1, [-1] = -1, default = 1})
    if self._direction ~= direction then
        self._direction = direction
    end
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2017/02/25 15:46:19
-- @desc 得到方向
function RoleStatePanel:getDirection()
    return switch(self._direction, {[1] = 1, [-1] = -1, default = 1})
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2016/11/14 11:08:12
-- @desc 设置气血
function RoleStatePanel:setQi(qi, currQiMax, qiMax)
    assert(type(qi) == "number", "qi = " .. tostring(qi))
    assert(type(currQiMax) == "number", "currQiMax = " .. tostring(currQiMax))
    assert(type(qiMax) == "number", "qiMax = " .. tostring(qiMax))
    qi, currQiMax, qiMax = math.floor(qi), math.floor(currQiMax), math.floor(qiMax)
    qi, currQiMax, qiMax = math.max(qi, 0), math.max(currQiMax, 0), math.max(qiMax, 0)
    -- add by XiaoZhiWei 2017/08/16 18:17:45 取整问题,修复气血显示0的问题
    if qi > 0 and qi < 1 then
        qi = 1
    end
    
    -- print("Helper:getRange(100 * qi / qiMax, 0, 100) = ", Helper:getRange(100 * qi / qiMax, 0, 100))
    self.Image_qiFrame.LoadingBar_qi:setPercent(Helper:getRange(100 * qi / qiMax, 0, 100))
    self.Image_qiFrame.LoadingBar_qiMax:setPercent(Helper:getRange(100 * currQiMax / qiMax, 0, 100))
    self.Image_qiFrame.Text_qi:setString(Helper:getRange(qi, 0, NUMBER_MAX) .. " / " .. currQiMax)
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2016/11/14 11:08:28
-- @desc 设置角色内力
function RoleStatePanel:setNeili(neili, neiliMax)
    assert(type(neili) == "number")
    assert(type(neiliMax) == "number")
    neili, neiliMax = math.floor(neili), math.floor(neiliMax)
    neili, neiliMax = math.max(neili, 0), math.max(neiliMax, 0)
    
    self.Image_neiliFrame.LoadingBar_neili:setPercent(Helper:getRange(100 * neili / neiliMax, 0, 100))
    self.Image_neiliFrame.LoadingBar_neiliMax:setPercent(Helper:getRange(100 * neili / neiliMax, 0, 100))
    self.Image_neiliFrame.Text_neili:setString(Helper:getRange(neili, 0, NUMBER_MAX) .. " / " .. neiliMax)
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2016/11/14 11:08:33
-- @desc 设置体力
function RoleStatePanel:setTili(tili, tiliMax)
    assert(type(tili) == "number")
    assert(type(tiliMax) == "number")
    tili, tiliMax = math.floor(tili), math.floor(tiliMax)
    tili, tiliMax = math.max(tili, 0), math.max(tiliMax, 0)
    
    self.LoadingBar_tili:setPercent(Helper:getRange(100 * tili / tiliMax, 0, 100))

-- self.LoadingBar_tili_back:uniqueDelayFunc("self.LoadingBar_tili_back:setPercent", 0.5, function()
--     self.LoadingBar_tili_back:setPercent(Helper:getRange(100 * tili / tiliMax, 0, 100))
-- end)
end

--[[
    @desc: 设置角色状态图标
    author:TangJian
    time:2022-03-23 16:20:23
    --@stateIcons: 
    @return:
]]
function RoleStatePanel:setStateIcons(stateIcons)
    self._buffIconArea:removeAllChildren()
    
    local itemCount = #stateIcons
    local colCount = 5
    local rowCount = math.ceil(itemCount/colCount)

    local testIcon = Resource:getBuffIconImage("毒d")
    local iconSize = testIcon:getContentSize()
    
    if PRINT_MODE == 1 then
        print("rowCount = ", rowCount)
    end
    
    
    self._buffIconArea:setContentSize(cc.size(self:getContentSize().width, rowCount * (iconSize.height)))
    
    -- if rowCount == 1 then
    --     rowCount = 2
    -- end
    Helper:foreachItemInMatrixArea(self._buffIconArea:getContentSize(), iconSize, colCount, rowCount, 0, 0,
        function(index, ix, iy, x, y)
            if index <= itemCount then
                local stateIcon = stateIcons[index]
                print("stateIcon.tag = ", stateIcon.tag)
                local icon = Resource:getBuffIconImage(stateIcon.tag)
                if icon then
                    self._buffIconArea:addChild(icon)
                    icon:setPosition(cc.p(x, y))
                    
                    -- 添加左上角数字 add by TangJian 2017/04/06 18:38:14
                    do
                        if stateIcon.leftUpNum > 1 then
                            local text = ccui.Text:create()
                            icon:addChild(text)
                            
                            text:setAnchorPoint(cc.p(0, 0.1))
                            
                            text:setFontName(Resource:getFontPath("default"))
                            
                            text:setPositionX(0)
                            -- text:setPositionX(-0)
                            -- text:setPositionY(icon:getContentSize().height)
                            text:setPositionY(0)
                            
                            local count = Helper:getDef(stateIcon.leftUpNum, 1)
                            
                            -- text:setString(2)
                            text:setString(count)
                            text:setFontSize(32)
                            
                            -- text:setTextColor(textStyle.fontColor)
                            text:enableOutline(cc.c4b(0, 0, 0, 255), 5)
                        end
                    end
                    
                    -- 添加层数
                    do
                        if stateIcon.count > 1 then
                            local text = ccui.Text:create()
                            icon:addChild(text)
                            
                            text:setAnchorPoint(cc.p(1, 0.1))
                            
                            text:setFontName(Resource:getFontPath("default"))
                            
                            text:setPositionX(icon:getContentSize().width)
                            text:setPositionY(0)
                            
                            local count = Helper:getDef(stateIcon.count, 1)
                            
                            -- text:setString(2)
                            text:setString(count)
                            text:setFontSize(32)
                            
                            -- text:setTextColor(textStyle.fontColor)
                            text:enableOutline(cc.c4b(0, 0, 0, 255), 5)
                        end
                    end
                end
            end
        end, self._direction)
    
    
    -- 重新整理ListView
    self:requestDoLayout()
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2017/02/25 15:26:17
-- @desc 初始化主动技能准备区域
function RoleStatePanel:initActiveZhaoReadyArea()
    -- 数据部分初始化
    self._activeZhaoReadyList = {}
    
    self._currActiveZhaoReadyItem = nil

-- ui部分初始化
-- self._activeZhaoReadyArea = ccui.Layout:create()
-- self._activeZhaoReadyArea:setContentSize(cc.size(self:getContentSize().width, 0))
-- self:addChild(self._activeZhaoReadyArea)
-- self._activeZhaoReadyArea:setSizeHeight(200)
-- self._activeZhaoReadyArea:setBackGroundColorType(1)
-- self._activeZhaoReadyArea:setBackGroundColor(cc.c3b(255, 0, 0))
-- self:addActiveZhaoReady("测试")
-- PopText("测试")
-- self._activeZhaoReadyArea:schedule(function()
--     -- PopText("测试")
-- -- self:removeActiveZhaoReady()
-- -- self:addActiveZhaoReady("测试")
-- end, 2)
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2017/02/25 15:29:00
-- @desc 添加主动技能准备
function RoleStatePanel:readyActiveZhao(zhaoName)
    if type(zhaoName) ~= "string" then
        return
    end
    
    if self._activeZhaoReadyArea == nil then
        self._activeZhaoReadyArea = ccui.Layout:create()
        self._activeZhaoReadyArea:setContentSize(cc.size(self:getContentSize().width, 0))
        self:addChild(self._activeZhaoReadyArea)
    end
    
    if self._currActiveZhaoReadyItem == nil then
        local roleStatePanelActiveZhaoReadyItem = RoleStatePanelActiveZhaoReadyItem:create()
        roleStatePanelActiveZhaoReadyItem:setDirection(self._direction)
        self._activeZhaoReadyArea:addChild(roleStatePanelActiveZhaoReadyItem)
        -- :addChild(roleStatePanelActiveZhaoReadyItem)
        -- self._activeZhaoReadyArea:setBackGroundColorType(1)
        -- self._activeZhaoReadyArea:setBackGroundColor(cc.c3b(255, 0, 0))
        self._activeZhaoReadyArea:setSizeHeight(roleStatePanelActiveZhaoReadyItem:getSizeHeight() * 3)
        
        roleStatePanelActiveZhaoReadyItem:setTitle(zhaoName)
        
        local totalWidth = math.max(roleStatePanelActiveZhaoReadyItem:getTitleSize().width * roleStatePanelActiveZhaoReadyItem:getLastScale(), roleStatePanelActiveZhaoReadyItem:getContentSize().width)
        
        local offsetX = 30
        switch(self:getDirection(),
            {
                [1] = function()
                    roleStatePanelActiveZhaoReadyItem:setAnchorPoint(cc.p(0.5, 0.5))
                    roleStatePanelActiveZhaoReadyItem:move(totalWidth / 2, self._activeZhaoReadyArea:getSizeHeight() / 2)
                end,
                [-1] = function()
                    roleStatePanelActiveZhaoReadyItem:setAnchorPoint(cc.p(0.5, 0.5))
                    roleStatePanelActiveZhaoReadyItem:move(self:getSizeWidth() - totalWidth / 2, self._activeZhaoReadyArea:getSizeHeight() / 2)
                end,
                default = function()
                    error("RoleStatePanel:addActiveZhaoReady()")
                end
            })
        
        self._currActiveZhaoReadyItem = roleStatePanelActiveZhaoReadyItem
        
        self._currActiveZhaoReadyItem:show1(function()
            -- PopText("显示完成")
            end)
    else
        self._currActiveZhaoReadyItem:removeFromParent()
        self._currActiveZhaoReadyItem = nil
        self:readyActiveZhao(zhaoName)
    end
    
    self:requestDoLayout()
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2017/02/25 17:36:19
-- @desc 移除按钮
function RoleStatePanel:unreadyActiveZhao()
    if self._currActiveZhaoReadyItem then
        self._currActiveZhaoReadyItem:hide1(function()
                -- PopText("隐藏完成")
                self._currActiveZhaoReadyItem:removeFromParent()
                self._currActiveZhaoReadyItem = nil
                
                self._activeZhaoReadyArea:removeFromParent()
                self._activeZhaoReadyArea = nil
        end)
    end
    
    self:requestDoLayout()
end

return RoleStatePanel
000