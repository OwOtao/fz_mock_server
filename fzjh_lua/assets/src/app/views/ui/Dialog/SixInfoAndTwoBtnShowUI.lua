local SixInfoAndTwoBtnShowUI = class("SixInfoAndTwoBtnShowUI", cc.Layer)

function SixInfoAndTwoBtnShowUI:create()
    local p = SixInfoAndTwoBtnShowUI:new()
    p:__init()
    return p
end

function SixInfoAndTwoBtnShowUI:__init()
    self._round = require("Layer.Dialog.SixInfoAndTwoBtnShowUI").create()["root"]
    self._round:addTo(self)

    Helper:convertUIByParent(self) -- 获得所有子节点
end

function SixInfoAndTwoBtnShowUI:setPnlBackgroundFunc(func)
    self.Pnl_Background:releaseFunc(func)
end

function SixInfoAndTwoBtnShowUI:setTextVisible1(bool)
    self.Pnl_Text1:setVisible(bool)
end

function SixInfoAndTwoBtnShowUI:setTextInfo1(key, value)
    self.Pnl_Text1.Txt_Key:setTextColor({r = 255, g = 255, b = 255})
    self.Pnl_Text1.Txt_Value:setTextColor({r = 255, g = 255, b = 255})
    self.Pnl_Text1.Txt_Key:setString(key)
    self.Pnl_Text1.Txt_Value:setString(value)
end

function SixInfoAndTwoBtnShowUI:setTextVisible1(bool)
    self.Pnl_Text1:setVisible(bool)
end

function SixInfoAndTwoBtnShowUI:setTextInfo2(key, value)
    self.Pnl_Text2.Txt_Key:setTextColor({r = 255, g = 255, b = 255})
    self.Pnl_Text2.Txt_Value:setTextColor({r = 255, g = 255, b = 255})
    self.Pnl_Text2.Txt_Key:setString(key)
    self.Pnl_Text2.Txt_Value:setString(value)
end

function SixInfoAndTwoBtnShowUI:setTextVisible2(bool)
    self.Pnl_Text2:setVisible(bool)
end

function SixInfoAndTwoBtnShowUI:setTextInfo3(key, value)
    self.Pnl_Text3.Txt_Key:setTextColor({r = 255, g = 255, b = 255})
    self.Pnl_Text3.Txt_Value:setTextColor({r = 255, g = 255, b = 255})
    self.Pnl_Text3.Txt_Key:setString(key)
    self.Pnl_Text3.Txt_Value:setString(value)
end

function SixInfoAndTwoBtnShowUI:setTextVisible3(bool)
    self.Pnl_Text3:setVisible(bool)
end

function SixInfoAndTwoBtnShowUI:setTextInfo4(key, value)
    self.Pnl_Text4.Txt_Key:setTextColor({r = 255, g = 255, b = 255})
    self.Pnl_Text4.Txt_Value:setTextColor({r = 255, g = 255, b = 255})

    self.Pnl_Text4.Txt_Key:setString(key)
    self.Pnl_Text4.Txt_Value:setString(value)
end

function SixInfoAndTwoBtnShowUI:setTextVisible4(bool)
    self.Pnl_Text4:setVisible(bool)
end

function SixInfoAndTwoBtnShowUI:setTextVisible5(bool)
    self.Pnl_Text5:setVisible(bool)
end

function SixInfoAndTwoBtnShowUI:setTextInfo5(key, value)
    self.Pnl_Text5.Txt_Key:setTextColor({r = 255, g = 255, b = 255})
    self.Pnl_Text5.Txt_Value:setTextColor({r = 255, g = 255, b = 255})

    self.Pnl_Text5.Txt_Key:setString(key)
    self.Pnl_Text5.Txt_Value:setString(value)
end

function SixInfoAndTwoBtnShowUI:setTextVisible6(bool)
    self.Pnl_Text6:setVisible(bool)
end

function SixInfoAndTwoBtnShowUI:setTextInfo6(key, value)
    self.Pnl_Text6.Txt_Key:setTextColor({r = 255, g = 255, b = 255})
    self.Pnl_Text6.Txt_Value:setTextColor({r = 255, g = 255, b = 255})

    self.Pnl_Text6.Txt_Key:setString(key)
    self.Pnl_Text6.Txt_Value:setString(value)
end

function SixInfoAndTwoBtnShowUI:setButtonUpVisible(bool)
    self.Btn_Up:setVisible(bool)
end

function SixInfoAndTwoBtnShowUI:setButtonUpFunction(name, func)
    self.Btn_Up.Txt_Name:setString(name)
    self.Btn_Up:releaseFunc(func)
end

function SixInfoAndTwoBtnShowUI:setButtonBottomVisible(bool)
    self.Btn_Bottom:setVisible(bool)
end

function SixInfoAndTwoBtnShowUI:setButtonBottomFunction(name, func)
    self.Btn_Bottom.Txt_Name:setString(name)
    self.Btn_Bottom:releaseFunc(func)
end
return SixInfoAndTwoBtnShowUI
000000000