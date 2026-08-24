local User = require("app.models.user.User")
local Item = require("app.models.item.Item")
local Role = require("app.models.role.Role")

local Meridian = require("app.models.Meridian.Meridian")

-- 左右互搏小游戏界面 LeftRightFightGameLayer
local LeftRightFightGameLayer = class("LeftRightFightGameLayer", LayerEx)

function LeftRightFightGameLayer:create()
	local p = LeftRightFightGameLayer:new()
	p:init()
	return p
end

local dir =
{
	[1] = {0, 22.5},
	[2] = {22.5, 45},
	[3] = {45, 67.5},
	[4] = {67.5, 90},
	[5] = {90, 112.5},
	[6] = {112.5, 135},
	[7] = {135, 157.5},
	[8] = {157.5, 180},
	[9] = {180, 202.5},
	[10] = {202.5, 225},
	[11] = {225, 247.5},
	[12] = {247.5, 270},
	[13] = {270, 292.5},
	[14] = {292.5, 315},
	[15] = {315, 337.5},
	[16] = {337.5, 360},
}

local square1 =
{
	-- [1] = {11,12,13,14},
	-- [2] = {1,2,15,16},
	-- [3] = {3,4,5,6},
	-- [4] = {7,8,9,10},

	[1] = {12,13},
	[2] = {1,16},
	[3] = {4,5},
	[4] = {8,9},
}

local square2 =
{
	-- [1] = {7,8,9,10},
	-- [2] = {3,4,5,6},
	-- [3] = {1,2,15,16},
	-- [4] = {11,12,13,14},

	[1] = {1,16},
	[2] = {12,13},
	[3] = {8,9},
	[4] = {4,5},
}

local triangle1 =
{
	[1] = {9,10,11,12},
	[2] = {1,16},
	[3] = {5,6,7,8},
}

local triangle2 =
{
	[1] = {13,14,15,16},
	[2] = {8,9},
	[3] = {1,2,3,4},
}

local circular1 =
{
	[1] = {9,10,11,12},
	[2] = {12,13,14},
	[3] = {13,14,15,16},
	[4] = {1,16,2},
	[5] = {1,2,3,4},
	[6] = {4,5,6},
	[7] = {5,6,7,8,9},
}

local circular2 =
{
	[1] = {16,14,15,16},
	[2] = {11,12,13},
	[3] = {9,10,11,12},
	[4] = {7,8,9},
	[5] = {5,6,7,8},
	[6] = {3,4,5},
	[7] = {1,2,3,4,16},
}

local squareProportion = {0.25, 0.25, 0.25, 0.25}
local triangleProportion = {0.30, 0.40, 0.30}
local circularProportion = {0.2, 0.1, 0.2, 0.1, 0.2, 0.1, 0.2}

function LeftRightFightGameLayer:init()
	self._UI = require("Layer/MeridianUI/LeftRightFightGameUI.lua").create()['root']
	self._UI:addTo(self)

	Helper:convertUIByParent(self)

	self.Panel_category.Text_Title:setString("互搏神通")

	self:setBack()

	self._drawNode = nil
end

-- 测试绘制
function LeftRightFightGameLayer:testDraw()
	self:show()
	self:createDrawNode()
	self:initDrawData()
	self:test()
end

-- 显示界面
function LeftRightFightGameLayer:showLayer(gameType)
	-- open 开启左右互搏 promote 提升左右互搏熟练度
	if gameType == nil then
		gameType = "open"
	end

	local role = User:getRole()
	if gameType == "Practice" then
	elseif role:isHaveImprintingId("zuoyouhuboyin") then
		gameType = "promote"
	else
		gameType = "open"
	end

	self.gameType = gameType

	self:initData()

	
	-- 更新剩余时间
	if self._handle ~= nil then
		self:unschedule(self._handle)
		self._handle = nil
	end
	
	self:show()
	self:refreshUI()
	
	self:delayFunc(1, function()
		self:setTouchHandler()
		self:createDrawNode()
		self:startGame()
	end)
end

