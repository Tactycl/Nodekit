const GuiService = game:GetService("GuiService")
const Players = game:GetService("Players")

const LocalPlayer = Players.LocalPlayer

const Node = require("./Node")
const Scene = require("./Scene")

const activateSubtree = require("./util/activateSubtree")
const enterSubtree = require("./util/enterSubtree")
const enterTransitionDidFinishSubtree = require("./util/enterTransitionDidFinishSubtree")
const exitTransitionDidStartSubtree = require("./util/exitTransitionDidStartSubtree")

const REFERENCE_SIZE_PIXELS = 1080

local Director = {}
Director.__index = function(self, key)
	local value = Director[key]
	if value ~= nil then
		return value
	end

	local froot = rawget(self, "froot")
	if froot then
		local frootValue = froot[key]
		if frootValue ~= nil then
			return frootValue
		end
	end

	return nil
end

local _instance

local function finalizeTransition(self, incoming)
	incoming:setSceneType(Scene.Type.DEFAULT)
	enterTransitionDidFinishSubtree(incoming)
	activateSubtree(incoming)
	incoming:setVisible(true)
	self.nextScene = nil
	self._transitionInProgress = false
end

local function updateScale()
	local inst = Director:getInstance()
	if not inst then
		return
	end

	local absSize = inst.root:getAbsoluteSize()
	local scale = absSize.Y / REFERENCE_SIZE_PIXELS

	inst.root:setScale(scale)
	inst.froot:setSize(UDim2.fromOffset(absSize.X / scale, absSize.Y / scale))
end

function Director:init()
	if _instance then
		return _instance
	end

	local inst = setmetatable({}, Director)

	inst.eventDispatcher = nil
	inst.runningScene = nil
	inst.nextScene = nil
	inst.sceneStack = {}

	inst.playerGui = LocalPlayer:WaitForChild("PlayerGui")
	inst.root = Node.ScreenGui:create()
		:setIgnoreGuiInset(true)
		:setZIndexBehavior(Enum.ZIndexBehavior.Sibling)
		:setId("root")
		:addType("Director")
	inst.root._instance.Parent = inst.playerGui

	inst.froot = Node.Frame:create()
		:setPosition(UDim2.fromScale(0.5, 0.5))
		:setAnchorPoint(Vector2.new(0.5, 0.5))
		:setBackgroundTransparency(1)
		:setId("froot")
		:addType("Container")
	inst.root:addChild(inst.froot)

	_instance = inst

	updateScale()
	inst.root.onAbsoluteSizeChanged = updateScale

	enterSubtree(inst.root)

	return inst
end

function Director:getInstance()
	return _instance
end

function Director:destroyInstance()
	if _instance then
		_instance:popToRootScene()
		_instance:popScene()
		_instance.root:destroy()
	end
	_instance = nil
end

function Director:getEventDispatcher()
	return self.eventDispatcher
end

function Director:setEventDispatcher(eventDispatcher)
	self.eventDispatcher = eventDispatcher
end

function Director:getScale()
	local v = self.root:getScale()
	return v > 0 and v
end

function Director:getWinSize()
	local size = self.froot:getSize()
	return Vector2.new(size.X.Offset, size.Y.Offset)
end

function Director:getAbsoluteWinSize()
	return self:getWinSize() * self:getScale()
end

function Director:getCursorPosition()
	return self.root:getCursorPosition()
end

function Director:getCursorPositionScaled()
	return self.root:getCursorPositionScaled()
end

function Director:getGuiInset()
	return GuiService:GetGuiInset()
end

function Director:isTransitionInProgress()
	return self._transitionInProgress
end

function Director:runWithScene(scene)
	self.sceneStack = { scene }
	self.runningScene = scene
	self.nextScene = nil
	self.froot:addChild(scene)

	activateSubtree(scene)

	return scene
end

