

-- add by XiaoZhiWei 2017/09/11 18:07:25 弹出层页面管理器
local PopupLayerController = class("PopupLayerController", LayerEx)

local UPDATE_INTERVER = 20
-- if Game:getPlatformId() == "android" then -- add by XiaoZhiWei 2017/11/01 16:58:40 安卓设备不需要页面优化
-- 	UPDATE_INTERVER = 99999999
-- end


function PopupLayerController:create()
	local p = PopupLayerController:new()
	p:init()
	return p
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/09/11 17:50:26
-- @desc 初始化方法
function PopupLayerController:init()
	self._layers = {
		SignInLayer = "app.views.layer.SignInLayer.SignInLayer",

		DebugLayer = "app.views.layer.DebugLayer.DebugLayer",
		AnimTestLayer = "app.views.layer.DebugLayer.AnimTestLayer",
		AnimOldFightTestLayer = "app.views.layer.DebugLayer.AnimOldFightTestLayer",

		StoreDialogLayer = "app.views.layer.StoreLayer.StoreDialogLayer",
		YueKaLayer = "app.views.layer.StoreLayer.YueKaLayer",
		YaShiLayer = "app.views.layer.StoreLayer.YaShiLayer",
		PayLayer = "app.views.layer.StoreLayer.PayLayer",
		-- 广告层
		ADLayer = "app.views.layer.ADLayer.ADLayer",
		
		ActionDescLayer = "app.views.layer.ActionLayer.ActionDescLayer",
		AnniversaryCelebrationConversionLayer ="app.views.layer.ActionLayer.AnniversaryCelebrationConversionLayer",
		ConsumeWingLayer = "app.views.layer.ActionLayer.ConsumeWingLayer",

		AttrPointLayer = "app.views.layer.AttrLayer.AttrPointLayer",
		JiaLiLayer = "app.views.layer.AttrLayer.JiaLiLayer",
		NeiDanLayer = "app.views.layer.AttrLayer.NeiDanLayer",
		BiWuGuanJiaLayer = "app.views.layer.BiWuLayer.BiWuGuanJiaLayer",
		BiWuRankingLayer = "app.views.layer.BiWuLayer.BiWuRankingLayer",
		BiWuNoticeLayer = "app.views.layer.BiWuLayer.BiWuNoticeLayer",

		CemeteryLayer = "app.views.layer.CemeteryLayer.CemeteryLayer",

		ChineseValentineCheckListLayer = "app.views.layer.ChineseValentineLayer.ChineseValentineCheckListLayer",
		ChineseValentineLayer = "app.views.layer.ChineseValentineLayer.ChineseValentineLayer",
		ChineseValentineMyQiyuanDialog = "app.views.layer.ChineseValentineLayer.ChineseValentineMyQiyuanDialog",
		PrayTreeDialog = "app.views.layer.ChineseValentineLayer.PrayTreeDialog",
		-- PrayTreeLayer = "app.views.layer.ChineseValentineLayer.PrayTreeLayer",

		DecorativeBoxLayer = "app.views.layer.DecorativeBoxLayer.DecorativeBoxLayer",
		DecorativePokedexLayer = "app.views.layer.DecorativeBoxLayer.DecorativePokedexLayer",

		BindingMailLayer = "app.views.layer.EmailLayer.BindingMailLayer",
		LogoutLayer = "app.views.layer.EmailLayer.LogoutLayer",
		LogoutLayerInMenu = "app.views.layer.EmailLayer.LogoutLayerInMenu",
		RetrieveArchiveLayer = "app.views.layer.EmailLayer.RetrieveArchiveLayer",

		ExamScoreLayer = "app.views.layer.ExamLayer.ExamScoreLayer",
		PalaceExamEntranceLayer = "app.views.layer.ExamLayer.PalaceExamEntranceLayer",
		PalaceExamJumpLayer = "app.views.layer.ExamLayer.PalaceExamJumpLayer",
		PalaceExamLayer = "app.views.layer.ExamLayer.PalaceExamLayer",
		ProvinceExamLayer = "app.views.layer.ExamLayer.ProvinceExamLayer",
		VillageExamLayer = "app.views.layer.ExamLayer.VillageExamLayer",
		GamblingHouseLayer = "app.views.layer.GamblingHouseLayer.GamblingHouseLayer",

		GameHelpLayer = "app.views.layer.GameHelp.GameHelpLayer",
		GhostItemLayer = "app.views.layer.Ghost.GhostItemLayer",

		ActiveZhaoBookCaseLayer = "app.views.layer.GongFuPageLayer.ActiveZhaoBookCaseLayer",
		BookCaseLayer = "app.views.layer.GongFuPageLayer.BookCaseLayer",
		BookLiteraryLayer = "app.views.layer.GongFuPageLayer.BookLiteraryLayer",
		BookRankLayer = "app.views.layer.GongFuPageLayer.BookRankLayer",
		WzRankLayer = "app.views.layer.GongFuPageLayer.WzRankLayer",

		YongBingBagLayer = "app.views.layer.GuYongBingLayer.YongBingBagLayer",
		YongBingInfoLayer = "app.views.layer.GuYongBingLayer.YongBingInfoLayer",

		InheritConfirmLayer = "app.views.layer.InheritLayer.InheritConfirmLayer",
		InheritConsultLayer = "app.views.layer.InheritLayer.InheritConsultLayer",
		InheritEventLayer = "app.views.layer.InheritLayer.InheritEventLayer",
		InheritSetNameLayer = "app.views.layer.InheritLayer.InheritSetNameLayer",

		KiteLayer = "app.views.layer.KiteLayer.KiteLayer",

		SelectMapDetailLayer = "app.views.layer.MapLayer.SelectMapDetailLayer",
		WordsShowingLayer = "app.views.layer.MapLayer.WordsShowingLayer",
		PlayerListLayer = "app.views.layer.MapPVPLayer.PlayerListLayer",
		PVPWaitingLayer = "app.views.layer.MapPVPLayer.WaitingLayer",

		LeftRightFightGameLayer = "app.views.layer.MeridianLayer.LeftRightFightGameLayer",
		MerdianAromaBurnerLayer = "app.views.layer.MeridianLayer.MerdianAromaBurnerLayer",
		MeridianCalmDownLayer = "app.views.layer.MeridianLayer.MeridianCalmDownLayer",
		MeridianDiseaseLayer = "app.views.layer.MeridianLayer.MeridianDiseaseLayer",
		MeridianGuBenLayer = "app.views.layer.MeridianLayer.MeridianGuBenLayer",

		ClimbingLayer = "app.views.layer.PopLayer.ClimbingLayer",
		DragonBoatLayer = "app.views.layer.PopLayer.DragonBoatLayer",
		HellBridgeLayer = "app.views.layer.PopLayer.HellBridgeLayer",
		LifeDeathBookLayer = "app.views.layer.PopLayer.LifeDeathBookLayer",
		NewDialogDodgeLayer = "app.views.layer.PopLayer.NewDialogDodgeLayer",
		PasswordLockLayer = "app.views.layer.PopLayer.PasswordLockLayer",
		StorytellerLayer = "app.views.layer.PopLayer.StorytellerLayer",
		TextPopLayer = "app.views.layer.PopLayer.TextPopLayer",
		TongGuanPopLayer = "app.views.layer.PopLayer.TongGuanPopLayer",
		TongGuanPopLayer2 = "app.views.layer.PopLayer.TongGuanPopLayer2",

        -- 新的通关结算界面
        NewTongGuanPopLayer = "app.views.layer.PopLayer.NewTongGuanPopLayer",

		QALayer = "app.views.layer.QALayer.QALayer",

		RoleInfoLayer = "app.views.layer.RoleLayer.RoleInfoLayer",
		RoleObserveLayer = "app.views.layer.RoleLayer.RoleObserveLayer",

		DaZao = "app.views.layer.ShenBingLayer.DaZao.lua",
		DialogUseLayer = "app.views.layer.ShenBingLayer.DialogUseLayer",
		ShenBingObserveLayer = "app.views.layer.ShenBingLayer.ShenBingObserveLayer",
		DuanZaoLuObserveLayer = "app.views.layer.ShenBingLayer.DuanZaoLuObserveLayer",
		XuanBingDong = "app.views.layer.ShenBingLayer.XuanBingDongLayer",
		CangYiGe = "app.views.layer.ShenBingLayer.CangYiGe",
		ShenBingInfo =  "app.views.layer.ShenBingLayer.ShenBingInfo",
		ShenBingSkilledLayer =  "app.views.layer.ShenBingLayer.ShenBingSkilledLayer",
		JiaGong =  "app.views.layer.ShenBingLayer.JiaGong",

		DunDiFuLayer = "app.views.layer.ShenShu.DunDiFuLayer",
		ShenShuHeChengLayer = "app.views.layer.ShenShu.ShenShuHeChengLayer",

		SignInPayYuanBaoLayer = "app.views.layer.SignInLayer.SignInPayYuanBaoLayer",

		SkillPreparePopLayer = "app.views.layer.SkillLayer.SkillPreparePopLayer",

		TaskGuajiLayer = "app.views.layer.TaskLayer.TaskGuajiLayer",
		TaskZhuXianLayer = "app.views.layer.TaskLayer.TaskZhuXianLayer",

		VisitTaskLayer = "app.views.layer.VisitTaskLayer.VisitTaskLayer",

		ArchiveLayer = "app.views.layer.ArchiveLayer",
		SignInMaskGiftLayer = "app.views.layer.ActionLayer.SignInMaskGiftLayer",

		PopConfirmLayer = "app.views.layer.DialogLayer.PopConfirmLayer",

		LiQuanLayer = "app.views.layer.LiQuanLayer.LiQuanLayer",

		MidAutumnQue = "app.views.layer.ActionLayer.MidAutumnQueLayer",
		ButtonPopLayer = "app.views.layer.PopLayer.ButtonPopLayer",
		NewXianShiLayer = "app.views.layer.ActionLayer.NewXianShiLayer",
		PopTextLayer = "app.views.layer.PopTextLayer.PopTextLayer",

		ShenBingMainObserveLayer = "app.views.layer.ShenBingLayer.DuanZao.ShenBingMainObserveLayer",
		FurnaceLayer = "app.views.layer.ShenBingLayer.DuanZao.FurnaceLayer",
		ShenBingNameLayer = "app.views.layer.ShenBingLayer.DuanZao.ShenBingNameLayer",
		ShenBingBagLayer = "app.views.layer.ShenBingLayer.CommonLayer.ShenBingBagLayer",
		NewShenBingBagLayer = "app.views.layer.ShenBingLayer.CommonLayer.NewShenBingBagLayer",
		RongLianDialogLayer = "app.views.layer.ShenBingLayer.DuanZao.RongLianDialogLayer",
		ShenBingRongLianLayer = "app.views.layer.ShenBingLayer.DuanZao.ShenBingRongLianLayer",
		ShenBingCuiLianLayer = "app.views.layer.ShenBingLayer.DuanZao.ShenBingCuiLianLayer",
		ShenBingNPCCuiLianLayer = "app.views.layer.ShenBingLayer.DuanZao.ShenBingNPCCuiLianLayer",

		--神兵排行榜
		ShenBingRankLayer = "app.views.layer.GongFuPageLayer.ShenBingRankLayer",
		--@desc 药囊
		MedicinalLayer = "app.views.layer.PoisonLayer.MedicinalLayer",

		--@desc 物品描述弹出框
		ItemDetailLayer = "app.views.layer.PopLayer.ItemDetailLayer",

		--@desc 选项弹窗界面
		ItemSelectLayer = "app.views.layer.DialogLayer.ItemSelectLayer",
		ItemSelectLayer2 = "app.views.layer.DialogLayer.ItemSelectLayer2",
		ItemSelectAutoFitLayer = "app.views.layer.DialogLayer.ItemSelectAutoFitLayer",

		BagDescLayer = "app.views.layer.AttrLayer.BagDescLayer",
		FestivalDialogLayer = "app.views.layer.ActionLayer.SpringFestival.FestivalDialogLayer",

		--@desc 全屏遮罩
		GlobalShadeLayer = "app.views.layer.PopLayer.GlobalShadeLayer",
		YiRongShuNoLayer = "app.views.layer.YiRongShuLayer.YiRongShuNoLayer",

		YiRongShuLayer = "app.views.layer.YiRongShuLayer.YiRongShuLayer",
		
		--@desc 面具兑换选择
		DecorativeSelectLayer = "app.views.layer.DecorativeBoxLayer.DecorativeSelectLayer",
		-- 新春登陆送元宝  2月9日到2月22
		DengLuJiangLiLayer = "app.views.layer.DialogLayer.DengLuJiangLiLayer",
		
		--小吃排队界面
		StreetSnackLayer = "app.views.layer.ActionLayer.SpringFestival.StreetSnackLayer",
		
		--@desc 戏台排队弹窗
		XiTaiQueueUpLayer = "app.views.layer.ActionLayer.XiTaiQueueUpLayer",

		--春分活动界面
		FlyKiteLayer = "app.views.layer.ActionLayer.FlyKiteLayer",
		--赛龙舟活动界面
		PlayDragonBoatLayer = "app.views.layer.ActionLayer.PlayDragonBoatLayer",
		--赛龙舟门派积分排行榜
		FlyKiteRankListLayer = "app.views.layer.ActionLayer.FlyKiteRankListLayer",
		--赛龙舟个人积分排行榜
		BoatPersonalRankingLayer = "app.views.layer.ActionLayer.BoatPersonalRankingLayer",
		--江湖三友详情界面
		JiangHuSanYouXQLayer = "app.views.layer.ActionLayer.JiangHuSanYouXQLayer",
		--江湖好友进入的界面
		JiangHuSanYouLayer = "app.views.layer.ActionLayer.JiangHuSanYouLayer",
		--江湖三友投票界面
		JiangHuSanYouVoteLayer = "app.views.layer.ActionLayer.JiangHuSanYouVoteLayer",
		--江湖三友的人物详情
		JiangHuSanYouRoleInfoLayer = "app.views.layer.ActionLayer.JiangHuSanYouRoleInfoLayer",

		--江湖好运来兑换积分界面
		HaoYunDuiHuanLayer = "app.views.layer.ActionLayer.HaoYunDuiHuanLayer",
		--江湖好运来活动界面
		JiangHuHaoYunLaiLayer = "app.views.layer.ActionLayer.JiangHuHaoYunLaiLayer",
		--2周年庆重光兑换活动
		ChongGuangDuiHuanLayer = "app.views.layer.ChongGuangDuiHuanLayer.ChongGuangDuiHuanLayer",
		--周年庆 大侠成长之路
		DaXiaChenZhangZhiLuLayer = "app.views.layer.ActionLayer.DaXiaChenZhangZhiLuLayer",
		--馆主的谢礼
		GuanZhuXieLiLayer = "app.views.layer.ActionLayer.GuanZhuXieLiLayer",
		--走穴十四经
		XingZhenLayer = "app.views.layer.XingZhenShiSiXueLayer.XingZhenLayer",
		XingZhenRewardLayer = "app.views.layer.XingZhenShiSiXueLayer.XingZhenRewardLayer",
		ShiZhenTextLayer = "app.views.layer.XingZhenShiSiXueLayer.ShiZhenTextLayer",
		--针法试炼
		XingZhenTryLayer = "app.views.layer.XingZhenShiSiXueLayer.XingZhenTryLayer",

		--@desc 七夕活动
		QiXiLikeLayer = "app.views.layer.ChineseValentineLayer.2018.QiXiLikeLayer",
		QiXiCheckInfoLayer = "app.views.layer.ChineseValentineLayer.2018.QiXiCheckInfoLayer",
		MatchLayer = "app.views.layer.ChineseValentineLayer.2018.MatchLayer",
		QiXiResultLayer = "app.views.layer.ChineseValentineLayer.2018.QiXiResultLayer",
		
		--@desc 派遣任务界面
		DispatchTaskLayer = "app.views.layer.HomelandLayer.DispatchTaskLayer.DispatchTaskLayer",
		
		--购房界面
		BuyHouseLayer = "app.views.layer.HomelandLayer.PurchaseLayer.BuyHouseLayer",
		BuyLandLayer = "app.views.layer.HomelandLayer.PurchaseLayer.BuyLandLayer",
		BiddingLayer = "app.views.layer.HomelandLayer.PurchaseLayer.BiddingLayer",
		BiddingQueryLayer = "app.views.layer.HomelandLayer.PurchaseLayer.BiddingQueryLayer",
		ChuWuGuiLayer = "app.views.layer.HomelandLayer.FurnitureLayer.ChuWuGuiLayer",

		MapActivePractice = "app.views.layer.SkillLayer.MapActivePractice",

		--大门改造界面
		DamenRenovationLayer = "app.views.layer.HomelandLayer.DamenRenovationLayer",
		
		--改造对联
		DuiLianLayer = "app.views.layer.HomelandLayer.DuiLianLayer",
		
		--雇佣详情界面
		EmployDscLayer = "app.views.layer.HomelandLayer.EmployDscLayer",
		
		HomelandRoleEmployLayer = "app.views.layer.HomelandLayer.HomelandRoleEmployLayer",
		
		--房屋事务界面
		RoomAffairLayer = "app.views.layer.HomelandLayer.RoomAffairLayer",
		--信差事务界面
		PostmanAffairLayer = "app.views.layer.HomelandLayer.PostmanAffairLayer",
		
		--房屋改造界面
		RoomRenovationLayer = "app.views.layer.HomelandLayer.RoomRenovationLayer",
		
		--房屋升级界面
		RoomUpgradeLayer = "app.views.layer.HomelandLayer.RoomUpgradeLayer",
		
		CheFuLayer = "app.views.layer.HomelandLayer.CheFuLayer",
		CheFuQianWangLayer = "app.views.layer.HomelandLayer.CheFuQianWangLayer",
		FangJianGaiMingLayer = "app.views.layer.HomelandLayer.FangJianGaiMingLayer",
		DecorativeSelectLayerEx = "app.views.layer.HomelandLayer.DecorativeSelectLayerEx",
		SheYanKuanDaiLayer = "app.views.layer.HomelandLayer.SheYankuanDaiLayer",
		YaoNonJiaoYiLayer = "app.views.layer.HomelandLayer.YaoNonJiaoYiLayer",
		DetialWithButtonPopLayer = "app.views.layer.DialogLayer.DetialWithButtonPopLayer",
		PopTextLayer2 = "app.views.layer.PopTextLayer.PopTextLayer2",
		TextAnimLayer = "app.views.layer.TextAnimLayer.TextAnimLayer",

		--玩家副本户型升级界面
		HouseEnlargeLayer = "app.views.layer.HomelandLayer.HouseEnlargeLayer",
		HouseEnlargeDetailsLayer = "app.views.layer.HomelandLayer.HouseEnlargeDetailsLayer",
		BiGuanLayer = "app.views.layer.SkillLayer.BiGuanLayer",

		AskToBuyLayer = "app.views.layer.HomelandLayer.AskToBuyLayer",

		HomelandRoleInfoLayer = "app.views.layer.HomelandLayer.HomelandRoleInfoLayer", 

		LetterFormatLayer = "app.views.layer.DialogLayer.LetterFormatLayer", 
		--实名认证
		BindingShiMingLayer = "app.views.layer.EmailLayer.BindingShiMingLayer",
		BindingIdcardLayer = "app.views.layer.EmailLayer.BindingIdcardLayer",
		PopWindowsLayer = "app.views.layer.DialogLayer.PopWindowsLayer",

		--神兵重铸
		ShenBingRemakeLayer="app.views.layer.ShenBingLayer.ShenBingRemake",
		--材料兑换
		GoodsShowLayer= "app.views.layer.StoreLayer.GoodsShowLayer",
		--中秋灯谜
		MidAutumnFestivalLanternRiddleLayer="app.views.layer.ActionLayer.MidAutumnFestivalLanternRiddleLayer",
		--购买二次确认界面
		ShoppingDialogLayer = "app.views.layer.DialogLayer.ShoppingDialogLayer",
		--中秋动画
		ShowActionLayer = "app.views.layer.MapLayer.ShowActionLayer",

		--@desc 家具描述弹窗
		FurnitureBackLayer = "app.views.layer.BagLayer.FurnitureBackLayer",
		
		--@desc 太清台
		TaiQingTaiLayer = "app.views.layer.HomelandLayer.FurnitureLayer.TaiQingTaiLayer",

		ChuWuXiangSalesLayer = "app.views.layer.SalesLayer.ChuWuXiangSalesLayer",
		
		ChuWuXiangReplaceLayer = "app.views.layer.HomelandLayer.FurnitureLayer.ChuWuXiangReplaceLayer",

		--充值特惠
		ZhouNianQingChongZhiLayer = "app.views.layer.ActionLayer.ZhouNianQingChongZhiLayer",
		-- 充值抽奖领周边
		PhysicalLotteryLayer = "app.views.layer.ActionLayer.PhysicalLotteryLayer",

		FloorPlanLayer = "app.views.layer.HomelandLayer.FloorPlanLayer",
			--购买打折界面
		DiscountLayer = "app.views.layer.DialogLayer.DiscountLayer",
		ChooseButtonLayer = "app.views.layer.DialogLayer.ChooseButtonLayer",
		ShenZhaoChuanGongLayer="app.views.layer.SkillLayer.ShenZhaoChuanGongLayer",
		-- LoginPopLayer = "app.views.layer.DialogLayer.LoginPopLayer"
		
		--岁末积福活动
		SuiMoJiFuLayer = "app.views.layer.ActionLayer.SuiMoJiFuLayer",
		DialogYuanBaoPayLayer = "app.views.layer.DialogLayer.DialogYuanBaoPayLayer",
		
		--门客代打界面
		MenKeDaiDaLayer = "app.views.layer.HomelandLayer.MenKeDaiDaLayer",
		--英雄宴相关界面
		HeroFeastRewardsLayer = "app.views.layer.ActionLayer.HeroFeastLayer.HeroFeastRewardsLayer",
		PrepareHeroFeastLayer = "app.views.layer.ActionLayer.HeroFeastLayer.PrepareHeroFeastLayer",
		PrepareDrinksLayer = "app.views.layer.ActionLayer.HeroFeastLayer.PrepareDrinksLayer",
		HeroFeastThreePhaseLayer = "app.views.layer.ActionLayer.HeroFeastLayer.HeroFeastThreePhaseLayer",

		ShowDetailListLayer = "app.views.layer.DialogLayer.ShowDetailListLayer",
		--摆放礼品
		FestivalGiveGiftLayer="app.views.layer.ActionLayer.SpringFestival.FestivalGiveGiftLayer",
		AttrPointRemoveLayer = "app.views.layer.AttrLayer.AttrPointRemoveLayer",
		CrossingRiverLayer = "app.views.layer.ActionLayer.CrossingRiverLayer",
		
		--下毒玩法
		PoisonPlayLayer = "app.views.layer.PoisonPlayLayer.PoisonPlayLayer",

		--冶炼箱
		SmeltBoxLayer = "app.views.layer.BagLayer.SmeltBoxLayer",
		
		--师门挂机任务相关界面
		TeacherGuaJiTaskListLayer = "app.views.layer.TeacherGuaJiTaskLayer.TeacherGuaJiTaskListLayer",
		GuaJiTaskPrepareLayer = "app.views.layer.TeacherGuaJiTaskLayer.GuaJiTaskPrepareLayer",
		KnowledgeSelectLayer = "app.views.layer.TeacherGuaJiTaskLayer.KnowledgeSelectLayer",
		GuajiTaskDetailLayer = "app.views.layer.TeacherGuaJiTaskLayer.GuajiTaskDetailLayer",
		HuPengYinBanLayer = "app.views.layer.TeacherGuaJiTaskLayer.HuPengYinBanLayer",
		GuaJiTaskProgressLayer = "app.views.layer.TeacherGuaJiTaskLayer.GuaJiTaskProgressLayer",
		TeammateInFoLayer = "app.views.layer.TeacherGuaJiTaskLayer.TeammateInFoLayer",
		VideoPlayLayer = "app.views.layer.CommunityLayer.VideoPlayLayer",
		FamilyPrestigeRanking = "app.views.layer.TeacherLayer.FamilyPrestigeRanking",
		
		--批量处理界面
		BatchProcessLayer = "app.views.layer.DialogLayer.BatchProcessLayer",
		ServantRewardLayer = "app.views.layer.HomelandLayer.ServantRewardLayer",
		LimitDiscountLayer = "app.views.layer.ActionLayer.LimitDiscountLayer",
		
		--钓鱼玩法
		FishingGameLayer = "app.views.layer.ActionLayer.FishingGameLayer.FishingGameLayer",
		FishingMarketLayer = "app.views.layer.ActionLayer.FishingGameLayer.FishingMarketLayer",
		FishingResultLayer = "app.views.layer.ActionLayer.FishingGameLayer.FishingResultLayer",

		--七夕情书活动
		QiXiLoveLetterLayer = "app.views.layer.ActionLayer.QiXiFestival_2019.QiXiLoveLetterLayer",
		QiXiRankLayer = "app.views.layer.ActionLayer.QiXiFestival_2019.QiXiRankLayer",
		QiXiMingShiGaoTuLayer = "app.views.layer.ActionLayer.QiXiFestival_2019.QiXiMingShiGaoTuLayer",

		BlackStoreLayer = "app.views.layer.SalesLayer.BlackStoreLayer",

		--国庆狂欢活动
		GuoQingKuangHuanLayer = "app.views.layer.ActionLayer.GuoQingKuangHuanLayer",
		HuaRongDaoLayer = "app.views.layer.MiniGame.HuaRongDaoLayer",
		
		--琴音助功界面
		SoundAssistsLayer = "app.views.layer.MiniGame.SoundAssistsLayer",

		EnterDreamLayer = "app.views.layer.DreamWorldLayer.EnterDreamLayer",
		LeaveDreamMapLayer = "app.views.layer.DreamWorldLayer.LeaveDreamMapLayer",
		DreamSalesLayer2 = "app.views.layer.DreamWorldLayer.DreamSalesLayer2",
		UseTalentLayer = "app.views.layer.DreamWorldLayer.UseTalentLayer",
		ItemDetailPopLayer = "app.views.layer.DreamWorldLayer.ItemDetailPopLayer",
		DreamTalentInfoLayer = "app.views.layer.DreamWorldLayer.DreamTalentInfoLayer",
		PrepareTalentLayer =  "app.views.layer.DreamWorldLayer.PrepareTalentLayer",
		DreamCompleteRewardLayer = "app.views.layer.DreamWorldLayer.DreamCompleteRewardLayer",
		DreamEntryLayer = "app.views.layer.DreamWorldLayer.DreamEntryLayer",

		--采灯
		LadderLanternLayer = "app.views.layer.MiniGame.LadderLanternLayer",
		LadderLanternRewardLayer = "app.views.layer.MiniGame.LadderLanternRewardLayer",

		--武学图鉴界面
		TuJianSkillInFoPopLayer = "app.views.layer.TuJianLayer.TuJianSkillInFoPopLayer",
		SkillXiuLianLayer = "app.views.layer.SkillLayer.SkillXiuLianLayer",

		RandomGiftLayer = "app.views.layer.ActionLayer.RandomGiftLayer",
		DialogALayer2 = "app.views.layer.DialogLayer.DialogALayer2",
		--仆人管理界面
		PuRenManagementLayer = "app.views.layer.HomelandLayer.PuRenManagementLayer",
		--香炉界面
		XiangLuLayer = "app.views.layer.HomelandLayer.FurnitureLayer.XiangLuLayer",
		
		DialogOLayer = "app.views.layer.DialogLayer.DialogOLayer",
		FlyKiteRewardLayer = "app.views.layer.ActionLayer.FlyKiteRewardLayer",
		WristbandCompetitionLayer = "app.views.layer.ActionLayer.WristbandCompetitionLayer",
		WristbandCompetitionResultLayer = "app.views.layer.ActionLayer.WristbandCompetitionResultLayer",

		--信物兑换
		TokenExchangeActivityLayer = "app.views.layer.ActionLayer.TokenExchangeActivity.TokenExchangeActivityLayer",

		SelectSkillTypeUI = "app.views.ui.SelfCreatedSkillUI.SelectSkillTypeUI",
		CreatedZhaoUI = "app.views.ui.SelfCreatedSkillUI.CreatedZhaoUI",
		ZhaosLibraryUI = "app.views.ui.SelfCreatedSkillUI.ZhaosLibraryUI",
		CreatedSkillUI = "app.views.ui.SelfCreatedSkillUI.CreatedSkillUI",
		ZhaoInfoUI = "app.views.ui.SelfCreatedSkillUI.ZhaoInfoUI",
		ZhaoModifyUI = "app.views.ui.SelfCreatedSkillUI.ZhaoModifyUI",
		CurrSkillInfoUI = "app.views.ui.SelfCreatedSkillUI.CurrSkillInfoUI",
		ZhaoImprovedPoolUI = "app.views.ui.SelfCreatedSkillUI.ZhaoImprovedPoolUI",
		BookRackUI = "app.views.ui.SelfCreatedSkillUI.BookRackUI",
		SelfCreatedSkillMenuUI = "app.views.ui.SelfCreatedSkillUI.SelfCreatedSkillMenuUI",
		ZhaoSelectDscUI = "app.views.ui.SelfCreatedSkillUI.ZhaoSelectDscUI",
		
		--图鉴自创武学招式界面
		TujianSelfCreateSkillActiveZhaoInfoLayer = "app.views.layer.TuJianLayer.TujianSelfCreateSkillActiveZhaoInfoLayer",
		--活动界面登录奖励
		LoginRewardLayer = "app.views.layer.ActionLayer.LoginRewardLayer",
		
		SelfCreatedTaskActionLayer = "app.views.layer.ActionLayer.SelfCreatedTaskActionLayer",

		JiangHuYiRenLuActionPresenters = "app.presenters.Activity.JiangHuYiRenLuActionPresenters",
		
		JiangHuMingWuLuActionPresenters = "app.presenters.Activity.JiangHuMingWuLuActionPresenters",

		DailyTasksActivityPresenters = "app.presenters.Activity.DailyTasksActivityPresenters",

		SpringEquinoxPresenters = "app.presenters.Activity.SpringEquinoxPresenters",

		MingShiZhiYuePresenters = "app.presenters.Activity.MingShiZhiYuePresenters",
		--2021春分活动相关
		FundActivityLayer = "app.views.layer.ActionLayer.SpringFestival_2021.FundActivityLayer",

		FisrtChargePresenters = "app.presenters.Activity.FisrtChargePresenters",

		IntelligenceUI = "app.views.ui.IntelligenceUI.IntelligenceUI",
		JiangHuSecretUI = "app.views.ui.IntelligenceUI.JiangHuSecretUI",

		JiangHuMiBaoPresenters = "app.presenters.Activity.JiangHuMiBaoPresenters",

		QuestionAndAnswerPresenters = "app.presenters.Activity.QuestionAndAnswerPresenters",
		MailBoxLayer = "app.views.layer.MailBoxLayer.MailBoxLayer",

		DreamStoreLayer = "app.views.layer.DreamWorldLayer.DreamStoreLayer",
		GuideSystemPresenters = "app.presenters.GuideSystem.GuideSystemPresenters",
		BiLuPresenters = "app.presenters.GuideSystem.BiLuPresenters",

		MaskUpgradeLayer = "app.views.layer.DecorativeBoxLayer.MaskUpgradeLayer",

		ChessboardLayer = "app.views.layer.ChessboardLayer.ChessboardLayer",
		ChessLeaveLayer = "app.views.layer.ChessboardLayer.ChessLeaveLayer",
		ChessCompleteLayer = "app.views.layer.ChessboardLayer.ChessCompleteLayer",

		JiangHuDuoBaoPresenters = "app.presenters.Activity.JiangHuDuoBaoPresenters",
		
		recordAndLearnSKillsPresenters = "app.presenters.recordAndLearnSKills.recordAndLearnSKillsPresenters",

		HangUpTaskStartInfoPresenter = "app.presenters.Tasks.HangUpTaskStartInfoPresenter",
		
		--@desc 防沉迷温馨提醒界面
		WarmPromptLayer = "app.views.layer.DialogLayer.WarmPromptLayer",
		
		ActiveSkillInfoInBattlePresenters = "app.presenters.Skill.ActiveInfo.ActiveSkillInfoInBattlePresenters",
		--新版天缘奇盒
		NewRandomGiftPresenters = "app.presenters.Activity.NewRandomGiftPresenters",
		--香囊密阁
		XiangNangMiGePresenters = "app.presenters.Activity.XiangNangMiGePresenters",
		--叠金充值
		DieJinChongZhiPresenters = "app.presenters.Activity.DieJinChongZhiPresenters",

		--@desc 南柯梦境开箱界面
		FondDrOpenBoxLayer = "app.views.layer.FondDrLayer.FondDrOpenBoxLayer",
		Dialog17Layer = "app.views.layer.DialogLayer.Dialog17Layer",

		--背包升级界面
		BagUpgradePresenters = "app.presenters.BagUpgrade.BagUpgradePresenters",
		-- 年兽活动
		NianBeastPresenters = "app.presenters.Activity.NianBeastPresenters",
		--活动规则界面
		ActionRuleUI = "app.views.ui.ActionUI.ActionRuleUI",

		--洗髓经说明界面
		XiSuiJingInfoUI = "app.views.ui.SkillUI.XiSuiJingInfoUI",

		--年龄弹窗
		GamePopLayer = "app.views.layer.PopLayer.GamePopLayer",

		--@desc 挑战副本详情界面
		ChallengeMapDetailPresenter = "app.presenters.ChallengeMap.ChallengeMapDetailPresenter",
		FestivalMapDetailPresenter = "app.presenters.ChallengeMap.FestivalMapDetailPresenter",
		ConcealMapDetailPresenter = "app.presenters.ChallengeMap.ConcealMapDetailPresenter",
		ChallengeMapFinishPresenter = "app.presenters.ChallengeMap.ChallengeMapFinishPresenter",
		ChallengeMapLosePresenter = "app.presenters.ChallengeMap.ChallengeMapLosePresenter",
		ChoiceResultPresenter = "app.presenters.ChallengeMap.ChoiceResultPresenter",
		ChallengeMapCustomsPresenter = "app.presenters.ChallengeMap.ChallengeMapCustomsPresenter",
		TimeChoiceResultPresenter = "app.presenters.ChallengeMap.TimeChoiceResultPresenter",
		ChallengeMapSucChoicePresenter = "app.presenters.ChallengeMap.ChallengeMapSucChoicePresenter",
		FishingPresenter = "app.presenters.ChallengeMap.MiniGame.FishingPresenter",
		AnswerPresenter = "app.presenters.ChallengeMap.MiniGame.AnswerPresenter",

		--@desc 武学突破
		SkillBreakPopPresent = "app.presenters.SkillBreakThrough.SkillBreakPopPresent",
		ZhaoBreakPopPresent = "app.presenters.SkillBreakThrough.ZhaoBreakPopPresent",
		VolumeBoxPresent = "app.presenters.SkillBreakThrough.VolumeBoxPresent",
		--续卷商人
		XuJuanStorePresent = "app.presenters.Store.XuJuanStorePresent",
		--限时历练
		LimitedTimeExperienceUI = "app.views.ui.ActionUI.LimitedTimeExperienceUI",

		--@desc 准备技能选择类型
		SkillSelectPrepareTypePresenter = "app.presenters.Skill.SelectPrepareType.SkillSelectPrepareTypePresenter",

		ChangeHouseSkinPresenters = "app.presenters.ChangeHouseSkin.ChangeHouseSkinPresenters",
		-- 练武场
		PracticeOfSkillUI = "app.views.ui.ActionUI.PracticeOfSkillUI",
		-- 千杯不醉活动
		DrinkMoreUI = "app.views.ui.ActionUI.DrinkMoreUI",
		

		--@desc 新版练功
		LianGongPresenter ="app.presenters.LianGong.LianGongPresenter",
		LianGongDetailPresenter = "app.presenters.LianGong.LianGongDetailPresenter",

		XiuLianPresenter = "app.presenters.XiuLian.XiuLianPresenter",
		XiuLianDetailPresenter = "app.presenters.XiuLian.XiuLianDetailPresenter",

		XinShenPresenter = "app.presenters.LianGong.XinShenPresenter",
		XinShenRecoveryPresenter = "app.presenters.LianGong.XinShenRecoveryPresenter",
		
		--地仓府库活动
		WareHouseUI = "app.views.ui.ActionUI.WareHouseUI",

		AnniversaryLoginRewardPresenter = "app.presenters.Activity.AnniversaryLoginRewardPresenter",

		--观影堂
		CommercialTimePresenter = "app.presenters.CommercialTime.CommercialTimePresenter",
		CommercialTimePrivilegeComfirmPresent = "app.presenters.CommercialTime.CommercialTimePrivilegeComfirmPresent",
		CommercialTimePrivilegePresenter= "app.presenters.CommercialTime.CommercialTimePrivilegePresenter",

		--日掷斗金
		YuanBaoConsumeActionPresenter = "app.presenters.Activity.YuanBaoConsumeActionPresenter",

		--丹青阁
		DanQingGePresenter = "app.presenters.Activity.DanQingGePresenter",

		--拳脚系统相关界面
		SpeedUpGuaJiPresenter = "app.presenters.FistFoot.SpeedUpGuaJiPresenter",
		TechniqueImprovePresenter = "app.presenters.FistFoot.TechniqueImprovePresenter",
		TechniqueUnlockPresenter = "app.presenters.FistFoot.TechniqueUnlockPresenter",

		KungFuTrailsPresenter = "app.presenters.Activity.KungFuTrailsPresenter",

		JiangHuZhenPinGePresenters = "app.presenters.Activity.JiangHuZhenPinGePresenters",

		WakeUpActionPresenter = "app.presenters.Activity.WakeUpActionPresenter",

		BindingTestMailLayer = "app.views.layer.EmailLayer.BindingTestMailLayer",
		ChongZhiJiFenGoodsPresenter = "app.presenters.Activity.ChongZhiJiFenGoodsPresenter",
		
		BasicSkillDetailPresenter = "app.presenters.Skill.SkillDetail.BasicSkillDetailPresenter",
		
		BasicActiveSkillDetailPresenter = "app.presenters.Skill.SkillDetail.BasicActiveSkillDetailPresenter",

		--练武场活动进阶
		PracticeSkillPresenter = "app.presenters.Activity.PracticeSkillPresenter",

		ShenBingAutoCuiLianLayer = "app.views.layer.ShenBingLayer.DuanZao.ShenBingAutoCuiLianLayer",
		
		ShenBingAutoCuiLianDetailLayer = "app.views.layer.ShenBingLayer.DuanZao.ShenBingAutoCuiLianDetailLayer",

		ShenBingNpcAutoCuiLianLayer = "app.views.layer.ShenBingLayer.DuanZao.ShenBingNpcAutoCuiLianLayer",
		
		ShenBingNpcAutoCuiLianDetailLayer = "app.views.layer.ShenBingLayer.DuanZao.ShenBingNpcAutoCuiLianDetailLayer",

		BuyCurrencyPresenter = "app.presenters.Activity.BuyCurrencyPresenter",

		ShenBingWareHouseLayer = "app.views.layer.ShenBingLayer.ShenBingWareHouseLayer",

		XuanBingDongBagLayer = "app.views.layer.ShenBingLayer.XuanBingDongBagLayer",

		WeaponDescInfoPresenter = "app.presenters.ItemDescInfo.WeaponDescInfoPresenter",

		ArmorDescInfoPresenter = "app.presenters.ItemDescInfo.ArmorDescInfoPresenter",

		JuBaoPenPresenter = "app.presenters.Activity.JuBaoPenPresenter",

		MeridianSkillPeiYuanLayer = "app.views.layer.SkillLayer.MeridianSkillPeiYuanLayer",

		MeridianSkillInfoUI = "app.views.ui.SkillUI.MeridianSkillInfoUI",

		MeridianSkillUseConfirmUI = "app.views.ui.SkillUI.MeridianSkillUseConfirmUI",
		
		BlackStorePresenter = "app.presenters.Store.BlackStorePresenter",

		BlackStoreGoodsSelectPresenter = "app.presenters.Store.BlackStoreGoodsSelectPresenter",

		CangJingGePresenter = "app.presenters.Activity.CangJingGePresenter",

		BlackStoreResultPresenter = "app.presenters.Store.BlackStoreResultPresenter",

		TeacherBuildSpeedUpPresenter = "app.presenters.TeacherBuild.TeacherBuildSpeedUpPresenter",
		
		CuiLianCaiLiaoStorePresenter = "app.presenters.Activity.CuiLianCaiLiaoStorePresenter",

		CuiLianCaiLiaoStoreSelectPresenter = "app.presenters.Activity.CuiLianCaiLiaoStoreSelectPresenter",

		DepartFromFamilyTextAnimLayer = "app.views.layer.DepartFromFamilyLayer.DepartFromFamilyTextAnimLayer",
		TeacherBuildUpgradePresenter = "app.presenters.TeacherBuild.TeacherBuildUpgradePresenter",
		TeacherBuildItemPresenter = "app.presenters.TeacherBuild.TeacherBuildItemPresenter",
		ReputationStorePresenter = "app.presenters.Store.ReputationStorePresenter",
		JiangHuZhenPinGeSelectPresenter = "app.presenters.Activity.JiangHuZhenPinGeSelectPresenter",
		ItemIconDescInfoPresenter = "app.presenters.ItemDescInfo.ItemIconDescInfoPresenter",
		NaturalAttrAdjustmentPlanPresenter = "app.presenters.NaturalAttrAdjustmentPlan.NaturalAttrAdjustmentPlanPresenter",
		SelectCostItemToSwitchAttrPlanPresenter = "app.presenters.NaturalAttrAdjustmentPlan.SelectCostItemToSwitchAttrPlanPresenter",
		KnowledgeSkillDetailShowPresenter = "app.presenters.Skill.SkillDetail.KnowledgeSkillDetailShowPresenter",
		FamilyExchangeStorePresenter = "app.presenters.Store.FamilyExchangeStorePresenter",

		SkillUpgradePresent = "app.presenters.Skill.SkillUpgrade.SkillUpgradePresent",
		SkillUpgradeConfirmPresent = "app.presenters.Skill.SkillUpgrade.SkillUpgradeConfirmPresent",
		TeacherBuildPromotePresenter = "app.presenters.TeacherBuild.TeacherBuildPromotePresenter",
		TeacherBuildResExchangeStorePresenter = "app.presenters.Store.TeacherBuildResExchangeStorePresenter",
		MakeMaskPresenter = "app.presenters.Mask.MakeMaskPresenter",
		MaskInfoPresenter = "app.presenters.Mask.MaskInfoPresenter",
		MaskRoleInfoBorderPresenter = "app.presenters.Mask.MaskRoleInfoBorderPresenter",
		MakeMaskSecretGiftPresenter = "app.presenters.Activity.MakeMaskSecretGiftPresenter",
		GoodsInfoMainPresenter = "app.presenters.GoodsInfo.GoodsInfoMainPresenter",
		
		FistFootShopPresenter = "app.presenters.Activity.FistFootShop.FistFootShopPresenter",
		FistFootShopDayPaySelectPresenter = "app.presenters.Activity.FistFootShop.FistFootShopDayPaySelectPresenter",
		FistFootShopBuySpecialOfferPresenter = "app.presenters.Activity.FistFootShop.FistFootShopBuySpecialOfferPresenter",
		FistFootShopBuySpecialOfferConfirmPresenter = "app.presenters.Activity.FistFootShop.FistFootShopBuySpecialOfferConfirmPresenter",
		FistFootShopBuyDayConfirmPresenter = "app.presenters.Activity.FistFootShop.FistFootShopBuyDayConfirmPresenter",

		MeridianInheritPresenter = "app.presenters.Meridian.MeridianInheritPresenter",
		MeridianRebuildPresenter = "app.presenters.Meridian.MeridianRebuildPresenter",

		replaceMeridianImprintingDebugLayer = "app.views.layer.DebugLayer.MeridianDebug.replaceMeridianImprintingDebugLayer",
		addMeridianImprintingDebugLayer = "app.views.layer.DebugLayer.MeridianDebug.addMeridianImprintingDebugLayer",

		MapRoleSkillInfoUI = "app.views.ui.MapRoleUI.MapRoleSkillInfoUI",
		MapRoleBagUI = "app.views.ui.MapRoleUI.MapRoleBagUI",
		MapRoleItemUI  = "app.views.ui.MapRoleUI.MapRoleItemUI",
		MapRoleAttrUI = "app.views.ui.MapRoleUI.MapRoleAttrUI",
		DreamMapRoleAttrUI = "app.views.ui.MapRoleUI.DreamMapRoleAttrUI",
		ChallengeMapRoleAttrUI = "app.views.ui.MapRoleUI.ChallengeMapRoleAttrUI",
		DreamMapRoleInfoUI = "app.views.ui.MapRoleUI.DreamMapRoleInfoUI",
		ChallengeMapRoleInfoUI = "app.views.ui.MapRoleUI.ChallengeMapRoleInfoUI",

		HiddenMeridianBreakthroughPresenter = "app.presenters.Meridian.HiddenMeridian.HiddenMeridianBreakthroughPresenter",
		HiddenMeridianYuQiPresenter = "app.presenters.Meridian.HiddenMeridian.HiddenMeridianYuQiPresenter",
		HiddenMeridianBuffPresenter = "app.presenters.Meridian.HiddenMeridian.HiddenMeridianBuffPresenter",
		HiddenMeridianUnlockBuffPresenter = "app.presenters.Meridian.HiddenMeridian.HiddenMeridianUnlockBuffPresenter",
		HiddenMeridianSpeedUpPresenter = "app.presenters.Meridian.HiddenMeridian.HiddenMeridianSpeedUpPresenter",
		AcupointActivatePresenter = "app.presenters.Meridian.HiddenMeridian.AcupointActivatePresenter",
		PuzzleGamePresenter = "app.presenters.ChallengeMap.MiniGame.PuzzleGamePresenter",
		StoreGoodsSelectPresenter = "app.presenters.Store.StoreGoodsSelectPresenter",
		StorePresenter = "app.presenters.Store.StorePresenter",
		YaShiBenefitPresenter = "app.presenters.YaShiBenefit.YaShiBenefitPresenter",
		SkillResExchangePresenter = "app.presenters.Activity.SkillResExchangePresenter",

		BatchUseActiveZhaoPagePresenter = "app.presenters.Skill.BatchUseActivePage.BatchUseActiveZhaoPagePresenter",
		GiftInfoPresenter = "app.presenters.GiftInfo.GiftInfoPresenter",
		YiZhiQianJinPresenter = "app.presenters.Activity.YiZhiQianJinPresenter",
		BaiDuanGePresenter = "app.presenters.Activity.BaiDuanGePresenter",

		ChallengeClearTimesPresenter = "app.presenters.Activity.ChallengeClearTimesPresenter",

	} -- add by XiaoZhiWei 2017/09/11 17:38:22 需要管理的页面列表
	self._layerCache = {} -- add by XiaoZhiWei 2017/09/11 17:42:02 记录一些页面切换的信息,用于管理页面的创建和销毁
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/09/12 10:21:18
-- @desc 获取页面
function PopupLayerController:getLayer(name)
	local layer = self[name]
	if layer == nil then
		local className = assert(self._layers[name], "找不到layer：" .. tostring(name))
		local LayerClass = require(className)
		self[name] = LayerClass:getInstance()
		layer = self[name]
		-- layer:addTo(self)
		layer.PopupLayerController = self
		-- add by XiaoZhiWei 2017/09/12 17:29:25 默认是隐藏状态
		self._layerCache[name] = 
		{
			isShow = false,
			time = GetTime()
		}
	else
	end
	return layer
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/09/11 17:48:23
-- @desc 显示页面
function PopupLayerController:showLayer(name, showFunc)
	--[[
		判断页面是否存在,不存在则创建.然后直接显示
	]]
	local layer = self:getLayer(name)
	print("PopupLayerController:showLayer = ", name, layer)
	layer:maxZ()
	if showFunc then
		showFunc(layer)
	end
	self._layerCache[name] = 
	{
		isShow = true,
		time = GetTime()
	}
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/09/11 17:48:50
-- @desc 隐藏页面
function PopupLayerController:hideLayer(name, hideFunc, removeTime)
	--[[
		隐藏页面,并记录一个时间
	]]
	if hideFunc then
		hideFunc(self:getLayer(name))
	end
	self._layerCache[name] = 
	{
		isShow = false,
		time = GetTime()
	}

	-- add by XiaoZhiWei 2017/09/30 11:28:31 移除时间是数字,并且小于控制器移除间隔.则用延迟移除页面
	if type(removeTime) == "number" and removeTime < UPDATE_INTERVER then
		self:delayFunc(removeTime < 0.5 and 0.5 or removeTime, function()
			if self:checkLayerCanRemoved(name) == true then
				self:removeLayer(name)
			end
		end)
	end
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/09/11 17:49:39
-- @desc 移除页面
function PopupLayerController:removeLayer(name)
	print("PopupLayerController:removeLayer(name) = ", name, type(name))
	-- PopText("页面移除释放 = "..tostring(name))
	--[[
		专门用来移除页面,移除后释放资源
	]]
	local layer = self:getLayer(name)
	if layer then
		layer:removeFromParent()
		self[name] = nil
		self._layerCache[name] = nil
		Game:freeMemorySmart()
	end
