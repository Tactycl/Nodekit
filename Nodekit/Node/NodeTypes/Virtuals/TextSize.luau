const Director = require("../../../Director")

local TextSize = {}

local function getDirectorScale()
	local directorInstance = Director:getInstance()
	return directorInstance and directorInstance:getScale() or 1
end

local function destroyConstraint(self)
	if self._textSizeConstraint then
		self._textSizeConstraint:Destroy()
		self._textSizeConstraint = nil
		self._minTextSize = nil
		self._maxTextSize = nil
	end
end

local function ensureConstraint(self)
	if not self._textSizeConstraint then
		self._textSizeConstraint = Instance.new("UITextSizeConstraint")
		self._textSizeConstraint.Parent = self._instance
		self._minTextSize = 0
		self._maxTextSize = math.huge
	end
	return self._textSizeConstraint
end

TextSize.getVirtualMax = function(self)
	local c = self._textSizeConstraint
	if c then
		return c.MaxTextSize / getDirectorScale()
	end
	return math.huge
end

TextSize.getVirtualMin = function(self)
	local c = self._textSizeConstraint
	if c then
		return c.MinTextSize / getDirectorScale()
	end
	return 0
end

TextSize.setVirtualMax = function(self, v)
	if v == nil then
		if TextSize.getVirtualMin(self) == 0 then
			destroyConstraint(self)
			return
		end

		v = math.huge
	end

	if typeof(v) ~= "number" then
		return
	end

	if v < 0 then
		v = 0
	end

	local c = ensureConstraint(self)
	local newV = v * getDirectorScale()

	if c.MinTextSize > newV then
		c.MaxTextSize = c.MinTextSize

	else
		c.MaxTextSize = newV
	end

	if c.MinTextSize == 0 and c.MaxTextSize == math.huge then
		destroyConstraint(self)

	else
		self._maxTextSize = v
	end
end

TextSize.setVirtualMin = function(self, v)
	if v == nil then
		if TextSize.getVirtualMax(self) == math.huge then
			destroyConstraint(self)
			return
		end
		v = 0
	end

	if typeof(v) ~= "number" then
		return
	end

	if v < 0 then
		v = 0
	end

	local c = ensureConstraint(self)
	local newV = v * getDirectorScale()

	if c.MaxTextSize < newV then
		c.MaxTextSize = newV
	end
	c.MinTextSize = newV

	if c.MinTextSize == 0 and c.MaxTextSize == math.huge then
		destroyConstraint(self)

	else
		self._minTextSize =	v
	end
end

return TextSize
