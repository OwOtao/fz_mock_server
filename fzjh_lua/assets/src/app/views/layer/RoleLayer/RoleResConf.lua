--[[
    副本角色相关资源配置
]]
local RoleResConf = {}

function RoleResConf:getBackImgPath(index)
    local path =
        switch(
        tostring(index),
        {
            --@desc 特殊家具背景
            ["1"] = "Image/UI/RoleUI/furBack.png",
            --@desc 周年庆边框
            ["2"] = Resource:getImgPath("anniversaryInfoFrame"),
            --@desc 二周年庆
            ["3"] = Resource:getImgPath("anniversaryInfoFrame2"),
            --@desc 月卡用户
            ["4"] = "Image/UI/RoleUI/11.png",
            --@desc 默认背景
            default = "Image/UI/RoleUI/RoeBack.png"
        }
    )

    return path
end

function RoleResConf:getBtnImgName(index)
    local imgName =
        switch(
        tostring(index),
        {
            ["1"] = "Button_JiaJu1",
            ["2"] = "Button_JiaJu2",
            default = "Button_3_0"
        }
    )

    return imgName
end

--@desc 获取角色的背景边框
function RoleResConf:getFaceInfoFrame(role)
    local index = role.backImg

    if index == nil and role.type ~= "item" then
        return role:getFaceInfoFrame()
    end

    return self:getBackImgPath(tostring(index))
end


function RoleResConf:getRoleSound(role)
    local age, sex, zhengQi = tonumber(role:getAttr("age")), role:getAttr("sex"), tonumber(role:getFinalAttr("zhengqi"))
    local effectName = ""

    if sex == "男" then
        if age < 15 then
            effectName = "nianShaoNormalNan"
        elseif age < 30 then
            if zhengQi >= 0 then
                effectName = "nianQingZhengNan"
            else
                effectName = "nianQingXieNan"
            end
        elseif age < 50 then
            if zhengQi >= 0 then
                effectName = "chengShuZhengNan"
            else
                effectName = "chengShuXieNan"
            end
        elseif age >= 50 then
            if zhengQi >= 0 then
                effectName = "nianLaoZhengNan"
            else
                effectName = "nianLaoXieNan"
            end
        end
    elseif sex == "女" then
        if age < 15 then
            effectName = "nianShaoNormalNv"
        elseif age < 50 then
            if zhengQi >= 0 then
                effectName = "nianQingZhengNv"
            else
                effectName = "nianQingXieNv"
            end
        elseif age >= 50 then
            if zhengQi >= 0 then
                effectName = "nianZhangZhengNv"
            else
                effectName = "nianZhangXieNv"
            end
        end
    else
        -- effectName = "nianShaoNormalNv"
    end

    return effectName
end

return RoleResConf0