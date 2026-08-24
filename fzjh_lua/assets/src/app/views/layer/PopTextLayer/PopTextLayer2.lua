local PopTextLayer2 = class("PopTextUI", cc.Layer)

function PopTextLayer2:create()
    local p = PopTextLayer2:new()
    p:init()
    return p
end

function PopTextLayer2:init()
    self._round = require("Layer/PopUI/PopText2UI.lua").create()["root"]
    self._round:addTo(self)

    Helper:convertUIByParent(self) -- 获得所有子节点

    self.Text_desc:setVisible(false)

    self.Panel_back:releaseFunc(
        function()
            self:hideLayer()
        end
    )
    
    self.Text_desc_OriginalPositionY=self.Text_desc:getPositionY()
    self.Text_desc_OriginalContentSize=self.Text_desc:getContentSize()
    self.Text_Title_OriginalPositionX=self.Text_Title:getPositionX()
    self.Button_2_OriginalPositionY=self.Button_2:getPositionY()
end

--@desc: 显示
--@author:Liang SongQiang
--@time:2018-06-05 21:43:09
--otherShow  纯粹查看显示 非房契、地契
function PopTextLayer2:showLayer(otherShow)
    if not otherShow then 
        otherShow=false
    end
    self:showOtherTypeItem(otherShow)
    self:initRichText()
    self:show()
end

function PopTextLayer2:setTitle(str)
    if str == nil or str == "" then
        self.Text_Title:setVisible(false)
        return
    end
    self.Text_Title:setVisible(true)

    self.Text_Title:setString(str)
end

function PopTextLayer2:setTitle2(str)
    if str == nil or str == "" then
        self.Text_Title2:setVisible(false)
        return
    end
    self.Text_Title2:setVisible(true)

    self.Text_Title2:setString(str)
end

function PopTextLayer2:setBtn1(name, fun)
    if name == nil or name == "" then
        self.Button_1:setVisible(false)
        return
    end
    self.Button_1:setVisible(true)

    self.Button_1.Text_Name:setString(name)

    self.Button_1:releaseFunc(
        function()
            fun()
        end
    )
end

function PopTextLayer2:setBtn2(name, fun)
    if name == nil or name == "" then
        self.Button_2:setVisible(false)
        return
    end
    self.Button_2:setVisible(true)

    self.Button_2.Text_Name:setString(name)

    self.Button_2:releaseFunc(
        function()
            fun()
        end
    )
end

function PopTextLayer2:onResume()
    self:unscheduleAll()
end

function PopTextLayer2:setDesc(str)
    if str == "" or str == nil then
        return
    end

    self:print(str)
end

--@desc: 隐藏界面
--@author:Liang SongQiang
--@time:2018-06-05 21:56:03
function PopTextLayer2:hideLayer()
    self:unscheduleAll()
    PopupLayerController:hideLayer(
        "PopTextLayer2",
        function(layer)
            layer:hide()
        end
    )
end

function PopTextLayer2:setLogVisible(bool)
    if bool == false or bool == nil then
        self.Image_Log:setVisible(false)
        return
    end
    self.Image_Log:setVisible(bool)
end

function PopTextLayer2:initRichText()
    local x, y = self.Text_desc:getPosition()
    local size = self.Text_desc:getContentSize()

    if self.RichText_Print then
        self.RichText_Print:removeFromParent()
        self.RichText_Print = nil
    end

    local richTextScroll = ExtRichTextScroll:create()
    self.Text_desc:getParent():addChild(richTextScroll)
    richTextScroll:setAnchorPoint(0.5, 0.5)
    richTextScroll:move(cc.p(x, y))
    richTextScroll:setSize(size)
    richTextScroll:setDirection(kCCScrollViewDirectionVertical)
    richTextScroll:getRichText():setVerticalSpace(5)
    self.RichText_Print = richTextScroll
    self.RichText_Print:setBounceEnabled(false)
    self.RichText_Print:setTouchEnabled(false)
end

function PopTextLayer2:print(str, verticalSpace)
    if str == "" then
        return
    end
    local textColor = cc.c3b(159, 159, 159)
    local textHeight = self.RichText_Print:getRichText():getNewContentSizeHeight()
    if textHeight >= 6666 then
        self:initRichText()
    end
    
    self.RichText_Print:getRichText():removeAllElement()
    self.RichText_Print:pushBackText(str, textColor, 255, Resource:getFontPath("default"), 42)

    if verticalSpace ~= nil and type(verticalSpace) == "number" then
        self.RichText_Print:pushBackNewLine(verticalSpace)
    else
        self.RichText_Print:pushBackNewLine()
    end
    self.RichText_Print:jumpToTop()
end

function PopTextLayer2:pushSchedule(func, time)
    print(type(func))
    if not func or type(func) ~= "function" then
        print("PopTextLayer2:pushSchedule 参数错误。")
        return
    end
    time = Helper:getDef(time, 1)
    self:schedule(
        function(ft)
            func()
        end,
        time
    )
end
--otherShow  纯粹查看显示 非房契、地契
function PopTextLayer2:showOtherTypeItem(otherShow)
    if otherShow==true then 
        self.Text_desc:setPositionY(self.Text_desc_OriginalPositionY-160)
        self.Text_desc:setContentSize({width = 920, height = 900})
        self.Text_Title:setPositionX(500.00)
        self.Button_2:setPositionY(self.Button_2_OriginalPositionY-80.00)
    else
        self.Text_desc:setPositionY(self.Text_desc_OriginalPositionY)
        self.Text_desc:setContentSize(self.Text_desc_OriginalContentSize)
        self.Text_Title:setPositionX(self.Text_Title_OriginalPositionX)
        self.Button_2:setPositionY(self.Button_2_OriginalPositionY)
    end
end

Helper:classDefNodeGetInstance(PopTextLayer2)
return PopTextLayer2
0