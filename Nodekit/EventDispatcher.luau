const UserInputService = game:GetService("UserInputService")

const Event = require("./Event")

local EventDispatcher = {}
EventDispatcher.__index = EventDispatcher

local function pointInGui(inst, p)
	local pos = inst.AbsolutePosition
	local size = inst.AbsoluteSize
	return p.X >= pos.X and p.Y >= pos.Y and p.X <= pos.X + size.X and p.Y <= pos.Y + size.Y
end

local function isPressInput(input)
	return input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch
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
		and type(node.isBlockingEventPropagation) == "function"
		and node:isBlockingEventPropagation() == true
end

local function getRootNode(self)
	local d = self._director
	return d and d.froot
end

local function handleNode(self, node, event)
	if not node then
		return
	end

	debug.profilebegin("EventDispatcher::handleNode")

	if isPointerEventType(event.type) then
		if type(node._onPointerEvent) == "function" then
			node:_onPointerEvent(event)
		end
		debug.profileend()
		return
	end

	if node._dispatchEvent then
		node:_dispatchEvent(event)
		
	elseif type(node.onEvent) == "function" then
		node:onEvent(event)
	end
	debug.profileend()
end

local function dispatchDirect(self, node, event)
	if node then
		handleNode(self, node, event)
	end
	return event
end

local function findTopmostAt(root, pos)
	debug.profilebegin("EventDispatcher::findTopmostAt")
	local function walk(node)
		local inst = node._instance

		local isGuiObject = inst:IsA("GuiObject")
		if isGuiObject and not inst.Visible then
			return nil
		end

		local _cachedIsInGui = nil

		if isGuiObject and (inst.ClipsDescendants or node:isA("CanvasGroup")) then
			_cachedIsInGui = pointInGui(inst, pos)
			if isGuiObject and not _cachedIsInGui then
				return nil
			end
		end

		for _, child in node:getRenderList() do
			local hit = walk(child)
			if hit then
				return hit
			end

			if isBlockingLayer(child) then
				return nil
			end
		end

		if isGuiObject and inst.Active and ((_cachedIsInGui ~= nil and _cachedIsInGui == true) or pointInGui(inst, pos)) then
			return node
		end

		return nil
	end

	local res = root and walk(root) or nil
	debug.profileend()
	return res
end

local function resolveInputPosition(self, input)
	if input.Position then
		return Vector2.new(input.Position.X, input.Position.Y)
	end
	return UserInputService:GetMouseLocation()
end

local function makePayload(input, processed, pos, wasButtonPressed)
	local wasTyping = UserInputService:GetFocusedTextBox() ~= nil
	local wasProcessed = processed == true or wasButtonPressed == true or wasTyping
	return {
		input = input,
		gameProcessed = processed,
		position = pos,
		wasButtonPressed = wasButtonPressed == true,
		wasTyping = wasTyping,
		wasProcessed = wasProcessed,
	}
end

local function updateHover(self, input, pos, hit)
	local prev = self._hoverNodes[input]

	if hit == prev then
		if hit then
			dispatchDirect(
				self,
				hit,
				Event:create("PointerMoved", {
					input = input,
					position = pos,
				})
			)
			return true
		end

		return false
	end

	self._hoverNodes[input] = hit

	if prev then
		dispatchDirect(
			self,
			prev,
			Event:create("PointerLeave", {
				input = input,
				position = pos,
			})
		)
	end

	if hit then
		dispatchDirect(
			self,
			hit,
			Event:create("PointerEnter", {
				input = input,
				position = pos,
			})
		)

		dispatchDirect(
			self,
			hit,
			Event:create("PointerMoved", {
				input = input,
				position = pos,
			})
		)
	end

	return prev ~= nil or hit ~= nil
end

