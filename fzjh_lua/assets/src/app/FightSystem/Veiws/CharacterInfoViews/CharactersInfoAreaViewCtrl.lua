--[[
    author:Seven
    time:2023-10-19 16:02:36
    desc: 角色信息区域管理类
]]
local newClass = require("third.class.NewClass")

local FightCommons = require("app.FightSystem.FightCommons")

local PlayerInfoViewUI = require("app.FightSystem.Veiws.CharacterInfoViews.UI.PlayerInfoViewUI")
local PlayerTargetInfoViewUI = require("app.FightSystem.Veiws.CharacterInfoViews.UI.PlayerTargetInfoViewUI")
local TeammateInfoViewUI = require("app.FightSystem.Veiws.CharacterInfoViews.UI.TeammateInfoViewUI")
local CharacterInfoAreaViewUI = require("app.FightSystem.Veiws.CharacterInfoViews.UI.CharacterInfoAreaViewUI")

local CharactersInfoAreaViewCtrl = {}

function CharactersInfoAreaViewCtrl:create(mainView)
    return CharactersInfoAreaViewCtrl.new():__init(mainView)
end

function CharactersInfoAreaViewCtrl:ctor()
    self.__viewModelMap = {}
    self.__leftInfoUIs = {}
    self.__rightInfoUIs = {}
end

local cloneItemNode = function(node)
    local cloneNode = node:clone()
    Helper:convertUIByParent(cloneNode)
    return cloneNode
end

