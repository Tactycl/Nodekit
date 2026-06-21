const callFnThroughTreeAndSelf = require("./callFnThroughTreeAndSelf")

return function(self)
	callFnThroughTreeAndSelf(self, "onExit", function(n)
		if n._setRunning then
			n:_setRunning(false)
		else
			n._isRunning = false
			n._isTransitioning = false
		end
	end)
end
