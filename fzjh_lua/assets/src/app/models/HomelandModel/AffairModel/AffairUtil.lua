local newClass = require("third.class.NewClass")

local AffairUtil = {
    __list = {}
}

function AffairUtil:create()
    local p = AffairUtil.new()
    p:init()
    return p
end

function AffairUtil:init()
    self.__list = {}
end

--@desc: 插入
--@author:Liang SongQiang
--@time:2018-08-10 10:43:52
--@affair: [src.app.models.HomelandModel.AffairModel.Affair#Affair]
function AffairUtil:pushToList(affair)
    table.insert(self.__list, affair)
end

--@desc: 删除
--@author:Liang SongQiang
--@time:2018-08-10 10:43:26
--@index:索引
function AffairUtil:popFromList(index)
    self:unBindUi(index)
    table.remove(self.__list, index)
end

function AffairUtil:getList()
    return self.__list
end

--@desc: 获取单个事务
--@author:Liang SongQiang
--@time:2018-08-10 11:25:50
--@index: 索引
--@return[src.app.models.HomelandModel.AffairModel.Affair#Affair]
function AffairUtil:getAffair( index )
    return self.__list[index]
end

function AffairUtil:getListNum()
    return #self.__list
end

--@desc: UI绑定
--@author:Liang SongQiang
--@time:2018-08-10 10:47:40
--@index:要绑定的索引
--@attrName:属性名
--@func: 绑定触发的方法
function AffairUtil:bindUi(index, attrName, func)
    --@RefType [src.app.models.HomelandModel.AffairModel.Affair#Affair]
    local affair = self.__list[index]

    if affair == nil then
        return nil
    end

    local tag = affair:bindAttrUiWithFunc(attrName, func)

    if affair._bindTag == nil then
        affair._bindTag = {}
    end

    table.insert(affair._bindTag, tostring(attrName .. ";" .. tag))

    return true
end

--@desc: 解除绑定
--@author:Liang SongQiang
--@time:2018-08-10 10:56:13
--@index:事务的索引
function AffairUtil:unBindUi(index)
    --@RefType [src.app.models.HomelandModel.AffairModel.Affair#Affair]
    local affair = self.__list[index]

    if affair == nil or MapIsEmpty(affair._bindTag) then
        return
    end

    for _,bindtag in ipairs(affair._bindTag) do
        local bind_arr = string.split(bindtag,";")

        local attrName =bind_arr[1]

        local tag = bind_arr[2]

        affair:unBindAttr(attrName,tag)
    end
end

--@desc: 清除列表
--@author:Liang SongQiang
--@time:2018-08-10 11:09:14
function AffairUtil:clearList()
    if MapIsEmpty(self.__list) then
        return
    end

    for index=#self.__list,1,-1 do
        self:popFromList(index)
    end

end

return newClass("AffairUtil", {}, AffairUtil)
00000