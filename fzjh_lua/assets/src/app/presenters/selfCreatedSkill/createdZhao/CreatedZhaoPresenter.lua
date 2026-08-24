local inherit = require("third.inherit.inherit")
local ICreatedZhaoPresenterOutput = require("app.presenters.selfCreatedSkill.createdZhao.ICreatedZhaoPresenterOutput")
local ICreatedZhaoPresenterInput = require("app.presenters.selfCreatedSkill.createdZhao.ICreatedZhaoPresenterInput")
local ZhaoCreator = require("app.models.SelfCreatedSkillSystem.ZhaoCreator")

local isImplement = require("third.assertIsInstance.assertIsInstance")

local CreatedZhaoPresenter = {}

function CreatedZhaoPresenter:create(ICreatedZhaoOutput,selfCreatedSkillSystem,zhaoCreateResult,callback)
    local p = inherit({}, CreatedZhaoPresenter)
    p:init(ICreatedZhaoOutput,selfCreatedSkillSystem,zhaoCreateResult,callback)
    return p
end

function CreatedZhaoPresenter:init(ICreatedZhaoOutput,selfCreatedSkillSystem,zhaoCreateResult,callback)
    self._selfCreatedSkillSystem = selfCreatedSkillSystem
    self._callback = callback
    self._ICreatedZhaoOutput = isImplement(ICreatedZhaoOutput, ICreatedZhaoPresenterOutput)
    local skillCreator = self._selfCreatedSkillSystem:getSkillCreator()

    if zhaoCreateResult.ret == true then
        self._zhaoIndex = zhaoCreateResult.zhaoData.index
        self._zhaoCreator = skillCreator:getZhaoCreator(self._zhaoIndex)
        self._msg = zhaoCreateResult.msg
        
        self:createEditBox(self._zhaoIndex)
        self:setButtonCancel()
        self:setButtonOk()
        self:setRandomNameButton()
        -- self:createShowSucTextList()

        self._ICreatedZhaoOutput:playAnim(skillCreator:getSucAnim())
    else
        -- self:createShowdefTextList()
        self._ICreatedZhaoOutput:playAnim(skillCreator:getDefAnim())
    end
    self._ICreatedZhaoOutput:setButtonHide(false)
end

function CreatedZhaoPresenter:showLayer()
    self._ICreatedZhaoOutput:setShowLayer()
end

function CreatedZhaoPresenter:createEditBox(zhaoIndex)
    self._ICreatedZhaoOutput:createEditBox()

    local text = "第"..Helper:numberCast(zhaoIndex).."式"
    self._ICreatedZhaoOutput:setEditBoxText(text)
end

function CreatedZhaoPresenter:setButtonCancel()
    self._ICreatedZhaoOutput:setButtonCancel(function()
        Audio:playEffect("xiaoAnNiu")
        local params = {
            skillId = self._selfCreatedSkillSystem:getSelfCreatingSkill():getId(),
            zhaoIndex = self._zhaoCreator:getIndex(),
            name = "无名招式",
        }
        self._selfCreatedSkillSystem:setZhaoAttr(params,function()
            self._selfCreatedSkillSystem:setZhaoName(self._zhaoCreator,"无名招式")
            self._ICreatedZhaoOutput:richPrint(string.gsub(self._msg,"&name","无名招式"))
            self._ICreatedZhaoOutput:setPanelCreateZhaoNameIsVisible(false)
            self._ICreatedZhaoOutput:setAfterAnimCallback(function()
                self._ICreatedZhaoOutput:setButtonHide(true,function()
                    Audio:playEffect("xiaoAnNiu")
                    if self._callback then
                        self._callback()
                    end
                    self._ICreatedZhaoOutput:hideLayer()
                end)
            end)
            self:createNameLessTextList()
            self._ICreatedZhaoOutput:startRunAnim()
        end)
    end)
end

