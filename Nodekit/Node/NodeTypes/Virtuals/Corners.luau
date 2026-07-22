local Corners = {}

local function destroyConstraint(self)
	if self._uiCorner then
		self._uiCorner:Destroy()
		self._uiCorner = nil
	end
end

local function ensureConstraint(self)
	if not self._uiCorner then
		self._uiCorner = Instance.new("UICorner")
		self._uiCorner.Parent = self._instance
	end
	return self._uiCorner
end

local function isZero(udim: UDim)
	return udim.Offset == 0 and udim.Scale == 0
end

local function allZero(self)
	local c = self._uiCorner
	if not c then
		return
	end

	return isZero(c.BottomLeftRadius) and isZero(c.BottomRightRadius) and isZero(c.TopLeftRadius) and isZero(c.TopRightRadius)
end

local function getVirtualIndividual(self, key: string)
	if self._uiCorner then
		return self._uiCorner[key]
	end
	return UDim.new()
end

local function setVirtualIndividual(self, key: string, v)
	if v == nil then
		if not self._uiCorner then
			return
		end
		self._uiCorner[key] = UDim.new(0, 0)
		if allZero(self) then
			destroyConstraint(self)
			return
		end
	end

	if typeof(v) == "UDim" then
		if isZero(v) and not self._uiCorner then
			return
		end
		ensureConstraint(self)[key] = v
		if allZero(self) then
			destroyConstraint(self)
		end
	end
end

Corners.getVirtualTopLeft = function(self, v)
	return getVirtualIndividual(self, "TopLeftRadius")
end

Corners.setVirtualTopLeft = function(self, v)
	setVirtualIndividual(self, "TopLeftRadius", v)
end

Corners.getVirtualTopRight = function(self, v)
	return getVirtualIndividual(self, "TopRightRadius")
end

Corners.setVirtualTopRight = function(self, v)
	setVirtualIndividual(self, "TopRightRadius", v)
end

Corners.getVirtualBottomRight = function(self, v)
	return getVirtualIndividual(self, "BottomRightRadius")
end

Corners.setVirtualBottomRight = function(self, v)
	setVirtualIndividual(self, "BottomRightRadius", v)
end

Corners.getVirtualBottomLeft = function(self, v)
	return getVirtualIndividual(self, "BottomLeftRadius")
end

Corners.setVirtualBottomLeft = function(self, v)
	setVirtualIndividual(self, "BottomLeftRadius", v)
end


-- Compatibility
Corners.getVirtual = function(self)
	local c = self._uiCorner
	if c then
		return c.CornerRadius
	end
	return UDim.new()
end

Corners.setVirtual = function(self, v)
	if v == nil then
		destroyConstraint(self)

	elseif typeof(v) == "UDim" then
		if v.Offset == 0 and v.Scale == 0 then
			destroyConstraint(self)
			return
		end

		local c = ensureConstraint(self)
		c.CornerRadius = v -- Compatibility
		c.BottomLeftRadius = v
		c.BottomRightRadius = v
		c.TopLeftRadius = v
		c.TopRightRadius = v
	end
end

return Corners
