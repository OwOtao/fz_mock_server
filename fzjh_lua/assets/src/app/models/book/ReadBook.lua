local ReadBook = {}

--@RefType [src.app.models.book.BookLiterary#BookLiterary]
local BookLiterary = require("app.models.book.BookLiterary")

local RoleTaskControllor = require("app.views.layer.RoleLayer.RoleTaskControllor")
local DialogCLayer = require("app.views.layer.DialogLayer.DialogCLayer")

local NOT_READ_REASON = {
    ["READING"] = "正在研读其他书籍。",
    ["PLACE"] = "先专心眼前事吧，现在不宜看书!",
    ["SKILL_LV"] = "读书识字等级不足,无法研读。",
    ["DUSHU_LV_ZERO"] = "没学习过江湖毒术，无法研读",
    ["DUSHU_LV"] = "江湖毒术等级不足，无法研读",
    ["DUANZAO_LV_ZERO"] = "没学习过锻造之术，无法研读",
    ["DUANZAO_LV"] = "锻造之术等级不足，无法研读",
    ["JING"] = "精力不足，无法研读"
}

-- {literaryId=[[mengzi]],index=1,id=3982,count=22,exp=1176234.5835501,itemId=[[yeshushuji9]]}

-- 显示详细信息窗口
local function setDialogC(params)
    if MapIsEmpty(params) then
        return
    end

    local dialogC = DialogCLayer:getInstance()

    local func1 = function()
        if params.func1 then
            params.func1()
        end
        dialogC:unscheduleAll()
    end

    local func2 = function()
        if params.func2 then
            params.func2()
        end
        dialogC:unscheduleAll()
    end

    local func3 = function()
        if params.func3 then
            params.func3()
        end
        dialogC:unscheduleAll()
    end

    local func4 = function()
        if params.func4 then
            params.func4()
        end
        dialogC:unscheduleAll()
    end

    if params.update == nil then
        params.update = function()
        end
    end

    dialogC:show(params.title, params.list, params.state)
    dialogC:setButton1(params.btn1, func1, params.unHide1)
    dialogC:setButton2(params.btn2, func2, params.unHide2)
    dialogC:setButton3(params.btn3, func3, params.unHide3)
    dialogC:setButton4(params.btn4, func4, params.unHide4)
    dialogC:setListHeight(true)
    dialogC:setBack(false)
    dialogC:setDescTextVisible(false)
    dialogC:unscheduleAll()
    dialogC:schedule(
        function(ft)
            params.update()
        end,
        1
    )
end

function ReadBook:getBookName(id)
    local name = ""

    local book = BookLiterary:getLiteraryById(id)

    if book then
        name = book.name
    end

    return Helper:getDef(name, "")
end

function ReadBook:readingState()
    local role = User:getRole()

    local status, errcode = false, "READING"

    local read_book = role:getAttr("read_book") or {}

    if role:isInCurrState(ROLE_CURR_STATE_READ) and read_book.id ~= self._id then
        status = true
    end

    return status, errcode
end

function ReadBook:readPlace()
    local status, errcode = false, "PLACE"

    if self._place then
        status = true
    end

    return status, errcode
end

function ReadBook:duShuShiZiLv()
    local role = User:getRole()

    local status, errcode = false, "SKILL_LV"

    local skill_lv = role:getSkillLv("dushushizi")

    if skill_lv < BookLiterary:getReadNeedLv(self._id) then
        status = true
    end

    if skill_lv < role:getLiteraryLv(self._id) then
        status = true
    end

    return status, errcode
end

function ReadBook:poisonLv()
    local role = User:getRole()
    local status, errcode = false, "DUSHU_LV"

    local dushulevel = BookLiterary:getReadNeedPoisonLv(self._id)

    if type(dushulevel) ~= "string" then
        return status, errcode
    end

    local roleDuShuLv = Helper:getDef(role:getSkillLv("jianghudushu"), 0)

    if roleDuShuLv == 0 then
        errcode = "DUSHU_LV_ZERO"
        status = true
        return status, errcode
    end

    local limitList = string.split(dushulevel, ";")

    local minlv, maxlv = limitList[1] or 0, limitList[2] or 0

    print("............dushulevel", minlv, maxlv, roleDuShuLv)

    if tonumber(minlv) > roleDuShuLv then
        status = true
    end

    return status, errcode
end

function ReadBook:duanZaoLv()
    local role = User:getRole()
    local status, errcode = false, "DUANZAO_LV"

    local duanzaolevel = BookLiterary:getReadNeedForgeLv(self._id)

    if type(duanzaolevel) ~= "string" then
        return status, errcode
    end

    local roleDuanZaoLv = Helper:getDef(role:getSkillLv("duanzaozhishu"), 0)

    if roleDuanZaoLv == 0 then
        errcode = "DUANZAO_LV_ZERO"
        status = true
        return status, errcode
    end

    local limitList = string.split(duanzaolevel, ";")

    local minlv, maxlv = limitList[1] or 0, limitList[2] or 0

    print("............duanzaolevel", minlv, maxlv, roleDuanZaoLv)

    if tonumber(minlv) > roleDuanZaoLv then
        status = true
    end

    return status, errcode
end

--@desc: 检查能不能读书
--@author:Liang SongQiang
--@time:2018-09-12 17:11:33
function ReadBook:onCheck()
    local chekcList = {
        self.readingState,
        self.readPlace,
        self.duShuShiZiLv,
        self.poisonLv,
        self.duanZaoLv
    }

    for i, func in ipairs(chekcList) do
        local status, errcode = func(self)

        if status then
            PopText(Helper:getDef(NOT_READ_REASON[errcode], "ERROR"))
            return false
        end
    end

    return true
end


--@desc: 检查能否提升江湖毒术经验
--@author:Liang SongQiang
--@time:2018-09-12 18:07:50
function ReadBook:checkPoisonSkillUp()
    --@RefType [src.app.models.role.Role#Role]
    local role = User:getRole()

    local roleSkillLv = Helper:getDef(role:getSkillLv("jianghudushu"), 0)

    local dushulevel = BookLiterary:getReadNeedPoisonLv(self._id)

    local limitList = string.split(dushulevel, ";")

    local minlv, maxlv = limitList[1] or 0, limitList[2] or 0

    if tonumber(maxlv) > 0 then
        if  roleSkillLv > tonumber(maxlv) then
            self._result.showPosionTips = 1
        else
            self._result.upPosisonLv = 1
        end
    end
end

--@desc: 检查能否提升锻造之术经验
--@author:Liang SongQiang
--@time:2018-09-12 18:08:09
function ReadBook:checkDuanZaoSkillUp()
    --@RefType [src.app.models.role.Role#Role]
    local role = User:getRole()

    local roleSkillLv = Helper:getDef(role:getSkillLv("duanzaozhishu"), 0)

    local dushulevel = BookLiterary:getReadNeedForgeLv(self._id)

    local limitList = string.split(dushulevel, ";")

    local minlv, maxlv = limitList[1] or 0, limitList[2] or 0

    if tonumber(maxlv) > 0 then
        if roleSkillLv > tonumber(maxlv) then
            self._result.showDuanZaoTips = 1
        else
            self._result.upDuanzaoLv = 1
        end
    
    end
end

function ReadBook:setPlace(place)
    self._place = place
end

function ReadBook:showReadDialog(id)
    self._id = id

    if not self:onCheck() then
        return
    end

    local role = User:getRole()

    self._result = {
        id = self._id,
        shuTong = 0,
        shuTongLv = 0,
        shuTongName = "",
        room = 0,
        showDuanZaoTips = 0,
        showPosionTips = 0,
        upPosisonLv = 0,
        upDuanzaoLv = 0,
        addLv = 0,
        currLv = 0,
        readTime = role:getAttr("jing") * 30
    }

    if role:isInCurrState(ROLE_CURR_STATE_READ) then
        local role_result = role:getAttr("read_book")
        self._id = role_result.id
        self._result._id =role_result.id
        self._result.upPosisonLv =role_result.isPosison
        self._result.upDuanzaoLv =role_result.isDuanZao
        self._result.shuTong =role_result.shuTong
        self._result.shuTongLv =role_result.shuTongLv
        self._result.shuTongName =role_result.shuTongName
        self._result.room =role_result.room

        self:showReading()
        return
    end


    self:checkPoisonSkillUp()

    self:checkDuanZaoSkillUp()

    self:startRead()
end

function ReadBook:showReading()
    local template = self:getReadingList()

    template.btn1 = "结束研读"
    template.func1 = function()
        local role = User:getRole()

        role:stopRead()

        if self._stopCallback then
            self._stopCallback()
            self._stopCallback = nil
        end
    end
    
    template.btn2 = "取消"

    setDialogC(template)
end

function ReadBook:checkBookRoom()
    if JIAYUAN_SYSTEM_IS_OPEN == false then
        return false
    end
    --@RefType [src.app.models.role.Role#Role]
    local role = User:getRole()

    local mid = role:getHouseId()

    if mid == nil then
        return false
    end

    local httpFinished = false
    local result = false

    HttpManagerEx:getAllRooms(
        mid,
        "tsfangjian006",
        function(status, errcode, errmsg, data)
            if status == 200 then
                if errcode == 0 then
                httpFinished = true
                if not MapIsEmpty(data) then
                        self._result.room = 1
                        result = true
                    end
                else
                    print(errcode, errmsg)
                end
            else
                print(status, errcode, errmsg)
            end
        end
    )

    while httpFinished == false do
        coroutine.yield()
    end
    return result
end

function ReadBook:checkShuTong()
    if JIAYUAN_SYSTEM_IS_OPEN == false then
        return false
    end
    
    --@RefType [src.app.models.role.Role#Role]
    local role = User:getRole()

    local mid = role:getHouseId()

    if mid == nil then
        return false
    end

    local httpFinished = false
    local result = false

    HttpManagerEx:getAllPersons(
        mid,
        "shutong001",
        function(status, errcode, errmsg, data)
            if status == 200 then
                if errcode == 0 then
                    httpFinished = true
                    if not MapIsEmpty(data) then
                        self._result.shuTong = 1
                        self._result.shuTongName = data[1].name
                        --@RefType [src.app.models.HomelandModel.HomelandRoleUtil#HomelandRoleUtil]
                        local HomelandRoleUtil = require("app.models.HomelandModel.HomelandRoleUtil")
                        self._result.shuTongLv = HomelandRoleUtil:getFidelityLv(data[1].defaultZhongCheng)
                        result = true
                    end
                else
                    print(errcode, errmsg)
                end
            else
                print(status, errcode, errmsg)
            end

        end
    )

    while httpFinished == false do
        coroutine.yield()
    end
    return result
end

--@desc: 打开阅读预览界面
--@author:Liang SongQiang
--@time:2018-09-12 20:08:12
function ReadBook:startRead()
    if JIAYUAN_SYSTEM_IS_OPEN then
        local WaitingLayer = require("app.views.layer.PopLayer.WaitingLayer")
        local waitingLayer = WaitingLayer:createInRunningScene()

        local msg = self:checkBookRoom() 

        if msg == true then
            msg = self:checkShuTong()

            if msg then
                local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")
                local dialog = DialogALayer:getInstance()
                dialog:hide()
                dialog:show("少侠，需要书童" .. self._result.shuTongName .. "陪读吗?")
                dialog:setBack(false)
                dialog:setButton1(
                    "是",
                    function()
                        self:__startRead()
                    end
                )
                
                dialog:setButton2(
                    "否",
                    function()
                        self._result.shuTong = 0
                        self._result.shuTongLv = 0
                        self._result.shuTongName = ""
                        self:__startRead()
                    end
                )
            else
                self:__startRead()
            end
        else
            self:__startRead()
        end
        waitingLayer:hide()
    end
end

function ReadBook:__startRead()
    local template = self:getShowList()
    template.btn1 = "开始研读"
    template.func1 = function()
        if self._result.showDuanZaoTips == 1 then
            self:duanZaoSkillReadTips()
        elseif self._result.showPosionTips == 1 then
            self:poisonSkillTips()
        else
            local role = User:getRole()
            if role:getLv() < role:getSkillLv("dushushizi") then
                self:duShuShiZiSkillTips()
            else
                self:read()
            end
        end
    end
    template.btn2 = "取消"

    setDialogC(template)
end

--@desc: 锻造之术过高提示
--@author:Liang SongQiang
--@time:2018-09-12 20:47:32
function ReadBook:duanZaoSkillReadTips()
    local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")
    local dialog = DialogALayer:getInstance()
    dialog:hide()
    dialog:show("YEL你对锻造之术已经颇有研究了，研读此书恐怕无法对你的锻造之术有所增益，是否继续研读？（继续研读仍可能增加读书识字经验）")
    dialog:setButton1(
        "继续研读",
        function()
            self:read()
        end
    )

    dialog:setButton2(
        "取消",
        function()
            dialog:hide()
        end
    )
end

--@desc: 江湖毒术等级过高提示
--@author:Liang SongQiang
--@time:2018-09-12 20:47:10
function ReadBook:poisonSkillTips()
    local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")
    local dialog = DialogALayer:getInstance()
    dialog:hide()
    dialog:show("YEL你对江湖毒术已经颇有研究了，研读此书恐怕无法对你的江湖毒术有所增益，是否继续研读？（继续研读仍可能增加读书识字经验）")
    dialog:setButton1(
        "继续研读",
        function()
            self:read()
        end
    )

    dialog:setButton2(
        "取消",
        function()
            dialog:hide()
        end
    )
end

--@desc: 读书识字等级过高提示
--@author:Liang SongQiang
--@time:2018-09-12 20:53:27
function ReadBook:duShuShiZiSkillTips()
    local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")
    local dialog = DialogALayer:getInstance()
    dialog:hide()
    dialog:show("YEL你的人物等级偏低，研读书籍，可能不会对读书识字带来提升，仅会提升书籍等级。")
    dialog:setButton1(
        "继续研读",
        function()
            self:read()
        end
    )

    dialog:setButton2(
        "取消",
        function()
            dialog:hide()
        end
    )
end

--@desc 开始阅读
function ReadBook:read()
    RoleTaskControllor:clickYanDuLayer(
        --@desc 开始研读
        function()
            local role = User:getRole()

            --@RefType [src.app.models.HomelandModel.HomelandDesc#HomelandDesc]
            local HomelandDesc = require("app.models.HomelandModel.HomelandDesc")
            local startDesc = HomelandDesc:getStartReadDesc(self:getBookName(self._id),self._result.room,self._result.shuTong,self._result.shuTongName)

            RichPrint("main", startDesc)

            local result = {
                id = self._id,
                startTime = GetTime(),
                isPosison = self._result.upPosisonLv,
                isDuanZao = self._result.upDuanzaoLv,
                shuTong = self._result.shuTong,
                shuTongLv = self._result.shuTongLv,
                shuTongName = self._result.shuTongName,
                room = self._result.room
            }

            role:setAttr("read_book", result)
            role:setFlag("当前研读书籍", self._id)
            role:setRoleCurrState(ROLE_CURR_STATE_READ)


            if self._startCallback then

                self._startCallback()

                self._startCallback = nil
            end
        end,
        --@desc 取消
        function()
            -- self:
        end
    )
end

function ReadBook:getTimeStr(time)
    local hour, min, sec
    hour = math.floor(time / 3600)
    min = math.floor(math.mod(time / 60, 60))
    sec = math.floor(math.mod(time, 60))

    return hour .. "小时" .. min .. "分钟" .. sec .. "秒"
end

function ReadBook:getShowList()
    local bookName = self:getBookName(self._id)
    local role = User:getRole()
    local currLv = role:getLiteraryLv(self._id)
    local currExp = role:getLiteraryExp(self._id)
    local exp = BookLiterary:getReadSecExp(role:getFinalAttr("currInt"),self._result.shuTongLv)
    local addLv = role:getLiteraryLvByExp(currExp + (self._result.readTime * exp))

    -- 等级超过读书识字等级 只能研读到读书识字的等级+1
    if addLv > role:getSkillLv("dushushizi") + 1 then
        addLv = role:getSkillLv("dushushizi") + 1
    end

    local aftAddExp = role:getLiteraryExpByLv(addLv)

    if addLv == currLv then
        aftAddExp = currExp + (self._result.readTime * exp)
    end

    local time = (aftAddExp - currExp) / exp

    local timeStr = self:getTimeStr(time)
    if PRINT_MODE == 1 then
        print("aftAddExp",aftAddExp)
        print("currExp : ",currExp)
        print("exp sec : ",exp)

        print("time : ",time)
    end
    
    local firstTitle = ""
    local firstNum = ""
    if self._result.shuTong == 1 then
        firstTitle = "书童："
        firstNum = self._result.shuTongName
    else
        firstTitle = "精力："
        firstNum = tostring(math.floor(role:getAttr("jing"))) .. "/" .. tostring(math.floor(role:getJingMax()))
    end

    local template = {
        title = "你要开始研读" .. bookName .. "吗？",
        list = {
            {
                title = firstTitle,
                num = firstNum
            },
            {title = "研读时长：", num = timeStr},
            {title = "书籍：", num = bookName},
            {title = "等级：", num = currLv .. "→" .. addLv}
        }
    }
    return template
end

function ReadBook:getReadingList()
    local bookName = self:getBookName(self._id)
    local role = User:getRole()
    local currLv = role:getLiteraryLv(self._id)
    local currExp = role:getLiteraryExp(self._id)
    local exp = BookLiterary:getReadSecExp(role:getFinalAttr("currInt"),self._result.shuTongLv)
    local addLv = role:getLiteraryLvByExp(currExp + (self._result.readTime * exp))

    -- 等级超过读书识字等级 只能研读到读书识字的等级+1
    if addLv > role:getSkillLv("dushushizi") + 1 then
        addLv = role:getSkillLv("dushushizi") + 1
    end

    local aftAddExp = role:getLiteraryExpByLv(addLv)

    if addLv == currLv then
        aftAddExp = currExp + (self._result.readTime * exp)
    end

    local time = (aftAddExp - currExp) / exp

    local timeStr = self:getTimeStr(time)
    if PRINT_MODE == 1 then
        print("aftAddExp",aftAddExp)
        print("currExp : ",currExp)
        print("exp sec : ",exp)

        print("time : ",time)
    end


    local text,num = "",0

    local firstTitle = ""

    local firstNum = ""

    if self._result.shuTong == 1 then
        firstTitle = "书童："
        firstNum = self._result.shuTongName
    else
        firstTitle = "精力："
        firstNum = tostring(math.floor(role:getAttr("jing"))).."/"..tostring(math.floor(role:getJingMax()))
    end

    local template = {
        title = "研读中",
        list = {
            {
                title = firstTitle,
                num = firstNum
            },
            {title = "研读时长：", num = timeStr},
            {title = "书籍：", num = bookName},
            {title = "等级：", num = currLv .. "→" .. addLv}
        }
    }

    return template
end

function ReadBook:setStartReadCallback( callback )
    self._startCallback = callback
end

function ReadBook:setStopReadCallback( callback )
    self._stopCallback = callback
end


return ReadBook
00000000000