local NewClass = require("third.class.NewClass")
local AbstractUseItem = require("app.models.role.item.UseItem.AbstractRoleUseItem")
local Item = require("app.models.item.Item")

local RoleUseItem_JuHuaJiu = {}

function RoleUseItem_JuHuaJiu:__canUseItem()
    local item = self._item
    local itemId = item.id
    local role = self._role

    local attrName = itemOfAttr[itemId][1]
    local attrUseCondition = itemOfAttr[itemId][2]
    local attrRemoveNum = itemOfAttr[itemId][3]
    if role:getAttr(attrName) < attrUseCondition then
        role._iOutput:popText("先天" .. attrStr[attrName] .. "小于" .. tostring(attrUseCondition) .. "，无法洗髓易经")
        return false
    end

    return true
end

function RoleUseItem_JuHuaJiu:__doUseItem()
    local item = Item:getOneItemByKey(self._item.id .. "_da")
    local role = self._role

    local function RichPrint(__, str)
        role._iOutput:richPrint(str)
    end

    if item ~= nil and item.itemList ~= nil then
        role._iOutput:showDrinkConfirm()

        local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")
        local dialog = DialogALayer:getInstance()
        dialog:show("面对醇香的菊花酒，你决定")
        dialog:setButton1(
            "小口抿",
            function()
                RichPrint("main", "你将酒倒入杯中并抿了一小口。")

                role:setFlag("奖励翻倍", 1)
                self:itemUseDescShow(
                    function()
                        local item = Item:getOneItemByKey(self.id .. "_xiao")
                        if item ~= nil then
                            -- 物品使用后获取物品列表
                            item:getItemAfterUse()
                        end
                        if func then
                            func()
                        end
                    end,
                    nil,
                    nil,
                    role
                )
            end
        )

        dialog:setButton2(
            "大口喝",
            function()
                RichPrint("main", "你开始抱着酒坛大口大口地喝酒。")
                --  一定概率全部消耗完
                if math.random(1, 10) > 1 then
                    role:setFlag("奖励翻倍", 3)
                    self:itemUseDescShow(
                        function()
                            local item = Item:getOneItemByKey(self.id .. "_da")
                            if item ~= nil then
                                -- 物品使用后获取物品列表
                                item:getItemAfterUse()
                            end
                            if func then
                                func()
                            end
                        end,
                        nil,
                        nil,
                        role
                    )
                else
                    -- 一口喝光，什么都不加
                    role:addItemCount(self.id, -1)
                    role:setFlag("奖励翻倍", 1)
                    RichPrint("main", "你喝了一口酒，感觉酒香醇厚，真乃美酒佳酿，干脆抱起酒坛一饮而尽，不想这酒后劲甚足，不一会你便呼呼大睡不省人事了，醒来一瞧整整一坛酒已经空空如也了。")
                    if func then
                        func()
                    end
                end
            end
        )
    else
        role:setFlag("奖励翻倍", 1)
        self:itemUseDescShow(
            function()
                local item = Item:getOneItemByKey(self.id .. "_xiao")
                if item ~= nil then
                    -- 物品使用后获取物品列表
                    item:getItemAfterUse()
                end
                if func then
                    func()
                end
            end,
            nil,
            nil,
            role
        )
    end

    return true
end

return NewClass("RoleUseItem_JuHuaJiu", {AbstractUseItem}, RoleUseItem_JuHuaJiu)
0000000