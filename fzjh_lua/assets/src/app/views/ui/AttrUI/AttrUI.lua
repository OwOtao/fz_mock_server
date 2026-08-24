local DialogELayer = require("app.views.layer.DialogLayer.DialogELayer")

local AttrUI = class("AttrUI", cc.Layer)

function AttrUI:create(resPath)
    local p = AttrUI:new()
    p:init(resPath)
    return p
end

function AttrUI:init()
    self._round = require("Layer/AttrUI/AttrUI.lua").create()["root"]
    self._round:addTo(self)

    Helper:convertUIByParent(self) -- 获得所有子节点
    self.Text_neili_jin:setVisible(false)
    self.Button_neidan:setVisible(false)
    self:initPanelHelp()
end

function AttrUI:updateSkin(skin_config)
    if skin_config.Rolebtnpic then
        self.Button_attrPoint:loadTextureNormal(skin_config.Rolebtnpic, 0)
        self.Button_inherit:loadTextureNormal(skin_config.Rolebtnpic, 0)
        self.Button_neidan:loadTextureNormal(skin_config.Rolebtnpic, 0)
        self.Button_jiali:loadTextureNormal(skin_config.Rolebtnpic, 0)
        self.Button_dazuo:loadTextureNormal(skin_config.Rolebtnpic, 0)
    end
end

function AttrUI:buttonJinShow()
    local self = self.Text_neili_jin
    self:setVisible(true)
    local actionTag = self:getActionTagByName("move")
    self:stopActionByTag(actionTag)
    local action =
        cc.Sequence:create(
        cc.Spawn:create(cc.ScaleTo:create(0.25, 1.1), cc.FadeIn:create(0.25)),
        cc.CallFunc:create(
            function()
                -- self:show()
            end
        )
    )
    action:setTag(actionTag)
    self:runAction(action)
end

function AttrUI:buttonJinHide()
    local self = self.Text_neili_jin
    local actionTag = self:getActionTagByName("move")
    self:stopActionByTag(actionTag)
    self:setScale(1.1)
    local action =
        cc.Sequence:create(
        cc.Spawn:create(cc.ScaleTo:create(0.25, 1.2), cc.FadeOut:create(0.25)),
        cc.CallFunc:create(
            function()
                self:setScale(1.0)
            end
        )
    )
    action:setTag(actionTag)
    self:runAction(action)
end

function AttrUI:setButtonDaZuo(func)
    self.Button_dazuo:releaseFunc(func)
end

function AttrUI:setButtonJiaLi(func)
    self.Button_jiali:releaseFunc(func)
end

function AttrUI:setButtonNeiDan(func)
    self.Button_neidan:releaseFunc(func)
end

function AttrUI:setButtonChangeTitle(func)
    self.Button_title:releaseFunc(func)
end

function AttrUI:setButtonInherit(func)
    self.Button_inherit:releaseFunc(func)
end

function AttrUI:setMySkillsButton(func)
    self.Button_attrPoint:releaseFunc(func)
end

function AttrUI:setTextNameTitle(title)
    self.Text_nameTitle:setColor(cc.c3b(208, 208, 208)) --默认白色
    self.Text_nameTitle:setString(title)
end

function AttrUI:setTextName(name)
    name = tostring(name)
    local role = User:getRole()
    local touxian = role:getTouXian()
    if string.len(touxian) >= 1 then
        name = touxian
    end
    name = name .. role:getName()
    self.Text_name:setString(name)
end

function AttrUI:setTextJing(curr, max)
    curr, max = tostring(curr), tostring(max)
    self.Text_jing:setString("『精力』" .. curr .. "/" .. max)
end

function AttrUI:setTextQi(curr, max, percent)
    curr, max = Helper:getDef(curr, User:getRoleAttr("qi")), Helper:getDef(max, User:getRole():getCurrQiMax())
    if not percent then
        percent = 1
    end
    self.Text_qi:setString("『气血』" .. curr .. "/" .. Helper:mathFloor(max) .. " (" .. tostring(math.floor(percent * 100)) .. "%)")
end

function AttrUI:setTextNeili(curr, max)
    self:setTextNeiliNum(curr, max)
end

function AttrUI:setTextNeiliNum(curr, max)
    curr, max = tostring(curr), tostring(max)
    self.Text_neili_num:setString(curr .. "/" .. max)
end

function AttrUI:setTextNeiliJin(curr, max)
    curr, max = tostring(curr), tostring(max)
    self.Text_neili_jin:setString("『内力』" .. curr .. "/" .. max)
end

function AttrUI:setTextExp(exp)
    exp = tostring(exp)
    self.Text_exp:setString("『经验』" .. exp)
end

function AttrUI:setTextPot(pot)
    pot = tostring(pot)
    self.Text_pot:setString("『潜能』" .. pot)
end

function AttrUI:setTextLv(lv)
    lv = tostring(lv)
    self.Text_lv:setString("『等级』" .. lv)
end

function AttrUI:setTextMoney(money)
    money = tostring(money)
    self.Text_money:setString("『金钱』" .. money)
end

function AttrUI:setTextSex(sex)
    sex = tostring(sex)
    self.Text_sex:setString("『性别』" .. sex)
