-- 界面控制器,用来控制界面切换
local LogSystem = require("app.models.LogSystem.LogSystem")
local MainLayer = require("app.views.layer.MainLayer")
local WaitingLayer = require("app.views.layer.PopLayer.WaitingLayer")
local Record = require("app.models.Record.Record")
local SyncWebTime = require("app.models.syncWebTime.SyncWebTime")

local ControllLayer = class("ControllLayer", require("app.views.base.ControllLayer"))

local layers = {
    --
    TitleLayer = "app.views.ui.TitleUI",
    PrintLayer = "app.views.ui.PrintUI",
    MainLayer = "app.views.layer.MainLayer",
    --任务
    TaskLayer = "app.views.layer.TaskLayer.TaskLayer",
    ZhuDongTaskLayer = "app.views.layer.TaskLayer.ZhuDongTaskLayer",
    MainTaskPresenter = "app.presenters.Tasks.MainTaskPresenter",
    --属性
    AttrLayer = "app.views.layer.AttrLayer.AttrControllLayer",
    --师门
    TeacherLayer = "app.views.layer.TeacherLayer.TeacherLayer",
    SelectTeacherLayer_type = "app.views.layer.TeacherLayer.SelectTeacherLayer",
    SelectTeacherLayer_family = "app.views.layer.TeacherLayer.SelectTeacherLayer",
    SkillInfoLayer = "app.views.layer.SkillLayer.SkillInfoLayer",
    SkillPrepareLayer = "app.views.layer.SkillLayer.SkillPrepareLayer",
    --@desc 武学突破
    SkillBreakThroughPresent = "app.presenters.SkillBreakThrough.SkillBreakThroughPresent",
    --@desc 主动技能突破
    ZhaoBreakThroughPresent = "app.presenters.SkillBreakThrough.ZhaoBreakThroughPresent",
    --师门任务
    ReceiveTeacherTaskLayer = "app.views.layer.TeacherTaskLayer.ReceiveTeacherTaskLayer",
    AppointRecordTeacherTaskLayer = "app.views.layer.TeacherTaskLayer.AppointRecordTeacherTaskLayer",
    TeacherTaskDetailsLayer = "app.views.layer.TeacherTaskLayer.TeacherTaskDetailsLayer",
    ActiveZhaoPrepareLayer = "app.views.layer.SkillLayer.ActiveZhaoPrepareLayer",
    ShiMenQingGuiLayer = "app.views.layer.TeacherTaskLayer.ShiMenQingGuiLayer",
    -- 菜单
    MenuLayer = "app.views.layer.MenuLayer.MenuLayer",
    -- 联机游戏
    OnlineGameLayer = "src.app.views.layer.OnlineGame.OnlineGameLayer",
    -- 副本, 地图
    EntryMapLayer = "app.views.layer.MapLayer.EntryMapLayer",
    SelectMapLayer = "app.views.layer.MapLayer.SelectMapLayer",
    SelectMapDetailLayer = "app.views.layer.MapLayer.SelectMapDetailLayer",
    MapLayer = "app.views.layer.MapLayer.MapLayer",
    TotalMapLayer = "app.views.layer.MapLayer.TotalMapLayer",
    MapRoleLayer = "app.views.layer.MapLayer.MapRoleLayer",
    -- 新的副本层
    NewMapLayer = "app.views.layer.MapLayer.NewMapLayer",
    NewMapRoleLayer = "app.views.layer.MapLayer.NewMapRoleLayer",
    InheritMapRoleLayer = "app.views.layer.MapLayer.InheritMapRoleLayer",
    --@desc 新的副本进入界面
    SelectMapMenuPresenter = "app.presenters.Map.SelectMapMenuPresenter",
    JiangHuAnecdotePresenter = "app.presenters.ChallengeMap.JiangHuAnecdotePresenter",
    -- 商城
    -- 设置界面
    SetupLayer = "app.views.ui.SetupUI",
    SetupLayerInMenuLayer = "app.views.ui.SetupUIInMenuLayer",
    -- 社区界面
    -- CommunityLayer = "app.views.layer.CommunityLayer.CommunityLayer",
    --神兵界面
    ShenBingLayer = "app.views.layer.ShenBingLayer.NewShenBingLayer",
    -- NewShenBingLayer = "app.views.layer.ShenBingLayer.NewShenBingLayer",
    ShenBingObserveLayer = "app.views.layer.ShenBingLayer.ShenBingObserveLayer",
    DaZuo = "app.views.layer.ShenBingLayer.DaZao",
    ShenBingSkilledLayer = "app.views.layer.ShenBingLayer.ShenBingSkilledLayer",
    XuanBingDong = "app.views.layer.ShenBingLayer.XuanBingDongLayer",
    XuanBingDongOld = "app.views.layer.ShenBingLayer.XuanBingDongOld",
    CangYiGe = "app.views.layer.ShenBingLayer.CangYiGe",
    CangYiGeOld = "app.views.layer.ShenBingLayer.CangYiGeOld",
    ShenBingInfo = "app.views.layer.ShenBingLayer.ShenBingInfo",
    --新神兵界面
    ShenBingMainObserveLayer = "app.views.layer.ShenBingLayer.DuanZao.ShenBingMainObserveLayer",
    FurnaceLayer = "app.views.layer.ShenBingLayer.DuanZao.FurnaceLayer",
    ShenBingCuiLianLayer = "app.views.layer.ShenBingLayer.DuanZao.ShenBingCuiLianLayer",
    ShenBingRongLianLayer = "app.views.layer.ShenBingLayer.DuanZao.ShenBingRongLianLayer",
    --比武界面
    BiWuStartLayer = "app.views.layer.BiWuLayer.BiWuStartLayer",
    BiWuMainLayer = "app.views.layer.BiWuLayer.BiWuMainLayer",
    BiWuWatchLayer = "app.views.layer.BiWuLayer.BiWuWatchLayer",
    BiWuExitLayer = "app.views.layer.BiWuLayer.BiWuExitLayer",
    -- 活动界面
    ActionLayer = "app.views.layer.ActionLayer.ActionLayer",
    -- 商城
    StoreLayer = "app.views.layer.StoreLayer.StoreLayer",
    --传承
    InheritLayer = "app.views.layer.InheritLayer.InheritLayer",
    InheritAttrLayer = "app.views.layer.InheritLayer.InheritAttrLayer",
    -- 调试界面
    DebugLayer = "app.views.layer.DebugLayer.DebugLayer",
    -- @author LiJie 增加排行的切入切出动画
    RankingLayer = "app.views.ui.RankingUI.RankingUI",
    -- @author LiJie    @time 2016/11/26 11:43:09
    BagLayer = "app.views.ui.AttrUI.BagUI",
    TableLayer = "app.views.ui.AttrUI.TableUI",
    -- 经脉
    QuietRoomLayer = "app.views.layer.MeridianLayer.QuietRoomLayer",
    MeridianBreakLayer = "app.views.layer.MeridianLayer.MeridianBreakLayer",
    --中秋答题问卷
    QSLayer = "app.views.layer.QALayer.QSLayer",
    UserEquipItemLayer = "app.views.layer.HomelandLayer.FurnitureLayer.UserEquipItemLayer",
    UserArmorItemLayer = "app.views.layer.HomelandLayer.FurnitureLayer.UserArmorItemLayer",
    FamilyGroupRankLayer = "app.views.layer.TeacherLayer.FamilyGroupRankLayer",
    TuJianMenuLayer = "app.views.layer.TuJianLayer.TuJianMenuLayer",
    TuJianInFoLayer = "app.views.layer.TuJianLayer.TuJianInFoLayer",
    DreamTalentLayer = "app.views.layer.DreamWorldLayer.DreamTalentLayer",
    SelfCreatedSkillMenuUI = "app.views.ui.SelfCreatedSkillUI.SelfCreatedSkillMenuUI",
    -- 拳脚系统
    FistFootMenuPresenter = "app.presenters.FistFoot.FistFootMenuPresenter",
    FistFootTaskPresenter = "app.presenters.FistFoot.FistFootTaskPresenter",
    FistFootGuaJiPresenter = "app.presenters.FistFoot.FistFootGuaJiPresenter",
    ActiveSkillPrepareUI = "app.views.ui.SkillUI.ActiveSkillPrepareUI",
    TechniquePresenter = "app.presenters.FistFoot.TechniquePresenter",
    TalentPagePresenter = "app.presenters.FistFoot.TalentPagePresenter",
    ComprehendCharacterPresenter = "app.presenters.FistFoot.ComprehendCharacterPresenter",
    CharacterInfoPresenter = "app.presenters.FistFoot.CharacterInfoPresenter",
    --家园仆人对练相关
    ActiveZhaoPracticePresenter = "app.presenters.ActiveZhaoPractice.ActiveZhaoPracticePresenter",
    GiftPagePresenter = "app.presenters.ActiveZhaoPractice.GiftPagePresenter",
    ForgetPagePresenter = "app.presenters.ActiveZhaoPractice.ForgetPagePresenter",
    --师门建设

    TeacherBuildMenuPresenter = "app.presenters.TeacherBuild.TeacherBuildMenuPresenter",
    TeacherBuildTaskPresenter = "app.presenters.TeacherBuild.TeacherBuildTaskPresenter",
    TeacherBuildGuaJiPresenter = "app.presenters.TeacherBuild.TeacherBuildGuaJiPresenter",
    TeacherBuildListPresenter = "app.presenters.TeacherBuild.TeacherBuildListPresenter",
    TeacherBuildInfoPresenter = "app.presenters.TeacherBuild.TeacherBuildInfoPresenter",
    TeacherBuildDonatePresenter = "app.presenters.TeacherBuild.TeacherBuildDonatePresenter",
    TeacherFeatPresenter = "app.presenters.TeacherBuild.TeacherFeatPresenter",
    TeacherFeatClassPresenter = "app.presenters.TeacherBuild.TeacherFeatClassPresenter",
    TeacherGuidancePresenter = "app.presenters.TeacherBuild.TeacherGuidancePresenter",
    MeridianImprintingPresenter = "app.presenters.Meridian.MeridianImprintingPresenter",
    HiddenMeridianMenuPresenter = "app.presenters.Meridian.HiddenMeridian.HiddenMeridianMenuPresenter"
}

