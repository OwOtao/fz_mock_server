--房屋改造界面
local RoomRenovationLayer = class("RoomRenovationLayer", LayerEx)
local HomelandRoleUtil = require("app.models.HomelandModel.HomelandRoleUtil")
local HomelandRoomUtil = require("app.models.HomelandModel.HomelandRoomUtil")

local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")

local familylist = requireWithEncrypt("script.others.familylist")

local normalList = familylist["普通房间"]
local specialList = familylist["特殊房屋"]
local roomTypeMap = familylist["特殊房间类型"] 

function RoomRenovationLayer:create()
	local p = RoomRenovationLayer:new()
	p:init()
	return p
end

function RoomRenovationLayer:init()
	local UI = require("Layer/HomelandUI/RoomRenovationUI.lua").create()['root']
	UI:addTo(self)
	Helper:convertUIByParent(self)

    self:setBackButton()
    self.maplayer = MainControllLayer:getLayer("MapLayer")
end

function RoomRenovationLayer:showLayer(map,environment)
	self:show()
    if map then
        self._map = map
    end
    if environment then
        self._environment = environment
    end

    self.pageNum = 1
    self._normalCanExtendCount = nil
    self._specailCanExtendCount = nil
    
    self:setButtonExchange()
    self:setExtendButton()
    self:setDismantleButton()
    self:setRestoreButton()
    self:setCurrCanRenovationRoomNum()

    self:initRoomList(self:getCurrData(self.pageNum))
    
end

--初始化房屋列表
function RoomRenovationLayer:initRoomList(currData)

    local lastRoomAttr = self:getCurrRoomAttr()
    local roomType = lastRoomAttr.roomType

    local lastData = {}
    if roomType == nil then
        print("roomType 为空")
        return 
    end
    if HomelandRoomUtil:roomIsSpecial(roomType) then
        lastData = HomelandRoomUtil:getSpeciaRoomAttr(roomType)
    else
        lastData = HomelandRoomUtil:getNormalRoomAttr(roomType)
    end

    

    for i = 1,#currData do
        self["Button_select"..i]:setVisible(true)
        self["Button_select"..i].Text_button_text:setString(currData[i].name)
        self["Button_select"..i]:releaseFunc(function ()
            if lastData.furniturelimit > currData[i].furniturelimit then
                PopText("当前房间放置家具上限大于改造房间家具上限")
                return
            end
            
            if lastData.roomid == currData[i].roomid then
                PopText("不能改造成同类型房间")
                return
            end

            if HomelandRoomUtil:roomIsSpecial(roomType) and HomelandRoomUtil:roomIsLimit(self._map,currData[i].roomtype) then
                PopText("该类型房间已达到建造上限")
                return
            end

            if not HomelandRoomUtil:checkRoomCanDismantleByFurnitureType(self._map) then
                PopText("房间内有可收起的家具不可被改造")
                return
            end

            local currRoomId = self._map:getCurrRoomId()
            local ret,msg = HomelandRoomUtil:checkRoomCanChangeBySpecialSituation(self._map,currRoomId,"改造")
            if ret == false then
                PopText(msg)
                return
            end

            PopupLayerController:showLayer("RoomUpgradeLayer", function(layer)
		    layer:showLayer(lastData,currData[i],self)
            end)
        end)
    end
    if #currData < 8 then
        for i = #currData + 1,8 do
            self["Button_select"..i]:setVisible(false)
        end
    end
end

--改造时隐藏的特殊房间列表
local roomHideList = {
    tsfangjian005 = true,  --仓库
    tsfangjian011 = true  --卧室
}

