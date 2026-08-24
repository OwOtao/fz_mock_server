local MailBoxLayer = class("MailBoxLayer", cc.Layer)
local MailBoxConstants = require("app.models.MailBox.MailBoxConstants")
local RoleTitleResManager = require("app.models.role.titleSystem.RoleTitleResManager")

function MailBoxLayer:create()
    local p = MailBoxLayer:new()
    p:init()
    return p
end

function MailBoxLayer:init()
    self._UI = require("app.views.ui.MailBoxUI.MailBoxUI"):create()
    self._UI:addTo(self)

    self._UI:setButtonBack(
        function()
            self:hideLayer()
        end
    )

    local MailBoxModel = require("app.models.MailBox.MailBoxModel")
    self._model = MailBoxModel:create(User:getRole())
    self._emailList = nil
    self._emailMaxNum = nil
end

function MailBoxLayer:showLayer(callback)
    self._model:getEmails(function()
        self._emailList = self._model:getEmailList()
        if #self._emailList > 1 then
            table.sort(self._emailList,function(a,b)
                if a.is_get == MailBoxConstants.UnGetAward and b.is_get ~= MailBoxConstants.UnGetAward then
                    return true
                elseif a.is_get ~= MailBoxConstants.UnGetAward and b.is_get == MailBoxConstants.UnGetAward then
                    return false
                else
                    if a.is_read == MailBoxConstants.IsRead and b.is_read == MailBoxConstants.UnRead then
                        return false
                    elseif a.is_read == MailBoxConstants.UnRead and b.is_read == MailBoxConstants.IsRead then
                        return true
                    else
                        if a.expired_time ~= b.expired_time then
                            return a.expired_time < b.expired_time
                        else
                            return a.id < b.id
                        end
                    end
                end
            end)
        end
        
        self._emailMaxNum = self._model:getEmailMaxNum()

        self:setEmailNum()
        self:initUI()
        self:setEmailListView()
        self:setButtonAllLinQu()
        self:setButtonDeleteRead()
        self:initPanelDesc()
        self:updata()
        self._handel = self:schedule(
            function(elapsed)
                self:updata()
            end, 1
        )
        if callback then
            callback()
        end
        self._UI:showUI()
    end)
end

