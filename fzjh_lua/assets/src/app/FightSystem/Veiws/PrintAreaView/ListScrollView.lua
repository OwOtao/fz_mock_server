local ListScrollView =
    class(
    "ListScrollView",
    function()
        return ccui.ScrollView:create()
    end
)

function ListScrollView:ctor(size)
    -- 设置ScrollView基本属性
    self:setContentSize(size)
    self:setDirection(ccui.ScrollViewDir.vertical)
    self:setBounceEnabled(false)
    self:setScrollBarEnabled(true)
    self:setScrollBarAutoHideEnabled(true)

    -- 设置触摸和裁剪
    self:setTouchEnabled(true)
    self:setClippingEnabled(true)

    -- 初始化内容容器
    local innerContainer = self:getInnerContainer()

    -- 创建内容承载节点（用于承载所有列表项）
    self.contentNode = cc.Node:create()
    self.contentNode:setAnchorPoint(cc.p(0, 1))
    self.contentNode:setPosition(cc.p(0, 0))

    -- 添加可视化背景，方便调试contentNode的位置和大小
    self.contentNodeBg = cc.LayerColor:create(cc.c4b(0, 255, 0, 100), 10, 10) -- 绿色半透明
    self.contentNodeBg:setAnchorPoint(cc.p(0, 0)) -- 背景锚点设为(0,0)
    self.contentNodeBg:setPosition(cc.p(0, -10)) -- 背景从contentNode锚点向下绘制
    self.contentNodeBg:setVisible(false) -- 调试时可见，平时隐藏
    self.contentNode:addChild(self.contentNodeBg, -1) -- 放在最底层

    innerContainer:addChild(self.contentNode)

    -- 初始化变量
    self.itemSpacing = 0 -- 项目间距
    self.totalHeight = 0 -- 总内容高度
    self.items = {} -- 存储所有项目

    -- self:setBackGroundColorType(1)
    -- self:setBackGroundColor({r = 255, g = 150, b = 100})
end

function ListScrollView:setItemSpacing(spacing)
    self.itemSpacing = spacing
end

-- 添加列表项
function ListScrollView:addItem(item)
    -- 如果item的Y轴锚点不是0.5，报错
    local item_anchor = item:getAnchorPoint()
    if item_anchor.y ~= 0.5 then
        error("ListScrollView:addItem: item anchorPoint.y must be 0.5")
        return
    end

    local innerContainer = self:getInnerContainer()
    local contentSize = self:getContentSize()

    -- 获取新元素高度
    local itemHeight = item:getContentSize().height

    -- 计算新元素在contentNode中的位置（contentNode锚点为(0,0.5)，从顶部向下排列）
    -- 新元素位置 = -(当前总高度 + 间距) - 元素高度/2
    local yPos = -self.totalHeight - self.itemSpacing - itemHeight / 2
    if #self.items == 0 then
        -- 第一个元素不需要间距
        yPos = -itemHeight / 2
    end
    item:setPosition(cc.p(0, yPos))

    -- 添加到contentNode
    self.contentNode:addChild(item)
    table.insert(self.items, item)

    -- 更新总高度（累加新元素高度和间距）
    if #self.items == 1 then
        self.totalHeight = itemHeight
    else
        self.totalHeight = self.totalHeight + self.itemSpacing + itemHeight
    end

    -- contentNode位置调整，确保第一个元素在ScrollView顶部，所有元素都能滚动访问
    local contentNodeY = math.max(contentSize.height, self.totalHeight)
    self.contentNode:setPosition(cc.p(0, contentNodeY))

    -- 更新contentNode背景大小和位置以便可视化
    self.contentNodeBg:setContentSize(cc.size(contentSize.width, self.totalHeight))
    self.contentNodeBg:setPosition(cc.p(0, -self.totalHeight)) -- 背景从顶部向下覆盖

    -- 更新内容容器大小
    local newInnerSize = cc.size(contentSize.width, math.max(contentSize.height, self.totalHeight))
    self:setInnerContainerSize(newInnerSize)
end