local switchs = {
    ["显示标题和输出栏"] = {
        animAftFunc = function(self)
            if PRINT_MODE == 1 then
                print("MenuLayerMainLayer animAftFunc")
            end
            local layer = self:getLayer("TitleLayer")
            layer:setLocalZOrder(10)
            layer:show(true)

            local layer = self:getLayer("PrintLayer")
            layer:setLocalZOrder(10)
            layer:show()
        end
    },
    ["隐藏标题和输出栏"] = {
        animAftFunc = function(self)
            if PRINT_MODE == 1 then
                print("MenuLayerMainLayer animAftFunc")
            end
            local layer = self:getLayer("TitleLayer")
            layer:setLocalZOrder(10)
            layer:hide(true)

            local layer = self:getLayer("PrintLayer")
            layer:setLocalZOrder(10)
            layer:hide()
        end
    },
    ["显示标题和输出栏并刷新界面"] = {
        animAftFunc = function(self)
            if PRINT_MODE == 1 then
                print("MenuLayerMainLayer animAftFunc")
            end
            local layer = self:getLayer("TitleLayer")
            layer:setLocalZOrder(10)
            layer:show(true)

            local layer = self:getLayer("PrintLayer")
            layer:setLocalZOrder(10)
            layer:show()
            local TeacherTaskLayer = self:getLayer("TeacherTaskLayer")
            TeacherTaskLayer:initLayer()
        end
    },
    -----------------------------------------------------------------------------------------------------------
    -- @author LiJie
    -- @time 2016/11/15 16:55:02
    -- @desc 显示标题和栏目的时候播放动画
    ["执行动画并显示标题和输出栏"] = {
        animAftFunc = function(self)
            if PRINT_MODE == 1 then
                print("MenuLayerMainLayer animAftFunc")
            end
            local layer = self:getLayer("TitleLayer")
            layer:setLocalZOrder(10)
            layer:show(true)

            local layer = self:getLayer("PrintLayer")
            layer:setLocalZOrder(10)
            layer:show(true)
        end
    },
    -- @author LiJie  先播放动画再进入界面
    ["先执行动画再隐藏标题和输出栏"] = {
        animPreFunc = function(self)
            if PRINT_MODE == 1 then
                print("MenuLayerMainLayer animPreFunc")
            end
            local layer = self:getLayer("TitleLayer")
            layer:setLocalZOrder(10)
            layer:hide(true)

            local layer = self:getLayer("PrintLayer")
            layer:setLocalZOrder(10)
            layer:hide(true)
        end
    },
    ["反向动画"] = {animDirection = -1},
    ["透明度动画"] = {animType = "fadeAnim"},
    ["显示标题并隐藏输出栏"] = {
        animAftFunc = function(self)
            if PRINT_MODE == 1 then
                print("MenuLayerMainLayer animAftFunc")
            end
            local layer = self:getLayer("TitleLayer")
            layer:setLocalZOrder(10)
            layer:show(true)

            local layer = self:getLayer("PrintLayer")
            layer:setLocalZOrder(0)
            layer:hide()
        end
    },
    -- @author LiJie  先播放动画。在进入界面
    ["先执行动画再显示标题并隐藏输出栏"] = {
        animPreFunc = function(self)
            if PRINT_MODE == 1 then
                print("MenuLayerMainLayer animPreFunc")
            end
            local layer = self:getLayer("TitleLayer")
            layer:setLocalZOrder(10)
            layer:show(true)

            local layer = self:getLayer("PrintLayer")
            layer:setLocalZOrder(0)
            layer:hide(true)
        end
    },
    -- 不显示标题，只显示输出栏
    ["隐藏标题显示输出栏"] = {
        animAftFunc = function(self)
            if PRINT_MODE == 1 then
                print("MenuLayerMainLayer animAftFunc")
            end
            local layer = self:getLayer("TitleLayer")
            layer:setLocalZOrder(10)
            layer:hide(true)

            local layer = self:getLayer("PrintLayer")
            layer:setLocalZOrder(10)
            layer:show(true)
        end
    },
    ["隐藏标题并显示输出栏"] = {
        animAftFunc = function(self)
            if PRINT_MODE == 1 then
                print("MenuLayerMainLayer animAftFunc")
            end
            local layer = self:getLayer("TitleLayer")
            layer:setLocalZOrder(0)
            layer:hide()

            local layer = self:getLayer("PrintLayer")
            layer:setLocalZOrder(10)
            layer:show()
        end
    },
    -- 菜单
    MenuLayer = "隐藏标题和输出栏",
    MenuLayerMainLayer = {"显示标题和输出栏"},
    -- 主界面
    MainLayer = "显示标题和输出栏",
    MainLayerMenuLayer = "隐藏标题和输出栏",
    MainLayerActionLayer = "隐藏标题和输出栏",
    ActionLayerMainLayer = "显示标题和输出栏",
    MainLayerSelectMapMenuPresenter = "先执行动画再显示标题并隐藏输出栏",
    SelectMapMenuPresenterMainLayer = "执行动画并显示标题和输出栏",
    SelectMapMenuPresenterSelectMapLayer = {
        animAftFunc = function(self)
            local layer = self:getLayer("TitleLayer")
            layer:setLocalZOrder(10)
            layer:show(true)
            layer:setTitleJHBack()

            local layer = self:getLayer("PrintLayer")
            layer:setLocalZOrder(10)
            layer:show()
            Audio:playMusic("jiangHuJieMian2", true)
        end,
        animDirection = -1
    },
    MainLayerSelectMapLayer = {
        animAftFunc = function(self)
            local layer = self:getLayer("TitleLayer")
            layer:setLocalZOrder(10)
            layer:show(true)
            layer.Button_back:setVisible(false)
            layer:setTitleJHBack()

            local layer = self:getLayer("PrintLayer")
            layer:setLocalZOrder(10)
            layer:show()
            Audio:playMusic("jiangHuJieMian2", true)
        end,
        animDirection = -1
    },
    SelectMapLayerMainLayer = {
        animPreFunc = function(self)
            local layer = self:getLayer("TitleLayer")
            layer.Button_back_JH:setVisible(false)
        end,
        animAftFunc = function(self)
            local layer = self:getLayer("TitleLayer")
            layer:setLocalZOrder(10)
            layer:show()

            local layer = self:getLayer("PrintLayer")
            layer:show()
            layer:setLocalZOrder(10)
            Audio:stopMusic()
        end
    },
    SelectMapLayerSelectMapMenuPresenter = {
        animPreFunc = function(self)
            local layer = self:getLayer("TitleLayer")
            layer:setLocalZOrder(10)
            layer:show(true)

            local layer = self:getLayer("PrintLayer")
            layer:setLocalZOrder(10)
            layer:hide(true)
        end,
        animAftFunc = function(self)
            Audio:stopMusic()
        end
    },
    SelectMapMenuPresenterJiangHuAnecdotePresenter = {
        animAftFunc = function(self)
            local layer = self:getLayer("TitleLayer")
            layer:setAnecdoteVisible(true)
            layer:setLocalZOrder(10)
            layer:show(true)

            local layer = self:getLayer("PrintLayer")
            layer:setLocalZOrder(0)
            layer:hide()
        end
    },
    JiangHuAnecdotePresenterSelectMapMenuPresenter = {
        animPreFunc = function(self)
            local layer = self:getLayer("TitleLayer")
            layer:setAnecdoteVisible(false)
        end,
        animAftFunc = function(self)
            local layer = self:getLayer("TitleLayer")
            layer:setLocalZOrder(10)
            layer:show(true)

            local layer = self:getLayer("PrintLayer")
            layer:setLocalZOrder(0)
            layer:hide()
        end
    },
    NewMapLayerSelectMapMenuPresenter = {
        animPreFunc = function(self)
            local layer = self:getLayer("TitleLayer")
            layer:setLocalZOrder(10)
            layer:show(true)

            local layer = self:getLayer("PrintLayer")
            layer:setLocalZOrder(0)
            layer:hide(true)
        end
    },
    DebugLayerWinAgainstLayer = {"透明度动画"},
    WinAgainstLayerDebugLayer = {"透明度动画"},
    TeacherLayerTeacherTaskLayer = {
        animPreFunc = function(self)
            local layer = self:getLayer("TitleLayer")
            layer.Button_back_JH:setVisible(false)
        end,
        animAftFunc = function(self)
            if PRINT_MODE == 1 then
                print("MenuLayerMainLayer animAftFunc")
            end
            local layer = self:getLayer("TitleLayer")
            layer:setLocalZOrder(10)

            local layer = self:getLayer("PrintLayer")
            layer:show()
            layer:setLocalZOrder(10)
            Audio:stopMusic()
        end
    },
    SelectMapLayerTeacherTaskLayer = {"显示标题和输出栏并刷新界面", "反向动画"},
    TeacherTaskLayerSelectMapLayer = {
        animAftFunc = function(self)
            if PRINT_MODE == 1 then
                print("MenuLayerMainLayer animAftFunc")
            end
            local layer = self:getLayer("TitleLayer")
            layer:setLocalZOrder(10)
            layer:show(true)
            layer.Button_back:setVisible(false)
            layer:setTitleJHBack()

            local layer = self:getLayer("PrintLayer")
            layer:setLocalZOrder(10)
            layer:show()
            Audio:playMusic("jiangHuJieMian2", true)
        end,
        animDirection = -1
    },
    TeacherTaskLayerReceiveTeacherTaskLayer = {
        animPreFunc = function(self)
            local layer = self:getLayer("TitleLayer")
            layer.Button_back_JH:setVisible(false)
        end,
        animAftFunc = function(self)
            if PRINT_MODE == 1 then
                print("MenuLayerMainLayer animAftFunc")
            end
            local layer = self:getLayer("TitleLayer")
            layer:setLocalZOrder(10)

            local layer = self:getLayer("PrintLayer")
            layer:show()
            layer:setLocalZOrder(10)
            Audio:stopMusic()
        end
    },
    TeacherTaskLayerShiMenQingGuiLayer = {
        animPreFunc = function(self)
            local layer = self:getLayer("TitleLayer")
            layer.Button_back_JH:setVisible(false)
        end,
        animAftFunc = function(self)
            if PRINT_MODE == 1 then
                print("MenuLayerMainLayer animAftFunc")
            end
            local layer = self:getLayer("TitleLayer")
            layer:setLocalZOrder(10)

            local layer = self:getLayer("PrintLayer")
            layer:show()
            layer:setLocalZOrder(10)
            Audio:stopMusic()
        end
    },
    TeacherTaskLayerAppointRecordTeacherTaskLayer = {
        animPreFunc = function(self)
            local layer = self:getLayer("TitleLayer")
            layer.Button_back_JH:setVisible(false)
        end,
        animAftFunc = function(self)
            if PRINT_MODE == 1 then
                print("MenuLayerMainLayer animAftFunc")
            end
            local layer = self:getLayer("TitleLayer")
            layer:setLocalZOrder(10)

            local layer = self:getLayer("PrintLayer")
            layer:show()
            layer:setLocalZOrder(10)
            Audio:stopMusic()
        end
    },
    AppointRecordTeacherTaskLayerTeacherTaskLayer = {"显示标题和输出栏", "反向动画"},
    ShiMenQingGuiLayerTeacherTaskLayer = {"显示标题和输出栏", "反向动画"},
    MapLayerTeacherTaskDetailsLayer = {"显示标题和输出栏", "反向动画"},
    MapLayerTeacherTaskLayer = {"显示标题和输出栏并刷新界面", "反向动画"},
    MainLayerSelectTeacherLayer_type = {"显示标题和输出栏"},
    JiuChouMapLayerBiWuMainLayer = {
        animAftFunc = function(self)
            if PRINT_MODE == 1 then
                print("MenuLayerMainLayer animAftFunc")
            end
            local MapRoleLayer = self:getLayer("MapRoleLayer")
            MapRoleLayer:hide(true)
            MapRoleLayer:setVisible(false)

            local layer = self:getLayer("PrintLayer")
            -- layer:setLocalZOrder(10)
            layer:hide()
            Audio:stopMusic()
        end
    },
    BiWuMainLayerJiuChouMapLayer = {
        animAftFunc = function(self)
            if PRINT_MODE == 1 then
                print("MenuLayerMainLayer animAftFunc")
            end
            local MapRoleLayer = self:getLayer("MapRoleLayer")
            MapRoleLayer:show()
            MapRoleLayer:onResume()
            MapRoleLayer:maxZ()
            local jiuChouMapLayer = self:getLayer("JiuChouMapLayer")
            -- MapRoleLayer:setTitle(jiuChouMapLayer._currRoom.name)
            jiuChouMapLayer:replaceRoom("fb202_05")
            MapRoleLayer:exitButtonFunc(
                false,
                function()
                    MapRoleLayer:hide(true)
                    MapRoleLayer:setVisible(false)
                    jiuChouMapLayer:leaveMap()
                    jiuChouMapLayer.ControllLayer:popLayer()
                end
            )
            Audio:stopMusic()
        end
    },
    JiuChouGroupLayerJiuChouMapLayer = {
        animAftFunc = function(self)
            if PRINT_MODE == 1 then
                print("MenuLayerMainLayer animAftFunc")
            end
            local MapRoleLayer = self:getLayer("MapRoleLayer")
            MapRoleLayer:show()
            MapRoleLayer:onResume()
            MapRoleLayer:maxZ()
            local jiuChouMapLayer = self:getLayer("JiuChouMapLayer")
            -- MapRoleLayer:setTitle(jiuChouMapLayer._currRoom.name)
            jiuChouMapLayer:replaceRoom("fb202_14")
            MapRoleLayer:exitButtonFunc(
                false,
                function()
                    MapRoleLayer:hide(true)
                    MapRoleLayer:setVisible(false)
                    jiuChouMapLayer:leaveMap()
                    jiuChouMapLayer.ControllLayer:popLayer()
                end
            )
            Audio:stopMusic()
        end
    },
    JiuChouMapLayerJiuChouGroupLayer = {
        animAftFunc = function(self)
            if PRINT_MODE == 1 then
                print("MenuLayerMainLayer animAftFunc")
            end
            local layer = self:getLayer("TitleLayer")
            layer:setLocalZOrder(10)
            layer:hide()
            local MapRoleLayer = self:getLayer("MapRoleLayer")
            MapRoleLayer:hide()
            MapRoleLayer:setVisible(false)
            local layer = self:getLayer("PrintLayer")
            layer:setLocalZOrder(10)
            layer:hide()
        end
    },
    AppointRecordTeacherTaskLayerTeacherTaskLayer = {"显示标题和输出栏", "反向动画"},
    ShiMenQingGuiLayerTeacherTaskLayer = {"显示标题和输出栏", "反向动画"},
    MapLayerTeacherTaskDetailsLayer = {"显示标题和输出栏", "反向动画"},
    MapLayerTeacherTaskLayer = {"显示标题和输出栏并刷新界面", "反向动画"},
    MainLayerTaskLayer = {"显示标题和输出栏"},
    MainLayerSelectTeacherLayer_type = {"显示标题和输出栏"},
    -----------------------------------------------------------------------------------------------------------
    -- @author LiJie
    -- @time 2016/11/15 15:34:32
    -- @desc  增加进入师门的动画
    MainLayerTeacherLayer = {"显示标题和输出栏"},
    -- --@desc 武学突破相关
    SkillBreakThroughPresentSkillInfoLayer = {
        animDuration = 0.3,
        animPreFunc = function(self)
            local layer = self:getLayer("TitleLayer")
            layer:setLocalZOrder(10)
            layer:setButton_setup()
            layer:setSetUpButtonName("设置")
        end,
        animAftFunc = function(self)
            local layer = self:getLayer("TitleLayer")
            layer:setTextTitle("我的技能")
        end
    },
    MapLayerBiWuMainLayer = {
        animAftFunc = function(self)
            if PRINT_MODE == 1 then
                print("MenuLayerMainLayer animAftFunc")
            end
            local MapRoleLayer = self:getLayer("MapRoleLayer")
            MapRoleLayer:show()
            MapRoleLayer:onResume()
            MapRoleLayer:maxZ()

            -- local layer = self:getLayer("PrintLayer")
            -- layer:setLocalZOrder(10)
            -- layer:show()
            local layer = self:getLayer("PrintLayer")
            layer:setLocalZOrder(0)
            layer:hide(true)
            Audio:stopMusic()
        end
    },
    -- 副本
    SelectMapLayerMapLayer = {
        animAftFunc = function(self)
            if PRINT_MODE == 1 then
                print("MenuLayerMainLayer animAftFunc")
            end

            local layer = self:getLayer("TitleLayer")
            layer:setLocalZOrder(10)
            layer:hide(true)

            local MapRoleLayer = self:getLayer("MapRoleLayer")
            MapRoleLayer:show()
            MapRoleLayer:onResume()
            MapRoleLayer:maxZ()
            local layer = self:getLayer("PrintLayer")
            layer:setLocalZOrder(10)
            layer:show()
            Audio:stopMusic()
        end
    },
    MapLayerSelectMapLayer = {
        animPreFunc = function(self)
            if PRINT_MODE == 1 then
                print(" MenuLayerMainLayeranimPreFunc")
            end
            local layer = self:getLayer("TitleLayer")
            layer:setTitleJHBack()
            layer:setLocalZOrder(10)
            layer:show(true)
        end,
        animAftFunc = function(self)
            self:getLayer("PrintLayer"):show()
            self:getLayer("MapRoleLayer"):setVisible(false)
            Audio:playMusic("jiangHuJieMian2", true)
        end
    },
    JiangHuAnecdotePresenterNewMapLayer = {
        animPreFunc = function(self)
            local layer = self:getLayer("TitleLayer")
            layer:setAnecdoteVisible(false)
        end,
        animAftFunc = function(self)
            Audio:stopMusic()
        end
    },
    NewMapLayerJiangHuAnecdotePresenter = {
        animPreFunc = function(self)
            local layer = self:getLayer("TitleLayer")
            layer:setAnecdoteVisible(true)
            layer:setLocalZOrder(10)
            layer:show(true)

            local layer = self:getLayer("PrintLayer")
            layer:setLocalZOrder(0)
            layer:hide(true)
        end
    },
    DebugLayerNewMapLayer = {
        animAftFunc = function(self)
            Audio:stopMusic()
        end
    },
    NewMapLayerDebugLayer = "先执行动画再显示标题并隐藏输出栏",
    MapLayerDebugLayer = {
        animPreFunc = function(self)
            if PRINT_MODE == 1 then
                print(" MenuLayerMainLayeranimPreFunc")
            end
            local layer = self:getLayer("TitleLayer")
            layer:setLocalZOrder(10)
            layer:show(true)

            local layer = self:getLayer("PrintLayer")
            layer:setLocalZOrder(10)
            layer:hide(true)
        end
    },
    MapLayerSetupLayer = {
        "显示标题并隐藏输出栏",
        {
            animAftFunc = function(self)
                self:getLayer("MapRoleLayer"):setVisible(false)
                -- Audio:playMusic("jiangHuJieMian2", true)
                local layer = self:getLayer("TitleLayer")
                layer:setLocalZOrder(10)
                layer:show(true)

                local layer = self:getLayer("PrintLayer")
                layer:setLocalZOrder(10)
                layer:hide(true)
            end
        }
    },
    MapLayerMainLayer = {
        animPreFunc = function(self)
            local layer = self:getLayer("TitleLayer")
            layer.Button_back_JH:setVisible(false)
        end,
        animAftFunc = function(self)
            if PRINT_MODE == 1 then
                print("MenuLayerMainLayer animAftFunc")
            end
            local layer = self:getLayer("TitleLayer")
            layer:setLocalZOrder(10)
            layer:show()
        end
    },
    MainLayerMapLayer = {
        animPreFunc = function(self)
            Audio:stopMusic()
        end,
        animAftFunc = function(self)
            if PRINT_MODE == 1 then
                print("MenuLayerMainLayer animAftFunc")
            end

            local layer = self:getLayer("TitleLayer")
            layer:setLocalZOrder(10)
            layer:hide(true)

            local MapRoleLayer = self:getLayer("MapRoleLayer")
            MapRoleLayer:show()
            MapRoleLayer:onResume()

            MapRoleLayer:maxZ()

            local layer = self:getLayer("PrintLayer")
            layer:setLocalZOrder(10)
            layer:show()
        end
    },
    AttrLayerMapLayer = {
        animAftFunc = function(self)
            if PRINT_MODE == 1 then
                print("MenuLayerMainLayer animAftFunc")
            end

            local layer = self:getLayer("TitleLayer")
            layer:setLocalZOrder(10)
            layer:hide(true)

            local MapRoleLayer = self:getLayer("MapRoleLayer")
            MapRoleLayer:show()
            MapRoleLayer:onResume()

            MapRoleLayer:maxZ()

            local layer = self:getLayer("PrintLayer")
            layer:setLocalZOrder(10)
            layer:show()
            Audio:stopMusic()
        end
    },
    SetupLayerMapLayer = {
        animAftFunc = function(self)
            if PRINT_MODE == 1 then
                print("MenuLayerMainLayer animAftFunc")
            end

            local layer = self:getLayer("TitleLayer")
            layer:setLocalZOrder(10)
            layer:hide(true)

            local MapRoleLayer = self:getLayer("MapRoleLayer")
            MapRoleLayer:show()

            MapRoleLayer:maxZ()

            local layer = self:getLayer("PrintLayer")
            layer:setLocalZOrder(10)
            layer:show()
            Audio:stopMusic()
        end
    },
    SelectMapLayerAttrLayer = {
        animAftFunc = function(self)
            if PRINT_MODE == 1 then
                print("MenuLayerMainLayer animAftFunc")
            end
            local layer = self:getLayer("TitleLayer")
            layer:setLocalZOrder(10)
            layer:show(true)

            local layer = self:getLayer("PrintLayer")
            layer:setLocalZOrder(10)
            layer:show()

            local layer = self:getLayer("AttrLayer")

            local maxn = #layer._layerStack
            local fromLayerName = layer._layerStack[maxn]
            Audio:stopMusic()
            -- if fromLayerName and fromLayerName == "BagLayer" then
            -- 	layer:getLayer("BagLayer"):showItemList()
            -- 	layer:getLayer("BagLayer"):showcangkuItem()
            -- end
        end
    },
    MainLayerAttrLayer = {
        animDuration = 0.3,
        animPreFunc = function(self)
        end,
        animAftFunc = function(self)
            local layer = self:getLayer("AttrLayer")

            local maxn = #layer._layerStack
            local fromLayerName = layer._layerStack[maxn]
            -- if fromLayerName and fromLayerName == "BagLayer" then
            -- 	layer:getLayer("BagLayer"):showItemList()
            -- 	layer:getLayer("BagLayer"):showcangkuItem()
            -- end
        end
    },
    SkillInfoLayerAttrLayer = {
        animDuration = 0.3,
        animPreFunc = function(self)
        end,
        animAftFunc = function(self)
            local layer = self:getLayer("TitleLayer")
            layer:setTextTitle("属性")
        end
    },
    SkillPrepareLayerSkillInfoLayer = {
        animDuration = 0.3,
        animPreFunc = function(self)
        end,
        animAftFunc = function(self)
            local layer = self:getLayer("TitleLayer")
            layer:setTextTitle("我的技能")
            layer:setSetUpButtonName()
            layer:setButton_setup()

            local skillInfoLayer = self:getLayer("SkillInfoLayer")
            skillInfoLayer:setSkillList()
        end
    },
    SkillInfoLayerTeacherLayer = {
        animDuration = 0.3,
        animPreFunc = function(self)
        end,
        animAftFunc = function(self)
            local layer = self:getLayer("TitleLayer")
        end
    },
    -- 任务属性界面
    AttrLayerMainLayer = {
        animDirection = -1,
        animPreFunc = function(self)
			self:getLayer("AttrLayer"):hideBagLayer()

            local layer = self:getLayer("TitleLayer")
            layer:setLocalZOrder(10)
            layer:show(true)

            local layer = self:getLayer("PrintLayer")
            layer:setLocalZOrder(10)
            layer:show()
        end
    },
    AttrLayerSelectMapLayer = {
        animAftFunc = function(self)
            if PRINT_MODE == 1 then
                print("MenuLayerMainLayer animAftFunc")
            end
            local layer = self:getLayer("TitleLayer")
            layer:setLocalZOrder(10)
            layer:show(true)
            layer:setTitleJHBack()
            local layer = self:getLayer("PrintLayer")
            layer:setLocalZOrder(10)
            layer:show()
            Audio:playMusic("jiangHuJieMian2", true)
        end,
        animDirection = -1
    },
    -- 玄兵古洞到悬兵洞
    ShenBingLayerXuanBingDong = {
        animPreFunc = function(self)
            if PRINT_MODE == 1 then
                print("ShenBingLayerXuanBingDong animPreFunc")
            end
            local layer = self:getLayer("TitleLayer")
            layer:setLocalZOrder(10)
            layer:setSetUpButtonName("武藏榜")
            layer:setButton_setupFunc(
                function()
                    Account:getEmail(
                        function(eventName, errmsg, email, isBind, isLogout)
                            if eventName == "有邮箱" and isBind == true then
                                -- isBind 为true的时候 才是已绑定邮箱
                                if User:getRole():getFlag("锻造状态") == "空闲" or User:getRole():getFlag("锻造状态") == 0 then
                                    PopupLayerController:showLayer(
                                        "ShenBingRankLayer",
                                        function(layer)
                                            layer:showLayer(8)
                                        end
                                    )
                                else
                                    PopText("你正在做别的事情，请稍候")
                                end
                            else
                                PopText("请先返回主界面，并点击右上角设置，绑定您的邮箱")
                                return
                            end
                        end
                    )
                end
            )
            layer:show(true)

            local layer = self:getLayer("PrintLayer")
            layer:setLocalZOrder(10)
            layer:hide()
        end,
        animDirection = -1
    },
    --悬兵洞到玄兵古洞
    XuanBingDongShenBingLayer = {
        animPreFunc = function(self)
            if PRINT_MODE == 1 then
                print("MenuLayerMainLayer animAftFunc")
            end
            local layer = self:getLayer("TitleLayer")
            layer:setLocalZOrder(10)
            layer:setSetUpButtonName("神兵榜")
            layer:setButton_setupFunc(
                function()
                    Account:getEmail(
                        function(eventName, errmsg, email, isBind, isLogout)
                            if eventName == "有邮箱" and isBind == true then
                                -- isBind 为true的时候 才是已绑定邮箱
                                if User:getRole():getFlag("锻造状态") == "空闲" or User:getRole():getFlag("锻造状态") == 0 then
                                    PopupLayerController:showLayer(
                                        "ShenBingRankLayer",
                                        function(layer)
                                            layer:showLayer(9)
                                        end
                                    )
                                else
                                    PopText("你正在做别的事情，请稍候")
                                end
                            else
                                PopText("请先返回主界面，并点击右上角设置，绑定您的邮箱")
                                return
                            end
                        end
                    )
                end
            )
            layer:show(true)

            local layer = self:getLayer("PrintLayer")
            layer:setLocalZOrder(10)
            layer:hide()
        end,
        animDirection = -1
    },
    ShenBingLayerXuanBingDongOld = {
        animPreFunc = function(self)
            if PRINT_MODE == 1 then
                print("ShenBingLayerXuanBingDongOld animPreFunc")
            end
            local layer = self:getLayer("TitleLayer")
            layer:setLocalZOrder(10)
            layer:setSetUpButtonName("武藏榜")
            layer:setButton_setupFunc(
                function()
                    Account:getEmail(
                        function(eventName, errmsg, email, isBind, isLogout)
                            if eventName == "有邮箱" and isBind == true then
                                -- isBind 为true的时候 才是已绑定邮箱
                                if User:getRole():getFlag("锻造状态") == "空闲" or User:getRole():getFlag("锻造状态") == 0 then
                                    PopupLayerController:showLayer(
                                        "ShenBingRankLayer",
                                        function(layer)
                                            layer:showLayer(8)
                                        end
                                    )
                                else
                                    PopText("你正在做别的事情，请稍候")
                                end
                            else
                                PopText("请先返回主界面，并点击右上角设置，绑定您的邮箱")
                                return
                            end
                        end
                    )
                end
            )
            layer:show(true)

            local layer = self:getLayer("PrintLayer")
            layer:setLocalZOrder(10)
            layer:hide()
        end,
        animDirection = -1
    },
    XuanBingDongOldShenBingLayer = {
        animPreFunc = function(self)
            if PRINT_MODE == 1 then
                print("MenuLayerMainLayer animAftFunc")
            end
            local layer = self:getLayer("TitleLayer")
            layer:setLocalZOrder(10)
            layer:setSetUpButtonName("神兵榜")
            layer:setButton_setupFunc(
                function()
                    Account:getEmail(
                        function(eventName, errmsg, email, isBind, isLogout)
                            if eventName == "有邮箱" and isBind == true then
                                -- isBind 为true的时候 才是已绑定邮箱
                                if User:getRole():getFlag("锻造状态") == "空闲" or User:getRole():getFlag("锻造状态") == 0 then
                                    PopupLayerController:showLayer(
                                        "ShenBingRankLayer",
                                        function(layer)
                                            layer:showLayer(9)
                                        end
                                    )
                                else
                                    PopText("你正在做别的事情，请稍候")
                                end
                            else
                                PopText("请先返回主界面，并点击右上角设置，绑定您的邮箱")
                                return
                            end
                        end
                    )
                end
            )
            layer:show(true)

            local layer = self:getLayer("PrintLayer")
            layer:setLocalZOrder(10)
            layer:hide()
        end,
        animDirection = -1
    },
    XuanBingDongMapLayer = {
        animPreFunc = function(self)
            if PRINT_MODE == 1 then
                print("MenuLayerMainLayer animAftFunc")
            end

            local layer = self:getLayer("TitleLayer")
            layer:setLocalZOrder(10)
            layer:setButton_setup()
            layer:setSetUpButtonName("设置")
            layer:show(true)

            local MapRoleLayer = self:getLayer("MapRoleLayer")
            MapRoleLayer:setVisible(true)
            MapRoleLayer:show(true)

            local layer = self:getLayer("PrintLayer")
            layer:setLocalZOrder(10)
            layer:show(true)
        end,
        animDirection = -1
    },
    MapLayerXuanBingDong = {
        animPreFunc = function(self)
            if PRINT_MODE == 1 then
                print("MenuLayerMainLayer animAftFunc")
            end

            local MapRoleLayer = self:getLayer("MapRoleLayer")
            MapRoleLayer:hide(true)
            MapRoleLayer:setVisible(false)

            local layer = self:getLayer("TitleLayer")
            layer:setLocalZOrder(10)
            layer:setSetUpButtonName("武藏榜")
            layer:setButton_setupFunc(
                function()
                    PopupLayerController:showLayer(
                        "ShenBingRankLayer",
                        function(layer)
                            layer:showLayer(8)
                        end
                    )
                end
            )
            layer:show(true)

            local layer = self:getLayer("PrintLayer")
            layer:setLocalZOrder(10)
            layer:hide()
        end,
        animDirection = -1
    },
    CangYiGeMapLayer = {
        animPreFunc = function(self)
            if PRINT_MODE == 1 then
                print("MenuLayerMainLayer animAftFunc")
            end

            local layer = self:getLayer("TitleLayer")
            layer:setLocalZOrder(10)
            layer:setButton_setup()
            layer:setSetUpButtonName("设置")
            layer:show(true)

            local MapRoleLayer = self:getLayer("MapRoleLayer")
            MapRoleLayer:setVisible(true)
            MapRoleLayer:show(true)

            local layer = self:getLayer("PrintLayer")
            layer:setLocalZOrder(10)
            layer:show(true)
        end,
        animDirection = -1
    },
    MapLayerCangYiGe = {
        animPreFunc = function(self)
            if PRINT_MODE == 1 then
                print("MenuLayerMainLayer animAftFunc")
            end

            local MapRoleLayer = self:getLayer("MapRoleLayer")
            MapRoleLayer:hide(true)
            MapRoleLayer:setVisible(false)

            local layer = self:getLayer("TitleLayer")
            layer:setLocalZOrder(10)
            layer:setSetUpButtonName("武藏榜")
            layer:setButton_setupFunc(
                function()
                    PopupLayerController:showLayer(
                        "ShenBingRankLayer",
                        function(layer)
                            layer:showLayer(8)
                        end
                    )
                end
            )
            layer:show(true)

            local layer = self:getLayer("PrintLayer")
            layer:setLocalZOrder(10)
            layer:hide()
        end,
        animDirection = -1
    },
    UserEquipItemLayerMapLayer = {
        animPreFunc = function(self)
            if PRINT_MODE == 1 then
                print("MenuLayerMainLayer animAftFunc")
            end

            local layer = self:getLayer("TitleLayer")
            layer:setLocalZOrder(10)
            layer:setButton_setup()
            layer:setSetUpButtonName("设置")
            layer:show(true)

            local MapRoleLayer = self:getLayer("MapRoleLayer")
            MapRoleLayer:setVisible(true)
            MapRoleLayer:show(true)

            local layer = self:getLayer("PrintLayer")
            layer:setLocalZOrder(10)
            layer:show(true)
        end,
        animDirection = -1
    },
    MapLayerUserEquipItemLayer = {
        animPreFunc = function(self)
            if PRINT_MODE == 1 then
                print("MenuLayerMainLayer animAftFunc")
            end

            local MapRoleLayer = self:getLayer("MapRoleLayer")
            MapRoleLayer:hide(true)
            MapRoleLayer:setVisible(false)

            local layer = self:getLayer("TitleLayer")
            layer:setLocalZOrder(10)
            layer:setSetUpButtonName("武藏榜")
            layer:setButton_setupFunc(
                function()
                    PopupLayerController:showLayer(
                        "ShenBingRankLayer",
                        function(layer)
                            layer:showLayer(8)
                        end
                    )
                end
            )
            layer:show(true)

            local layer = self:getLayer("PrintLayer")
            layer:setLocalZOrder(10)
            layer:hide()
        end,
        animDirection = -1
    },
    UserArmorItemLayerMapLayer = {
        animPreFunc = function(self)
            if PRINT_MODE == 1 then
                print("MenuLayerMainLayer animAftFunc")
            end

            local layer = self:getLayer("TitleLayer")
            layer:setLocalZOrder(10)
            layer:setButton_setup()
            layer:setSetUpButtonName("设置")
            layer:show(true)

            local MapRoleLayer = self:getLayer("MapRoleLayer")
            MapRoleLayer:setVisible(true)
            MapRoleLayer:show(true)

            local layer = self:getLayer("PrintLayer")
            layer:setLocalZOrder(10)
            layer:show(true)
        end,
        animDirection = -1
    },
    MapLayerUserArmorItemLayer = {
        animPreFunc = function(self)
            if PRINT_MODE == 1 then
                print("MenuLayerMainLayer animAftFunc")
            end

            local MapRoleLayer = self:getLayer("MapRoleLayer")
            MapRoleLayer:hide(true)
            MapRoleLayer:setVisible(false)

            local layer = self:getLayer("TitleLayer")
            layer:setLocalZOrder(10)
            layer:setSetUpButtonName("武藏榜")
            layer:setButton_setupFunc(
                function()
                    PopupLayerController:showLayer(
                        "ShenBingRankLayer",
                        function(layer)
                            layer:showLayer(8)
                        end
                    )
                end
            )
            layer:show(true)

            local layer = self:getLayer("PrintLayer")
            layer:setLocalZOrder(10)
            layer:hide()
        end,
        animDirection = -1
    },
    --玄兵古洞到锻造页面
    ShenBingLayerFurnaceLayer = {
        animPreFunc = function(self)
            if PRINT_MODE == 1 then
                print("MenuLayerMainLayer animAftFunc")
            end
            local layer = self:getLayer("TitleLayer")
            layer:setLocalZOrder(10)
            layer:setSetUpButtonName("已学技艺")
            layer:setButton_setupFunc(
                function()
                    if User:getRole():getFlag("锻造状态") == "空闲" or User:getRole():getFlag("锻造状态") == 0 then
                        MainControllLayer:pushLayer("ShenBingSkilledLayer")
                        local ShenBingSkilledLayer = MainControllLayer:getLayer("ShenBingSkilledLayer")
                        ShenBingSkilledLayer:show()
                    else
                        PopText("你正在做别的事情，请稍候")
                    end
                end
            )
            layer:show(true)

            local layer = self:getLayer("PrintLayer")
            layer:setLocalZOrder(10)
            layer:hide()
        end,
        animDirection = -1
    },
    --副本到锻造页面
    MapLayerFurnaceLayer = {
        animPreFunc = function(self)
            if PRINT_MODE == 1 then
                print("MenuLayerMainLayer animAftFunc")
            end
            local MapRoleLayer = self:getLayer("MapRoleLayer")
            MapRoleLayer:hide(true)
            MapRoleLayer:setVisible(false)
            local layer = self:getLayer("TitleLayer")
            layer:setLocalZOrder(10)
            layer:setSetUpButtonName("已学技艺")
            layer:setButton_setupFunc(
                function()
                    if User:getRole():getFlag("锻造状态") == "空闲" or User:getRole():getFlag("锻造状态") == 0 then
                        User:getRole():setFlag("PVP活动状态", "忙碌")
                        MainControllLayer:pushLayer("ShenBingSkilledLayer")
                        local ShenBingSkilledLayer = MainControllLayer:getLayer("ShenBingSkilledLayer")
                        ShenBingSkilledLayer:show()
                    else
                        PopText("你正在做别的事情，请稍候")
                    end
                end
            )
            layer:show(true)

            local layer = self:getLayer("PrintLayer")
            layer:setLocalZOrder(10)
            layer:hide()
        end,
        animDirection = -1
    },
    --锻造页面到副本页面
    FurnaceLayerMapLayer = {
        animAftFunc = function(self)
            User:getRole():setFlag("PVP活动状态", "空闲中")
            if PRINT_MODE == 1 then
                print("MenuLayerMainLayer animAftFunc")
            end
            local MapRoleLayer = self:getLayer("MapRoleLayer")
            MapRoleLayer:show()
            MapRoleLayer:onResume()
            MapRoleLayer:maxZ()
            local layer = self:getLayer("TitleLayer")
            layer:hide(true)
            layer:setSetUpButtonName("设置")
            layer:setButton_setup()
            local layer = self:getLayer("PrintLayer")
            layer:setLocalZOrder(10)
            layer:show()
            Audio:resumeMusic()
        end
    },
    --锻造页面到玄兵古洞
    FurnaceLayerShenBingLayer = {
        animPreFunc = function(self)
            if PRINT_MODE == 1 then
                print("MenuLayerMainLayer animAftFunc")
            end
            local layer = self:getLayer("TitleLayer")
            layer:setLocalZOrder(10)
            layer:setSetUpButtonName("神兵榜")
            layer:setButton_setupFunc(
                function()
                    Account:getEmail(
                        function(eventName, errmsg, email, isBind, isLogout)
                            if eventName == "有邮箱" and isBind == true then
                                -- isBind 为true的时候 才是已绑定邮箱
                                if User:getRole():getFlag("锻造状态") == "空闲" or User:getRole():getFlag("锻造状态") == 0 then
                                    PopupLayerController:showLayer(
                                        "ShenBingRankLayer",
                                        function(layer)
                                            layer:showLayer(9)
                                        end
                                    )
                                else
                                    PopText("你正在做别的事情，请稍候")
                                end
                            else
                                PopText("请先返回主界面，并点击右上角设置，绑定您的邮箱")
                                return
                            end
                        end
                    )
                end
            )
            layer:show(true)

            local layer = self:getLayer("PrintLayer")
            layer:setLocalZOrder(10)
            layer:hide()
        end,
        animDirection = -1
    },
    --玄兵古洞到藏衣阁
    ShenBingLayerCangYiGe = {
        animPreFunc = function(self)
            if PRINT_MODE == 1 then
                print("MenuLayerMainLayer animAftFunc")
            end
            local layer = self:getLayer("TitleLayer")
            layer:setLocalZOrder(10)
            layer:setSetUpButtonName("武藏榜")
            layer:setButton_setupFunc(
                function()
                    Account:getEmail(
                        function(eventName, errmsg, email, isBind, isLogout)
                            if eventName == "有邮箱" and isBind == true then
                                -- isBind 为true的时候 才是已绑定邮箱
                                if User:getRole():getFlag("锻造状态") == "空闲" or User:getRole():getFlag("锻造状态") == 0 then
                                    PopupLayerController:showLayer(
                                        "ShenBingRankLayer",
                                        function(layer)
                                            layer:showLayer(8)
                                        end
                                    )
                                else
                                    PopText("你正在做别的事情，请稍候")
                                end
                            else
                                PopText("请先返回主界面，并点击右上角设置，绑定您的邮箱")
                                return
                            end
                        end
                    )
                end
            )
            layer:show(true)

            local layer = self:getLayer("PrintLayer")
            layer:setLocalZOrder(10)
            layer:hide()
        end,
        animDirection = -1
    },
    ShenBingLayerCangYiGeOld = {
        animPreFunc = function(self)
            if PRINT_MODE == 1 then
                print("ShenBingLayerCangYiGeOld animAftFunc")
            end
            local layer = self:getLayer("TitleLayer")
            layer:setLocalZOrder(10)
            layer:setSetUpButtonName("武藏榜")
            layer:setButton_setupFunc(
                function()
                    Account:getEmail(
                        function(eventName, errmsg, email, isBind, isLogout)
                            if eventName == "有邮箱" and isBind == true then
                                -- isBind 为true的时候 才是已绑定邮箱
                                if User:getRole():getFlag("锻造状态") == "空闲" or User:getRole():getFlag("锻造状态") == 0 then
                                    PopupLayerController:showLayer(
                                        "ShenBingRankLayer",
                                        function(layer)
                                            layer:showLayer(8)
                                        end
                                    )
                                else
                                    PopText("你正在做别的事情，请稍候")
                                end
                            else
                                PopText("请先返回主界面，并点击右上角设置，绑定您的邮箱")
                                return
                            end
                        end
                    )
                end
            )
            layer:show(true)

            local layer = self:getLayer("PrintLayer")
            layer:setLocalZOrder(10)
            layer:hide()
        end,
        animDirection = -1
    },
    --藏衣阁到玄兵古洞
    CangYiGeShenBingLayer = {
        animPreFunc = function(self)
            if PRINT_MODE == 1 then
                print("MenuLayerMainLayer animAftFunc")
            end
            local layer = self:getLayer("TitleLayer")
            layer:setLocalZOrder(10)
            layer:setSetUpButtonName("神兵榜")
            layer:setButton_setupFunc(
                function()
                    Account:getEmail(
                        function(eventName, errmsg, email, isBind, isLogout)
                            if eventName == "有邮箱" and isBind == true then
                                -- isBind 为true的时候 才是已绑定邮箱
                                if User:getRole():getFlag("锻造状态") == "空闲" or User:getRole():getFlag("锻造状态") == 0 then
                                    PopupLayerController:showLayer(
                                        "ShenBingRankLayer",
                                        function(layer)
                                            layer:showLayer(9)
                                        end
                                    )
                                else
                                    PopText("你正在做别的事情，请稍候")
                                end
                            else
                                PopText("请先返回主界面，并点击右上角设置，绑定您的邮箱")
                                return
                            end
                        end
                    )
                end
            )
            layer:show(true)

            local layer = self:getLayer("PrintLayer")
            layer:setLocalZOrder(10)
            layer:hide()
        end,
        animDirection = -1
    },
    CangYiGeOldShenBingLayer = {
        animPreFunc = function(self)
            if PRINT_MODE == 1 then
                print("CangYiGeOldShenBingLayer animAftFunc")
            end
            local layer = self:getLayer("TitleLayer")
            layer:setLocalZOrder(10)
            layer:setSetUpButtonName("神兵榜")
            layer:setButton_setupFunc(
                function()
                    Account:getEmail(
                        function(eventName, errmsg, email, isBind, isLogout)
                            if eventName == "有邮箱" and isBind == true then
                                -- isBind 为true的时候 才是已绑定邮箱
                                if User:getRole():getFlag("锻造状态") == "空闲" or User:getRole():getFlag("锻造状态") == 0 then
                                    PopupLayerController:showLayer(
                                        "ShenBingRankLayer",
                                        function(layer)
                                            layer:showLayer(9)
                                        end
                                    )
                                else
                                    PopText("你正在做别的事情，请稍候")
                                end
                            else
                                PopText("请先返回主界面，并点击右上角设置，绑定您的邮箱")
                                return
                            end
                        end
                    )
                end
            )
            layer:show(true)

            local layer = self:getLayer("PrintLayer")
            layer:setLocalZOrder(10)
            layer:hide()
        end,
        animDirection = -1
    },
    --主界面到玄兵古洞
    MainLayerShenBingLayer = {
        animPreFunc = function(self)
            if PRINT_MODE == 1 then
                print("MenuLayerMainLayer animAftFunc")
            end
            local layer = self:getLayer("TitleLayer")
            layer:setLocalZOrder(10)
            layer:setSetUpButtonName("神兵榜")
            layer:setButton_setupFunc(
                function()
                    Account:getEmail(
                        function(eventName, errmsg, email, isBind, isLogout)
                            if eventName == "有邮箱" and isBind == true then
                                -- isBind 为true的时候 才是已绑定邮箱
                                if User:getRole():getFlag("锻造状态") == "空闲" or User:getRole():getFlag("锻造状态") == 0 then
                                    PopupLayerController:showLayer(
                                        "ShenBingRankLayer",
                                        function(layer)
                                            layer:showLayer(9)
                                        end
                                    )
                                else
                                    PopText("你正在做别的事情，请稍候")
                                end
                            else
                                PopText("请先返回主界面，并点击右上角设置，绑定您的邮箱")
                                return
                            end
                        end
                    )
                end
            )
            layer:show(true)

            local layer = self:getLayer("PrintLayer")
            layer:setLocalZOrder(10)
            layer:hide(true)
            -- Audio:playMusic("jiangHuJieMian2", true)
        end,
        animDirection = -1
    },
    --玄兵古洞到主界面
    ShenBingLayerMainLayer = {
        animPreFunc = function(self)
            if PRINT_MODE == 1 then
                print("MenuLayerMainLayer animAftFunc")
            end
            local layer = self:getLayer("TitleLayer")
            layer:setLocalZOrder(10)
            layer:setButton_setup()
            layer:setSetUpButtonName("设置")
            layer:show(true)

            local layer = self:getLayer("PrintLayer")
            layer:setLocalZOrder(10)
            layer:show(true)
        end,
        animDirection = -1
    },
    -- 背包界面 - 副本
    MapLayerAttrLayer = {"显示标题和输出栏", "反向动画"},
    -- 任务界面
    -- TaskLayerMainLayer = {"显示标题和输出栏", "反向动画"},
    -- MainLayerTaskLayer = {"隐藏标题显示输出栏", "反向动画"},
    ZhuDongTaskLayerMainLayer = {"显示标题和输出栏", "反向动画"},
    MainLayerZhuDongTaskLayer = {
        animAftFunc = function(self)
            -- local layer = self:getLayer("TitleLayer")
            -- layer:setLocalZOrder(1)
            -- layer:hide()
            -- layer.Button_back:setVisible(false)
            -- layer:setTitleJHBack()

            local layer = self:getLayer("PrintLayer")
            layer:setLocalZOrder(10)
            layer:show()
            Audio:playMusic("jiangHuJieMian2", true)
        end,
        "反向动画"
    },
    MainTaskPresenterMainLayer = {"显示标题和输出栏", "反向动画"},
    MainLayerMainTaskPresenter = {
        animAftFunc = function(self)
            -- local layer = self:getLayer("TitleLayer")
            -- layer:setLocalZOrder(1)
            -- layer:hide()
            -- layer.Button_back:setVisible(false)
            -- layer:setTitleJHBack()

            local layer = self:getLayer("PrintLayer")
            layer:setLocalZOrder(10)
            layer:show()
        end
    },
    MainTaskPresenterDebugLayer = {"显示标题和输出栏", "反向动画"},
    DebugLayerMainTaskPresenter = {"显示标题并隐藏输出栏", "反向动画"},
    -- TaskLayer
    ActionLayerSelectMapLayer = {
        animAftFunc = function(self)
            if PRINT_MODE == 1 then
                print("MenuLayerMainLayer animAftFunc")
            end
            local layer = self:getLayer("TitleLayer")
            layer:setLocalZOrder(10)
            layer:show(true)
            layer.Button_back:setVisible(false)
            layer:setTitleJHBack()

            local layer = self:getLayer("PrintLayer")
            layer:setLocalZOrder(10)
            layer:show()
            Audio:playMusic("jiangHuJieMian2", true)
        end,
        animDirection = -1
    },
    SelectMapLayerActionLayer = "隐藏标题和输出栏",
    MainTaskPresenterSelectMapLayer = {
        animAftFunc = function(self)
            if PRINT_MODE == 1 then
                print("MenuLayerMainLayer animAftFunc")
            end
            local layer = self:getLayer("TitleLayer")
            layer:setLocalZOrder(10)
            -- layer:hide(true)
            layer.Button_back:setVisible(false)
            layer:setTitleJHBack()

            local layer = self:getLayer("PrintLayer")
            layer:setLocalZOrder(10)
            layer:show()
            Audio:playMusic("jiangHuJieMian2", true)
        end,
        animDirection = -1
    },
    -- SelectMapLayerTaskLayer =
    SelectMapLayerMainTaskPresenter = {
        animAftFunc = function(self)
            if PRINT_MODE == 1 then
                print("MenuLayerMainLayer animAftFunc")
            end
            local layer = self:getLayer("TitleLayer")
            layer.Button_back_JH:setVisible(false)
            layer:setLocalZOrder(10)

            local layer = self:getLayer("PrintLayer")
            layer:setLocalZOrder(10)
            layer:show()
            Audio:stopMusic()
        end
    },
    StoreLayerActionLayer = {
        animPreFunc = function(self)
            if PRINT_MODE == 1 then
                print("MenuLayerMainLayer animAftFunc")
            end
        end,
        animDirection = -1
    },
    MainTaskPresenterMapLayer = {
        animAftFunc = function(self)
            if PRINT_MODE == 1 then
                print("MenuLayerMainLayer animAftFunc")
            end

            local layer = self:getLayer("TitleLayer")
            layer:setLocalZOrder(10)
            layer:hide(true)

            local MapRoleLayer = self:getLayer("MapRoleLayer")
            MapRoleLayer:show()
            MapRoleLayer:onResume()
            MapRoleLayer:maxZ()
            local layer = self:getLayer("PrintLayer")
            layer:setLocalZOrder(10)
            layer:show()
            Audio:stopMusic()
        end
    },
    -- MainTaskPresenterMapLayer = {"隐藏标题并显示输出栏"},
    MapLayerMainTaskPresenter = {"显示标题和输出栏"},
    -- MapLayerTaskLayer = {"显示标题和输出栏"},

    -- 师门
    SelectTeacherLayer_typeMainLayer = {"显示标题和输出栏", "反向动画"},
    SelectTeacherLayer_familySelectTeacherLayer_type = {"显示标题和输出栏", "反向动画"},
    --SkillInfoLayerTeacherLayer = {"显示标题和输出栏", "反向动画"},
    --SkillPrepareLayerSkillInfoLayer = {"显示标题和输出栏", "反向动画"},
    -- SkillPrepareLayerActiveZhaoPrepareLayer = {"显示标题并隐藏输出栏"},
    -- ActiveZhaoPrepareLayerSkillPrepareLayer = {animDirection = - 1},

    TeacherLayerMainLayer = {"显示标题和输出栏", "反向动画"},
    SetupLayerMainLayer = {"显示标题和输出栏", "反向动画"},
    MainLayerSetupLayer = {"显示标题并隐藏输出栏"},
    -- 历史公告 - 设置 - 主界面 - 开始界面
    -- SetupLayerCommunityLayer = {"显示标题并隐藏输出栏"},
    -- CommunityLayerSetupLayer = {"显示标题并隐藏输出栏", {animDirection = -1}},
    -- MainLayerCommunityLayer = {"显示标题并隐藏输出栏"},
    -- CommunityLayerMainLayer = {"显示标题和输出栏", {animDirection = -1}},
    MenuLayerSetupLayer = {"显示标题并隐藏输出栏"},
    SetupLayerMenuLayer = {"隐藏标题和输出栏", {animDirection = -1}},
    MenuLayerSetupLayerInMenuLayer = {{animType = "MoveAnim"}, "显示标题并隐藏输出栏"},
    SetupLayerInMenuLayerMenuLayer = {"隐藏标题和输出栏", {animType = "MoveAnim", animDirection = -1}},
    -- 活动界面
    DebugLayerActionLayer = {"先执行动画再隐藏标题和输出栏", {animType = "fadeAnim"}},
    ActionLayerDebugLayer = {"显示标题并隐藏输出栏", {animDirection = -1, animType = "fadeAnim"}},
    -- 商城
    MainLayerStoreLayer = {"先执行动画再隐藏标题和输出栏", {animType = "fadeAnim"}},
    StoreLayerMainLayer = {"执行动画并显示标题和输出栏", {animDirection = -1, animType = "fadeAnim"}},
    ActionLayerStoreLayer = {"隐藏标题和输出栏", {animDirection = -1, animType = "MoveAndFadeAnim"}},
    MainLayerJingXiuLayer = {"显示标题和输出栏", "反向动画"},
    JingXiuLayerMainLayer = {"显示标题和输出栏"},
    ShenBingLayerShenBingSkilledLayer = {"先执行动画再显示标题并隐藏输出栏"},
    BingMainLayerrMainLayer = {"执行动画并显示标题和输出栏", "反向动画"},
    --比武界面
    BiWuStartLayerBiWuMainLayer = {"隐藏标题和输出栏"},
    BiWuMainLayerBiWuWatchLayer = {"隐藏标题和输出栏"},
    BiWuWatchLayerBiWuMainLayer = {"隐藏标题和输出栏", "反向动画"},
    BiWuMainLayerBiWuExitLayer = {"隐藏标题和输出栏", "透明度动画"},
    BiWuExitLayerBiWuMainLayer = {"隐藏标题和输出栏", "反向动画"},
    BiWuWatchLayerBiWuExitLayer = {"隐藏标题和输出栏", "反向动画"},
    --传承
    AttrLayerInheritLayer = {"显示标题和输出栏"},
    InheritLayerAttrLayer = {"显示标题和输出栏", "反向动画"},
    AttrLayerInheritAttrLayer = {"显示标题和输出栏"},
    InheritAttrLayerAttrLayer = {"显示标题和输出栏", "反向动画"},
    InheritLayerInheritAttrLayer = {"显示标题和输出栏"},
    -- 经脉
    MainLayerQuietRoomLayer = {"显示标题并隐藏输出栏"},
    QuietRoomLayerMainLayer = {"显示标题和输出栏", "反向动画"},
    QuietRoomLayerMeridianBreakLayer = {"显示标题并隐藏输出栏"},
    MeridianBreakLayerQuietRoomLayer = {"显示标题并隐藏输出栏", "反向动画"},
    QuietRoomLayerMeridianImprintingPresenter = {"显示标题并隐藏输出栏"},
    MeridianImprintingPresenterQuietRoomLayer = {"显示标题并隐藏输出栏", "反向动画"},
    QuietRoomLayerHiddenMeridianMenuPresenter = {"显示标题并隐藏输出栏"},
    HiddenMeridianMenuPresenterQuietRoomLayer = {"显示标题并隐藏输出栏", "反向动画"},
    -- -- 社区
    -- MainLayerFightLayer =
    -- {
    -- 	animAftFunc = function(self)
    -- 		local layer = self:getLayer("TitleLayer")
    -- 		layer:show(true)
    --
    -- 		local layer = self:getLayer("PrintLayer")
    -- 		layer:hide(true)
    -- 	end,
    -- 	animDirection = -1
    -- },
    -- FightLayerMainLayer =
    -- {
    -- 	animAftFunc = function(self)
    -- 		local layer = self:getLayer("TitleLayer")
    -- 		layer:setLocalZOrder(10)
    --
    -- 		local layer = self:getLayer("PrintLayer")
    -- 		layer:show(true)
    -- 		layer:setLocalZOrder(10)
    -- 	end
    -- },
    -- 测试层 add by TangJian 2016/11/08 16:16:16
    MainLayerDebugLayer = {"显示标题并隐藏输出栏", "反向动画"},
    DebugLayerMainLayer = {"显示标题和输出栏"},
    -- @author LiJie  增加排行的切入切出动画
    MainLayerRankingLayer = {"先执行动画再隐藏标题和输出栏"},
    RankingLayerMainLayer = {"执行动画并显示标题和输出栏", "反向动画"},
    -- @author LiJie    @time 2016/11/26 11:32:05
    MainLayerBookBoxLayer = {"显示标题和输出栏"},
    BookBoxLayerMainLayer = {"显示标题和输出栏", "反向动画"},
    TestLayer = {"显示标题和输出栏"},
    -- JiuChouMapLayerJiuChouLeiTaiLayer = "显示标题和输出栏",
    -- JiuChouLeiTaiLayerJiuChouMapLayer = "显示标题并隐藏输出栏",
    JiuChouLeiTaiLayerJiuChouGroupLayer = {"隐藏标题和输出栏"},
    JiuChouMapLayerDebugLayer = {"显示标题并隐藏输出栏"},
    DebugLayerJiuChouMapLayer = {"隐藏标题和输出栏"},
    DebugLayerQSLayer = {"隐藏标题和输出栏"},
    --内挂切入动画
    TaskLayerNeiGuaLayer = {
        animPreFunc = function(self)
            if PRINT_MODE == 1 then
                print("TaskLayerNeiGuaLayer animPreFunc")
            end
            local layer = self:getLayer("TitleLayer")
            layer:setLocalZOrder(10)
            layer:hide(true)
        end,
        animAftFunc = function(self)
            if PRINT_MODE == 1 then
                print("TaskLayerNeiGuaLayer animAftFunc")
            end

            local layer = self:getLayer("PrintLayer")
            layer:setLocalZOrder(10)
            layer:show()
        end
    },
    NeiGuaLayerTaskLayer = {"显示标题和输出栏"},
    -- MapLayerChineseValentineCheckListLayer = {"隐藏标题和输出栏"},
    -- ChineseValentineCheckListLayerMapLayer= {"显示标题和输出栏"}
    MainLayerJiuChouMapLayer = {
        animAftFunc = function(self)
            if PRINT_MODE == 1 then
                print("MenuLayerMainLayer animAftFunc")
            end
            local MapRoleLayer = self:getLayer("MapRoleLayer")
            MapRoleLayer:show()
            MapRoleLayer:onResume()
            MapRoleLayer:maxZ()

            local layer = self:getLayer("PrintLayer")
            layer:setLocalZOrder(10)
            layer:hide()
            Audio:stopMusic()
        end
    },
    JiuChouMapLayerMainLayer = {"显示标题和输出栏"},
    SkillInfoLayerMapLayer = {
        animDirection = -1,
        animAftFunc = function(self)
            if PRINT_MODE == 1 then
                print("MenuLayerMainLayer animAftFunc")
            end

            local layer = self:getLayer("TitleLayer")
            layer:setLocalZOrder(10)
            layer:hide(true)

            local MapRoleLayer = self:getLayer("MapRoleLayer")
            MapRoleLayer:show()
            MapRoleLayer:onResume()
            MapRoleLayer:maxZ()
        end
    },
    MapLayerSkillInfoLayer = {
        animPreFunc = function(self)
            local MapRoleLayer = self:getLayer("MapRoleLayer")
            MapRoleLayer:hide()
            MapRoleLayer:setVisible(false)

            local layer = self:getLayer("TitleLayer")
            layer.Button_back:setVisible(true)
            layer.Button_back_JH:setVisible(false)
        end,
        animAftFunc = function(self)
            local layer = self:getLayer("TitleLayer")
            layer:setLocalZOrder(10)
            layer:show(true)
        end
    },
    AttrLayerTuJianMenuLayer = {"显示标题并隐藏输出栏"},
    MapLayerDreamTalentLayer = {
        animPreFunc = function(self)
            local MapRoleLayer = self:getLayer("MapRoleLayer")
            MapRoleLayer:hide()
            MapRoleLayer:setVisible(false)

            local layer = self:getLayer("TitleLayer")
            layer.Button_back:setVisible(true)
            layer.Button_back_JH:setVisible(false)

            local printLayer = self:getLayer("PrintLayer")
            printLayer:setLocalZOrder(10)
            printLayer:hide()
        end,
        animAftFunc = function(self)
            local layer = self:getLayer("TitleLayer")
            layer:setLocalZOrder(10)
            layer:show(true)
        end
    },
    DreamTalentLayerMapLayer = {
        animDirection = -1,
        animAftFunc = function(self)
            local layer = self:getLayer("TitleLayer")
            layer:setLocalZOrder(10)
            layer:hide(true)

            local MapRoleLayer = self:getLayer("MapRoleLayer")
            MapRoleLayer:show()
            MapRoleLayer:onResume()
            MapRoleLayer:maxZ()

            local printLayer = self:getLayer("PrintLayer")
            printLayer:setLocalZOrder(10)
            printLayer:show()
        end
    },
    TuJianMenuLayerAttrLayer = {"显示标题和输出栏"},
    TuJianMenuLayerTuJianInFoLayer = {"显示标题并隐藏输出栏"},
    TuJianInFoLayerTuJianMenuLayer = {"显示标题并隐藏输出栏"},
    TeacherLayerFamilyGroupRankLayer = {"显示标题并隐藏输出栏"},
    FamilyGroupRankLayerTeacherLayer = {"显示标题和输出栏"},
    MapLayerFamilyGroupRankLayer = {
        animPreFunc = function(self)
            local MapRoleLayer = self:getLayer("MapRoleLayer")
            MapRoleLayer:hide()
            MapRoleLayer:setVisible(false)

            local layer = self:getLayer("PrintLayer")
            layer:setLocalZOrder(10)
            layer:hide(true)

            local layer = self:getLayer("TitleLayer")
            layer.Button_back:setVisible(true)
            layer.Button_back_JH:setVisible(false)
            layer:show(true)
        end
    },
    FamilyGroupRankLayerMapLayer = {
        animPreFunc = function(self)
            local MapRoleLayer = self:getLayer("MapRoleLayer")
            MapRoleLayer:show(true)
            MapRoleLayer:onResume()
            MapRoleLayer:maxZ()

            local layer = self:getLayer("PrintLayer")
            layer:setLocalZOrder(10)
            layer:show(true)

            local layer = self:getLayer("TitleLayer")
            layer:setLocalZOrder(10)
            layer:hide(true)
        end
    },
    TeacherLayerMapLayer = {
        animPreFunc = function(self)
            local layer = self:getLayer("TitleLayer")
            layer:setLocalZOrder(10)
            layer:hide(true)
            Audio:stopMusic()
        end,
        animAftFunc = function(self)
            if PRINT_MODE == 1 then
                print("MenuLayerMainLayer animAftFunc")
            end

            local MapRoleLayer = self:getLayer("MapRoleLayer")
            MapRoleLayer:show()
            MapRoleLayer:onResume()
            MapRoleLayer:maxZ()

            local layer = self:getLayer("PrintLayer")
            layer:setLocalZOrder(10)
            layer:initRichText()
            layer:show()
        end
    },
    MapLayerTeacherLayer = {
        animPreFunc = function(self)
            local MapRoleLayer = self:getLayer("MapRoleLayer")
            MapRoleLayer:hide()
            MapRoleLayer:setVisible(false)

            local layer = self:getLayer("PrintLayer")
            layer:setLocalZOrder(10)

            local layer = self:getLayer("TitleLayer")
            -- layer.Button_back:setVisible(true)
            -- layer.Button_back_JH:setVisible(false)
            layer:show(true)
        end
    },
    DebugLayerMapLayer = {
        animPreFunc = function(self)
            local layer = self:getLayer("TitleLayer")
            layer:setLocalZOrder(10)
            layer:hide(true)
            Audio:stopMusic()
        end,
        animAftFunc = function(self)
            if PRINT_MODE == 1 then
                print("MenuLayerMainLayer animAftFunc")
            end

            local MapRoleLayer = self:getLayer("MapRoleLayer")
            MapRoleLayer:show()
            MapRoleLayer:onResume()
            MapRoleLayer:maxZ()

            local layer = self:getLayer("PrintLayer")
            layer:setLocalZOrder(10)
            layer:show()
        end,
        MapLayerDebugLayer = {
            animPreFunc = function(self)
                local MapRoleLayer = self:getLayer("MapRoleLayer")
                MapRoleLayer:hide()
                MapRoleLayer:setVisible(false)
                local layer = self:getLayer("PrintLayer")
                layer:setLocalZOrder(10)

                local layer = self:getLayer("TitleLayer")
                -- layer.Button_back:setVisible(true)
                -- layer.Button_back_JH:setVisible(false)
                layer:show(true)
            end
        }
    },
    MainLayerSelfCreatedSkillMenuUI = {"显示标题和输出栏"},
    SelfCreatedSkillMenuUIMainLayer = {"显示标题和输出栏"},
    MapLayerSelfCreatedSkillMenuUI = {
        animPreFunc = function(self)
            local MapRoleLayer = self:getLayer("MapRoleLayer")
            MapRoleLayer:hide()
            MapRoleLayer:setVisible(false)

            local layer = self:getLayer("TitleLayer")
            layer.Button_back:setVisible(true)
            layer.Button_back_JH:setVisible(false)
            layer:show(true)

            local layer = self:getLayer("PrintLayer")
            layer:setLocalZOrder(10)
            layer:initRichText()
        end
    },
    SelfCreatedSkillMenuUIMapLayer = {
        animAftFunc = function(self)
            local layer = self:getLayer("TitleLayer")
            layer:doMapLayerToSelfCreatedSkillMenuUIFunc()
            layer:setLocalZOrder(10)
            layer:hide(true)

            local MapRoleLayer = self:getLayer("MapRoleLayer")
            MapRoleLayer:show()
            MapRoleLayer:onResume()

            MapRoleLayer:maxZ()

            local layer = self:getLayer("PrintLayer")
            layer:setLocalZOrder(10)
            layer:initRichText()
            layer:show()
        end
    },
    MainLayerFistFootMenuPresenter = {"显示标题并隐藏输出栏"},
    FistFootMenuPresenterMainLayer = {"显示标题和输出栏", "反向动画"},
    FistFootMenuPresenterFistFootTaskPresenter = {"显示标题并隐藏输出栏"},
    FistFootTaskPresenterFistFootMenuPresenter = {"显示标题并隐藏输出栏", "反向动画"},
    FistFootTaskPresenterFistFootGuaJiPresenter = {"显示标题并隐藏输出栏"},
    FistFootGuaJiPresenterFistFootTaskPresenter = {"显示标题并隐藏输出栏"},
    FistFootMenuPresenterFistFootGuaJiPresenter = {"显示标题并隐藏输出栏"},
    FistFootGuaJiPresenterFistFootMenuPresenter = {"显示标题并隐藏输出栏", "反向动画"},
    FistFootMenuPresenterTechniquePresenter = {"显示标题并隐藏输出栏"},
    TechniquePresenterFistFootMenuPresenter = {"显示标题并隐藏输出栏", "反向动画"},
    TechniquePresenterComprehendCharacterPresenter = {"显示标题并隐藏输出栏"},
    ComprehendCharacterPresenterTechniquePresenter = {"显示标题并隐藏输出栏", "反向动画"},
    ComprehendCharacterPresenterCharacterInfoPresenter = {"显示标题并隐藏输出栏"},
    CharacterInfoPresenterComprehendCharacterPresenter = {"显示标题并隐藏输出栏", "反向动画"},
    FistFootMenuPresenterTalentPagePresenter = {"显示标题并隐藏输出栏"},
    TalentPagePresenterFistFootMenuPresenter = {"显示标题并隐藏输出栏", "反向动画"},
    BiWuMainLayerBiWuStartLayer = {
        animAftFunc = function(self)
            local layer = self:getLayer("TitleLayer")
            layer:setLocalZOrder(10)
            layer:ButtonBack(
                function()
                    self:pushLayer("MainLayer")
                end
            )
            layer:show(true)

            local layer = self:getLayer("PrintLayer")
            layer:setLocalZOrder(0)
            layer:hide()
        end,
        animDirection = -1
    },
    SkillInfoLayerSkillPrepareLayer = {
        animDuration = 0.3,
        animPreFunc = function(self)
            local layer = self:getLayer("TitleLayer")
            layer:setSetUpButtonName("准备技能")
            layer:setSkillPrepSkillLayerSetupBtnVisible(true)
            layer:setButton_setupFunc(
                function()
                    MainControllLayer:pushLayer("ActiveSkillPrepareUI")
                    local activeSkillPrepareUI = MainControllLayer:getLayer("ActiveSkillPrepareUI")
                    local activeSkillPreparePresenter = require("app.presenters.ActiveSkillPrepare.ActiveSkillPreparePresenter"):create()
                    local activeSkillPrepare = require("app.models.ActiveSkillPrepare.ActiveSkillPrepare"):create()
                    activeSkillPrepare:setRole(User:getRole())
                    activeSkillPrepare:initialize()

                    activeSkillPreparePresenter:setOutput(activeSkillPrepareUI)
                    activeSkillPreparePresenter:setInput(activeSkillPrepare)

                    activeSkillPrepareUI:setInput(activeSkillPreparePresenter)
                    activeSkillPrepareUI:showLayer()
                end
            )
        end
    },
    SkillPrepareLayerMapLayer = {
        animDuration = 0.3,
        animPreFunc = function(self)
        end,
        animAftFunc = function(self)
            local layer = self:getLayer("TitleLayer")
            layer:setSetUpButtonName()
            layer:setButton_setup()
            layer:hide()

            local MapRoleLayer = self:getLayer("MapRoleLayer")
            MapRoleLayer:setVisible(true)
            MapRoleLayer:showPanelSkill()

            User:getRole():setFlag("PVP活动状态", "空闲中")
        end
    },
    SkillPrepareLayerNewMapLayer = {
        animDuration = 0.3,
        animPreFunc = function(self)
        end,
        animAftFunc = function(self)
            local layer = self:getLayer("TitleLayer")
            layer:setSetUpButtonName()
            layer:setButton_setup()
            layer:hide()

            local MapRoleLayer = self:getLayer("NewMapRoleLayer")
            MapRoleLayer:setVisible(true)
            MapRoleLayer:showPanelSkill()
        end
    },
    BiWuStartLayerMainLayer = {
        animAftFunc = function(self)
           	if PRINT_MODE == 1 then
				print("MenuLayerMainLayer animAftFunc")
			end
			local layer = self:getLayer("TitleLayer")
			layer:setLocalZOrder(10)
			layer:show(true)
			layer:setTitleBack()
			layer.Button_back:setVisible(false)
			
			local layer = self:getLayer("PrintLayer")
			layer:setLocalZOrder(10)
			layer:show(true)
        end,
        animDirection = -1
    },
    MapLayerActiveZhaoPracticePresenter = {
        animPreFunc = function(self)
            local MapRoleLayer = self:getLayer("MapRoleLayer")
            MapRoleLayer:hide()
            MapRoleLayer:setVisible(false)

            local layer = self:getLayer("TitleLayer")
            layer.Button_back:setVisible(true)
            layer.Button_back_JH:setVisible(false)
            layer:show(true)
        end
    },
    ActiveZhaoPracticePresenterMapLayer = {
        animAftFunc = function(self)
            local layer = self:getLayer("TitleLayer")
            layer:setLocalZOrder(10)
            layer:hide(true)

            local MapRoleLayer = self:getLayer("MapRoleLayer")
            MapRoleLayer:show()
            MapRoleLayer:onResume()
            MapRoleLayer:maxZ()
        end
    },
    MapLayerGiftPagePresenter = {
        animPreFunc = function(self)
            local MapRoleLayer = self:getLayer("MapRoleLayer")
            MapRoleLayer:hide()
            MapRoleLayer:setVisible(false)

            local layer = self:getLayer("TitleLayer")
            layer.Button_back:setVisible(true)
            layer.Button_back_JH:setVisible(false)
            layer:show(true)
        end
    },
    GiftPagePresenterMapLayer = {
        animAftFunc = function(self)
            local layer = self:getLayer("TitleLayer")
            layer:setLocalZOrder(10)
            layer:hide(true)

            local MapRoleLayer = self:getLayer("MapRoleLayer")
            MapRoleLayer:show()
            MapRoleLayer:onResume()
            MapRoleLayer:maxZ()
        end
    },
    GiftPagePresenterForgetPagePresenter = {"显示标题和输出栏"},
    ForgetPagePresenterGiftPagePresenter = {"显示标题和输出栏"},
    TeacherLayerTeacherBuildMenuPresenter = {"显示标题和输出栏"},
    TeacherBuildMenuPresenterTeacherLayer = {"显示标题和输出栏", "反向动画"},
    TeacherBuildMenuPresenterTeacherBuildTaskPresenter = {"显示标题并隐藏输出栏"},
    TeacherBuildTaskPresenterTeacherBuildMenuPresenter = {"显示标题和输出栏", "反向动画"},
    TeacherBuildMenuPresenterTeacherBuildGuaJiPresenter = {"显示标题并隐藏输出栏"},
    TeacherBuildGuaJiPresenterTeacherBuildMenuPresenter = {"显示标题和输出栏", "反向动画"},
    TeacherBuildTaskPresenterTeacherBuildGuaJiPresenter = {"显示标题并隐藏输出栏"},
    TeacherBuildGuaJiPresenterTeacherBuildTaskPresenter = {"显示标题并隐藏输出栏"},
    TeacherBuildMenuPresenterTeacherBuildListPresenter = {"显示标题并隐藏输出栏"},
    TeacherBuildListPresenterTeacherBuildMenuPresenter = {"显示标题和输出栏", "反向动画"},
    TeacherBuildListPresenterTeacherBuildInfoPresenter = {"显示标题并隐藏输出栏"},
    TeacherBuildInfoPresenterTeacherBuildListPresenter = {"显示标题并隐藏输出栏", "反向动画"},
    TeacherBuildInfoPresenterTeacherBuildDonatePresenter = {"显示标题并隐藏输出栏"},
    TeacherBuildDonatePresenterTeacherBuildInfoPresenter = {"显示标题并隐藏输出栏", "反向动画"},
    TeacherBuildMenuPresenterTeacherFeatPresenter = {"显示标题并隐藏输出栏"},
    TeacherFeatPresenterTeacherBuildMenuPresenter = {
        animDuration = 0.3,
        animPreFunc = function(self)
        end,
        animAftFunc = function(self)
            local layer = self:getLayer("TitleLayer")
            layer:setSetUpButtonName()
            layer:setButton_setup()
            layer:setLocalZOrder(10)
            layer:show(true)

            local layer = self:getLayer("PrintLayer")
            layer:setLocalZOrder(10)
            layer:show()
        end,
        animDirection = -1
    },
    TeacherBuildInfoPresenterMainLayer = {"显示标题和输出栏", "反向动画"},
    TeacherBuildMenuPresenterTeacherGuidancePresenter = {"显示标题并隐藏输出栏"},
    TeacherGuidancePresenterTeacherBuildMenuPresenter = {
        animDuration = 0.3,
        animPreFunc = function(self)
        end,
        animAftFunc = function(self)
            local layer = self:getLayer("TitleLayer")
            layer:setSetUpButtonName()
            layer:setButton_setup()
            layer:setLocalZOrder(10)
            layer:show(true)

            local layer = self:getLayer("PrintLayer")
            layer:setLocalZOrder(10)
            layer:show()
        end,
        animDirection = -1
    },
    ActionLayerMapLayer = {
        animAftFunc = function(self)
            local layer = self:getLayer("TitleLayer")
            layer:setLocalZOrder(10)
            layer:hide(true)

            local MapRoleLayer = self:getLayer("MapRoleLayer")
            MapRoleLayer:show()
            MapRoleLayer:onResume()
            MapRoleLayer:maxZ()

            local layer = self:getLayer("PrintLayer")
            layer:setLocalZOrder(10)
            layer:show()
            Audio:stopMusic()
        end
    },
    MapLayerActionLayer = "隐藏标题和输出栏"
}

