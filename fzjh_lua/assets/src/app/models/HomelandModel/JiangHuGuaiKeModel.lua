local JiangHuGuaiKeModel = {}
local MapInfo = require("app.models.map.MapInfo")
local JHGKMoBan = require("script.others.guaike").Sheet1
local CRFactory = require("app.models.HomelandModel.CRFactory")
local ActivityCalendarUtils = require("app.models.Action.ActivityCalendarUtils")


local activity_conf = {
    needBagSpace = 2,

    condition = function ( self,condTye )
        if condTye == "time" then 
            local activityId = GameConst:getDefaultValue("bafangyouli_dengmenxiebao")
            return ActivityCalendarUtils:checkActivityIsOpen(activityId)
        elseif condTye == "bagSpace" then 
            local activityId = GameConst:getDefaultValue("bafangyouli_dengmenxiebao")
            if ActivityCalendarUtils:checkActivityIsOpen(activityId) then
                local role = User:getRole() 
                if role:getAttr("weight") - #role:getItems() >= self.needBagSpace then 
                else
                    PopText("背包空间不足，需空余出"..tostring(self.needBagSpace).."个位子才可进行挑战。")
                    return false
                end
            end
        end

        return true
    end,

    getReward = function (self,lv)
        local levelNetReward = {
            [1] = {
                ["jiaozi"] = 15,
            },
            [2] = {
                ["jiaozi"] = 20,
            },
            [3] = {
                ["jiaozi"] = 25,
            }
        }
        local levelLocalReward = {
            [1] = {
                ["exp"] = 3000,
                ["pot"] = 2000,
            },
             [2] = {
                ["exp"] = 4000,
                ["pot"] = 2500,
            },
             [3] = {
                ["exp"] = 5000,
                ["pot"] = 3000,
            }
        }
        --游历头衔
        local function getSpecialTitle()
            local ActivityCalendarUtils = require("app.models.Action.ActivityCalendarUtils")
            ActivityCalendarUtils:getSpecialTitle("weekdmxb")
        end

        local jiaoziNum = levelNetReward[lv]["jiaozi"] or 0 
        local isBuff = false
        local role = User:getRole()
        HttpManagerEx:addCurrencyNumber({["jiaozi"] =jiaoziNum },"DailyTies_dmxb_"..lv,"weekact", function(status, errcode, errmsg, data)
            if 200 == status and 0 == errcode then
                if MapIsEmpty(data.currency) == false then
                    for currency,valueData in pairs(data.currency) do
                        if valueData.value > 0 then 
                             PopText("增加"..tostring(valueData.value)..role:getCHAttrName(currency).."，共拥有"..tostring(valueData.count)..role:getCHAttrName(currency))
                        end
                        if valueData.desc ~= nil and valueData.desc ~= ""  then
                            PopText(valueData.desc)
                        end
                    end
                end
                HttpManagerEx:checkGoodsValid({"yuhuiling"}, function(status, errcode, errmsg, data)
                    if 200 == status and 0 == errcode then
                        for k,v in pairs(data) do 
                            if "yuhuiling" == v.itemId and v.number > 0 then 
                                isBuff = true
                            end
                        end

                        for k,v in pairs(levelLocalReward[lv]) do
                            local buffAddValue = role:getDayFlag("yuhuiling_"..k)
                            local addValue = 0 
                            if isBuff  then 
                                addValue = YUHUILING_BUFF * v 

                                if addValue > YUHUILING_NUM_LIMIT - buffAddValue then 
                                    addValue = math.max(YUHUILING_NUM_LIMIT - buffAddValue,0)
                                end
                            end
                            
                            role:setDayFlag("yuhuiling_"..k,buffAddValue + addValue)
                            role:addAttr(k,v + addValue)
                            PopText("获得"..tostring(v + addValue)..role:getCHAttrName(k))
                        end
                        getSpecialTitle()
                    else
                        PopText("网络请求出错,请换个网络环境再试!")
                    end
                end, IS_SHOW_WAITING)
            else
                PopText("网络请求出错,请换个网络环境再试!")
            end
        end, IS_SHOW_WAITING)
    end
}

