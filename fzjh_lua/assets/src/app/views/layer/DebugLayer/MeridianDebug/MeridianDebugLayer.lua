local MeridianDebug = require("app.views.layer.DebugLayer.MeridianDebug.MeridianDebug")

local MeridianDebugLayer = {}

function MeridianDebugLayer:showui(layer, backFunc)
    self.__layer = layer
    self.__layer.ListView:removeAllItems()
    self:__init()

    self.__layer:addButton("返回", backFunc)
end

function MeridianDebugLayer:__init()
    self:__addButton(
        "从配置中重置成旧版本数据",
        function()
            local role = User:getRole()
            MeridianDebug:resetMerianImprintingsBefore20250121(role)

            PopText("重置成功")

            Game:restart()
        end
    )

    self:__addEditor(
        "（需重启）设置服务器记录天赋页解锁页数",
        "填写解锁页数(重启游戏生效)",
        function(editBox, text)
            local pageNum = tonumber(text)
            if type(pageNum) ~= "number" then
                PopText("请填写正确的数字")
                return
            end

            if pageNum < 1 then
                PopText("解锁页数不能小于1")
                return
            end

            HttpManagerEx:testSetMeridianPageNum(
                pageNum,
                function(status, errcode, errmsg, data)
                    if status == 200 and errcode == 0 then
                        PopText("设置成功")
                    else
                        PopText(errmsg)
                    end
                end,
                IS_SHOW_WAITING
            )
        end
    )

    self:__addButton(
        "解锁天赋页",
        function()
            local pageIndex = User:getRole():getMeridianSystem():unlockMeridianImprintingPage()

            if pageIndex == -1 then
                PopText("天赋页已满")
                return
            end


            HttpManagerEx:testSetMeridianPageNum(
                pageIndex,
                function(status, errcode, errmsg, data)
                    if status == 200 and errcode == 0 then
                        PopText("新增天赋页" .. pageIndex .. "成功")
                    else
                        PopText(errmsg)
                    end
                end,
                IS_SHOW_WAITING
            )
        end
    )

    self:__addButton(
        "经脉传承",
        function()
            local ImprintingInherit = require("app.models.Meridian.Inherit.ImprintingInherit"):create(User:getRole())

            if ImprintingInherit:needSelectMeridianImprintingForInherit() then
                PopupLayerController:showLayer(
                    "MeridianInheritPresenter",
                    function(presenter)
                        local ui = require("app.views.ui.Meridian.MeridianInheritUI"):create()
                        presenter:setInput(ImprintingInherit)
                        presenter:setUI(ui)
                        presenter:showPresenter()
                    end
                )
            else
                ImprintingInherit:initInheritDefaultSelectMeridianImprintingData()
                ImprintingInherit:inherit()
            end
        end
    )
end

function MeridianDebugLayer:__addButton(name, func)
    self.__layer:addButton(name, func)
end

function MeridianDebugLayer:__addEditor(name, placeholder, func)
    self.__layer:addEditor(name, placeholder, func)
end

return MeridianDebugLayer
00000000