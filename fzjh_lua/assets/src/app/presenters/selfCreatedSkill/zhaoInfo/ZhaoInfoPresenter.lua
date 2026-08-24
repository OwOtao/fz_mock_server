local inherit = require("third.inherit.inherit")
local IZhaoInfoPresenterOutput = require("app.presenters.selfCreatedSkill.zhaoInfo.IZhaoInfoPresenterOutput")
local IZhaoInfoPresenterInput = require("app.presenters.selfCreatedSkill.zhaoInfo.IZhaoInfoPresenterInput")
local isImplement = require("third.assertIsInstance.assertIsInstance")
local SelfCreatedSkillManager = require("app.models.SelfCreatedSkillSystem.SelfCreatedSkillManager.SelfCreatedSkillManager")
local SelfCreatedSkillConstants = require("app.models.SelfCreatedSkillSystem.SelfCreatedSkillConstants")
local StringUtil = require("app.extends.StringUtil")
local newSkillanim = assert(require("script.skill.newSkillanim").Sheet1)

local ZhaoInfoPresenter = {}

function ZhaoInfoPresenter:create(IZhaoInfoOutput,selfCreatedSkillSystem,zhaoIndex,callback)
    local p = inherit({}, ZhaoInfoPresenter)
    p:init(IZhaoInfoOutput,selfCreatedSkillSystem,zhaoIndex,callback)
    return p
end

function ZhaoInfoPresenter:init(IZhaoInfoOutput,selfCreatedSkillSystem,zhaoIndex,callback)
    self._selfCreatedSkillSystem = selfCreatedSkillSystem
    self._zhaoIndex = zhaoIndex
    self._callback = callback
    
    self._IZhaoInfoOutput = isImplement(IZhaoInfoOutput, IZhaoInfoPresenterOutput)
end


function ZhaoInfoPresenter:showLayer(skillId)

    self:__updateZhao()

    self:showTextZhaoName()
    self:showTextZhaoIndex()
    self:showTextZhaoQuality()
    self:showTextZhaoDsc()
    self:showTextZhaoNeed()
    self:showTextStr()
    self:showAffix()

    -- self:setZhaoAttrImage()
    -- self:setZhaoAffixImage()
    self:setButton3()
    self:setButton4()
    self:setButtonBack()
    self:playWuXueAnim()
    
    self._IZhaoInfoOutput:setButton4IsVisible(true)
    self._IZhaoInfoOutput:setShowLayer()
end

function ZhaoInfoPresenter:__updateZhao()
    self.__zhao = self._selfCreatedSkillSystem:getSelfCreatingZhao(self._zhaoIndex)
end


function ZhaoInfoPresenter:showTextZhaoName()
    local text = self.__zhao:getName()
    local textColor = self.__zhao:getColor()
    self._IZhaoInfoOutput:setTextZhaoNameAndColor(text,textColor)
end

function ZhaoInfoPresenter:showTextZhaoIndex()
    local text = "第"..Helper:numberCast(self._zhaoIndex).."招"
    self._IZhaoInfoOutput:setTextZhaoIndex(text)
end

function ZhaoInfoPresenter:showTextZhaoQuality()
    local text = self.__zhao:getQualityText()
    self._IZhaoInfoOutput:setTextZhaoType(text)
end

function ZhaoInfoPresenter:showTextZhaoDsc()
    local zhaoDscId = self.__zhao:getDscId()
    local text = SelfCreatedSkillManager:getUnsignedZhaoDescByActionId(zhaoDscId,self.__zhao)
    self._IZhaoInfoOutput:setTextZhaoDsc(text)
end

function ZhaoInfoPresenter:showTextZhaoNeed()
	local skill = self._selfCreatedSkillSystem:getSelfCreatingSkill()
	local minLvText = "不低于"..tostring(self.__zhao:getGrade()).."级"
	local maxGradeLv = self.__zhao:getMaxGrade()
	local maxLv = self.__zhao:getMaxLv()
	local limitLv = math.min(maxGradeLv,maxLv) 
	local maxLvText = ""
	if maxLv then
		maxLvText = "(最大"..tostring(limitLv).."级)"
	end

    self._IZhaoInfoOutput:setTextZhaoNeed("【当前武学】"..minLvText..maxLvText)
end

