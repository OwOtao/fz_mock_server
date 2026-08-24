local CheFuQianWangLayer = class("CheFuQianWangLayer", cc.Layer)
local Resource = require("app.Resource")

local UserMapRelation = require("app.models.map.UserMapRelation")
local _totalList = UserMapRelation:getLocationRelationMap()

local _showList = {}

function CheFuQianWangLayer:create()
    local p = CheFuQianWangLayer:new()
    p:init()
    return p
end

function CheFuQianWangLayer:init()
    self._UI = require("Layer/Dialog/ItemSelectUI.lua").create()["root"]
    self._UI:addTo(self)
    Helper:convertUIByParent(self)
    self:setBack()
    self:createButton()
end

function CheFuQianWangLayer:showLayer()
    self:show()
end

--@desc: 创建当前级数的列表
--@author:Liang SongQiang
--@time:2018-07-02 15:26:25
--@currIndex: 当前点击的值
--@n: 层数
function CheFuQianWangLayer:initCurrIndexList(currIndex, n)
    n = n or 1

    local result = {}
    if n > 1 then
        --@desc 从第二层开始，每一层都是点击的最后一个才会获取当前限制的值，否则获取全部列表
        local isLast = true
        for i=1,#self._retList do
            if self._retList[i] ~= self._limitArray[i] then
                isLast = false
                break
            end
        end

        if not isLast  then
            for i = 1, #_totalList[n] do
                local temp = {
                    name = _totalList[n][i],
                    mid = i
                }
                table.insert(result, temp)
            end
            self._showList = result
            return
        end
    end

    --@desc 当前层的最大索引
    local currMaxIndex = self._limitArray[n]

    local startIndex = 1
    if n == 1 then
        startIndex = self._startIndex
    end

    for i = startIndex, currMaxIndex do
        local temp = {
            name = _totalList[n][i],
            mid = i
        }
        table.insert(result, temp)
    end

    self._showList = result
end

function CheFuQianWangLayer:hideLayer()
    PopupLayerController:hideLayer(
        "CheFuQianWangLayer",
        function(layer)
            layer:hide()
        end
    )
end

function CheFuQianWangLayer:setTitle(text)
    if text == nil then
        text = ""
    end

    self.Text_Title:setString(text)
end

--@desc: 设置每一级的最大值
--@author:Liang SongQiang
--@time:2018-07-02 15:35:29
--@startIndex: 第一层开始的索引值
--@limitArray: 每一级的最大值  数据结构：{4,2,5,6}
function CheFuQianWangLayer:setTotalList(startIndex, limitArray)
    if startIndex > limitArray[1] then
        assert(false, "服务器返回值出错或客户端startIndex出错：" .. startIndex .. "，" .. limitArray[1])
    end

    self._limitArray = limitArray
    self._index = 1 -- add by XiaoZhiWei 2018/06/05 22:52:24 初始化索引数

    self._startIndex = startIndex

    self._retList = {}

    self:initCurrIndexList()

    self:setList()
end

--@desc: 设置列表数据
--@author:Liang SongQiang
--@time:2018-01-27 24:24:40
--@list:
function CheFuQianWangLayer:setList()
    -- add by XiaoZhiWei 2018/06/05 22:27:58 优化
    do
        -- if MapIsEmpty(self._totalList) == true then
        --     self:hideLayer()
        --     return
        -- end
        local list = self._showList

        if MapIsEmpty(list) == true then
            self:hideLayer()
            return
        end


        local rowIndex, isLeft = 0, false
        for index, data in ipairs(list) do
            rowIndex = math.ceil(index / 2) - 1
            local panel = self.Item_List:getItem(rowIndex)
            if panel == nil then
                panel = self.Panel_List:clone()
                Helper:convertUIByParent(panel)
                panel.Button_Left:setVisible(false)
                panel.Button_Right:setVisible(false)
                panel.Button_Left.Text_name:enableOutline({r = 26, g = 26, b = 26, a = 255}, 5)
                panel.Button_Right.Text_name:enableOutline({r = 26, g = 26, b = 26, a = 255}, 5)
                self.Item_List:pushBackCustomItem(panel)
            end
            if index % 2 == 0 then
                panel.Button_Right:setVisible(true)
                panel.Button_Right.Text_name:setString(data.name)
                panel.Button_Right:releaseFunc(
                    function()
                        self.btnFucn(data.mid)
                    end
                )
            else
                panel.Button_Right:setVisible(false) -- add by XiaoZhiWei 2018/06/05 22:36:28 考虑到一行只有一个的情况
                panel.Button_Left:setVisible(true)
                panel.Button_Left.Text_name:setString(data.name)
                panel.Button_Left:releaseFunc(
                    function()
                        self.btnFucn(data.mid)
                    end
                )
            end
        end

        -- add by XiaoZhiWei 2018/06/05 22:38:37 删除多余的数据
        for i = math.ceil(#list / 2) + 1, #self.Item_List:getItems() do
            self.Item_List:removeLastItem()
        end

        self.Item_List:jumpToTop()
    end
end

function CheFuQianWangLayer:setBtnClickFunc(func)
    self.btnFucn = function(mid)
        table.insert(self._retList,mid)
        if self._index == 3 then
            func(self._retList)
            self:hideLayer()
        else
            self._index = self._index + 1
            self:initCurrIndexList(mid,self._index)
            self:setList()
        end
    end
end

function CheFuQianWangLayer:setBack()
    self.Panel_back:releaseFunc(
        function()
            self:hideLayer()
        end
    )
end

function CheFuQianWangLayer:createButton()
    local roleButton = Resource:getUIByName("Button_4")
    self:addChild(roleButton)
    Helper:convertUI(roleButton)
    roleButton.Text_buttonName:enableOutline(cc.c4b(0, 0, 0, 255), 5)
    roleButton:move(cc.p(550, 200))
    roleButton.Text_buttonName:setString("算了")
    roleButton:releaseFunc(
        function()
            Audio:playEffect("xiaoAnNiu")
            self:hideLayer()
        end
    )
end

Helper:classDefNodeGetInstance(CheFuQianWangLayer)
return CheFuQianWangLayer
0