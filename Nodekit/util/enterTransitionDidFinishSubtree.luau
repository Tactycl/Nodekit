const callFnThroughTreeAndSelf = require("./callFnThroughTreeAndSelf")

return function(self)
	callFnThroughTreeAndSelf(self, "onEnterTransitionDidFinish", function(n)
		if n._setEnteringTransition then
			n:_setEnteringTransition(false)
		else
			n._isTransitioning = false
		end
	end)
end
