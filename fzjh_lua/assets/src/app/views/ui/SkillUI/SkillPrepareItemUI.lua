local SkillPrepareItemUI = {}

local Resource = require("app.Resource")

local SkillPrepareItemUI = {}

function SkillPrepareItemUI:create()
    local p = Resource:getUIByName("Panel_skillPrepareItemUI")
    Helper:tableCover(p, SkillPrepareItemUI)
    p:init()
    return p
end

function SkillPrepareItemUI:init()
    Helper:convertUI(self)
    self:setTouchEnabled(true) -- 设置为可触摸

    self.Text_name:enableOutline(cc.c4b(0, 0, 0, 255), 5)
    self.Text_selectSkill:enableOutline(cc.c4b(0, 0, 0, 255), 5)
    self.Text_stageDsc:enableOutline(cc.c4b(0, 0, 0, 255), 5)
    self.Text_lv:enableOutline(cc.c4b(0, 0, 0, 255), 5)
end

function SkillPrepareItemUI:setName(str)
    if str == "" then
        self.Image_nameBack:setVisible(false)
    else
        self.Image_nameBack:setVisible(true)
    end
    return self.Text_name:setString(str)
end

function SkillPrepareItemUI:setButtonText(str)
    return self.Text_selectSkill:setString(str)
end

local BTN_DEFAULT_TEXTURE = "Image/UI/SkillUI/02.png"
function SkillPrepareItemUI:loadButtonNormalTexture(texture)
    texture = (texture ~= nil and texture ~= "") and texture or BTN_DEFAULT_TEXTURE

    -- 如果文件不存在，则使用默认图片
    if not cc.FileUtils:getInstance():isFileExist(texture) then
        texture = BTN_DEFAULT_TEXTURE
    end

    self.Button_selectSkill:loadTextureNormal(texture, 0)
end

function SkillPrepareItemUI:setSkillStageDsc(str)
    return self.Text_stageDsc:setString(str)
end

function SkillPrepareItemUI:setSkillLv(lv)
    return self.Text_lv:setString(lv)
end

return SkillPrepareItemUI
000000000