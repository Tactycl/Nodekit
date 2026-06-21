const callFnThroughTreeAndSelf = require("./callFnThroughTreeAndSelf")

return function(self)
	callFnThroughTreeAndSelf(self, "onExitTransitionDidStart", function(n)
		if n._setExitingTransition then
			n:_setExitingTransition(true)
		else
			n._isTransitioning = true
		end
	end)
end
