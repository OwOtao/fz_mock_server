local MainUI = class("MainUI", cc.Layer)

function MainUI:create()
    local p = MainUI:new()
    p:init()
    return p
end

function MainUI:init()
    self._round = require("Layer/MainUI.lua").create()["root"]
    self._round:addTo(self)

    Helper:convertUI(self) -- 获得所有子节点

    self.Text_chengzhang:setVisible(false)
    self.Image_hongdian_shangcheng:setVisible(false)
    self.Image_hongdian_paihang:setVisible(false)
end

function MainUI:updateSkinUI(skinConfig)
    if skinConfig ~= nil then
        self.Button_task:ignoreContentAdaptWithSize(false)
        self.Button_jianghu:ignoreContentAdaptWithSize(false)
        self.Button_shimen:ignoreContentAdaptWithSize(false)

        self.Button_task:setScale9Enabled(true)
        self.Button_jianghu:setScale9Enabled(true)
        self.Button_shimen:setScale9Enabled(true)

        self.Button_task:setCapInsets({x = 253, y = 11, width = 22, height = 195})
        self.Button_jianghu:setCapInsets({x = 33, y = 11, width = 22, height = 12})
        self.Button_shimen:setCapInsets({x = 33, y = 11, width = 22, height = 12})

        local buttons = {
            task = skinConfig.MaskBtnPic,
            jianghu = skinConfig.StorybtnPic,
            shimen = skinConfig.StorybtnPic,
            selfCreatedSkill = skinConfig.SmallbtnPic,
            shangcheng = skinConfig.SmallbtnPic,
            paihang = skinConfig.SmallbtnPic,
            meridian = skinConfig.SmallbtnPic,
            dream = skinConfig.SmallbtnPic,
            shenbing = skinConfig.SmallbtnPic,
            quanJiao = skinConfig.SmallbtnPic
        }

        for k, v in pairs(buttons) do
            local btnNode = self["Button_" .. k]
            btnNode:loadTextureNormal(v, 0)
            local newSize = btnNode:getVirtualRenderer():getContentSize()
            btnNode:setContentSize(newSize)

            local txtNode = self["Button_" .. k .. "_name"]
            if txtNode then
                -- 重新设置文字控件位置到btnNode的中心点
                print(k, newSize.width / 2, newSize.height / 2)
                txtNode:setPositionX(newSize.width / 2)
                txtNode:setPositionY(newSize.height / 2)
            end

            local hongdianNode = self["Image_hongdian_" .. k]
            if hongdianNode then
                -- 重新设置红点位置到btnNode的右上角，x偏移73% ,y偏移90%
                hongdianNode:setPositionX(newSize.width * 0.80)
                hongdianNode:setPositionY(newSize.height * 0.9)
            end
        end

        self.Button_task:setSize({width = 968.0000, height = 217.0000})
        self.Button_jianghu:setSize({width = 450.0000, height = 162.0000})
        self.Button_shimen:setSize({width = 450.0000, height = 162.0000})
    end
end

function MainUI:updataSkinAnim(ft)
    if self.__animator then
        self.__animator:update(ft)
    end
end

function MainUI:setTextUserName(txt)
    self.Text_userName:setString(txt)
end

function MainUI:setTextName(txt)
    self.Text_name:setColor(cc.c3b(208, 208, 208)) --默认颜色
    self.Text_name:setString(txt)
end

function MainUI:setTextJing(curr, max)
    curr, max = tostring(Helper:mathFloor(curr)), tostring(Helper:mathFloor(max))
    self.Text_jing:setString("『精力』" .. curr .. "/" .. max)
end

function MainUI:setTextQi(curr, max, percent)
    curr, max = Helper:getDef(curr, User:getRoleAttr("qi")), Helper:getDef(max, User:getRole():getCurrQiMax())
    if not percent then
        percent = 1
    end
    self.Text_qi:setString("『气血』" .. curr .. "/" .. Helper:mathFloor(max) .. " (" .. tostring(math.floor(percent * 100)) .. "%)")
end

function MainUI:setTextNeili(str)
    self.Text_neili:setString(str)
end

function MainUI:setTextExp(exp)
    exp = tostring(exp)
    self.Text_exp:setString("『经验』" .. exp)
end

function MainUI:setTextPot(pot)
    pot = tostring(pot)
    self.Text_pot:setString("『潜能』" .. pot)
end

function MainUI:setTextLv(lv)
    lv = tostring(lv)
    self.Text_lv:setString("『等级』" .. lv)
end

function MainUI:setTextMoney(money)
    money = tostring(money)
    self.Text_money:setString("『金钱』" .. money)
end

function MainUI:setTextChengzhang(var)
    var = tostring(var)
    self.Text_chengzhang:setString("『成长』" .. var .. "/小时")
end

function MainUI:getUINode(name)
    return self[name]
end

return MainUI
0000000000