end

function AttrUI:setTextAge(age)
    age = tostring(age)
    self.Text_age:setString("『年龄』" .. age)
end

function AttrUI:setTextSpouse(spouse)
    spouse = tostring(spouse)
    self.Text_spouse:setString("『缘分』" .. spouse)
end

function AttrUI:setTextMaster(master)
    if not master then
        master = "无"
    end
    self.Text_master:setString("『师父』" .. master)
end

function AttrUI:setTextStr(secStr, str)
    if not str or type(str) ~= "number" then
        str = 0
    end
    if not secStr or type(secStr) ~= "number" then
        secStr = 0
    end
    self.Text_str:setString("【臂力】" .. tostring(secStr + str) .. "/" .. str)
end

function AttrUI:setTextDex(secDex, dex)
    if not dex or type(dex) ~= "number" then
        dex = 0
    end
    if not secDex or type(secDex) ~= "number" then
        secDex = 0
    end
    self.Text_dex:setString("【身法】" .. tostring(secDex + dex) .. "/" .. dex)
end

function AttrUI:setTextInt(secInt, int)
    if not int or type(int) ~= "number" then
        int = 0
    end
    if not secInt or type(secInt) ~= "number" then
        secInt = 0
    end
    self.Text_int:setString("【悟性】" .. tostring(secInt + int) .. "/" .. int)
end

function AttrUI:setTextCon(secCon, con)
    if not con or type(con) ~= "number" then
        con = 0
    end
    if not secCon or type(secCon) ~= "number" then
        secCon = 0
    end
    self.Text_con:setString("【根骨】" .. tostring(secCon + con) .. "/" .. con)
end

function AttrUI:setTextLooks(looks)
    looks = tostring(looks)
    self.Text_looks:setString("【容貌】" .. looks)
end

function AttrUI:setTextLuck(luck)
    luck = tostring(luck)
    self.Text_luck:setString("【福缘】" .. luck)
end

function AttrUI:setTextChengzhang()
    self.Text_chengzhang:setVisible(false)
end

function AttrUI:setHeadAreaClickFunc(func)
    self.Button_head:releaseFunc(
        function()
            func()
        end
    )
end

function AttrUI:setPanelClick(panelName, str)
    local panel = self[panelName]
    if not panel then
        return
    end

    local dialog = DialogELayer:getInstance()
    panel:addTouchEventListener(
        function(ref, eventType)
            if eventType == ccui.TouchEventType.began then
                panel.Image_7:setVisible(false)
            elseif eventType == ccui.TouchEventType.ended then
                -- 内力窗口
                local desc = clone(str)
                if panelName == "Panel_9" and str ~= nil then
                    desc = desc .. "\n" .. "你能达到最大的内力上限:" .. tostring(Helper:mathFloor(User:getRole():getNeiLiLimit()))
                end
                dialog:show(desc)
                dialog:setPanelBack(
                    function()
                        panel.Image_7:setVisible(true)
                    end
                )
            elseif eventType == ccui.TouchEventType.canceled then
                panel.Image_7:setVisible(true)
            end
        end
    )
end

local list = {
    {
        name = "Panel_7",
        str = "精力用来练功，任务等日常活动。\n通过修炼门派心法可以长精。\n年龄越大，精力越长。"
    },
    {
        name = "Panel_8",
        str = "气血是人体的健康值。\n气血值=0，角色就会死亡。\n战斗中被打伤，气血上限值会降低。上限值的恢复较慢，吃药和内功疗伤可以加快上限恢复。\n用内力可以恢复气血状态。\n内力越深厚，气血越长。\n年龄越大，气血越长。"
    },
    {
        name = "Panel_9",
        str = "内力是内功赋予的特殊能量，有许多用途。\n通过打坐可以修炼内力上限，也可以快速回复内力。\n加力是玩家每次出招所附带的内力值。\n加力越大，伤害越高，当然内力消耗也就更快。"
    },
    {
        name = "Panel_10",
        str = "身法影响你的防御及躲避能力。身法越好，便越容易避开对手的攻击。\n学习基本轻功可以增加身法。"
    },
    {
        name = "Panel_11",
        str = "根骨越高，气血恢复速度越快。精力和气血增长的也更快。战斗时受的伤也越轻。\n学习基本内功可以增加根骨。"
    },
    {
        name = "Panel_12",
        str = "悟性是你的学习能力。读书，请教，领悟武功，闭关修炼。这些都会受到悟性的影响。\n学习读书识字可以增加悟性。"
    },
    {
        name = "Panel_13",
        str = "臂力主要影响你进攻时的杀伤力，不论是空手还是持械，臂力越大，伤害越高。\n学习基本拳脚可以增加臂力。"
    }
}
function AttrUI:initPanelHelp()
    for i, v in ipairs(list) do
        self:setPanelClick(v.name, v.str)
    end
end

function AttrUI:disablePanelClick()
    for i, v in ipairs(list) do
        local panel = self[v.name]
        if panel then
            panel:setTouchEnabled(false)
        end
    end
end

function AttrUI:getHeadNodePos()
    return self.Node_HeadViewPos:getPosition()
end

return AttrUI
0000000000000000