local HuPengYinBanLayer = class("HuPengYinBanLayer", cc.Layer)
local SelectButtonModel = require("app.models.task.teacherGuaJiTask.SelectButtonModel")
local TeacherGuaJiTaskUtil = require("app.models.task.teacherGuaJiTask.TeacherGuaJiTaskUtil")
local HomelandRoleUtil = require("app.models.HomelandModel.HomelandRoleUtil")
local RoleTaskControllor = require("app.views.layer.RoleLayer.RoleTaskControllor")
local FamilyGroup = require("app.models.family.FamilyGroup")
local WaitingLayer = require("app.views.layer.PopLayer.WaitingLayer")

function HuPengYinBanLayer:create()
	local p = HuPengYinBanLayer:new()
	p:init()
	return p
end

function HuPengYinBanLayer:init()
	self._round = require("Layer/TeacherTask/TeacherGuaJiTask/HuPengYinBanUI.lua").create()['root']
	self._round:addTo(self)
	Helper:convertUIByParent(self)

    self.currTitle = 1 

    self.task = nil

	self.tongmenMap = {}  --选择的同门数据map
    self.menkeMap = {}  --选择的门客数据map
end

local titleTable = {
    {name = "同门" ,list = {}},
    {name = "门客" ,list = {}}
}

local ButtonPos = {
    [1] = {
        x = 162,
        y = 221
    },
    [2] = {
        x = 500,
        y = 221
    },
    [3] = {
        x = 838,
        y = 221
    },
    [4] = {
        x = 162,
        y = 91
    },
    [5] = {
        x = 500,
        y = 91
    },
    [6] = {
        x = 838,
        y = 91
    }
}
local waitingLayer

function HuPengYinBanLayer:showLayer(task)
    self.task = task
    self.currList = {} --当前列表人物数据
    self.isSelect = {} --已经选择的同伴
    self.tongmenMap = {}  --选择的同门数据map
    self.menkeMap = {}  --选择的门客数据map
    self.currTitle = 1 --1同门 2 门客
    self.menkeType = self.task.menkeType -- 0没有限制 1 该任务不能组门客 2该任务只能组门客

    
    waitingLayer = WaitingLayer:createInRunningScene()

    self:initTongBanList()
    self:setButtonOk()
    self:setButtonClose()
end

function HuPengYinBanLayer:hideLayer()
    PopupLayerController:hideLayer("HuPengYinBanLayer", function(layer)
        self:hide()
    end)
end

function HuPengYinBanLayer:setButtonClose()
	self.Button_close:releaseFunc(function()
		self:hideLayer()
	end)
end

function HuPengYinBanLayer:setButtonOk()
    --先判断是否正在进行挂机，不能同时进行两个挂机任务

    local func = function()
        self:setMenkeAndTongMenMap()

        --设置task选择的同伴
        TeacherGuaJiTaskUtil:setTaskTeammate(self.task,self.isSelect)

        --计算知识和同伴契合情况
        TeacherGuaJiTaskUtil:calTrendCheck(self.task,self.tongmenMap,self.menkeMap)

        --开始挂机
        TeacherGuaJiTaskUtil:startTask(self.task)

        --刷新任务列表
        local refreshTaskListFunc = TeacherGuaJiTaskUtil:getRefreshTaskListFunc()
        if refreshTaskListFunc then
            refreshTaskListFunc()
        end

        PopupLayerController:hideLayer("GuaJiTaskPrepareLayer", function(layer)
			layer:hide()
		end)

        self:hideLayer()
        
        PopupLayerController:showLayer("GuaJiTaskProgressLayer", function(layer)
            layer:showLayer(self.task)
            PopText("开始进行师门任务！")
        end)
    end

    self.Button_ok:releaseFunc(function()
        if #self.isSelect < 1 then
            PopText("至少选择一名同伴")
            return
        end

        RoleTaskControllor:clickTeacherGuaJiTaskLayer(func)
    end)
end

