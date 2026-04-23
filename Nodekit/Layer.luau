local RunService = game:GetService("RunService")

local safeCall = require("./util/safeCall")

local Node = require("./Node")

local Layer = Node:inherit()
Layer._BASE_TYPE = "Layer"

function Layer:inherit()
	local newClass = {}

	newClass.__index = function(obj, key)
		local v = rawget(newClass, key)
		if v ~= nil then
			return v
		end

		return self.__index(obj, key)
	end

	setmetatable(newClass, { __index = self })

	return newClass
end

function Layer:create(t: string?)
	local node = Node.Frame:create()
		:setSize(UDim2.fromScale(1, 1))
		:setPosition(UDim2.fromScale(0.5, 0.5))
		:setAnchorPoint(Vector2.new(0.5, 0.5))
		:setBackgroundTransparency(1)
		:setActive(false)
		:setType(t or "Layer")

	local inst: any = setmetatable(node, Layer)

	inst._eventsEnabled = true
	inst._blocksEventsBelow = false

	inst._isUpdateEnabled = false
	inst._updatePriority = 0
	inst._updateConn = nil
	inst._isPaused = false

	safeCall(inst, "init")
	return inst
end

function Layer:setEventEnabled(enabled: boolean)
	self._eventsEnabled = enabled and true or false
	return self
end

function Layer:isEventEnabled(): boolean
	return self._eventsEnabled == true
end

function Layer:setBlocksEventsBelow(blocks: boolean)
	self._blocksEventsBelow = blocks and true or false
	return self
end

function Layer:isBlockingEventPropagation(): boolean
	return self._blocksEventsBelow == true
end

function Layer:isTopLayer(): boolean
	local parent = self:getParent()
	local detectedSelf = false
	for _, childNode in parent._children do
		if childNode == self then
			detectedSelf = true

		elseif detectedSelf then
			return false
		end
	end

	return true
end

function Layer:isBlockedByOtherLayer(): boolean
	local parent = self:getParent()
	local detectedSelf = false
	for _, childNode in parent._children do
		if childNode == self then
			detectedSelf = true

		elseif detectedSelf and childNode._blocksEventsBelow then
			return true
		end
	end

	return false
end

function Layer:onPause() end
function Layer:onResume() end

function Layer:scheduleUpdate(priority: number?)
	self._isUpdateEnabled = true
	self._updatePriority = priority or 0

	if self._isRunning and not self._updateConn then
		self:_attachUpdate()
	end

	return self
end

function Layer:unscheduleUpdate()
	self._isUpdateEnabled = false
	self:_detachUpdate()
	return self
end

function Layer:isUpdateScheduled(): boolean
	return self._isUpdateEnabled == true
end

function Layer:update(_dt: number) end

function Layer:_attachUpdate()
	self:_detachUpdate()

	self._updateConn = RunService.Heartbeat:Connect(function(dt)
		if not self._isRunning then
			return
		end
		if not self._isUpdateEnabled then
			return
		end
		if self._isPaused then
			return
		end
		safeCall(self, "update", dt)
	end)
end

function Layer:_detachUpdate()
	if typeof(self._updateConn) == "RBXScriptConnection" then
		self._updateConn:Disconnect()
		self._updateConn = nil
	end
end

function Layer:_setRunning(running: boolean)
	if running and not self._isRunning then
		self._isRunning = true
		self._isPaused = false
		self:onEnter()

		if self._isUpdateEnabled then
			self:_attachUpdate()
		end
	elseif not running and self._isRunning then
		self._isRunning = false
		self._isPaused = false
		self._isTransitioning = false
		self:_detachUpdate()
		self:onExit()
	end
end

function Layer:_setEnteringTransition(active: boolean)
	self._isTransitioningIn = active and true or false
	if not active then
		self:onEnterTransitionDidFinish()
	end
end

function Layer:_setExitingTransition(active: boolean)
	self._isTransitioningOut = active and true or false
	if active then
		self:onExitTransitionDidStart()
	end
end

function Layer:pause()
	if self._isPaused then
		return self
	end
	self._isPaused = true
	self:onPause()
	return self
end

function Layer:resume()
	if not self._isPaused then
		return self
	end
	self._isPaused = false
	self:onResume()
	return self
end

function Layer:isPaused(): boolean
	return self._isPaused == true
end

local RunService = game:GetService("RunService")

local safeCall = require("./util/safeCall")

local Node = require("./Node")

local Layer = Node:inherit()
Layer._BASE_TYPE = "Layer"

