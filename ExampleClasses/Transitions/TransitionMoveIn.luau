const ReplicatedStorage = game:GetService("ReplicatedStorage")

const Nodekit = require(ReplicatedStorage.Packages.Nodekit)

const Transition = Nodekit.Transition

local TransitionMoveIn = Transition:inherit()

export type TransitionMoveInOptions = {
	easingStyle: Nodekit.TweenEasingStyle?,
}

function TransitionMoveIn:create(opts: TransitionMoveInOptions?)
	local inst = setmetatable(Transition:create(), TransitionMoveIn)
	inst._easingStyle = opts and opts.easingStyle or Enum.EasingStyle.Linear
	return inst
end

function TransitionMoveIn:run(duration: number, incoming: any, outgoing: any, finish: () -> ())
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

	incoming:setPosition(UDim2.fromScale(0.5, -0.5))

	local tweenIn = incoming:tween(duration, self._easingStyle, Enum.EasingDirection.Out):toPosition(UDim2.fromScale(0.5, 0.5))
	tweenIn:onComplete(finalize):play()
end

return TransitionMoveIn
