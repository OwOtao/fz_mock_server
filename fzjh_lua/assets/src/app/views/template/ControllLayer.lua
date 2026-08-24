-- 界面控制器,用来控制界面切换


local MainLayer = require("app.views.layer.MainLayer")

local ControllLayer = class("ControllLayer", cc.Layer)

local layers = --
{
}

function ControllLayer:create()
	local p = ControllLayer:new()
	p:init()
	return p
end

function ControllLayer:init()
	self._layers = layers

	self:preLoad()
	self:initLayerStack()


	self:getLayer("BackLayer")

	-- self.MainLayer = MainLayer:getInstance()
	-- self:getLayer("MainLayer")
	-- self:getLayer("TaskLayer")




	self:getLayer("TitleLayer")
	self:getLayer("PrintLayer")


	-- self:switchLayer("MainLayer", "TaskLayer")

	self:pushLayer("MainLayer")
end

function ControllLayer:preLoad()
end

function ControllLayer:initLayerStack()
	self._layerStack = {}
end

function ControllLayer:pushLayer(name, anim)
	local layerStack = self._layerStack
	local maxn = #layerStack
	if maxn > 0 then
		local fromLayerName = layerStack[maxn]
		local toLayerName = name
		if fromLayerName == toLayerName then
			if PRINT_MODE == 1 then
				print("不能切换到相同层")
			end
			return false
		end
		if maxn > 50 then
			if PRINT_MODE == 1 then
				print("压入层数过多, 自动移除第一条记录")
			end
			table.remove(layerStack, 1)
		end
		self:switchLayer(fromLayerName, toLayerName, anim)
	elseif maxn == 0 then
		self:switchLayer(nil, name)
	else
		assert("压入层出问题!!")
	end
	table.insert(layerStack, name)
end

function ControllLayer:popLayer()
	local layerStack = self._layerStack
	local maxn = #layerStack
	if maxn == 1 then
		if PRINT_MODE == 1 then
			print("已经没有层可以弹出")
		end
	elseif maxn > 1 then
		local fromLayerName = layerStack[maxn]
		local toLayerName = layerStack[maxn-1]
		self:switchLayer(fromLayerName, toLayerName, false)
		table.remove(layerStack, #layerStack)
	end
end

function ControllLayer:getLayer(name)
	local layer = self[name]
	if layer == nil then
		if PRINT_MODE == 1 then
			print("getLayer name = "..tostring(name))
			for k,v in pairs(self._layers) do
				print(k)
			end
		end
		local LayerClass = assert(self._layers[name])
		self[name] = LayerClass:create()
		layer = self[name]
		layer:addTo(self)
		layer.ControllLayer = self
	end
	return layer
end

function ControllLayer:playSwitchAnim(fromLayerName, toLayerName, anim, isAnimForward)
	if isAnimForward == nil then
		isAnimForward = true
	end
	if anim == nil then
		anim = true
	end

	local fromLayer = self:getLayer(fromLayerName)
	local toLayer = self:getLayer(toLayerName)

	if anim then
		if isAnimForward then
			fromLayer:move(cc.p(0, 0))
			toLayer:move(cc.p(display.width, 0))
			toLayer:resumeSelfAndChildren()

			local fromTag = fromLayer:getActionTagByName("Switch")
			local toTag = toLayer:getActionTagByName("Switch")

			local fromAction = cc.Sequence:create(
				cc.MoveTo:create(0.3, cc.p(-display.width, 0)),
				cc.CallFunc:create(
					function()
						fromLayer:setVisible(false)
						fromLayer:pauseSelfAndChildren()
					end))
			fromAction:setTag(fromTag)

			toLayer:setVisible(true)
			local toAction = cc.Sequence:create(
				cc.MoveTo:create(0.3, cc.p(0, 0)),
				cc.CallFunc:create(
					function()
						-- toLayer:resumeSelfAndChildren()
					end))
			toAction:setTag(toTag)

			fromLayer:stopActionByTag(fromTag)
			fromLayer:runAction(fromAction)
			toLayer:stopActionByTag(toTag)
			toLayer:runAction(toAction)
		else
			fromLayer:move(cc.p(0, 0))
			toLayer:move(cc.p(-display.width, 0))
			toLayer:resumeSelfAndChildren()

			local fromTag = fromLayer:getActionTagByName("Switch")
			local toTag = toLayer:getActionTagByName("Switch")

			local fromAction = cc.Sequence:create(
				cc.MoveTo:create(0.3, cc.p(display.width, 0)),
				cc.CallFunc:create(
					function()
						fromLayer:setVisible(false)
						fromLayer:pauseSelfAndChildren()
					end))
			fromAction:setTag(fromTag)

			toLayer:setVisible(true)
			local toAction = cc.Sequence:create(
				cc.MoveTo:create(0.3, cc.p(0, 0)),
				cc.CallFunc:create(
					function()
						-- toLayer:resumeSelfAndChildren()
					end))
			toAction:setTag(toTag)

			fromLayer:stopActionByTag(fromTag)
			fromLayer:runAction(fromAction)
			toLayer:stopActionByTag(toTag)
			toLayer:runAction(toAction)
		end
	else
		local fromTag = fromLayer:getActionTagByName("Switch")
		local toTag = toLayer:getActionTagByName("Switch")
		fromLayer:stopActionByTag(fromTag)
		toLayer:stopActionByTag(toTag)

		fromLayer:move(cc.p(display.width, 0))
		toLayer:move(cc.p(0, 0))

		toLayer:setVisible(true)
		toLayer:resumeSelfAndChildren()

		fromLayer:setVisible(false)
		fromLayer:pauseSelfAndChildren()

		if layerStack[maxn] == "TaskLayer" then
			toLayer:init()
		end
	end
end

function ControllLayer:switchLayer(fromLayerName, toLayerName, anim, isAnimForward )
	if PRINT_MODE == 1 then
		print("function ControllLayer:switchLayer("..tostring(fromLayerName)..", "..tostring(toLayerName)..")")
	end

	if fromLayerName and toLayerName then
		self:playSwitchAnim(fromLayerName, toLayerName, anim, isAnimForward)
	else
		local toLayer = self:getLayer(toLayerName)
		toLayer:resumeSelfAndChildren()
		toLayer:move(cc.p(0, 0))
	end
end

function ControllLayer:hideLayer(layer)

end

function ControllLayer:showLayer(layer)

end

Helper:classDefNodeGetInstance(ControllLayer)
return ControllLayer
000000000000000