--设置选择的门客和同门数据
function HuPengYinBanLayer:setMenkeAndTongMenMap()
    if not MapIsEmpty(self.isSelect) then
        for i,v in ipairs(self.isSelect) do
            if v.roleType == "同门" then
                for index,roleData in ipairs(titleTable[1].list) do
                    if roleData.id == v.roleId then
                        table.insert(self.tongmenMap,roleData)
                    end
                end
            elseif v.roleType == "门客" then
                for index,roleData in ipairs(titleTable[2].list) do
                    if roleData.id == v.roleId then
                        local data = table.mergeMap(roleData, HomelandRoleUtil:getMobanRoleAttr(roleData.modal))
                        Npc:initNpc(data)
                        Npc:initItemsAndEquips(data)
                        local role = Helper:tableCover(Role:create(), data)
                        roleData.kongfu = role:getKongfu()
                        print("--门客功夫值：",roleData.name,roleData.kongfu)
                        table.insert(self.menkeMap,roleData)
                    end
                end
            else
                assert(false,"类型出错")
            end
        end
    end
end


function HuPengYinBanLayer:initListItem(roleList)
    if not MapIsEmpty(roleList) then
        self.Text_none:setVisible(false)
        self.currList = roleList
    else
        self.Text_none:setVisible(true)
        self.Text_none:setString("你没有可供选择的"..titleTable[self.currTitle].name)
        self.currList = {}
    end

    self:refreshUpList()
    self:refreshDownList()
end

function HuPengYinBanLayer:createUpPanel(data)
	local panel = self.Panel_item:clone()
    Helper:convertUIByParent(panel)
    panel.Text_stateDsc:enableOutline({r = 0, g = 0, b = 0, a = 255}, 5)
    panel.Panel_ButtonDsc.Text_name:enableOutline({r = 0, g = 0, b = 0, a = 255}, 5)
    panel.Button_1.Text_buttonName:enableOutline({r = 26, g = 26, b = 26, a = 255}, 5)

    local roleId = data.id
    local name = data.name

    local stateDsc = ""
    if data.job == "menke001" then
        stateDsc = HomelandRoleUtil:getGuanJiaFidelity(data.defaultZhongCheng)
        if stateDsc and stateDsc ~= "" then
           stateDsc = string.sub(stateDsc, 13,-4)
        end
        stateDsc = "忠诚度："..stateDsc
    else
        stateDsc = FamilyGroup:getIntimacyDescAndNext(data.intimacy)
        stateDsc = "亲密度："..stateDsc
    end
    panel.Text_stateDsc:setString(stateDsc)
    panel.Panel_ButtonDsc.Text_name:setString(name)

    panel.Panel_ButtonDsc:releaseFunc(function()
        PopupLayerController:showLayer("TeammateInFoLayer", function(layer)
            layer:show(true)
            layer:setRoleInfo(data)
        end)
    end)

    if self:cheakIsSelect(roleId) then
        panel.Button_1:setVisible(false)
        panel.Text_select:setVisible(true)
    else
        panel.Button_1:setVisible(true)
        panel.Text_select:setVisible(false)
    end

	panel.Button_1:releaseFunc(function()
        if self.currTitle == 1 and self.menkeType == 2 then
            PopText("该任务只能组门客")
            return
        elseif self.currTitle == 2 and self.menkeType == 1 then
            PopText("该任务不能组门客")
            return
        end

        if #self.isSelect >= 5 then
            PopText("可选择的同伴已达上限")
            return
        end

        if self.currTitle == 1 then
            table.insert( self.isSelect, {roleId = roleId,name = name,roleType = "同门"} )
        elseif self.currTitle == 2 then
            table.insert( self.isSelect, {roleId = roleId,name = name,roleType = "门客"} )
        else
            assert(false,"HuPengYinBanLayer:createUpPanel(data) 未知情况")
        end

        self:refreshUpList()
        self:refreshDownList()
    end)
	return panel
end

function HuPengYinBanLayer:createDowmButton(data)
    local button = Resource:getUIByName("Button_4")
    Helper:convertUIByParent(button)
    button.Text_buttonName:enableOutline({r = 26, g = 26, b = 26, a = 255}, 5)

    local roleId = data.roleId
    local name = data.name

    button.Text_buttonName:setString(name)
    button:releaseFunc(function()
        if not MapIsEmpty(self.isSelect) then
            for i,v in ipairs(self.isSelect) do
                if v.roleId == roleId then
                    table.remove( self.isSelect, i)
                end
            end
        end
        self:refreshUpList()
        self:refreshDownList()
    end)

    return button
