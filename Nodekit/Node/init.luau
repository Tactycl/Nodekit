local CollectionService = game:GetService("CollectionService")
local UserInputService = game:GetService("UserInputService")

local enterSubtree = require("./util/enterSubtree")
local exitSubtree = require("./util/exitSubtree")
local safeCall = require("./util/safeCall")

local NodeTypes = require("@self/NodeTypes")
local NodeRegistry = require("@self/NodeRegistry")
local Tween = require("@self/Tween")
local Action = require("@self/Action")

local ZINDEX_ORDERING_PRIORITY = {
	"Node",
	"Layer",
	"Scene",
}

local function getName(self)
	local rblxInstance = self._instance
	local typeName = (self._type ~= nil and self._type ~= self._BASE_TYPE) and `{self._BASE_TYPE}::{self._type}` or self._BASE_TYPE
	local id = self._id
	local order = rblxInstance:IsA("GuiObject") and rblxInstance.LayoutOrder or "0"
	local childrenCount = #self._children

	local name = id ~= nil and `{typeName} "{id}"` or typeName
	if childrenCount > 0 then
		name ..= ` <{childrenCount}>`
	end
	
	return `[{order}] {name}`
end

local function updateInstanceName(self)
	self._instance.Name = getName(self)
end

local function markRenderDirty(node)
	while node do
		node._renderListDirty = true
		node = node._parent
	end
end

local function normalizeGuiSiblingOrder(parentNode)
	if not parentNode then
		return
	end

	local z = 0
	local function apply(baseType)
		for _, childNode in parentNode._children do
			if childNode._BASE_TYPE == baseType then
				local inst = childNode._instance
				if inst and inst:IsA("GuiObject") then
					if inst.ZIndex ~= z or inst.LayoutOrder ~= z then
						inst.ZIndex = z
						inst.LayoutOrder = z
						updateInstanceName(childNode)
					end
					z += 1
				end
			end
		end
	end

	for i = #ZINDEX_ORDERING_PRIORITY, 1, -1 do
		apply(ZINDEX_ORDERING_PRIORITY[i])
	end
	markRenderDirty(parentNode)
end

local function rebuildRenderList(self)
	local list = {}

	local function walk(node)
		local children = node._children
		if not children then
			return
		end

		for i = #ZINDEX_ORDERING_PRIORITY, 1, -1 do
			local baseType = ZINDEX_ORDERING_PRIORITY[i]

			for j = 1, #children do
				local child = children[j]
				if child._BASE_TYPE == baseType then
					walk(child)

					if child._instance and child._instance:IsA("GuiObject") then
						table.insert(list, 1, child)
					end
				end
			end
		end
	end

	walk(self)

	self._renderList = list
	self._renderListDirty = false
end

local function clampInsertIndex(zIndex: number, len: number): number
	local idx = zIndex + 1
	if idx < 1 then
		idx = 1
	end
	if idx > len + 1 then
		idx = len + 1
	end
	return idx
end

local function detachFromOldParent(childNode)
	local oldParent = childNode._parent
	if not oldParent then
		return nil
	end

	for i, c in oldParent._children do
		if c == childNode then
			table.remove(oldParent._children, i)
			break
		end
	end

	childNode._parent = nil
	childNode._instance.Parent = nil

	normalizeGuiSiblingOrder(oldParent)
	updateInstanceName(oldParent)
	safeCall(oldParent, "onChildRemoved", childNode)

	return oldParent
end