function ControllLayer:create()
    local p = ControllLayer:new()
    p:init()
    return p
end

function ControllLayer:init()
    self._layers = layers -- 层次
    self._switchs = switchs --

    self._defaultSwitch = {
        -- 默认切换方式
        animType = "MoveAndFadeAnim",
        animDuration = 0.3,
        animDirection = 1,
        animPreFunc = nil,
        animAftFunc = nil
    }

    self:preLoad() -- 预加载所有层
    self:initLayerStack() -- 初始化层栈队列
    local printLayer = self:getLayer("PrintLayer")
    printLayer:registerRichPrint()

    self:delayFunc(
        0.01,
        function()
            self:pushLayer("MenuLayer")
        end
    )

    self.__isSwitching = true

    -- 渲染循环
    Game:setRenderLoop(
        function(ft)
            local titleLayer = self:getLayerWithoutCreate("TitleLayer")
            if titleLayer then
                titleLayer:update(ft)
            end
        end
    )
end

function ControllLayer:getBackgroundLayer()
    return self.__backgroundLayer
end

function ControllLayer:MoveAndFadeAnim(fromLayerName, toLayerName, duration, direction, callBack)
    if duration == nil then
        duration = 0.3
    end
    if direction == nil then
        direction = 1
    end

    local fromLayer = self:getLayer(fromLayerName)
    local toLayer = self:getLayer(toLayerName)

    self:initAnimLayer(fromLayer)
    self:initAnimLayer(toLayer)

    callBack("preAnim")

    local fromTag = fromLayer:getActionTagByName("Switch")
    local toTag = toLayer:getActionTagByName("Switch")

    fromLayer:stopActionByTag(fromTag)
    toLayer:stopActionByTag(toTag)

    if direction > 0 then
        fromLayer:move(cc.p(0, 0))
        toLayer:move(cc.p(display.width, 0))
        self:__updateLayerSkin(toLayer, toLayerName)
        toLayer:resumeSelfAndChildren()

        self:uniqueDelayFunc(
            "delayFunc" .. fromLayerName,
            0.01,
            function()
                local fromAction =
                    cc.Sequence:create(
                    cc.FadeOut:create(duration / 1),
                    cc.DelayTime:create(0.01),
                    cc.CallFunc:create(
                        function()
                        end
                    )
                )
                fromAction:setTag(fromTag)
                fromLayer:runAction(fromAction)
            end
        )

        self:uniqueDelayFunc(
            "delayFunc" .. toLayerName,
            0.01,
            function()
                self.__backgroundLayer:switchTo(toLayerName)
                local HouseSkin = require("app.models.ChangeHouseSkin.HouseSkin")
                if HouseSkin:hasPrintLayerCurrentConfig(toLayerName) then
                    self:getLayer("PrintLayer"):updateSkinUI(toLayerName)
                end

                toLayer:setVisible(true)
                local toAction =
                    cc.Sequence:create(
                    cc.MoveTo:create(duration, cc.p(0, 0)),
                    cc.DelayTime:create(0.01),
                    cc.CallFunc:create(
                        function()
                            fromLayer:move(cc.p(0, display.height))
                            fromLayer:setVisible(false)
                            fromLayer:pauseSelfAndChildren()
                            callBack("aftAnim")
                        end
                    )
                )
                toAction:setTag(toTag)

                toLayer:runAction(toAction)
            end
        )
    else
        fromLayer:move(cc.p(0, 0))
        toLayer:move(cc.p(-display.width, 0))
        self:__updateLayerSkin(toLayer, toLayerName)
        toLayer:resumeSelfAndChildren()

        self:uniqueDelayFunc(
            "delayFunc" .. fromLayerName,
            0.01,
            function()
                local fromAction =
                    cc.Sequence:create(
                    cc.FadeOut:create(duration / 1),
                    cc.DelayTime:create(0.01),
                    cc.CallFunc:create(
                        function()
                        end
                    )
                )
                fromAction:setTag(fromTag)
                fromLayer:runAction(fromAction)
            end
        )

        self:uniqueDelayFunc(
            "delayFunc" .. toLayerName,
            0.01,
            function()
                self.__backgroundLayer:switchTo(toLayerName)
                local HouseSkin = require("app.models.ChangeHouseSkin.HouseSkin")
                if HouseSkin:hasPrintLayerCurrentConfig(toLayerName) then
                    self:getLayer("PrintLayer"):updateSkinUI(toLayerName)
                end

                toLayer:setVisible(true)
                local toAction =
                    cc.Sequence:create(
                    cc.MoveTo:create(duration, cc.p(0, 0)),
                    cc.DelayTime:create(0.01),
                    cc.CallFunc:create(
                        function()
                            fromLayer:move(cc.p(0, display.height))
                            fromLayer:setVisible(false)
                            fromLayer:pauseSelfAndChildren()
                            callBack("aftAnim")
                        end
                    )
                )
                toAction:setTag(toTag)
                toLayer:runAction(toAction)
            end
        )
    end