function CreatedZhaoPresenter:setButtonOk()
    self._ICreatedZhaoOutput:setButtonOk(function(editName)
        Audio:playEffect("xiaoAnNiu")
        if self:checkZhaoName(editName) then
            local params = {
                skillId = self._selfCreatedSkillSystem:getSelfCreatingSkill():getId(),
                zhaoIndex = self._zhaoCreator:getIndex(),
                name = editName,
            }
            self._selfCreatedSkillSystem:setZhaoAttr(params,function()
                self._selfCreatedSkillSystem:setZhaoName(self._zhaoCreator,editName)
                self._ICreatedZhaoOutput:richPrint(string.gsub(self._msg,"&name",editName))
                self._ICreatedZhaoOutput:setPanelCreateZhaoNameIsVisible(false)
                self._ICreatedZhaoOutput:setAfterAnimCallback(function()
                    self._ICreatedZhaoOutput:setButtonHide(true,function()
                        Audio:playEffect("xiaoAnNiu")
                        if self._callback then
                            self._callback()
                        end
                        self._ICreatedZhaoOutput:hideLayer()
                    end)
                end)
                self:createNameTextList(editName)
                self._ICreatedZhaoOutput:startRunAnim()
            end)
        end
    end)
end

function CreatedZhaoPresenter:setRandomNameButton()
    self._ICreatedZhaoOutput:setRandomNameButton(function()
        return self._zhaoCreator:createRandomName()
    end)
end

-- function CreatedZhaoPresenter:createShowSucTextList()
    -- local text = "你缓缓闭上双眼，|凝神聚意，|心中默念曾经习得的招式名称，|脑海里浮现出每个招式的身形动作，|猛然间你似有所得……"
    -- self._ICreatedZhaoOutput:createShowTextList(text,{},nil,nil)
-- end

-- function CreatedZhaoPresenter:createShowdefTextList()
    -- local text = "你眉头紧锁，|在纸上写写画画，|将所学招式一一在纸上排列，|试图找出其中的规律与奥妙，|但许久后你仍是一无所获。"
--     self._ICreatedZhaoOutput:createShowTextList(text,{},nil,nil)
-- end

function CreatedZhaoPresenter:createNameTextList(name)
    local text =  "你急匆匆在纷乱的纸叠上写下一套招式，|决定起名为「"..name.."」，|你望向纸上所写，|将纸上的招数尝试了好几遍，|脸上露出疲惫而欣喜的笑容。"
    local config = {
        color = cc.c3b(147, 130, 96),
        fontColor = cc.c4b(26, 26, 26, 255),
        font = "Font/default.ttf",
        fontSize = 46,
        speedRate = 0.5
    }
    self._ICreatedZhaoOutput:createShowTextList(text,config,1220,500)
end

function CreatedZhaoPresenter:createNameLessTextList()
    local config = {
        color = cc.c3b(147, 130, 96),
        fontColor = cc.c4b(26, 26, 26, 255),
        font = "Font/default.ttf",
        fontSize = 46,
        speedRate = 0.5
    }
    local text =  "你急匆匆在纷乱的纸叠上写下一套招式，|决定暂不为招式起名，|你望向纸上所写，|将纸上的招数尝试了好几遍，|脸上露出疲惫而欣喜的笑容。"
    self._ICreatedZhaoOutput:createShowTextList(text,config,1220,500)
end

function CreatedZhaoPresenter:checkZhaoName(name)
    if name == nil or name == "" then
        self._ICreatedZhaoOutput:popText("名字不能为空!!!")
        return false
    end

    if not Helper:isChinese(name) then
        self._ICreatedZhaoOutput:popText("名字必须是中文!!!")
        return false
    end

    -- 一个 utf－8的中文字，占3个字节
    if string.len(name) > 5 * 3 then		
        self._ICreatedZhaoOutput:popText("名字最多五个字")
        return false
    end

    if Helper:isMaskOff(name)  then
        -- self._ICreatedZhaoOutput:popText("名字包含不合法字符!")
        self._ICreatedZhaoOutput:popText(tostring(name) .. " 是非法词汇，请更换后再试。")
        return false
    else
        return true
    end
end

isImplement(CreatedZhaoPresenter, ICreatedZhaoPresenterInput)
return CreatedZhaoPresenter
0000