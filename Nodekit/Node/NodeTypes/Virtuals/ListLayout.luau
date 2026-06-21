const Director = require("../../../Director")

local ListLayout = {}

local function getDirectorScale()
	local directorInstance = Director:getInstance()
	return directorInstance and directorInstance:getScale() or 1
end

local function destroyConstraint(self)
	if self._listLayout then
		self._listLayout:Destroy()
		self._listLayout = nil
	end
end

local function ensureConstraint(self)
	if not self._listLayout then
		self._listLayout = Instance.new("UIListLayout")
		self._listLayout.SortOrder = Enum.SortOrder.LayoutOrder
		self._listLayout.Parent = self._instance
	end
	return self._listLayout
end

ListLayout.setVirtualEnabled = function(self, enabled)
	if enabled == true then
		ensureConstraint(self)
	else
		destroyConstraint(self)
	end
end

ListLayout.getVirtualEnabled = function(self)
	return self._listLayout ~= nil
end

ListLayout.setVirtualFillDirection = function(self, fillDirection)
	if typeof(fillDirection) == "EnumItem" and fillDirection.EnumType == Enum.FillDirection then
		local c = ensureConstraint(self)
		c.FillDirection = fillDirection
	end
end

ListLayout.getVirtualFillDirection = function(self)
	if self._listLayout then
		return self._listLayout.FillDirection
	end
	return Enum.FillDirection.Vertical
end

ListLayout.setVirtualHorizontalAlignment = function(self, horizontalAlignment)
	if typeof(horizontalAlignment) == "EnumItem" and horizontalAlignment.EnumType == Enum.HorizontalAlignment then
		local c = ensureConstraint(self)
		c.HorizontalAlignment = horizontalAlignment
	end
end

ListLayout.getVirtualHorizontalAlignment = function(self)
	if self._listLayout then
		return self._listLayout.HorizontalAlignment
	end
	return Enum.HorizontalAlignment.Center
end

ListLayout.setVirtualVerticalAlignment = function(self, verticalAlignment)
	if typeof(verticalAlignment) == "EnumItem" and verticalAlignment.EnumType == Enum.VerticalAlignment then
		local c = ensureConstraint(self)
		c.VerticalAlignment = verticalAlignment
	end
end

ListLayout.getVirtualVerticalAlignment = function(self)
	if self._listLayout then
		return self._listLayout.VerticalAlignment
	end
	return Enum.VerticalAlignment.Center
end

ListLayout.setVirtualPadding = function(self, padding)
	if typeof(padding) == "UDim" then
		local c = ensureConstraint(self)
		c.Padding = padding
	end
end

ListLayout.getVirtualPadding = function(self)
	if self._listLayout then
		return self._listLayout.Padding
	end
	return UDim.new(0, 0)
end

ListLayout.setVirtualWraps = function(self, wraps)
	if typeof(wraps) == "boolean" then
		local c = ensureConstraint(self)
		c.Wraps = wraps
	end
end

ListLayout.getVirtualWraps = function(self)
	if self._listLayout then
		return self._listLayout.Wraps
	end
	return false
end

ListLayout.setVirtualHorizontalFlex = function(self, horizontalFlex)
	if typeof(horizontalFlex) == "EnumItem" and horizontalFlex.EnumType == Enum.UIFlexAlignment then
		local c = ensureConstraint(self)
		c.HorizontalFlex = horizontalFlex
	end
end

ListLayout.getVirtualHorizontalFlex = function(self)
	if self._listLayout then
		return self._listLayout.HorizontalFlex
	end
	return Enum.UIFlexAlignment.None
end

ListLayout.setVirtualVerticalFlex = function(self, verticalFlex)
	if typeof(verticalFlex) == "EnumItem" and verticalFlex.EnumType == Enum.UIFlexAlignment then
		local c = ensureConstraint(self)
		c.VerticalFlex = verticalFlex
	end
end

ListLayout.getVirtualVerticalFlex = function(self)
	if self._listLayout then
		return self._listLayout.VerticalFlex
	end
	return Enum.UIFlexAlignment.None
end

ListLayout.setVirtualItemLineAlignment = function(self, itemLineAlignment)
	if typeof(itemLineAlignment) == "EnumItem" and itemLineAlignment.EnumType == Enum.ItemLineAlignment then
		local c = ensureConstraint(self)
		c.ItemLineAlignment = itemLineAlignment
	end
end

ListLayout.getVirtualItemLineAlignment = function(self)
	if self._listLayout then
		return self._listLayout.ItemLineAlignment
	end
	return Enum.ItemLineAlignment.Automatic
end

ListLayout.getVirtualAbsoluteContentSize = function(self)
	if self._listLayout then
		return self._listLayout.AbsoluteContentSize / getDirectorScale()
	end
	return Vector2.zero
end

return ListLayout