--
function LeftRightFightGameLayer:startGame()
	-- self.canDraw = true
	local graphical1, graphical2 = self:randomGraphical()
	local jindu = self:getData(1)
	local faild = self:getData(2)

	local Image =
	{
		[1] = "Image/UI/MeridianUI/yuan.png",
		[2] = "Image/UI/MeridianUI/sanjiao.png",
		[3] = "Image/UI/MeridianUI/juxing.png",
	}

	self.Image_right.Image_graphical:loadTexture(Image[graphical1])
	self.Image_left.Image_graphical:loadTexture(Image[graphical2])

	self.Image_right.Image_graphical:setVisible(true)
	self.Image_left.Image_graphical:setVisible(true)

	self:setData(jindu, faild, graphical1, graphical2)

	self.startTime = GetTime()

	if self._handle ~= nil then
		self:unschedule(self._handle)
		self._handle = nil
	end

	self._handle = self:schedule(function (ft)
		self:update(ft)
	end,1/30)
end

function LeftRightFightGameLayer:initData()
	self:initDrawData()

	-- 1 圆形 2 三角形 3 正方形
	-- 游戏保存的数据 游戏进度 失败次数 左边需要画的图形 右边需要画的图形
	self.data = "0;0;1;1"

	-- 开始时间
	self.startTime = nil

	-- 是否可以绘制
	self.canDraw = false
end

--
function LeftRightFightGameLayer:getData(index)
	return tonumber(string.split(self.data,";")[index])
end

function LeftRightFightGameLayer:setData(jindu, faild, graphical1, graphical2)
	jindu = Helper:getDef(jindu, self:getData(1))
	faild = Helper:getDef(faild, self:getData(2))
	graphical1 = Helper:getDef(graphical1, self:getData(3))
	graphical2 = Helper:getDef(graphical2, self:getData(4))

	self.data = jindu .. ";" .. faild .. ";" .. graphical1 .. ";" .. graphical2
end

function LeftRightFightGameLayer:initDrawData()
	self.left =
	{
		lastX = 0,
		lastY = 0,
		isDraw = false,		-- 是否正在绘画中
		dirList = {},		-- 笔画方向列表
		lengthList = {},	-- 笔画长度列表
		totalLength = {},	-- 总长度
		state = 0,			-- 状态 0 还没画 1 画对 2 画错
	}

	self.right =
	{
		lastX = 0,
		lastY = 0,
		isDraw = false,		-- 是否正在绘画中
		dirList = {},		-- 笔画方向列表
		lengthList = {},	-- 笔画长度列表
		totalLength = {},	-- 总长度
		state = 0,			-- 状态 0 还没画 1 画对 2 画错
	}
end

function LeftRightFightGameLayer:createDrawNode()
	if self._drawNode ~= nil then
		self._drawNode:removeFromParent()
		self._drawNode = nil
	end

	self._drawNode = cc.DrawNode:create()
	self:addChild(self._drawNode)
end