-- 刷新布局
function ListScrollView:refreshLayout()
    local contentSize = self:getContentSize()

    -- 重新排列所有项目位置（从顶部向下排列，使用动态高度）
    local currentY = 0
    self.totalHeight = 0
    for i, item in ipairs(self.items) do
        item:setAnchorPoint(cc.p(0, 0.5))
        local itemHeight = item:getContentSize().height

        if i == 1 then
            -- 第一个元素
            currentY = -itemHeight / 2
        else
            -- 后续元素：当前Y - 间距 - 元素高度/2
            currentY = currentY - self.items[i - 1]:getContentSize().height / 2 - self.itemSpacing - itemHeight / 2
        end

        item:setPosition(cc.p(0, currentY))

        self.totalHeight = self.totalHeight + itemHeight
        if i > 1 then
            self.totalHeight = self.totalHeight + self.itemSpacing
        end
    end

    -- contentNode位置调整，确保第一个元素在ScrollView顶部，所有元素都能滚动访问
    if #self.items > 0 then
        local contentNodeY = math.max(contentSize.height, self.totalHeight)
        self.contentNode:setPosition(cc.p(0, contentNodeY))
        -- 更新contentNode背景大小以便可视化
        self.contentNodeBg:setContentSize(cc.size(contentSize.width, self.totalHeight))
    else
        self.contentNode:setPosition(cc.p(0, 0))
        -- 清空背景
        self.contentNodeBg:setContentSize(cc.size(0, 0))
    end

    -- 更新内容容器
    local newInnerSize = cc.size(contentSize.width, math.max(contentSize.height, self.totalHeight))
    self:setInnerContainerSize(newInnerSize)
end

function ListScrollView:getItem(index)
    return self.items[index]
end

-- 移除第一个元素，只做删除操作
function ListScrollView:removeFirst()
    if #self.items == 0 then
        return
    end

    local removedItem = self.items[1]

    -- 移除第一个元素
    removedItem:removeFromParent()
    table.remove(self.items, 1)

    -- 如果没有剩余元素，重置状态
    if #self.items == 0 then
        self.totalHeight = 0
        self.contentNode:setPosition(cc.p(0, 0))
        self.contentNodeBg:setContentSize(cc.size(0, 0))
        self:setInnerContainerSize(self:getContentSize())
    else
        self.__isRemoveDirty = true
    end
end

-- 更新元素位置和高度布局
function ListScrollView:updatePositionAndHeight()
    if #self.items == 0 then
        return
    end

    if not self.__isRemoveDirty then
        return
    end

    -- 清除脏标记
    self.__isRemoveDirty = false

    local contentSize = self:getContentSize()

    -- 重新计算所有剩余元素的位置，从第一个元素开始重新布局
    local currentY = 0
    self.totalHeight = 0
    for i, item in ipairs(self.items) do
        local itemHeight = item:getContentSize().height

        if i == 1 then
            -- 第一个元素
            currentY = -itemHeight / 2
        else
            -- 后续元素：当前Y - 间距 - 元素高度/2
            currentY = currentY - self.items[i - 1]:getContentSize().height / 2 - self.itemSpacing - itemHeight / 2
        end

        item:setPosition(cc.p(0, currentY))

        self.totalHeight = self.totalHeight + itemHeight
        if i > 1 then
            self.totalHeight = self.totalHeight + self.itemSpacing
        end
    end

    -- 重新计算contentNode位置
    local contentNodeY = math.max(contentSize.height, self.totalHeight)
    self.contentNode:setPosition(cc.p(0, contentNodeY))

    -- 更新contentNode背景大小和位置以便可视化
    self.contentNodeBg:setContentSize(cc.size(contentSize.width, self.totalHeight))
    self.contentNodeBg:setPosition(cc.p(0, -self.totalHeight))

    -- 更新内容容器大小
    local newInnerSize = cc.size(contentSize.width, math.max(contentSize.height, self.totalHeight))
    self:setInnerContainerSize(newInnerSize)
end

