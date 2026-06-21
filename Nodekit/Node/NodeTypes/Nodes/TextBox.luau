const safeCall = require("../../../util/safeCall")

const VirtualCorners = require("../Virtuals/Corners")
const VirtualTextSize = require("../Virtuals/TextSize")
const VirtualScale = require("../Virtuals/Scale")
const VirtualPadding = require("../Virtuals/Padding")
const VirtualAspectRatio = require("../Virtuals/AspectRatio")
const VirtualFlexItem = require("../Virtuals/FlexItem")
const VirtualGradient = require("../Virtuals/Gradient")
const VirtualSizeConstraint = require("../Virtuals/SizeConstraint")

const onPointerEvent = require("../Funcs/onPointerEvent")
const onAbsoluteSizeChanged = require("../Funcs/onAbsoluteSizeChanged")

local TextBox = {}

TextBox.rblxClass = "TextBox"
TextBox.initParams = { "Text" }

TextBox.create = function(self)
	self._instance.Interactable = false
	self._instance.ClearTextOnFocus = false
	self._instance.Text = ""
	self._instance.BackgroundColor3 = Color3.new(1, 1, 1)
	self._instance.BorderSizePixel = 0
	self._instance.BorderColor3 = Color3.new(0, 0, 0)
	self._instance.TextColor3 = Color3.new(0, 0, 0)
	self._instance.PlaceholderColor3 = Color3.new(0, 0, 0)

	self._instance.FocusLost:Connect(function()
		safeCall(self, "onFocusLost")
	end)

	self._instance.Focused:Connect(function()
		safeCall(self, "onFocused")
	end)
end

