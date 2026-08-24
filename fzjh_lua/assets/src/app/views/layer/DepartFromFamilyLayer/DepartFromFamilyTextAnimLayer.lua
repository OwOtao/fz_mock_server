local DepartFromFamilyTextAnimLayer = class("DepartFromFamilyTextAnimLayer", cc.Layer)

function DepartFromFamilyTextAnimLayer:create()
	local p = DepartFromFamilyTextAnimLayer:new()
	p:init()
	return p
end

function DepartFromFamilyTextAnimLayer:init()
	self.UI = require("Layer.TextAnimUI.TextAnimUI").create()["root"]
	self.UI:addTo(self)
	Helper:convertUI(self) -- 获得所有子节点

    self._actionState = false
    self._actionIndex = 1
    self._actionCount = 8
	self._animInfo = {}
end

function DepartFromFamilyTextAnimLayer:setAnimInfo(info)
    self._animInfo = info
    Helper:print_lua_table(self._animInfo)
end

function DepartFromFamilyTextAnimLayer:showLayer(func)
    self._actionState = false
    self._actionIndex = 1
    self._actionCount = #self._animInfo

    self:show()

    self.Panel_Show:setVisible(true)
    self.Panel_back:setOpacity(0)
    self.Panel_back:setVisible(true)
    self:createTextByArray(self._animInfo)
    self.Panel_back:releaseFunc(function()
        if self._actionIndex >= self._actionCount then
            self:hideLayer()
            if func then
                func()
            end
        else
            self:clickFunc()        
        end
	end)

    local action = cc.Sequence:create(
	    cc.FadeIn:create(2),
        cc.CallFunc:create(function()
            self:startAnim()
        end)
	)

    self.Panel_back:runAction(action)
end

function DepartFromFamilyTextAnimLayer:hideLayer()
    PopupLayerController:hideLayer("DepartFromFamilyTextAnimLayer",function()
        local action =
        cc.Sequence:create(
            cc.FadeOut:create(2),
            cc.CallFunc:create(function()
                self.Panel_Show:removeAllChildren()
                self:hide()
            end)
        )

        self.Panel_back:runAction(action)
        self.Panel_Show:setVisible(false)

        if self.handle then
            self:unschedule(self.handle)
            self.handle = nil
        end
        
    end)
end

function DepartFromFamilyTextAnimLayer:createTextByArray(strArray)
	local viewsize = cc.Director:getInstance():getWinSize()
	local fontSize = 48  --字体大小
	local spaceDistance = 5 ---间隔距离
    local distance = 150 --距离上边界的距离
	local extraSpace = 60  --一大段额外曾加的间距
	local scrollWidth = 850   ----scroll的宽度
	local heightCount = 0 ----记录所有panel的高度
	local height = 0  -- 
    
	for i = 1, #strArray do
        local Text = ExtRichTextScroll:create()
        Text:setTag(i)
        Text:setSize(cc.size(scrollWidth, 60))
        Text:setDirection(kCCScrollViewDirectionVertical)
        Text:setAnchorPoint(0.5, 1)
        
        self.Panel_Show:addChild(Text)
        
        local textColor = cc.c3b(190, 170, 130)
        Text:pushBackText(strArray[i].text, textColor, 255, Resource:getFontPath("default"), fontSize)
        Text:setSelfAndChildrenCascadeOpacityEnabled(true)
        Text:setBounceEnabled(false)
        Text:setOpacity(0)

        local richText = Text:getRichText()
        richText:setVerticalSpace(spaceDistance)

        self:delayFunc(0.1,function()
            
            height = richText:getNewContentSizeHeight()
            Text:setSize(cc.size(scrollWidth, height))
    
            local pos = cc.p(viewsize.width / 2, viewsize.height - distance - heightCount)
            Text:setPosition(pos)
            print(pos.x,pos.y,height)
    
            heightCount = heightCount + height
        end)
	end
end

function DepartFromFamilyTextAnimLayer:playAnim(duration)
    if self._actionIndex > self._actionCount then
        return
    end

    self._actionState = true

    duration = self._animInfo[self._actionIndex].duration

    local text = self.Panel_Show:getChildByTag(self._actionIndex)
    
    text:runActionWithName("showAnim",
        cc.Sequence:create(
            cc.FadeIn:create(duration)
            , cc.CallFunc:create(function()
                self._actionIndex = self._actionIndex + 1
                self._actionState = false
            end)))
end

function DepartFromFamilyTextAnimLayer:clickFunc()
    if self._actionIndex > self._actionCount then
        return
    end

    local text = self.Panel_Show:getChildByTag(self._actionIndex)
    
    text:stopActionByName("showAnim")
    text:setOpacity(255)

    self._actionIndex = self._actionIndex + 1
    self._actionState = false
end

function DepartFromFamilyTextAnimLayer:isCanPlay()
    return self._actionState == false
end

function DepartFromFamilyTextAnimLayer:startAnim()
    self.handle = self:schedule(function(ft)
        if self:isCanPlay() then
            self:playAnim()
        end

        if self._actionIndex > self._actionCount then
            self:unschedule(self.handle)
            self.handle = nil
        end 
    end)
end

Helper:classDefNodeGetInstance(DepartFromFamilyTextAnimLayer)
return DepartFromFamilyTextAnimLayer
000000000000000