function Director:replaceScene(scene)
	local outgoing = self.runningScene
	self.nextScene = scene

	if outgoing then
		outgoing:removeFromParent()
	end

	self.sceneStack[#self.sceneStack] = scene
	self.runningScene = scene
	self.froot:addChild(scene)

	activateSubtree(scene)

	self.nextScene = nil
	return scene
end

function Director:pushScene(scene)
	local outgoing = self.runningScene
	self.nextScene = scene

	if outgoing then
		outgoing:removeFromParent()
	end

	table.insert(self.sceneStack, scene)
	self.runningScene = scene
	self.froot:addChild(scene)

	activateSubtree(scene)

	self.nextScene = nil
	return scene
end

function Director:popScene()
	local outgoing = table.remove(self.sceneStack)
	local incoming = self.sceneStack[#self.sceneStack]
	if not incoming then
		return
	end

	self.nextScene = incoming

	if outgoing then
		outgoing:removeFromParent()
	end

	self.runningScene = incoming

	if incoming then
		self.froot:addChild(incoming)
		incoming:setVisible(true)
	end

	self.nextScene = nil
	return incoming
end

function Director:replaceSceneWithTransition(t, transitionScene, incoming)
	if self._transitionInProgress then
		return
	end
	self._transitionInProgress = true

	local outgoing = self.runningScene
	self.nextScene = incoming

	if not outgoing then
		table.insert(self.sceneStack, incoming)
		self.runningScene = incoming
		self.froot:addChild(incoming)

		activateSubtree(incoming)

		self.nextScene = nil
		self._transitionInProgress = false
		return incoming
	end

	outgoing:setSceneType(Scene.Type.TRANSITION)
	exitTransitionDidStartSubtree(outgoing)

	self.sceneStack[#self.sceneStack] = incoming
	self.runningScene = incoming

	self.froot:add(incoming, outgoing)

	incoming:setSceneType(Scene.Type.TRANSITION)

	local finished = false
	local function finish()
		if finished then
			return
		end
		finished = true

		outgoing:setSceneType(Scene.Type.DEFAULT)
		outgoing:removeFromParent()

		finalizeTransition(self, incoming)
	end

	if type(transitionScene.run) == "function" then
		transitionScene:run(t, incoming, outgoing, finish)
	else
		finish()
	end

	return incoming
end

function Director:pushSceneWithTransition(t, transitionScene, incoming)
	if self._transitionInProgress then
		return
	end
	self._transitionInProgress = true

	local outgoing = self.runningScene
	self.nextScene = incoming

	if outgoing then
		outgoing:setSceneType(Scene.Type.TRANSITION)
		exitTransitionDidStartSubtree(outgoing)
	end

	table.insert(self.sceneStack, incoming)
	self.runningScene = incoming

	if outgoing then
		self.froot:addChild(outgoing)
	end
	self.froot:addChild(incoming)

	incoming:setSceneType(Scene.Type.TRANSITION)

	local finished = false
	local function finish()
		if finished then
			return
		end
		finished = true

		if outgoing then
			outgoing:setSceneType(Scene.Type.DEFAULT)
			outgoing:removeFromParent()
		end

		finalizeTransition(self, incoming)
	end

	if type(transitionScene.run) == "function" then
		transitionScene:run(t, incoming, outgoing, finish)
	else
		finish()
	end

	return incoming
end

function Director:popSceneWithTransition(t, transitionScene)
	if self._transitionInProgress then
		return
	end

	local outgoing = self.runningScene
	local incoming = self.sceneStack[#self.sceneStack - 1]

	if not incoming then
		return
	end

	self._transitionInProgress = true
	self.nextScene = incoming

	outgoing:setSceneType(Scene.Type.TRANSITION)
	exitTransitionDidStartSubtree(outgoing)

	self.froot:add(incoming, outgoing)

	incoming:setSceneType(Scene.Type.TRANSITION)

	local finished = false
	local function finish()
		if finished then
			return
		end
		finished = true

		table.remove(self.sceneStack)
		self.runningScene = incoming

		outgoing:setSceneType(Scene.Type.DEFAULT)
		outgoing:removeFromParent()

		finalizeTransition(self, incoming)
	end

	if type(transitionScene.run) == "function" then
		transitionScene:run(t, incoming, outgoing, finish)
	else
		finish()
	end

	return incoming
end

function Director:popToRootScene()
	while #self.sceneStack > 1 do
		self:popScene()
	end
	return self.runningScene
end

function Director:getRunningScene()
	return self.runningScene
end

function Director:getNextScene()
	return self.nextScene
end

function Director:getNumberOfRunningScenes()
	return #self.sceneStack
end

return Director