function ZhaoInfoPresenter:showTextStr()
    local zhaotype = self.__zhao:getType()
    local levelList,titalList,dscList = {},{},{}
    if zhaotype == SelfCreatedSkillConstants.SkillThirdType.QING_GONG then
        titalList[1] = "【闪躲】"
        levelList[1] = self.__zhao:getDodgeLevel()
        dscList[1] = SelfCreatedSkillManager:getParamsById("dodge_dsc")
        titalList[2] = "【攻速】"
        levelList[2] = self.__zhao:getAttackSpeedLevel()
        dscList[2] = SelfCreatedSkillManager:getParamsById("attackSpeed_dsc")
        titalList[3] = "【炼形】"
        levelList[3] = self.__zhao:getSpeedAddLevel()
        dscList[3] = SelfCreatedSkillManager:getParamsById("speedAdd_dsc")
        titalList[4] = "【炼步】"
        levelList[4] = self.__zhao:getDodgeAddLevel()
        dscList[4] = SelfCreatedSkillManager:getParamsById("dodgeAdd_dsc")
        titalList[5] = "【部位】"
        levelList[5] = self.__zhao:getHitPosName(self.__zhao:getHitPos1()).."部"
        dscList[5] = SelfCreatedSkillManager:getParamsById("hitPos1_dsc2")
    elseif zhaotype == SelfCreatedSkillConstants.SkillThirdType.NEI_GONG then
        titalList[1] = "【回复】"
        levelList[1] = self.__zhao:getRecoveryLevel()
        dscList[1] = SelfCreatedSkillManager:getParamsById("recovery_dsc")
        titalList[2] = "【气血】"
        levelList[2] = self.__zhao:getBloodLevel()
        dscList[2] = SelfCreatedSkillManager:getParamsById("blood_dsc")
        titalList[3] = "【回内】"
        levelList[3] = self.__zhao:getNeiLiLevel()
        dscList[3] = SelfCreatedSkillManager:getParamsById("recoveryNeili_dsc")
        titalList[4] = "【炼化】"
        levelList[4] = self.__zhao:getRecoveryAddLevel()
        dscList[4] = SelfCreatedSkillManager:getParamsById("recoveryAdd_dsc")
        titalList[5] = "【炼气】"
        levelList[5] = self.__zhao:getBloodAddLevel()
        dscList[5] = SelfCreatedSkillManager:getParamsById("bloodAdd_dsc")
    elseif zhaotype == SelfCreatedSkillConstants.SkillThirdType.ZHAO_JIA then
        titalList[1] = "【防御】"
        levelList[1] = self.__zhao:getDefenseLevel()
        dscList[1] = SelfCreatedSkillManager:getParamsById("defense_dsc")
        titalList[2] = "【格挡】"
        levelList[2] = self.__zhao:getParryLevel()
        dscList[2] = SelfCreatedSkillManager:getParamsById("parry_dsc")
        titalList[3] = "【炼体】"
        levelList[3] = self.__zhao:getDefenseAddLevel()
        dscList[3] = SelfCreatedSkillManager:getParamsById("defenseAdd_dsc")
        titalList[4] = "【炼技】"
        levelList[4] = self.__zhao:getParryAddLevel()
        dscList[4] = SelfCreatedSkillManager:getParamsById("parryAdd_dsc")
        titalList[5] = "【部位】"
        levelList[5] = self.__zhao:getHitPosName(self.__zhao:getHitPos1()).."部"
        dscList[5] = SelfCreatedSkillManager:getParamsById("hitPos1_dsc3")
    else
        titalList[1] = "【力道】"
        levelList[1] = self.__zhao:getAttackLevel()
        dscList[1] = SelfCreatedSkillManager:getParamsById("attack_dsc")
        titalList[2] = "【命中】"
        levelList[2] = self.__zhao:getHitLevel()
        dscList[2] = SelfCreatedSkillManager:getParamsById("hit_dsc")
        titalList[3] = "【重伤】"
        levelList[3] = self.__zhao:getTopLimitLevel()
        dscList[3] = SelfCreatedSkillManager:getParamsById("topLimit_dsc")
        titalList[4] = "【消耗】"
        levelList[4] = self.__zhao:getSpiritLevel()
        dscList[4] = SelfCreatedSkillManager:getParamsById("spirit_dsc")
        titalList[5] = "【炼准】"
        levelList[5] = self.__zhao:getHitAddLevel()
        dscList[5] = SelfCreatedSkillManager:getParamsById("hitAdd_dsc")
        titalList[6] = "【炼劲】"
        levelList[6] = self.__zhao:getAttackAddLevel()
        dscList[6] = SelfCreatedSkillManager:getParamsById("attackAdd_dsc")
        titalList[7] = "【部位】"
        levelList[7] = self.__zhao:getHitPosName(self.__zhao:getHitPos1()).."部"
        dscList[7] = SelfCreatedSkillManager:getParamsById("hitPos1_dsc1")
    end
    for i = 1, 8 do
        local retList = {}
        if titalList[i] then
            retList["isVisible"] = true
            retList["textLevel"] = levelList[i]
            retList["strLevel"] = titalList[i]
            retList["dsc"] = dscList[i]
            self._IZhaoInfoOutput:setPanelAttr(i,retList)
        else
            retList["isVisible"] = false
            self._IZhaoInfoOutput:setPanelAttr(i,retList)
        end
    end
