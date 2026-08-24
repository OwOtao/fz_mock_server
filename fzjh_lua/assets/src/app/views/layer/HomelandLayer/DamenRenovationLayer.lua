--大门改造界面
local DamenRenovationLayer = class("DamenRenovationLayer", LayerEx)
local HomelandRoomUtil = require("app.models.HomelandModel.HomelandRoomUtil")

local familylist = requireWithEncrypt("script.others.familylist")
local doorListMap = familylist["大门信息"]

local function sortDoorMap( )
    local temp = {}
    for k,v in pairs(doorListMap) do
        table.insert( temp,v )
    end

    table.sort( temp,function ( a,b )
        return tonumber(a.doorcost) < tonumber(b.doorcost)
    end )

    doorListMap = temp
end

sortDoorMap()


local currDamenInfo = {}
function DamenRenovationLayer:create()
	local p = DamenRenovationLayer:new()
	p:init()
	return p
end

function DamenRenovationLayer:init()
    local UI = require("Layer/HomelandUI/DaMenRemouldUI.lua").create()['root']
	UI:addTo(self)
	Helper:convertUIByParent(self)

    self:setChangeButton()
    self:setBackButton()
end

function DamenRenovationLayer:hideLayer()
    PopupLayerController:hideLayer("DamenRenovationLayer",function (layer)
        layer:hide()
    end)
end

function DamenRenovationLayer:showLayer(map,item)
    self:show()
    if map then
        self._map = map
        self.item = item
        local currRoomId = self._map:getCurrRoomId()
        self._currRoomAttr = self._map:getRoomById(currRoomId)
        self._currDaMenId = self._map.extra.doorId
    end
    self:getYinPiao()
    self:initDamenList()
    self.changeData = {}
end

--初始化大门列表
function DamenRenovationLayer:initDamenList()
    self.ListView_1:removeAllItems()
    self.Text_money:setVisible(false)
    for key,value in ipairs(doorListMap) do
        local row = self:createPanel(value)
        
        row:releaseFunc(function()
            if value.doorid == self._currDaMenId then
                PopText("当前大门已经是这种大门了！")
                return
            end
            if self.preClick then
                local data = doorListMap[self.preClick.index]
                local preRow = self.ListView_1:getItem(self.preClick.listIndex)
                preRow.Text_name:setColor(cc.c3b(255, 255, 255))
                preRow.Text_cost:setColor(cc.c3b(255, 255, 255))
                preRow.Text_name:setString(Helper:getDef(data.colordoor,"WHT")..data.doorname)
                preRow.Text_kuang:setVisible(false)
            end

            self.preClick = {
                index = key,
                listIndex = self.ListView_1:getIndex(row)
            }

            row.Text_name:setColor(cc.c3b(80, 246, 244))
            row.Text_cost:setColor(cc.c3b(80, 246, 244))
            --变色
            row.Text_kuang:setVisible(true)

            self.Text_money:setVisible(true)
            self.Text_money:setString("花费"..value.doorcost.."银票")
            self.changeData = value
            -- self:setCurrDamenInfo(value)
            self:setClick(self.changeData)

        end)
        self.ListView_1:pushBackCustomItem(row)
    end

    local currdoorData = self:getCurrDamenInfo()
    local caozuotiaojianText = "闯门条件:"
    if MapIsEmpty(currdoorData) == false then
        local caozuotiaojian = currdoorData.caozuotiaojian
        local caozuotiaojian1 = currdoorData.caozuotiaojian1
        if caozuotiaojian then
            local caozuotiaojianAttr = string.split(caozuotiaojian,";")
            
            local attr = caozuotiaojianAttr[1]
            local logic = caozuotiaojianAttr[2]
            local value = caozuotiaojianAttr[3]
            
            local role = User:getRole()
            attr = role:getCHAttrName(attr)
            caozuotiaojianText = caozuotiaojianText.."\n"..attr..logic..value
        end

        if caozuotiaojian1 then
            local caozuotiaojian1Attr = string.split(caozuotiaojian1,";")
            
            local skillid = caozuotiaojian1Attr[1]
            local skill = Skill:getSkill(skillid)

            local skillName = skill.name
            local logic = caozuotiaojian1Attr[2]
            local value = caozuotiaojian1Attr[3]
            
            caozuotiaojianText = caozuotiaojianText.."\n"..skillName..logic..value.."级"
        end
        self.Panel_2.Text_condition:setString(caozuotiaojianText)
        self.Panel_2.Text_name:setString(currdoorData.doorname)
        self.Panel_2.Text_dsc:setString(currdoorData.doordsc)
    else
        self.Panel_2.Text_condition:setString(caozuotiaojianText)
        self.Panel_2.Text_name:setString("")
        self.Panel_2.Text_dsc:setString("")
    end
end

