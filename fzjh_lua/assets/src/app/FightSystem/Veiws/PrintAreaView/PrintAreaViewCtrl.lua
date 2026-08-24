--[[
    author:Seven
    time:2023-10-23 15:10:46
    desc: 信息打印区域
]]
local newClass = require("third.class.NewClass")
local ListScrollView = require("app.FightSystem.Veiws.PrintAreaView.ListScrollView")

local textColor = cc.c3b(159, 159, 159)

-- 战斗输出默认文字颜色
local textFont = Resource:getFontPath("default")

local RECORD_FIGHT_STATUS_STRING_LINE_MAX = 2000

local MORE_TEXT = "继续下拉可查看更多内容"
local RELEASE_TEXT = "松开查看更多内容"

local PrintAreaViewCtrl = {}

function PrintAreaViewCtrl:create(...)
    return PrintAreaViewCtrl.new():__init(...)
end

function PrintAreaViewCtrl:ctor()
end

function PrintAreaViewCtrl:__init(mainView)
    --@RefType [FightMainView]
    self.__mainView = mainView

    self.__ui = self.__mainView:getUINode("PrintArea")
    Helper:convertUIParent(self.__ui)

    if self.richPrint then
        self.richPrint:removeFromParent()
        self.richPrint = nil
    end

    self.richPrint = ExtRichTextScroll:create()
    self.__ui:addChild(self.richPrint)
    local size = self.__ui.Text_print:getContentSize()
    local x, y = self.__ui.Text_print:getPosition()
    self.richPrint:setPosition(cc.p(x - size.width / 2, y - size.height / 2))
    self.richPrint:setSize(size)
    self.richPrint:setScrollBarEnabled(false)
    self.richPrint:getRichText():setVerticalSpace(5)

    -- 设置最大显示高度
    self.richPrint:setTextMaxHeight(size.height)

    self.richPrint:setTouchEnabled(false)

    self.richPrintTextArray = {}

    return self
end

function PrintAreaViewCtrl:printText(msg)
    if table.getn(self.richPrintTextArray) >= RECORD_FIGHT_STATUS_STRING_LINE_MAX then
        table.remove(self.richPrintTextArray, 1)
    end

    table.insert(self.richPrintTextArray, msg)

    msg = tostring(msg)
    self.richPrint:pushBackText(msg, textColor, 255, textFont, 42)
    self.richPrint:pushBackNewLine(0)
end

