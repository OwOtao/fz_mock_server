local SwitchServerLayer = class("SwitchServerLayer", LayerEx)

function SwitchServerLayer:create()
    local p = SwitchServerLayer.new()
    p:init()
    return p
end

function SwitchServerLayer:init()
    self._entryGameFunc = function() end
    
    self.UI = require("Layer/SwitchServerUI/SwitchServerUI.lua").create()['root']
    self:addChild(self.UI)
    Helper:convertUIByParent(self)
    
    -- 隐藏部件 add by TangJian 2017/06/27 21:56:41
    self.Panel_parts:setClippingEnabled(true)

    self.Image_root.Text_8:setString("当前分区：")
    
    self:initButton()
end

function SwitchServerLayer:initButton()
    self.Panel_back:releaseFunc(function()
        self:hide()
    end)
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2017/06/28 17:16:45
-- @desc 显示并且刷新服务器列表
function SwitchServerLayer:showAndUpdate()
    self:hideFast()
    
    self:refreshServerList(
        function()
            self:show()
        end
    )

end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2017/06/27 21:57:53
-- @desc 创建选择服务器item
function SwitchServerLayer:createServerItem(serverId, serverName, serverChannel, serverDesc, serveerPatitionName, should_select_migrate)
    local serverItem = self.Panel_parts.Panel_serverItem:clone()
    Helper:convertUI(serverItem)
    serverItem.Text_serverName:setString(serverName)
    serverItem.Text_serverDesc:setString(Helper:getDef(serverDesc, ""))
    
    -- 响应按键
    serverItem:releaseFunc(function()
        if serverId == SwitchServerController:getActiveServerId() then
            PopText("你已经在当前分区")
            return
        end 
        if serverChannel == "taptap" or serverChannel == "fzjh" then
            -- if SwitchServerController:getUserInfo().needSelectInherit == true then
            if should_select_migrate == true then
                local switchServerSelectStartLayer = SwitchServerSelectStartLayer:getInstance()
                switchServerSelectStartLayer:show()
                switchServerSelectStartLayer:setItemFunc1(function()

                    local switchServerEmailLayer = SwitchServerEmailLayer:getInstance()
                    switchServerEmailLayer:show()
                    
                    switchServerEmailLayer:setEditEmail(SwitchServerController:getUserInfo().email)
                    
                    -- 获取验证码 add by TangJian 2017/06/28 18:03:41
                    switchServerEmailLayer:setGetCodeFunc(function()
                        local email = switchServerEmailLayer:getEditEmail()
                        Account:sendEmail("继承", email,
                            function(status, expired_time, errmsg)
                                if status == "发送成功" then
                                    PopText("已发送验证码到您邮箱")
                                else
                                    PopText(errmsg)
                                end
                            end)
                    end)
                    
                    -- 确认 add by TangJian 2017/06/28 18:03:48
                    switchServerEmailLayer:setConfirmFunc(function()
                    local email = switchServerEmailLayer:getEditEmail()
                    local code = switchServerEmailLayer:getEditCode()

                    SwitchServerController:migrateToNewPackage(email, code, serverId,
                        function(status, errmsg)
                            if status == "成功" then
                                SwitchServerController:switchServer(serverId,
                                    function(status)
                                        if status == "成功" then
                                            local switchServerInheritRoleEntryGameLayer = SwitchServerInheritRoleEntryGameLayer:getInstance()
                                            switchServerInheritRoleEntryGameLayer:show()
                                            switchServerInheritRoleEntryGameLayer:setEntryGameFunc(
                                            function()
                                                switchServerInheritRoleEntryGameLayer:hide()
                                                switchServerEmailLayer:hide()
                                                switchServerSelectStartLayer:hide()
                                                self:hide()
                                                self._entryGameFunc()
                                                PopText("已切换到服务器：" .. serverName)
                                                -- SwitchServerController:setSelectServerName(serverName)
                                                SwitchServerController:setSelectServerId(serverId)
                                            end)
                                        end
                                    end)
                            else
                                PopText(errmsg)
                            end
                        end)
                    end)
                end)
                switchServerSelectStartLayer:setItemFunc2(function()
                    SwitchServerController:switchServer(serverId,
                    function(status)
                        if status == "成功" then
                            switchServerSelectStartLayer:hide()
                            self:hide()
                            -- SwitchServerController:setSelectServerName(serverName)
                            SwitchServerController:setSelectServerId(serverId)

                            PopText("已切换到服务器：" .. serverName)
                        end
                    end)
                end)
            else
                SwitchServerController:switchServer(serverId,
                function(status)
                    if status == "成功" then
                        self:hide()
                        -- SwitchServerController:setSelectServerName(serverName)
                        SwitchServerController:setSelectServerId(serverId)

                        cc.Director:getInstance():getRunningScene():delayFunc(0.5, function()
                            PopText("已切换到服务器：" .. serverName)
                        end)

                    end
                end)
            end
        else
            SwitchServerController:switchServer(serverId,
                function(status)
                    if status == "成功" then
                        self:hide()
                        PopText("已切换到服务器：" .. serverName)
                        SwitchServerController:setSelectServerId(serverId)

                        -- SwitchServerController:setSelectServerName(serverName)
                    end
                end)
        end
    end)
    return serverItem
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2017/06/27 21:58:25
-- @desc 刷新服务器列表
function SwitchServerLayer:refreshServerList(callback)
    SwitchServerController:updateServerList(
        function(status, errmsg)
            if status == "成功" then
                self:setServerList(SwitchServerController:getServerList())
                self:setCurrActiveServer(SwitchServerController:getActiveServerName())
                callback()
            else
                PopText(errmsg)
                self:hide()
            end
        end)
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2017/06/27 22:41:44
-- @desc 设置服务器列表
function SwitchServerLayer:setServerList(serverList)
    self.Image_root.ListView_server:removeAllItems()
    for i, server in ipairs(serverList) do
        self.Image_root.ListView_server:pushBackCustomItem(self:createServerItem(server.id, server.name, server.channel, server.desc, server.partition_name, server.should_select_migrate))
    end
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2017/06/27 22:45:05
-- @desc 设置当前活跃服务器
function SwitchServerLayer:setCurrActiveServer(name)
    self.Image_root.Text_currServerName:setString(name)
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2017/06/28 23:05:30
-- @desc 设置回调
function SwitchServerLayer:setEntryGameFunc(func)
    self._entryGameFunc = Helper:getDef(func, function() end)
end

Helper:classDefNodeGetInstance(SwitchServerLayer)
return SwitchServerLayer
00