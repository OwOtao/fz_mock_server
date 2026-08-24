local TaiQingTaiModel = {}

--@RefType [src.app.models.HomelandModel.HomelandRoleUtil#HomelandRoleUtil]
local HomelandRoleUtil = require("app.models.HomelandModel.HomelandRoleUtil")

function TaiQingTaiModel:getLeftList()
    return self._leftList
end

function TaiQingTaiModel:getRightList()
    return self._rightList
end

function TaiQingTaiModel:getLeftItem(index)
    return self._leftList[index]
end

function TaiQingTaiModel:popLeftItem(index)
    table.remove(self._leftList, index)
end

function TaiQingTaiModel:pushLeftItem(value)
    table.insert(self._leftList, value)
    self:sortLeftList()
end

function TaiQingTaiModel:getRightItem(index)
    return self._rightList[index]
end

function TaiQingTaiModel:popRightItem(index)
    table.remove(self._rightList, index)
end

function TaiQingTaiModel:pushRightItem(value)
    table.insert(self._rightList, 1, value)
end

function TaiQingTaiModel:setZcLv(value)
    self._zclv = value
end

function TaiQingTaiModel:getZcLv()
    return self._zclv
end

function TaiQingTaiModel:getCost()
    return math.floor(#self._rightList * 2.5 * (140 / self:getZcLv()))
end

function TaiQingTaiModel:setYinPiao(num)
    self._yinpiao = num or 0
end

--@desc: 创建要宴请的npc列表
--@author:Liang SongQiang
--@time:2018-09-27 16:17:17
--@map: [src.app.models.map.BaseMap#BaseMap]
function TaiQingTaiModel:initLeftList(map)
    local list = {}

    local rooms = map:getRoomMap()

    for roomId, room in pairs(rooms) do
        local rolelist = map:getRoomRoleList(roomId)

        for index, role_id in ipairs(rolelist) do
            local npc = map:getRole(role_id)
            if npc.type == "role" and npc.jobType ~= nil then
                if HomelandRoleUtil:getFidelityLvByRoleId(map, role_id) >= 3 or npc.job == "guanjia001" then
                    local t = {
                        id = npc.id,
                        name = npc.realName or npc.name,
                        jobType = npc.jobType,
                        zc = npc.defaultZhongCheng
                    }
                    table.insert(list, t)
                end
            end
        end
    end

    self._leftList = list

    self:sortLeftList()

    local npc = self:getLeftItem(1)
    local lv = 1
    if npc ~= nil and npc.jobType == "guanjia001" then
        lv = HomelandRoleUtil:getFidelityLv(npc.zc)
    end

    self:setZcLv(lv)
end

function TaiQingTaiModel:initRightList()
    self._rightList = {}
end

--@desc: 排序
--@author:Liang SongQiang
--@time:2018-09-27 16:54:56
function TaiQingTaiModel:sortLeftList()
    if MapIsEmpty(self._leftList) then
        return
    end

    table.sort(
        self._leftList,
        function(a, b)
            if a.jobType == "guanjia001" then
                return true
            elseif b.jobType == "guanjia001" then
                return false
            end

            return a.zc > b.zc
        end
    )
end



function TaiQingTaiModel:clear()
    self._rightList = {}
    self._leftList = {}
    self._zc = 0
    self._yinpiao = 0
end

function TaiQingTaiModel:fete(callback)
    if MapIsEmpty(self._rightList) then
        PopText("请选择您要宴请的人。")
        return
    end


    if self._yinpiao < self:getCost() then
        PopText("你拥有的银票不足，无法开宴！")
        return
    end

    local update_data = {}

    local addValues = {}

    for index, npc in ipairs(self._rightList) do
        local addValue = (HomelandRoleUtil:getFidelityLv(npc.zc) + 1) ^ 2 + math.random(16, 36)

        print(addValue, npc.zc, npc.name)

        if npc.zc + addValue > 4000 then
            addValue = math.max( 4000 - npc.zc,0 )
        end

        addValues[npc.id] = addValue

        update_data[npc.id] = {
            defaultZhongCheng = npc.zc + addValue
        }
    end

    local cost = {
        value = self:getCost(),
        unit = "yinpiao"
    }

    --@RefType [src.app.models.role.Role#Role]
    local role = User:getRole()

    local map = role:getCurrMap()

    Helper:print_lua_table(update_data)

    HttpManagerEx:updateHomeAttr(
        map.mid,
        nil,
        update_data,
        nil,
        cost,
        function(status, errcode, errmsg, data)
            if 200 == status then
                if 0 == errcode then
                    PopText("你花费了 " .. cost.value .. "银票")
                    local text = "HIY你登上太清台，踌躇满志、逸兴遄飞，胸中的豪情很想找人分享。于是你宴请了"
                    for npcId, addValue in pairs(addValues) do
                        local npc = map:getRole(npcId)
                        npc.defaultZhongCheng = npc.defaultZhongCheng + addValue

                        text = text .. "HIC" .. (npc.realName or npc.name) .. "NOR、"
                        RichPrint("main", (npc.realName or npc.name) .. "忠诚度 + " .. addValue)
                    end

                    text = string.sub(text, 1, -4)

                    text = text .. "HIY，一时间觥筹交错，主仆尽欢。NOR"

                    role:setTimeLimitFlag("设宴CD", 1, 3600 * 48)
                    
                    if callback then
                        callback()
                    end

                    RichPrint("main", text)
                else
                    PopText("宴请失败")
                    print("errcode = " .. errcode, "errmsg : " .. errmsg)
                end
            else
                PopText("网络请求出错,请换个网络环境再试!")
            end
        end,
        IS_SHOW_WAITING
    )
end

return TaiQingTaiModel
00000