function MailBoxLayer:setEmailNum()
    self._UI:setEmailNum("容量："..#self._emailList.."/"..self._emailMaxNum)
end

function MailBoxLayer:initUI()
    if #self._emailList > 0 then
        self._UI:setNotEmailTextIsVisible(false)
        self._UI:setButtonAllLinQuEnabled(true)
        self._UI:setButtonDeleteReadEnabled(true)
    else
        self._UI:setNotEmailTextIsVisible(true)
        self._UI:setButtonAllLinQuEnabled(false)
        self._UI:setButtonDeleteReadEnabled(false)
    end

end

function MailBoxLayer:setButtonDeleteRead(func)
    self._UI:setButtonDeleteRead(function()
        local data = {
            desc = "少侠是否确定删除已处理邮件，确认后将无法还原，请谨慎操作。",
            buttonFunc = function(callback)
                self._model:deleteIsFinishEmails(function(result,deleteList)
                    if result == 0 then
                        local idTab = {}
                        for i,id in ipairs(deleteList) do
                            idTab[id] = true
                        end
                        for i = #self._emailList,1,-1 do
                            if idTab[self._emailList[i].id] == true then
                                table.remove(self._emailList,i)
                                self._UI:removeListViewItem(i-1)
                            end
                        end
                        self._UI:popText("删除成功")
                        self:setEmailNum()
                        self:initUI()
                    end
                    
                    if callback then
                        callback()
                    end
                end)
            end
        }
        
        self._UI:initPanelTip(data)
    end)
end

function MailBoxLayer:setEmailListView()
    if MapIsEmpty(self._emailList) then
        return
    end
    local retArray = {}
    for i,v in ipairs(self._emailList) do
        local tab = {
            title = "",
            isNew = false,
            image = "Image/UI/MailBox/kuang2.png"
        }
        tab["title"] = v.title
        tab["expired_time"] = v.expired_time
        if (v.is_get == MailBoxConstants.NotAward and v.is_read == MailBoxConstants.UnRead) or v.is_get == MailBoxConstants.UnGetAward then
            tab["isNew"] = true
        end

        if v.is_get == MailBoxConstants.UnGetAward then
            tab["image"] = "Image/UI/MailBox/kuang4.png"
        end
        
        tab["deleteFunc"] = function()
            local retData = {
                desc = "",
                buttonFunc = EMPTY_FUNC
            
            }
            if v.is_get == MailBoxConstants.UnGetAward then
                retData["desc"] = "少侠是否确定删除邮件，确认后将无法还原，请谨慎操作。"
            else
                retData["desc"] = "邮件中有未领取的附件，少侠是否确定删除邮件，确认后将无法还原，请谨慎操作。"
            end
            retData["buttonFunc"] = function(callback)
                self._model:deleteEmail(v.id,function(result,data)
                    if result == 0 then
                        local index = self._model:deleteEmailById(v.id)
                        self._UI:removeListViewItem(index-1)
                        self._UI:popText("删除成功")                    
                    elseif result == 2 then
                        local index = self._model:deleteEmailById(v.id)
                        self._UI:removeListViewItem(index-1)
                        self._UI:popText("此邮件已过期，无法删除")
                    end
                    if callback then
                        callback()
                    end
                end)
            end
            
            self._UI:initPanelTip(retData)
        end

        tab["func"] = function()
            self._model:readEmail(v.id,function(result,data)
                if result == 0 then
                    v.is_read = MailBoxConstants.IsRead
                    v.expired_time = data.expired_time
                    self:popEmail(data)
                    if v.is_get ~= MailBoxConstants.UnGetAward then
                        self._UI:refreshListViewItemIsNew(i-1,false)
                    end
                elseif result == 2 then
                    local index = self._model:deleteEmailById(v.id)
                    self._UI:removeListViewItem(index-1)
                    self._UI:popText("此邮件已过期，无法打开")
                end
            end)
        end
        table.insert(retArray, tab)
    end

    self._UI:setEmailListView(retArray)
end

function MailBoxLayer:updata()
    if MapIsEmpty(self._emailList) == false then
        for i,v in ipairs(self._emailList) do
            if v.expired_time <= 0 then
                v.expired_time = 0
            end
            local day, hour, minute,second = Helper:sec3timeDsc(v.expired_time)
            local cdTimetext = "剩余时间："..day.."天"..hour.."小时"..minute.."分"..second.."秒"
            v.expired_time = v.expired_time - 1
            self._UI:refreshListViewItemTextTime(i-1,cdTimetext)
        end
    else
        self:unschedule(self._handel)
    end
end

function MailBoxLayer:popEmail(data)
    if data.is_get == MailBoxConstants.NotAward then
        self._UI:initPanelShow2(self:initPopData(data))
    elseif data.is_get == MailBoxConstants.UnGetAward or data.is_get == MailBoxConstants.GetAward then
        self._UI:initPanelShow1(self:initPopData(data))
    else
        assert(nil,"邮件状态有问题"..data.is_get)
    end
end

function MailBoxLayer:initPopData(data)
    local retData = {
        id = nil,
        title = "",
        contents = "",
        buttonStata = false,
        buttonFunc = EMPTY_FUNC,
        showList = {
            -- {name = "",num = 1}
        }
    }
    retData["id"] = data.id
    retData["title"] = data.title
    retData["contents"] = data.contents

    --@desc 附件处理
    if data.is_get == MailBoxConstants.UnGetAward or data.is_get == MailBoxConstants.GetAward then
        --本地物品
        if MapIsEmpty(data.loc_items) == false then
            for i,v in ipairs(data.loc_items) do
                local itemAttr = assert(Item:getOneItemByKey(v.id),"物品不存在"..v.id)
                local stateText = ""
                if MailBoxConstants.StateName[v.state] then
                    stateText = MailBoxConstants.StateName[v.state]
                else
                    error("附件状态异常"..v.state)
                end
                table.insert(retData["showList"],{name = itemAttr.name,num = v.num,stateText= stateText})
            end
        end

        --虚拟物品
        if MapIsEmpty(data.net_items) == false then
            for i,v in ipairs(data.net_items) do
                local stateText = ""
                if MailBoxConstants.StateName[v.state] then
                    stateText = MailBoxConstants.StateName[v.state]
                else
                    error("附件状态异常"..v.state)
                end
                table.insert(retData["showList"],{name = v.name,num = v.num,stateText= stateText})
            end
        end

        --本地属性
        if MapIsEmpty(data.loc_attrs) == false then
            for i,v in ipairs(data.loc_attrs) do
                local name = User:getRole():getCHAttrName(v.id)
                if name == nil or name == "" then
                    assert(nil,"属性不存在"..v.id)
                end
                local stateText = ""
                if MailBoxConstants.StateName[v.state] then
                    stateText = MailBoxConstants.StateName[v.state]
                else
                    error("附件状态异常"..v.state)
                end
                table.insert(retData["showList"],{name = name,num = v.num,stateText= stateText})
            end
        end

        --服务器属性
        if MapIsEmpty(data.net_attrs) == false then
            for i,v in ipairs(data.net_attrs) do
                local name = User:getRole():getCHAttrName(v.id)

                local stateText = ""
                if MailBoxConstants.StateName[v.state] then
                    stateText = MailBoxConstants.StateName[v.state]
                else
                    error("附件状态异常"..v.state)
                end
                table.insert(retData["showList"],{name = name,num = v.num,stateText= stateText})
            end
        end

        --新货币类型
        if MapIsEmpty(data.new_currencys) == false then
            for i,v in ipairs(data.new_currencys) do
                local name = self._model:getNewCurrencyName(v.id)

                local stateText = ""
                if MailBoxConstants.StateName[v.state] then
                    stateText = MailBoxConstants.StateName[v.state]
                else
                    error("附件状态异常"..v.state)
                end
                table.insert(retData["showList"],{name = name,num = v.num,stateText= stateText})
            end
        end

         --称号
         if MapIsEmpty(data.title_items) == false then
            for i,v in ipairs(data.title_items) do
                local titleId = tostring(v.id)
                local title = RoleTitleResManager:getBasicTitleClassById(titleId)

                local stateText = ""
                if MailBoxConstants.StateName[v.state] then
                    stateText = MailBoxConstants.StateName[v.state]
                else
                    error("附件状态异常"..v.state)
                end
                table.insert(retData["showList"],{name = title:getText(),num = v.num,stateText= stateText})
            end
        end
    end

    if data.is_get == MailBoxConstants.UnGetAward then
        retData["buttonStata"] = true
        retData["buttonFunc"] = function(callback)
            self:confirmLayer("若后续进行读档操作，会导致已领取的附件丢失，是否继续完成领取？",function()
                --@desc 可领取列表
                local retrievables = self._model:createRetrievables(data)

                self._model:getEmailReward(retData.id,retrievables,function(result,netData)
                    if result == 0 then
                        self._model:receiveReward(netData)
                        if netData.msg then
                            self._UI:popText(netData.msg)
                        end

                        local email = self._model:getEmailById(retData.id)
                        email.expired_time = netData.expired_time
                        email.is_get = netData.is_get
                        
                        local image = "Image/UI/MailBox/kuang4.png"
                        local isNew = true
                        if netData.is_get == MailBoxConstants.GetAward then
                            image = "Image/UI/MailBox/kuang2.png"
                            isNew = false
                        end

                        local index = self._model:getEmailIndex(retData.id)
                        self._UI:refreshListViewItemIsNew(index-1,isNew,image)
                        if callback then
                            callback()
                        end
                    elseif result == 2 then
                        if callback then
                            callback()
                        end
                        local index = self._model:deleteEmailById(retData.id)
                        self._UI:removeListViewItem(index-1)
                        self._UI:popText("此邮件已过期，无法领取")
                    end
                end)
            end)
        end
    end

    return retData
end

function MailBoxLayer:setButtonAllLinQu()
    self._UI:setButtonAllLinQu(function()
        self._model:getAllEmailRewardList(function(data)
            self._UI:initPanelShowAllItem(self:initAllEmailRewardData(data))
        end)
    end)
end

function MailBoxLayer:initAllEmailRewardData(data)
    local retData = {
        needWeight = "所需空间",
        currWeight = "",
        buttonFunc = EMPTY_FUNC,
        showList = {
            -- {name = "",num = 1}
        }
    }
    local needCount = 0
    local role = User:getRole()
    local itemsCount = #role:getItems()
    local roleWeight = role:getAttr("weight")
    retData["currWeight"] = itemsCount.."/"..roleWeight.." 背包空间"

    local mergeData = self._model:mergeAllEmailRewardData(data)

    --本地物品
    if MapIsEmpty(mergeData.loc_items) == false then
        for id,num in pairs(mergeData.loc_items) do
            local itemAttr = assert(Item:getOneItemByKey(id),"物品不存在"..id)
            table.insert(retData["showList"],{name = itemAttr.name,num = num})

            if role:checkIsNoLimitItem(id) == false then
                if itemAttr.canFold == ITEM_STATE_FALSE then   --不能堆叠
                    needCount = needCount + num
                elseif itemAttr.canFold == ITEM_STATE_TRUE then   --能堆叠
                    local mod, remainder = math.modf(num / 99)
    
                    if math.ceil(remainder) == 1 then
                        mod = mod + 1
                    end
                    needCount = needCount + mod
                end
            end
        end
    end

    --虚拟物品
    if MapIsEmpty(mergeData.net_items) == false then
        for id,v in pairs(mergeData.net_items) do
            table.insert(retData["showList"],{name = v.name,num = v.num})
        end
    end

    --本地属性
    if MapIsEmpty(mergeData.loc_attrs) == false then
        for id,num in pairs(mergeData.loc_attrs) do
            local name = User:getRole():getCHAttrName(id)
            if name == nil or name == "" then
                assert(nil,"属性不存在"..id)
            end
            table.insert(retData["showList"],{name = name,num = num})
        end
    end

    --服务器属性
    if MapIsEmpty(mergeData.net_attrs) == false then
        for id,num in pairs(mergeData.net_attrs) do
            local name = User:getRole():getCHAttrName(id)
            table.insert(retData["showList"],{name = name,num = num})
        end
    end

    --新货币
    if MapIsEmpty(mergeData.new_currencys) == false then
        for id,num in pairs(mergeData.new_currencys) do
            local name = self._model:getNewCurrencyName(id)
            table.insert(retData["showList"],{name = name,num = num})
        end
    end

    --称号
    if MapIsEmpty(mergeData.title_items) == false then
        for id,num in pairs(mergeData.title_items) do
            local titleId = tostring(id)
            local title = RoleTitleResManager:getBasicTitleClassById(titleId)
            table.insert(retData["showList"],{name = title:getText(),num = num})
        end
    end

    retData["needWeight"] = "所需空间"..needCount
    retData["buttonFunc"] = function()
        self:confirmLayer("若后续进行读档操作，会导致已领取的附件丢失，是否继续完成领取？",function()
            --@desc 可领取列表
            local retrievables = self._model:createRetrievables(data)

            self._model:getAllEmailReward(retrievables,function(result,netData)
                if result == 0 then
                    self._model:receiveReward(netData)
                    if netData.msg then
                        self._UI:popText(netData.msg)
                    end

                    local is_getList = netData.is_getList
                    for index,email in ipairs(self._emailList) do
                        for i,v in ipairs(is_getList) do
                            if email.id == v.id then
                                email.is_get = MailBoxConstants.GetAward
                                email.expired_time = v.expired_time

                                self._UI:refreshListViewItemIsNew(index-1,false,"Image/UI/MailBox/kuang2.png")
                            end
                        end
                    end 
                elseif result == 2 then
                    local expired_ids = netData.expired_ids
                    for i,id in ipairs(expired_ids) do
                        local index = self._model:deleteEmailById(id)
                        self._UI:removeListViewItem(index-1)
                    end
                    self._UI:popText("已有邮件过期，请重新领取")
                end
            end)
        end)
    end

    return retData
end

function MailBoxLayer:confirmLayer(text,callback)
    local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")
    local dialog = DialogALayer:getInstance()
    dialog:hide()
    dialog:show(text)
    dialog:setButton1(
        "是",
        function()
            if callback then
                callback()
            end
        end
    )
    dialog:setButton2(
        "否",
        function()
        end
    )
    dialog:setWeChatVisible(false)
end

function MailBoxLayer:hideLayer()
    PopupLayerController:hideLayer(
        "MailBoxLayer",
        function(layer)
            self:unschedule(self._handel)
            self._UI:hideUI()
        end
    )
end

function MailBoxLayer:initPanelDesc()
    self._UI:initPanelDesc("江湖邮驿的最大邮件容量为50份，未读状态的邮件储存时间为30天，已领取完毕的含附件邮件和已阅读的纯文本邮件储存时间为3天，邮件储存时间到期后自动删除。若邮件数量达到上限，接收新的邮件时，优先删除顺序为：剩余时间最短的已阅读的纯文本邮件、已领取完毕的含附件邮件、未阅读的纯文本邮件、未领取的含附件邮件。")
end

Helper:classDefNodeGetInstance(MailBoxLayer)
return MailBoxLayer
00000000000