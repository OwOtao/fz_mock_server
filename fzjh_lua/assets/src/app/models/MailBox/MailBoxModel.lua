local NewClass = require("third.class.NewClass")
local MailBoxConstants = require("app.models.MailBox.MailBoxConstants")
local CurrencyUtil = require("app.models.Currency.CurrencyUtil")
local RoleTitleResManager = require("app.models.role.titleSystem.RoleTitleResManager")

local logTab= function(data)
    if DEBUG_MODE == 1 then
        Helper:print_lua_table(data)
    end
end

local MailBoxModel = {
    _emailList = {},
    _emailMaxNum = 50
}

function MailBoxModel:create(role)
    local p = MailBoxModel.new()
    p:init(role)
    return p
end

function MailBoxModel:init(role)
    self._role = role
end

function MailBoxModel:getEmailList()
    return self._emailList
end

function MailBoxModel:getEmailMaxNum()
    return self._emailMaxNum
end

function MailBoxModel:deleteEmailById(id)
    local index = self:getEmailIndex(id)
    table.remove(self._emailList,index)

    return assert(index,"邮箱列表没有这封邮件"..id)
end

function MailBoxModel:getEmailById(id)
    for i,v in ipairs(self._emailList) do
        if v.id == id then
            return v
        end
    end
    assert(nil,"邮箱列表没有这封邮件"..id)
end

function MailBoxModel:getEmailIndex(id)
    local index
    for i,v in ipairs(self._emailList) do
        if v.id == id then
            index = i
            break
        end
    end
    return assert(index,"邮箱列表没有这封邮件"..id)
end

function MailBoxModel:getEmails(callback)
    HttpManagerEx:getEmails(function(status, errcode, errmsg, data)
        if status == 200 then
            logTab(data)
            if errcode == 0 then
                self._emailList = data.emailList
                self._emailMaxNum = data.emailMaxNum
                if callback then
                    callback()
                end
            else
                PopText(errmsg)
            end
        else
            PopText(errmsg)
        end
    end,IS_SHOW_WAITING)
end

function MailBoxModel:deleteEmail(id,callback)
    HttpManagerEx:deleteEmail(id,function(status, errcode, errmsg, data)
        if status == 200 then
            if errcode == 0 then
                if callback then
                    callback(errcode)
                end
            elseif errcode == 2 then
                if callback then
                    callback(errcode)
                end
            else
                PopText(errmsg)
            end
        else
            PopText(errmsg)
        end
    end,IS_SHOW_WAITING)
end

function MailBoxModel:readEmail(id,callback)
    HttpManagerEx:readEmail(id,function(status, errcode, errmsg, data)
        if status == 200 then
            logTab(data)
            if errcode == 0 then
                if callback then
                    callback(errcode,data)
                end
            elseif errcode == 2 then
                if callback then
                    callback(errcode,{})
                end
            else
                PopText(errmsg)
            end
        else
            PopText(errmsg)
        end
    end,IS_SHOW_WAITING)
end

--@desc: 获取邮件奖励
--@author:LvBin
--@time:2022-02-21 15:57:39
--@id: 邮件id
	--@retrievables: 可领取列表(包括背包能放下的物品和前端属性)
	--@callback: 
--@return
function MailBoxModel:getEmailReward(id,retrievables,callback)
    local dataVer = self._role:getServerActionSystem():getDataVersion()
    local familyId = self._role:getFamilyId()
    local currencyVersion = self._role:getCurrencyVersion()
    
    HttpManagerEx:getEmailReward(id, familyId, retrievables, dataVer, currencyVersion,function(status, errcode, errmsg, data)
        if status == 200 then
            logTab(data)
            if errcode == 0 then
                callback(errcode,data)

                if data.dataVer then
                    self._role:getServerActionSystem():setDataVersion(data.dataVer)
                end

                if data.currencyVersion then
                    self._role:setCurrencyVersion(data.currencyVersion)
                end
            elseif errcode == 2 then
                callback(errcode)
            else
                PopText(errmsg)
            end
        else
            PopText(errmsg)
        end
    end,IS_SHOW_WAITING)

    if callback then
        callback(1)
    end 
end

--@desc 获取所有邮件奖励列表
function MailBoxModel:getAllEmailRewardList(callback)
    HttpManagerEx:getAllEmailRewardList(function(status, errcode, errmsg, data)
        if status == 200 then
            logTab(data)
            if errcode == 0 then
                if callback then
                    callback(data)
                end
            else
                PopText(errmsg)
            end
        else
            PopText(errmsg)
        end
    end,IS_SHOW_WAITING)
end

--@desc: 领取所有邮件奖励
--@author:LvBin
--@time:2022-02-21 18:06:26
--@retrievables: 可领取列表(包括背包能放下的物品和前端属性)
	--@callback: 
--@return
function MailBoxModel:getAllEmailReward(retrievables,callback)
    local dataVer = self._role:getServerActionSystem():getDataVersion()
    local familyId = self._role:getFamilyId()
    local currencyVersion = self._role:getCurrencyVersion()

    HttpManagerEx:getAllEmailReward(familyId, retrievables, dataVer, currencyVersion, function(status, errcode, errmsg, data)
        if status == 200 then
            logTab(data)
            if errcode == 0 then
                if callback then
                    callback(errcode,data)
                end

                if data.dataVer then
                    self._role:getServerActionSystem():setDataVersion(data.dataVer)
                end

                if data.currencyVersion then
                    self._role:setCurrencyVersion(data.currencyVersion)
                end
            elseif errcode == 2 then
                if callback then
                    callback(errcode,data)
                end
            else
                PopText(errmsg)
            end
        else
            PopText(errmsg)
        end
    end,IS_SHOW_WAITING)
