local QiXiResultLayer = class("QiXiResultLayer", cc.Layer)

--@RefType [app.models.Action.ChineseValentine.2018.QiXiUtil#QiXiUtil]
local QiXiUtil = require("app.models.Action.ChineseValentine.2018.QiXiUtil")

function QiXiResultLayer:create()
    local p = QiXiResultLayer:new()
    p:init()
    return p
end

function QiXiResultLayer:setButtonBack()
    self.Button_back:releaseFunc(
        function()
            self:hideLayer()
        end
    )
end

function QiXiResultLayer:init()
    self._UI = require("Layer/ActionUI/QIXI2018/QIXIResultUI").create()["root"]
    self._UI:addTo(self)
    Helper:convertUIByParent(self)

    self:schedule(
        function(ft)
            self:updateCategory()
        end,
        0
    )

    self:setButtonBack()

    self.__currTitle = "" -- add by XiaoZhiWei 2017/05/15 21:36:41 当前界面标题
    self.__oldOffset = 0 -- add by XiaoZhiWei 2017/06/26 21:25:29 记录上一次抬头的坐标值
end

function QiXiResultLayer:hideLayer()
    PopupLayerController:hideLayer(
        "QiXiResultLayer",
        function(layer)
            for i = #self._days, 1, -1 do
                local text = self._days[i].categoryText

                if text ~= nil then
                    self.Panel_Title:removeChild(text)
                end

                table.remove(self._days, i)
            end

            -- self.Panel_Title:removeAllChildren()
            layer.PageView_List:setTouchEnabled(false)
            layer:setVisible(false)

            User:getRole():setFlag("PVP活动状态", "空闲中")

            layer:hide()
        end
    )
end

function QiXiResultLayer:showLayer(web_data)
    User:getRole():setFlag("PVP活动状态", "忙碌")

    local list = QiXiUtil:createResultDataList(web_data)

    self._days = {}

    for i, v in ipairs(list) do
        self._days[i] = {}
        self._days[i]["data"] = v
        self:createOnePage(i, v)
    end

    self:updateCategory()

    self:show()
end

-- 排行榜单页初始化
function QiXiResultLayer:createOnePage(index, params)
    if index == nil or MapIsEmpty(params) then
        return
    end

    local layout = self.PageView_List:getPageByIndex(index - 1)
    local pageUI
    if layout == nil then
        layout = self.Panel_Layout:clone()
        Helper:convertUIByParent(layout)
        self.PageView_List:addPage(layout)
        pageUI = layout.ListView_1
        pageUI:setSwallowTouches(false)

        -- 设置itemModel
        local itemModel = pageUI:getItem(0)

        pageUI:setItemModel(itemModel)

        pageUI:removeAllItems()
    else
        pageUI = layout:getChildren()[1]
    end

    self:createCategory(index)
    self:createListView(pageUI, index)
end

--@desc 创建ListView UI
function QiXiResultLayer:createListView(listView, index)
    local data_array = self._days[index].data

    for i, result in ipairs(data_array) do
        local row = listView:getItem(i - 1)
        if row == nil then
            row = self.Panel_Item:clone()
            Helper:convertUIByParent(row)
            listView:pushBackCustomItem(row)
        end

        if tonumber(result.level) == 1 then
            row.Image_back:loadTexture("Image/UI/ChineseValentine/frame_yel.png", 0)
        elseif tonumber(result.level) == 2 then
            row.Image_back:loadTexture("Image/UI/ChineseValentine/frame_red.png", 0)
        else
            row.Image_back:loadTexture("Image/UI/ChineseValentine/frame_normal.png", 0)
        end

        local text1 = "你将" .. result.npcName1 .. "和" .. result.npcName2 .. "通过红线牵在了一起。"
        row.Text_1:setString(text1)
        local text2 = "有" .. Helper:numberCast(result.ratio) .. "成人做出了同样的选择"
        row.Text_2:setString(text2)

        row.Button_1:releaseFunc(
            function()
                -- print(result.textIndex)
                local desc = QiXiUtil:getResultDesc(result.level, result.textIndex)

                local text = string.split(desc, "|")
                local TeacherAnimationLayer = require("app.views.layer.TeacherLayer.TeacherAnimationLayer")
                local teacherAnimationLayer = TeacherAnimationLayer:getInstance()
                teacherAnimationLayer:setVisible(false)
                teacherAnimationLayer:createTextFromArrayForQiXi1(text)
                teacherAnimationLayer:show(
                    function()
                        Audio:stopMusic( "qixiBgm" )
                    end
                )
                Audio:playMusic( "qixiBgm",true )
                -- teacherAnimationLayer:setHideWithCallFunc(
                --     function()
                --         User:getRole():setFlag("PVP活动状态", "空闲中")
                --     end
                -- )
            end
        )
    end
end

-- 创建标题
function QiXiResultLayer:createCategory(index)
    if index == nil then
        return
    end

    local cn_text = Helper:numberCast(index)

    local title = "第" .. cn_text .. "天"

    local day_data = self._days[index]
    day_data.name = title
    local text = day_data.categoryText
    if text == nil then
        text = ccui.Text:create(title, "Font/HYCFS.ttf", 60)
        text:setColor(cc.c3b(208, 208, 208))
        text:setAnchorPoint(0.5000, 0.5000)
        self.Panel_Title:addChild(text)
        day_data.categoryText = text
        text:enableOutline(cc.c4b(0, 0, 0, 255), 5) -- 描边无效, 不知道咋了.
        text:setTouchEnabled(true)
    end

    if index == 1 then
        text:setFontSize(60)
        text:setOpacity(255)
    else
        text:setFontSize(48)
        text:setOpacity(125)
    end

    text:releaseFunc(
        function()
            self:initOnePageWithNum(
                index,
                function()
                    self.PageView_List:playScrollPageAnim(index - 1)
                    self:delayFunc(
                        0,
                        function()
                            self.PageView_List:getPageByIndex(index - 1)
                        end
                    )
                end
            )
        end
    )
end

function QiXiResultLayer:initOnePageWithNum(pageNum, successFunc, failedFunc)
    if successFunc then
        successFunc()
    end
end

function QiXiResultLayer:updateCategory()
    if self.PageView_List == nil then
        return
    end

    local offsetX = self.PageView_List:getInnerContainerPosX()

    local totalWidth = #self._days * 1080
    local gapWidth = 200
    for i = 1, #self._days do
        local day_data = self._days[i]
        if day_data.categoryText then
            day_data.categoryText:setPositionY(self.Panel_Title:getContentSize().height / 2)
            day_data.categoryText:setPositionX((offsetX / 1080) * gapWidth + (i - 1) * gapWidth + display.width / 2)
            --+ 340)

            -- 缩放效果
            local posX = day_data.categoryText:getPositionX()
            if posX > display.width / 2 - gapWidth and posX < display.width / 2 + gapWidth then
                local scale = 1 + 0.3 * (1 - math.abs(display.width / 2 - posX) / gapWidth)
                -- day_data.categoryText:setScale(scale)

                if scale > 1.2 then
                    day_data.categoryText:setZ(5) -- 层级有点问题需要调整
                    day_data.categoryText:setFontSize(60)
                    day_data.categoryText:setOpacity(255)

                    if self.__oldOffset == offsetX then
                        self.__currTitle = day_data.name
                    else
                        self.__oldOffset = offsetX
                    end
                else
                    day_data.categoryText:setZ(1)
                    day_data.categoryText:setFontSize(48)
                    day_data.categoryText:setOpacity(125)
                end
            else
                -- day_data.categoryText:setScale(1)
                day_data.categoryText:setZ(1)
                day_data.categoryText:setFontSize(48)
                day_data.categoryText:setOpacity(125)
            end
        end
    end
end

Helper:classDefNodeGetInstance(QiXiResultLayer)
return QiXiResultLayer
00000000