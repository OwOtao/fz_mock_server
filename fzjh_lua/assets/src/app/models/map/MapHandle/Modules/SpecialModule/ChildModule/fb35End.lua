--@SuperType [src.app.models.map.MapHandle.Modules.BaseModule#BaseModule]
local fb35End = class("fb35End", require("app.models.map.MapHandle.Modules.BaseModule"))

--@desc 涉及副本ID ：格式{["id"] = true} 默认为nil，无限制
fb35End.mapId = {["fb35"] = true}

--@desc 条件结果的方法
fb35End.doResult = {
    ["第35章大结局"] = function(map, result, environment)
        print("==========第三十五章大结局============")
        --PopText("==========第三十五章大结局============")
        PopupLayerController:showLayer(
            "WordsShowingLayer",
            function(layer)
                layer:reinit()
                layer:setResultCallback(
                    function()
                        map:setFlag("童姥结局", 1)
                    end
                )
                layer:show()
            end
        )
    end
}

return fb35End
0