end

function MailBoxModel:deleteIsFinishEmails(callback)
    HttpManagerEx:deleteIsFinishEmails(function(status, errcode, errmsg, data)
        if status == 200 then
            logTab(data)
            if errcode == 0 then
                if callback then
                    callback(errcode,data.delete_ids)
                end
            else
                if callback then
                    callback(errcode)
                end
                PopText(errmsg)
            end
        else
            PopText(errmsg)
        end
    end,IS_SHOW_WAITING)
end

--@desc: 创建可领取列表
--@author:LvBin
--@time:2022-02-21 15:55:46
--@data: 
--@return
function MailBoxModel:createRetrievables(data)
    local retrievables = {}

    local role = clone(self._role)

    if MapIsEmpty(data.loc_items) == false then
        for i,v in ipairs(data.loc_items) do
            if v.state == MailBoxConstants.OneItemUnGet then
                if role:checkCanBuyThings(v.id,v.num,"bag",false) then
                    role:changeItemCount(v.id,v.num,nil,nil)
                    table.insert(retrievables,v.onlyId)
                end
            end
        end
    end

    --本地属性
    if MapIsEmpty(data.loc_attrs) == false then
        for i,v in ipairs(data.loc_attrs) do
            if v.state == MailBoxConstants.OneItemUnGet then
                table.insert(retrievables,v.onlyId)
            end
        end
    end

    return retrievables
end

--@desc: 合并全部邮件奖励数据
--@author:LvBin
--@time:2022-02-21 18:22:25
--@return
function MailBoxModel:mergeAllEmailRewardData(data)
    local retData = {
        loc_items = {},
        net_items = {},
        loc_attrs = {},
        net_attrs = {},
        new_currencys = {},
        title_items = {}
    }
    --本地物品
    if MapIsEmpty(data.loc_items) == false then
        for i,v in ipairs(data.loc_items) do
            if retData.loc_items[v.id] == nil then
                retData.loc_items[v.id] = 0
            end
            retData.loc_items[v.id] = retData.loc_items[v.id] + v.num
        end
    end

    --虚拟物品
    if MapIsEmpty(data.net_items) == false then
        for i,v in ipairs(data.net_items) do
            if retData.net_items[v.id] == nil then
                retData.net_items[v.id] = {num = 0}
            end
            retData.net_items[v.id] = {name = v.name,num = retData.net_items[v.id].num + v.num}
        end
    end

    --本地属性
    if MapIsEmpty(data.loc_attrs) == false then
        for i,v in ipairs(data.loc_attrs) do
            if retData.loc_attrs[v.id] == nil then
                retData.loc_attrs[v.id] = 0
            end
            retData.loc_attrs[v.id] = retData.loc_attrs[v.id] + v.num
        end
    end

    --服务器属性
    if MapIsEmpty(data.net_attrs) == false then
        for i,v in ipairs(data.net_attrs) do
            if retData.net_attrs[v.id] == nil then
                retData.net_attrs[v.id] = 0
            end
            retData.net_attrs[v.id] = retData.net_attrs[v.id] + v.num
        end
    end

    --新货币
    if MapIsEmpty(data.new_currencys) == false then
        for i,v in ipairs(data.new_currencys) do
            if retData.new_currencys[v.id] == nil then
                retData.new_currencys[v.id] = 0
            end
            retData.new_currencys[v.id] = retData.new_currencys[v.id] + v.num
        end
    end

    --basicTitle
    if MapIsEmpty(data.title_items) == false then
        for i,v in ipairs(data.title_items) do
            if retData.title_items[v.id] == nil then
                retData.title_items[v.id] = 0
            end
            retData.title_items[v.id] = retData.title_items[v.id] + v.num
        end
    end

    return retData
end

function MailBoxModel:receiveReward(data)
    if MapIsEmpty(data.loc_items) == false then
        for i,v in pairs(data.loc_items) do 
            local itemAttr = Item:getOneItemByKey(v.id)
            self._role:addItemCount(v.id,v.num,nil,nil,"邮箱")
            PopText("获得"..itemAttr.name.."X"..v.num)
        end
    end
    if MapIsEmpty(data.net_items) == false then
        for i,v in ipairs(data.net_items) do
            PopText("获得"..v.name.."X"..v.num)
        end
    end
    if MapIsEmpty(data.loc_attrs) == false then
        for i,v in ipairs(data.loc_attrs) do
            local name = self._role:getCHAttrName(v.id)
            self._role:addAttr(v.id,v.num)
            PopText("获得"..name.."X"..v.num)
        end
    end
    if MapIsEmpty(data.net_attrs) == false then
        for i,v in ipairs(data.net_attrs) do
            local name = self._role:getCHAttrName(v.id)
            PopText("获得"..name.."X"..v.num)
        end
    end

    if MapIsEmpty(data.new_currencys) == false then
        for i,v in ipairs(data.new_currencys) do
            local name = self:getNewCurrencyName(v.id)
            PopText("获得"..name.."X"..v.num)
        end
    end

    if MapIsEmpty(data.title_items) == false then
        for i,v in ipairs(data.title_items) do
            local titleId = tostring(v.id)
            local title = RoleTitleResManager:getBasicTitleClassById(titleId)
            if title then
                if self._role:hasBasicTitle(titleId) == false then
                    self._role:addBasicTitle(titleId)
                end
                PopText("获得"..title:getColorName())
            end
        end
    end
end

function MailBoxModel:getNewCurrencyName(id)
    assert(id, "MailBoxModel:getNewCurrencyName id is nil")
    
    local name = CurrencyUtil:getCurrencyName(id)

    return name
end


return NewClass("MailBoxModel", {}, MailBoxModel)00000000000