TextBox.properties = {
	readable = {
		"ClearTextOnFocus",
		"ContentText",
		"CursorPosition",
		"Font",
		"FontFace",
		"LineHeight",
		"MaxVisibleGraphemes",
		"MultiLine",
		"OpenTypeFeatures",
		"OpenTypeFeaturesError",
		"PlaceholderColor3",
		"PlaceholderText",
		"RichText",
		"SelectionStart",
		"ShowNativeInput",
		"Text",
		"TextBounds",
		"TextColor",
		"TextColor3",
		"TextDirection",
		"TextEditable",
		"TextFits",
		"TextScaled",
		"TextSize",
		"TextStrokeColor3",
		"TextStrokeTransparency",
		"TextTransparency",
		"TextTruncate",
		"TextWrapped",
		"TextXAlignment",
		"TextYAlignment",
		"Active",
		"AnchorPoint",
		"AutomaticSize",
		"BackgroundColor",
		"BackgroundColor3",
		"BackgroundTransparency",
		"BorderColor",
		"BorderColor3",
		"BorderMode",
		"BorderSizePixel",
		"ClipsDescendants",
		"GuiState",
		"NextSelectionDown",
		"NextSelectionLeft",
		"NextSelectionRight",
		"NextSelectionUp",
		"Position",
		"Rotation",
		"Selectable",
		"SelectionImageObject",
		"SelectionOrder",
		"Size",
		"SizeConstraint",
		"Transparency",
		"Visible",
		"AbsolutePosition",
		"AbsoluteRotation",
		"AbsoluteSize",
		"AutoLocalize",
		"RootLocalizationTable",
		"SelectionBehaviorDown",
		"SelectionBehaviorLeft",
		"SelectionBehaviorRight",
		"SelectionBehaviorUp",
		"SelectionGroup",
	},
	writeable = {
		"ClearTextOnFocus",
		"CursorPosition",
		"Font",
		"FontFace",
		"LineHeight",
		"MaxVisibleGraphemes",
		"MultiLine",
		"OpenTypeFeatures",
		"PlaceholderColor3",
		"PlaceholderText",
		"RichText",
		"SelectionStart",
		"ShowNativeInput",
		"Text",
		"TextColor",
		"TextColor3",
		"TextDirection",
		"TextEditable",
		"TextScaled",
		"TextSize",
		"TextStrokeColor3",
		"TextStrokeTransparency",
		"TextTransparency",
		"TextTruncate",
		"TextWrapped",
		"TextXAlignment",
		"TextYAlignment",
		"Active",
		"AnchorPoint",
		"AutomaticSize",
		"BackgroundColor",
		"BackgroundColor3",
		"BackgroundTransparency",
		"BorderColor",
		"BorderColor3",
		"BorderMode",
		"BorderSizePixel",
		"ClipsDescendants",
		"NextSelectionDown",
		"NextSelectionLeft",
		"NextSelectionRight",
		"NextSelectionUp",
		"Position",
		"Rotation",
		"Selectable",
		"SelectionImageObject",
		"SelectionOrder",
		"Size",
		"SizeConstraint",
		"Transparency",
		"Visible",
		"AutoLocalize",
		"RootLocalizationTable",
		"SelectionBehaviorDown",
		"SelectionBehaviorLeft",
		"SelectionBehaviorRight",
		"SelectionBehaviorUp",
		"SelectionGroup",
	},

	virtualReadable = {
		{ name = "CornerRadius", fn = VirtualCorners.getVirtual },

		{ name = "MaxTextSize", fn = VirtualTextSize.getVirtualMax },
		{ name = "MinTextSize", fn = VirtualTextSize.getVirtualMin },

		{ name = "Scale", fn = VirtualScale.getVirtual },

		{ name = "PaddingLeft", fn = VirtualPadding.getVirtualLeft },
		{ name = "PaddingRight", fn = VirtualPadding.getVirtualRight },
		{ name = "PaddingTop", fn = VirtualPadding.getVirtualTop },
		{ name = "PaddingBottom", fn = VirtualPadding.getVirtualBottom },
		
		{ name = "AspectRatioEnabled", fn = VirtualAspectRatio.getVirtualEnabled },
		{ name = "AspectRatio", fn = VirtualAspectRatio.getVirtualAspectRatio },
		{ name = "AspectRatioType", fn = VirtualAspectRatio.getVirtualAspectType },
		{ name = "AspectRatioDominantAxis", fn = VirtualAspectRatio.getVirtualDominantAxis },

		{ name = "FlexItemEnabled", fn = VirtualFlexItem.getVirtualEnabled },
		{ name = "FlexMode", fn = VirtualFlexItem.getVirtualFlexMode },
		{ name = "FlexItemLineAlignment", fn = VirtualFlexItem.getVirtualItemLineAlignment },

		{ name = "GradientEnabled", fn = VirtualGradient.getVirtualEnabled },
		{ name = "GradientColor", fn = VirtualGradient.getVirtualColor },
		{ name = "GradientTransparency", fn = VirtualGradient.getVirtualTransparency },
		{ name = "GradientOffset", fn = VirtualGradient.getVirtualOffset },
		{ name = "GradientRotation", fn = VirtualGradient.getVirtualRotation },

		{ name = "MinSize", fn = VirtualSizeConstraint.getVirtualMinSize },
		{ name = "MaxSize", fn = VirtualSizeConstraint.getVirtualMaxSize },
	},
	virtualWriteable = {
		{ name = "CornerRadius", fn = VirtualCorners.setVirtual },

		{ name = "MaxTextSize", fn = VirtualTextSize.setVirtualMax },
		{ name = "MinTextSize", fn = VirtualTextSize.setVirtualMin },

		{ name = "Scale", fn = VirtualScale.setVirtual },

		{ name = "PaddingLeft", fn = VirtualPadding.setVirtualLeft },
		{ name = "PaddingRight", fn = VirtualPadding.setVirtualRight },
		{ name = "PaddingTop", fn = VirtualPadding.setVirtualTop },
		{ name = "PaddingBottom", fn = VirtualPadding.setVirtualBottom },
		{ name = "PaddingHorizontal", fn = VirtualPadding.setVirtualHorizontal },
		{ name = "PaddingVertical", fn = VirtualPadding.setVirtualVertical },
		{ name = "Padding", fn = VirtualPadding.setVirtualAll },
		
		{ name = "AspectRatioEnabled", fn = VirtualAspectRatio.setVirtualEnabled },
		{ name = "AspectRatio", fn = VirtualAspectRatio.setVirtualAspectRatio },
		{ name = "AspectRatioType", fn = VirtualAspectRatio.setVirtualAspectType },
		{ name = "AspectRatioDominantAxis", fn = VirtualAspectRatio.setVirtualDominantAxis },

		{ name = "FlexItemEnabled", fn = VirtualFlexItem.setVirtualEnabled },
		{ name = "FlexMode", fn = VirtualFlexItem.setVirtualFlexMode },
		{ name = "FlexItemLineAlignment", fn = VirtualFlexItem.setVirtualItemLineAlignment },

		{ name = "GradientEnabled", fn = VirtualGradient.setVirtualEnabled },
		{ name = "GradientColor", fn = VirtualGradient.setVirtualColor },
		{ name = "GradientTransparency", fn = VirtualGradient.setVirtualTransparency },
		{ name = "GradientOffset", fn = VirtualGradient.setVirtualOffset },
		{ name = "GradientRotation", fn = VirtualGradient.setVirtualRotation },

		{ name = "MinSize", fn = VirtualSizeConstraint.setVirtualMinSize },
		{ name = "MaxSize", fn = VirtualSizeConstraint.setVirtualMaxSize },
	},
}

TextBox.funcs = {
	_onPointerEvent = onPointerEvent,
	_onAbsoluteSizeChanged = onAbsoluteSizeChanged,

	captureFocus = function(self)
		local inst = self._instance
		if inst then
			inst.Interactable = true
			inst:CaptureFocus()
		end
		safeCall(self, "onFocused")
	end,

	releaseFocus = function(self)
		local inst = self._instance
		if inst then
			inst:ReleaseFocus()
			inst.Interactable = false
		end
		safeCall(self, "onFocusLost")
	end,

	isFocused = function(self)
		local inst = self._instance
		return inst and inst:IsFocused() == true
	end,
}

return TextBox
