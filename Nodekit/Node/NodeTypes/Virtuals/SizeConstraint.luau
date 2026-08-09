local SizeConstraint = {}

local function destroyConstraint(self)
	if self._sizeConstraint then
		self._sizeConstraint:Destroy()
		self._sizeConstraint = nil
	end
end

local function ensureConstraint(self)
	if not self._sizeConstraint then
		self._sizeConstraint = Instance.new("UISizeConstraint")
		self._sizeConstraint.Parent = self._instance
	end
	return self._sizeConstraint
end

SizeConstraint.getVirtualMaxSize = function(self)
	local c = self._sizeConstraint
	if c then
		return c.MaxSize
	end
	return Vector2.new(math.huge, math.huge)
end

SizeConstraint.getVirtualMinSize = function(self)
	local c = self._sizeConstraint
	if c then
		return c.MinSize
	end
	return Vector2.zero
end

SizeConstraint.setVirtualMaxSize = function(self, v)
	if v == nil then
		local min = SizeConstraint.getVirtualMinSize(self)
		if min.X == 0 and min.Y == 0 then
			destroyConstraint(self)
			return
		end
		v = Vector2.new(math.huge, math.huge)
	end

	if typeof(v) ~= "Vector2" then
		return
	end

	local c = ensureConstraint(self)
	c.MaxSize = Vector2.new(math.max(0, v.X), math.max(0, v.Y))

	c.MinSize = Vector2.new(math.min(c.MinSize.X, c.MaxSize.X), math.min(c.MinSize.Y, c.MaxSize.Y))

	if c.MinSize.X == 0 and c.MinSize.Y == 0 and c.MaxSize.X == math.huge and c.MaxSize.Y == math.huge then
		destroyConstraint(self)
	end
end

SizeConstraint.setVirtualMinSize = function(self, v)
	if v == nil then
		local max = SizeConstraint.getVirtualMaxSize(self)
		if max.X == math.huge and max.Y == math.huge then
			destroyConstraint(self)
			return
		end
		v = Vector2.zero
	end

	if typeof(v) ~= "Vector2" then
		return
	end

	local c = ensureConstraint(self)
	c.MinSize = Vector2.new(math.max(0, v.X), math.max(0, v.Y))

	c.MaxSize = Vector2.new(math.max(c.MaxSize.X, c.MinSize.X), math.max(c.MaxSize.Y, c.MinSize.Y))

	if c.MinSize.X == 0 and c.MinSize.Y == 0 and c.MaxSize.X == math.huge and c.MaxSize.Y == math.huge then
		destroyConstraint(self)
	end
end

return SizeConstraint
