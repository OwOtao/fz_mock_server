local RoleBorderConfig = require("app.models.HeadViewSystem.RoleBorderConfig")

local res = require("script.HeadView.roleBorderConf")["Sheet1"]

local BorderConfigManager = {
    __cache = {}
}

--@desc: 获取框体信息对象
--@author:Seven
--@time:2021-11-23 12:06:57
--@return [src.app.models.HeadViewSystem.RoleBorderConfig#RoleBorderConfig]
function BorderConfigManager:getBorderConf(id)
    id = tostring(id)

    if self.__cache[id] == nil then
        local resData = res[id]

        if resData == nil then
            error("找不到对应的特殊框体配置 id ：" .. id)
        end

        self.__cache[id] = RoleBorderConfig:create(resData)
    end

    return self.__cache[id]
end



return BorderConfigManager
000