function Layer:inherit()
	local newClass = {}

	newClass.__index = function(obj, key)
		local v = rawget(newClass, key)
		if v ~= nil then
			return v
		end

		return self.__index(obj, key)
	end

	setmetatable(newClass, { __index = self })

	return newClass
end

function Layer:create(t: string?)
	local node = Node.Frame:create()
		:setSize(UDim2.fromScale(1, 1))
		:setPosition(UDim2.fromScale(0.5, 0.5))
		:setAnchorPoint(Vector2.new(0.5, 0.5))
		:setBackgroundTransparency(1)
		:setActive(false)
		:setType(t or "Layer")

	local inst: any = setmetatable(node, Layer)

	inst._eventsEnabled = true
	inst._blocksEventsBelow = false

	inst._isUpdateEnabled = false
	inst._updatePriority = 0
	inst._updateConn = nil
	inst._isPaused = false

	safeCall(inst, "init")
	return inst
end

function Layer:setEventEnabled(enabled: boolean)
	self._eventsEnabled = enabled and true or false
	return self
end

function Layer:isEventEnabled(): boolean
	return self._eventsEnabled == true
end

function Layer:setBlocksEventsBelow(blocks: boolean)
	self._blocksEventsBelow = blocks and true or false
	return self
end

function Layer:isBlockingEventPropagation(): boolean
	return self._blocksEventsBelow == true
end

function Layer:isTopLayer(): boolean
	local parent = self:getParent()
	local detectedSelf = false
	for _, childNode in parent._children do
		if childNode == self then
			detectedSelf = true

		elseif detectedSelf then
			return false
		end
	end

	return true
end

function Layer:isBlockedByOtherLayer(): boolean
	local parent = self:getParent()
	local detectedSelf = false
	for _, childNode in parent._children do
		if childNode == self then
			detectedSelf = true

		elseif detectedSelf and childNode._blocksEventsBelow then
			return true
		end
	end

	return false
end

function Layer:onPause() end
function Layer:onResume() end

function Layer:scheduleUpdate(priority: number?)
	self._isUpdateEnabled = true
	self._updatePriority = priority or 0

	if self._isRunning and not self._updateConn then
		self:_attachUpdate()
	end

	return self
end

function Layer:unscheduleUpdate()
	self._isUpdateEnabled = false
	self:_detachUpdate()
	return self
end

function Layer:isUpdateScheduled(): boolean
	return self._isUpdateEnabled == true
end

function Layer:update(_dt: number) end

function Layer:_attachUpdate()
	self:_detachUpdate()

	self._updateConn = RunService.Heartbeat:Connect(function(dt)
		if not self._isRunning then
			return
		end
		if not self._isUpdateEnabled then
			return
		end
		if self._isPaused then
			return
		end
		safeCall(self, "update", dt)
	end)
end

function Layer:_detachUpdate()
	if typeof(self._updateConn) == "RBXScriptConnection" then
		self._updateConn:Disconnect()
		self._updateConn = nil
	end
end

function Layer:_setRunning(running: boolean)
	if running and not self._isRunning then
		self._isRunning = true
		self._isPaused = false
		self:onEnter()

		if self._isUpdateEnabled then
			self:_attachUpdate()
		end
	elseif not running and self._isRunning then
		self._isRunning = false
		self._isPaused = false
		self._isTransitioning = false
		self:_detachUpdate()
		self:onExit()
	end
end

function Layer:_setEnteringTransition(active: boolean)
	self._isTransitioningIn = active and true or false
	if not active then
		self:onEnterTransitionDidFinish()
	end
end

function Layer:_setExitingTransition(active: boolean)
	self._isTransitioningOut = active and true or false
	if active then
		self:onExitTransitionDidStart()
	end
end

function Layer:pause()
	if self._isPaused then
		return self
	end
	self._isPaused = true
	self:onPause()
	return self
end

function Layer:resume()
	if not self._isPaused then
		return self
	end
	self._isPaused = false
	self:onResume()
	return self
end

function Layer:isPaused(): boolean
	return self._isPaused == true
end

function Layer:_dispatchEvent(event)
	if self._eventsEnabled then
		safeCall(self, "onEvent", event)
	end
	if self._blocksEventsBelow then
		event:consume()
	end
end

function Layer:destroy()
	self:_detachUpdate()
	return Node.destroy(self)
end

return Layer


function Layer:destroy()
	self:_detachUpdate()
	return Node.destroy(self)
end

return Layer