function PrintAreaViewCtrl:openTouch()
    -- 只使用后50条记录
    local logCount = table.getn(self.richPrintTextArray)
    local maxCount = math.min(50, logCount)
    local fightStatusString = table.concat(self.richPrintTextArray, "NOR\n", logCount - maxCount + 1, logCount)

    if self.richPrint then
        self.richPrint:removeFromParent()
        self.richPrint = nil
    end

    -- 停止并移除之前的闪烁文本
    if self.blinkLabel then
        self.blinkLabel:stopAllActions()
        self.blinkLabel:removeFromParent()
        self.blinkLabel = nil
    end

    self.richPrint = ExtRichTextScroll:create()
    self.__ui:addChild(self.richPrint)
    local size = self.__ui.Text_print:getContentSize()
    local x, y = self.__ui.Text_print:getPosition()
    self.richPrint:setPosition(cc.p(x - size.width / 2, y - size.height / 2))
    self.richPrint:setSize(size)
    self.richPrint:setScrollBarEnabled(false)
    self.richPrint:getRichText():setVerticalSpace(5)
    -- 设置最大显示高度
    self.richPrint:setTextMaxHeight(size.height)

    -- 设置最大显示高度
    self.richPrint:setTextMaxHeight(9999999999)

    if logCount > maxCount then
        -- 先添加一个 RichElementCustomNode 来包含带动画的 Label
        -- 获取富文本的宽度
        local richTextWidth = self.richPrint:getContentSize().width

        self.blinkLabel = cc.Label:createWithTTF(MORE_TEXT, textFont, 32)
        self.blinkLabel:setTextColor(cc.c4b(255, 0, 0, 255))
        self.blinkLabel:setDimensions(richTextWidth, 0) -- 设置宽度与富文本一致
        self.blinkLabel:setHorizontalAlignment(cc.TEXT_ALIGNMENT_CENTER) -- 水平居中
        self.blinkLabel:setVerticalAlignment(cc.VERTICAL_TEXT_ALIGNMENT_CENTER) -- 垂直居中

        -- 播放循环闪烁动画（透明度从255渐变到51，即20%）
        self.blinkLabel:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.FadeTo:create(1, 20), cc.FadeTo:create(1, 255))))

        -- 使用 RichElementCustomNode 将 Label 添加到富文本中
        local customElement = ccui.RichElementCustomNode:create(1, cc.c3b(255, 255, 255), 255, self.blinkLabel)
        self.richPrint:getRichText():pushBackElement(customElement)

        self.richPrint:setBounceEnabled(true) -- 开启回弹效果
        self:__setupPullToRefresh()
    else
        self.richPrint:setBounceEnabled(false) -- 开启回弹效果
    end

    -- 添加换行
    self.richPrint:pushBackNewLine(0)

    -- 添加后续的文本内容
    self.richPrint:pushBackText(fightStatusString, textColor, 255, textFont, 42)

    -- 启用触摸并添加下拉刷新功能
    self.richPrint:setTouchEnabled(true)
end

-- 设置下拉刷新功能
function PrintAreaViewCtrl:__setupPullToRefresh()
    local PULL_THRESHOLD = 100 -- 下拉阈值（像素）
    self.__pullRefreshTriggered = false -- 使用实例变量保存状态
    self.__isScrolling = false -- 标记是否正在滚动

    -- 注册滚动事件监听
    self.richPrint:addEventListener(
        function(sender, eventType)
            if eventType == ccui.ScrollviewEventType.scrolling then
                self.__isScrolling = true

                -- 获取内部容器的位置和大小
                local innerContainer = self.richPrint:getInnerContainer()
                local innerPosY = innerContainer:getPositionY()
                local innerHeight = innerContainer:getContentSize().height

                -- 获取滚动视图的可见高度
                local scrollViewHeight = self.richPrint:getContentSize().height

                -- 计算正常情况下顶部的位置（内容高度 - 可见高度）
                local topPosition = -(innerHeight - scrollViewHeight)

                -- 计算下拉距离：当前位置比顶部位置更小（更负）时，说明在下拉
                local pullDistance = topPosition - innerPosY

                -- 判断是否下拉超过阈值
                if pullDistance > PULL_THRESHOLD then
                    if not self.__pullRefreshTriggered then
                        self.__pullRefreshTriggered = true
                        -- 更新提示文本
                        if self.blinkLabel then
                            self.blinkLabel:setString(RELEASE_TEXT)
                        end
                    end
                else
                    if self.__pullRefreshTriggered then
                        self.__pullRefreshTriggered = false
                        if self.blinkLabel then
                            self.blinkLabel:setString(MORE_TEXT)
                        end
                    end
                end
            elseif eventType == ccui.ScrollviewEventType.scrollToTop then
                -- 只有在停止滚动后（松手回弹）才处理
                if not self.__isScrolling then
                    -- 滚动到顶部时
                    if self.__pullRefreshTriggered then
                        -- 触发下拉刷新
                        self:__onPullToRefreshTriggered()
                        self.__pullRefreshTriggered = false

                        -- 恢复提示文本
                        if self.blinkLabel then
                            self.blinkLabel:setString(MORE_TEXT)
                        end
                    end
                end
            elseif eventType == ccui.ScrollviewEventType.scrollToBottom then
                -- 滚动到底部
                self.__isScrolling = false
            elseif eventType == ccui.ScrollviewEventType.bounceTop then
                -- 顶部回弹
                self.__isScrolling = false
            elseif eventType == ccui.ScrollviewEventType.bounceBottom then
                -- 底部回弹
                self.__isScrolling = false
            end
        end
    )

    -- 添加触摸事件监听来检测松手
    self.richPrint:addTouchEventListener(
        function(sender, eventType)
            if eventType == ccui.TouchEventType.ended or eventType == ccui.TouchEventType.canceled then
                print("触摸结束, triggered=" .. tostring(self.__pullRefreshTriggered))
                self.__isScrolling = false

                -- 立即检查并处理
                if self.__pullRefreshTriggered then
                    print("触发下拉刷新")
                    self:__onPullToRefreshTriggered()
                end

                -- 重置状态和文本
                self.__pullRefreshTriggered = false
                if self.blinkLabel then
                    self.blinkLabel:setString(MORE_TEXT)
                end
            end
        end
    )
