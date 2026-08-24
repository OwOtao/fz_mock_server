local WXShare = {
    __title = "良心独立游戏佳作——画面简约内容丰富，高自由度的武侠世界，轻松的放置玩法以及代入感极高的探索解谜。没时间解释了，拔剑吧，骚年！",
    __text = "没时间解释了，快拔剑吧！"
}

function WXShare:initTitleAndText(title, text)
    self.__text = text
    self.__title = title
end

function WXShare:doShare(callBack)
    if device.platform == "windows" then
        print("平台不能分享")
        return
    end
    
    local WaitingLayer = require("app.views.layer.PopLayer.WaitingLayer")
    local waitingLayer = WaitingLayer:createInRunningScene()
    waitingLayer:setText("请稍后...")

    SdkMethod:WeiXin_setAboutLink(Game:getFenXiangURL(), self.__title, self.__text)
    
    SdkMethod:WeiXin_SetCallback(function(eventName)
        if eventName == "成功" then
            HttpManagerEx:getReward(2, function(status, errcode, errmsg, data,isEncrypted)
                if status == 200 and errcode == 0 then
                    if not data.add_yuanbao or not data.total_yuanbao then
                        PopText("请稍后查看")
                    elseif not data.add_yuanbao then
                        PopText("成功获取元宝")
                        User:getRole():setAttr("yuanbao", data.total_yuanbao)
                    elseif not data.total_yuanbao then
                        PopText("成功获取元宝, 元宝 + "..tostring(data.add_yuanbao))
                    else
                        PopText("成功获取元宝, 元宝 + "..tostring(data.add_yuanbao))
                        User:getRole():setAttr("yuanbao", data.total_yuanbao)
                    end

                    if callBack then
                        callBack()
                    end
                else
                    PopText(errmsg)
                end

                waitingLayer:hideAndRemoveSelf()
            end)
        else
            waitingLayer:hideAndRemoveSelf()
        end
    end)

    SdkMethod:shareToWeixinFriends()
end

return WXShare0000000000