-- 随机出现图形 不重复
function LeftRightFightGameLayer:randomGraphical()
	local Graphical = { 1,2,3 }
	local graphical1, graphical2

	local randNum = math.random(1,#Graphical)

	graphical1 = Graphical[randNum]
	table.remove(Graphical, randNum)

	randNum = math.random(1,#Graphical)
	graphical2 = Graphical[randNum]

	return graphical1, graphical2
end

function LeftRightFightGameLayer:update()
	local currTime = GetTime()
	if self.startTime ~= nil then
		local time = 9 - (currTime - self.startTime)
		if time < 0 then
			time = 0

			-- 时间到
			if self._handle ~= nil then
				self:unschedule(self._handle)
				self._handle = nil
			end

			--@desc 时间到了之后
			if self.canDraw == false then
				self.canDraw = true
			end

			self:faild()
		end
		self.LoadingBar:setPercent((time / 9) * 100)
	end

	self:refreshUI()
end

function LeftRightFightGameLayer:refreshUI()
	local role = User:getRole()

	local leftRightFightExp = role:getAttr("leftRightFightExp")

	--@desc 等级
	local leftRightFightLv = math.ceil(leftRightFightExp / 100)

	--@desc 熟练度
	local leftRightFightDegree = leftRightFightExp % 100

	if leftRightFightExp > 99 and leftRightFightDegree == 0 then
		leftRightFightLv = leftRightFightLv + 1
	end

	if leftRightFightLv > 10 then
		leftRightFightLv = 10
	end

	local jindu = self:getData(1)

	self.Text_exp:setString("『熟练度』" .. leftRightFightDegree .. "/100")
	self.Text_jindu:setString("『进度』" .. jindu .. "/3")
	self.Text_level:setString("『等级』" .. leftRightFightLv)
end

function LeftRightFightGameLayer:setBack()
	self.Panel_category.Button_return:releaseFunc(function()
		if self._drawNode ~= nil then
			self._drawNode:removeFromParent()
			self._drawNode = nil
		end

		PopupLayerController:hideLayer("LeftRightFightGameLayer", function(layer)
			User:getRole():setFlag("PVP活动状态", "空闲中")
			self:hide()
		end, 0)
	end)
end

-- 匹配图形
function LeftRightFightGameLayer:matchingGraph(dir, graphical)
	local graphical1 = self:getData(3)
	local graphical2 = self:getData(4)

	if dir == "left" then
		if graphical1 == graphical then
			self.left.state = 1

			if self.right.state == 1 then
				self:successful()
			end
		else
			self.left.state = 2
			if self.right.state ~= 2 then
				self:faild()
			end
		end
	elseif dir == "right" then
		if graphical2 == graphical then
			self.right.state = 1
			if self.left.state == 1 then
				self:successful()
			end
		else
			self.right.state = 2
			if self.left.state ~= 2 then
				self:faild()
			end
		end
	end
end

-- 成功
function LeftRightFightGameLayer:successful()
	self.canDraw = false
	PopText("正确")

	local jindu = self:getData(1)

	jindu = jindu + 1
	self:setData(jindu, nil, nil, nil)

	if self._handle ~= nil then
		self:unschedule(self._handle)
		self._handle = nil
	end

	if jindu >= 3 then
		PopText("挑战成功")
		self:delayFunc(1, function()
			self:gameOver(true)
		end)
		return
	end

	self:delayFunc(1, function()
		self:initDrawData()
		self:createDrawNode()
		self:startGame()
	end)
end

-- 失败
function LeftRightFightGameLayer:faild()
	if self.canDraw == false then
		return
	end

	PopText("失败")
	self.canDraw = false

	local faild = self:getData(2)

	faild = faild + 1
	self:setData(nil, faild, nil, nil)

	if self._handle ~= nil then
		self:unschedule(self._handle)
		self._handle = nil
	end

	if faild >= 3 then
		PopText("挑战失败")
		self:delayFunc(1, function()
			self:gameOver(false)
		end)
		return
	end

	self:delayFunc(1, function()
		self:initDrawData()
		self:createDrawNode()
		self:startGame()
	end)
end

-- 游戏结束
function LeftRightFightGameLayer:gameOver(isSucc)
	local role = User:getRole()

	if self.gameType == "open" and isSucc == true then
		-- 是否已拥有左右互搏
		if role:isHaveImprintingId("zuoyouhuboyin") ~= true then
			PopText("互搏神通开启")
			role:getMeridianSystem():addMeridianImprinting("zuoyouhuboyin")
			role:addAttr("leftRightFightExp", 1)
		end
	elseif self.gameType == "promote" and isSucc == true then
		local num = math.random(10, 20)
		PopText("互搏神通熟练度 + " .. num)
		role:addAttr("leftRightFightExp", num)
	end
	PopupLayerController:hideLayer("LeftRightFightGameLayer", function(layer)
		User:getRole():setFlag("PVP活动状态", "空闲中")
		self:hide()
	end, 0)
end

-- 判断是否触碰在左还是右
function LeftRightFightGameLayer:checkTouchInLayer(x, y)
	if self.canDraw == false then
		return
	end

	-- 1 左 2 右
	local leftPosX, leftPosY = self.Image_left1:getPositionX(), self.Image_left1:getPositionY()
	local leftSize = self.Image_left1:getSize()

	local rightPoxX, rightPoxY = self.Image_right1:getPositionX(), self.Image_right1:getPositionY()
	local rightSize = self.Image_right1:getSize()

	if (x >= leftPosX and x <= leftPosX + leftSize.width) and (y >= leftPosY and y <= leftPosY + leftSize.height) then
		return 1
	elseif (x >= rightPoxX and x <= rightPoxX + rightSize.width) and (y >= rightPoxY and y <= rightPoxY + rightSize.height) then
		return 2
	end

	return 0
end

-- 测试
function LeftRightFightGameLayer:test()

	self:addTouchEventListener(
		function(touch, event)
			local x = touch:getLocation().x
			local y = touch:getLocation().y

			if self:checkTouchInLayer(x ,y) ~= 1 then
				return false
			end

			if self.left.isDraw == true then
 				return false
 			end
 			self.left.lastX = x
			self.left.lastY = y
			self.left.dirList = {}
			self.left.length = {}
			self.left.totalLength = 0
			self.left.isDraw = true

			return true
		end,
		function(touch, event)
			local currX = touch:getLocation().x
 			local currY = touch:getLocation().y

 			local x = currX - self.left.lastX
 			local y = currY - self.left.lastY

 			local z = math.sqrt(x ^ 2 + y ^ 2)

 			self.left.totalLength = self.left.totalLength + z

 			-- print("( " .. x ..  " , " .. y .. " )" .. " " .. z)

 			-- print("rad = " .. math.deg(math.acos(x/z)))

 			local rad = 0
 			if y >= 0 then
 				rad = math.deg(math.acos(x/z))
 			else
 				rad = 360 - math.deg(math.acos(x/z))
 			end


 			for i,v in ipairs(dir) do
 				if rad >= v[1] and rad < v[2] then
 					if MapIsEmpty(self.left.dirList) ~=true and i == self.left.dirList[#self.left.dirList] then
 						self.left.length[#self.left.dirList] = self.left.length[#self.left.dirList] + z
 					else
 						table.insert(self.left.dirList, i)
 						table.insert(self.left.length, z)
 					end
 				end
 			end

 			self._drawNode:drawLine(cc.p(self.left.lastX, self.left.lastY), cc.p(touch:getLocation().x, touch:getLocation().y), cc.c4f(255, 1, 1, 30))
			self.left.lastX = touch:getLocation().x
			self.left.lastY = touch:getLocation().y
		end,
		function(touch, event)
			self.left.isDraw = false
 			if self:check(self.left, square1, squareProportion, 0.1) == true then
 				print("正方形1")
 				PopText("左 正方形1")
 			elseif self:check(self.left, square2, squareProportion, 0.1) == true then
 				print("正方形2")
 				PopText("左 正方形2")
 			elseif self:check(self.left, triangle1, triangleProportion, 0.1) == true then
 				print("三角形1")
 				PopText("左 三角形1")
 			elseif self:check(self.left, triangle2, triangleProportion, 0.1) == true then
 				print("三角形2")
 				PopText("左 三角形2")
 			elseif self:check(self.left, circular1, circularProportion, 0) == true then
 				print("圆形1")
 				PopText("左 圆形1")
 			elseif self:check(self.left, circular2, circularProportion, 0) == true then
 				print("圆形2")
 				PopText("左 圆形2")
 			end
		end)
end

function LeftRightFightGameLayer:setTouchHandler()

	self:addTouchEventListener(
		function(touch, event)
			self.canDraw = true

			local x = touch:getLocation().x
			local y = touch:getLocation().y

			if self:checkTouchInLayer(x ,y) ~= 1 then
				return false
			end

			if self.left.isDraw == true then
 				return false
 			end
 			self.left.lastX = x
			self.left.lastY = y
			self.left.dirList = {}
			self.left.length = {}
			self.left.totalLength = 0
			self.left.isDraw = true

			return true
		end,
		function(touch, event)
			if self.canDraw == false then
				return
			end

			if self.left.isDraw == false then
 				return
 			end

			local currX = touch:getLocation().x
 			local currY = touch:getLocation().y

 			local x = currX - self.left.lastX
 			local y = currY - self.left.lastY
			 
 			local z = math.sqrt(x ^ 2 + y ^ 2)
			 
 			self.left.totalLength = self.left.totalLength + z
			 
 			-- print("( " .. x ..  " , " .. y .. " )" .. " " .. z)
			 
 			-- print("rad = " .. math.deg(math.acos(x/z)))
			 
 			local rad = 0
 			if y >= 0 then
				rad = math.deg(math.acos(x/z))
			else
				rad = 360 - math.deg(math.acos(x/z))
 			end
			 
			 
 			for i,v in ipairs(dir) do
				if rad >= v[1] and rad < v[2] then
					if MapIsEmpty(self.left.dirList) ~=true and i == self.left.dirList[#self.left.dirList] then
						self.left.length[#self.left.dirList] = self.left.length[#self.left.dirList] + z
					else
						table.insert(self.left.dirList, i)
						table.insert(self.left.length, z)
					end
				end
			end
			
			self._drawNode:drawLine(cc.p(self.left.lastX, self.left.lastY), cc.p(touch:getLocation().x, touch:getLocation().y), cc.c4f(255, 1, 1, 30))
			self.left.lastX = touch:getLocation().x
			self.left.lastY = touch:getLocation().y
			
			if self:checkTouchInLayer(currX ,currY) ~= 1 then
				self:faild()
				return
			end
		end,
		function(touch, event)
			if self.canDraw == false then
				return
			end

			-- self.left.isDraw = false
 			if self:check(self.left, square1, squareProportion, 0.1) == true then
 				print("正方形1")
 				-- PopText("左 正方形1")

 				self:matchingGraph("left", 3)


 			elseif self:check(self.left, square2, squareProportion, 0.1) == true then
 				print("正方形2")
 				-- PopText("左 正方形2")

 				self:matchingGraph("left", 3)


 			elseif self:check(self.left, triangle1, triangleProportion, 0.1) == true then
 				print("三角形1")
 				-- PopText("左 三角形1")

 				self:matchingGraph("left", 2)


 			elseif self:check(self.left, triangle2, triangleProportion, 0.1) == true then
 				print("三角形2")
 				-- PopText("左 三角形2")

 				self:matchingGraph("left", 2)


 			elseif self:check(self.left, circular1, circularProportion, 0) == true then
 				print("圆形1")
 				-- PopText("左 圆形1")

 				self:matchingGraph("left", 1)


 			elseif self:check(self.left, circular2, circularProportion, 0) == true then
 				print("圆形2")
 				-- PopText("左 圆形2")

 				self:matchingGraph("left", 1)

 			else
 				self:matchingGraph("left", 0)
 			end
		end)

	self:addTouchEventListener(
		function(touch, event)
			self.canDraw = true
			local x = touch:getLocation().x
			local y = touch:getLocation().y

			if self:checkTouchInLayer(x ,y) ~= 2 then
				return false
			end

			if self.right.isDraw == true then
 				return false
 			end
 			self.right.lastX = x
			self.right.lastY = y
			self.right.dirList = {}
			self.right.length = {}
			self.right.totalLength = 0
			self.right.isDraw = true

			return true
		end,
		function(touch, event)
			if self.canDraw == false then
				return
			end

			if self.right.isDraw == false then
 				return
 			end

			local currX = touch:getLocation().x
 			local currY = touch:getLocation().y

 			local x = currX - self.right.lastX
 			local y = currY - self.right.lastY

 			local z = math.sqrt(x ^ 2 + y ^ 2)
			 
 			self.right.totalLength = self.right.totalLength + z
 			-- print("( " .. x ..  " , " .. y .. " )" .. " " .. z)
			 
 			-- print("rad = " .. math.deg(math.acos(x/z)))
			 
 			local rad = 0
 			if y >= 0 then
				rad = math.deg(math.acos(x/z))
			else
				rad = 360 - math.deg(math.acos(x/z))
			end
			
			
			for i,v in ipairs(dir) do
				if rad >= v[1] and rad < v[2] then
					if MapIsEmpty(self.right.dirList) ~=true and i == self.right.dirList[#self.right.dirList] then
						self.right.length[#self.right.dirList] = self.right.length[#self.right.dirList] + z
					else
 						table.insert(self.right.dirList, i)
 						table.insert(self.right.length, z)
					end
				end
			end
			
			self._drawNode:drawLine(cc.p(self.right.lastX, self.right.lastY), cc.p(touch:getLocation().x, touch:getLocation().y), cc.c4f(255, 1, 1, 30))
			self.right.lastX = touch:getLocation().x
			self.right.lastY = touch:getLocation().y
			if self:checkTouchInLayer(currX ,currY) ~= 2 then
			   self:faild()
			   return
		   end
		end,
		function(touch, event)
			if self.canDraw == false then
				return
			end
			print("===================== ,right")
			-- self.right.isDraw = false
 			if self:check(self.right, square1, squareProportion, 0.1) == true then
 				print("正方形1")
 				-- PopText("右 正方形1")

 				self:matchingGraph("right", 3)
 			elseif self:check(self.right, square2, squareProportion, 0.1) == true then
 				print("正方形2")
 				-- PopText("右 正方形2")

 				self:matchingGraph("right", 3)
 			elseif self:check(self.right, triangle1, triangleProportion, 0.1) == true then
 				print("三角形1")
 				-- PopText("右 三角形1")

 				self:matchingGraph("right", 2)
 			elseif self:check(self.right, triangle2, triangleProportion, 0.1) == true then
 				print("三角形2")
 				-- PopText("右 三角形2")

 				self:matchingGraph("right", 2)
 			elseif self:check(self.right, circular1, circularProportion, 0) == true then
 				print("圆形1")
 				-- PopText("右 圆形1")

 				self:matchingGraph("right", 1)
 			elseif self:check(self.right, circular2, circularProportion, 0) == true then
 				print("圆形2")
 				-- PopText("右 圆形2")

 				self:matchingGraph("right", 1)
 			else
 				self.right.state = 2
 				self:matchingGraph("right", 0)
 			end
		end)
end

-- 检测图像 flag 正反方向
function LeftRightFightGameLayer:check(dirData, shape, proportion, pr)
	local minLength = 1 / (#shape * 10)
	local maxLength = (1 / #shape) * 1.25

	local length = dirData.length
	local dirList = dirData.dirList
	local totalLength = dirData.totalLength

	if MapIsEmpty(dirList) == true then
		return false
	end

	-- print("maxLength = " .. maxLength)
	-- print("minLength = " .. minLength)

	-- for i,v in ipairs(dirList) do
	-- 	print("【" .. v .. "】 " .. length[i], length[i] / totalLength)
	-- end

	local function getStartIndex()
		-- 获得正确开始的笔画
		local startIndex = -1
		local index = -1
		for i,v in ipairs(dirList) do
			-- 太短的笔画忽略
			if length[i] / totalLength > 0.025 then
				for shapeIndex, dirArray in ipairs(shape) do
					for dirIndex,dir in ipairs(dirArray) do
						if dir == v then
							index = shapeIndex
							startIndex = shapeIndex
							return index
						end
					end
				end

				-- 第一个笔画，找不到合适的，图形画错了
				return index
			end
		end
		return index
	end

	-- -- 获得正确开始的笔画
	-- local index = getStartIndex()

	-- if index == -1 then
	-- 	print("找不到匹配笔画")
	-- 	return false
	-- end

	-- -- 根据第一笔，获得正确的顺序
	-- local newShape = {}
	-- local newproportion = {}
	-- for i=1,#shape do
	-- 	table.insert(newShape, shape[index])
	-- 	table.insert(newproportion, proportion[index])
	-- 	index = index + 1
	-- 	if index > #shape then
	-- 		index = 1
	-- 	end
	-- end

	-- shape = newShape
	-- proportion = newproportion
	-- index = 1

	local index = 1

	-- 当前笔画长度
	local currLength = 0

	local function getSameLine(i, index)
		if not shape[index] then
			return true, 0
		end

		local f = true
		-- print("index = ".. index)
		-- print("self.dirList[" .. i .. "] = " .. self.dirList[i])
		-- local str = "shape[" .. index .. "]"
		-- for dirIndex,dir in ipairs(shape[index]) do
		-- 	str = str .. dir .. ","
		-- end
		-- print(str)
		for dirIndex,dir in ipairs(shape[index]) do
			if dir == dirList[i] then
				f = false
				return f, length[i]
			end
		end
		return f, 0
	end

	for i = 1, #dirList do
		-- 太短的笔画忽略
		if length[i] / totalLength > 0.025 then
			local f = true
			local count = 1
			while(f and count >= 0) do
				local length = 0
				f, length = getSameLine(i, index)
				currLength = currLength + length

				-- 笔画方向改变，判断下一个
				if f == true then
					-- 检测长度是否在范围之内
					if pr ~= 0 and ( currLength / totalLength > proportion[index] + pr or currLength / totalLength < proportion[index] - pr ) then
						print("长度超出范围 " .. currLength / totalLength .. " <> " ..proportion[index])
						return false
					end

					index = index + 1
					count = count - 1
					if index > #shape then
						print("笔画太多")
						return false
					end
					currLength = 0
				end
			end

			if count < 0 then
				print("找不到匹配的笔画 " .. dirList[i] .. " index = " .. index)
				return false
			end
		end
	end

	if index ~= #shape then
		print("笔画不足")
		return false
	end

	return true
end

Helper:classDefNodeGetInstance(LeftRightFightGameLayer)

return LeftRightFightGameLayer00000000