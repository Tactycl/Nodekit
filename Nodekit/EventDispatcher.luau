local UserInputService = game:GetService("UserInputService")

local Event = require("./Event")

local EventDispatcher = {}
EventDispatcher.__index = EventDispatcher

local function isGuiObject(inst)
	return inst ~= nil and inst:IsA("GuiObject")
end

local function isVisibleInHierarchy(node)
	while node do
		local inst = node._instance
		if inst and inst:IsA("GuiObject") then
			if inst.Visible ~= true then
				return false
			end
		end
		node = node._parent
	end
	return true
end

local function isPointerTarget(node)
	local inst = node and node._instance
	if not isGuiObject(inst) then
		return false
	end
	if inst.Active ~= true then
		return false
	end
	if not isVisibleInHierarchy(node) then
		return false
	end
	return true
end

local function pointInGui(inst, p)
	local pos = inst.AbsolutePosition
	local size = inst.AbsoluteSize
	return p.X >= pos.X and p.Y >= pos.Y and p.X <= pos.X + size.X and p.Y <= pos.Y + size.Y
end

local function isPressInput(input)
	return input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch
end

local function getPointerId(input)
	return input
end

local function isPointerEventType(t)
	return t == "PointerEnter"
		or t == "PointerLeave"
		or t == "PointerMoved"
		or t == "PointerWheel"
		or t == "PointerBegan"
		or t == "PointerEnded"
		or t == "PointerChanged"
		or t == "PointerClick"
end

local function isBlockingLayer(node)
	return node
		and node.isBlockingEventPropagation
		and typeof(node.isBlockingEventPropagation) == "function"
		and node:isBlockingEventPropagation() == true
end

local function canCullByParentBounds(node)
	local inst = node and node._instance
	return inst and inst:IsA("GuiObject") and inst.ClipsDescendants == true
end

local function getRunningScene(self)
	local d = self._director
	return d and d.getRunningScene and d:getRunningScene()
end

local function handleNode(self, node, event)
	if not node then
		return
	end

	if isPointerEventType(event.type) then
		if typeof(node._onPointerEvent) == "function" then
			node:_onPointerEvent(event)
		end
		return
	end

	if node._dispatchEvent then
		node:_dispatchEvent(event)
		
	elseif typeof(node.onEvent) == "function" then
		node:onEvent(event)
	end
end

local function dispatchDirect(self, node, event)
	if node then
		handleNode(self, node, event)
	end
	return event
end

local function findTopmostAt(root, pos)
	local function walk(node)
		local renderList = node:getRenderList()
		if renderList then
			if canCullByParentBounds(node) then
				local inst = node._instance
				if inst and inst:IsA("GuiObject") and not pointInGui(inst, pos) then
					return nil
				end
			end

			for i = 1, #renderList do
				local child = renderList[i]
				local hit = walk(child)
				if hit then
					return hit
				end
				
				if isBlockingLayer(child) then
					return nil
				end
			end
		end

		if isPointerTarget(node) and pointInGui(node._instance, pos) then
			return node
		end

		return nil
	end

	return root and walk(root) or nil
end

local function resolveInputPosition(self, input)
	if input.Position then
		return Vector2.new(input.Position.X, input.Position.Y)
	end
	return UserInputService:GetMouseLocation()
end

local function makePayload(input, processed, pos, wasButtonPressed, pointerId)
	return {
		input = input,
		gameProcessed = processed,
		position = pos,
		wasButtonPressed = wasButtonPressed == true,
		pointerId = pointerId,
	}
end

local function updateHover(self, pointerId, pos)
	local scene = getRunningScene(self)
	if not scene then
		return false
	end

	local dispatched = false
	local hit = findTopmostAt(scene, pos)
	local prev = self._hoverNodes[pointerId]

	if hit == prev then
		if hit then
			dispatchDirect(
				self,
				hit,
				Event:create("PointerMoved", {
					position = pos,
					pointerId = pointerId,
				})
			)
			dispatched = true
		end
		return dispatched
	end

	self._hoverNodes[pointerId] = hit

	if prev then
		dispatchDirect(
			self,
			prev,
			Event:create("PointerLeave", {
				position = pos,
				pointerId = pointerId,
			})
		)
		dispatched = true
	end

	if hit then
		dispatchDirect(
			self,
			hit,
			Event:create("PointerEnter", {
				position = pos,
				pointerId = pointerId,
			})
		)
		dispatchDirect(
			self,
			hit,
			Event:create("PointerMoved", {
				position = pos,
				pointerId = pointerId,
			})
		)
		dispatched = true
	end

	return dispatched
end