end

function ZhaoInfoPresenter:showAffix()
    local affixs = self.__zhao:getAffixs()
    for i = 1, 6 do
        local affix = affixs[i]
        if affix then
            self._IZhaoInfoOutput:setPanelTipIsVisible(i,true)
            self._IZhaoInfoOutput:setPanelTip(i,affix:getName(),affix:getDsc())
        else
            self._IZhaoInfoOutput:setPanelTipIsVisible(i,false)
        end
    end
end

function ZhaoInfoPresenter:hideLayer()
    self._IZhaoInfoOutput:hideLayer()
end

-- function ZhaoInfoPresenter:setZhaoAttrImage()
--     --@desc 获取招式属性是否锁定
--     local isOpen = false
--     local image = "Image/UI/SelfCreatedSkillUI/1-2.png"
--     if isOpen then
--         image = "Image/UI/SelfCreatedSkillUI/1-1.png"
--     end
--     self._IZhaoInfoOutput:setZhaoAttrImage(image)
-- end

-- function ZhaoInfoPresenter:setZhaoAffixImage()
--     local isOpen = true
--     local image = "Image/UI/SelfCreatedSkillUI/1-2.png"
--     if isOpen then
--         image = "Image/UI/SelfCreatedSkillUI/1-1.png"
--     end
--     self._IZhaoInfoOutput:setZhaoAttrImage(image)
-- end

function ZhaoInfoPresenter:setButton3()
    self._IZhaoInfoOutput:setButton3(function()
        Audio:playEffect("xiaoAnNiu")
        self._selfCreatedSkillSystem:getImprovedPropList(function(propList)
            PopupLayerController:showLayer("ZhaoImprovedPoolUI",
            function(layer)
                local presenter = require("app.presenters.selfCreatedSkill.zhaoImprovedPool.ZhaoImprovedPoolPresenter")
                layer:showLayer(self._selfCreatedSkillSystem,propList,presenter,self._zhaoIndex,true,function(data)
                    if MapIsEmpty(data.zhaos) == false then
                        self._selfCreatedSkillSystem:updataZhao(self._zhaoIndex,data.zhaos)
                        self:__updateZhao()
                        self:showTextZhaoName()
                        self:showTextZhaoIndex()
                        self:showTextZhaoQuality()
                        self:showTextZhaoDsc()
                        self:showTextZhaoNeed()
                        self:showTextStr()
                        
                        self:showAffix()
                    else
                        print("招式数据为空")
                    end
                end)
            end)
        end)
    end)
end

function ZhaoInfoPresenter:setButton4()
    self._IZhaoInfoOutput:setButton4(function()
        Audio:playEffect("xiaoAnNiu")
        PopupLayerController:showLayer("ZhaoModifyUI",
        function(layer)
            layer:showLayer(self._selfCreatedSkillSystem,self._zhaoIndex,function()
                self:__updateZhao()
                self:showTextZhaoName()
                self:showTextZhaoDsc()
            end)
        end
    )
    end)
end

function ZhaoInfoPresenter:setButtonBack()
    self._IZhaoInfoOutput:setButtonBack(function()
        Audio:playEffect("fanHuiQuXiao")
        if self._callback then
            self._callback()
        end
        self:hideLayer()
    end)
end