--设置当前显示的数据
function RoomRenovationLayer:getCurrData(num)
    if num == nil then
        num = 0 
    end
    
    --判断房间是普通房间还是特殊房间
    local currRoomAttr = self:getCurrRoomAttr()
    local currRoomType = currRoomAttr.roomType
    
    local currList = {}
    local tab = {}
    local startNum = (num-1) * 8 + 1
    local endNum = num * 8

    if HomelandRoomUtil:roomIsSpecial(currRoomType)  then
        local index = 1
        for k,v in pairs(specialList) do
            if v.upgrade2 == 1 and roomHideList[v.roomid] ~= true then
                currList[tostring(index)] = v
                index = index + 1
            end
        end
    else
        currList = normalList
    end

    local maxNum = 0
    for k, v in pairs(currList) do
        maxNum = maxNum + 1
    end

    if startNum >= maxNum then
        startNum = 1
        endNum = 8
    end

    if endNum > maxNum then
        endNum = maxNum
    end

    for i = startNum, endNum do
        table.insert(tab,#tab+1,currList[tostring(i)])
    end

    return tab
end

--设置当前能扩建的房间数量
function RoomRenovationLayer:setCurrCanRenovationRoomNum()
    local currRole = self._environment.currRole
    local fidelity = Helper:getDef(currRole.defaultZhongCheng,0)


    local normalRoomLimit,specialRoomLimit = HomelandRoomUtil:getCommonAndSpecialroomLimit(fidelity)

    local normalCount,specialCount = 0,0
    normalCount,specialCount = HomelandRoomUtil:getCurrMapCommonAndSpecialroomCount()

    self._normalCanExtendCount = Helper:getDef(math.max(normalRoomLimit-normalCount,0),0)
    self._specailCanExtendCount = Helper:getDef(math.max(specialRoomLimit-specialCount,0),0)

    self.Text_ptnum:setString("可扩建普通房间："..self._normalCanExtendCount)
    self.Text_gnnum:setString("可扩建功能房间："..self._specailCanExtendCount)

    
    local currRoomAttr = self:getCurrRoomAttr()
   
    Helper:print_lua_table(currRoomAttr)
    self.Text_curr:setString("当前房间："..currRoomAttr.name)
end

--获取当前房间属性
function RoomRenovationLayer:getCurrRoomAttr()
    local currRoomAttr = {}

    local currRoomId = self._map:getCurrRoomId()
    if currRoomId then 
        currRoomAttr = self._map.room[currRoomId]
    end
    return currRoomAttr
end 
--设置换一批按钮
function RoomRenovationLayer:setButtonExchange()
    self.Button_exchange:releaseFunc(function ()
        if not self.pageNum then
			self.pageNum = 1
		end
        self.pageNum = self.pageNum+1
        
        self:initRoomList(self:getCurrData(self.pageNum))

        if #self:getCurrData(self.pageNum) < 8 or #normalList == self.pageNum*8 then
            self.pageNum = 0
        end

    end)

end

--设置返回按钮
function RoomRenovationLayer:setBackButton()
    -- self.Button_NO.Text_buttonName:setString("返回")
    self.Button_back:releaseFunc(function()
		self:hide()
	end)
end

--设置扩建按钮
function RoomRenovationLayer:setExtendButton()
    local currRole = self._environment.currRole
    local fidelity = Helper:getDef(currRole.defaultZhongCheng,0)

    self.Button_extend:releaseFunc(function()
        local currRoomAttr = self:getCurrRoomAttr()
        local roomType = currRoomAttr.roomType
        if HomelandRoomUtil:roomIsSpecial(roomType) then
            PopText("该房间周围无法扩建")
            return
        end
        local lv = Helper:getDef(HomelandRoleUtil:getFidelityLv(fidelity),0)
        if lv < 4 then
            PopText("管家忠诚度等级不够，无法进行房屋扩建")
        else
            self:hide()
            local UserMap = require("app.models.map.UserMap")
			UserMap:setEnlargeState(true,self._specailCanExtendCount,self._normalCanExtendCount)
            self._map.__MapLayer:refreshRoom()
        end
       
	end)
end

--设置拆除按钮
function RoomRenovationLayer:setDismantleButton()
    local currRole = self._environment.currRole
    local fidelity = Helper:getDef(currRole.defaultZhongCheng,0)
    
    self.Button_dismantle:releaseFunc(function()
        local currRoomAttr = self:getCurrRoomAttr()
        local roomType = currRoomAttr.roomType
        local lv = Helper:getDef(HomelandRoleUtil:getFidelityLv(fidelity),0)
        
        if lv < 5 then
            PopText("管家忠诚度等级不够，无法进行房屋拆除")
            return
        end

        if HomelandRoomUtil:roomIsDismantle(roomType) == false then
            PopText("该房间无法被拆除")
            return
        end
		
        local currRoomId = self._map:getCurrRoomId()
        local roomList = self._map:getNearRoomsExceptSelf(currRoomId,1)
            
        if #roomList ~= 1 then
            PopText("相邻房间数量不为1，不可拆除")
            return
        end

        if not HomelandRoomUtil:checkRoomCanDismantleByFurnitureType(self._map) then
            PopText("房间内有可收起的家具不可被拆除")
            return
        end

        local ret,msg = HomelandRoomUtil:checkRoomCanChangeBySpecialSituation(self._map,currRoomId,"拆除")
        if ret == false then
            PopText(msg)
            return
        end
        
            
        local dialog = DialogALayer:getInstance()
        dialog:show("你确定要拆除吗？")
        dialog:setButton1("确定", function()
            --@RefType [app.models.HomelandModel.RoomModel.RoomRemoveModel#RoomRemoveModel]
            local RoomRemoveModel = require("app.models.HomelandModel.RoomModel.RoomRemoveModel")

            RoomRemoveModel:removeRoom(self._map,currRoomId,function ()
                local currRoom = self._map:getRoomById(currRoomId)
                local currRoomType = currRoom.roomType
                if HomelandRoomUtil:roomIsSpecial(currRoomType) then
                    self._specailCanExtendCount = self._specailCanExtendCount + 1
                else
                    self._normalCanExtendCount = self._normalCanExtendCount + 1
                end

                self:hide()
            end)
            
        end)
        dialog:setButton2("取消", function()
            dialog:hide()
        end)

       
	end)
end

--设置房屋还原按钮
function RoomRenovationLayer:setRestoreButton()
    local currRole = self._environment.currRole
    local fidelity = Helper:getDef(currRole.defaultZhongCheng,0)

    self.Button_restore:releaseFunc(function()
        local lv = Helper:getDef(HomelandRoleUtil:getFidelityLv(fidelity),0)
        if lv <= 6 then
            PopText("管家忠诚度等级不够，无法进行房屋还原")
            return
        end
        
        local role = User:getRole()
        local map = role:getCurrMap()
        local ret ,msg =  map:cheakUserMapIsRebuild()
        if ret == false then
            PopText(msg.."房屋还原")
            return
        end

        local dialog = DialogALayer:getInstance()
        dialog:show("你确定要花费10000银票进行还原吗？")
        dialog:setButton1("确定", function()        
            HttpManagerEx:restoreUserMap(self._map.mid,function(status, errcode, errmsg, data)
                if 200 == status then
                    if 0 == errcode then
                        self:hide()
                        MainControllLayer:getLayer("MapLayer"):userQuit()
                        User:getRole():setMapWithId(self._map.id, nil)
                        PopText("房屋已还原，请重新进入副本")
                    else
                        PopText(tostring(errmsg))
                    end
                else
                    PopText("网络请求出错,请换个网络环境再试!")
                end
            end, IS_SHOW_WAITING)
        end)
        dialog:setButton2("取消", function()
            dialog:hide()
        end)
	end)
end

    
Helper:classDefNodeGetInstance(RoomRenovationLayer)
return RoomRenovationLayer000000