-- 当最后一个元素大小改变后，重新计算布局 (真正的O(1)操作)
function ListScrollView:updateLastItemSize()
    if #self.items == 0 then
        return
    end

    local contentSize = self:getContentSize()
    local lastItem = self.items[#self.items]
    local newItemHeight = lastItem:getContentSize().height
    local oldPos = cc.p(lastItem:getPosition())
    local oldY = oldPos.y

    -- 基于倒数第二个元素位置计算最后一个元素的新位置
    local newY
    if #self.items == 1 then
        -- 只有一个元素的情况
        newY = -newItemHeight / 2
    else
        -- 多个元素：基于倒数第二个元素计算
        local secondLastItem = self.items[#self.items - 1]
        local secondLastPos = cc.p(secondLastItem:getPosition())
        local secondLastY = secondLastPos.y
        local secondLastHeight = secondLastItem:getContentSize().height
        newY = secondLastY - secondLastHeight / 2 - self.itemSpacing - newItemHeight / 2
    end

    -- 计算原来最后元素的高度（基于位置推算）
    local oldItemHeight
    if #self.items == 1 then
        -- 如果只有一个元素，通过位置计算原高度
        oldItemHeight = -oldY * 2 -- 因为元素中心在-height/2位置
    else
        -- 多个元素：通过与倒数第二个元素的距离计算
        local secondLastItem = self.items[#self.items - 1]
        local secondLastPos = cc.p(secondLastItem:getPosition())
        local secondLastY = secondLastPos.y
        local secondLastHeight = secondLastItem:getContentSize().height
        -- 距离 = spacing + oldItemHeight/2 + secondLastHeight/2
        local distance = secondLastY - oldY
        oldItemHeight = (distance - self.itemSpacing) * 2 - secondLastHeight
    end

    -- 更新最后元素位置
    lastItem:setPosition(cc.p(0, newY))

    -- 计算高度差值，更新totalHeight
    local heightDiff = newItemHeight - oldItemHeight
    self.totalHeight = self.totalHeight + heightDiff

    -- 重新调整contentNode位置，确保所有元素都能滚动访问
    local contentNodeY = math.max(contentSize.height, self.totalHeight)
    self.contentNode:setPosition(cc.p(0, contentNodeY))

    -- 更新contentNode背景大小和位置以便可视化
    self.contentNodeBg:setContentSize(cc.size(contentSize.width, self.totalHeight))
    self.contentNodeBg:setPosition(cc.p(0, -self.totalHeight))

    -- 更新内容容器大小
    local newInnerSize = cc.size(contentSize.width, math.max(contentSize.height, self.totalHeight))
    self:setInnerContainerSize(newInnerSize)
end

-- 清空所有项目
function ListScrollView:clear()
    self.items = {}
    self.totalHeight = 0
    self.contentNode:removeAllChildren()

    -- 重新添加可视化背景
    self.contentNodeBg = cc.LayerColor:create(cc.c4b(0, 255, 0, 100), 0, 0)
    self.contentNodeBg:setAnchorPoint(cc.p(0, 0))
    self.contentNodeBg:setPosition(cc.p(0, 0))
    self.contentNode:addChild(self.contentNodeBg, -1)

    self.contentNode:setPosition(cc.p(0, 0))
    self:setInnerContainerSize(self:getContentSize())
end

-- 滚动到指定索引
function ListScrollView:scrollToItem(index, animated)
    if index >= 1 and index <= #self.items then
        -- 计算目标元素在contentNode中的位置（使用动态高度）
        local targetItemY = 0
        for i = 1, index - 1 do
            targetItemY = targetItemY - self.items[i]:getContentSize().height - self.itemSpacing
        end
        targetItemY = targetItemY - self.items[index]:getContentSize().height / 2

        -- 计算需要的滚动偏移，让目标元素显示在ScrollView底部
        local contentNodeY = self.contentNode:getPosition().y
        local yOffset = -(targetItemY + contentNodeY)
        self:scrollToOffset(cc.p(0, yOffset), animated and 0.5 or 0)
    end
end

return ListScrollView
0000