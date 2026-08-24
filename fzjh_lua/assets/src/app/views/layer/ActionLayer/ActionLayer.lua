
local ActionLayer = class("ActionLayer", cc.Layer)

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/01/14 17:23:08
-- @desc 初始化活动列表
local rowList = {}
local function initActionList(list)
	local funcTab =
	{
		["江湖名士充值加送"] = function(actionId)
			HttpManagerEx:getNewYearFestivalState(actionId,function(status, errcode, errmsg, data)
				if status == 200 and errcode == 0  then
					if data ~= nil and data.is_open == 1 and data.status == 1 then
						local ChongZhiJiaSongLayer = require("app.views.layer.ActionLayer.ChongZhiJiaSongLayer")
						local dsc = ""
						if MapIsEmpty(data.detail_desc) == false then
							for i,desc in ipairs(data.detail_desc) do
								dsc = dsc .. desc .."\n"
							end
						end
						ChongZhiJiaSongLayer:showLayer(actionId,dsc)
					end
				else
					PopText(errmsg)
				end
			end, IS_SHOW_WAITING)
		end,

		["签到活动"] = function(actionId, actionRule)
			Audio:playEffect("daSuanPan")

			local SignIpnLayer = require("app.views.layer.SignInLayer.SignInLayer")
			SignIpnLayer:showLayer()
			SignIpnLayer:initRule(actionRule)
		end,
		["首充活动"] = function(tab, actionRule)
			PopupLayerController:showLayer(
				"FisrtChargePresenters",
				function(layer)
					layer:showLayer()
					layer:initRule(actionRule)
				end
			)
            -- add by XiaoZhiWei 2018/10/16 13:58:50 合并版本,兼容安卓和ios设备
		end,

		["累计充值"] = function(tab)
        	local LeiJiChongZhiLayer = require("app.views.layer.ActionLayer.NewLeiJiChongZhiLayer")
            LeiJiChongZhiLayer:showLayer(tab)
            -- add by XiaoZhiWei 2018/10/16 13:55:38 合并版本,兼容安卓和ios设备
		end,
		["限时礼包累计奖励"] = function(actionId, actionRule)
			local XianShiPointLayer = require("app.views.layer.ActionLayer.XianShiPointLayer")
			XianShiPointLayer:getInstance():showLayer(actionId)
			XianShiPointLayer:getInstance():initRule(actionRule)
		end,
		["春分风筝活动"] = function(actionId)
			-- PopupLayerController:showLayer("FlyKiteLayer",function(layer)
			-- 	layer:getAllTypePoint()
			-- end)
			local role = User:getRole()
            local menpai = role:getFamilyId()
            -- HttpManagerEx:getPersonalBoatScore(menpai,function(status, errcode, errmsg, data)
            HttpManagerEx:getPersonalBoatScore(menpai,function(status, errcode, errmsg, data)
            	if PRINT_MODE == 1 then
            		print("------------------春分风筝活动")
            		Helper:print_lua_table(data)
            	end
                if status == 200 and errcode == 0 then
					PopupLayerController:showLayer("FlyKiteLayer",function(layer)
						layer:showBoatLayer(Helper:getDef(data, {}))
					end)
                else
                    PopText(errmsg)
                end
            end,IS_SHOW_WAITING)
		end,

		["赛龙舟活动"] = function(actionId)
            local role = User:getRole()
            local menpai = role:getFamilyId()
            -- HttpManagerEx:getPersonalBoatScore(menpai,function(status, errcode, errmsg, data)
            HttpManagerEx:getPersonalBoatScore(menpai,function(status, errcode, errmsg, data)
            	if PRINT_MODE == 1 then
            		print("bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb赛龙舟活动bbbbbbbbbbbb")
            		Helper:print_lua_table(data)
            	end
                if status == 200 and errcode == 0 then
					PopupLayerController:showLayer("PlayDragonBoatLayer",function(layer)
						layer:showBoatLayer(Helper:getDef(data, {}))
					end)
                else
                    PopText(errmsg)
                end
            end,IS_SHOW_WAITING)
		end,

        ["江湖三友"] = function(actionId, actionRule)
			HttpManagerEx:getNewYearFestivalState(actionId,function(status, errcode, errmsg, data)
				if status == 200 and errcode == 0  then
					local dsc = ""
					if MapIsEmpty(data.detail_desc) == false then
						for i,desc in ipairs(data.detail_desc) do
							dsc = dsc .. desc .."\n"
						end
					end
					HttpManagerEx:getJhSanYouList(function(status, errcode, errmsg, data)
						if status == 200 and errcode == 0 then
							PopupLayerController:showLayer("JiangHuSanYouLayer",function(layer)
								layer:setDesc(dsc)
								layer:showLayer(data.list,data.canVote)
								layer:initRule(actionRule)
							end)
						else
							PopText(errmsg)
						end
					end,IS_SHOW_WAITING)
				else
					PopText(errmsg)
				end
			end, IS_SHOW_WAITING)
        	
        end,
        ["大侠的成长之路"] = function(actionId, actionRule)
        	PopupLayerController:showLayer("DaXiaChenZhangZhiLuLayer",function(layer)
	     		layer:showLayer(actionId)
				layer:initRule(actionRule)
	    	end)
        end,
		["充值积分兑换"] = function(actionId, actionRule)
			PopupLayerController:showLayer("AnniversaryCelebrationConversionLayer", function(layer)
				layer:showLayer("zhounianqin_cz",actionId)
				layer:initRule(actionRule)
			end)
		end,
		--@desc 界面服务器数据更改，只修改了充值积分，如有需求通知服务器修改
		-- ["周年庆积分兑换"] = function(actionId, actionRule)
		-- 	PopupLayerController:showLayer("AnniversaryCelebrationConversionLayer", function(layer)
		-- 		layer:showLayer("zhounianqin_jf",actionId)
		-- 	end)
		-- end,
		-- ["武道七日谈"] = function(actionId, actionRule)
		-- 	PopupLayerController:showLayer("AnniversaryCelebrationConversionLayer", function(layer)
		-- 		layer:showLayer("wudaoshop",actionId)
		-- 	end)
		-- end,
		["充值特惠"] = function(actionId)
			if device.platform == "android" then
				if CURR_DEVICE_CHANNEL == "4399" then
					local ZhouNianQingChongZhiLayer = require("app.views.layer.ActionLayer.ZhouNianQingChongZhiLayer")	
					ZhouNianQingChongZhiLayer:showLayer(actionId)
				elseif CURR_DEVICE_CHANNEL == "yyh" then

				end
			elseif device.platform == "ios" then

			else
				local ZhouNianQingChongZhiLayer = require("app.views.layer.ActionLayer.ZhouNianQingChongZhiLayer")	
				ZhouNianQingChongZhiLayer:showLayer(actionId)
			end 
		end,
		["充值抽奖领周边"] = function(actionId)
			local PhysicalLotteryLayer = require("app.views.layer.ActionLayer.PhysicalLotteryLayer")	
			PhysicalLotteryLayer:showLayer(actionId)	
		end,
		["暑期开心大礼包"] = function(actionId)
			local NewSignInGiftBagLayer = require("app.views.layer.ActionLayer.NewSignInGiftBagLayer")	
			NewSignInGiftBagLayer:showLayer(actionId)
		end,
		["应用汇活动礼包"] = function(actionId)
			if device.platform == "android" then
				if CURR_DEVICE_CHANNEL == "4399" then

				elseif CURR_DEVICE_CHANNEL == "yyh" then
					local SignInGiftBagLayer = require("app.views.layer.ActionLayer.SignInGiftBagLayer")	
					SignInGiftBagLayer:showLayer(actionId)
				end
			elseif device.platform == "ios" then

			else
				local SignInGiftBagLayer = require("app.views.layer.ActionLayer.SignInGiftBagLayer")	
				SignInGiftBagLayer:showLayer(actionId)
			end 
		end,
		["4399独家礼包"] = function(actionId)
			if device.platform == "android" then
				if CURR_DEVICE_CHANNEL == "4399" then
					local SignInGiftBagLayer = require("app.views.layer.ActionLayer.SignInGiftBagLayer")	
					SignInGiftBagLayer:showLayer(actionId)
				elseif CURR_DEVICE_CHANNEL == "yyh" then

				end
			elseif device.platform == "ios" then

			else
				local SignInGiftBagLayer = require("app.views.layer.ActionLayer.SignInGiftBagLayer")	
				SignInGiftBagLayer:showLayer(actionId)
			end 
		end,
		["4399暑期清凉礼包"] = function(actionId)
			if device.platform == "android" then
				if CURR_DEVICE_CHANNEL == "4399" then
					local SignInGiftBagLayer = require("app.views.layer.ActionLayer.SignInGiftBagLayer")	
					SignInGiftBagLayer:showLayer(actionId)
				elseif CURR_DEVICE_CHANNEL == "yyh" then

				end
			elseif device.platform == "ios" then

			else
				local SignInGiftBagLayer = require("app.views.layer.ActionLayer.SignInGiftBagLayer")	
				SignInGiftBagLayer:showLayer(actionId)
			end 
		end,
		["4399独家定制礼包"] = function(actionId)
			if device.platform == "android" then
				if CURR_DEVICE_CHANNEL == "4399" then
					local SignInGiftBagLayer = require("app.views.layer.ActionLayer.SignInGiftBagLayer")	
					SignInGiftBagLayer:showLayer(actionId)
				elseif CURR_DEVICE_CHANNEL == "yyh" then

				end
			elseif device.platform == "ios" then

			else
				local SignInGiftBagLayer = require("app.views.layer.ActionLayer.SignInGiftBagLayer")	
				SignInGiftBagLayer:showLayer(actionId)
			end 
		end,
		["4399独家开学礼包"] = function(actionId)
			if device.platform == "android" then
				if CURR_DEVICE_CHANNEL == "4399" then
					local SignInGiftBagLayer = require("app.views.layer.ActionLayer.SignInGiftBagLayer")	
					SignInGiftBagLayer:showLayer(actionId)
				elseif CURR_DEVICE_CHANNEL == "yyh" then

				end
			elseif device.platform == "ios" then

			else
				local SignInGiftBagLayer = require("app.views.layer.ActionLayer.SignInGiftBagLayer")	
				SignInGiftBagLayer:showLayer(actionId)
			end 
		end,
		["4399独家教师节礼包"] = function(actionId)
			if device.platform == "android" then
				if CURR_DEVICE_CHANNEL == "4399" then
					local SignInGiftBagLayer = require("app.views.layer.ActionLayer.SignInGiftBagLayer")	
					SignInGiftBagLayer:showLayer(actionId)
				elseif CURR_DEVICE_CHANNEL == "yyh" then

				end
			elseif device.platform == "ios" then

			else
				local SignInGiftBagLayer = require("app.views.layer.ActionLayer.SignInGiftBagLayer")	
				SignInGiftBagLayer:showLayer(actionId)
			end 
		end,
		["4399独家国庆节礼包"] = function(actionId)
			if device.platform == "android" then
				if CURR_DEVICE_CHANNEL == "4399" then
					local SignInGiftBagLayer = require("app.views.layer.ActionLayer.SignInGiftBagLayer")	
					SignInGiftBagLayer:showLayer(actionId)
				elseif CURR_DEVICE_CHANNEL == "yyh" then

				end
			elseif device.platform == "ios" then

			else
				local SignInGiftBagLayer = require("app.views.layer.ActionLayer.SignInGiftBagLayer")	
				SignInGiftBagLayer:showLayer(actionId)
			end 
		end,
		["4399新手礼包"] = function(actionId)
			if device.platform == "android" then
				if CURR_DEVICE_CHANNEL == "4399" then
					local SignInGiftBagLayer = require("app.views.layer.ActionLayer.SignInGiftBagLayer")	
					SignInGiftBagLayer:showLayer(actionId)
				elseif CURR_DEVICE_CHANNEL == "yyh" then

				end
			elseif device.platform == "ios" then

			else
				local SignInGiftBagLayer = require("app.views.layer.ActionLayer.SignInGiftBagLayer")	
				SignInGiftBagLayer:showLayer(actionId)
			end 
		end,
		["一掷千金"] = function(actionId, actionRule)
			PopupLayerController:showLayer("YiZhiQianJinPresenter",function(layer)
				layer:showLayer()
				layer:initRule(actionRule)
			end)
		end,
		["中秋问卷"] = function (actionId)

			HttpManagerEx:getNewYearFestivalState(actionId,function (status, errcode, errmsg, data)
				if status == 200 and errcode == 0 then
					Helper:print_lua_table(data)
					--@RefType [app.models.role.Role#Role]
					local role = User:getRole()
					local flag = role:getInheritFlag("MidAutumn")
					if flag ~= "finish" then		
						PopupLayerController:showLayer("MidAutumnQue", function(layer)
							local text = "致各位大侠： \n \n"
							.."\t\t花开花落，月缺月圆。在中秋佳节之际，江湖世界陪伴大家度过分别与难忘的夏夜，迎来重逢与新识的秋天。 \n \n"
							.."\t\t正值这个桂子飘香之际，有新鲜血液流入江湖，为这个世界增添活力，也有那些熟悉的面孔，在背后用宽容默默地支持。 \n \n"
							.."\t\t相逢即为缘，我们希望江湖世界能带给支持者欢笑，也希望不断地优化，与更多人相逢相识。 \n \n"
							.."\t\t为此，我们决定在中秋推出问卷调查活动，让各位大侠描绘出心中最想要的江湖。江湖世界也将因各位大侠的选择做出改变。 \n \n \n \n"
							.."\t\t祝各位大侠中秋快乐，游戏愉快！"
							layer:show(data)
							layer:setDesc(text)
						end)
					else
						PopText("您已参加过此次问卷调查。")
					end 
				else
					if DEBUG_MODE == 1 then
						PopText(errmsg)
					end
					PopText("网络出错，请重试！")
				end
			end)

		end,
		["调查问卷"] = function (actionId)

			HttpManagerEx:getNewYearFestivalState(actionId,function (status, errcode, errmsg, data)
				if status == 200 and errcode == 0 then
					Helper:print_lua_table(data)
					--@RefType [app.models.role.Role#Role]
					local role = User:getRole()
					local flag = role:getInheritFlag("Question")
                    local tiankongtiFlag = role:getInheritFlag("tiankongti")
					-- local flagCount = role:getFlag("问卷调查次数")
					if flag ~= "finish" and tiankongtiFlag == 0 then
	                    PopupLayerController:showLayer("MidAutumnQue", function(layer)
							local text = "致各位少侠： \n \n"
							.."\t\t寒去暑来，夏日将近，《放置江湖》与诸位少侠从相识到相知，已过去不少日夜。 \n \n"
							.."\t\t在感谢诸位少侠一路以来的包容与支持外，我们也深知自己尚存诸多不足。 \n \n"
							.."\t\t对此，我们在这里放出问卷调查一份，望诸位少侠踊跃参与，提出宝贵的看法与意见。 \n \n"
							.."\t\t我们将针对少侠们的意见，不断改正提高，以此为大家带来更好更理想的江湖。 \n \n"
							.."\t\t作为回报，参与调查的少侠在答完问卷内所有题目后，系统会自动发放神秘礼盒一份，传承后无法再次参与。 \n \n \n \n"
							.."\t\t祝各位少侠游戏愉快。"
							layer:show(data)
							layer:setDesc(text)
						end)
					elseif flag == "finish"	and tiankongtiFlag == 0 then
					    local QuestionnaireLayer = require("app.views.layer.ActionLayer.QuestionnaireLayer")
	                    local dialog = QuestionnaireLayer:getInstance()
	                    dialog:showLayer()
	                    if PRINT_MODE == 1 then
	                        print("11111111111111111111111111111111111111111111111111",tiankongtiFlag)
	                    end   
	                else
						PopText("您已参加过此次问卷调查。")
					end 
				else
					if DEBUG_MODE == 1 then
						PopText(errmsg)
					end
					PopText("网络出错，请重试！")
				end
			end)

		end,
		["礼包兑换"] = function(actionId)
			PopupLayerController:showLayer("SignInMaskGiftLayer",function(layer)
				layer:show()
				layer:initLayer(actionId)
			end)
		end,
		["江湖狂欢礼包"] = function(actionId)
			local currTime = GetTime()
			local yuanxiaoTime = Helper:getTimeStampWithStringDate("20170212",0)
			local XianShiLayer = require("app.views.layer.ActionLayer.KuangHuanLayer"):getInstance()
			XianShiLayer:getState(actionId)
		end,
		["迎春聚福"] = function(actionId, actionRule)
	        local ConsumeWingLayer = require("app.views.layer.ActionLayer.ConsumeWingLayer")
            ConsumeWingLayer:showLayer(actionId)
			ConsumeWingLayer:initRule(actionRule)
		end,
		["叠金同庆"] = function(actionId, actionRule)
			local ConsumeWingLayer = require("app.views.layer.ActionLayer.ConsumeWingLayer")
            ConsumeWingLayer:showLayer(actionId)
			ConsumeWingLayer:initRule(actionRule)
		end,
		["江湖名人录"] = function(actionId)
			-- local ConsumeWingLayer = require("app.views.layer.ActionLayer.ConsumeWingLayer")
			-- ConsumeWingLayer:showLayer(actionId)
			PopupLayerController:showLayer(
                "JiangHuYiRenLuActionPresenters",
                function(layer)
                    layer:showLayer()
                end
            )
		end,
		["江湖名武录"] = function(actionId)
			PopupLayerController:showLayer(
                "JiangHuMingWuLuActionPresenters",
                function(layer)
                    layer:showLayer()
                end
            )
		end,
		["江湖珍品阁"] = function(activity_id,actionId, actionRule)
			--旧江湖珍品阁
			if activity_id == "jianghumingwu" then
				PopupLayerController:showLayer(
					"JiangHuMingWuLuActionPresenters",
					function(layer)
						layer:showLayer()
						layer:initRule(actionRule)
					end
				)
			else --新版
				PopupLayerController:showLayer(
					"JiangHuZhenPinGePresenters",
					function(layer)
						layer:setActionId(activity_id)
						layer:showLayer()
						layer:initRule(actionRule)
					end
				)
			end
		end,
		["财神帮的聚宝盆"] = function(actionId, actionRule)
	        local ConsumeWingLayer = require("app.views.layer.ActionLayer.ConsumeWingLayer")
            ConsumeWingLayer:showLayer(actionId)
			ConsumeWingLayer:initRule(actionRule)
		end,
		["迎新大吉"] = function(actionId)
			HttpManagerEx:getNewYearFestivalState(actionId,function(status, errcode, errmsg, data)
				if status == 200 and errcode == 0  then
					if data ~= nil and data.is_open == 1 and data.status == 1 then
						local ChongZhiChouJiangLayer = require("app.views.layer.ActionLayer.ChongZhiChouJiangLayer")
						ChongZhiChouJiangLayer:getInstance():showLayer(data) 
					end
				else
					PopText(errmsg)
				end
			end, IS_SHOW_WAITING)

		end,
		["每日充值抽奖"] = function(actionId, actionRule)
			HttpManagerEx:getNewYearFestivalState(actionId,function(status, errcode, errmsg, data)
				if status == 200 and errcode == 0  then
					if data ~= nil and data.is_open == 1 and data.status == 1 then
						local NewChongZhiChouJiangLayer = require("app.views.layer.ActionLayer.NewChongZhiChouJiangLayer")
						NewChongZhiChouJiangLayer:getInstance():showLayer(data)
						NewChongZhiChouJiangLayer:getInstance():initRule(actionRule)
					end
				else
					PopText(errmsg)
				end
			end, IS_SHOW_WAITING)

		end,
		["江湖回忆录"] = function(actionId)
			local layer = require("app.views.layer.ActionLayer.ZhangDanLayer"):getInstance()
			layer:showLayer(actionId)
		end,
		["江湖换物节"] = function(actionId, actionRule)
			PopupLayerController:showLayer("JiangHuHaoYunLaiLayer",function(layer)
				layer:showLayer(actionId)
				layer:initRule(actionRule)
			end)
		end,
		["汇字天成"] = function(actionId)
			HttpManagerEx:getNewYearFestivalState(actionId,function(status, errcode, errmsg, data)
				if status == 200 and errcode == 0  then
					if data ~= nil and data.is_open == 1 and data.status == 1 then
						PopupLayerController:showLayer("ChongGuangDuiHuanLayer",function(layer)
							local SFTokenCollection2019 = require("app.models.SpringFestival.2019.SFTokenCollection2019")
							SFTokenCollection2019:initConfig()
							layer:setConfig(SFTokenCollection2019:getConfig())
							layer:showLayer(data)
						end)
					end
					
				else
					PopText(errmsg)
				end
			end, IS_SHOW_WAITING)
		end,
		["妙物兑宝"] = function(actionId)
			HttpManagerEx:getNewYearFestivalState(actionId,function(status, errcode, errmsg, data)
				if status == 200 and errcode == 0  then
					if data ~= nil and data.is_open == 1 and data.status == 1 then
						PopupLayerController:showLayer("TokenExchangeActivityLayer",function(layer)
							layer:showLayer(data)
						end)
					end
					
				else
					PopText(errmsg)
				end
			end, IS_SHOW_WAITING)
		end,

		["馆主的谢礼"] = function(actionId)
			PopupLayerController:showLayer("GuanZhuXieLiLayer",function(layer)
				layer:showLayer(actionId)
			end)
		end,
		["江湖迎春归"] = function(actionId)
			local SuiMoJiFuLayer = require("app.views.layer.ActionLayer.SuiMoJiFuLayer"):getInstance()
			SuiMoJiFuLayer:showLayer(actionId)
		end,
		["新春英雄宴"] = function(actionId)
			local HeroFeastRewardsLayer = require("app.views.layer.ActionLayer.HeroFeastLayer.HeroFeastRewardsLayer"):getInstance()
			HeroFeastRewardsLayer:showLayer(actionId)
		end,
		["限时充值加送"] = function(actionId)
			local LimitDiscountLayer = require("app.views.layer.ActionLayer.LimitDiscountLayer"):getInstance()
			LimitDiscountLayer:showLayer(actionId)
		end,
		["宝阁失窃"] = function(actionId)
			PopupLayerController:showLayer("QiXiLoveLetterLayer",function(layer)
				layer:showLayer(actionId)
			end)
		end,
		["名师高徒"] = function(actionId)

			HttpManagerEx:getNewYearFestivalState(actionId,function(status, errcode, errmsg, data)
				if status == 200 and errcode == 0  then
					if data ~= nil and data.is_open == 1 and data.status == 1 then
						PopupLayerController:showLayer("QiXiMingShiGaoTuLayer",function(layer)
							layer:showLayer(data)
						end)
					end
				else
					PopText(errmsg)
				end
			end, IS_SHOW_WAITING)
		end,
		["豪礼贺国岁"] = function(actionId)
			HttpManagerEx:getNewYearFestivalState(actionId,function(status, errcode, errmsg, data)
				if status == 200 and errcode == 0  then
					if data ~= nil and data.is_open == 1 and data.status == 1 then
						Helper:print_lua_table(data)
						PopupLayerController:showLayer("GuoQingKuangHuanLayer",function(layer)
							layer:showLayer(data)
						end)
					end
				else
					PopText(errmsg)
				end
			end, IS_SHOW_WAITING)
		end,
		["天缘奇盒"] = function(activity_id,actionId, actionRule)
			--旧天缘奇盒 使用id
			if activity_id == "2020xcsuijilibao" then
				HttpManagerEx:getNewYearFestivalState(actionId,function(status, errcode, errmsg, data)
					if status == 200 and errcode == 0  then
						if data ~= nil and data.is_open == 1 and data.status == 1 then
							Helper:print_lua_table(data)
							PopupLayerController:showLayer("RandomGiftLayer",function(layer)
								layer:showLayer(data)
							end)
						end
					else
						PopText(errmsg)
					end
				end, IS_SHOW_WAITING)
			else --新版使用 activity_id
				PopupLayerController:showLayer("NewRandomGiftPresenters",function(layer)
					layer:setActionId(activity_id)
					layer:showLayer()
					layer:initRule(actionRule)
				end)
			end
			
		end,
		["七日登录"] = function(actionId)
			HttpManagerEx:getNewYearFestivalState(actionId,function(status, errcode, errmsg, data)
				if status == 200 and errcode == 0  then
					if data ~= nil and data.is_open == 1 and data.status == 1 then
						HttpManagerEx:getLoginYuandanInfo(function(status, errcode, errmsg, data)
							if status == 200 and errcode == 0  then
								PopupLayerController:showLayer("LoginRewardLayer",function(layer)
									layer:showLayer(data)
								end)
							else
								PopText(errmsg)
							end
						end, IS_SHOW_WAITING)
					end
				else
					PopText(errmsg)
				end
			end, IS_SHOW_WAITING)
		end,

		["江湖宝藏"] = function(actionId)
			HttpManagerEx:getNewYearFestivalState(actionId,function(status, errcode, errmsg, data)
				if status == 200 and errcode == 0  then
					if data ~= nil and data.is_open == 1 and data.status == 1 then
						local ChongZhiChouJiangLayer = require("app.views.layer.ActionLayer.LaBaChongZhiChouJiangLayer")
						ChongZhiChouJiangLayer:getInstance():showLayer(data) 
					end
				else
					PopText(errmsg)
				end
			end, IS_SHOW_WAITING)
		end,

		["地宫古迹"] = function (actionId)

			local role = User:getRole()
			if role:getSelfCreatedSkillSystem():isOpenSystem() == false then
				PopText("神功系统未开启")
				return 
			end

			HttpManagerEx:getNewYearFestivalState(actionId,function(status, errcode, errmsg, data)
				if status == 200 and errcode == 0  then
					if data ~= nil and data.is_open == 1 and data.status == 1 then
						PopupLayerController:showLayer(
							"SelfCreatedTaskActionLayer",
							function(layer)
								layer:setTitleName(data.name)
								local dsc = ""
								if MapIsEmpty(data.detail_desc) == false then
									for i,desc in ipairs(data.detail_desc) do
										dsc = dsc .. desc .."\n"
									end
									layer:setDesc(dsc)
								end
								layer:showLayer()
							end
						)
					end
				else
					PopText(errmsg)
				end
			end, IS_SHOW_WAITING)
		end,
		["宅家充值福利"] = function(actionId, actionRule)
			local ConsumeWingLayer = require("app.views.layer.ActionLayer.ConsumeWingLayer")
            ConsumeWingLayer:showLayer(actionId)
			ConsumeWingLayer:initRule(actionRule)
		end,
		["每日任务"] = function(actionId, actionRule)
			PopupLayerController:showLayer(
				"DailyTasksActivityPresenters",
				function(layer)
					layer:showLayer()
					layer:initRule(actionRule)
				end
			)
		end,
		["充值福利"] = function(actionId, actionRule)
			HttpManagerEx:getActionState(actionId,nil,function(status, errcode, errmsg, data)
				if status == 200 and errcode == 0  then
					if data ~= nil and data.is_open == 1 and data.status == 1 then
						PopupLayerController:showLayer(
							"SpringEquinoxPresenters",
							function(layer)
								layer:setText_desc(data.detail_desc)
								layer:setText_title(data.name)
								layer:showLayer()
								layer:initRule(actionRule)
							end
						)
					end
				else
					PopText(errmsg)
				end
			end, IS_SHOW_WAITING)
		end,

		["小年充值福利"] = function(actionId, actionRule)
			HttpManagerEx:getActionState(actionId,nil,function(status, errcode, errmsg, data)
				if status == 200 and errcode == 0  then
					if data ~= nil and data.is_open == 1 and data.status == 1 then
						PopupLayerController:showLayer(
							"SpringEquinoxPresenters",
							function(layer)
								layer:setText_desc(data.detail_desc)
								layer:setText_title(data.name)
								layer:setActionId(data.activity_id)
								layer:showLayer()
								layer:initRule(actionRule)
							end
						)
					end
				else
					PopText(errmsg)
				end
			end, IS_SHOW_WAITING)
		end,

		["名士之约"] = function(actionId, actionRule)
			PopupLayerController:showLayer(
				"MingShiZhiYuePresenters",
				function(layer)
					layer:setActionId(actionId)
					layer:showLayer()
					layer:initRule(actionRule)
				end
			)
		end,
		["卿云宝阁"] = function(actionId)
			local productKey = "com.mkjump.fzjha.product104"
			HttpManagerEx:getNewYearFestivalState(actionId,function(status, errcode, errmsg, data)
				if status == 200 and errcode == 0  then
					if data ~= nil and data.is_open == 1 and data.status == 1 then
						PopupLayerController:showLayer(
							"FundActivityLayer",
							function(layer)
								local timeStartStr = Helper:getTimeStrCNFormat(data["start"])
								local timeEndStr = Helper:getTimeStrCNFormat(data["end"])
								local dsc = ""
								if MapIsEmpty(data.detail_desc) == false then
									for i,desc in ipairs(data.detail_desc) do
										desc = string.gsub(desc,"#start#",timeStartStr)
										desc = string.gsub(desc,"#end#",timeEndStr)
										dsc = dsc .. desc .."\n"
									end
								end
								layer:setActionTitle(data.name)
								layer:setActionDesc(dsc)
								layer:showLayer(data.activity_id,productKey)
							end
						)
					end
				else
					PopText(errmsg)
				end
			end, IS_SHOW_WAITING)
		end,
		["梨园艺馆"] = function(actionId)
			local productKey = "com.mkjump.fzjha.product105"
			HttpManagerEx:getNewYearFestivalState(actionId,function(status, errcode, errmsg, data)
				if status == 200 and errcode == 0  then
					if data ~= nil and data.is_open == 1 and data.status == 1 then
						PopupLayerController:showLayer(
							"FundActivityLayer",
							function(layer)
								local timeStartStr = Helper:getTimeStrCNFormat(data["start"])
								local timeEndStr = Helper:getTimeStrCNFormat(data["end"])
								local dsc = ""
								if MapIsEmpty(data.detail_desc) == false then
									for i,desc in ipairs(data.detail_desc) do
										desc = string.gsub(desc,"#start#",timeStartStr)
										desc = string.gsub(desc,"#end#",timeEndStr)
										dsc = dsc .. desc .."\n"
									end
								end
								layer:setActionTitle(data.name)
								layer:setActionDesc(dsc)
								layer:showLayer(data.activity_id,productKey)
							end
						)
					end
				else
					PopText(errmsg)
				end
			end, IS_SHOW_WAITING)
		end,

		["江湖秘宝"] = function(actionId, actionRule)
			PopupLayerController:showLayer("JiangHuMiBaoPresenters",function(layer)
				layer:setActionId(actionId)
				layer:showLayer()
				layer:initRule(actionRule)
			end)
		end,

		["江湖夺宝"] = function(actionId, actionRule)
			PopupLayerController:showLayer("JiangHuDuoBaoPresenters",function(layer)
				layer:setActionId(actionId)
				layer:showLayer()
				layer:initRule(actionRule)
			end)
		end,

		["香囊密阁"] = function(actionId, actionRule)
			PopupLayerController:showLayer("XiangNangMiGePresenters",function(layer)
				layer:setActionId(actionId)
				layer:initRule(actionRule)
				layer:showLayer()
			end)
		end,

		["江湖叠金节"] = function(actionId, actionRule)
			PopupLayerController:showLayer("DieJinChongZhiPresenters",function(layer)
				layer:setActionId(actionId)
				layer:initRule(actionRule)
				layer:showLayer()
			end)
		end,

		["驱赶年兽"] = function(actionId, actionRule)
			PopupLayerController:showLayer("NianBeastPresenters",function(layer)
				layer:initRule(actionRule)
				layer:showLayer()
			end)
		end,

		["限时历练"] = function(actionId, actionRule)
			local LimitedTimeExperiencePresenters = require("app.presenters.Activity.LimitedTimeExperiencePresenters")
			local LimitedTimeExperience = require("app.models.Action.LimitedTimeExperience"):create()
			local LimitedTimeExperienceUI = PopupLayerController:getLayer("LimitedTimeExperienceUI")
			local limitedTimeExperiencePresenter = LimitedTimeExperiencePresenters:create(LimitedTimeExperienceUI,LimitedTimeExperience)
			limitedTimeExperiencePresenter:setRole(User:getRole())
			limitedTimeExperiencePresenter:setActionId(actionId)
			limitedTimeExperiencePresenter:initRule(actionRule)
			limitedTimeExperiencePresenter:showLayer()
		end,

		["练武场"] = function(actionId, actionRule)
			PopupLayerController:showLayer("PracticeSkillPresenter",function(layer)
				layer:setActionId(actionId)
				layer:showLayer()
				layer:initRule(actionRule)
			end)
		end,
		
		["举杯共饮"] = function(actionId, actionRule)
			local DrinkMorePresenters = require("app.presenters.Activity.DrinkMorePresenters")
			local DrinkMore = require("app.models.Action.DrinkMore"):create()
			local DrinkMoreUI = PopupLayerController:getLayer("DrinkMoreUI")
			local drinkMorePresenters = DrinkMorePresenters:create(DrinkMoreUI,DrinkMore)
			drinkMorePresenters:initRule(actionRule)
			drinkMorePresenters:setRole(User:getRole())
			drinkMorePresenters:showLayer()
		end,

		["地仓府库"] = function(actionId, actionRule)
			local WareHousePresentrs = require("app.presenters.Activity.WareHousePresentrs")
			local WareHouseActivity = require("app.models.Action.WareHouseActivity"):create()
			local WareHouseUI = PopupLayerController:getLayer("WareHouseUI")
			local wareHousePresentrs = WareHousePresentrs:create(WareHouseUI,WareHouseActivity)
			wareHousePresentrs:setRule(actionRule)
			wareHousePresentrs:setRole(User:getRole())
			wareHousePresentrs:showLayer()
		end,

		["周年登录礼"] = function(actionId, actionRule)
			PopupLayerController:showLayer("AnniversaryLoginRewardPresenter",function(layer)
				layer:initRule(actionRule)
				layer:setRole(User:getRole())
				layer:showLayer()
			end)
		end,

		["香囊商店"] = function(actionId, actionRule) --与江湖秘宝一样 奖励配置不一
			PopupLayerController:showLayer("JiangHuMiBaoPresenters",function(layer)
				layer:setActionId(actionId)
				layer:showLayer()
				layer:initRule(actionRule)
			end)
		end,

		["密钥商店"] = function(actionId, actionRule) --与江湖秘宝一样 奖励配置不一
			PopupLayerController:showLayer("JiangHuMiBaoPresenters",function(layer)
				layer:setActionId(actionId)
				layer:showLayer()
				layer:initRule(actionRule)
			end)
		end,

		["佳酿老铺"] = function(actionId, actionRule) --与江湖秘宝一样 奖励配置不一
			PopupLayerController:showLayer("JiangHuMiBaoPresenters",function(layer)
				layer:setActionId(actionId)
				layer:showLayer()
				layer:initRule(actionRule)
			end)
		end,

		["鞭炮小铺"] = function(actionId, actionRule) --与江湖秘宝一样 奖励配置不一
			PopupLayerController:showLayer("JiangHuMiBaoPresenters",function(layer)
				layer:setActionId(actionId)
				layer:showLayer()
				layer:initRule(actionRule)
			end)
		end,

		["铁匠铺"] = function(actionId, actionRule)
			local SmithyActionPresenter = require("app.presenters.Activity.SmithyActionPresenter")
			local SmithyAction = require("app.models.Action.SmithyAction"):create()
			local SmithyActionUI = PopupLayerController:getLayer("PracticeOfSkillUI")
			local SmithyActionPresenters = SmithyActionPresenter:create(SmithyActionUI,SmithyAction)
			SmithyActionPresenters:setRole(User:getRole())
			SmithyActionPresenters:initRule(actionRule)
			SmithyActionPresenters:showLayer()
		end,

		["醒梦堂"] = function(actionId, actionRule)
			PopupLayerController:showLayer("WakeUpActionPresenter",function(layer)
				layer:setActionId(actionId)
				layer:showLayer()
				layer:initRule(actionRule)
			end)
		end,

		["日掷斗金"] = function(actionId, actionRule)
			PopupLayerController:showLayer("YuanBaoConsumeActionPresenter",function(layer)
				layer:showLayer()
				layer:initRule(actionRule)
			end)
		end,

		["丹青阁"] = function(actionId, actionRule)
			PopupLayerController:showLayer("DanQingGePresenter",function(layer)
				layer:setActionId(actionId)
				layer:initRule(actionRule)
				layer:showLayer()
			end)
		end,

		["武门试炼"] = function(actionId, actionRule)
			PopupLayerController:showLayer("KungFuTrailsPresenter",function(layer)
				layer:initRule(actionRule)
				layer:showLayer()
			end)
		end,

		["招财进宝"] = function(actionId, actionRule)
			PopupLayerController:showLayer("JuBaoPenPresenter",function(layer)
				layer:setActionId(actionId)
				layer:initRule(actionRule)
				layer:showLayer()
			end)
		end,

		["藏经阁"] = function(actionId, actionRule)
			PopupLayerController:showLayer("CangJingGePresenter",function(layer)
				layer:setActionId(actionId)
				layer:initRule(actionRule)
				layer:showLayer()
			end)
		end,

		["易金圩市"] = function(actionId, actionRule)
			PopupLayerController:showLayer("CuiLianCaiLiaoStorePresenter",function(layer)
				layer:setActionId(actionId)
				layer:initRule(actionRule)
				layer:showLayer()
			end)
		end,

		["轻功校场"] = function(actionId, actionRule)
			PopupLayerController:showLayer("PracticeSkillPresenter",function(layer)
				layer:setActionId(actionId)
				layer:showLayer()
				layer:initRule(actionRule)
			end)
		end,

		["内功校场"] = function(actionId, actionRule)
			PopupLayerController:showLayer("PracticeSkillPresenter",function(layer)
				layer:setActionId(actionId)
				layer:showLayer()
				layer:initRule(actionRule)
			end)
		end,

		["指法校场"] = function(actionId, actionRule)
			PopupLayerController:showLayer("PracticeSkillPresenter",function(layer)
				layer:setActionId(actionId)
				layer:showLayer()
				layer:initRule(actionRule)
			end)
		end,

		["爪法校场"] = function(actionId, actionRule)
			PopupLayerController:showLayer("PracticeSkillPresenter",function(layer)
				layer:setActionId(actionId)
				layer:showLayer()
				layer:initRule(actionRule)
			end)
		end,

		["琴法校场"] = function(actionId, actionRule)
			PopupLayerController:showLayer("PracticeSkillPresenter",function(layer)
				layer:setActionId(actionId)
				layer:showLayer()
				layer:initRule(actionRule)
			end)
		end,

		["心神阁"] = function(actionId, actionRule)
			PopupLayerController:showLayer("DanQingGePresenter",function(layer)
				layer:setActionId(actionId)
				layer:initRule(actionRule)
				layer:showLayer()
			end)
		end,

		["通武积市"] = function(actionId, actionRule)
			PopupLayerController:showLayer("FistFootShopPresenter",function(layer)
				layer:setActionId(actionId)
				layer:initRule(actionRule)
				layer:showLayer()
			end)
		end,

		["墨千秋的赠礼"] = function(actionId, actionRule)
			PopupLayerController:showLayer("MakeMaskSecretGiftPresenter",function(layer)
				layer:initRule(actionRule)
				layer:showLayer()
			end)
		end,

		["鞭法校场"] = function(actionId, actionRule)
			PopupLayerController:showLayer("PracticeSkillPresenter",function(layer)
				layer:setActionId(actionId)
				layer:showLayer()
				layer:initRule(actionRule)
			end)
		end,

		["观影堂特权加送"] = function(actionId, actionRule)
			PopupLayerController:showLayer("CommercialTimePrivilegePresenter",function(layer)
				layer:showLayer()
			end)
		end,
		
		["武识互通"] = function(actionId, actionRule)
			HttpManagerEx:getNewYearFestivalState(actionId,function(status, errcode, errmsg, data)
				if status == 200 and errcode == 0  then
					if data ~= nil and data.is_open == 1 and data.status == 1 then
						PopupLayerController:showLayer(
							"SkillResExchangePresenter",
							function(layer)
								local dsc = ""

								if MapIsEmpty(data.detail_desc) == false then
									for i,desc in ipairs(data.detail_desc) do
										dsc = dsc .. desc .."\n"
									end
								end

								layer:setTitle(data.name)
								layer:setDsc(dsc)
								layer:setActionId(data.activity_id)
								layer:showLayer()
							end
						)
					end
				else
					PopText(errmsg)
				end
			end, IS_SHOW_WAITING)
		end,

		["刀法校场"] = function(actionId, actionRule)
			PopupLayerController:showLayer("PracticeSkillPresenter",function(layer)
				layer:setActionId(actionId)
				layer:showLayer()
				layer:initRule(actionRule)
			end)
		end,

		["醉仙秘市"] = function(actionId, actionRule)
			HttpManagerEx:getNewYearFestivalState(actionId,function(status, errcode, errmsg, data)
				if status == 200 and errcode == 0  then
					if data ~= nil and data.is_open == 1 and data.status == 1 then
						PopupLayerController:showLayer(
							"SkillResExchangePresenter",
							function(layer)
								local dsc = ""

								if MapIsEmpty(data.detail_desc) == false then
									for i,desc in ipairs(data.detail_desc) do
										dsc = dsc .. desc .."\n"
									end
								end

								layer:setTitle(data.name)
								layer:setDsc(dsc)
								layer:setActionId(data.activity_id) 
								layer:showLayer()
							end
						)
					end
				else
					PopText(errmsg)
				end
			end, IS_SHOW_WAITING)
		end,

		["百锻阁"] = function(actionId, actionRule)
			PopupLayerController:showLayer(
				"BaiDuanGePresenter",
				function(layer)
					layer:setActionId(actionId)
					layer:showLayer()
					layer:initRule(actionRule)
				end
			)
		end,

		["平遥之约"] = function(actionId, actionRule)
			PopupLayerController:showLayer(
				"ChallengeClearTimesPresenter",
				function(layer)
					layer:setActionId(actionId)
					layer:showLayer()
					layer:initRule(actionRule)
				end
			)
		end,

		["双钩校场"] = function(actionId, actionRule)
			PopupLayerController:showLayer("PracticeSkillPresenter",function(layer)
				layer:setActionId(actionId)
				layer:showLayer()
				layer:initRule(actionRule)
			end)
		end,
	}
	for k,action in pairs(list) do
		if funcTab[action.name] ~= nil then
			action.func = funcTab[action.name]
		end
	end
	return list
end

function ActionLayer:create()
	local p = ActionLayer:new()
	p:init()
	return p
end

function ActionLayer:init()
	local UI = require("Layer/ActionUI/ActionUI.lua").create()['root']
	UI:addTo(self)

	Helper:convertUI(self)

	self:setActivityBtn()
	self.Panel_row:setVisible(false)
	self.Button_back:releaseFunc(function()
		self:hide()
	end)

	self:setVisible(false)
end

function ActionLayer:show(list,lastLayer)
	HttpManagerEx:getSpringFestivalList(function(status, errcode, errmsg, data)
		if status == 200 and errcode == 0 then
			self:afterGetList(initActionList(data),list)
			MainControllLayer:pushLayer("ActionLayer")
			self:setVisible(true)
		end
	end, IS_SHOW_WAITING)

	if lastLayer then 
		self.lastLayer=lastLayer
	end
	-- self:afterGetList()
	-- HttpManagerEx:getActionData(function(str)
	-- 	self:afterGetList(str)
	-- end)
end

function ActionLayer:hide()
	if self.lastLayer and self.lastLayer == "MainLayer" then  --主界面入口
		MainControllLayer:popLayer()
		MainControllLayer:getLayer("MainLayer"):setStroeTexture()
	else   --其他入口 
		--商城
		MainControllLayer:getLayer("StoreLayer"):refreshStoreList(function()
			MainControllLayer:popLayer()
			-- self:setVisible(false)
		end)
	end
end
function ActionLayer:hideHongDian(index)
	for k,row in pairs(rowList) do
		if index == k then
			row.Image_hongdian:setVisible(false)
		end
	end
end
function ActionLayer:getIsShow(action,list)
	for k,v in pairs(list) do
		if action.name == v then
			return true
		end
	end
	return false
end

local ManageActionByName = {
    ["江湖狂欢礼包"] = true,
    ["一掷千金"] = true,
    ["迎春聚福"] = true,
    ["财神帮的聚宝盆"] = true,
    ["小年充值福利"] = true,
    ["江湖迎春归"] = true,
    ["新春英雄宴"] = true,
    ["名士之约"] = true,
    ["限时充值加送"] = true,
    ["江湖异人录"] = true,
    ["江湖秘宝"] = true,
    ["江湖夺宝"] = true,
    ["香囊密阁"] = true,
    ["江湖叠金节"] = true,
    ["充值福利"] = true,
    ["限时历练"] = true,
    ["练武场"] = true,
    ["香囊商店"] = true,
    ["密钥商店"] = true,
    ["佳酿老铺"] = true,
    ["招财进宝"] = true,
    ["藏经阁"] = true,
    ["易金圩市"] = true,
    ["轻功校场"] = true,
    ["内功校场"] = true,
    ["爪法校场"] = true,
    ["指法校场"] = true,
    ["鞭炮小铺"] = true,
	["琴法校场"] = true,
	["丹青阁"] = true,
	["心神阁"] = true,
	["通武积市"] = true,
	["墨千秋的赠礼"] = true,
	["鞭法校场"] = true,
	["观影堂特权加送"] = true,
	["刀法校场"] = true,
	["百锻阁"] = true,
	["百战砺心"] = true,
	["双钩校场"] = true,
	["平遥之约"] = true,
}

function ActionLayer:afterGetList(list,showList)
	self.ListView_list:removeAllItems()

	local function getActionRule(ruleDesc)
		local dsc = ""
		if MapIsEmpty(ruleDesc) == false then
			for i,desc in ipairs(ruleDesc) do
				dsc = dsc .. desc .."\n"
			end
		end
		return dsc
	end

	for k,action in ipairs(list) do
		-- 状态不为1 或者 开关部位 1 则不开启活动
		if action.status == 1 and action.is_open == 1 then
			local row = self:createOneRow(action)
			rowList[k] = row
			if self:getIsShow(action,showList.list) == true then
				row.Image_hongdian:setVisible(true)
				
				-- local reset = DataBase:getDataWithString("resetChange")
				-- if reset == "1" and action.name == "签到活动" then
				-- 	DataBase:setDataByString("resetChange","0")
				-- 	row.Image_hongdian:setVisible(false)
				-- else
					-- row.Image_hongdian:setVisible(true)
				-- end
			else
				row.Image_hongdian:setVisible(false)
			end
			local func = Helper:getDef(action.func, function()
				PopupLayerController:showLayer("ActionDescLayer", function(layer)
					layer:show(action)
				end)
			end)

			local rFunc = function()
				HttpManagerEx:getNewYearFestivalState(action.id, function(status, errcode, errmsg, data)
				    if status == 200 and errcode == 0 and data.is_open == 1 and data.status == 1 then
						local actionRule = getActionRule(data.rule_desc)
				   	 	local action = cc.Sequence:create(cc.CallFunc:create(
			        	function()
			        		if ManageActionByName[action.name] then
			        			func(action.activity_id,actionRule)
							elseif action.name == "天缘奇盒" or action.name == "江湖珍品阁" then
								func(action.activity_id,action.id,actionRule)
			        		else
			        			func(action.id,actionRule)
			        		end
			        	end),cc.DelayTime:create(0.5),cc.CallFunc:create(
			        	function()
			    			self:hideHongDian(k)
			        	end))
			        self:runAction(action)
					end
				end, IS_SHOW_WAITING)
			end
			row.Image_kuang:releaseFunc(function()
				rFunc()
			end)

			row.Panel_btn:releaseFunc(function()
				rFunc()
			end)
			--row.Image_hongdian:setVisible(true)
			-- math.randomseed(tostring(os.time()):reverse():sub(1, 7))
			-- if math.mod(math.random(),2) == 1 then

			-- else
			-- 	row.Image_hongdian:setVisible(false)
			-- end
			row:setVisible(true)
			--Image/UI/TeacherUI/anniu_ddfs.png
			--row.Image_button:loadTextureNormal("Image/UI/TeacherUI/anniu_ddfs.png",0)
			self.ListView_list:pushBackCustomItem(row)
		end
	end
end

function ActionLayer:createOneRow(action)
	if not action then
		return
	end
	local row = self.Panel_row:clone()
	Helper:convertUI(row)
	--Helper:convertUIByParent(self)
	-- local s=action.time
	-- 重新计算,方式太老
	-- local p="(%d+)-(%d+)-(%d+) (%d+):(%d+):(%d+)"
	-- local year,month,day,hour,min,sec=s:match(p)
	-- local offset = action.time - GetTime()
	-- if offset <= 0 then
	-- 	offset = 0
	-- end
	-- day = math.floor(offset/3600/24)
	-- hour = math.floor((offset - day*3600*24)/3600)
	local remainTime = Helper:getDef(action.remain_time, 0)
	local time1 = 259200

	if remainTime > time1 then
		row.Text_timeNum:setTextColor({r = 169, g = 169, b = 169})
	else
		row.Text_timeNum:setTextColor({r = 140, g = 33, b = 33})
	end

	if remainTime > time1 then
		row.Image_end:setVisible(false)
	else
		row.Image_end:setVisible(true)
	end

	row.Text_title:setString(action.name)
	row.Text_timeNum:setString(action.time)
	row.Text_desc:setString(action.desc)
	row.Text_item:setString(action.gift)
	row.Image_hongdian:setPositionX(row.Text_title:getPositionX()+row.Text_title:getContentSize().width + 15)
	row.Image_hongdian:setPositionY(row.Text_title:getPositionY()+row.Text_title:getContentSize().height - 15)
	return row
end

function ActionLayer:setActivityBtn()
	self.Image_activityBtn:releaseFunc(function()
		local ActivityCalendarLayer = require("app.views.layer.ActionLayer.ActivityCalendarLayer")
		ActivityCalendarLayer:getInstance():showLayer()
	end)
end

Helper:classDefNodeGetInstance(ActionLayer)
return ActionLayer0000000000000000