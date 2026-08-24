local ItemSelectAutoFitLayer = class("ItemSelectAutoFitLayer", cc.Layer)

function ItemSelectAutoFitLayer:create()
    local p = ItemSelectAutoFitLayer:new()
    p:init()
    return p
end

function ItemSelectAutoFitLayer:init()
    self._UI = require("Layer/Dialog/ItemSelectUI.lua").create()["root"]
    self._UI:addTo(self)
    Helper:convertUIByParent(self)
    self:setBack()

	-- 让界面接近原来的ChooseButtonLayer

    -- 标题文字颜色：纯白
    self.Text_Title:setColor(cc.c3b(255,255,255))
    -- 标题文字向下移动60像素
    self.Text_Title:setPositionY(self.Text_Title:getPositionY() - 60)

    -- 按钮面板向下移动190像素
    self.Item_List:setPositionY(self.Item_List:getPositionY() - 190)

    -- 左右按钮各自贴边，让中间间距大一些
    self.Panel_List.Button_Left:setPositionX(0)
    self.Panel_List.Button_Right:setPositionX(self.Panel_List:getSize().width)

    -- 背景透明度：90%
    self.Panel_back:setBackGroundColorOpacity(255 * 0.9)

    -- ItemSelectUI中Panel_List是一行两个按钮，这里创建一个一列按钮的面板（隐藏右侧按钮，左侧按钮居中）
    self.Panel_List_1 = self.Panel_List:clone()
    Helper:convertUIByParent(self.Panel_List_1)
    self.Panel_List_1.Button_Right:setVisible(false)
    self.Panel_List_1.Button_Left:setAnchorPoint(cc.p(0.5, 0.5))
    self.Panel_List_1.Button_Left:setPositionX(self.Panel_List_1.Button_Left:getParent():getSize().width * 0.5)
    self.Panel_List:getParent():addChild(self.Panel_List_1)
end

function ItemSelectAutoFitLayer:showLayer()
    self:show()
end

function ItemSelectAutoFitLayer:hideLayer()
    self:hide()
end

--[[
    @desc: 设置标题
    author: HanTao
    time: 2019-07-02 15:00:49
    --@text: 标题文本
    @return 
]]
function ItemSelectAutoFitLayer:setTitle(text)
    if text == nil then
        text = ""
    end

    self.Text_Title:setString(text)
end

--@desc: 设置列表数据自适应排版（根据按钮数量自适应列数，少于6个按钮，排1列，否则排2列）
--@author: HanTao
--@time: 2019-07-02 12:56:07
--@list: 按钮信息列表，格式：{{name="按钮文字", index=按钮索引}, ...}，参数会传递给点击按钮的回调
function ItemSelectAutoFitLayer:setList(list)
    self.Item_List:removeAllItems()
    -- 恢复标题文字颜色：纯白
    self.Text_Title:setColor(cc.c3b(255,255,255))

    local pList = {}
    
    if #list < 6 then
        for i = 1, #list do
            local panel = self.Panel_List_1:clone()
            Helper:convertUIByParent(panel)
            panel.Button_Left.Text_name:enableOutline({r = 26, g = 26, b = 26, a = 255}, 5)
            table.insert(pList, panel)
        end
        
        for index, data in ipairs(list) do
            local panel = pList[index]

            panel.Button_Left.Text_name:setString(data.name)
            panel.Button_Left:releaseFunc(function ()
                self.btnFucn(data.index)
            end)
        end
    else
        local mod, remainder = math.modf(#list / 2)

        if math.ceil(remainder) == 1 then
            mod = mod + 1
        end
        
        for i = 1, mod do
            local panel = self.Panel_List:clone()
            Helper:convertUIByParent(panel)
            panel.Button_Right:setVisible(false)
            panel.Button_Left.Text_name:enableOutline({r = 26, g = 26, b = 26, a = 255}, 5)
            panel.Button_Right.Text_name:enableOutline({r = 26, g = 26, b = 26, a = 255}, 5)
            table.insert(pList, panel)
        end

        for index, data in ipairs(list) do
            local pListIndex = math.ceil(index / 2)
            local panel = pList[pListIndex]

            if index % 2 == 1 then
                panel.Button_Left.Text_name:setString(data.name)
                panel.Button_Left:releaseFunc(function ()
                    self.btnFucn(data.index)
                end)
            elseif index % 2 == 0 then
                panel.Button_Right:setVisible(true)
                panel.Button_Right.Text_name:setString(data.name)
                panel.Button_Right:releaseFunc(function ()
                    self.btnFucn(data.index)
                end)
            else
                assert(false,"代码有问题！！")
            end
        end
    end

    for i,panel in ipairs(pList) do
        self.Item_List:pushBackCustomItem(panel)
    end

    -- 数量大于12的时候显示滚动条，否没必要滚动条
    if #list > 12 then
        self.Item_List:setScrollBarEnabled(true)
    else
        self.Item_List:setScrollBarEnabled(false)
    end
end

--@desc: 给选择按钮点击事件
--@author: HanTao
--@time: 2019-07-02 15:00:12
--@func: 形如 function( index )，index是按钮索引
function ItemSelectAutoFitLayer:setBtnClickFunc(func)
    self.btnFucn = func
end

function ItemSelectAutoFitLayer:setBack()
    self.Panel_back:releaseFunc(
        function()
            PopupLayerController:hideLayer(
                "ItemSelectLayer",
                function(layer)
                    layer:hideLayer()
                end
            )
        end
    )
end

Helper:classDefNodeGetInstance(ItemSelectAutoFitLayer)
return ItemSelectAutoFitLayer
00