local function attachToParent(childNode, parentNode, zIndex: number?)
	childNode._parent = parentNode
	childNode._instance.Parent = parentNode._instance

	if zIndex == nil then
		table.insert(parentNode._children, childNode)

	else
		local idx = clampInsertIndex(zIndex, #parentNode._children)
		table.insert(parentNode._children, idx, childNode)
	end

	normalizeGuiSiblingOrder(parentNode)
	updateInstanceName(parentNode)
	safeCall(parentNode, "onChildAdded", childNode)

	local function walk(node)
		safeCall(node, "onAncestryChanged")
		for _, child in node._children do
			walk(child)
		end
	end

	walk(childNode)
end

local Node = {}
Node._BASE_TYPE = "Node"
Node.__index = function(self, key)
	local method = rawget(Node, key)
	if method then
		return method
	end

	if typeof(key) ~= "string" then
		return nil
	end

	if key:sub(1, 3) == "set" then
		local propName = key:sub(4)
		assert(self._metaWriteable[propName] ~= nil or self._metaVirtualWriteable[propName] ~= nil, `{propName} is not a valid member of {getName(self)}`)

		if self._metaWriteable[propName] then
			return function(self, v)
				if typeof(self._instance[propName]) == typeof(v) then
					self._instance[propName] = v
				end
				return self
			end

		elseif self._metaVirtualWriteable[propName] then
			return function(self, v)
				self._metaVirtualWriteable[propName](self, v)
				safeCall(self, "onChanged", propName, v)
				safeCall(self, ("on%sChanged"):format(propName), v)
				return self
			end
		end

	elseif key:sub(1, 3) == "get" then
		local propName = key:sub(4)
		assert(self._metaReadable[propName] ~= nil or self._metaVirtualReadable[propName] ~= nil, `{propName} is not a valid member of {getName(self)}`)

		if self._metaReadable[propName] then
			return function(self)
				return self._instance[propName]
			end

		elseif self._metaVirtualReadable[propName] then
			return function(self)
				return self._metaVirtualReadable[propName](self)
			end
		end
	end

	return nil
end

function Node:inherit()
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

function Node:_trackAction(a)
	self._actions = self._actions or {}
	self._actions[a] = true
end

function Node:_untrackAction(a)
	if self._actions then
		self._actions[a] = nil
	end
end

function Node:getRblxInstance()
	return self._instance
end

function Node:getCursorPosition()
	local cursorPos = UserInputService:GetMouseLocation()
	if typeof(self.getAbsolutePosition) ~= "function" then
		return cursorPos
	end
	return cursorPos - self:getAbsolutePosition()
end

function Node:getCursorPositionScaled()
	if typeof(self.getAbsoluteSize) ~= "function" then
		return Vector2.new(1, 1)
	end
	return self:getCursorPosition() / self:getAbsoluteSize()
end

function Node:addTag(tag: string)
	if not self._tags[tag] then
		self._tags[tag] = true
		CollectionService:AddTag(self._instance, tag)
	end
	return self
end

function Node:removeTag(tag: string)
	if self._tags[tag] then
		self._tags[tag] = nil
		CollectionService:RemoveTag(self._instance, tag)
	end
	return self
end

function Node:hasTag(tag: string)
	return self._tags[tag] == true
end

function Node:getTags()
	local out = {}
	for tag in self._tags do
		out[#out + 1] = tag
	end
	return table.freeze(out)
end

function Node:setAttribute(name: string, value: any)
	self._attributes[name] = value
	self._instance:SetAttribute(name, value)
	return self
end

function Node:getAttribute(name: string)
	return self._attributes[name]
end

function Node:removeAttribute(name: string)
	self:setAttribute(name, nil)
	return self
end

function Node:getAttributes()
	return table.freeze(table.clone(self._attributes))
end

function Node:setId(id: string)
	self._id = id
	updateInstanceName(self)
	return self
end

function Node:getId()
	return self._id
end

function Node:getName()
	return getName(self)
end

function Node:setType(t: string)
	self._type = t
	updateInstanceName(self)
	return self
end

function Node:getType()
	return self._type
end

function Node:isA(n: string)
	if self._type == n or self._BASE_TYPE == n then
		return true
	end
	return self._instance:IsA(n)
end

function Node:isDescendantOf(otherNode)
	if self == otherNode or typeof(otherNode) ~= "table" or otherNode._instance == nil then
		return false
	end
	return self._instance:IsDescendantOf(otherNode._instance)
end

function Node:addChild(childNode, zIndex: number?)
	assert(typeof(childNode) == "table" and childNode._instance, "addChild expects a Node")
	assert(childNode ~= self, "Cannot parent node to itself")

	if childNode._parent == self and zIndex == nil then
		return self
	end

	detachFromOldParent(childNode)
	attachToParent(childNode, self, zIndex)

	if self._isRunning == true then
		enterSubtree(childNode)
	end

	return self
end

function Node:add(...)
	for _, childNode in { ... } do
		self:addChild(childNode)
	end
	return self
end

function Node:getParent()
	return self._parent
end

function Node:removeFromParent()
	if not self._parent then
		return self
	end

	local wasRunning = (self._isRunning == true)

	detachFromOldParent(self)

	if wasRunning then
		exitSubtree(self)
	end

	return self
end

function Node:getDescendants()
	local descendants = {}
	local function walk(node)
		for _, childNode in node._children do
			table.insert(descendants, childNode)
			walk(childNode)
		end
	end
	walk(self)
	return table.freeze(descendants)
end

function Node:getDescendantsByType(type: string, ignoresNodeDescendantsWhenNodeNotType: boolean?)
	local descendants = {}
	local function walk(node)
		for _, childNode in node._children do
			if childNode._type == type or childNode._BASE_TYPE == type then
				table.insert(descendants, childNode)
				walk(childNode)

			elseif not ignoresNodeDescendantsWhenNodeNotType then
				walk(childNode)
			end
		end
	end
	walk(self)
	return table.freeze(descendants)
end

function Node:getChildren()
	return table.freeze(table.clone(self._children))
end

function Node:getChildrenByType(type: string)
	local children = {}
	for _, childNode in self._children do
		if childNode._type == type or childNode._BASE_TYPE == type then
			table.insert(children, childNode)
		end
	end
	return table.freeze(children)
end

function Node:getChildById(id: string, i: number?)
	local currentPointerIndex = 0
	for _, childNode in self._children do
		if childNode._id and childNode._id == id then
			if currentPointerIndex == (i or 0) then
				return childNode
			end
			currentPointerIndex += 1
		end
	end
	return
end

function Node:getChildAtIndex(i: number?)
	return self._children[(i or 0) + 1]
end

function Node:getChildByType(type: string, i: number?)
	local currentPointerIndex = 0
	for _, childNode in self._children do
		if childNode._type == type or childNode._BASE_TYPE == type then
			if currentPointerIndex == (i or 0) then
				return childNode
			end
			currentPointerIndex += 1
		end
	end
	return
end

function Node:querySelector(idString: string)
	local idList = string.split(idString, " ")
	local idSet = {}
	for i = 1, #idList do
		idSet[idList[i]] = true
	end

	local selection = {}

	local function walk(node)
		for _, child in node._children do
			if child._id and idSet[child._id] then
				selection[#selection + 1] = child
			end
			walk(child)
		end
	end

	walk(self)
	return table.freeze(selection)
end

function Node:clearAllChildrenWhichAreA(n: string)
	for i = #self._children, 1, -1 do
		local childNode = self._children[i]
		if childNode:isA(n) then
			childNode:destroy()
		end
	end
	return self
end

function Node:clearAllChildren()
	while #self._children > 0 do
		local childNode = table.remove(self._children)
		childNode:destroy()
	end
	return self
end

function Node:getRenderList()
	if self._renderListDirty or not self._renderList then
		rebuildRenderList(self)
	end
	return self._renderList
end

function Node:_trackTween(tween)
	if not self._activeTweens then
		self._activeTweens = {}
	end

	for _, tr in tween._tracks do
		local prop = tr.name
		local prev = self._activeTweens[prop]
		if prev and prev ~= tween then
			prev:cancel()
		end
		self._activeTweens[prop] = tween
	end
end

function Node:_untrackTween(tween)
	if not self._activeTweens then
		return
	end

	for prop, t in self._activeTweens do
		if t == tween then
			self._activeTweens[prop] = nil
		end
	end
end

function Node:tween(time: number, easingStyleOrFunc: Enum.EasingStyle?|(v: number) -> (number)?, easingDirection: Enum.EasingDirection?)
	local tweenInstance = Tween:create(self, time, easingStyleOrFunc, easingDirection)
	self._tweens[tweenInstance] = true
	return tweenInstance
end

function Node:pauseTween(tween)
	safeCall(tween, "pause")
end

function Node:resumeTween(tween)
	safeCall(tween, "resume")
end

function Node:stopTween(tween)
	if self._tweens and self._tweens[tween] then
		tween:cancel()
		self:_untrackTween(tween)
		self._tweens[tween] = nil
	end
end

function Node:stopAllTweens()
	if not self._tweens then
		return
	end
	for tw in self._tweens do
		tw:cancel()
	end
	table.clear(self._tweens)
	self._activeTweens = nil
end

function Node:stopAllActions()
	if not self._actions then
		return
	end
	for a in self._actions do
		if a and a.cancel then
			a:cancel()
		end
	end
	self._actions = {}
end

function Node:isRunning()
	return self._isRunning == true
end

function Node:isTransitioning()
	return self._isTransitioning == true
end

function Node:delay(t)
	local a = Action.delay(self, t)
	self:_trackAction(a)
	return a
end

function Node:call(fn)
	local a = Action.call(self, fn)
	self:_trackAction(a)
	return a
end

function Node:sequence(...)
	local a = Action.sequence(self, ...)
	self:_trackAction(a)
	return a
end

function Node:parallel(...)
	local a = Action.parallel(self, ...)
	self:_trackAction(a)
	return a
end

function Node:onActivated() end
function Node:onEnter() end
function Node:onExit() end
function Node:onEnterTransitionDidFinish() end
function Node:onExitTransitionDidStart() end
function Node:onEvent(event: any) end

function Node:destroy()
	safeCall(self, "onDestroyed")

	self:stopAllTweens()
	self:clearAllChildren()
	self:removeFromParent()

	NodeRegistry.unregister(self)

	table.clear(self._tags)
	table.clear(self._attributes)

	self._instance:Destroy()
end

NodeTypes:init(function(className)
	local self = setmetatable({}, Node)
	local instance = Instance.new(className)

	self._instance = instance
	self._parent = nil
	self._id = nil
	self._type = "Node"

	self._isRunning = false
	self._isTransitioning = false

	self._tweens = {}
	self._children = {}
	self._tags = {}
	self._attributes = {}

	self._renderList = nil
	self._renderListDirty = true

	NodeRegistry.register(self)
	updateInstanceName(self)

	return self
end)

for class, t in NodeTypes.classes do
	Node[class] = t
end

return Node