end

--检查是否被选中
function HuPengYinBanLayer:cheakIsSelect(id)
    if not MapIsEmpty(self.isSelect) then
        for i,v in ipairs(self.isSelect) do
            if v.roleId == id then
                return true
            end
        end
        return false
    else
        return false
    end 
end

--刷新上方列表
function HuPengYinBanLayer:refreshUpList()
    self.ListView_TaskList:removeAllItems()
    local list = self.currList
    if MapIsEmpty(list) then
        return
    end
    
    for i,v in ipairs(list) do
        
        local panel = self:createUpPanel(v)
        
        self.ListView_TaskList:pushBackCustomItem(panel)
    end

end

--刷新下方列表
function HuPengYinBanLayer:refreshDownList()
    self.Panel_ButtonList:removeAllChildren()
    local list = self.isSelect
    if MapIsEmpty(list) then
        return
    end
    
    for i, v in ipairs(list) do
        local button = self:createDowmButton(v)
        button:addTo(self.Panel_ButtonList)
        button:setPosition(ButtonPos[i].x,ButtonPos[i].y)
    end
end

function HuPengYinBanLayer:initTabList(titleTable)
    for i,table in ipairs(titleTable) do
        local panel = self["Panel_tongmen"..i]
        Helper:convertUIByParent(panel)
        panel.Text_name:setString(table.name)

        if i == self.currTitle then
            --被选中的table
            panel.Image_1:setVisible(true)
            panel.Text_name:setColor(cc.c3b(233,231,77))

            self:initListItem(table.list)
        else
            panel.Image_1:setVisible(false)
            panel.Text_name:setColor(cc.c3b(255,255,255))
        end
        
        panel:releaseFunc(function()
            self.currTitle = i
            self:initTabList(titleTable)
        end)
    end
end

--初始化同门列表
function HuPengYinBanLayer:initTongBanList()
    FamilyGroup:getGroupMembers(function(data)
        if DEBUG_MODE == 1 then
            print("同门数据")
            Helper:print_lua_table(data)
        end
        
        FamilyGroup:getAllMembersIntimacy(
            function(intimacyList)
                titleTable[1].list = {}
                if DEBUG_MODE == 1 then
                    print("亲密度数据")
                    Helper:print_lua_table(intimacyList)
                end
                if not MapIsEmpty(data) then
                    for i,roleData in ipairs(data) do
                        roleData.id = roleData.userid --同门数据赋值id字段，方便和门客数据一起处理
                        if intimacyList[roleData.userid] ~= nil then
                            roleData.intimacy = intimacyList[roleData.userid] --临时记录一下同门亲密度 字段 intimacy

                            table.insert(titleTable[1].list,roleData)
                        else
                            assert(false,"为什么下发的亲密度列表没有这个同门  同门名字 = "..roleData.name)
                        end
                    end
                end
                local role = User:getRole()
                local mid = role:getHouseId()

                if mid ~= nil then
                    HttpManagerEx:getAllPersons(
                        mid,
                        "menke001",
                        function(status, errcode, errmsg, data)
                            if status == 200 then
                                if errcode == 0 then
                                    titleTable[2].list = {}
                                    if DEBUG_MODE == 1 then
                                        print("门客数据")
                                        Helper:print_lua_table(data)
                                    end
                                    if not MapIsEmpty(data) then
                                        titleTable[2].list = data
                                    end

                                    self:initTabList(titleTable)
                                    if waitingLayer then
                                        waitingLayer:hideAndRemoveSelf() -- 隐藏并且删除自身
                                        waitingLayer = nil
                                    end
                                    self:show()
                                else
                                    print(errcode, errmsg)
                                end
                            else
                                print(status, errcode, errmsg)
                            end
                        end
                    )
                else
                    self:initTabList(titleTable)
                    if waitingLayer then
                        waitingLayer:hideAndRemoveSelf() -- 隐藏并且删除自身
                        waitingLayer = nil
                    end
                    self:show()
                end
            end
        )
    end)
end

Helper:classDefNodeGetInstance(HuPengYinBanLayer)
return HuPengYinBanLayer00000000000000