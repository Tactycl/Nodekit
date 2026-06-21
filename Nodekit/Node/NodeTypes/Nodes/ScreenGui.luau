const VirtualScale = require("../Virtuals/Scale")
const VirtualPadding = require("../Virtuals/Padding")

local ScreenGui = {}

ScreenGui.rblxClass = "ScreenGui"
ScreenGui.initParams = {}

ScreenGui.properties = {
	readable = {
		"ClipToDeviceSafeArea",
		"SafeAreaCompatibility",
		"ScreenInsets",
		"AbsolutePosition",
		"AbsoluteRotation",
		"AbsoluteSize",
		"Enabled",
		"IgnoreGuiInset",
		"ResetOnSpawn",
		"ZIndexBehavior",
		"AutoLocalize",
		"RootLocalizationTable",
		"SelectionGroup",
	},
	writeable = {
		"ClipToDeviceSafeArea",
		"SafeAreaCompatibility",
		"ScreenInsets",
		"Enabled",
		"IgnoreGuiInset",
		"ResetOnSpawn",
		"ZIndexBehavior",
		"AutoLocalize",
		"RootLocalizationTable",
		"SelectionGroup",
	},

	virtualReadable = {
		{ name = "Scale", fn = VirtualScale.getVirtual },
		{ name = "PaddingLeft", fn = VirtualPadding.getVirtualLeft },
		{ name = "PaddingRight", fn = VirtualPadding.getVirtualRight },
		{ name = "PaddingTop", fn = VirtualPadding.getVirtualTop },
		{ name = "PaddingBottom", fn = VirtualPadding.getVirtualBottom },
	},
	virtualWriteable = {
		{ name = "Scale", fn = VirtualScale.setVirtual },
		{ name = "PaddingLeft", fn = VirtualPadding.setVirtualLeft },
		{ name = "PaddingRight", fn = VirtualPadding.setVirtualRight },
		{ name = "PaddingTop", fn = VirtualPadding.setVirtualTop },
		{ name = "PaddingBottom", fn = VirtualPadding.setVirtualBottom },
		{ name = "PaddingHorizontal", fn = VirtualPadding.setVirtualHorizontal },
		{ name = "PaddingVertical", fn = VirtualPadding.setVirtualVertical },
		{ name = "Padding", fn = VirtualPadding.setVirtualAll },
	},
}

return ScreenGui
