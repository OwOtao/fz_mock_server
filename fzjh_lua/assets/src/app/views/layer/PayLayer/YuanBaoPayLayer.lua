local YuanBaoPayLayer = class("YuanBaoPayLayer", LayerEx)

local buyItemFunc = function(item, callback, others, num, isDiscount)
    callback = Helper:getDef(callback,EMPTY_FUNC)

    if others ~= nil and others.isOpenPay == true then
        HttpManagerEx:getYuanBao(
            function(status, errcode, errmsg, data)
                if status == 200 and errcode == 0 then
                    User:setRoleAttr("yuanbao", data.yuanbao)
    
                    if data.yuanbao < item.price * num then
                        if GameChannelContext:isOpenPay() == false then
                            PopText("元宝不足，购买失败！")
                            callback("failed")
                            return
                        end

                        local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")
                        local dialog = DialogALayer:getInstance()
                        dialog:hide()
                        dialog:show("你的元宝不足，前往充值后才可继续操作。", "HIY是否前往充值NOR")
                        dialog:setButton1(
                            "确定",
                            function()
                                Game:openPayLayer(function()
                                    PopupLayerController:showLayer("PayLayer", function(layer)
                                        layer:show()
                                    end)
                                end)
                            end
                        )
    
                        dialog:setButton2(
                            "取消",
                            function()
                            end
                        )
                        callback("failed")
                        return
                    end
    
                    TransCheck:buyItem(
                        item,
                        function(eventType, reward)
                            callback(eventType, reward)
                        end,
                        others,
                        num,
                        isDiscount
                    )
                end
            end,
            IS_SHOW_WAITING
        )
    else
        TransCheck:buyItem(
            item,
            function(eventType, reward)
                callback(eventType, reward)
            end,
            others,
            num,
            isDiscount
        )
    end

end



-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/05/23 10:39:46
-- @desc 配合服务器处理赠品问题, 同一个赠品如果发放不同数量,服务器将无法锁定到具体的奖励记录,导致异常
function YuanBaoPayLayer.buyStoreItem(id , itemId, callback ,number,others)
    if type(callback) ~= "function" then
        callback = function()end
    end
    -- 通过网络请求服务器获取商品信息
    HttpManagerEx:getGoodsInfo(itemId, function(status,errcode,errmsg,data)
        if status == 200 then
            if errcode == 0 then
                if type(data) == "table" and _G.next(data) then

                    -- 显示商品购买界面
                    local layer = YuanBaoPayLayer:getInstance()
                    layer:show()
                    if number ~= nil and type(number) == "number" then
                        layer:setItemName(data.name.."X"..tostring(number))
                        layer:setItemPrice(data.price*number)
                    else
                        layer:setItemName(data.name)
                        layer:setItemPrice(data.price)
                    end
                    layer:setItemDesc("    "..data.dsc1.."\n    "..data.dsc2)
                    layer:setItemIcon(data.icon)
                    layer:setSpecialTextShow(data.itemId)
                    layer:setShareDesc(data.share)
                    layer:setImageShow(data.discount)
                    data.id = id -- add by XiaoZhiWei 2017/05/23 15:00:13 提供服务器使用,用于锁定具体奖励记录

                    -- 设置购买按钮
                    layer:setPayFunc(function()
                        buyItemFunc(data,function (eventType)
                            callback(eventType)
                            layer:hide()
                        end,others,Helper:getDef(number,1))
                        -- TransCheck:buyItem(data, function(eventType)
                        --     callback(eventType)
                        --     layer:hide()
                        -- end, {}, Helper:getDef(number,1))
                    end)

                    -- 设置取消按钮
                    layer:setCancelFunc(function()
                        callback("cancel")
                        layer:hide()
                    end)
                else
                    PopText("获得商品数据出错.")
                end
            else
                PopText("获得商品数据出错..")
            end
        else
            PopText("网络请求出错,请换个网络环境再试!")
        end
    end, IS_SHOW_WAITING)
end

