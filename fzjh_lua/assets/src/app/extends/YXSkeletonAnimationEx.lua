function YXSkeletonAnimation:lazyInit()
    if self._slotColorMap == nil then
        self._slotColorMap = {}
    end
    if self._slotAttachmentNameMap == nil then
        self._slotAttachmentNameMap = {}
    end
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2017/03/18 12:07:40
-- @desc 还原玩家设置的特性
function YXSkeletonAnimation:useCustom()
    self:lazyInit()
    
    if next(self._slotColorMap) ~= nil and next(self._slotAttachmentNameMap) then
        self:setSlotsToSetupPose()
    end

    for k, v in pairs(self._slotColorMap) do
        self:setSlotColor(k, v)
    end
    
    for k, v in pairs(self._slotAttachmentNameMap) do
        self:setAttachment(k, v)
    end
end

function YXSkeletonAnimation:playAnim(animName, loop)
    if type(animName) == "function" then
        animName = animName()
    end
    
    if loop == nil then
        loop = false
    elseif type(loop) == "number" then
        if loop == 0 then
            loop = false
        else
            loop = true
        end
    elseif loop ~= false then
        loop = true
    end
    
    self:resetAnimState()
    self:setSpeedScale(1)
    self:setBonesToSetupPose()    
    self:setBackwards(false)
    
    -- 使用玩家设置的特性 add by TangJian 2017/03/18 12:07:20
    self:useCustom()
    
    return self:setAnimation(0, animName, loop)
end

function YXSkeletonAnimation:setAnimFrameFromTo(from, to)
    if from ~= nil then
        self:setStartTime(from / 30)
    end
    if to ~= nil then
        self:setEndTime(to / 30)
    end
end

function YXSkeletonAnimation:playAnimFromToWithDuration(animName, from, to, duration)
    
    local interval = to - from
    
    if interval < 0 then
        interval = 0
    end
    
    local speedScale = interval / (30 / duration)
    
    if speedScale < 0 then
        from, to = swap(from, to)
    end
    
    self:playAnim(animName, loop)
    self:setAnimFrameFromTo(from, to)
    --self:getAnim():setBackwards(backwards)
    self:setSpeedScale(speedScale)

end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2017/04/08 11:55:40
-- @desc 渐现
function YXSkeletonAnimation:fadeIn()
    self:runActionWithName("fadeInAdnFadeOut", cc.FadeIn:create(0.3))
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2017/04/08 11:55:55
-- @desc 渐隐
function YXSkeletonAnimation:fadeOut()
    self:runActionWithName("fadeInAdnFadeOut", cc.FadeOut:create(0.3))
end

-- 替换
Decorator:replace(YXSkeletonAnimation, "setSlotColor",
    function(funcName, func, self, slotName, c4f)
        self:lazyInit()
        
        self._slotColorMap[slotName] = c4f
        return func(self, slotName, c4f)
    end)

Decorator:replace(YXSkeletonAnimation, "setAttachment",
    function(funcName, func, self, slotName, attachmentName)
        self:lazyInit()
        
        self._slotAttachmentNameMap[slotName] = attachmentName
        return func(self, slotName, attachmentName)
    end)
0000000000000000