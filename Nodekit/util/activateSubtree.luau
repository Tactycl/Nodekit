const callFnThroughTreeAndSelf = require("./callFnThroughTreeAndSelf")

return function(self)
	callFnThroughTreeAndSelf(self, "onActivated")
end