--生成怪客
function JiangHuGuaiKeModel:createGuaiKe(map)
    --家园副本的默认房间就是门前
    local roomId = map:getDefaultRoomId()
    if User:getRole():getDayFlag("江湖怪客列表") == 0 then
        local guaikemobanList = clone(self:createRandomGuaiKeMobanList())
        local guaikeIdList = {} --记录生成的怪物id

        for i = 1,#guaikemobanList do
            local npc = guaikemobanList[i]
               
            if npc.title then
                local titleList = string.split(npc.title,";")
                npc.title = titleList[math.random( 1,#titleList)]
            end

            npc.canSee = true
            npc.type = "role"
            npc.name = self:getNamebySex(npc.sex)
            npc.conditionAndResults = {}
            CRFactory:createBtnCR(npc, "交谈", "怪物交谈")
            CRFactory:createBtnCR(npc, "接受挑战", "接受挑战",npc.id,3)
            CRFactory:createBtnCR(npc, "门客代打", "门客代打",npc.id,3)
            CRFactory:openOrCloseBtnFunc(npc, "怪物交谈", "open")
            CRFactory:openOrCloseBtnFunc(npc, "接受挑战", "open")
            CRFactory:openOrCloseBtnFunc(npc, "门客代打", "open")

            table.insert( guaikeIdList,{name = npc.name,id = guaikemobanList[i].id,title = npc.title})

            -- Npc:initRoleWithRandomAttr(npc)
            -- Map:initNpcEquipsAndItems(npc)
            -- Map:initNpcActiveZhao(npc)
            Npc:initNpc(npc)

            npc = Helper:tableCover(Role:create(), npc)

            npc:updateRoleBuff()
            MapInfo:addMapRole(map, npc)
            MapInfo:addRoleToRoom(map, roomId, npc.id)
        end
        User:getRole():setDayFlag("江湖怪客列表",guaikeIdList)
    else
        local guaikeIdList = User:getRole():getDayFlag("江湖怪客列表")
        if DEBUG_MODE == 1 then
            Helper:print_lua_table(guaikeIdList)
        end
        if MapIsEmpty(guaikeIdList) then
            return
        end

        for i = 1,#guaikeIdList do
            local guaikeId = guaikeIdList[i].id
            local guaikeMoban = clone(self:getGuaiKeMobanById(guaikeId)) 

            guaikeMoban.canSee = true
            guaikeMoban.type = "role"
            guaikeMoban.name = guaikeIdList[i].name
            guaikeMoban.title = guaikeIdList[i].title
            guaikeMoban.conditionAndResults = {}
            CRFactory:createBtnCR(guaikeMoban, "交谈", "怪物交谈")
            CRFactory:createBtnCR(guaikeMoban, "接受挑战", "接受挑战",guaikeMoban.id,3)
            CRFactory:createBtnCR(guaikeMoban, "门客代打", "门客代打",guaikeMoban.id,3)
            CRFactory:openOrCloseBtnFunc(guaikeMoban, "怪物交谈", "open")
            CRFactory:openOrCloseBtnFunc(guaikeMoban, "接受挑战", "open")
            CRFactory:openOrCloseBtnFunc(guaikeMoban, "门客代打", "open")

            -- Npc:initRoleWithRandomAttr(guaikeMoban)
            -- Map:initNpcEquipsAndItems(guaikeMoban)
            -- Map:initNpcActiveZhao(guaikeMoban)
            
            Npc:initNpc(guaikeMoban)

            local npc = Helper:tableCover(Role:create(), guaikeMoban)

            npc:updateRoleBuff()
            MapInfo:addMapRole(map, npc)
            MapInfo:addRoleToRoom(map, roomId, npc.id)
        end
    end
end

-- 获取战胜怪客奖励
-- isMenKe 是否是门客代打
function JiangHuGuaiKeModel:getWinRewards(isMenKe,menke,map,guaiKeName,roomId,guaikeLv)
    local menKeId = ""
    if isMenKe == 1 then
        menKeId = menke.id
    end

    local role = User:getRole()
    local mid = role:getHouseId()

    HttpManagerEx:getGuaikeReward(isMenKe,menKeId,mid,guaikeLv,function(status, errcode, errmsg, data, isEncrypted)
        if status == 200 then
            if errcode ~= 0 then
            	PopText(errmsg)
            else
                local role = User:getRole()
                local yinpiao = data.yinpiao
                local yueli = data.yueli
                local weiwang = data.weiwang
                local activityItems = data.activityItems
                if yinpiao and yinpiao ~= 0 then
                    PopText("银票 + ".. yinpiao)
                end
                if yueli and yueli ~= 0 then
                    role:addAttr("yueli", yueli)
                    PopText("江湖阅历 + ".. yueli)
                end
                if weiwang and weiwang ~= 0 then
                    role:addAttr("weiwang", weiwang)
                    PopText("江湖威望 + ".. weiwang)
                end

                if MapIsEmpty(activityItems)==false then 
                    for index,itemData in pairs(activityItems) do 
                        if itemData and itemData.itemId and itemData.num then 
                            role:addItemCount(itemData.itemId, tonumber(itemData.num))
                            local itemAttr=role:getOneItemByKey(itemData.itemId)
                            PopText("获得"..itemAttr.name.." X "..tostring(itemData.num))
                        end
                    end
                end
                if activity_conf:condition("time") then 
                    activity_conf:getReward(guaikeLv)
                end

                if isMenKe == 1 then
                    local HomelandRoleUtil = require("app.models.HomelandModel.HomelandRoleUtil")
                    HomelandRoleUtil:updateFidelity(data.defaultZhongCheng, menke)
                    local name = menke.realName or menke.name
                    local textList = {
                        "HIC经过一番较量，YEL"..name.."NOR击败了前来挑战的HIR"..guaiKeName.."NOR，你为YEL"..name.."NOR喝彩，YEL"..name.."NOR面露喜色，与你的关系更亲近了。",
                        "HIC经过一番较量，YEL"..name.."NOR击败了前来挑战的HIR"..guaiKeName.."NOR，你对YEL"..name.."NOR点点头表示嘉许，YEL"..name.."NOR抱拳回礼，与你的关系更亲近了。"
                    }
                    RichPrint("main",textList[math.random( 1,#textList)])
                    
                    do
                        local ShenShiTask = require("app.models.HomelandModel.MapMeetModel.ShenShiTask")
                        local shenShiStatus = ShenShiTask:getTaskStatus(menke)
                        local lv = HomelandRoleUtil:getFidelityLv(menke.defaultZhongCheng)
                        if shenShiStatus == 0 and lv == 7 then
                            ShenShiTask:unlockTask(menke,map,data.level_up,data.trait)
                            return
                        end
                    end
                    if data.level_up == true then
                        HomelandRoleUtil:DeblockRoleTrait(menke, data.trait)
                        HomelandRoleUtil:updateRoleFunc(menke, map)
                        RichPrint("main", "经过长时间的相处，" .. name .. "对你更为忠心了。")
                    end
                end
            end
        else
            PopText(errmsg)
        end
    end, IS_SHOW_WAITING)
end

--获取符合玩家当前等级的怪客模版
function JiangHuGuaiKeModel:getCurrLvCanCreateMobanArray()
    local role = User:getRole()
    local roleLv = role:getLv()
    local MobanList = {} --符合玩家等级的怪客模版
    for k,v in pairs(JHGKMoBan) do
        if roleLv >= v.minlevel and roleLv <= v.maxlevel then
            table.insert( MobanList, v)
        end
    end

    return MobanList
end

--移除被杀死的怪客
function JiangHuGuaiKeModel:removeKilledGuaiKe(map,roomId,npcId)
    if map == nil or roomId == nil or npcId == nil then
        return
    end

    map:removeRoomRole(roomId,npcId)
    local role = User:getRole()
    local guaikeIdList = role:getDayFlag("江湖怪客列表")
    if MapIsEmpty(guaikeIdList) then
        return
    end
    for index ,v in ipairs(guaikeIdList) do
        if v.id == npcId then
            table.remove(guaikeIdList, index)
        end
    end

    role:setDayFlag("江湖怪客列表",guaikeIdList)
end

--根据id获取怪物模版
function JiangHuGuaiKeModel:getGuaiKeMobanById(id)
    return assert(JHGKMoBan[tostring(id)],"JiangHuGuaiKeModel:getGuaiKeMobanById   id = "..id)
end

--根据id获取怪客交谈文本
function JiangHuGuaiKeModel:textMoren(id)
    local guaikeMoban = self:getGuaiKeMobanById(id)
    local textList = string.split(guaikeMoban.textMoren,";")
    return textList[math.random( 1,#textList)]
end

--根据id获取怪客被击败时的文本
function JiangHuGuaiKeModel:textLose(id)
    local guaikeMoban = self:getGuaiKeMobanById(id)
    local textList = string.split(guaikeMoban.textLose,";")
    return textList[math.random( 1,#textList)]
end

--根据id获取怪客胜利时的文本
function JiangHuGuaiKeModel:getTextWin(id)
    local guaikeMoban = self:getGuaiKeMobanById(id)
    local textList = string.split(guaikeMoban.textWin,";")
    return textList[math.random( 1,#textList)]
end

--根据id获取逃跑时输出的文本
function JiangHuGuaiKeModel:getTextEscape(id)
    local guaikeMoban = self:getGuaiKeMobanById(id)
    local textList = string.split(guaikeMoban.textEscape,";")
    return textList[math.random( 1,#textList)]
end



--创建随机怪客模版
function JiangHuGuaiKeModel:createRandomGuaiKeMobanList()
    local guaiKeMoban = self:getCurrLvCanCreateMobanArray()
    if MapIsEmpty(guaiKeMoban) then
        assert(false,"策划表没有这个分段的怪客")
    end

    local guaikeList1 = {}
    local guaikeList2 = {}
    local guaikeList3 = {}
    for i ,v in ipairs(guaiKeMoban) do
        if tonumber(v.groupID) == 1 then
            table.insert( guaikeList1, v)
        elseif tonumber(v.groupID) == 2 then
            table.insert( guaikeList2, v)
        elseif tonumber(v.groupID) == 3 then
            table.insert( guaikeList3, v)
        else
            assert(false,"怪客资源表人物分类填错")
        end
    end
    local guaike1 = guaikeList1[math.random( 1,#guaikeList1)]
    local guaike2 = guaikeList2[math.random( 1,#guaikeList2)]
    local guaike3 = guaikeList3[math.random( 1,#guaikeList3)]

    assert(guaike1 and guaike2 and guaike3,"JiangHuGuaiKeModel:createRandomGuaiKeMobanList() 检查为什么随机不到怪客模版")

    local mobanList = {}
    table.insert( mobanList,guaike1)
    table.insert( mobanList,guaike2)
    table.insert( mobanList,guaike3)
    return mobanList
end

--生成能代打的门客数组
function JiangHuGuaiKeModel:createCanFightMenkeArray(map)
    local menkeArray = {}
    local rooms = map:getRoomMap()

    for roomId, room in pairs(rooms) do
        local rolelist = map:getRoomRoleList(roomId)

        for i, npcId in ipairs(rolelist) do
            local npc = map:getRole(npcId)
            if npc.type == "role" and npc.jobType == "menke001" then
                table.insert(menkeArray, npc)
            end
        end
    end

    return menkeArray
end

--根据男女获取随机姓名
function JiangHuGuaiKeModel:getNamebySex(sex)
    local A, B, C = {},{},{}
    local name = ""
    A = {"郭","严","曹","孔","施","吕","何","许","尤","秦","朱","杨","韩","沈","蒋","卫","褚","冯","郑","吴","徐","洛","楚","杜","穆","胡","金","段","谢","华","李","王","刘","陈","沐","梁","周","白","雁","张","苏","怀","易","棠","舒","乐","林","顾","羊","赵","钱","孙","李","万","齐","姜","任","雷","风","詹","水","尚","车","谭","牧","全","叶","仇","谷","甘","厉","萧","赖","卓","游","宋","燕","魏","晋","丰","荆","桓","辛","冷","步","廖","向","古","易","曾","轩辕","东郭","司空","东门","夏侯","呼延","长孙","令狐","宇文","诸葛","司马","公孙","百里","鲜于","端木","南宫","皇甫","上官","西门","太史"}
    B = {"墨","草","子","归","山","然","夜","扬","云","庆","画","坤","宏","谷","刚","丰","枫","赐","孝","乾","节","德","双","文","生","全","安","元","武","欢","润","言","风","泽","若","才","平","凡","轩","达","源","材","吉","开","思","北","西","南","东","理","明","常","礼","义","勇","信","连","亨","当","行","宁","颂","江","河","海","忠","阳","镇","扬","力","榆","州","康宇","伦","飞","城","远","洪","故","来","青","虎","龙","罡","坚","仪","方","化","溪","松","章","建","逸","元","鸿","冠","宇","磊","泰","明毅","不凡","无病","国栋","安邦","承业","有德","孝安","子玉","长庆","祖恩"}
    C = {"晴","虹","丹","丽","燕","枝","岚","月","霞","珠","碧","鹃","芝","紫","汐","淑","贞","珂","倩","茜","沁","鸢","璇","悠","幽","佳","蓉","凉","柔","蔓","熙","樱","影","琳","湘","芊","珞","芷","瑶","涟","澈","静","菊","雾","云","袖","烟","如","香","雨","雪","竹","兰","致","梅","锦","姬","芸","歌","娜","君","如","婉","笑","媚","露","灵","妙","衣","诗","颖","妍","怡","荷","桃","心","韵","涵","琪","慧","敏","珊","烟","秀","冰","慕","婧","萱","莲","然","婷","茜","凝","雅","思","念","萍","颜","茹","馨","师师","小小","洁洁","青青","灵灵","安安","招娣","胜男","欢欢","真真"}

    if sex == "男" then
        name = A[math.random(1,#A)]..B[math.random( 1,#B)]
    else
        name = A[math.random(1,#A)]..C[math.random( 1,#C)]
    end

    if Helper:isMaskOff(name) then
        return self:getNamebySex(sex)
    else
        return name
    end
end
--活动期间检测是否可战斗
function JiangHuGuaiKeModel:checkCanFight()
    return activity_conf:condition("bagSpace")
end

return JiangHuGuaiKeModel00000000