local GuanJiaModel = {}

local HomelandRoleUtil = require("app.models.HomelandModel.HomelandRoleUtil")
local familylist = requireWithEncrypt("script.others.familylist")
local roleMobanList = familylist["人物模板设计"]  


--获取随机生成的管家信息
--参数traitValue = result.arg2,条件结果填的参数，特性值
function GuanJiaModel:getRandomGuanJiaResult(traitValue)
    local guanjiaData = {}
    local name = "管家"
    local sex = "男"
    local age = 0
    local looks = 0
   	local defaultZhongCheng = 0 -- 初始忠诚度
    local price = 0
    local price_unit = "yinpiao"
	local speedZhongCheng = 0 --忠诚成长度
   
    local character = "" --性格id
    local traitVal = 0
	-- local trait1 = ""
	-- local trait2 = ""
	-- local trait3 = ""
    local jobType = "guanjia001"  --职业类型；jobType 职业:0 无职业 1管家 2仆人 3门客
	local modal = "" --武功信息id
    local mobanSkill = {}
    local shenShi = ""

    local agelist,sexlist,texinglist,looklist,lifelist = HomelandRoleUtil:getAttrList(jobType)
    if agelist then
        age = math.random(agelist[1],agelist[2])
    end

    sex = Helper:getDef(self._sex,"男")

    if looklist then
        looks = math.random(looklist[1],looklist[2])
    end
    -- if lifelist then
    --     shenShi = lifelist[math.random(1,#lifelist)]
    -- end
    traitVal = traitValue
    name = self:getGjRandomName(sex)
    
    local conformList =  HomelandRoleUtil:getTexingList(traitValue) --符合特点值要求的特点列表
    local finalList = {}   --最终符合要求的特性列表
    if texinglist and conformList then
        for k,v in pairs(texinglist) do
            for ker,value in pairs(conformList) do
                if v == value then
                    table.insert(finalList,v)
                end
            end
        end
        -- print("------------------finalList--------------------")
        -- Helper:print_lua_table(finalList)
        -- print("------------------finalList--------------------end")
        local list = finalList
        local count = HomelandRoleUtil:getTexingCount()
        local index
        if not MapIsEmpty(list) then
            if count == 0 then
            elseif count == 1 then
                index = math.random(1,#list)
                guanjiaData["trait1"] = list[index]
            elseif count == 2 then
                for i =1 ,2 do
                    index = math.random(1,#list)
                    guanjiaData["trait"..i] = list[index]
                    table.remove( list,index)
                end
            elseif count == 3 then
                for i =1 ,3 do
                    index = math.random(1,#list)
                    guanjiaData["trait"..i] = list[index]
                    table.remove( list,index)
                end
            end
        end
    end
    
    if sex == "男" then
        defaultZhongCheng = math.random(1,200)
        price = math.random(1500,2000)
        modal = self:getWugongInfo(sex)
    elseif sex == "女" then
        defaultZhongCheng = math.random(50,230)
        price = math.random(1800,2400)
        modal = self:getWugongInfo(sex)
    else
        assert(false,"管家性别未知")
    end

    character = HomelandRoleUtil:getRandomCharacterId()

    local dailyUpZhongcheng = HomelandRoleUtil:getCharacterFactor(jobType).Dailyup1
	local dailyUpZhongcheng1 = HomelandRoleUtil:getCharacterAttr(character).Dailyup

    speedZhongCheng = dailyUpZhongcheng*dailyUpZhongcheng1

    mobanSkill = HomelandRoleUtil:getUploadWebRoleSkillArray(modal)
    
    guanjiaData.name = name
    guanjiaData.sex = sex
    guanjiaData.age = age
    guanjiaData.looks = looks
    guanjiaData.shenShi = shenShi
    guanjiaData.traitVal = traitVal
    guanjiaData.jobType = jobType
    guanjiaData.defaultZhongCheng = defaultZhongCheng
    guanjiaData.speedZhongCheng = speedZhongCheng
    guanjiaData.price = price
    guanjiaData.price_unit = price_unit
    guanjiaData.modal = modal
    guanjiaData.character = character
    guanjiaData.leave_day = ""
    guanjiaData.mobanSkill = mobanSkill
    return guanjiaData
end

--获取招募管家数据列表
function GuanJiaModel:initEmployListInLocal()
    local list = {}
    for i = 1, 3 do
        table.insert( list,self:getRandomGuanJiaResult(self._traitValue))
    end
    return list
end 

function GuanJiaModel:getWugongInfo(sex)
    local randomMobanId = math.random(1,53)
    if sex == "女" then
        randomMobanId = math.random(10,40)
    end
    if randomMobanId < 10 then
        randomMobanId = "moban00"..randomMobanId
    else
        randomMobanId = "moban0"..randomMobanId
    end

    return tostring(randomMobanId)
end

--@npcId:招募npc的ID 
--@desc: 设置招募npc的Id
function GuanJiaModel:setNpcId(npcId)
    self._npcId = npcId
end

function GuanJiaModel:getNpcId()
    return self._npcId
end

--@mid: 用户地图id
function GuanJiaModel:setMid( mid )
    self._mid = mid
end

--设置特性值
function GuanJiaModel:setTraitValue(traitValue)
    self._traitValue = traitValue
end

--设置性别
function GuanJiaModel:setSex(sex)
    self._sex = sex
end

function GuanJiaModel:clear()
    self._npcId = nil
    self._traitValue = nil
    self._list = {}
    self._mid = nil
    self._sex = nil
end

--@desc: 获取列表
--@author:Liang SongQiang
--@time:2018-09-03 16:18:33
function GuanJiaModel:getList()
    return self._list
end

function GuanJiaModel:pop( index )
    if MapIsEmpty(self._list) then
        return
    end

    table.remove(self._list,index)
end
--@desc: 生成仆人招募列表
--@callback: 生成成功后的回调函数
function GuanJiaModel:initEmployList(callback)
    HttpManagerEx:getEmployList(self._npcId,self._mid,function(status, errcode, errmsg, data)
        if status == 200 then
            if errcode == 0 then
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

--@desc: 刷新列表
--@needCost:是否需要花费金钱
--@callback: 回调函数
function GuanJiaModel:refresh(needCost,callback)
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

                    if callback then
                        callback()
                    end
                end
            else
                PopText(errmsg)
            end
        else
            PopText(errmsg)
        end
    end, IS_SHOW_WAITING)
end

function GuanJiaModel:getDsc()
    local dsc = "我书院长于育人，多年来在管家培养上颇有建树。以下便是我书院培养的学生，皆有意谋求管家一职，敢问可有意雇佣？"
    return dsc
end

--雇佣管家成功的回调
function GuanJiaModel:employeeNpc(index,callback)
    local npc = self._list[index]
    if MapIsEmpty(npc) then
        print("没有NPC信息,"..index)
        Helper:print_lua_table(self._list)
        return
    end

    local text = ""

	local jobType = npc.jobType
	local name = npc.name
	local unit = npc.price_unit
    local price = npc.price
    local hid = npc.hid or 0

    PopupLayerController:showLayer("PopConfirmLayer",function (layer)
        layer:showRefreshPannel()
        local temp = {
            yuanbao = "元宝",
            yinpiao = "银票"
        }
        local HomelandUtil = require("app.models.HomelandModel.HomelandUtil")

        if HomelandUtil:isJobTypeFromFlag("guanjia001") == true then
            text = "你得家园中已经有一名管家了,雇佣后会将其自动辞退,是否继续雇佣？雇佣"..name.."需花费"..price..temp[unit].."。"
        else
            text = "雇佣"..name.."需花费"..price..temp[unit]..",是否要雇佣？"
        end

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
        elseif unit == "yuanbao" then
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

        layer:setDsc(text.."RED（管家雇佣后无法辞退，请慎重选择）")
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
                HttpManagerEx:addEmployee(hid,objId,mid,self._npcId,{},function(status, errcode, errmsg, data)
                    if status == 200 and errcode == 0 then
                        local successText = "YEL"..name.."：多谢#ch#成全！以后家中事务尽可放心交给我，我一定替#ch#您打理得井井有条的。"
                        local HomelandDesc = require("app.models.HomelandModel.HomelandDesc")
                        successText = HomelandDesc:subChengHuText(successText)
                        RichPrint("main",successText)

                        User:getRole():setDayFlag("第一次管家交谈", 0)

                        local currMap = User:getRole():getCurrMap()
                        local fjId = data.fjId
                        if currMap:getMapType() == MAP_TYPE.MYHOME then	
                            local role = clone(data)
                            role = HomelandRoleUtil:initHomelandMapRole(role,currMap)
                            role.id = data.rwId
                            currMap:createRole(role)
                            currMap:addRoomRole(fjId,data.rwId)	

                            currMap:addPersonJobCount(jobType,1)
                            local HomelandUtil = require("app.models.HomelandModel.HomelandUtil")
                            HomelandUtil:updateRoleFlag(currMap)

                            currMap.__MapLayer:delayRefreshMap()
                        else
                            local role = User:getRole()
                            local mid = role:getHouseId()
                            role:setMapWithId("user_fb_" .. mid, nil)
                            role:setInheritFlag("haveGj",1)
                        end
                    
                        -- 需要服务器把雇佣成功的数据下发
                        HomelandRoleUtil:recordEmployData(data.rwId,data)
                    
                        local FangQiModel = require("app.models.HomelandModel.FangQiModel")
                        FangQiModel:updateInfo({isDispose = true})

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

--获取随机管家名字
function GuanJiaModel:getGjRandomName(sex)
    local xing, nanMing, nvMing = {}, {}, {}
    xing = {"安", "柏", "鲍", "毕", "曹", "岑", "昌", "常", "丁", "酆", "傅", "郝", "赫", "华", "姜", "解", "雷", "廉", "吕", "马", "聂", "潘", "彭", "史", "汤", "陶", "滕", "邬", "许", "严", "应", "杭", "喻", "李", "仇", "卢", "项", "江", "万", "堪", "黎", "席", "经", "车", "贾", "裘", "支", "费", "祁", "屈", "纪", "鄂", "田", "尹", "阎", "蔡", "粱", "罗", "咎", "夏", "禹", "高", "管", "穆", "汪", "骆", "周", "袁", "姚", "由", "吴", "钮", "惠", "刘", "诸", "甄", "荀", "张", "孟", "於", "俞", "景", "唐", "石", "吉", "薛", "魏", "符", "包", "羊", "宓", "程", "荣", "詹", "家", "崔", "封", "钱", "洪", "左", "贺", "邵", "邢", "燕", "鹿", "方", "韩", "戚", "范", "冯", "谢", "施", "任", "段", "魏", "柳", "鲁", "裴", "卫", "沈", "陆", "邹", "苏", "王", "孔", "翟", "秦", "何", "韦", "卓", "蒋", "窦", "苗", "郑", "陈", "翁", "牧", "贲", "孙", "牟", "郁", "颜", "闵", "莫", "庞", "樊", "蔺", "嵇", "邱", "向", "楼", "缪", "龚", "温", "褚", "柯", "宋", "徐", "虞", "韶", "郜", "宗", "凌", "郦", "霍", "宣", "狄", "叶", "卜", "元", "单", "邓", "白", "慕", "巫", "廖", "沙", "武", "仲", "柳", "唐", "叶", "方", "连", "宁", "祖", "齐", "阮", "童", "浑", "秋", "尤", "于", "章", "支", "朱", "诸", "顾", "房", "董", "余", "侯", "宫", "伍", "杨", "赵", "乔", "佟", "萧", "占", "干", "雍", "糜", "全", "葛", "苻", "权", "祝", "皮", "庾", "曲", "赖", "瞿", "牛", "资", "公冶", "伯赏", "轩辕", "长孙", "司马", "鲜于", "欧阳", "司空", "单于", "夏侯", "上官", "皇甫", "南宫", "诸葛", "巫马", "阳佟", "太叔", "东方", "尉迟", "呼延", "慕容", "宇文", "淳于", "子车", "闾丘", "东郭", "归海", "赫连", "司空", "乐正", "濮阳", "西门", "百里", "司徒", "令狐", "左丘", "公西", "谷粱", "拓跋", "赵", "钱", "孙", "李", "周", "吴", "郑", "王", "冯", "陈", "卫", "蒋", "沈", "韩", "杨", "朱", "秦", "许", "何", "吕", "张", "孔", "曹", "严", "华", "金", "魏", "陶", "姜", "戚", "谢", "章", "云", "苏", "潘", "葛", "范", "彭", "鲁", "韦", "昌", "马", "苗", "方", "俞", "任", "袁", "柳", "史", "唐", "费", "岑", "薛", "雷", "贺", "倪", "汤", "滕", "殷", "罗", "毕", "郝", "乐", "傅", "齐", "康", "伍", "余", "元", "顾", "孟", "平", "黄", "穆", "萧", "尹", "姚", "邵", "堪", "汪", "狄", "明", "成", "戴", "宋", "庞", "熊", "纪", "舒", "屈", "项", "祝", "董", "粱", "杜", "蓝", "席", "季", "贾", "江", "童", "颜", "郭", "梅", "盛", "林", "刁", "钟", "徐", "高", "夏", "蔡", "田", "樊", "胡", "凌", "霍", "万", "支", "柯", "管", "卢", "莫", "房", "解", "应", "宗", "丁", "邓", "洪", "包", "诸", "左", "石", "崔", "吉", "龚", "程", "裴", "陆", "荣", "翁", "荀", "惠", "甄", "魏", "封", "段", "巫", "乌", "焦", "牧", "秋", "伊", "仇", "甘", "武", "刘", "景", "詹", "束", "龙", "叶", "司", "韶", "郜", "蒲", "赖", "卓", "蒙", "乔", "姬", "冉", "温", "庄", "柴", "慕", "习", "向", "易", "廖", "文", "越", "师", "巩", "聂", "敖", "冷", "简", "曾", "沙", "关", "游", "万", "欧阳", "太史", "端木", "上官", "司马", "东方", "独孤", "南宫", "万俟", "闻人", "夏侯", "诸葛", "尉迟", "公羊", "赫连", "澹台", "皇甫", "宗政", "濮阳", "公冶", "太叔", "申屠", "公孙", "慕容", "仲孙", "钟离", "长孙", "宇文"}
    nanMing = {"和光","烨凌","辰韦","昊穹","昊天","俊捷","修","原","伯","甫","乐逸","彬","耀","茂","吉","骏","风","硕","慨","泰","才","飞龙","岁","曜","建业","振国","天泽","宏达","俊明","棋同","承泽","正业","乐志","阳炎","鸿云","兴为","鸿德","博延","震博","光泽","昊伟","景明","昂","逸","令","哲茂","和","朔","翰","琪","沛","楠","绍","鹏云","长","兴","元武","鸿卓","飞虎","俊英","子明","庆生","光","德本","俊侠","海超","智宇","毅君","晨","浩言","涵亮","严昆","阔","华晖","明旭","怿","民","羽","晔","明俊","光赫","湛","令枫","翰墨","永福","国源","景辉","鸿达","元忠","昆颉","耘涛","子实","文翰","文滨"}
    nvMing = {"静涵","文君","芷若","清宁","秀筠","菱","淑婉","紫蕙","蕴","淑珍","晴","菁","黛","梓童","芸溪","星然","宣","兰蕙","洛灵","恬","媚","妙","燕婉","茹薇","春英","碧琳","云梦","曼音","玄清","曜儿","幼仪","霞月","秋怜","莉","冰凝","槐","艳芳","初怜","惠丽","颖馨","醉","然","映","秀","茵","湘","秀媛","秋露","静雅","爰爰","洁玉","颖","忆","琬","歌云","倾","乐欣","芊丽","璇","清","文心","雅楠","佳美","顺","筠","碧莹","娇然","瑶瑾","晗月","蓝尹","敏慧","吉敏","莹","瑶","竹月","灵秋","雪漫","冰","霞姝","倩美","骊婷","幼安","华月","菡","婉丽","晴丽","莹华","翠凝","清秋","霏","彤蕊","婉静","晶滢","令慧","悠婉","云蓉","妞","楠青","若华","倚","代容","凤","丹"}
    
    local retXing = xing[math.random(1, #xing)]
    local retMing
    if sex == "male" or sex == "男" then
        retMing = nanMing[math.random(1, #nanMing)]
    elseif sex == "female" or sex == "女" then
        retMing = nvMing[math.random(1, #nvMing)]
    end
    
    local name = retXing .. retMing

    if Helper:isMaskOff(name) then
        return self:getGjRandomName(sex)
    else
        return name
    end
end

return GuanJiaModel000000000