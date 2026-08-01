const Node = require("./Node")

local Scene = Node:inherit()
Scene._BASE_TYPE = "Scene"
Scene.Type = table.freeze({
	DEFAULT = "DEFAULT",
	TRANSITION = "TRANSITION",
})

function Scene:inherit()
	local newClass = {}

	newClass.__index = function(obj, key)
		local v = rawget(newClass, key)
		if v ~= nil then
			return v
		end

		return self.__index(obj, key)
	end

	setmetatable(newClass, { __index = self })

	return newClass
end

function Scene:create(t: string?)
	local node = Node.Frame:create()
		:setPosition(UDim2.fromScale(0.5, 0.5))
		:setAnchorPoint(Vector2.new(0.5, 0.5))
		:setSize(UDim2.fromScale(1, 1))
		:setBackgroundTransparency(1)
		:addType("Scene")

	if type(t) == "string" then
		node:addType(t)
	end

	local inst = setmetatable(node, Scene)
	inst._sceneType = Scene.Type.DEFAULT
	inst._initFailed = false

	if type(inst.init) == "function" then
		local ok = inst:init()
		if ok == false then
			inst._initFailed = true
		end
	end

	return inst
end

function Scene:getSceneType()
	return self._sceneType
end

function Scene:setSceneType(t: string)
	self._sceneType = t
	return self
end

function Scene:initFailed()
	return self._initFailed == true
end

function Scene:destroy()
	self:clearAllChildren()
	self:removeFromParent()
	if self._instance then
		self._instance:Destroy()
	end
end

return Scene
