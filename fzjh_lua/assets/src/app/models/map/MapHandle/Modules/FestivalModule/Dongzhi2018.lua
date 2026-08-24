--@SuperType [src.app.models.map.MapHandle.Modules.BaseModule#BaseModule]
local Dongzhi2018 = class("Dongzhi2018", require("app.models.map.MapHandle.Modules.BaseModule"))

local HomelandUtil = require("app.models.HomelandModel.HomelandUtil")
local CRFactory = require("app.models.HomelandModel.CRFactory")
local FangQiModel = require("app.models.HomelandModel.FangQiModel")
local HomelandDesc = require("app.models.HomelandModel.HomelandDesc")

--@RefType [src.app.models.map.MapInfo#MapInfo]
local MapInfo = require("app.models.map.MapInfo")

--@desc 开启状态，默认开启
Dongzhi2018.status = 1

--@desc 活动时间 : 格式：20171001，默认值0 表示无时间限制
Dongzhi2018.activityTime = 0


Dongzhi2018.doResult = {
    ["做月饼"] = function (map, result, environment)
        local currRole = environment.currRole
        if map.dongZhiJiaoZiReward then
            local text = "#ch#，刚烹饪的食物还在灶台呢，你先吃完我再给你做。"
            PopText(HomelandDesc:subChengHuText(text))  --称呼
            return
        end
        local todayCount = User:getRole():getDayFlag("中秋做月饼")
        if todayCount >= 1 then
            PopText("做月饼次数已达今日上限！")
            return
        end
        local list = {
            {name = "五仁月饼",item1 ="2021zqmf",item2 = "2021zqwrx",reward = "2021zqwryb"},
            {name = "莲蓉月饼",item1 ="2021zqmf",item2 = "2021zqxrx",reward = "2021zqlryb"},
            {name = "火腿月饼",item1 ="2021zqmf",item2 = "2021zqhtx",reward = "2021zqhtyb"},
        }
        PopupLayerController:showLayer(
            "ChooseButtonLayer",
            function(layer)
                local text = "#ch#，您要做哪种月饼，我可以代劳。"
                text = HomelandDesc:subChengHuText(text)

                local params = {}
                for i, v in ipairs(list) do
                    params["btnName" .. i] = v.name
                    params["btnFunc" .. i] = function()
                        local jiaoziArray = list[i]
                        if jiaoziArray == nil then
                            assert(false," 检查烹饪饺子 index = "..i)
                        end
                        local item1 = jiaoziArray.item1
                        local item2 = jiaoziArray.item2
                        local reward = jiaoziArray.reward

                        local ret = false
                        local role = User:getRole()
                        local items1 =
                            role:getItems(function(item)
                                return item.itemId == item1
                            end
                        )
                        local items2 =
                            role:getItems(function(item)
                                return item.itemId == item2
                            end
                        )
                        
                        if #items1 > 0 and #items2 > 0 then
                            ret = true
                        end

                        if ret then
                            role:addItemCount(item1,-1)
                            role:addItemCount(item2,-1)
                            local itemAttr1 = Item:getOneItemByKey(item1)
                            local itemAttr2 = Item:getOneItemByKey(item2)
                            PopText("您消耗了 " .. itemAttr1.name .. " X1")
                            PopText("您消耗了 " .. itemAttr2.name .. " X1")

                            map.dongZhiJiaoZiReward = reward
                            role:setDayFlag("中秋做月饼",role:getDayFlag("中秋做月饼") + 1)

                            local roleList = map:getRoomRoleList(map:getCurrRoomId())
                            for i, v in ipairs(roleList) do
                                local roleData = map:getRole(v)
                                if roleData.iType == "灶台" then
                                    local conAndResult = {
                                        conditionRelation = "and",
                                        conditions = {
                                            {
                                                arg1 = "玩家操作",
                                                arg2 = "使用4"
                                            }
                                        },
                                        results = {
                                            {
                                                arg1 = "取走食物"
                                            }
                                        }
                                    }
                                    table.insert(roleData.conditionAndResults, conAndResult)
                                    local ResultsNum = #roleData.conditionAndResults
                                    roleData["canUse"..ResultsNum] = 1
                                    roleData["useName"..ResultsNum] = "取走食物"
                                end
                            end
                            PopupLayerController:showLayer(
                                "GlobalShadeLayer",
                                function(layer)
                                    layer:showLayer()
                                    layer:setPopText("厨子此时正在烹饪，还是稍等片刻吧。")
                                end
                            )

                            local textArr = {
                                "厨子把面粉搅拌成面团，把月饼馅包入面粉团中，揉成球状。",
                                "HIY面球轻搓成椭圆放入模具，印出花边，最后放入平锅中烧烤。",
                                "HIB待香味溢出，厨子将月饼取了出来。"
                            }

                            local index = 0
                            map:setSchedule(
                                function(tag)
                                    index = index + 1
                                    RichPrint("main", textArr[index])

                                    if index == #textArr then
                                        PopupLayerController:hideLayer(
                                            "GlobalShadeLayer",
                                            function(layer)
                                                PopText("月饼制作完毕，已经端到灶台上了！")
                                                layer:hideLayer()
                                                map:unSchedule(tag)
                                            end
                                        )
                                    end
                                end,
                                1,1
                            )
                        else
                            PopText(HomelandDesc:subChengHuText("#ch#，这食材不够，我也无法做月饼呀。"))
                        end
                    end
                end
                layer:initLayer(text,
                    params.btnName1,
                    params.btnFunc1,
                    params.btnName2,
                    params.btnFunc2,
                    params.btnName3,
                    params.btnFunc3
                )
            end
        )
    end,
    ["取走食物"] = function(map, result, environment)
        local currRole = environment.currRole
        local reward = map.dongZhiJiaoZiReward
        assert(reward,"检查为什么没有食物")

        local fq = User:getRole():getHomelandAttr("fq")
        if MapIsEmpty(fq) then 
            print("没有房契数据")
            return
        end

        local percent = math.random(1, 100)  --概率
        local num = 1 
        local reWardList = {}
        reWardList[reward] = num
        if User:getRole():checkCanBuyTwoOrMoreThings(reWardList) ~= true then
			return
		end
        local itemAttr = Item:getOneItemByKey(reward)
        print("percent"..percent)
        print("取走"..itemAttr.name.."x"..num) 
        User:getRole():addItemCount(reward, num)
        PopText("获取物品" .. itemAttr.name .. "X" .. tostring(num))

        for i = 1,8 do
            local ResultsName = currRole["useName"..i]
            if ResultsName then
                if ResultsName == "取走食物" then
                    currRole["canUse"..i] = 0
                    table.remove( currRole.conditionAndResults,i)
                end
            else
                break
            end
        end
        map.dongZhiJiaoZiReward = nil
    end,
}

function Dongzhi2018:entryMap(map, currTime)
    if map:getMapType() ~= MAP_TYPE.MYHOME then
        return
    end

    self:initChuZiConditionAndResults(map)
end

function Dongzhi2018:initChuZiConditionAndResults(map)
    -- 活动时间开启时间
    if DEBUG_MODE == 1 or (GetTime() > Helper:getTimeStampWithStringDate("20210919", 0) and GetTime() < Helper:getTimeStampWithStringDate("20211003", 0)) then
    else
        return
    end

    if HomelandUtil:isRoomByTypeFromFlag("tsfangjian014") then
        local rooms = map:getRoomMap()

        for roomId, room in pairs(rooms) do
            if room.roomType == "tsfangjian014" then
                local roleList = room.roleList
                if not MapIsEmpty(roleList) then
                    for k, v in pairs(roleList) do
                        local npc = map:getRole(v)
                        if npc and npc.jobType == "chuzi001" then
                            CRFactory:createBtnCR(npc, "做月饼", "做月饼")
                            CRFactory:openOrCloseBtnFunc(npc, "做月饼", "open")
                            break
                        end
                    end
                end
                break
            end
        end
    end
end

return Dongzhi2018
00000000