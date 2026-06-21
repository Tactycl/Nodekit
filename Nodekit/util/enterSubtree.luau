const callFnThroughTreeAndSelf = require("./callFnThroughTreeAndSelf")

return function(self)
	callFnThroughTreeAndSelf(self, "onEnter", function(n)
		if n._setRunning then
			n:_setRunning(true)
		else
			n._isRunning = true
		end
	end)
end
