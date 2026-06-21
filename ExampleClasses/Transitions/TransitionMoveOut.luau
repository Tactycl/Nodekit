const ReplicatedStorage = game:GetService("ReplicatedStorage")

const Nodekit = require(ReplicatedStorage.Packages.Nodekit)

const Transition = Nodekit.Transition

local TransitionMoveOut = Transition:inherit()

export type TransitionMoveOutOptions = {
	easingStyle: Nodekit.TweenEasingStyle?,
}

function TransitionMoveOut:create(opts: TransitionMoveOutOptions?)
	local inst = setmetatable(Transition:create(), TransitionMoveOut)
	inst._easingStyle = opts and opts.easingStyle or Enum.EasingStyle.Linear
	return inst
end

function TransitionMoveOut:run(duration: number, incoming: any, outgoing: any, finish: () -> ())
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

	local tweenOut = outgoing:tween(duration, self._easingStyle, Enum.EasingDirection.In):toPosition(UDim2.fromScale(0.5, -0.5))
	tweenOut:onComplete(finalize):play()
end

return TransitionMoveOut
