local class = require("third.class.NewClass")

local ChallengeMapRoleAttrPresenter = {}

function ChallengeMapRoleAttrPresenter:create()
    local p = ChallengeMapRoleAttrPresenter.new()
    return p
end

function ChallengeMapRoleAttrPresenter:setOutput(iRoleInfoView)
    self.__output = iRoleInfoView
end

function ChallengeMapRoleAttrPresenter:setInput(iRoleInfoModel)
    self.__input = iRoleInfoModel
end

function ChallengeMapRoleAttrPresenter:setRole(role)
    self.__input:setRole(role)
end

function ChallengeMapRoleAttrPresenter:showRoleAttrPanel()
    local attr1,attr1Name = math.floor(self.__input:getRoleAtk()),"【攻击力】"
    self.__output:setRoleAttrTextVisible(1,true)
    self.__output:setRoleAttrTextStr(1,attr1Name.." "..attr1)

    local attr2,attr2Name = math.floor(self.__input:getRoleDef()),"【防御力】"
    self.__output:setRoleAttrTextVisible(2,true)
    self.__output:setRoleAttrTextStr(2,attr2Name.." "..attr2)

    local attr3,attr3Name = math.floor(self.__input:getRolePowerDamage()),"【伤害力】"
    self.__output:setRoleAttrTextVisible(3,true)
    self.__output:setRoleAttrTextStr(3,attr3Name.." "..attr3)

    local attr4,attr4Name = math.floor(self.__input:getRoleFangHu()),"【防护力】"
    self.__output:setRoleAttrTextVisible(4,true)
    self.__output:setRoleAttrTextStr(4,attr4Name.." "..attr4)

    local attr5,attr5Name = math.floor(self.__input:getRoleDodge()),"【躲闪力】"
    self.__output:setRoleAttrTextVisible(5,true)
    self.__output:setRoleAttrTextStr(5,attr5Name.." "..attr5)

    local attr7,attr7Name = tostring(math.floor(self.__input:getRoleAttr("strCondSkill"))).."/"..tostring(math.floor(self.__input:getRoleAttr("str"))),"【臂力】"
    self.__output:setRoleAttrTextVisible(7,true)
    self.__output:setRoleAttrTextStr(7,attr7Name.." "..attr7)

    local attr8,attr8Name = tostring(math.floor(self.__input:getRoleAttr("conCondSkill"))).."/"..tostring(math.floor(self.__input:getRoleAttr("con"))),"【根骨】"
    self.__output:setRoleAttrTextVisible(8,true)
    self.__output:setRoleAttrTextStr(8,attr8Name.." "..attr8)

    local attr9,attr9Name = tostring(math.floor(self.__input:getRoleAttr("dexCondSkill"))).."/"..tostring(math.floor(self.__input:getRoleAttr("dex"))),"【身法】"
    self.__output:setRoleAttrTextVisible(9,true)
    self.__output:setRoleAttrTextStr(9,attr9Name.." "..attr9)

    local attr10,attr10Name = math.floor(self.__input:getRoleAttr("plusPoint")),"【加力值】"
    self.__output:setRoleAttrTextVisible(10,true)
    self.__output:setRoleAttrTextStr(10,attr10Name.." "..attr10)

    local attr11,attr11Name = math.floor(self.__input:getRoleAttr("zhengqi")),"【侠义正气】"
    self.__output:setRoleAttrTextVisible(11,true)
    self.__output:setRoleAttrTextStr(11,attr11Name.." "..attr11)
    
    local attr12,attr12Name = math.floor(self.__input:getRoleAttr("looks")),"【容貌值】"
    self.__output:setRoleAttrTextVisible(12,true)
    self.__output:setRoleAttrTextStr(12,attr12Name.." "..attr12)
end

return class("ChallengeMapRoleAttrPresenter", {}, ChallengeMapRoleAttrPresenter)
00