local function NewYuanBaoPayUI(itemData,item,callback,others)
    local textList = {
        Text_tital = itemData.name,
        Text_type = itemData:getItemShowType(),
        Text_dsc = itemData.dsc,
        Text_price = "售价:"..item.price.."元宝",
        Text_affirm = "确定购买"..itemData.name.."吗？",
        Text_havenum = "已拥有:"..User:getRole():getItemTotalCount(itemData.id)..itemData.unit,
    }

    local ShoppingDialogLayer = require("app.views.layer.DialogLayer.ShoppingDialogLayer")
    PopupLayerController:showLayer("ShoppingDialogLayer",function(layer)
        layer:showLayer(textList,function()
        end)
        -- add by LvBin 2019/04/24 11:16:40 车夫礼包优惠活动
        local isDiscount = IS_NOT_DISCOUNT
        if item.itemId == "chefugift001" then
            layer:setRichText("RED（拥有车行徽记，购买将实付360元宝）")
            local chefuitem = User:getRole():getItem("chefuitem004")
            if chefuitem then
                isDiscount = IS_DISCOUNT
            end
        end
        layer:setButton_confirm("确定", function()

            buyItemFunc(item,function (eventType,reward)
                callback(eventType,reward)
            end,others,1,isDiscount)
            -- TransCheck:buyItem(item, function(eventType,reward)
            --     callback(eventType,reward)
            -- end, others,1,isDiscount)
        end)
        layer:setButton_close("取消", function()
        end)
    end)
end

local function OldYuanBaoPayUI(item,callback,others)
    -- 显示商品购买界面
    local layer = YuanBaoPayLayer:getInstance()
    layer:show()

    layer:setItemName(item.name)
    layer:setItemDesc("    "..item.dsc1.."\n    "..item.dsc2)
    layer:setItemPrice(item.price)
    layer:setItemIcon(item.icon)
    layer:setShareDesc(item.share)
    layer:setSpecialTextShow(item.itemId)
    layer:setImageShow(item.discount)
    -- 设置购买按钮
    layer:setPayFunc(function()
        buyItemFunc(item,function (eventType,reward)
            callback(eventType,reward)
            layer:hide()
        end,others)
        -- TransCheck:buyItem(item, function(eventType,reward)
        --     callback(eventType,reward)
        --     layer:hide()
        -- end, others)
    end)

    -- 设置取消按钮
    layer:setCancelFunc(function()
        callback("cancel")
        layer:hide()
    end)
end

function YuanBaoPayLayer.buyItem(itemId, callback, ...)
    if type(callback) ~= "function" then
        callback = function()end
    end

    -- 额外传给服务器的数据 经脉印记 折扣免单
    local others = ...

    if others == nil then
        others = {}
    end

    -- 通过网络请求服务器获取商品信息
    HttpManagerEx:getGoodsInfo_2(itemId, others, function(status,errcode,errmsg,data)
        if status == 200 then
            if errcode == 0 then
                if type(data) == "table" and _G.next(data) then
                    local item = data

                    local itemData = Item:getOneItemByKey(itemId)
                    
                    if itemData then
                        NewYuanBaoPayUI(itemData,item,callback,others)
                    else
                        OldYuanBaoPayUI(item,callback,others)
                    end
                
                else
                    PopText("获得商品数据出错.")
                end
            else
                PopText("获得商品数据出错..")
            end
        else
            PopText("网络请求出错,请换个网络环境再试!")
        end
    end, IS_SHOW_WAITING)
    -- if others ~= nil then
    --     print("getGoodsInfo_2")
    -- else
    --     print("getGoodsInfo")
    --     -- 通过网络请求服务器获取商品信息
    --     HttpManagerEx:getGoodsInfo(itemId, function(status,errcode,errmsg,data)
    --         if status == 200 then
    --             if errcode == 0 then
    --                 if type(data) == "table" and _G.next(data) then
    --                     local item = data

    --                     local itemData = Item:getOneItemByKey(itemId)
                        
    --                     if MapIsEmpty(itemData) == false and itemData.id == itemId then
    --                         NewYuanBaoPayUI(itemData,item,callback,{})
    --                     else
    --                         OldYuanBaoPayUI(item,callback,{})
    --                     end
    --                 else
    --                     PopText("获得商品数据出错.")
    --                 end
    --             else
    --                 PopText("获得商品数据出错..")
    --             end
    --         else
    --             PopText("网络请求出错,请换个网络环境再试!")
    --         end
    --     end, IS_SHOW_WAITING)
    -- end
