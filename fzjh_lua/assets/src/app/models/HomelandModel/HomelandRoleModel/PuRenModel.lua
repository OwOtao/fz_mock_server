local PuRenModel = {}

local HomelandRoleUtil = require("app.models.HomelandModel.HomelandRoleUtil")
local familylist = requireWithEncrypt("script.others.familylist")
local roleTypeList = familylist["人物类型"]

local roleMobanList = familylist["人物模板设计"]
local tempRoleMobanList = clone(roleMobanList)
local finalRoleMobanList = {} --剔除绣女 书童 铁匠专用moban

local test = {}
local function initRoleMobanList()
    local tem = {
        moban150 = true,
        moban151 = true,
        moban152 = true,
        moban153 = true,
        moban154 = true,
        moban155 = true,
        moban156 = true,
        moban157 = true,
        moban158 = true
    }

    for k ,v in pairs(tempRoleMobanList) do
        table.insert( finalRoleMobanList, v )
    end

    for i = #finalRoleMobanList,1,-1 do
        local mobanid = finalRoleMobanList[i].mobanid
        if tem[mobanid] == true then
            table.remove(finalRoleMobanList,i)
        end
    end
end

initRoleMobanList()


--获取符合身世规则的随机仆人职业
function PuRenModel:getRandomProfession(tab)
    local weight = {[1] = 30,[2] = 10,[3] = 10,[4] = 10,[5] = 10,[6] = 10,[7] = 80,[8] = 10}

    if not MapIsEmpty(tab) then
        for i ,v in ipairs(tab) do
            weight[v] = 0
        end
    end

    local random = Helper:RandomByWeight(weight)
    if DEBUG_MODE == 1 then
        print("-------------------------随机仆人职业----------------------------",random)
    end
    local resultTab = {
		[1] = "huyuan001",
		[2] = "shutong001",
		[3] = "xiunv001",
		[4] = "laonong001",
		[5] = "chuzi001",
        [6] = "tiejiang001",
        [7] = "puren001",
        [8] = "peilian001"
	}
    return resultTab[random]
end

local _trans = {
    huyuan001 = 1,
    shutong001 = 2,
    xiunv001 = 3,
    laonong001 = 4,
    chuzi001 = 5,
    tiejiang001 = 6,
    puren001 = 7,
    peilian001 = 8,
}


--清除缓存的修剪列表
function PuRenModel:clearTrimList()
    self.trimList = nil
end

function PuRenModel:TrimProfession()
    local resultTab = { "huyuan001","shutong001", "xiunv001","laonong001","chuzi001","tiejiang001","puren001","peilian001"}
    local tab = {}
    for i,v in ipairs(resultTab) do
        local shenShi = HomelandRoleUtil:getMapRoleRandomShenShi(self.trimList,v)
        if shenShi == false then
            table.insert(tab,_trans[v])
        end
    end

    return tab
end

--生成雇佣列表上的职业列表
function PuRenModel:getProfessionList(trimList,param)
    self.trimList = Helper:getDef(clone(trimList),{})

    local roleNum = Helper:getDef(self:getZhaomuListNum(param),0)

    local professionList = {}
    if roleNum == 0 then
        return {}
    end 

    for i = 1,roleNum do
        local tab = self:TrimProfession()
        local tep ={} 
        local profession = self:getRandomProfession(tab)
        
        local shenShi = HomelandRoleUtil:getMapRoleRandomShenShi(self.trimList,profession)
        assert(shenShi,"PuRenModel:getProfessionList 检查为什么修剪过了还是随不到身世")

        tep.jobType = profession
        tep.shenShi = shenShi        
        --[[professionList = {
            jobType = jobType,
            shenShi = shenShiId
        }]]
        table.insert(professionList,tep)
        table.insert(self.trimList,shenShi)
    end
    
    self:clearTrimList()

    return professionList
end

--获取招募列表人数数量
function PuRenModel:getZhaomuListNum(param)
    local randomCount = 0
    local K
    local lv = HomelandRoleUtil:getFidelityLv(param)
    if lv > 4 then
        K = 0
    else
        K = math.min(1000/(lv+3)^2,20)
    end

    if K < math.random(1,100) then 
        randomCount = math.min(math.floor(param/1000)+1,5)
    end

    print("randomCount = ",randomCount)
    return randomCount