local function dispatchWheel(self, pos, delta)
	local scene = getRunningScene(self)
	if not scene then
		return false
	end

	local hit = findTopmostAt(scene, pos)
	if hit then
		dispatchDirect(
			self,
			hit,
			Event:create("PointerWheel", {
				position = pos,
				delta = delta,
			})
		)
		return true
	end

	return false
end

local function dispatchDownTree(self, root, event)
	if not root or not event then
		return event
	end

	local function walk(node)
		handleNode(self, node, event)

		if typeof(event.isConsumed) == "function" and event:isConsumed() then
			return true
		end

		if isBlockingLayer(node) then
			return true
		end

		local children = node._children
		if children then
			for _, childNode in children do
				if walk(childNode) then
					return true
				end
			end
		end

		return false
	end

	walk(root)
	return event
end

function EventDispatcher:create(director)
	local inst = setmetatable({}, EventDispatcher)
	inst._director = director
	inst._enabled = true
	inst._conns = {}
	inst._hoverNodes = {}
	inst._pressNodes = {}
	inst._focusLostConn = nil
	return inst
end

function EventDispatcher:dispatch(event, root)
	local r = root or getRunningScene(self)
	return dispatchDownTree(self, r, event)
end

function EventDispatcher:bindUserInput()
	self._conns[#self._conns + 1] = UserInputService.InputBegan:Connect(function(input, gp)
		if not self._enabled then
			return
		end

		local pointerId = getPointerId(input)
		local pos = resolveInputPosition(self, input)

		local pointerSent = false

		if input.UserInputType ~= Enum.UserInputType.Touch then
			if updateHover(self, pointerId, pos) then
				pointerSent = true
			end
		end

		local scene = getRunningScene(self)
		local hit = scene and findTopmostAt(scene, pos)

		if isPressInput(input) then
			self._pressNodes[pointerId] = hit
			if hit then
				dispatchDirect(
					self,
					hit,
					Event:create("PointerBegan", makePayload(input, gp, pos, false, pointerId))
				)
				pointerSent = true
			end
		end

		dispatchDownTree(self, scene, Event:create("InputBegan", makePayload(input, gp, pos, pointerSent, pointerId)))
	end)

	self._conns[#self._conns + 1] = UserInputService.InputChanged:Connect(function(input, gp)
		if not self._enabled then
			return
		end

		local pointerId = getPointerId(input)
		local pos = resolveInputPosition(self, input)

		local pointerSent = false

		if input.UserInputType == Enum.UserInputType.MouseWheel then
			local d = input.Position and input.Position.Z or 0
			if d ~= 0 and dispatchWheel(self, pos, d) then
				pointerSent = true
			end

		else
			if input.UserInputType ~= Enum.UserInputType.Touch then
				if updateHover(self, pointerId, pos) then
					pointerSent = true
				end
			end
		end

		local scene = getRunningScene(self)
		local hit = scene and findTopmostAt(scene, pos)
		if hit then
			dispatchDirect(
				self,
				hit,
				Event:create("PointerChanged", makePayload(input, gp, pos, false, pointerId))
			)
			pointerSent = true
		end

		dispatchDownTree(self, scene, Event:create("InputChanged", makePayload(input, gp, pos, pointerSent, pointerId)))
	end)

	self._conns[#self._conns + 1] = UserInputService.InputEnded:Connect(function(input, gp)
		if not self._enabled then
			return
		end

		local pointerId = getPointerId(input)
		local scene = getRunningScene(self)
		local pos = resolveInputPosition(self, input)

		local pointerSent = false

		if input.UserInputType ~= Enum.UserInputType.Touch then
			if updateHover(self, pointerId, pos) then
				pointerSent = true
			end
		end

		if isPressInput(input) then
			local hit = scene and findTopmostAt(scene, pos)
			local pressed = self._pressNodes[pointerId]

			if hit then
				dispatchDirect(
					self,
					hit,
					Event:create("PointerEnded", makePayload(input, gp, pos, false, pointerId))
				)
				pointerSent = true
			end

			if hit and pressed and hit == pressed then
				dispatchDirect(
					self,
					hit,
					Event:create("PointerClick", makePayload(input, gp, pos, false, pointerId))
				)
				pointerSent = true
			end

			self._pressNodes[pointerId] = nil
			self._hoverNodes[pointerId] = nil
		end

		dispatchDownTree(self, scene, Event:create("InputEnded", makePayload(input, gp, pos, pointerSent, pointerId)))
	end)

	return self
end

function EventDispatcher:destroy()
	for _, c in self._conns do
		c:Disconnect()
	end
	self._conns = {}
	self._hoverNodes = {}
	self._pressNodes = {}
	self._director = nil
end

return EventDispatcher
