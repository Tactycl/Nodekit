const TweenService = game:GetService("TweenService")
const RunService = game:GetService("RunService")

local Tween = {}

export type EasingStyle = Enum.EasingStyle | (alpha: number, easingDirection: Enum.EasingDirection) -> (number)

Tween.__index = function(self, key)
	local method = rawget(Tween, key)
	if method then
		return method
	end

	if typeof(key) == "string" and key:sub(1, 2) == "to" then
		local propName = key:sub(3)
		return function(_, value)
			return self:_setGoal(propName, value)
		end
	end

	return nil
end

local function assertNotPlayed(self)
	if self._rec.played then
		error("Tween already played; create a new tween for a new run", 3)
	end
end

local function lerpColor3(a, b, t)
	return Color3.new(math.lerp(a.R, b.R, t), math.lerp(a.G, b.G, t), math.lerp(a.B, b.B, t))
end

local function lerpVector2(a, b, t)
	return Vector2.new(math.lerp(a.X, b.X, t), math.lerp(a.Y, b.Y, t))
end

local function lerpUDim(a, b, t)
	return UDim.new(math.lerp(a.Scale, b.Scale, t), math.floor(math.lerp(a.Offset, b.Offset, t) + 0.5))
end

local function lerpUDim2(a, b, t)
	return UDim2.new(
		math.lerp(a.X.Scale, b.X.Scale, t),
		math.floor(math.lerp(a.X.Offset, b.X.Offset, t) + 0.5),
		math.lerp(a.Y.Scale, b.Y.Scale, t),
		math.floor(math.lerp(a.Y.Offset, b.Y.Offset, t) + 0.5)
	)
end

local function getLerperFor(value)
	local t = typeof(value)
	if t == "number" then
		return math.lerp
	end
	if t == "Color3" then
		return lerpColor3
	end
	if t == "Vector2" then
		return lerpVector2
	end
	if t == "UDim" then
		return lerpUDim
	end
	if t == "UDim2" then
		return lerpUDim2
	end
	return nil
end

local function resolveWrite(node, propName)
	if node._metaVirtualWriteable and node._metaVirtualWriteable[propName] then
		local setFn = node._metaVirtualWriteable[propName]
		return "virtual", setFn
	end
	if typeof(node[`set{propName}`]) == "function" then
		return "virtual", node[`set{propName}`]
	end
	if node._metaWriteable and node._metaWriteable[propName] then
		return "native", nil
	end

	return nil
end

local function resolveRead(node, propName, kind)
	if kind == "virtual" then
		if node._metaVirtualReadable and node._metaVirtualReadable[propName] then
			return node._metaVirtualReadable[propName]
		end
		if typeof(node[`get{propName}`]) == "function" then
			return node[`get{propName}`]
		end
	end

	return nil
end

local function fireCompleted(self)
	if self._rec.cancelled then
		return
	end
	local node = self._node
	if node and node._untrackTween then
		node:_untrackTween(self)
	end
	for _, cb in self._rec.completed do
		task.spawn(cb)
	end
end

function Tween:create(node: any, time: number, easingStyleOrFunc: EasingStyle?, easingDirection: Enum.EasingDirection?)
	local inst = setmetatable({}, Tween)

	inst._node = node
	inst._time = (typeof(time) == "number" and time) or 0
	
	if typeof(easingStyleOrFunc) == "function" then
		inst._interpolateFunc = easingStyleOrFunc
		
	else
		inst._style = easingStyleOrFunc or Enum.EasingStyle.Linear
	end
	inst._dir = easingDirection or Enum.EasingDirection.In

	inst._goals = {}

	inst._rec = {
		conn = nil,
		completed = {},
		played = false,
		cancelled = false,
		paused = false,
	}

	inst._tracks = nil
	inst._elapsed = 0

	return inst
end

function Tween:_setGoal(propName: string, value: number)
	assertNotPlayed(self)

	local node = self._node
	if not node then
		return self
	end

	local kind = resolveWrite(node, propName)
	if not kind then
		error(("Property '%s' is not tweenable on this node type"):format(propName), 3)
	end

	local vt = typeof(value)
	if vt == "Vector3" or vt == "CFrame" then
		error(("Tween does not support type '%s' for '%s'"):format(vt, propName), 3)
	end

	local lerpFn = getLerperFor(value)
	if not lerpFn then
		error(("Tween does not support type '%s' for '%s'"):format(vt, propName), 3)
	end

	self._goals[propName] = value
	return self
end

function Tween:onComplete(cb: () -> ()?)
	table.insert(self._rec.completed, cb)
	return self
end

function Tween:pause()
	self._rec.paused = true
	return self
end

function Tween:resume()
	self._rec.paused = false
	return self
end

function Tween:cancel()
	self._rec.cancelled = true
	if self._rec.conn then
		self._rec.conn:Disconnect()
	end
	self._rec.conn = nil
	return self
end

function Tween:play()
	assertNotPlayed(self)
	self._rec.played = true

	local node = self._node
	local inst = node and node._instance
	if not inst then
		fireCompleted(self)
		return self
	end

	if next(self._goals) == nil then
		fireCompleted(self)
		return self
	end

	local tracks = {}
	for propName, target in self._goals do
		local kind, setFn = resolveWrite(node, propName)
		local from

		if kind == "native" then
			from = inst[propName]
		else
			local getFn = resolveRead(node, propName, "virtual")
			if not getFn then
				error(("Virtual property '%s' must have a getter to tween"):format(propName), 3)
			end
			from = getFn(node)
		end

		if typeof(from) ~= typeof(target) then
			error(("Tween type mismatch for '%s' (from %s to %s)"):format(propName, typeof(from), typeof(target)), 3)
		end

		local lerpFn = getLerperFor(target)
		if not lerpFn then
			error(("Tween does not support type '%s' for '%s'"):format(typeof(target), propName), 3)
		end

		tracks[#tracks + 1] = {
			name = propName,
			kind = kind,
			set = setFn,
			from = from,
			to = target,
			lerp = lerpFn,
		}
	end

	self._tracks = tracks
	self._elapsed = 0

	if node and node._trackTween then
		node:_trackTween(self)
	end

	if self._time <= 0 then
		for _, tr in tracks do
			if tr.kind == "native" then
				inst[tr.name] = tr.to
			else
				tr.set(node, tr.to)
			end
		end
		if self._rec.conn then
			self._rec.conn:Disconnect()
		end
		self._rec.conn = nil
		fireCompleted(self)
		return self
	end

	self._rec.conn = RunService.RenderStepped:Connect(function(dt)
		if self._rec.cancelled then
			if self._rec.conn then
				self._rec.conn:Disconnect()
			end
			self._rec.conn = nil
			return
		end

		if self._rec.paused then
			return
		end

		self._elapsed += dt
		local alpha = self._elapsed / self._time
		if alpha > 1 then
			alpha = 1
		end

		local eased
		if typeof(self._interpolateFunc) == "function" then
			eased = self._interpolateFunc(alpha, self._dir)
			
		else
			eased = TweenService:GetValue(alpha, self._style, self._dir)
		end
		
		if alpha >= 1 then
			eased = 1
		end

		for _, tr in tracks do
			local v = tr.lerp(tr.from, tr.to, eased)
			if tr.kind == "native" then
				inst[tr.name] = v
			else
				tr.set(node, v)
			end
		end

		if alpha >= 1 then
			if self._rec.conn then
				self._rec.conn:Disconnect()
			end
			self._rec.conn = nil
			fireCompleted(self)
		end
	end)

	return self
end

return Tween