end

-- 创建文本项节点（用于 ListScrollView）
-- 每个节点包含多行文本（通过 RichText 实现）
function PrintAreaViewCtrl:__createTextItemNode(textStr, width)
    -- 创建富文本来显示多行内容
    local richTextPrint = ExtRichTextScroll:create()
    richTextPrint:getRichText():setVerticalSpace(5)
    richTextPrint:setAnchorPoint(cc.p(0, 0.5))
    richTextPrint:setTextMaxHeight(9999999)
    richTextPrint:setSize(cc.size(width, 0))
    richTextPrint:setTouchEnabled(false)

    richTextPrint.getContentSize = function(self)
        return {
            width = width,
            height = richTextPrint:getRichText():getNewContentSizeHeight()
        }
    end

    richTextPrint:pushBackText(textStr, textColor, 255, textFont, 42)
    richTextPrint:pushBackNewLine(0)

    richTextPrint:getRichText():formatText()

    -- 获取实际的文本高度
    local actualHeight = richTextPrint:getRichText():getNewContentSizeHeight()
    print("实际文本高度:", actualHeight)

    -- 设置 ExtRichTextScroll 的大小以匹配内容
    richTextPrint:setContentSize(cc.size(width, actualHeight))

    return richTextPrint
end

-- 下拉刷新触发时的回调方法
function PrintAreaViewCtrl:__onPullToRefreshTriggered()
    local printNode = self.__mainView:getUINode("Panel_PrintTextAll")

    Helper:convertUIByParent(printNode)

    -- 先停止之前的动画并重置透明度，避免重复和状态异常
    printNode.Text_4:stopAllActions()
    printNode.Text_4:setOpacity(255)
    printNode.Text_4:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.FadeTo:create(1, 20), cc.FadeTo:create(1, 255))))

    printNode:setPosition(cc.p(0, 0))
    printNode:setVisible(true)

    printNode.Panel_Tag:setScale(0)

    -- 使用1秒的弹性缩放动画显示Panel_Tag
    local scaleUp = cc.ScaleTo:create(0.3, 1)
    printNode.Panel_Tag:runAction(scaleUp)

    -- 只在第一次添加监听器
    if not self.__printNodeInit then
        local richTextSize = printNode.Panel_Tag:getContentSize()
        local allLogNodeWidth = richTextSize.width + 5

        self.__printNodeInit = true

        -- 记录已加载文本的起始索引（从最早的日志开始）
        self.__loadedStartIndex = 1

        -- 创建 ListScrollView 替代 ExtRichTextScroll
        local listScrollView = ListScrollView.new(richTextSize)
        printNode.Panel_Tag:addChild(listScrollView)
        listScrollView:setAnchorPoint(cc.p(0, 0))
        listScrollView:setPosition(cc.p(0, 0))
        listScrollView:setClippingEnabled(true)
        listScrollView:setTouchEnabled(true)
        listScrollView:setVisible(true)

        -- 保存引用
        self.__listScrollView = listScrollView

        -- 初始加载前 200 条日志
        local logCount = table.getn(self.richPrintTextArray)
        local initialLoadCount = math.min(200, logCount)

        -- 计算从哪里开始加载（最早的200条）
        local startIdx = 1
        local endIdx = initialLoadCount

        local str = table.concat(self.richPrintTextArray, "NOR\n", startIdx, endIdx)
        local itemNode = self:__createTextItemNode(str, allLogNodeWidth)
        listScrollView:addItem(itemNode)

        -- 更新已加载的起始索引
        self.__loadedStartIndex = endIdx + 1

        local isLoadingMore = false
        local scrollViewHeight = printNode.Panel_Tag:getContentSize().height
        local LOAD_MORE_THRESHOLD = scrollViewHeight * 1.5

        -- 加载更多日志的函数
        local function tryLoadMore()
            if isLoadingMore then
                return
            end

            local totalLogCount = table.getn(self.richPrintTextArray)

            -- 检查是否还有更多日志可加载
            if self.__loadedStartIndex > totalLogCount then
                return
            end

            isLoadingMore = true

            -- 获取当前滚动位置（相对于 innerContainer）
            local innerContainer = listScrollView:getInnerContainer()
            local previousPosY = innerContainer:getPositionY()

            -- 计算下一次加载的日志，100条

            local batchEnd = math.min(self.__loadedStartIndex + 100 - 1, totalLogCount)
            local _str = table.concat(self.richPrintTextArray, "NOR\n", self.__loadedStartIndex, batchEnd)

            -- 保存当前滚动位置相关信息
            local innerContainer = listScrollView:getInnerContainer()
            local oldInnerHeight = innerContainer:getContentSize().height
            local oldPosY = innerContainer:getPositionY()

            -- 创建新的节点并添加到列表底部
            local itemNode = self:__createTextItemNode(_str, allLogNodeWidth)
            listScrollView:addItem(itemNode)

            -- 计算新增的高度
            local newInnerHeight = innerContainer:getContentSize().height
            local heightDiff = newInnerHeight - oldInnerHeight

            -- 调整滚动位置，保持视觉上的稳定
            -- 由于新内容添加在底部，需要调整 innerContainer 的位置
            local newPosY = oldPosY - heightDiff
            innerContainer:setPositionY(newPosY)

            -- 更新已加载索引
            self.__loadedStartIndex = batchEnd + 1

            isLoadingMore = false
        end

        -- 监听滚动事件
        listScrollView:addEventListener(
            function(sender, eventType)
                -- 监听滚动中和惯性滚动事件
                if eventType == 9 or eventType == ccui.ScrollviewEventType.scrolling then
                    local innerContainer = sender:getInnerContainer()
                    local innerHeight = innerContainer:getContentSize().height

                    if innerHeight > scrollViewHeight then
                        local innerPosY = innerContainer:getPositionY()
                        -- 计算距离底部的距离
                        local distanceToBottom = -innerPosY

                        -- 当接近底部时加载更多
                        if distanceToBottom <= LOAD_MORE_THRESHOLD then
                            tryLoadMore()
                        end
                    end
                elseif eventType == ccui.ScrollviewEventType.scrollToBottom or eventType == ccui.ScrollviewEventType.bounceBottom then
                    -- 滚动到底部时也尝试加载
                    tryLoadMore()
                end
            end
        )

        printNode:setTouchEnabled(true)
        printNode:setSwallowTouches(true)

        -- 添加点击放开后关闭面板的功能
        printNode:addTouchEventListener(
            function(sender, eventType)
                if eventType == ccui.TouchEventType.ended then
                    printNode:setVisible(false)
                    printNode.Text_4:stopAllActions()
                    printNode.Text_4:setOpacity(255)
                end
            end
        )
    end
end

return newClass("PrintAreaViewCtrl", {}, PrintAreaViewCtrl)
00000000