end


function PuRenModel:getRandomPuRenResult(param,jobType,shenShi)
    local purenData = {}
    local name = "小四"   --姓名
    local sex = "男" 
    local age = 0
    local looks = 0
    local character = "" --性格id
    local defaultZhongCheng = 500 -- 初始忠诚度
    local speedZhongCheng = 0
    local price = 0
    local price_unit = "yinpiao"
    local PriceEmploy = 0 -- 雇佣价格
    local traitVal = 0 --特点值 
    local modal = ""
    local mobanSkill = {}
    local leave_day = 0
    local loyallv = 0
    traitVal = (param/7)

    character = HomelandRoleUtil:getRandomCharacterId()

    local dailyupZhongcheng = HomelandRoleUtil:getCharacterFactor(jobType).Dailyup1
    local dailyupZhongcheng1 = HomelandRoleUtil:getCharacterAttr(character).Dailyup
    local leaveDay = HomelandRoleUtil:getCharacterFactor(jobType).leave1
    local leaveDayFactor = HomelandRoleUtil:getCharacterAttr(character).leave

    speedZhongCheng = dailyupZhongcheng*dailyupZhongcheng1
    leave_day = leaveDay*leaveDayFactor

    defaultZhongCheng = math.random(50+math.floor(param/20),100+math.floor(param/4))
    modal,loyallv = self:getRandomWuMobanidAndLoyallv(defaultZhongCheng,jobType)
    mobanSkill = HomelandRoleUtil:getUploadWebRoleSkillArray(modal)
    local agelist,sexlist,texinglist,looklist = HomelandRoleUtil:getAttrList(jobType)
    if agelist then
        age = math.random(agelist[1],agelist[2])
    end

    if sexlist then
        local random = math.random(1,#sexlist)
        sex = sexlist[random]
        
    end
    
    if looklist then
        looks = math.random(looklist[1],looklist[2])
    end
    name = self:getNamebySex(sex)
    local conformList =  HomelandRoleUtil:getTexingList(traitVal) --符合特点值要求的特点列表

    local finalList = {}   --最终符合要求的特性列表
    local K4 = 0
    if texinglist and conformList then
        for k,v in pairs(texinglist) do
            for ker,value in pairs(conformList) do
                if v == value then
                    table.insert(finalList,v)
                end
            end
        end
        print("------------------finalList--------------------")
        Helper:print_lua_table(finalList)
        print("------------------finalList--------------------end")
        local list = finalList
        local count = HomelandRoleUtil:getTexingCount()
        local index
        if not MapIsEmpty(list) then
            if count == 0 then
            elseif count == 1 then
                index = math.random(1,#list)
                purenData["trait1"] = list[index]
                K4 = HomelandRoleUtil:getTexingMap(list[index]).attributevalue
            elseif count == 2 then
                for i =1 ,2 do
                    index = math.random(1,#list)
                    purenData["trait"..i] = list[index]
                    K4 = K4 + HomelandRoleUtil:getTexingMap(list[index]).attributevalue
                    table.remove( list,index)
                end
            elseif count == 3 then
                for i =1 ,3 do
                    index = math.random(1,#list)
                    purenData["trait"..i] = list[index]
                    K4 = K4 + HomelandRoleUtil:getTexingMap(list[index]).attributevalue
                    table.remove( list,index)
                end
            end
        end
    end
    K4 = math.min(K4,300) --最大值300
    price ,price_unit = self:getPriceEmploy(defaultZhongCheng,loyallv,jobType,K4)

    purenData.jobType = jobType
    purenData.name = name
    purenData.sex = sex
    purenData.age = age
    purenData.looks = looks
    purenData.shenShi = shenShi
    purenData.character = character
    purenData.defaultZhongCheng = math.floor(defaultZhongCheng)
    purenData.speedZhongCheng = math.floor(speedZhongCheng)
    purenData.price = math.floor(price)
    purenData.price_unit = price_unit
    purenData.traitVal = math.floor(traitVal)
    purenData.modal = modal
    purenData.leave_day = math.floor(leave_day)
    purenData.mobanSkill = mobanSkill
    return purenData
end

local xiuNvMoBan = 
    {
        {
            mobanid = "moban150",
            loyallv = 1
        },
        {
            mobanid = "moban151",
            loyallv = 1
        },
        {
            mobanid = "moban152",
            loyallv = 1
        }
    }
local shuTongMoBan = 
    {
        {
            mobanid = "moban153",
            loyallv = 1
        },
        {
            mobanid = "moban154",
            loyallv = 1
        },
        {
            mobanid = "moban155",
            loyallv = 1
        }
    }
local tieJiangMoBan = 
    {
        {
            mobanid = "moban156",
            loyallv = 1
        },
        {
            mobanid = "moban157",
            loyallv = 1
        },
        {
            mobanid = "moban158",
            loyallv = 1
        }
    }
--获取随机武功模版id和武功等级
--fidelity 仆人初始忠诚度
-- 绣女的人物模板用（moban150、moban151、moban152）三者随机取一种；
-- 书童的人物模板用（moban153、moban154、moban155）三者随机取一种；
-- 铁匠的人物模板用（moban156、moban157、moban158）三者随机取一种；
function PuRenModel:getRandomWuMobanidAndLoyallv(fidelity,jobType)
    if type(fidelity) ~= "number" then
        return
    end
    local mobanid,loyallv

    if jobType == "xiunv001" then
        local randomNum = math.random(1,3)
        mobanid = xiuNvMoBan[randomNum].mobanid
        loyallv = xiuNvMoBan[randomNum].loyallv
    elseif jobType == "shutong001" then
        local randomNum = math.random(1,3)
        mobanid = shuTongMoBan[randomNum].mobanid
        loyallv = shuTongMoBan[randomNum].loyallv
    elseif jobType == "tiejiang001" then
        local randomNum = math.random(1,3)
        mobanid = tieJiangMoBan[randomNum].mobanid
        loyallv = tieJiangMoBan[randomNum].loyallv
    else
        local randomLoyallv = math.random(1,math.min(math.floor(fidelity/9),111))
        print("获取随机武功模版id和武功等级")
        print("randomLoyallv = ",randomLoyallv)

        for k,v in pairs(finalRoleMobanList) do
            if v.loyallv == randomLoyallv then
                mobanid = v.mobanid
                loyallv = v.loyallv
                break
            end
        end
    end

    return mobanid,loyallv
end

--根据男女获取随机姓名
function PuRenModel:getNamebySex(sex)
    local A, B, C,D = {},{},{},{}
    local name = ""
    A = {"郭","严","曹","孔","施","吕","何","许","尤","秦","朱","杨","韩","沈","蒋","卫","褚","冯","郑","吴","寒","落","楚","炫","木","子","金","永","谢","华","李","王","苍","陈","沐","良","周","白","雁","张","守","怀","易","棠","舒","乐","阿","大","小","太史","慕容","马矢","单于","麦丘","赵","钱","孙","李","万","齐","姜","任","雷","风","詹","天","义","车","井","牧","全","叶","仇","谷","甘","厉","怀","赖","卓","游","宋","燕","魏","晋","丰","荆","桓","辛","冷","步","廖","向","古","易","广","轩辕","东郭","司空","东门","夏侯","呼延","长梧","公明","孙叔","拓跋"}
    B = {"墨","草","子","归","山","然","夜","扬","云","庆","画","林","宏","谷","刚","丰","枫","赐","九","八","毕","云德","双","文","生","全","安","元","武","欢","润","言","风","泽","若","才","平","凡","轩","达","源","财","吉","开","思","北","西","南","东","泰","忠","宝","福","喜","儿","七","六","五","四","二","三","连","亨","当","行","宁","颂","江","河","海","航","阳","镇","扬","力","榆","州","康泰","伦","飞","城","远","洪","故","来","青","虎","龙","罡","坚","仪","方","化","溪","松","章","建","逸","元","鸿","冠","宇","磊","泰","金毅"}
    C = {"奕","千","浣","招","柒","绣","棉","杏","荷","墨","贝","丝","梦","素","如","梧","桃","念","妙","忆","锦","凌","文","绮","芳","欣","之","幼","白","惜","司","入","蓝","绿","青","紫","洛","烟","安","心","灵","初","微","大","立","小","冬","秋","春","夏","长孙","北宫","丘丽","公析","素和","华","陶","水","安","明","乐","伊","于","怀","常","步","喻","冉","任","连","余","玉","若","兰","梦","尹","桂","年","狄","韶","素","高","纪","季","清","晴","佩","凤","红","闻","含","寻","紫","雅","忆","司琴","信非","公孙","百里","东方","端木","南宫","皇甫","上官","元和"}
    D = {"晴","儿","言","丽","燕","枝","祥","月","霞","珠","碧","鹃","芝","朱","汐","淑","城","间","倩","茜","沁","鸢","璇","悠","幽","佳","蓉","凉","柔","蔓","熙","樱","影","琳","湘","芊","珞","芷","瑶","涟","澈","静","菊","雾","云","秀","烟","如","香","画","书","棋","琴","寒","雨","雪","竹","兰","至","梅","锦","姬","芸","歌","娜","君","如","婉","笑","凡","露","灵","妙","衣","诗","颖","妍","怡","荷","桃","心","韵","涵","琪","慧","敏","珊","烟","秀","冰","慕","静","旋","花","然","婷","茜","凝","寒","思","念","萍","颜","姚","馨"}

    if sex == "男" then
        name = A[math.random(1,#A)]..B[math.random( 1,#B)]
    else
        name = C[math.random(1,#C)]..D[math.random( 1,#D)]
    end

    if Helper:isMaskOff(name)  then
        return self:getNamebySex(sex)
    else
        return name
    end
end

--获取雇佣价格和支付方式
--fidelity 仆人初始忠诚度
function PuRenModel:getPriceEmploy(defaultZhongCheng,loyallv,jobType,K4)
    local payMethod --支付方式(元宝：20%，银票：80%)
    local priceEmploy = 0
    local random = math.random( 1,100)
    if random > 20 then
        payMethod = "yinpiao"
    else
        payMethod = "yuanbao"
    end

    local K1 = loyallv
    local K2 = defaultZhongCheng --忠诚度
    local K3 = HomelandRoleUtil:getRoleTypeData(jobType).hirevlaue 
    local K4 = K4
    switch(payMethod,
    {
        ["yinpiao"] = function()       
            priceEmploy = math.floor((math.min(K1*0.5+K3*0.4+K4*0.5,200)))*14
        end,
        ["yuanbao"] = function()
            priceEmploy = math.floor(math.min(math.min(K1*0.5+K3*0.4+K4*0.5,200)*0.35,50))*14
        end
    })
    return priceEmploy,payMethod
end

--@desc: 本地生成招募列表
--@author:Liang SongQiang
--@time:2018-09-03 16:26:18
function PuRenModel:initEmployListInLocal()
    local professionList ,shenShiList = self:getProfessionList(self._lifeTrim,self._zc)
    local employListData = {}
    if MapIsEmpty(professionList) then
        return employListData
    end
    for i = 1 ,#professionList do
        local purenData = self:getRandomPuRenResult(self._zc,professionList[i].jobType,professionList[i].shenShi)
        table.insert(employListData,purenData)
    end

    return employListData
end

--@desc: 设置需要裁剪的数据
--@author:Liang SongQiang
--@time:2018-09-03 15:29:03
--@life_trims: 需要裁剪的数据
function PuRenModel:setlifeTrims( life_trims )
    self._lifeTrim = life_trims
end

--@desc: 需要招募仆人的用户地图id
--@author:Liang SongQiang
--@time:2018-09-03 15:29:45
--@mid: 用户地图id
function PuRenModel:setMid( mid )
    self._mid = mid
end

--@desc: 招募列表生成所需要的忠诚度
--@author:Liang SongQiang
--@time:2018-09-03 15:31:06
--@zhongCheng: 管家忠诚度
function PuRenModel:setZhongCheng(zhongCheng)
    self._zc = zhongCheng
end

--@desc: 设置招募npc的Id
--@author:Liang SongQiang
--@time:2018-09-03 15:32:25
--@npcId:招募npc的ID 
function PuRenModel:setNpcId(npcId)
    self._npcId = npcId
end

function PuRenModel:getNpcId()
    return self._npcId
end

--@desc: 获取列表
--@author:Liang SongQiang
--@time:2018-09-03 16:18:33
function PuRenModel:getList()
    return self._list
end


function PuRenModel:pop( index )
    if MapIsEmpty(self._list) then
        return
    end

    table.remove(self._list,index)
end

function PuRenModel:push( data )
    if MapIsEmpty(self._list) then
        self._list = {}
    end

    table.insert( self._list,data)
end

function PuRenModel:clear()
    self._npcId = nil
    self._zc = nil
    self._list = {}
    self._mid = nil
    self._lifeTrim = nil
end

--@desc: 刷新列表
--@author:Liang SongQiangz
--@time:2018-09-03 16:34:58
--@needCost:是否需要花费金钱
--@callback: 回调函数
function PuRenModel:refresh(needCost,callback)
    local save_type = 1

    if needCost == 2 then
        save_type = 2
    end
    
    local list = self:initEmployListInLocal()
    
    HttpManagerEx:saveEmployeeList(save_type,self._npcId,list,function(status, errcode, errmsg, data)
        if status == 200 then
            if errcode == 0 then
                if callback then
                    self._list = {}
                    for i = 1,#data do
                        if data[i].state == 0 then
                            table.insert(self._list,data[i])
                        end
                    end

                    callback()
                end
            else
                PopText(errmsg)
            end
        else
            PopText(errmsg)
        end
    end, IS_SHOW_WAITING)
end


--@desc: 生成仆人招募列表
--@author:Liang SongQiang
--@time:2018-09-03 15:18:55
--@life_trims:需要裁剪的身世模板ID
--@zhongcheng:忠诚度
--@callback: 生成成功后的回调函数
function PuRenModel:initEmployList(callback)
    HttpManagerEx:getEmployList(self._npcId,self._mid,function(status, errcode, errmsg, data)
        if status == 200 then
            if errcode == 0 then
                self:setlifeTrims(data.shenshi)

                if not MapIsEmpty(data.list) then
                    self._list ={}
                    for i = 1,#data.list do
                        if data.list[i].state == 0 then
                            table.insert(self._list,data.list[i])
                        end
                    end

                    callback()
                else
                    self:refresh(1,callback)
                end
            else
                PopText(errmsg)
            end
        else
            PopText(errmsg)
        end
    end, IS_SHOW_WAITING)
end


function PuRenModel:getDsc()
    local num = Helper:getDef(#self._list, 0)
    local HomelandDesc = require("app.models.HomelandModel.HomelandDesc")
    local dsc = HomelandDesc:getEmployLayerTitalDsc(num)

    return dsc
end


function PuRenModel:getJobDsc(jobType)
    local jobDsc = "仆人"
	if jobType == "menke001" then
		jobDsc = "门客"
	end
	return jobDsc
end

function PuRenModel:getSexDsc(sex)
	local sexDsc = "他"
	if sex == "女" then
		sexDsc = "她"
	end
	return sexDsc
end


--data 服务器下发的雇佣数据
--雇佣仆人成功的回调
function PuRenModel:employeeNpc(index,callback)
    local npc = self._list[index]
    if MapIsEmpty(npc) then
        print("没有NPC信息,"..index)
        Helper:print_lua_table(self._list)
        return
    end

	local jobType = npc.jobType
	local name = npc.name
	local unit = npc.price_unit
    local price = npc.price
    local hid = npc.hid or 0

    local jobDsc= self:getJobDsc(jobType)

    local sexDsc = self:getSexDsc(npc.sex)

	local chineseJob = HomelandRoleUtil:getCHAJobTypeName(jobType)


    PopupLayerController:showLayer("PopConfirmLayer",function (layer)
        layer:showRefreshPannel()
        local temp = {
            yuanbao = "元宝",
            yinpiao = "银票"
        }
        local text = "雇佣"..name.."首次需支付"..price..temp[unit].."，之后每7天需要发一次薪，"..name.."的日薪是"..(price/14)..temp[unit].."。请问是否要雇佣？"

        if unit == "yinpiao" then
            HttpManagerEx:viewCurrencyByType("yinpiao", User:getRole():getCurrencyVersion(),function(status, errcode, errmsg, data)
                if status == 200 then
                    if errcode == 0 then
                        layer:setDesc2("当前拥有银票:"..data.number,"YEL")
                    else
                    PopText(errmsg)
                    end
                else
                    PopText(errmsg)
                end
            end, IS_SHOW_WAITING)
        elseif  unit == "yuanbao" then
            HttpManagerEx:getYuanBao(function(status, errcode, errmsg, data)
                if status == 200 then
                    if errcode == 0 then
                        layer:setDesc2("当前拥有元宝:"..data.yuanbao,"YEL") 
                    else
                        PopText(errmsg)
                    end
                end
            end) 
        else
            assert(false,"GuanJiaModel:employeeNpc  购买单位出错")
        end
        
        layer:setDsc(text)
        layer:setButtonNameAndCallFunc(
            "确定",
            function()
                local objId = HomelandRoleUtil:createObjId(jobType)

                local mid = User:getRole():getHouseId()

                local push_data = {}
                if hid == 0 then
                    push_data = npc
                end

                print("hid = ",hid,"objId = ",objId,"mid = ",mid)
                HttpManagerEx:addEmployee(hid,objId,mid,self._npcId,push_data,function(status, errcode, errmsg, data)
                    if status == 200 and errcode == 0 then
                        local successText = "你花了"..price..temp[unit].."雇佣"..name.."成为你的"..jobDsc.."，"..sexDsc.."将作为"..chineseJob.."为你服务，请善待"..sexDsc.."，及时发薪。"
                        RichPrint("main",successText)


                        local currMap = User:getRole():getCurrMap()
                        local fjId = data.fjId
                        if currMap:getMapType() == MAP_TYPE.MYHOME then	
                            local role = clone(data)
                            
                            role = HomelandRoleUtil:initHomelandMapRole(role,currMap)
                            role.id = data.rwId
                            currMap:createRole(role)
                            currMap:addRoomRole(fjId,objId)

                            currMap:addPersonJobCount(jobType,1)

                            self:updateMapPuRenInfo("add",currMap,data.rwId,data.fjId,name)

                            local HomelandUtil = require("app.models.HomelandModel.HomelandUtil")
                            HomelandUtil:updateRoleFlag(currMap)

                            currMap.__MapLayer:delayRefreshMap()
                        else
                            local role = User:getRole()
                            local mid = role:getHouseId()
                            role:setMapWithId("user_fb_" .. mid, nil)
                        end
                        
                        HomelandRoleUtil:addServantCount(1)
                    
                        local rwId = data.rwId
                        local id_index = string.split(rwId,"_")[2]

                        User:getRole():setHomelandAttr("prIdIndex",tonumber(id_index))
                    
                        -- 需要服务器把雇佣成功的数据下发
                        HomelandRoleUtil:recordEmployData(data.rwId,data)

                        self:pop(index)
                    
                        if callback then
                            callback()
                        end
                    else
                        print("errcode : ",errcode)
                        PopText(errmsg)
                    end
                end, IS_SHOW_WAITING)
            end
        )

        layer:setCanelButtonNameAndCallFunc("取消")
    end)
end

--刷新副本仆人基本信息
--{rwid = 仆人id , fjId = 仆人所在房间,rwName = 仆人名字}
function PuRenModel:updateMapPuRenInfo(operation,map,rwId,fjId,rwName)
    if MapIsEmpty(map) then 
        return
    end
    if MapIsEmpty(map.puRenInfo) then 
        map.puRenInfo = {}
    end
    local puRenInfo = map.puRenInfo
    if operation == "add" then 
        local prBaseInfo ={} 
        prBaseInfo.rwId = rwId
        prBaseInfo.fjId = fjId
        prBaseInfo.name = rwName
        table.insert(puRenInfo,prBaseInfo)
    elseif operation == "reduced" then 
        for k,v in pairs(puRenInfo) do 
            if rwId == v.rwId then 
                puRenInfo[k] = nil
                break
            end
        end
    elseif operation == "changeRoom" then
        for k,v in pairs(puRenInfo) do 
            if rwId == v.rwId then 
                puRenInfo[k].fjId = fjId
                break
            end
        end
    end
    map.puRenInfo = puRenInfo
end

function PuRenModel:getPuRenRoomId(map,rwId)
    if MapIsEmpty(map) then 
        return
    end
    if MapIsEmpty(map.puRenInfo) then 
        map.puRenInfo = {}
    end
    local puRenInfo = map.puRenInfo

    for k,v in pairs(puRenInfo) do 
        if rwId == v.rwId then 
            return v.fjId
        end
    end
    print("未找到该仆人所在房间")
    return
end

return PuRenModel000