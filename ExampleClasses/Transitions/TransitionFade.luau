const ReplicatedStorage = game:GetService("ReplicatedStorage")

const Nodekit = require(ReplicatedStorage.Packages.Nodekit)

const Node = Nodekit.Node
const Transition = Nodekit.Transition

local TransitionFade = Transition:inherit()

export type TransitionFadeOptions = {
	color: Color3?,
}

function TransitionFade:create(opts: TransitionFadeOptions?)
	local inst = setmetatable(Transition:create(), TransitionFade)
	inst._color = (opts and opts.color) or Color3.new(0, 0, 0)
	return inst
end

function TransitionFade:run(duration: number, incoming: any, outgoing: any, finish: () -> ())
	local done = false
	local function finalize()
		if done then
			return
		end
		done = true
		finish()
	end

	if not duration or duration <= 0 then
		finalize()
		return
	end

	local parent = incoming:getParent() or outgoing:getParent()
	if not parent then
		finalize()
		return
	end

	local overlay = Node.Frame:create()
		:setSize(UDim2.fromScale(1, 1))
		:setPosition(UDim2.fromScale(0.5, 0.5))
		:setAnchorPoint(Vector2.new(0.5, 0.5))
		:setBackgroundColor3(self._color)
		:setBackgroundTransparency(1)
		:setActive(false)
		:setId("transition-overlay")
		:setType("TransitionFade")
	parent:addChild(overlay)

	local half = duration * 0.5
	local tweenIn = overlay:tween(half, Enum.EasingStyle.Quad, Enum.EasingDirection.Out):toBackgroundTransparency(0)
	local tweenOut = overlay:tween(half, Enum.EasingStyle.Quad, Enum.EasingDirection.In):toBackgroundTransparency(1)

	incoming:setVisible(false)
	tweenIn:onComplete(function()
		if outgoing then
			outgoing:setVisible(false)
		end
		incoming:setVisible(true)

		tweenOut:onComplete(function()
			overlay:destroy()
			finalize()
		end):play()
	end):play()
end

return TransitionFade
