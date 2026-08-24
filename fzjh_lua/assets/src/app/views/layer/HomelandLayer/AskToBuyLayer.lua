--求购土地界面
local AskToBuyLayer = class("AskToBuyLayer", LayerEx)
function AskToBuyLayer:create()
	local p = AskToBuyLayer:new()
	p:init()
	return p
end

function AskToBuyLayer:init()
	local UI = require("Layer/HomelandUI/AsktobusUI.lua").create()['root']
	UI:addTo(self)
	Helper:convertUI(self)

    self:setBackButton()
	
end

function AskToBuyLayer:showLayer(map)
    if map ~= nil then
        self._map = map
    end
	self:show()
    self:createEditBox()
    self:bid()
end

function AskToBuyLayer:bid()
    local DiQiModel = require("app.models.HomelandModel.DiQiModel")
    local dpInfo = DiQiModel:getDpInfoById(self._map.dpId)
    local startprice = dpInfo.startprice
    local affair_count = Helper:getDef(self._map.affair_count,startprice)
    self.Text_desc3:setString("曾有人出价:"..affair_count.."银票(仅供参考)")
    self.Button_1:releaseFunc(function()
        local num = self:getEditBoxText()
		num = self:checkText(num,true)
		if num == false then
			PopText("含有非法字符")
			return
		end

        if num == "" then
            PopText("你还没有填写求购数额")
            return 
        end

        if tonumber(num) < tonumber(startprice) then
            PopText("出价不能低于地皮初始价"..startprice.."银票")
            return
        end

        self:saveUserInfo(num)
	end)
end

function AskToBuyLayer:checkText(str,isCheckNum)
	--去掉字符串中空格
	local char_tab = string.getChars(str)
	char_tab = self:deleteNilFromTable(char_tab)
	if char_tab == false then
		return false
	end
	if isCheckNum == true or isCheckNum == 1 then
		if self:checkCharIsNumber(string.getBytes(char_tab)) then
			return char_tab
		else
			return false
		end
	else
		return char_tab
	end
end

function AskToBuyLayer:deleteNilFromTable(tab)
	if tab ~= nil and type(tab) == "table" then
		for i = #tab,1,-1 do 
			if tab[i] == " " or string.byte(tab[i]) == 32 then
				table.remove(tab,i)
			end
		end
		if #tab == 0 then
			return ""
		end
		return self:connectCharToString(tab)
	end
end
function AskToBuyLayer:checkCharIsNumber(tab)
	if tab ~= nil and type(tab) == "table" then
		for k ,v in pairs(tab) do 
			if v > 57 or v < 48 then
				return false
			end
		end
		return true
	end	
	return false
end
function AskToBuyLayer:connectCharToString(tab)
	if tab ~= nil and type(tab) == "table" then
		local str = ""
		for k,v in pairs(tab) do 
			str = str .. v
		end
		return str
	end	
end

function AskToBuyLayer:createEditBox()
	local num = ""

	if self.image_kuang == nil then
		self:setEditBox("Image_kuang","image_kuang",num)
	else
		self["image_kuang"]:setText(num)
	end
end

function AskToBuyLayer:setEditBox(node,name,str)
	if self[node] then
		local size = self[node]:getContentSize()
		self[name] = ccui.EditBox:create(size, "请输入")
		self[name]:setInputMode(1)
		self[name]:setInputFlag(3)
		self[name]:setReturnType(1)
		self[name]:setFontSize(54)
		self[name]:setPlaceholderFontSize(54)
		self[name]:setPlaceholderFontName("Font/default.ttf")
		self[node]:getParent():addChild(self[name])
		self[name]:setPosition(self[node]:getPositionX(), self[node]:getPositionY())
		str = Helper:getDef(str,"")
		self[name]:setText(str)
	else
		assert(nil)
	end
end

--设置返回
function AskToBuyLayer:setBackButton()
    self.Button_2:releaseFunc(function()
		self:hide()
	end)
end

function AskToBuyLayer:getEditBoxText()
	local num
	num = self.image_kuang:getText()
	return num
end

function AskToBuyLayer:saveUserInfo(num)
    local pushData = {
        userid = self._map.uid,
        affair_id = 5,
        affair_val = {
            from_name = User:getRole():getAttr("name"),
            currency = "yinpiao",
            number = num,
            dpId = self._map.dpId ,
            location = self._map.location,
        },
		mid = User:getRole():getHouseId(),
        affair_count = num,
        biz_type = 1,
        from_id = User:getRole().userid,
        expired_time = GetTime()+ 24 * 3600*7,
        objId = self._map.dpId
    }
	HttpManagerEx:pushAffair(
			pushData,
			function(status, errcode, errmsg, data)
				if status == 200 then
					if errcode == 0 then
                        self:hide()
						PopText("你已向房主发出求购")
						local text = "RED出价成功！请务必留意后续进展，如果交易达成，请尽快领取地契、并搬入房屋，否则可能会有地财两失之虞！NOR"
						RichPrint("main",text)
					else
						print("errcode : ", errcode)
						PopText(errmsg)
					end
				else
					PopText(errmsg)
				end
			end
    	)
end

Helper:classDefNodeGetInstance(AskToBuyLayer)
return AskToBuyLayer0000000000000