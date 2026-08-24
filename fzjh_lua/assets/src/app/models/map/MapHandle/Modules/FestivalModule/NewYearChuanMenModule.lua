--@SuperType [src.app.models.map.MapHandle.Modules.BaseModule#BaseModule]
local NewYearChuanMenModule = class("NewYearChuanMenModule", require("app.models.map.MapHandle.Modules.BaseModule"))
local HomelandDesc = require("app.models.HomelandModel.HomelandDesc")
local HomelandRoleUtil = require("app.models.HomelandModel.HomelandRoleUtil")
local CRFactory = require("app.models.HomelandModel.CRFactory")
local newYearVisitedWord={
    [1]={
        [1]="管家迎面而来，你上前说道：新春新喜，在下此来欲向贵府主人拜年。",
        [2]="新春吉利，今晨鸿气东来，家主恰巧出门拜年，待家主归来之时，我必定回禀大侠前来拜年之事。",
        },
    [2]={
        [1]="管家迎面而来，你上前说道：在下趁这新春之际特来拜访，欲向贵府主人道上一声新年快乐。",
        [2]="新年如意。大侠有礼，只不巧家主正好外出拜年，待家主归来必定转达大侠祝福之意。",
        },
    [3]={
        [1]="管家迎面而来，你上前说道：闻得早竹报平安，在下特地前来，送上一句年丰岁华，聊表新春祝福之意。",
        [2]="大侠新春快乐！有劳大侠记挂我家家主，可惜家主一早出门拜年，尚未归来，在下不才替家主道一声：多谢记挂，愿大侠福禄满屋。",
        },
    [4]={
        [1]="管家迎面而来，你上前说道：新年之际，回想江湖一路或曾与贵府主人擦身而过，今日特地前来道一声万事如意。",
        [2]="新年快乐！大侠客气，家主素来好客若非一早出门拜年定能与大侠引为知己。待家主归来，我必当细细回禀。",
        },
    [5]={
        [1]="管家迎面而来，你上前说道：新年大吉！在下喜结天下英豪，趁新春之刻，正好向贵府主人拜年，顺便结识一番。",
        [2]="喜气盈门，不知竟是大侠来访。新春快乐，家主一早就出门拜年了，待家主归来我必定替大侠转告。",
        },
}
local specialRewardWord={
    [1]="新春吉利，今晨鸿气东来，家主恰巧出门拜年，特让在下在此招待前来拜访的侠士，并奉上厚礼，以表我家家主的心意。",
    [2]="新年如意。大侠有礼，不巧家主正好外出拜年，幸已吩咐在下备好薄礼，以答谢大侠新春特来恭贺之情。",
    [3]="大侠新春快乐！家主一早出门拜年，尚未归来，在下不才替家主献上薄礼，并道一声：多谢记挂，愿大侠福禄满屋。",
    [4]="新年快乐！大侠客气，家主素来好客若非一早出门拜年定能与大侠引为知己。这些许礼物，算是家主愿与少侠相交并作答谢之意。",
    [5]="喜气盈门，不知竟是大侠来访。新春快乐，家主一早就出门拜年了，特让在下恭候大侠来访，这礼物只作新年之贺，不成敬意。",
}

--@desc 开启状态，默认开启
NewYearChuanMenModule.status = 1

--@desc 活动时间 : 格式：20171001，默认值0 表示无时间限制
NewYearChuanMenModule.activityTime = 0

NewYearChuanMenModule.doResult = {
    ["摆放礼品"]=function(map, result, environment)
        local function giveGiftFunc()
            local giftType=User:getRole():getDayFlag("giftType")
            local guanjiaID=environment.currRole.id

            HttpManagerEx:addLandGift(giftType,
                guanjiaID, 
              function(status, errcode, errmsg, data)
                            if status == 200 then
                                if errcode == 0 then
                                    -- if data.zcd>0 and MapIsEmpty(data.defaultZhongCheng) ==false then 
                                    --     PopText("管家忠诚度 + "..tostring(Helper:getDef(data.zcd,0)))
                                    --     HomelandRoleUtil:updateFidelity(data.defaultZhongCheng.defaultZhongCheng, environment.currRole)
                                    --     if data.defaultZhongCheng.level_up == true and data.defaultZhongCheng.trait then
                                    --         HomelandRoleUtil:DeblockRoleTrait(environment.currRole, data.defaultZhongCheng.trait)
                                    --         HomelandRoleUtil:updateRoleFunc(environment.currRole, map)
                                    --     end
                                    -- else
                                    --     PopText("管家忠诚度已满")
                                    -- end
                                                                   
                                    User:getRole():setDayFlag("摆放礼品", 1)
                                    local rewardRsid={[1]="2019chuanmen1",[2]="2019chuanmen2"}
                                    local SpringFestival = require("app.models.SpringFestival.SpringFestival")
                                    SpringFestival:getNewYearRewardByRsid(rewardRsid[giftType])
                                    SpringFestival:getHouserGiveGiftExtraReward(giftType)
                                    map.__MapLayer:delayRefreshMap()
                                    RichPrint("main","YEL"..environment.currRole.name.."：新年快乐。按照老爷的意思，我会将这些礼物分配摆放，如有侠士前来拜年，一一派发。")
                                else
                                    print("errcode:",errcode,"msg:",errmsg)
                                    PopText(errmsg)
                                end
                            else
                                PopText(errmsg)
                            end
                        end,
            IS_SHOW_WAITING)
            print("------giftType:"..tostring(giftType))
        end
        if User:getRole():getDayFlag("摆放礼品")<1 then 
            local showText="YEL"..environment.currRole.name.."：".."#ch#，正逢佳节，我们是否要在家中添置一些礼品，如有访客登门拜年，可给他们派发。"
            showText=HomelandDesc:subChengHuText(showText)
            local btnTitle={[1]="添置红包",[2]="添置福袋",[3]="暂不添置"}
            local spendText={[1]="将扣除28万碎银",[2]="将扣除50元宝"}
            local spendType={[1]="money",[2]="yuanbao"}
            local spendNum={[1]=280000,[2]=50}
            PopupLayerController:showLayer("FestivalGiveGiftLayer",function ( layer )
                layer:showLayer(btnTitle,spendText,showText,spendType,spendNum,giveGiftFunc)
            end)
        else
            local showText="YEL"..environment.currRole.name.."：".."#ch#，您今日已经摆放过礼品了。"
            showText=HomelandDesc:subChengHuText(showText)
            RichPrint("main",showText)
        end
    end,

    ["登门拜年"]=function(map, result, environment)
        local role = User:getRole()
        local pushData = {
            userid = map.uid,
            affair_id = "13",
            affair_val = {
                from_name = role.name,
                visit_time=GetTime(),
                gift_type=5
            },
            biz_type = 2,
            objId = math.floor(GetTime()),
            from_id = User:getUserId(),
            expired_time = GetTime() + 3600 * 48,
            count = "",
        }
        HttpManagerEx:pushAffair(
            pushData,
            function(status, errcode, errmsg, data)
                if status == 200 then
                    if errcode == 0 then
                        print("已经向房主发出登门拜年事务")
                        local giftType=tonumber(data.gift_type)
                        local rewardRsid={[1]="2019chuanmen5",[2]="2019chuanmen6",[3]="2019chuanmen7",}
                        local SpringFestival = require("app.models.SpringFestival.SpringFestival")
                        local wordIndex=math.random(1,#newYearVisitedWord)
                        for k,text in pairs(newYearVisitedWord[wordIndex]) do 
                            environment.mapLayer:delayFunc(k,function ()
                                if k==2 then
                                    if giftType==3 then   --普通奖励
                                        if User:getRole():getDayFlag("拜年奖励")<10 then 
                                            User:getRole():setDayFlag("拜年奖励", User:getRole():getDayFlag("拜年奖励")+1)
                                            text="YEL"..environment.currRole.name.."："..text
                                            RichPrint("main",text)
                                            SpringFestival:getNewYearRewardByRsid(rewardRsid[giftType])
                                            SpringFestival:getVisitorNewYearExtraReward(giftType)
                                            -- RichPrint("main","你收到房主的新年奖励")
                                        end
                                    elseif giftType==1 or giftType==2 then  --特殊奖励还存在普通奖励
                                        if User:getRole():getDayFlag("拜年红包奖励")<5 then
                                            User:getRole():setDayFlag("拜年红包奖励", User:getRole():getDayFlag("拜年红包奖励")+1)
                                            SpringFestival:getNewYearRewardByRsid(rewardRsid[giftType])
                                            SpringFestival:getVisitorNewYearExtraReward(giftType)
                                            text="YEL"..environment.currRole.name.."："..specialRewardWord[wordIndex]
                                            RichPrint("main",text)
                                        end 
                                        if User:getRole():getDayFlag("拜年奖励")<10 then 
                                            User:getRole():setDayFlag("拜年奖励", User:getRole():getDayFlag("拜年奖励")+1)
                                            SpringFestival:getNewYearRewardByRsid(rewardRsid[3])
                                            SpringFestival:getVisitorNewYearExtraReward(3)
                                        end
                                        if type(data.addYuanbao)=="number" and data.addYuanbao>0 then
                                            PopText("获得"..tostring(data.addYuanbao).."元宝！") 
                                        end
                                    elseif giftType==11 or giftType==12 then  --只有特殊奖励
                                        if User:getRole():getDayFlag("拜年红包奖励")<5 then
                                            User:getRole():setDayFlag("拜年红包奖励", User:getRole():getDayFlag("拜年红包奖励")+1)
                                            local rewardType=giftType-10
                                            SpringFestival:getNewYearRewardByRsid(rewardRsid[rewardType])
                                            SpringFestival:getVisitorNewYearExtraReward(rewardType)
                                            text="YEL"..environment.currRole.name.."："..specialRewardWord[wordIndex]
                                            RichPrint("main",text)
                                        end
                                        if type(data.addYuanbao)=="number" and data.addYuanbao>0 then
                                            PopText("获得"..tostring(data.addYuanbao).."元宝！") 
                                        end 
                                    end
                                    map.__MapLayer:delayRefreshMap()
                                else
                                    RichPrint("main","YEL"..text)
                                end
                            end)
                        end      
                    else
                        print("errcode : ", errcode,"errmsg : ",errmsg)
                        PopText(errmsg)
                    end
                    map:setFlag("roleHouseStatus", 2)
                    map:doRoomConditionAndResult(environment.currRoomId)
                else
                    PopText(errmsg)
                end
            end
        )  
    end,
}

function NewYearChuanMenModule:entryMap(map, currTime)
    if DEBUG_MODE == 1 or (GetTime() < Helper:getTimeStampWithStringDate("20220212", 0) and GetTime() > Helper:getTimeStampWithStringDate("20220129", 0)) then
	    self:initGuanJiaConditionAndResults(map)
        self:createChuanMenShiWu(map)
    end
end

function NewYearChuanMenModule:initGuanJiaConditionAndResults(map)
    if HomelandRoleUtil:currMapHaveGj(map) == true then
        local guanjia = map:getRole("guanjia1001")
        if guanjia then
        	if map:getMapType() == MAP_TYPE.MYHOME then 
            	CRFactory:createBtnCR(guanjia, "摆放礼品", "摆放礼品")
            	CRFactory:openOrCloseBtnFunc(guanjia, "摆放礼品", "open")
            elseif map:getMapType() == MAP_TYPE.OTHERHOME then 
            	CRFactory:createBtnCR(guanjia, "拜年", "登门拜年")
            	CRFactory:openOrCloseBtnFunc(guanjia, "登门拜年", "open")
            end
	    end
	end
end


function NewYearChuanMenModule:createChuanMenShiWu(map)
    local time=Helper:getDayTime(GetTime())
    local visitTime={
            [1]={[1]=time+3600*2,[2]=time+3600*8},
            [2]={[1]=time+3600*10,[2]=time+3600*14},
            [3]={[1]=time+3600*18,[2]=time+3600*21}
        }
    local randVisitorSex={
        [0]="男",
        [1]="女",
    }
    local canProduce=false
    local visitIndex=0
    local timeSolt=User:getRole():getDayFlag("NPC新年串门")
    
    if timeSolt==0 then 
        timeSolt="0" 
    end
    for i,v in pairs(visitTime) do    --NPC新年串门 “0123”
        if GetTime() >=visitTime[i][1] and GetTime() <=visitTime[i][2] then 
            if string.find(timeSolt,tostring(i))==nil then 
                canProduce=true
                visitIndex=i
                User:getRole():setDayFlag("NPC新年串门",timeSolt..tostring(i))
                break
            end
        end 
    end

    if map:getMapType() == MAP_TYPE.MYHOME and HomelandRoleUtil:currMapHaveGj(map) == true then
        if canProduce==true then 
            local pushData = {
                userid = map.uid,
                affair_id = "13",
                affair_val = {
                    from_name = Helper:getRandomName(randVisitorSex[math.random(1,#randVisitorSex)]),
                    visit_time=GetTime(),
                    gift_type=6+visitIndex
                },
                biz_type = 2,
                objId = math.floor(GetTime()),
                from_id = Helper:getOnlyId(),
                expired_time = GetTime() + 3600 * 24,
                count = "",
            }
            HttpManagerEx:pushAffair(
                pushData,
                function(status, errcode, errmsg, data)
                    if status == 200 then
                        if errcode == 0 then
                            print("虚假信息生成")
                        else
                            print("errcode : ", errcode)
                            print(errmsg)
                        end
                    else
                        PopText(errmsg)
                    end
                end
            )
        end
    end
end

return NewYearChuanMenModule
000000000000