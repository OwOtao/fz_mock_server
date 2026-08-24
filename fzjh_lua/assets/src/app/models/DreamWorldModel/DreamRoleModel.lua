local DreamRoleModel = {}

--从服务器获取人物数据
function DreamRoleModel:getDreamRoleFromWeb(func)
    HttpManagerEx:getDreamRoleData(
        function(status, errcode, errmsg, data)
            if status == 200 then
                if errcode == 0 then
                    if func then
                        func(data)
                    end
                    return true
                elseif errcode == 2 then
                    if func then
                        func(nil)
                    end
                    return true
                else
                    PopText(errmsg)
                    return false
                end
            else
                PopText(errmsg)
                return false
            end
        end,
        IS_SHOW_WAITING,
        HTTP_MANAGER_RETRY_TYPE_RETRY
    )
end

--上传梦境人物数据
function DreamRoleModel:uploadDreamRole(dreamRoleData,callback)
    if MapIsEmpty(dreamRoleData) then
        return
    end
    HttpManagerEx:uploadDreamRoleData(dreamRoleData,function(status, errcode, errmsg, data)
        if status == 200 then
            return callback(errcode,errmsg,data)
        else
            PopText(errmsg)
            return false
        end
    end,IS_SHOW_WAITING,HTTP_MANAGER_RETRY_TYPE_RETRY)
end

--@desc 注册主角相关事件
function DreamRoleModel:addRoleMessage(role)
    MessageCenter:addListener("itemChangeEvent",function(event)
        if role ~= event.role then
            return
        end

        local itemId = event.itemId
        local count = event.count
        --@desc 无数量变化
        if count == 0 then
            return
        end

        local itemData = Item:getOneItemByKey(itemId)

        --@desc 排除不需要检测的物品
        if itemId == "drwp101" or itemId == "drwp102" or itemId == "drwp103" or itemData.treasure == 1 then
            --@TODO 2020-08-06 16:10:49 临时刷新物品数量方法
            local mapLayer = MainControllLayer:getLayer("MapLayer")
            mapLayer:setItemCount()
        end
    end,role)
end

return DreamRoleModel000000000