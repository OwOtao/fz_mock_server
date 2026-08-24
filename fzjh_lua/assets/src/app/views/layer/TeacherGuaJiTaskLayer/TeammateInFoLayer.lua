local TeammateInFoLayer = class("TeammateInFoLayer", cc.Layer)
local HomelandRoleUtil = require("app.models.HomelandModel.HomelandRoleUtil")
local FamilyGroup = require("app.models.family.FamilyGroup")

function TeammateInFoLayer:create()
    local p = TeammateInFoLayer:new()
    p:init()
    return p
end

function TeammateInFoLayer:init()
    self._UI = require("Layer/TeacherTask/TeacherGuaJiTask/TeammateUI.lua").create()['root']
    self._UI:addTo(self)

    Helper:convertUI(self) -- 获得所有子节点

    self:initRichText()

    self.Panel_back:releaseFunc(function()
        PopupLayerController:hideLayer("TeammateInFoLayer", function()
            self:hide(true)
        end)
    end)

    self:hide() -- 隐藏自身
end

function TeammateInFoLayer:initRichText()
    if self.RichText_print then
        self.RichText_print:removeFromParent()
    end

    local x, y = self.Panel_dscArea:getPosition()
    local size = self.Panel_dscArea:getContentSize()

    self.RichText_print = ExtRichTextScroll:create()
    self.RichText_print:setAnchorPoint( 0.5 , 0.5 )
    self.Panel_dscArea:getParent():addChild(self.RichText_print)
    self.RichText_print:move(cc.p(x, y))
    self.RichText_print:setSize(size)
    self.RichText_print:setDirection(kCCScrollViewDirectionVertical)
    self.RichText_print:getRichText():setVerticalSpace(10)
end

function TeammateInFoLayer:pushRoleDsc(dsc)
    self:initRichText()

    local textColor = cc.c3b(208, 208, 208)

    self.RichText_print:pushBackText(dsc, textColor, 255, Resource:getFontPath("default"), 42)
end

--人物详细资料界面
function TeammateInFoLayer:setRoleInfo(data)
    self:reset()

    if data.job and data.job == "menke001" then
        data = table.mergeMap(data, HomelandRoleUtil:getMobanRoleAttr(data.modal))
        Npc:initNpc(data)
        Npc:initItemsAndEquips(data)
    end

    local role = self:setRoleFromData(data)
    
    self.Text_title:setString(role.name)
    self.Text_title:setTextHorizontalAlignment(0)

    local dsc = self:getRoleDsc(role)
    self:pushRoleDsc(dsc)
   
    --头像
    self.Image_di:setVisible(true)
    self.Image_frame:setVisible(true)
    self.Image_head:setVisible(true)
    local present = require("app.presenters.HeadView.HVPPresent"):create(self.Image_head,self.Image_di,data)
    present:showAnim()
    present:playEffect()

    self.Image_back:setVisible(true)

    local imagePath = role:getFaceInfoFrame()
    self.Image_back:loadTexture(imagePath)

    -- 设置图片大小
    local texture = cc.TextureCache:getInstance():getTextureForKey(imagePath);
    self.Image_back:setSize(texture:getContentSize())

    imagePath = role:getFaceFrame()
    self.Image_frame:loadTexture(imagePath)

     -- 设置图片大小
    local texture = cc.TextureCache:getInstance():getTextureForKey(imagePath);
    self.Image_frame:setSize(texture:getContentSize())

end

--设置玩家资料属性
function TeammateInFoLayer:setRoleFromData(data)
    local role = Helper:tableCover(Role:create(), data)
    role:initMap()
    return role
end

--重置界面
function TeammateInFoLayer:reset()
    self.Text_title:setTextHorizontalAlignment(1)
    self.Image_di:setVisible(false)
    self.Image_frame:setVisible(false)
    self.Image_head:setVisible(false)
end

function TeammateInFoLayer:getRoleDsc(role)
    local dsc = ""
    if not role then
        return dsc
    end

    dsc = role:getRoleInfoDsc(role).."\n    \n"

    if role.job == "menke001" then
        dsc = dsc..role.name.."的忠诚度为"..role.defaultZhongCheng.."，"..HomelandRoleUtil:getGuanJiaFidelity(role.defaultZhongCheng).."。\n"
    else
        dsc = dsc..role.name.."与你的亲密度达到"..role.intimacy.."，".."你们现在是"..FamilyGroup:getIntimacyDescAndNext(role.intimacy).."。\n"
    end

    dsc = dsc..role.name.."的侠义正气为".. role:getAttr("zhengqi").."。\n"

    -- dsc = dsc..role.name.."的气血：".. role:getAttr("qi").."/"..role:getFinalAttr("qiMax").."\n"

    -- dsc = dsc..role.name.."的内力：".. role:getAttr("neili").."/"..role:getFinalAttr("neiliMax").."\n"

    return dsc
end

Helper:classDefNodeGetInstance(TeammateInFoLayer)

return TeammateInFoLayer
000