local function dispatchUpTree(self, root, event, ignoreRoot)
	if not root or not event then
		return event
	end

	debug.profilebegin("EventDispatcher::dispatchUpTree")

	local function walk(node)
		local inst = node._instance
		if inst:IsA("GuiObject") and not inst.Visible then
			return false
		end

		for _, childNode in node:getRenderList() do
			if walk(childNode) then
				return true
			end
		end

		if not ignoreRoot or node ~= root then
			handleNode(self, node, event)

			if event._isConsumed then
				return true
			end

			if isBlockingLayer(node) then
				return true
			end
		end

		return false
	end

	walk(root)
	debug.profileend()
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

function EventDispatcher:dispatch(event, root, ignoreRoot)
	local r = root or getRootNode(self)
	return dispatchUpTree(self, r, event, ignoreRoot or root == nil)
end

function EventDispatcher:bindUserInput()
	self._conns[#self._conns + 1] = UserInputService.InputBegan:Connect(function(input, gp)
		if not self._enabled then
			return
		end

		local pos = resolveInputPosition(self, input)

		local root = getRootNode(self)
		local hit = root and findTopmostAt(root, pos)

		if input.UserInputType ~= Enum.UserInputType.Touch then
			updateHover(self, input, pos, hit)
		end

		local wasButtonPressed = false
		if isPressInput(input) then
			self._pressNodes[input] = hit
			if hit then
				dispatchDirect(
					self,
					hit,
					Event:create("PointerBegan", makePayload(input, gp, pos, false))
				)
				wasButtonPressed = true
			end
		end

		dispatchUpTree(self, root, Event:create("InputBegan", makePayload(input, gp, pos, wasButtonPressed)), true)
	end)

	self._conns[#self._conns + 1] = UserInputService.InputChanged:Connect(function(input, gp)
		if not self._enabled then
			return
		end

		local inputType = input.UserInputType

		local isMouseMovement = inputType == Enum.UserInputType.MouseMovement
		local isTouchMovement = inputType == Enum.UserInputType.Touch
		local isMouseWheel = inputType == Enum.UserInputType.MouseWheel

		if not isMouseMovement and not isTouchMovement and not isMouseWheel then
			local root = getRootNode(self)

			dispatchUpTree(
				self,
				root,
				Event:create("InputChanged", makePayload(input, gp, nil, false)),
				true
			)

			return
		end

		local pos = resolveInputPosition(self, input)
		local root = getRootNode(self)

		local hit = root and findTopmostAt(root, pos)
		local pointerSent = false

		if isMouseWheel then
			local delta = input.Position.Z

			if delta ~= 0 and hit then
				dispatchDirect(
					self,
					hit,
					Event:create("PointerWheel", {
						input = input,
						gameProcessed = gp,
						position = pos,
						delta = delta,
					})
				)

				pointerSent = true
			end

		else
			if isMouseMovement then
				pointerSent = updateHover(self, input, pos, hit)
			end

			if hit then
				dispatchDirect(self, hit, Event:create("PointerChanged", makePayload(input, gp, pos, false)))

				pointerSent = true
			end
		end

		if not pointerSent then
			dispatchUpTree(
				self,
				root,
				Event:create("InputChanged", makePayload(input, gp, pos, false)),
				true
			)
		end
	end)

	self._conns[#self._conns + 1] = UserInputService.InputEnded:Connect(function(input, gp)
		if not self._enabled then
			return
		end

		local pos = resolveInputPosition(self, input)

		local root = getRootNode(self)
		local hit = root and findTopmostAt(root, pos)

		if input.UserInputType ~= Enum.UserInputType.Touch then
			updateHover(self, input, pos, hit)
		end

		local wasButtonPressed = false
		if isPressInput(input) then
			local pressed = self._pressNodes[input]

			if hit then
				dispatchDirect(
					self,
					hit,
					Event:create("PointerEnded", makePayload(input, gp, pos, false))
				)
				wasButtonPressed = true
			end

			if hit and pressed and hit == pressed then
				dispatchDirect(
					self,
					hit,
					Event:create("PointerClick", makePayload(input, gp, pos, false))
				)
				wasButtonPressed = true
			end

			self._pressNodes[input] = nil
			self._hoverNodes[input] = nil
		end

		dispatchUpTree(self, root, Event:create("InputEnded", makePayload(input, gp, pos, wasButtonPressed)), true)
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
