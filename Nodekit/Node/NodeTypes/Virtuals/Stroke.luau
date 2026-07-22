local Stroke = {}

local function destroyConstraint(self)
	if self._stroke then
		self._stroke:Destroy()
		self._stroke = nil
	end
end

local function ensureConstraint(self)
	if not self._stroke then
		self._stroke = Instance.new("UIStroke")
		self._stroke.Parent = self._instance
	end
	return self._stroke
end

Stroke.setVirtualEnabled = function(self, enabled)
	if enabled == true then
		ensureConstraint(self)
	else
		destroyConstraint(self)
	end
end

Stroke.getVirtualEnabled = function(self)
	return self._stroke ~= nil
end

Stroke.setVirtualApplyMode = function(self, v)
	if typeof(v) == "EnumItem" and v.EnumType == Enum.ApplyStrokeMode and self._stroke then
		self._stroke.ApplyStrokeMode = v
	end
end

Stroke.getVirtualApplyMode = function(self)
	return self._stroke and self._stroke.ApplyStrokeMode or Enum.ApplyStrokeMode.Contextual
end

Stroke.setVirtualBorderOffset = function(self, v)
	if typeof(v) == "UDim" and self._stroke then
		self._stroke.BorderOffset = v
	end
end

Stroke.getVirtualBorderOffset = function(self)
	return self._stroke and self._stroke.BorderOffset or UDim.new()
end

Stroke.setVirtualBorderPosition = function(self, v)
	if typeof(v) == "EnumItem" and v.EnumType == Enum.BorderStrokePosition and self._stroke then
		self._stroke.BorderStrokePosition = v
	end
end

Stroke.getVirtualBorderPosition = function(self)
	return self._stroke and self._stroke.BorderStrokePosition or Enum.BorderStrokePosition.Outer
end

Stroke.setVirtualColor = function(self, v)
	if typeof(v) == "Color3" and self._stroke then
		self._stroke.Color = v
	end
end

Stroke.getVirtualColor = function(self)
	return self._stroke and self._stroke.Color or Color3.new(0, 0, 0)
end

Stroke.setVirtualLineJoinMode = function(self, v)
	if typeof(v) == "EnumItem" and v.EnumType == Enum.LineJoinMode and self._stroke then
		self._stroke.LineJoinMode = v
	end
end

Stroke.getVirtualLineJoinMode = function(self)
	return self._stroke and self._stroke.LineJoinMode or Enum.LineJoinMode.Round
end

Stroke.setVirtualSizingMode = function(self, v)
	if typeof(v) == "EnumItem" and v.EnumType == Enum.StrokeSizingMode and self._stroke then
		self._stroke.StrokeSizingMode = v
	end
end

Stroke.getVirtualSizingMode = function(self)
	return self._stroke and self._stroke.StrokeSizingMode or Enum.StrokeSizingMode.FixedSize
end

Stroke.setVirtualThickness = function(self, v)
	if type(v) == "number" and self._stroke then
		self._stroke.Thickness = v
	end
end

Stroke.getVirtualThickness = function(self)
	return self._stroke and self._stroke.Thickness or 1
end

Stroke.setVirtualTransparency = function(self, v)
	if type(v) == "number" and self._stroke then
		self._stroke.Transparency = math.clamp(v, 0, 1)
	end
end

Stroke.getVirtualTransparency = function(self)
	return self._stroke and self._stroke.Transparency or 0
end

return Stroke
