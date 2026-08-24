local PortraitZhenYing = {}

--是否属于中原阵营
function PortraitZhenYing:isZhongYuanZY(portraitId)
    if portraitId == nil then
        return false
    end
    local list = {
        mianju1002 = true,
        mianju1004 = true,
        mianju1005 = true,
        mianju1008 = true,
        mianju1010 = true,
        mianju1012 = true,
        mianju1013 = true,
        mianju1017 = true,
        mianju1018 = true,
        mianju1019 = true,
        mianju1020 = true,
        mianju1025 = true,
        mianju1029 = true,
        mianju1043 = true,
        mianju1044 = true,
        mianju1047 = true,
        mianju1050 = true,
        mianju1051 = true,
        mianju1053 = true,
        mianju1058 = true,
        mianju1066 = true,
        mianju1067 = true,
        mianju1071 = true,
        mianju1072 = true,
        mianju1074 = true,
        mianju1075 = true,
        mianju1080 = true,
        mianju1083 = true,
        mianju1084 = true,
        mianju1087 = true,
        mianju1091 = true,
        mianju1097 = true,
        mianju1100 = true,
        mianju1110 = true,
        mianju1111 = true,
        mianju1113 = true,
        mianju1116 = true,
        mianju1117 = true,
        mianju1121 = true,
        mianju1122 = true,
        mianju1128 = true,
        mianju1130 = true,
        mianju1132 = true,
        mianju1135 = true,
        mianju1148 = true,
        mianju1155 = true,
    }

    if list[portraitId] then
        return true
    end

    return false
end

--是否属于重光阵营
function PortraitZhenYing:isChongGuangZY(portraitId)
    if portraitId == nil then
        return false
    end
    local list = {
        mianju1054 = true,
        mianju1055 = true,
        mianju1059 = true,
        mianju1060 = true,
        mianju1093 = true,
        mianju1145 = true,
        mianju1146 = true,
        mianju1147 = true,
    }

    if list[portraitId] then
        return true
    end

    return false
end

--是否属于其它阵营，包括不戴面具
function PortraitZhenYing:isOtherZY(portraitId)
    if self:isZhongYuanZY(portraitId) == false and self:isChongGuangZY(portraitId) == false then
        return true
    end

    return false
end


--对外接口 面具是否是指定阵营
--portraitId  面具id
--zhenYing  指定阵营  0 其它 ,1 中原 ,2重光
function PortraitZhenYing:isAppointZY(portraitId,zhenYing)
    if zhenYing == nil then
        return false
    end

    local result = switch(tostring(zhenYing),
    {
        ["0"] = self.isOtherZY,

        ["1"] = self.isZhongYuanZY,

        ["2"] = self.isChongGuangZY,
    },self,portraitId)

    return result
end

return PortraitZhenYing0000000000000