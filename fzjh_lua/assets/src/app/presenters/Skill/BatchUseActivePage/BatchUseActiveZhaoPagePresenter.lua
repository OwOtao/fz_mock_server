local BatchUseActiveZhaoPagePresenter = class("BatchUseActiveZhaoPagePresenter", cc.Layer)

function BatchUseActiveZhaoPagePresenter:create()
    local p = BatchUseActiveZhaoPagePresenter:new()
    p:init()
    return p
end

function BatchUseActiveZhaoPagePresenter:init()
    self.__ui = require("app.views.ui.ActiveZhao.BatchUseActiveZhaoPageUI"):create()

    self.__ui:addTo(self)
end

function BatchUseActiveZhaoPagePresenter:setCallBack(func)
	self.__callback = func
end

function BatchUseActiveZhaoPagePresenter:showLayer(itemAttr,count)
	self.__touchTime = 0

	self.__selectLearnNum = 1

	self.__role = User:getRole()

    local zhaoId = itemAttr.zhaoId

	self.__zhaoExp = Helper:mathFloor(self.__role:getSkillZhaoExp(zhaoId))
	
	self.__zhaoExpLimit = self.__role:getZhaoExpLimit(zhaoId,self.__role:getZhaoLvLimit(zhaoId))

	self:__initLearnMaxNum(count)

	local zhao = Skill:getActiveZhao(zhaoId)


	self.__ui:setTextTitle(itemAttr.name)

	self.__ui:setTextDesc(itemAttr.dsc)

	self.__ui:setTextInfo1("「"..zhao.name.."」的重数为："..self.__role:getSkillZhaoLv(zhaoId).."重")

	self.__ui:setTextInfo2("「"..zhao.name.."」的熟练度为："..self.__zhaoExp)
	
	self.__ui:setTextInfo3("「"..zhao.name.."」当前熟练度上限为："..self.__zhaoExpLimit)

	self.__ui:setTextTip("残页最大可使用数量：\n以使用最多数量的残页，获得的最大熟练度，不会超过当前技能重数熟练度上限为准。与当前背包拥有的对应技能残页数不同。")

	self.__ui:setButtonCancel(function()
		self:hideLayer()
	end)

	self.__ui:setButtonConfirm(function()
		self:hideLayer()

		if self.__callback then
			self.__callback(self.__selectLearnNum)
		end
	end)

	self:__setTextSelectNum()
				
	self:__setButtons()
	
	self.__ui:showUI()
end

function BatchUseActiveZhaoPagePresenter:hideLayer()
    PopupLayerController:hideLayer(
        "BatchUseActiveZhaoPagePresenter",
        function(layer)
            self.__ui:hideUI()
        end
    )
end

function BatchUseActiveZhaoPagePresenter:__initLearnMaxNum(count)
	local currInt = self.__role:getFinalAttr("currInt")

	local deficitExp = self.__zhaoExpLimit - self.__zhaoExp

	local extraMaxExp = currInt / 5 + 0.5 * (currInt/2)

	local deficitCount = math.floor(deficitExp / (500 + extraMaxExp))

	self.__learnMaxNum = Helper:getRange(deficitCount,1,count)
end

function BatchUseActiveZhaoPagePresenter:__createBeganFunc(callback)
    local function retFunc()
        local currTime = GetTime()

        if currTime - self.__touchTime < 0.3 then
            return
        end

        self.__touchTime = currTime

        self:__clearHandle()

        local total_time = 0

        self.__handle =
            self:schedule(
            function(ft)
                total_time = total_time + ft
                if total_time > 1.25 then
                    callback()
                end
            end
        )
    end
    return retFunc
end

function BatchUseActiveZhaoPagePresenter:__clearHandle()
    if self.__handle ~= nil then
        self:unschedule(self.__handle)
        self.__handle = nil
    end
end

function BatchUseActiveZhaoPagePresenter:__setButtons()
	local buttonList = {
		{
			num = -10,
			image1 = "Image/UI/AttrUI/leftgrey.png",
			image2 = "Image/UI/AttrUI/leftbright.png",
			compare = function()
				return self.__selectLearnNum - 10 >= 1
			end
		},
		{
			num = -1,
			image1 = "Image/UI/AttrUI/leftgrey.png",
			image2 = "Image/UI/AttrUI/leftbright.png",
			compare = function()
				return self.__selectLearnNum - 1 >= 1
			end
		},
		{
			num = 1,
			image1 = "Image/UI/AttrUI/jiali02b.png",
			image2 = "Image/UI/AttrUI/jiali02.png",
			compare = function()
				return self.__selectLearnNum + 1 <= self.__learnMaxNum
			end
		},
		{
			num = 10,
			image1 = "Image/UI/AttrUI/jiali02b.png",
			image2 = "Image/UI/AttrUI/jiali02.png",
			compare = function()
				return self.__selectLearnNum + 10 <= self.__learnMaxNum
			end
		},
	}

	for i,buttonData in ipairs(buttonList) do
		local retData = {
			image = buttonData.image1,
			title = Helper:numberToStringWithPlus(buttonData.num),
			titleColor = {r = 255, g = 255, b = 255},
			beganFunc = EMPTY_FUNC,
			endedFunc = EMPTY_FUNC,
			canceledFunc = EMPTY_FUNC
		}
		if buttonData.compare() then
			retData.image = buttonData.image2
			retData.titleColor = {r = 19, g = 227, b = 30}
			retData.beganFunc =
				self:__createBeganFunc(
				function()
					if not buttonData.compare() then
						self:__clearHandle()
						return
					end
	
					self.__selectLearnNum = self.__selectLearnNum + buttonData.num
	
					self:__setTextSelectNum()

					self:__setButtons()
				end
			)
	
			retData.endedFunc = function()
				self.__selectLearnNum = self.__selectLearnNum + buttonData.num
	
				self:__setTextSelectNum()

				self:__setButtons()
	
				self:__clearHandle()
			end
			retData.canceledFunc = function()
				self:__clearHandle()
			end
		end

		self.__ui:setButton(i,retData)
	end
end

function BatchUseActiveZhaoPagePresenter:__setTextSelectNum()
	self.__ui:setTextSelectNum(self.__selectLearnNum.."/"..self.__learnMaxNum)
end

Helper:classDefNodeGetInstance(BatchUseActiveZhaoPagePresenter)

return BatchUseActiveZhaoPagePresenter
000