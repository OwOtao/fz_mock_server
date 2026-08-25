
local CoroutinePool = require("third.coroutine.CoroutinePool")
local TitleUI = class("TitleUI", cc.Layer)

--@RefType [src.app.models.map.PingAnTown#PingAnTown]
local PingAnTown = require("app.models.map.PingAnTown")

local TITLE_CONFIG = {
	[0]={
        fontColor = {r = 128, g = 128, b = 128},
        img = "Image/UI/HomelandUI/doorplate_1.png"
    },
    [1]={
        fontColor = {r = 128, g = 128, b = 128},
        img = "Image/UI/HomelandUI/doorplate_1.png"
    },
    [2]={
        fontColor = {r = 107, g = 81, b = 76},
        img = "Image/UI/HomelandUI/doorplate_2.png"
    },
    [3]={
        fontColor = {r = 138, g = 110, b = 80},
        img = "Image/UI/HomelandUI/doorplate_3.png"
    },
    [4]={
        fontColor = {r = 239, g = 201, b = 130},
        img = "Image/UI/HomelandUI/doorplate_4.png"
    }
}

function TitleUI:create()
	local p = TitleUI:new()
	p:init()
	return p
end

local tabs =
{
	MainLayer = "",
	TaskLayer = "任务",
	AttrLayer = "属性",
	SelectMapLayer = "江湖",
	TeacherLayer = "师门",
	SkillPrepareLayer = "准备武功",
	ActiveSkillPrepareUI = "准备技能",
	BiWuStartLayer = "比武场",
	ShenBingLayer = "玄兵古洞",
	XuanBingDong = "悬兵洞",
	XuanBingDongOld = "悬兵洞",
	CangYiGe  = "藏衣阁",
	CangYiGeOld  = "藏衣阁",
	ShenBingSkilledLayer =  "已学技艺",
	SetupLayer = "设置",
	-- CommunityLayer = "公告",
	InheritLayer = "传承",
	InheritAttrLayer = "传承",
	QuietRoomLayer = "静修室",
	MeridianBreakLayer = "经脉",
	MeridianImprintingPresenter = "经脉天赋",
	HiddenMeridianMenuPresenter = "隐脉",
	FurnaceLayer = "锻造炉",
	UserEquipItemLayer = "墙壁",
	UserArmorItemLayer = "衣柜",
	FamilyGroupRankLayer = "进境排行",
	TuJianMenuLayer = "图鉴",
	SelfCreatedSkillMenuUI = "书房",
	SelectMapMenuPresenter = "我的江湖",
	JiangHuAnecdotePresenter = "江湖轶闻",
	SkillBreakThroughPresent = "武学突破",
	ZhaoBreakThroughPresent = "技能突破",
	FistFootMenuPresenter = "拳脚修炼",
	FistFootTaskPresenter = "修行方式",
	FistFootGuaJiPresenter = "修行中",
	TechniquePresenter = "技巧修炼",
	TalentPagePresenter = "易法换技",
	ComprehendCharacterPresenter = "领悟特性",
	CharacterInfoPresenter = "特性详细",
	ActiveZhaoPracticePresenter = "对练招式",
	GiftPagePresenter = "授予残页",
	ForgetPagePresenter = "忘却招式",

	TeacherBuildMenuPresenter = "江湖浪人",
	TeacherBuildTaskPresenter = "师门日常",
	TeacherBuildGuaJiPresenter = "日常进行中",
	TeacherBuildListPresenter = "师门建筑",
	TeacherBuildInfoPresenter = "建筑名称",
	TeacherBuildDonatePresenter = "捐献建筑材料",
	TeacherFeatPresenter = "师门建树",
	TeacherFeatClassPresenter = "师门名衔",
	TeacherGuidancePresenter = "师门指点"
}

local IsShowSetUp = false

local specialTab = {
	MapLayerXuanBingDong = function (self)
		self.Panel_tips:setVisible(false)
		return  "墙壁"
	end,
	MapLayerCangYiGe = function (self)
		self.Panel_tips:setVisible(false)
		return  "衣柜"
	end
}


function TitleUI:init()
    self._round = require("Layer/TitleUI.lua").create()["root"]
    self._round:addTo(self)

    Helper:convertUI(self) -- 获得所有子节点
    self.activity_hongdian=false
    self:setTitleBack()
    self:setButton_setup()
    self.Text_Custom:setVisible(false)
    self:pingAnButton()
    self.lastLayer = nil
	self:setAnecdoteVisible(false)

    self.__coroutinePool = CoroutinePool:create()
    self.__coroutinePool:addAsync("TitleUI", 
        function(thread)
            while true do
                repeat
                    local layerStack = MainControllLayer._layerStack
                    if #layerStack > 0 then
                        local layerName = layerStack[#layerStack]

                        if self.lastLayer == layerName then
                            break
                        end
                        
                        self.lastLayer = layerName

                        if layerName == "SkillInfoLayer" then
                            self.Image_back:setVisible(false)

                            self.Button_setup:setVisible(false)

							self.Text_Custom:setVisible(true)

                            self.Text_title:setTextColor({r = 208, g = 208, b = 208})

                            self.Text_title:setFontName("Font/HYCFS.ttf")
                            break
                        end

                        if layerName == "MapLayer" then
                            break
                        end


						self.Button_setup:setVisible(false)
                        self.Button_back:setVisible(false)
                        self.Button_back_JH:setVisible(false)
                        self.Panel_title:setVisible(false)
                        self.Panel_title:setTouchEnabled(false)
                        self.Image_left:setVisible(false)
                        self.Image_right:setVisible(false)
                        self.Image_left_0:setVisible(false)
                        self.Image_right_0:setVisible(false)
                        self.Text_Custom:setVisible(false)
                        self.Panel_tips:setVisible(false)
						self.Image_rule:setVisible(false)

                        switch(
                            layerName,
                            {
                                MainLayer = function()
                                    self.Button_setup:setVisible(true)
                                    self.Panel_title:setVisible(true)
                                    self.Panel_title:setTouchEnabled(true)
                                    self.Button_action:setVisible(true)
                                    -- local DogYearSpringFestival = require("app.models.SpringFestival.DogYearSpringFestival")
                                    -- if DogYearSpringFestival:getDogYearSpringFestivalState() == true then
                                    -- 	self.Image_left:setVisible(true)
                                    -- 	self.Image_right:setVisible(true)
                                    -- 	self.Image_left_0:setVisible(true)
                                    -- 	self.Image_right_0:setVisible(true)
                                    -- end
                                end,
                                SelectMapLayer = function()
                                    self.Button_back:setVisible(true)
                                    self.Button_back_JH:setVisible(false)
                                    self.Button_action:setVisible(false)
                                end,
                                CangYiGe = function()
                                    self.Panel_tips:setPosition(432.23, 54.00)
                                    self.Panel_tips:setVisible(true)
                                    self.Button_setup:setVisible(true)
                                    self.Button_back:setVisible(true)
                                    self.Button_action:setVisible(false)
                                end,
                                CangYiGeOld = function()
                                    self.Panel_tips:setPosition(432.23, 54.00)
                                    self.Panel_tips:setVisible(true)
                                    self.Button_setup:setVisible(true)
                                    self.Button_back:setVisible(true)
                                    self.Button_action:setVisible(false)
                                end,
                                XuanBingDong = function()
                                    self.Panel_tips:setPosition(432.23, 54.00)
                                    self.Panel_tips:setVisible(true)
                                    self.Button_setup:setVisible(true)
                                    self.Button_back:setVisible(true)
                                    self.Button_action:setVisible(false)
                                end,
                                XuanBingDongOld = function()
                                    self.Panel_tips:setPosition(432.23, 54.00)
                                    self.Panel_tips:setVisible(true)
                                    self.Button_setup:setVisible(true)
                                    self.Button_back:setVisible(true)
                                    self.Button_action:setVisible(false)
                                end,
                                ShenBingLayer = function()
                                    self.Panel_tips:setPosition(432.23, 54.00)
                                    self.Button_setup:setVisible(true)
                                    self.Button_back:setVisible(true)
                                    self.Button_action:setVisible(false)
                                end,
                                FurnaceLayer = function()
                                    self.Panel_tips:setPosition(432.23, 54.00)
                                    self.Panel_tips:setVisible(true)
                                    self.Button_setup:setVisible(true)
                                    self.Button_back:setVisible(true)
                                    self.Button_action:setVisible(false)
                                end,
                                ShenBingSkilledLayer = function()
                                    self.Panel_tips:setPosition(403, 54.00)
                                    self.Panel_tips:setVisible(true)
                                    -- self.Button_setup:setVisible(true)
                                    self.Button_back:setVisible(true)
                                    self.Button_action:setVisible(false)
                                end,
                                MeridianImprintingPresenter = function()
                                    self.Panel_tips:setPosition(403, 54.00)
                                    self.Panel_tips:setVisible(true)
                                    -- self.Button_setup:setVisible(true)
                                    self.Button_back:setVisible(true)
                                    self.Button_action:setVisible(false)
                                end,
								HiddenMeridianMenuPresenter = function()
                                    self.Button_back:setVisible(true)
                                    self.Button_action:setVisible(false)
									self.Image_rule:setVisible(true)
                                end,
                                MeridianBreakLayer = function()
                                    self:setChongZhuButton()
                                    self.Button_back:setVisible(true)
                                    self.Button_action:setVisible(false)
								end,
                                ActionLayer = function()
                                    self.Button_back:setVisible(false)
                                    self.Button_action:setVisible(false)
                                end,
                                TeacherLayer = function()
                                    self.Button_back:setVisible(true)
                                    self.Button_setup:setVisible(false)
                                    self.Button_action:setVisible(false)
                                end,
                                SkillBreakThroughPresent = function()
									self.Text_Custom:setVisible(true)
                                    self.Button_back:setVisible(true)
                                    self.Button_setup:setVisible(false)
                                    self.Button_action:setVisible(false)
                                end,
								SkillPrepareLayer = function()
                                    self.Button_back:setVisible(true)
									if self.__prepBtnSetupVisible == true then
										self.Button_setup:setVisible(true)
									else
										self.Button_setup:setVisible(false)
									end
                                    self.Button_action:setVisible(false)
                                end,
								ComprehendCharacterPresenter = function()
									self.Text_Custom:setVisible(true)
									self.Button_back:setVisible(true)
                                    self.Button_action:setVisible(false)
								end,
								GiftPagePresenter = function()
									self.Text_Custom:setVisible(true)
									self.Button_back:setVisible(true)
                                    self.Button_action:setVisible(false)
								end,
								TeacherFeatPresenter = function()
                                    self.Button_back:setVisible(true)
                                    self.Button_setup:setVisible(true)
                                    self.Button_action:setVisible(false)
                                end,
								TeacherGuidancePresenter = function()
                                    self.Button_back:setVisible(true)
                                    self.Button_setup:setVisible(true)
                                    self.Button_action:setVisible(false)
                                end,
                                default = function()
                                    self.Button_back:setVisible(true)
                                    self.Button_action:setVisible(false)
                                end
                            }
                        )
                        
                        if layerName == "MainLayer" then
                            self:setMainLayerActivityInfo(false)
                            self:setMailBoxHongdian(true)
                        else
                            self:setMainLayerActivityInfo()
                            self:setMailBoxHongdian(false)
                        end

                        local titleName = ""
                        titleName = tabs[layerName]
                        
                        -- self.Image_back:setVisible(false)
                        if JIAYUAN_SYSTEM_IS_OPEN == true then
                            if #layerStack > 1 then
                                local specialName = layerStack[#layerStack - 1] .. layerName

                                if specialTab[specialName] then
                                    titleName = specialTab[specialName](self)
                                end
                            end

                            if layerName == "MainLayer" then
                                local role = User:getRole()
                                local status = role:getHouseStatus()
                                if status == 1 then
                                    local fq = role:getHomelandAttr("fq")
                                    titleName = fq.houseName
                                    local fqId = fq.fqId

                                    local FangQiModel = require("app.models.HomelandModel.FangQiModel")
                                    local level = FangQiModel:getLevel(fqId)

                                    local imgSrc, fontColor
                                    if TITLE_CONFIG[level] ~= nil then
                                        imgSrc = TITLE_CONFIG[level].img
                                        fontColor = TITLE_CONFIG[level].fontColor
                                    end

                                    if imgSrc == nil then
                                        self.Image_back:setVisible(false)
                                    else
                                        self.Image_back:loadTexture(imgSrc, 0)
                                        self.Text_title:setTextColor(fontColor)
                                        self.Text_title:setFontName("Font/HYCFS.ttf")
                                        self.Image_back:setVisible(true)
                                    end
                                else
                                    self.Image_back:setVisible(false)
                                    self.Text_title:setTextColor({r = 208, g = 208, b = 208})
                                    self.Text_title:setFontName("Font/HYCFS.ttf")
                                end
                            else
                                self.Image_back:setVisible(false)
                                
                                self.Text_title:setTextColor({r = 208, g = 208, b = 208})
                                
                                self.Text_title:setFontName("Font/HYCFS.ttf")
                            end
                        end
                        
                        if layerName == "TeacherLayer" then
                            self.Panel_title:setVisible(true)
                            self.Panel_title:setTouchEnabled(true)
                            local role = User:getRole()

                            if role:getLv()>=300 then 
                                local teacherId = User:getRoleAttr("teacherId")

                                local npc = Npc:getNpc(teacherId)

                                if npc == nil then
                                    self.Image_back:setVisible(false)
                                else
                                    local imgSrc = npc.titleImg
                                    if imgSrc == nil then
                                        self.Image_back:setVisible(false)
                                    else
                                        self.Image_back:loadTexture("Image/UI/TeacherUI/"..imgSrc, 0)
                                        self.Image_back:setVisible(true)
                                    end
                                end
                            else
                                local Family = require("app.models.family.Family")
                                local titleText,titleImage=Family:getLowLevelShowTitleInfo()
                                if titleImage == nil then
                                    self.Image_back:setVisible(false)
                                else
                                    self.Image_back:loadTexture("Image/UI/TeacherUI/"..titleImage, 0)
                                    self.Image_back:setVisible(true)
                                end
                            end
                            self.Text_title:setTextColor({r = 208, g = 208, b = 208})
                            self.Text_title:setFontName("Font/HYCFS.ttf")
                        elseif layerName == "TeacherBuildMenuPresenter" then
                            titleName = User:getRole():getFamilyName()
						elseif layerName == "TeacherBuildInfoPresenter" then
							titleName = User:getRole():getTeacherBuildSystem():getCurrBuildName()
                        end
                        self:setTextTitle(titleName)
                    end
                    print("执行一次TitleUI刷新")
                until true
                thread:yield()
            end
        end)
end

function TitleUI:update(ft)
    self.__coroutinePool:update(ft)
end

function TitleUI:afterFuncShowGlobalShadeLayer(isShow)
	if isShow then 
		PopupLayerController:showLayer("GlobalShadeLayer",function(layer)
			layer:showLayer()
		 	end)
	else
		PopupLayerController:hideLayer("GlobalShadeLayer",function(layer)
			layer:delayFunc(0.5,function()
					layer:hideLayer()
				end)
			end)
	end
end

function TitleUI:setMainLayerActivityInfo(isShow)
	self.Text_action:setColor(cc.c3b(225, 227, 115))
	if isShow~=nil then 
		if isShow then 
			self.activity_hongdian=true
		end
		self.Image_hongdian:setVisible(self.activity_hongdian)
		self.Button_action:releaseFunc(function()
			self:afterFuncShowGlobalShadeLayer(true)
			HttpManagerEx:getEventList(2, User:getRole():getCurrencyVersion(), function(status, errcode, errmsg, data)
					if status ==200 and errcode == 0 then 
						Audio:playEffect("daSuanPan")
						--MainControllLayer:pushLayer("ActionLayer")
						local ActionLayer=MainControllLayer:getLayer("ActionLayer")
						ActionLayer:show(data,"MainLayer")
						self.Image_hongdian:setVisible(false)
						self.activity_hongdian=false
						self:afterFuncShowGlobalShadeLayer(false)
					else
						self:afterFuncShowGlobalShadeLayer(false)
						PopText(errmsg)
					end
				end,IS_SHOW_WAITING)
		end)
	else
		self.Image_hongdian:setVisible(false)
	end
	
end

function TitleUI:setMailBoxHongdian(isMainLayer)
	if isMainLayer == true then
		local role = User:getRole()
		if role:getMailBoxState() == 1 and IsShowSetUp == false then
			self.Image_mbHongdian:setVisible(true)
		else
			self.Image_mbHongdian:setVisible(false)
		end
	else
		self.Image_mbHongdian:setVisible(false)
	end
end

function TitleUI:setSetUpButtonName(name)
	name = Helper:getDef(name,"设置")
	self.Text_setup:setString(name)
end

function TitleUI:setLayerTitleName(layerName, str)
	if not str then
		return
	end
	tabs[layerName] = str
end

function TitleUI:setSkillPrepSkillLayerSetupBtnVisible(bool)
	--@desc 该属性只对主动技能准备界面生效，临时处理使用该方案进行处理
	self.__prepBtnSetupVisible = bool
	self.Button_setup:setVisible(bool)
end

function TitleUI:setButton_setup()
	self.Button_setup:setTouchEnabled(true)
	self.Button_setup:releaseFunc(function()
		Audio:playEffect("xiaoAnNiu")
		MainControllLayer:pushLayer("SetupLayer")
        MainControllLayer:getLayer("SetupLayer"):show()
        
		self.Image_mbHongdian:setVisible(false)
		IsShowSetUp = true
	end)
end

function TitleUI:setButton_setupFunc(func)
	self.Button_setup:setTouchEnabled(true)
	self.Button_setup:releaseFunc(function()
		Audio:playEffect("xiaoAnNiu")
		if func then
			func()
		end
	end)
end


function TitleUI:show(anim)
	local imgHeight = self.Image_titleBack:getContentSize().height
	local tag = self:getActionTagByName("TitleShowAndHide")
	self:setVisible(true)
	self:stopActionByTag(tag)
	if anim then
		local action = cc.Sequence:create(cc.MoveTo:create(0.3, cc.p(0, 0)))
		action:setTag(tag)
		self:runAction(action)
	else
		self:move(cc.p(0, 0))
	end
	-- self:switchLayer()
end

function TitleUI:hide(anim)
	local imgHeight = self.Image_titleBack:getContentSize().height
	local tag = self:getActionTagByName("TitleShowAndHide")
	self:stopActionByTag(tag)
	self:setVisible(false)
	if anim then
		local action = cc.Sequence:create(cc.MoveTo:create(0.3, cc.p(0, imgHeight)))
		action:setTag(tag)
		self:runAction(action)
	else
		self:move(cc.p(0, imgHeight))
	end
end

function TitleUI:switch(duration)
	if duration and duration > 0 then
		duration = duration / 2
	else
		duration = 0
	end
	
	local imgHeight = self.Image_titleBack:getContentSize().height
	local tag = self:getActionTagByName("TitleShowAndHide")
	self:stopActionByTag(tag)
	
	local action = cc.Sequence:create(cc.MoveTo:create(duration, cc.p(0, imgHeight)), cc.MoveTo:create(duration, cc.p(0, 0)))
	action:setTag(tag)
	self:runAction(action)
end

function TitleUI:setTextTitle(str)
	self.Text_title:setString(str)
end

function TitleUI:setTitle(str)
	self.Text_title:setString(str)
end

function TitleUI:setTitleBack()
	self.Button_back_JH:setVisible(false)
	self.Button_back:setVisible(true)
	self.Button_back:releaseFunc(function()
		Audio:playEffect("fanHuiQuXiao")
		MainControllLayer:popLayer()
		if self.backCallFunc then
			self.backCallFunc()
			self.backCallFunc = nil
		end
	end)
end
--设置回调，仅执行一次
function TitleUI:setBackCallFunc(func)
	if not func then
		return
	end
	self.backCallFunc = func
end

function TitleUI:ButtonBack(func)
	self.Button_back:releaseFunc(func)
end

-- 江湖界面返回按钮
function TitleUI:setTitleJHBack()
	self.Button_back:setVisible(true)
	self.Button_back_JH:setVisible(false)
	self.Button_back:releaseFunc(function()
		Audio:playEffect("fanHuiQuXiao")
		MainControllLayer:popLayer()
	end)
	-- self.
end

--注册经脉重筑按钮
function TitleUI:setChongZhuButton()
	self.Text_Custom:setString("重筑")
	self.Text_Custom:setVisible(true)
	self.Text_Custom:releaseFunc(function()
		HttpManagerEx:getActionTimes("JingMaiChongZhu",function(status, errcode, errmsg, data)
			if status == 200 then
				if errcode == 0 then
					PopupLayerController:showLayer("DialogYuanBaoPayLayer", function(layer)
						local text = "RED重筑：将经脉重置为初始状态，经脉等级将变为1级，但现有真气保留，经脉天赋将被移除，但根据已传承次数可选择保留一定数量，确定重筑后，将会进行相关操作。\n请慎重考虑后再做决定。"
						layer:showLayer()
						layer:setTiTleText("经脉重筑")
						layer:setTextTitle1("是否要进行经脉重筑？")
						layer:setDesc(text)
						local costText = ""
						if tonumber(data.num) == 0 then
							costText = "本次重筑免费"
						else
							costText = "需要消耗"..data.remove.."元宝"
						end
						layer:setPrice(costText)
						
						layer:setButton1("确定重筑",
							function()
								--此处还需要判断元宝是否够，让服务器返回元宝数量
								local yuanbaoNum = data.yuanbao
								print("yuanbaoNum = ",yuanbaoNum)
								if tonumber(yuanbaoNum) < tonumber(data.remove) then
									PopText("元宝不足")
									return 
								end

								local role = User:getRole()
								local meridianCount = role.meridian.meridianCount
								if meridianCount < 1 then
									PopText("至少打通一条经脉方能重筑！")
									return
								end
								
								local ImprintingRebuild = require("app.models.Meridian.Rebuild.ImprintingRebuild"):create(User:getRole())

								PopupLayerController:showLayer("MeridianRebuildPresenter", function(presenter)
									local ui = require("app.views.ui.Meridian.MeridianInheritUI"):create()
									presenter:setInput(ImprintingRebuild)
									presenter:setUI(ui)
									presenter:showPresenter()
								end)
							end
						)
						layer:setButton2("取消",
							function()
							end
						)
						layer:setTextItemNameIsVisible(false)
						layer:setImageItemIconIsVisible(false)
					end)
				else
					PopText(errmsg)
					print("errmsg", errmsg, "errcode", errcode)
				end
			else
				PopText(errmsg)
			end
		end,
		IS_SHOW_WAITING)
	end)
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2018/05/25 15:20:29
-- @params 
-- @desc 进入玩家副本
function TitleUI:entryUserMap()
	--@desc 检查能否进入
	local role = User:getRole()
	local RoleTaskControllor = require("app.views.layer.RoleLayer.RoleTaskControllor")
	if RoleTaskControllor:clickMapLayer(role, function()end) == false then
		return false
	end

	local UserMap = require("app.models.map.UserMap")
	local mid, userid = role:getHouseId() or "" , User:getUserId()

	local entryMapLayer = self.ControllLayer:getLayer("EntryMapLayer")
	entryMapLayer:maxZ()
	entryMapLayer:show()
	entryMapLayer:setCenterText("你心有所感，在家里随意走了走。")
	Audio:playEffect("huijiaBGM")

	UserMap:getUserMap(mid, userid, function(map,isSuccess)
		if isSuccess == false then
			MainControllLayer:removeLayer("EntryMapLayer")
			return
		end

		map._isComingIn = true
		 --RichPrint("main", "HIC你心有所感，在家里随意走了走。")
		 --RichPrint("main", "HIC车夫扬起手中鞭，吆喝道：看车！去"..tostring(map.name).."了。")

		local titleLayer = MainControllLayer:getLayer("TitleLayer")
		local mapRoleLayer = MainControllLayer:getLayer("MapRoleLayer")
		mapRoleLayer:onResume()
		titleLayer:hide(true)


		self:delayFunc(1,
		function(obj)
			map:setCallBackAndConnect(function()
				local mapLayer = MainControllLayer:getLayer("MapLayer")

				mapLayer:setMap(map)

				--@desc 获取门前
				local defaultRoom = map:getRoomAttr(map:getDefaultRoomId())

				local doorRoomId = defaultRoom.link[UserMap:getHouseDirByIndex(map.dirMark)]

				if doorRoomId ~= nil then
	
					local guanjia
					local roleList=map:getRoomRoleList(doorRoomId)
					for i,roleId in pairs(roleList) do
						if roleId and "guanjia1001"==roleId then
							guanjia=map:getRole(roleId)
						end
					end
					if guanjia then 
						local strName=guanjia.name
						entryMapLayer:hide(EMPTY_FUNC) -- 隐藏界面
						RichPrint("main", "HIC"..strName.."：有事要吩咐么？NOR")
					end
				end
				
				-- 释放地图动画层
				MainControllLayer:removeLayer("EntryMapLayer")
				
				MainControllLayer:pushLayer("MapLayer")

				MessageCenter:notify("EnterMap",{map=map})
				mapLayer:teleportRoom(doorRoomId)
			end)
		end)
	end)
end


-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/12/18 17:11:19
-- @desc 平安小镇按钮
function TitleUI:pingAnButton()
	self.Panel_title:setVisible(true)
	self.Panel_title:setTouchEnabled(true)
	self.Panel_title:releaseFunc(function()
		
		if MainControllLayer:getCurrLayer() == "MainLayer" then
			local role = User:getRole()
			local fq = role:getHomelandAttr("fq")

			if JIAYUAN_SYSTEM_IS_OPEN == true then
				if fq.mid and fq.status == 1 then
					self:entryUserMap()
				end
			end
		elseif MainControllLayer:getCurrLayer() == "TeacherLayer" then

			if User:getRole():getLv()<300 then 
				PopText("进入师门地图需要角色等级达到300级！")
				return 
			end
			
			local RoleTaskControllor = require("app.views.layer.RoleLayer.RoleTaskControllor")
			if RoleTaskControllor:clickMapLayer(role, function()end) == false then
				return 
			end

			--@RefType [src.app.models.family.Family#Family]
			local Family = require("app.models.family.Family")

			local fbId,roomId = Family:getFamilyMapIdAndRoomId()

			local map = Family:getFamilyMap()

			if MapIsEmpty(map) then
				return
			end
			
			-- 播放进入地图动画
			local entryMapLayer = MainControllLayer:getLayer("EntryMapLayer")
			entryMapLayer:maxZ()
			entryMapLayer:setCenterText("你走到师傅面前")
			entryMapLayer:show()

			self:delayFunc(1,
			function(obj)
				local mapLayer = MainControllLayer:getLayer("MapLayer")
				map:setCallBackAndConnect(function()
					mapLayer:setMap(map)
		
					entryMapLayer:hide(EMPTY_FUNC)

					if Map:getMapVersionByMapId(map.id) == EDITOR_MAP_VERSION and map._isComingIn ~= true then
                        map:refreshBranchEvent()
					end
					
                    map._isComingIn = true
				end)
				
				-- 释放地图动画层
				MainControllLayer:removeLayer("EntryMapLayer")
				
				MainControllLayer:pushLayer("MapLayer")
				MessageCenter:notify("EnterMap",{map=map})

				mapLayer:teleportRoom(roomId)
			end)
		end
	end)
end

-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2018/01/26 14:54:24
-- @desc tip
function TitleUI:setTipFunc(func)
	func = Helper:getDef(func,function()
		self.Image_7:setVisible(true)
	end)
	self.Panel_tips:releaseFunc(function()
		self.Image_7:setVisible(false)
		func(function()
			self.Image_7:setVisible(true)
		end)
	end)
end

local ANIM_Time = 0.05 * 60
local imagePath = "Image/UI/MainUI/denglong.png"
local imagePathAn = "Image/UI/MainUI/denglongan.png"
--self.flag  1 当前显示高亮图片，2当前显示暗图片
--小灯笼的动画
function TitleUI:setLanternAnimation()
	self.canAnima = Helper:getDef(self.canAnima,true)
	if self.canAnima == true then
		local animation = cc.Sequence:create(cc.CallFunc:create(function()
			self.canAnima = false
		end),cc.FadeTo:create(ANIM_Time/2,0),
			cc.FadeTo:create(ANIM_Time/2,255),
			cc.CallFunc:create(function()
				self.canAnima = true
		end))
		self.Image_left:runActionWithName("left",animation)
		local anim = cc.Sequence:create(cc.CallFunc:create(function()
			self.canAnima = false
		end),cc.FadeTo:create(ANIM_Time/2,0),
			cc.FadeTo:create(ANIM_Time/2,255),
			cc.CallFunc:create(function()
				self.canAnima = true
		end)) 
		self.Image_right:runActionWithName("right",anim)



		-- local animation = cc.Sequence:create(cc.CallFunc:create(function()
		-- 	self.canAnima = false
		-- end),cc.FadeTo:create(ANIM_Time/2,125),cc.CallFunc:create(function()
		-- 	if self.flag == 1 then
		-- 		self.Image_right:loadTexture(imagePathAn)
		-- 		self.flag = 2

		-- 	else
		-- 		self.Image_right:loadTexture(imagePath)
		-- 		self.flag = 1
		-- 	end
		-- end),cc.FadeTo:create(ANIM_Time/2,255),cc.CallFunc:create(function()
		-- 	self.canAnima = true
		-- end))
		-- self.Image_right:runActionWithName("right",animation)

	end
end

function TitleUI:setMapLayerToSelfCreatedSkillMenuUIFunc(func)
	self.mapLayerToSelfCreatedSkillMenuUIFunc = func
end

function TitleUI:doMapLayerToSelfCreatedSkillMenuUIFunc()
	if self.mapLayerToSelfCreatedSkillMenuUIFunc and type(self.mapLayerToSelfCreatedSkillMenuUIFunc) == "function" then
		self.mapLayerToSelfCreatedSkillMenuUIFunc(self)
	end
end

function TitleUI:setAnecdoteVisible(visible)
	self.Text_anecdote:setVisible(Helper:getDef(visible,false))
end

function TitleUI:setAnecdoteText(text)
	self.Text_anecdote:setString(Helper:getDef(text,""))
end

function TitleUI:setImageRuleFunc(func)
	self.Image_rule:releaseFunc(function()
		if func then
			func()
		end
	end)
end

function TitleUI:setCustomButton(name,func)
	self.Text_Custom:setString(name)
	self.Text_Custom:setVisible(true)
	self.Text_Custom:releaseFunc(function()
		if func then
			func()
		end
	end)
end

return TitleUI0