end

-- 开始游戏, 入口
function ControllLayer:startGame()
    FILE_IS_LOADING = true -- 表示资源已经载入完毕

    -- HttpManagerEx:uploadUserData("kaishi")
    Game:updatePayInfo() -- 更新支付信息

    Account:getGameUserInfo(
        function(eventType, data, errmsg)
            if eventType == "获取成功" then
                -- 根据服务器数据情况 初始化 用户数据
                local isDepartFromFamilyError = false --叛师异常（回档）
                local function initUserDataFromWeb(data)
                    if MapIsEmpty(data) == true then
                        return
                    end

                    --实名认证相关数据
                    if MapIsEmpty(data.idauth) == false then
                        local function cheakIsAdult(isadult)
                            print("isadult = ", isadult)
                            --判断是否成年
                            if isadult == true then
                                SCREEN_TIME_OPEN = false
                            else
                                SCREEN_TIME_OPEN = true --防沉迷开关

                                Game:MonitorScreenTime()
                            end
                        end

                        local idauth = data.idauth
                        local isbind = idauth.isbind --是否绑定
                        local isadult = idauth.isadult --是否成年

                        if Game:isOpenShiMing() == true then
                            if isbind ~= true then
                                PopupLayerController:showLayer(
                                    "BindingIdcardLayer",
                                    function(layer)
                                        layer:show()
                                        layer:addCallback(
                                            function(Adult)
                                                cheakIsAdult(Adult)
                                            end
                                        )
                                    end
                                )
                            else
                                cheakIsAdult(isadult)
                            end
                        end
                    end

                    --[[				初始化属性
				account: guankaLimit 关卡上限 cid 账户ID
				role: yueka expired_time 月卡及剩余时间
				{"errcode":0,"data":{"account":{"guanqialimit":10,"duocundang":0},"role":{"yueka":0,"baoyuefengshenfu":0}}}
				]]
                    -- 账户相关数据
                    if MapIsEmpty(data.account) == false then
                        local account = data.account
                        -- 不为空且必须是数字类型
                        -- User:setRoleAttr("guanqiaLimit", Helper:getDef(account.guanqialimit, 10))

                        local oldMapReleation = {
                            ["fuben11-20"] = "volume_2",
                            ["fuben21-30"] = "volume_3",
                            ["fuben31-35"] = "volume_4",
                            ["fuben36-40"] = "volume_5"
                        }

                        for oleVolumeId, newVolumeId in pairs(oldMapReleation) do
                            if data.account.guanqialimit[oleVolumeId] == 1 or data.account.guanqialimit[newVolumeId] == 1 then
                                data.account.guanqialimit[newVolumeId] = 1
                            end
                        end

                        local m_volume = User:getRoleAttr("m_volume")
                        for volumeId, state in pairs(data.account.guanqialimit) do
                            if oldMapReleation[volumeId] == nil then
                                if state == 1 then
                                    m_volume[volumeId] = true
                                else
                                    m_volume[volumeId] = false
                                end
                            end
                        end
                        User:setRoleAttr("m_volume", m_volume)

                        -- 账户ID
                        User:setRoleAttr("accountId", Helper:getRange(Helper:getDef(account.cid, 0), 0))

                        if data.account.createTime ~= nil and type(data.account.createTime) == "number" then
                            User:setRoleAttr("createTime", data.account.createTime)

                            if Game:isTesting() == true then
                                User:setRoleAttr("createTime", data.account.createTime - (3600 * 24 * 7))
                            end
                        end
                    end

                    -- 角色相关数据
                    if MapIsEmpty(data.role) == false then
                        local webRoleData = data.role
                        -- 月卡存在并且时间大于当前时间
                        if tonumber(webRoleData.yueka) ~= nil then
                            User:getRole():updateYueKaStatus(webRoleData.yueka)

                            if GetTime() < tonumber(webRoleData.yueka) then
                                --月卡每日福利是否领取 1领取 0未领取
                                if type(webRoleData.yueka_reward) == "number" then
                                    User:getRole():setDayFlag("yueKa_reward", webRoleData.yueka_reward)
                                end
                            end
                        else
                            User:getRole():updateYueKaStatus(nil)
                        end

                        User:getRole():updateYaShiStatus(webRoleData.yashi)

                        if webRoleData.yashiWelfarePoint then
                            local YaShiBenefit = require("app.models.YaShiBenefit.YaShiBenefit")
                            local canExchange = webRoleData.yashiWelfarePoint > 0
                            YaShiBenefit:setCanExchange(canExchange)
                        end

                        --@desc 观影堂特权数据
                        User:getRole():setViewingHallPrivilegeExpiredTime(webRoleData.privilege_expired_time)
                        User:getRole():setViewingHallPrivilegeRemainingWatches(webRoleData.privilege_remaining_watches)
                    end

                    -- 角色相关公告信息
                    if MapIsEmpty(data.notice) == false then
                        local notice = data.notice
                        local roleNoticeVersion = User:getRoleAttr("notice_version")
                        if tonumber(notice.version) ~= nil and tonumber(roleNoticeVersion) ~= nil and tonumber(roleNoticeVersion) < tonumber(notice.version) then --  服务器公告版本号不为空，并且比角色版本号新
                            User:setRoleAttr("notice_version", notice.version)
                            User:setRoleAttr("notice_url", notice.url)
                        else
                            User:setRoleAttr("notice_url", nil)
                        end
                    end

                    -- add by XiaoZhiWei 2017/07/18 18:11:20 角色是否作弊  0 没作弊 1 作弊
                    local is_cheat = Helper:getDef(data.is_cheat, 0)
                    if is_cheat == 0 then
                        User:setRoleAttr("role_is_cheat", false)
                    elseif is_cheat == 1 then
                        User:setRoleAttr("role_is_cheat", true)
                    else
                        -- add by XiaoZhiWei 2017/07/18 18:22:37 测试的时候打印一下消息
                        if Game:isTesting() == true then
                            PopText("没有这个情况需要沟通" .. tostring(is_cheat))
                        end
                        User:setRoleAttr("role_is_cheat", false)
                    end

                    --@desc 家园系统开关判断
                    if data.jiayuantch == true then
                        JIAYUAN_SYSTEM_IS_OPEN = true
                    else
                        JIAYUAN_SYSTEM_IS_OPEN = false
                    end

                    if not MapIsEmpty(data.hometch) and data.hometch.switchs == 1 then
                        --@RefType [app.models.role.Role#Role]
                        local role = User:getRole()
                        local flag = role:getInheritFlag("家园引导")

                        if flag < 2 then
                            role:setInheritFlag("家园引导", 2)
                        end
                    end

                    if MapIsEmpty(data.task) == false then
                        --@TODO 2021-01-25 19:19:51 暂时只有task22任务，需修改
                        if data.task["task22"] ~= nil then
                            local SelfCreatedSkillTaskModel = require("app.models.SelfCreatedSkillSystem.SelfCreatedSkillTask.SelfCreatedSkillTaskModel")
                            SelfCreatedSkillTaskModel:loginUpdate(data.task["task22"])
                        end
                    end

                    --@desc 自创武学书籍数据
                    if MapIsEmpty(data.selfCreateSkill) == false then
                        local role = User:getRole()
                        role:getSelfCreatedSkillSystem():setBooksData(data.selfCreateSkill)
                    end

                    --@desc 邮箱是否有未处理邮件
                    if MapIsEmpty(data.redDot) == false then
                        local role = User:getRole()
                        role:setMailBoxState(data.redDot.email)
                    end

                    --@desc 角色背包校正
                    if data.bag_level then
                        local Bag = require("app.models.role.bag.Bag")
                        local bag = Bag:create()
                        bag:setRole(User:getRole())
                        bag:correctLevelTrue(data.bag_level)
                    end

                    --@desc 角色仓库校正
                    if data.warehouse_level then
                        local WareHouse = require("app.models.role.bag.WareHouse")
                        local wareHouse = WareHouse:create()
                        wareHouse:setRole(User:getRole())
                        wareHouse:correctLevelTrue(data.warehouse_level)
                    end

                    --@desc 角色背包神兵携带数量校正
                    if data.arsenal_level then
                        local role = User:getRole()
                        role:setAttr("bagShenBingNumLimit", data.arsenal_level)
                    end

                    --@desc 角色神兵可拥有数量校正
                    if data.weaponhold_level then
                        local role = User:getRole()
                        local ShenBingDuanZao = require("app.models.ShenBing.DuanZao.ShenBingDuanZao")
                        local limit = ShenBingDuanZao:getShenBingLimitByLevel(data.weaponhold_level)
                        role:setAttr("shenBingNumLimit", limit)
                    end

                    --皮肤id
                    if data.usedUiId then
                        local HouseSkin = require("app.models.ChangeHouseSkin.HouseSkin")
                        HouseSkin:setSkinId(data.usedUiId)
                    end

                    --4399活动
                    if data.flag_4399 then
                        local ActionOf4399 = require("src.app.models.Action.ActionOf4399")
                        ActionOf4399:setActionOpen(true)
                        ActionOf4399:setActionId(data.flag_4399)
                    end

                    --白名单
                    if data.isWhiteList then --0(不是白名单)  1 (是白名单)
                        local role = User:getRole()
                        role:setAttr("isWhiteList", data.isWhiteList)
                    end

                    if data.transferSign then --叛师校验
                        if User:getRoleAttr("departFromFamilySign") ~= data.transferSign then
                            isDepartFromFamilyError = true
                            User:setRoleAttr("departFromFamilySign", data.transferSign)
                        end
                    end

                    --散人装备外门武学数量和心法等级限制数据
                    if data.mcmrestrictId then
                        User:getRole():setAttr("mcmrestrictId", data.mcmrestrictId)
                    end

                    if data.meridianTalentPage then
                        User:getRole():getMeridianSystem():repairMeridianData(data.meridianTalentPage)
                    end

                    --挑战副本通关数据
                    if data.challengeMapCompleted then
                        local ChallengeMapSystem = require("app.models.ChallengeMap.ChallengeMapSystem")
                        ChallengeMapSystem:getInstance():initCompletedMapIds(data.challengeMapCompleted)
                    end
                end
                initUserDataFromWeb(data)

                -- add by XiaoZhiWei 2017/06/30 13:26:14 add with ios 1.0
                -- add by XiaoZhiWei 2017/06/20 16:03:32 读取本地配置,同步副本偶遇状态
                local MapPvp = DataBase:getDataWithString("MapPvp")
                if MapPvp == nil then
                    MapPvp = "ONLINE" -- add by XiaoZhiWei 2017/06/20 16:13:34 默认是在线模式
                    DataBase:setDataByString("MapPvp", MapPvp)
                end

                -- add by XiaoZhiWei 2018/06/02 12:12:20 离线模式检查一下是否有邮箱 (只检查一次)
                if MapPvp ~= "OFFLINE" and User:getRole():getFlag("邮箱检查") == 0 then
                    Account:getEmail(
                        function(eventName, errmsg, email, isBind, isLogout)
                            if eventName == "有邮箱" and isBind == true then
                            else
                                DataBase:setDataByString("MapPvp", "OFFLINE")
                                User:getRole():setFlag("PVP战斗状态", "离线模式")
                            end
                            User:getRole():setFlag("邮箱检查", 1)
                        end
                    )
                else
                    if MapPvp == "ONLINE" then
                        User:getRole():setFlag("PVP战斗状态", "战斗结束")
                    elseif MapPvp == "OFFLINE" then
                        User:getRole():setFlag("PVP战斗状态", "离线模式")
                    else
                        User:getRole():setFlag("PVP战斗状态", "免打扰模式")
                    end
                end

                -- 副本对战
                MapPVP:loadData()

                if DEBUG_MODE == 1 then
                    MapPVP:clearHistoryData()
                end

                if User:getRole():getFlag("用户存档方式") == 1 then
                    ROLE_DATA_SAVE_STYLE_AUTO = true
                elseif User:getRole():getFlag("用户存档方式") == 2 then
                    ROLE_DATA_SAVE_STYLE_AUTO = false
                end

                -- 上传一下收集数据 ------
                Collection:uploadCollection()
                Statistics:uploadItemStatisticsData()

                AchievementSystem:initData(User:getRole(), User:getUserId())
                AchievementSystem:updateTujianTypeRecord()

                self:pushLayer("MainLayer")

                local lianGongSystem = User:getRole():getLianGongSystem()

                local AsyncFunction = require("third.async.AsyncFunction")

                local ok, isLianGoning = lianGongSystem:getLianGongState()
                if ok then
                    lianGongSystem:setIsLianGonging(isLianGoning)

                    local ok, msg = AsyncFunction:asyncAwaitWithCallback(lianGongSystem.pullLianGongData, lianGongSystem, "callback")
                    if ok then
                        local xiuLianSystem = User:getRole():getXiuLianSystem()
                        local ok, isXiuLianing = AsyncFunction:asyncAwaitWithCallback(xiuLianSystem.getXiuLianState, xiuLianSystem, "callback")
                        if ok then
                            xiuLianSystem:setIsXiuLianing(isXiuLianing)
                            local ok, msg = AsyncFunction:asyncAwaitWithCallback(xiuLianSystem.pullXiuLianData, xiuLianSystem, "callback")
                            if ok then
                                self:setGameUpdate()
                            else
                                PopText(msg)
                            end
                        else
                            PopText("获取修炼状态失败")
                        end
                    else
                        PopText(msg)
                    end
                else
                    PopText("获取练功状态失败")
                end

                local fistFootSystem = User:getRole():getFistFootSystem()
                local ok, msg = AsyncFunction:asyncAwaitWithCallback(fistFootSystem.pullData, fistFootSystem, "callback")

                --@desc 修复装备的外门武学不符合装备条件
                User:getRole():getPrepareSkillModel():repairPrepareSkill()
                -- 刷新物品表缓存
                User:getRole():getServerActionSystem():refreshItemMapCache(
                    1,
                    function(...)
                        print("刷新服务器物品表缓存完成", ...)
                        return true
                    end
                )

                local DepartFromFamily = require("app.models.departFromFamily.DepartFromFamily")
                local departFromFamily = DepartFromFamily:create()
                departFromFamily:setRole(User:getRole())

                if isDepartFromFamilyError == true then
                    departFromFamily:repairDepartFromFamilyError()
                end

                departFromFamily:repairDepartFromFamilyData()

                local teacherBuildSystem = User:getRole():getTeacherBuildSystem()
                local ok, msg = AsyncFunction:asyncAwaitWithCallback(teacherBuildSystem.getTeacherBuildData, teacherBuildSystem, "callback")

                AsyncFunction:asyncAwaitWithCallback(teacherBuildSystem.getTeacherBuildInFo, teacherBuildSystem, "callback")

                local HiddenMeridianConstants = require("app.models.Meridian.HiddenMeridianConstants")
                User:getRole():getHiddenMeridianSystem():deleteHMBuffByNodal(HiddenMeridianConstants.DeleteBuffNodal.LOGIN)
            else
                -- 获取失败,什么都不允许进行
                PopText(errmsg)
            end
        end
    )
end

function ControllLayer:setGameUpdate()
    if self._gameIsUpdating then
        return
    end

    if SdkMethod.LOGIN_SetCallback ~= nil then
        SdkMethod:LOGIN_SetCallback(
            function(eventName)
                if eventName == "logout" then
                    Game:restart()
                end
            end
        )
    end

    -- 注册
    self:addNodeEvent(
        "exit",
        function()
            local User = require("app.models.user.User")
            if PRINT_MODE == 1 then
                print("退出游戏")
            end

            -- 移除本地log
            if LogManager and removeLogFile then
                LogManager:removeLogFile()
            end

            -- 防止变成残废
            local role = User:getRole()
            if role and role.userid and role.userid > 0 then
                User:save()
            end

            -- 释放资源
            if Resource then
                Resource:releaseRes()
            end
        end
    )

    -- 等待界面
    self.__waitingLayer = nil

    Game:setLogicLoop(
        function(ft)
            -- 游戏后台逻辑更新调度器
            if not self:isSwitching() and self:isUpdate() then
                if not MainCoroutinePool:contains("MainControllerLayer") then
                    -- 创建携程去刷新角色数据
                    MainCoroutinePool:add(
                        "MainControllerLayer",
                        function()
                            if self:isUpdate() == true then
                                -- 更新角色属性
                                self:__updateRoleAttr()

                                coroutine.yield()

                                -- 角色更新
                                LogSystem:log("ControllLayer:User:update()")
                                User:update()
                                coroutine.yield()

                                PopupLayerController:update()

                                if Record:isNeedSubmit() then
                                    Record:submitLog()
                                end

                                Record:updateUpload()

                                -- 内存回收
                                self:collectGarbageStep()
                            end
                            coroutine.yield()
                        end
                    )
                end
            end

            -- 全局协程池调度
            MainCoroutinePool:update(ft)

            require("app.models.Pay.IosPurchaseCheck"):update()

            -- 尝试释放动画资源
            Game:cleanUnuseAutoReleaseTextures(ft / 6)

            if not self:isSwitching() and self:isUpdate() then
                -- 开始保存角色存档
                if ROLE_DATA_SAVE_STYLE_AUTO then
                    -- LogSystem:log("ControllLayer:User:saveRoleStep()")
                    User:saveRoleStep()
                end
            end

            -- 反作弊調度
            MainCheatingAgainstSystem:update(ft)
        end
    )

    self._gameIsUpdating = true
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/11/29 03:01:36
-- @desc 按步骤清理内存
function ControllLayer:collectGarbageStep()
    LogSystem:log("ControllLayer:UcollectGarbageStep()")
    -- add by XiaoZhiWei 2017/10/27 10:35:47 安卓关闭及时内存清理
    if Game:getPlatformId() == "ios" or CURR_DEVICE_CHANNEL == "ios" then
        collectgarbage("step")
    end
end

-- 刷新角色属性
function ControllLayer:__updateRoleAttr()
    LogSystem:log("ControllLayer:__updateRoleAttr()")

    local role = User:getRole()
    if role and role.userid and role.userid > 0 then
    else
        return
    end

    -- 时间间隔控制  定为1秒
    -- add by XiaoZhiWei 2017/06/19 17:40:42 副本偶遇状态更
    if MainControllLayer:getCurrLayer() == "MapLayer" then
        MapPVP:update()
    end

    coroutine.yield()

    role:updateRoleBuff()

    coroutine.yield()

    -- add by XiaoZhiWei 2017/04/05 20:24:29 挂机收益前移,情况: 在离线状态下,挂机和练功如果同时进行时,需先计算经验和潜能的收益,再计算练功.否则离线提升的经验和潜能不会参与到练功离线收益计算内
    local RoleTaskControllor = require("app.views.layer.RoleLayer.RoleTaskControllor")
    RoleTaskControllor:update()

    coroutine.yield()

    role:spontaneousRecovery()

    coroutine.yield()

    DoFuncWithInterval(
        "ControllLayer.save.user.data",
        function()
            role:calcNeiLiLimit()
            -- 移除本地log
            if LogManager and removeLogFile then
                LogManager:removeLogFile()
            end
        end,
        5
    )

    DoFuncWithInterval(
        "ControllLayer.save.user.age",
        function()
            role:calculateAge()
        end,
        300
    )
    coroutine.yield()

    if role._buffManager then
        role._buffManager:update()
    end
end

Helper:classDefNodeGetInstance(ControllLayer)

-- 加密标记
ControllLayer.isEncrypted = true
return ControllLayer
0000000000