local weaponAttachMap = {
    [SelfCreatedSkillConstants.SkillThirdType.JIAN_FA] = {"images/weapon/sword1","kk/duanjian","kk/ruanjian","kk/zhongjian","kk/cijian"},
    [SelfCreatedSkillConstants.SkillThirdType.DAO_FA] = {"images/weapon/knife1","kk/duandao","kk/wandao","kk/dahuandao","kk/shuangrenfu"},
    [SelfCreatedSkillConstants.SkillThirdType.GUN_FA] = {"images/weapon/gun1","kk/changqiang","kk/sanjiegun/sanjiegun","kk/langyabang","kk/zhanji"},
    [SelfCreatedSkillConstants.SkillThirdType.BIAN_FA] = {"images/weapon/bian1","kk/ruanbian","kk/jiujiebian","kk/ganzibian","kk/lianjia"},
    [SelfCreatedSkillConstants.SkillThirdType.SHUANG_CHI] = {"kk/shuanghuanwuqi_1","kk/duijian","kk/shuanggou"},
    [SelfCreatedSkillConstants.SkillThirdType.AN_QI] = {"kk/anqi/zhuixing","kk/anqi/yuanxing","kk/anqi/zhenxing",},
    [SelfCreatedSkillConstants.SkillThirdType.QIN_FA] = {"kk/jichuqinfa/jichuqinfa_qin2","kk/yueqi/Flute"},
}

function ZhaoInfoPresenter:playWuXueAnim()
    local skill = self._selfCreatedSkillSystem:getSelfCreatingSkill()
    local firstType = skill:getFirstType()
    
    if firstType == SelfCreatedSkillConstants.SkillFirstType.QUAN_JIAO or SelfCreatedSkillConstants.SkillFirstType.BING_QI then
        self._IZhaoInfoOutput:setPanelAnimAreaIsVisible(true)
    else
        self._IZhaoInfoOutput:setPanelAnimAreaIsVisible(false)
        return
    end

    local weaponName1 = "" 
    local weaponName2 = ""
    local secondType = skill:getThirdType()
    local weapontypeList = skill:getWeapontype()
    local weapontype
    if firstType == SelfCreatedSkillConstants.SkillFirstType.BING_QI then
        weapontype = weapontypeList[math.random(1,#weapontypeList)]
    end

    -- 待机姿势
    local standAnim = skill:getStandAnim()
    if string.find(standAnim, "_", -1) then
        standAnim = standAnim..StringUtil:subNum(weapontype)
    end

    -- 前跳动画
    local jumpForwardAnim = skill:getJumpForwardAnim()
    if string.find(jumpForwardAnim, "_", -1) then
        jumpForwardAnim = jumpForwardAnim..StringUtil:subNum(weapontype)
    end

    -- 兵器图片
    if weaponAttachMap[secondType] then
        weaponName1 = weaponAttachMap[secondType][tonumber(StringUtil:subNum(weapontype))]
		if secondType == SelfCreatedSkillConstants.SkillThirdType.SHUANG_CHI then
			weaponName2 = weaponName1
		end
    end

    local zhaoData = self.__zhao:getData()
    local animList = {}
    for i = 1,99 do
        local anims = {}
        if zhaoData["anim"..i] then
            anims["anim"] = zhaoData["anim"..i]
            anims["offset"] = zhaoData["offset"..i]
            anims["speed"] = zhaoData["speed"..i]
            anims["hitPos"] = zhaoData["hitPos"..i]
            if string.find(anims["anim"], "_", -1) then
                local newAnimId = anims["anim"]..StringUtil:subNum(weapontype)
                local newSkillanimParam = newSkillanim[newAnimId]

                anims["anim"] = newAnimId
                anims["offset"] = newSkillanimParam["offset"]
                anims["hitPos"] = newSkillanimParam["location"]
            end
        else
            break
        end
        table.insert(animList,anims)
    end

    print("---------------playWuXueAnim-----------------")
    Helper:print_lua_table(animList)
    print("standAnim = ",standAnim,"jumpForwardAnim = ",jumpForwardAnim,"weaponName1 = ",weaponName1,"weaponName2 = ",weaponName2)
    
    self._IZhaoInfoOutput:playWuXueAnim(standAnim,jumpForwardAnim,animList,weaponName1,weaponName2)
end

isImplement(ZhaoInfoPresenter, IZhaoInfoPresenterInput)
return ZhaoInfoPresenter
0000