function CharactersInfoAreaViewCtrl:__init(mianView)
    --@RefType [FightMainView]
    self.__mainView = mianView

    --@RefType [src.app.FightSystem.Veiws.CharacterInfoViews.UI.CharacterInfoAreaViewUI#CharacterInfoAreaViewUI]
    self.__UI = require("app.FightSystem.Veiws.CharacterInfoViews.UI.CharacterInfoAreaViewUI"):create(self.__mainView:getUINode("RolesInfoArea"))
    self.__UI:setMainView(self.__mainView)

    self.__UI:setLeftListVisible(false)
    self.__UI:setRightListVisible(false)

    self.__uiBindMap = {}

    for i = 1, FightCommons.TEAMMATE_COUNT do
        if i == 1 then
            local lUI = PlayerInfoViewUI:create(cloneItemNode(self.__mainView:getUINode("RoleInfoPanel_L")))
            lUI:setMainView(self.__mainView)
            self.__UI:insertCustomItemToLeft(i, lUI:getNode())
            self:__initLeftAttrBuffIcon(lUI)
            table.insert(self.__leftInfoUIs, lUI)

            local rUI = PlayerTargetInfoViewUI:create(cloneItemNode(self.__mainView:getUINode("RoleInfoPanel_R")))
            rUI:setMainView(self.__mainView)
            self.__UI:insertCustomItemToRight(i, rUI:getNode())
            self:__initRightAttrBuffIcon(rUI)
            table.insert(self.__rightInfoUIs, rUI)
        else
            local lUI = TeammateInfoViewUI:create(cloneItemNode(self.__mainView:getUINode("TeamRoleInfoPanel_L")))
            lUI:setMainView(self.__mainView)
            self.__UI:insertCustomItemToLeft(i, lUI:getNode())
            self:__initLeftAttrBuffIcon(lUI)
            table.insert(self.__leftInfoUIs, lUI)

            local rUI = TeammateInfoViewUI:create(cloneItemNode(self.__mainView:getUINode("TeamRoleInfoPanel_R")))
            rUI:setMainView(self.__mainView)
            self.__UI:insertCustomItemToRight(i, rUI:getNode())
            self:__initRightAttrBuffIcon(rUI)
            table.insert(self.__rightInfoUIs, rUI)
        end
    end

    self:__initLeftListViewPosition()
    self:__initRightListViewPosition()

    return self
end

function CharactersInfoAreaViewCtrl:__initRightListViewPosition()
    local rightListView = self.__UI:getRightListViewNode()
    local position = cc.p(rightListView:getPosition())
    local size = rightListView:getSize()
    rightListView:setPositionX(position.x + size.width)
end

function CharactersInfoAreaViewCtrl:__initLeftListViewPosition()
    local leftListView = self.__UI:getLeftListViewNode()
    local position = cc.p(leftListView:getPosition())
    local size = leftListView:getSize()
    leftListView:setPositionX(position.x - size.width)
end

function CharactersInfoAreaViewCtrl:getListViewUINode(dir)
    if dir == "left" then
        return self.__UI:getLeftListViewNode()
    elseif dir == "right" then
        return self.__UI:getRightListViewNode()
    else
        error("CharactersInfoAreaViewCtrl:getListViewUINode(dir) dir is error ： " .. tostring(dir))
    end
end

--@desc: 战斗开始前初始化接口
--@author:Seven
--@time:2023-10-21 11:45:15
function CharactersInfoAreaViewCtrl:startFightInit()
end

--@desc: 初始化信息buffui图标
--@author:Seven
--@time:2023-10-19 16:56:53
--@ui: [src.app.FightSystem.Veiws.CharacterInfoViews.UI.PlayerInfoViewUI#PlayerInfoViewUI]
function CharactersInfoAreaViewCtrl:__initLeftAttrBuffIcon(ui)
    local iconNode = self.__mainView:getUINode("ImgIcon")

    local bigIconNode = self.__mainView:getUINode("ImgIconBig")

    for j = 1, FightCommons.BUFFICON_MAXCOUNT do
        local buffIcon = cloneItemNode(iconNode)

        local buffIconPosX = 35.08 + (j - 1) * 59.96

        buffIcon:setPosition(cc.p(buffIconPosX, 31.05))

        buffIcon:setVisible(true)

        ui:addBuffIcon(buffIcon, j)
    end

    for i = 0, FightCommons.ALL_BUFFICON_MAXCOUNT - 1 do
        local buffIcon = cloneItemNode(bigIconNode)

        local x = math.fmod(i, 6) + 1

        local y = math.modf(i / 6) + 1

        local buffIconPosX = 65.62 + (x - 1) * 76.45

        local buffIconPosY = 391.08 - (y - 1) * 83.83

        buffIcon:setPosition(cc.p(buffIconPosX, buffIconPosY))

        buffIcon:setVisible(true)

        ui:addBuffBigIcon(buffIcon, i + 1)
    end
end

--@desc: 初始化信息buffui图标
--@author:Seven
--@time:2023-10-19 16:56:53
--@ui: [src.app.FightSystem.Veiws.CharacterInfoViews.UI.PlayerInfoViewUI#PlayerInfoViewUI]
function CharactersInfoAreaViewCtrl:__initRightAttrBuffIcon(ui)
    local iconNode = self.__mainView:getUINode("ImgIcon")

    local bigIconNode = self.__mainView:getUINode("ImgIconBig")

    for j = 1, FightCommons.BUFFICON_MAXCOUNT do
        local buffIcon = cloneItemNode(iconNode)

        local buffIconPosX = 477.76 - (j - 1) * 59.96

        buffIcon:setPosition(cc.p(buffIconPosX, 31.05))

        buffIcon:setVisible(true)

        ui:addBuffIcon(buffIcon, j)
    end

    for i = 0, FightCommons.ALL_BUFFICON_MAXCOUNT - 1 do
        local buffIcon = cloneItemNode(bigIconNode)

        local x = math.fmod(i, 6) + 1

        local y = math.modf(i / 6) + 1

        local buffIconPosX = 447.87 - (x - 1) * 76.45

        local buffIconPosY = 391.08 - (y - 1) * 83.83

        buffIcon:setPosition(cc.p(buffIconPosX, buffIconPosY))

        buffIcon:setVisible(true)

        ui:addBuffBigIcon(buffIcon, i + 1)
    end
end

--@desc:
--@author:Seven
--@time:2023-10-20 15:47:50
--@ui: 视图类
--@viewCharacter: [src.app.FightSystem.Veiws.ViewCommonModel.Character.ViewCharacter#ViewCharacter]
function CharactersInfoAreaViewCtrl:__syncUIShow(viewCharacter)
    local id = viewCharacter:getId()

    local qi = viewCharacter:getUIShowAttr("qi")
    local qiMax = viewCharacter:getUIShowAttr("qiMax")
    local qiLimit = viewCharacter:getUIShowAttr("qiLimitBattle")

    local neili = viewCharacter:getUIShowAttr("neili")
    local neiliMax = viewCharacter:getUIShowAttr("neiliMax")

    local tili = viewCharacter:getUIShowAttr("tili")
    local tiliMax = viewCharacter:getUIShowAttr("tiliMax")

    self:setInfoQiAnQiMaxView(id, qi, qiMax, qiLimit)
    self:setInfoNeiliAndNeiliMaxView(id, neili, neiliMax)
    self:setInfoTiliView(id, tili, tiliMax)

    self:setIconsView(id, viewCharacter:getIcons())
end

--@desc: 绑定左边ui信息显示接口
--@author:Seven
--@time:2023-10-20 15:44:16
--@index: 索引
--@viewCharacter: [src.app.FightSystem.Veiws.ViewCommonModel.Character.ViewCharacter#ViewCharacter]
function CharactersInfoAreaViewCtrl:bindLeftUI(index, viewCharacter)
    local ui = self.__leftInfoUIs[index]

    ui:setVisible(true)

    self.__uiBindMap[viewCharacter:getId()] = ui

    ui:setRoleName(viewCharacter:getName())

    ui:registerClickFunc(
        function()
            ui:showAllBuffPanel()
        end,
        function()
            ui:hideAllBuffPanel()
        end,
        function()
            ui:hideAllBuffPanel()
        end
    )

    self:__syncUIShow(viewCharacter)
end

--@desc: 绑定右边ui信息显示接口
--@author:Seven
--@time:2023-10-20 15:44:16
--@index: 索引
--@viewCharacter: [src.app.FightSystem.Veiws.ViewCommonModel.Character.ViewCharacter#ViewCharacter]
function CharactersInfoAreaViewCtrl:bindRightUI(index, viewCharacter)
    local ui = self.__rightInfoUIs[index]

    ui:setVisible(true)

    self.__uiBindMap[viewCharacter:getId()] = ui

    ui:setRoleName(viewCharacter:getName())

    ui:registerClickFunc(
        function()
            ui:showAllBuffPanel()
        end,
        function()
            ui:hideAllBuffPanel()
        end,
        function()
            ui:hideAllBuffPanel()
        end
    )

    self:__syncUIShow(viewCharacter)
end

function CharactersInfoAreaViewCtrl:setInfoQiAnQiMaxView(id, qi, qiMax, qiLimit)
    local ui = self.__uiBindMap[id]
    ui:setRoleQiAndQiMaxValue(qi, qiMax)
    ui:setRoleQiProgress(qi / qiLimit * 100)
    ui:setRoleQiMaxProgress(qiMax / qiLimit * 100)
end

function CharactersInfoAreaViewCtrl:setInfoNeiliAndNeiliMaxView(id, neili, neiliMax)
    local ui = self.__uiBindMap[id]
    ui:setRoleNeiLiAndNeiLiMaxValue(neili, neiliMax)
    ui:setRoleNeiLiProgress(neili / neiliMax * 100)
end

--@desc: 角色体力值和体力最大值UI刷新接口
--@author:Seven
--@time:2023-10-20 15:42:42
--@id: 角色id
--@tili: 体力值
--@tiliMax: 体力最大值
function CharactersInfoAreaViewCtrl:setInfoTiliView(id, tili, tiliMax)
    local ui = self.__uiBindMap[id]
    local percent = (tili / tiliMax) * 100

    local BattleConstConf = require("app.FightSystem.Configuration.BattleConstConf")
    --@desc 可出手的占比
    local attack_percent = BattleConstConf:get("autoUseSkillTili") / tiliMax * 100

    ui:setTiliMaxProgress(percent)
    if percent <= attack_percent then
        ui:setTiliProgress(percent)
    end
end

--@desc: 设置角色信息区域图标显示接口
--@author:Seven
--@time:2023-10-20 16:51:47
--@id: id
--@icons: 图标信息
function CharactersInfoAreaViewCtrl:setIconsView(id, icons)
    local ui = self.__uiBindMap[id]

    local showIcon = function(node, icon)
        node.Img:loadTexture(icon.imagePath, 0)
        if icon.count > 1 then
            node.TextLayer:setString(icon.count)
            node.TextLayer:setVisible(true)
        else
            node.TextLayer:setVisible(false)
        end
    end

    for i = 1, FightCommons.ALL_BUFFICON_MAXCOUNT do
        local icon = icons[i]
        local isShow = icon ~= nil

        if i <= FightCommons.BUFFICON_MAXCOUNT then
            local bigNode = ui:getBigIconNode(i)
            bigNode:setVisible(isShow)

            if isShow then
                showIcon(bigNode, icon)
            end
        end

        local smallNode = ui:getIconNode(i)
        smallNode:setVisible(isShow)
        if isShow then
            showIcon(smallNode, icon)
        end
    end
end

function CharactersInfoAreaViewCtrl:showNeiliCost(id, value)
    local ui = self.__uiBindMap[id]
    ui:showNeiliCost(value)
end

function CharactersInfoAreaViewCtrl:showOperationName(id, name)
    local ui = self.__uiBindMap[id]
    ui:showOperationName(name)
end

function CharactersInfoAreaViewCtrl:removeOperationName(id, hideAnimStyle)
    local ui = self.__uiBindMap[id]
    ui:hideOperationName(hideAnimStyle)
end

function CharactersInfoAreaViewCtrl:removeAllOperationName(id)
    local ui = self.__uiBindMap[id]
    ui:removeAllOperationName()
end

function CharactersInfoAreaViewCtrl:update(ft)
    for i, v in ipairs(self.__leftInfoUIs) do
        v:onUpdate(ft)
    end

    for i, v in ipairs(self.__rightInfoUIs) do
        v:onUpdate(ft)
    end
end

return newClass("CharactersInfoAreaViewCtrl", {}, CharactersInfoAreaViewCtrl)
0000000000000