end

function YuanBaoPayLayer:pop(itemId, preBuyFunc, endBuyFunc)

    local layer = YuanBaoPayLayer:getInstance()
    layer:show()

    layer:setItemName("HIY关卡11-20")
    layer:setItemDesc("RED购买后可进入11-20关卡探索。")
    layer:setItemPrice("100 元宝")
    -- layer:setItemPrice("998 元宝")

    layer:setPayFunc(function()
        print("payFunc")
    end)

    layer:setCancelFunc(function()
        layer:hide()
    end)

    return layer
end

function YuanBaoPayLayer:create()
    local p = YuanBaoPayLayer.new()
    return p
end

function YuanBaoPayLayer:ctor()
    self:init()
end

function YuanBaoPayLayer:init()
    local UI = require("Layer/PayUI/YuanBaoPayUI.lua").create()['root']
    self:addChild(UI)
    Helper:convertUI(self)

    -- 初始为隐藏状态
    self:hideFast()
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 设置描述
function YuanBaoPayLayer:setItemDesc(desc)
    self.Text_desc:setTextVerticalAlignment(1)
    self.Text_desc:setString(desc)
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 设置商品名称
function YuanBaoPayLayer:setItemName(name)
    self.Text_itemName:setString(name)
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 设置商品图片
function YuanBaoPayLayer:setItemIcon(icon)
    if cc.FileUtils:getInstance():isFileExist(icon) then
        self.Image_itemIcon:loadTexture(icon)
    else
        self.Image_itemIcon:loadTexture("Image/UI/StoreUI/zhuzi.png") -- 设置为默认图标
    end
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 设置分享
function YuanBaoPayLayer:setShareDesc(shareDesc)
    if self.Text_notice == nil then
        return
    end
    if shareDesc then
        self.Text_notice:setVisible(true)
        self.Text_notice:setString(tostring(shareDesc))
    else
        self.Text_notice:setVisible(false)
    end
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 设置价格描述
function YuanBaoPayLayer:setItemPrice(priceDsc)
    self.Text_price:setString("需要花费："..tostring(priceDsc).." 元宝")
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 设置付费方法
function YuanBaoPayLayer:setPayFunc(func)
    self.Button_pay:releaseFunc(function()
        if func then
            func()
        end
    end)
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 设置取消方法
function YuanBaoPayLayer:setCancelFunc(func)
    self.Button_cancel:releaseFunc(function()
        print("self.Button_cancel:releaseFunc(function()")
        if func then
            func()
        end
    end)
end


-- @desc 设置购买打折图片显示
function YuanBaoPayLayer:setImageShow(flag)
    self.Image_DaZhe:setVisible(false)
    if flag then
        local dis_img_path = {
            ["0.9"] = "Image/UI/StoreUI/jiuzhe.png",
            ["0.8"] = "Image/UI/StoreUI/bazhe.png",
            ["0.6"] = "Image/UI/StoreUI/liuzhe.png",
            default = "Image/UI/StoreUI/jiuzhe.png"
        }
        local img_path = switch(tostring(flag),dis_img_path)
        self.Image_DaZhe:loadTexture(img_path,0)
        self.Image_DaZhe:setVisible(true)
    end
end

local specialItems = {
    -- ["yuhuiling"] = "八方游侠通过购买《八方礼包》获取更优惠。"
}
function YuanBaoPayLayer:setSpecialTextShow(itemId)
    if not itemId then 
        self.Text_specialText:setVisible(false)
        return 
    end
    if specialItems[itemId] then 
        self.Text_specialText:setString(specialItems[itemId])
        
        self.Text_specialText:setVisible(true)
    else
        self.Text_specialText:setVisible(false)
    end
end
Helper:classDefNodeGetInstance(YuanBaoPayLayer)
return YuanBaoPayLayer
0000000000000000