end

local canNotRemoveList = 
{
	RoleObserveLayer = true
}
-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/09/30 11:33:17
-- @desc 检查是否能够移除
function PopupLayerController:checkLayerCanRemoved(name)
	local cache = self._layerCache[name]
	-- add by XiaoZhiWei 2017/09/30 11:35:59 未显示 不在排除列表
	if MapIsEmpty(cache) == false and cache.isShow == false and canNotRemoveList[name] ~= true then
		-- assert(MapIsEmpty(cache) == false, "这里存在了异常,缓存为空")
		return true
	else
		return false
	end
end

function PopupLayerController:checkLayerIsShow(name)
	local cache = self._layerCache[name]

	if MapIsEmpty(cache) == true or cache.isShow == false then
		return false
	else
		return true
	end
end


-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/09/11 17:49:12
-- @desc 刷新
function PopupLayerController:update()
	--[[
		遍历页面缓存列表,判断时间是否超出限制,超出则移除
	]]
	local currTime = GetTime()
	for layerName,cache in pairs(self._layerCache) do
		if currTime - cache.time >= UPDATE_INTERVER and self:checkLayerCanRemoved(layerName) == true then
			self:removeLayer(layerName)
		end
	end
end

Helper:classDefNodeGetInstance(PopupLayerController)
return PopupLayerController000000