const safeCall = require("../../../util/safeCall")

return function(self, event)
	local t = event.type
	local p = event.payload
	local inst = self._instance

	if t == "PointerEnter" then
		self._hovered = true
		if inst and inst:IsA("TextBox") then
			inst.Interactable = true
		end
		safeCall(self, "onMouseEnter", p)
		return
	end

	if t == "PointerLeave" then
		self._hovered = false
		if inst and inst:IsA("TextBox") and not self:isFocused() then
			inst.Interactable = false
		end
		safeCall(self, "onMouseLeave", p)
		return
	end

	if t == "PointerMoved" then
		safeCall(self, "onMouseMoved", p)
		return
	end

	if t == "PointerWheel" then
		local d = p and p.delta or 0
		if d > 0 then
			safeCall(self, "onMouseWheelForward", p)
		elseif d < 0 then
			safeCall(self, "onMouseWheelBackward", p)
		end
		return
	end

	if t == "PointerBegan" then
		local input = p and p.input
		if not input then
			return
		end

		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			if self._instance:IsA("TextBox") then
				self:captureFocus()
			end

			self._pressed = true
			safeCall(self, "onPress", p)
			event:consume()
			return
		end
		return
	end

	if t == "PointerEnded" then
		local input = p and p.input
		if not input then
			return
		end

		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			self._pressed = false
			safeCall(self, "onRelease", p)
			event:consume()
			return
		end
		return
	end

	if t == "PointerClick" then
		if self._instance:IsA("TextBox") then
			self:captureFocus()
		end
		safeCall(self, "onClick", p)
		event:consume()
		return
	end
end