function DamenRenovationLayer:setClick(data)
    local caozuotiaojianText = "闯门条件:"
    if MapIsEmpty(data) == false then
        local caozuotiaojian = data.caozuotiaojian
        local caozuotiaojian1 = data.caozuotiaojian1
        if caozuotiaojian then
            local caozuotiaojianAttr = string.split(caozuotiaojian,";")
            
            local attr = caozuotiaojianAttr[1]
            local logic = caozuotiaojianAttr[2]
            local value = caozuotiaojianAttr[3]
            
            local role = User:getRole()
            attr = role:getCHAttrName(attr)
            caozuotiaojianText = caozuotiaojianText.."\n"..attr..logic..value
        end
        
        if caozuotiaojian1 then
            local caozuotiaojian1Attr = string.split(caozuotiaojian1,";")
            
            local skillid = caozuotiaojian1Attr[1]
            local skill = Skill:getSkill(skillid)

            local skillName = skill.name
            local logic = caozuotiaojian1Attr[2]
            local value = caozuotiaojian1Attr[3]
            
            caozuotiaojianText = caozuotiaojianText.."\n"..skillName..logic..value.."级"
        end
        self.Panel_3.Text_condition:setString(caozuotiaojianText)
        self.Panel_3.Text_name:setString(data.doorname)
        self.Panel_3.Text_dsc:setString(data.doordsc)
    else
        self.Panel_3.Text_condition:setString(caozuotiaojianText)
        self.Panel_3.Text_name:setString("")
        self.Panel_3.Text_dsc:setString("")
    end
end
function DamenRenovationLayer:createPanel(list)
    list = Helper:getDef(list,{})
	local panel = self:clonePanel()
	self:setPanel(panel,list)
	return panel
end

function DamenRenovationLayer:clonePanel()
	local panel = self.Panel_1:clone()
	Helper:convertUIByParent(panel)
	return panel
end

function DamenRenovationLayer:setPanel(panel,list)
	if not panel then
		return
	end
	list = Helper:getDef(list,{})
	panel.Text_name:setString(Helper:getDef(list.colordoor,"WHT")..list.doorname)
    panel.Text_cost:setString(list.doorcost.."银票")
    
end

--获取当前银票数量
function DamenRenovationLayer:getYinPiao()
	HttpManagerEx:viewCurrencyByType("yinpiao", User:getRole():getCurrencyVersion(), function(status, errcode, errmsg, data)
        if status == 200 then
            if errcode == 0 then
                self._currYinPiao = data.number
                self.Text_yinpiao:setString("『银票』"..self._currYinPiao)
            else
               PopText(errmsg)
               self:hideLayer()
            end
        else
            PopText(errmsg)
            self:hideLayer()
        end
    end, IS_SHOW_WAITING)
end

--设置银票显示数值
function DamenRenovationLayer:setYinPiao()
    print("self._currYinPiao = ",self._currYinPiao)
    self.Text_yinpiao:setString("『银票』"..self._currYinPiao)
end

--获取当前大门信息
function DamenRenovationLayer:getCurrDamenInfo()
    local currDoorId  = self._currDaMenId

    if currDoorId == nil then
        return
    end
    for k,v in pairs(doorListMap) do
        if v.doorid == currDoorId then
            return v
        end
    end
end

--设置离开按钮
function DamenRenovationLayer:setBackButton()
    self.Button_NO.Text_buttonNoName:setString("离开")
    self.Button_NO:releaseFunc(function()
		self:hideLayer()
	end)
end

--设置更换按钮
function DamenRenovationLayer:setChangeButton()
    self.Button_Yes.Text_buttonYesName:setString("更换")
    self.Button_Yes:releaseFunc(function()
        local changeData = self.changeData
        if MapIsEmpty(changeData) then
            PopText("你未选中大门")
            return
        end
        
        local needyinpiao = changeData.cost

        local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")
        local dialog = DialogALayer:getInstance()
        local currDamenInfo = self:getCurrDamenInfo()
        dialog:show(" 此改造方案将把目前的"..currDamenInfo.doorname.."改造为"..changeData.doorname.."，预计花费"..changeData.doorcost.."银票，你确定改造吗？")
        dialog:setWeChatVisible(false)
        dialog:setButton1("确定", function()
            local fjId = self._map:getCurrRoomId()
            local mid = self._map.mid
            local attr = {}
            attr.doorId = changeData.doorid
            local point = changeData.doorcost

            HttpManagerEx:uploadMapExtra(mid,attr,point,function(status, errcode, errmsg, data)
                if status == 200 and errcode == 0 then
                    Helper:print_lua_table(self._currRoomAttr)
                    self._currDaMenId = attr.doorId
                    self._map.extra.doorId = attr.doorId
                    self._currYinPiao = self._currYinPiao - data.remove_point
                    self:setYinPiao()
                    self:initDamenList()
                    
                    self:setClick()

                    HomelandRoomUtil:updateDoorRoomAndDoorItemDsc(self.item,self._currRoomAttr,self._map)
                    
                    self._map.__MapLayer:refreshMap()
                    self.changeData = nil
                    
                else
                    PopText(errmsg)
                end
            end, IS_SHOW_WAITING)
        end)

        dialog:setButton2("取消", function()
            dialog:hide()
        end)
        -- end

	end)
end

function DamenRenovationLayer:setButton()

    self.Button_Yes.Text_buttonYesName:setString("换一批")
    self.Button_Yes:releaseFunc(function ()
    
    
    end)
end
--确认改造
function DamenRenovationLayer:remouldConfirm(data)
    --[[当前大门信息保存,消耗银票,
    大门信息保存待确定,银票属性名待确定]]

    --@desc 保存大门信息 更新银票属性

    local role = User:getRole()
    role:setAttr("damenData",data)
end

Helper:classDefNodeGetInstance(DamenRenovationLayer)
return DamenRenovationLayer0000000000