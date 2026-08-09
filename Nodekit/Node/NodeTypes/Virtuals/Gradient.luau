local Gradient = {}

local function destroyConstraint(self)
	if self._gradient then
		self._gradient:Destroy()
		self._gradient = nil
	end
end

local function ensureConstraint(self)
	if not self._gradient then
		self._gradient = Instance.new("UIGradient")
		self._gradient.Parent = self._instance
	end
	return self._gradient
end

Gradient.setVirtualEnabled = function(self, enabled)
	if enabled == true then
		ensureConstraint(self)
	else
		destroyConstraint(self)
	end
end

Gradient.getVirtualEnabled = function(self)
	return self._gradient ~= nil
end

Gradient.setVirtualColor = function(self, color)
	if typeof(color) == "ColorSequence" then
		local c = ensureConstraint(self)
		c.Color = color
		return
	end

	if typeof(color) == "Color3" then
		local c = ensureConstraint(self)
		c.Color = ColorSequence.new(color)
		return
	end
end

Gradient.getVirtualColor = function(self)
	if self._gradient then
		return self._gradient.Color
	end
	return ColorSequence.new(Color3.new(1, 1, 1))
end

Gradient.setVirtualOffset = function(self, offset)
	if typeof(offset) == "Vector2" then
		local c = ensureConstraint(self)
		c.Offset = offset
	end
end

Gradient.getVirtualOffset = function(self)
	if self._gradient then
		return self._gradient.Offset
	end
	return Vector2.zero
end

Gradient.setVirtualRotation = function(self, rotation)
	if typeof(rotation) == "number" then
		local c = ensureConstraint(self)
		c.Rotation = rotation
	end
end

Gradient.getVirtualRotation = function(self)
	if self._gradient then
		return self._gradient.Rotation
	end
	return 0
end

Gradient.setVirtualTransparency = function(self, transparency)
	if typeof(transparency) == "NumberSequence" then
		local c = ensureConstraint(self)
		c.Transparency = transparency
		return
	end

	if typeof(transparency) == "number" then
		local c = ensureConstraint(self)
		c.Transparency = NumberSequence.new(transparency)
		return
	end
end

Gradient.getVirtualTransparency = function(self)
	if self._gradient then
		return self._gradient.Transparency
	end
	return NumberSequence.new(0)
end

return Gradient
