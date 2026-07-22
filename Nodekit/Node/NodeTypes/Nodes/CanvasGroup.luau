const VirtualCorners = require("../Virtuals/Corners")
const VirtualScale = require("../Virtuals/Scale")
const VirtualPadding = require("../Virtuals/Padding")
const VirtualAspectRatio = require("../Virtuals/AspectRatio")
const VirtualFlexItem = require("../Virtuals/FlexItem")
const VirtualGradient = require("../Virtuals/Gradient")
const VirtualSizeConstraint = require("../Virtuals/SizeConstraint")
const VirtualListLayout = require("../Virtuals/ListLayout")
const VirtualGridLayout = require("../Virtuals/GridLayout")
const VirtualStroke = require("../Virtuals/Stroke")

const onPointerEvent = require("../Funcs/onPointerEvent")

local CanvasGroup = {}

CanvasGroup.rblxClass = "CanvasGroup"
CanvasGroup.initParams = {}

CanvasGroup.create = function(self)
	self._instance.BackgroundColor3 = Color3.new(1, 1, 1)
	self._instance.BorderSizePixel = 0
	self._instance.BorderColor3 = Color3.new(0, 0, 0)
end

CanvasGroup.properties = {
	readable = {
		"GroupColor3",
		"GroupTransparency",
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
		"GuiState",
		"Interactable",
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
		"GroupColor3",
		"GroupTransparency",
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
		"Interactable",
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

		{ name = "ListLayoutEnabled", fn = VirtualListLayout.getVirtualEnabled },
		{ name = "ListFillDirection", fn = VirtualListLayout.getVirtualFillDirection },
		{ name = "ListHorizontalAlignment", fn = VirtualListLayout.getVirtualHorizontalAlignment },
		{ name = "ListHorizontalFlex", fn = VirtualListLayout.getVirtualHorizontalFlex },
		{ name = "ListItemLineAlignment", fn = VirtualListLayout.getVirtualItemLineAlignment },
		{ name = "ListPadding", fn = VirtualListLayout.getVirtualPadding },
		{ name = "ListVerticalAlignment", fn = VirtualListLayout.getVirtualVerticalAlignment },
		{ name = "ListVerticalFlex", fn = VirtualListLayout.getVirtualVerticalFlex },
		{ name = "ListWraps", fn = VirtualListLayout.getVirtualWraps },
		{ name = "ListAbsoluteContentSize", fn = VirtualListLayout.getVirtualAbsoluteContentSize },

		{ name = "GridLayoutEnabled", fn = VirtualGridLayout.getVirtualEnabled },
		{ name = "GridCellSize", fn = VirtualGridLayout.getVirtualCellSize },
		{ name = "GridCellPadding", fn = VirtualGridLayout.getVirtualCellPadding },
		{ name = "GridFillDirection", fn = VirtualGridLayout.getVirtualFillDirection },
		{ name = "GridFillDirectionMaxCells", fn = VirtualGridLayout.getVirtualFillDirectionMaxCells },
		{ name = "GridHorizontalAlignment", fn = VirtualGridLayout.getVirtualHorizontalAlignment },
		{ name = "GridStartCorner", fn = VirtualGridLayout.getVirtualStartCorner },
		{ name = "GridVerticalAlignment", fn = VirtualGridLayout.getVirtualVerticalAlignment },
		{ name = "GridAbsoluteCellCount", fn = VirtualGridLayout.getVirtualAbsoluteCellCount },
		{ name = "GridAbsoluteCellSize", fn = VirtualGridLayout.getVirtualAbsoluteCellSize },
		{ name = "GridAbsoluteContentSize", fn = VirtualGridLayout.getVirtualAbsoluteContentSize },

		{ name = "StrokeEnabled", fn = VirtualStroke.setVirtualEnabled },
		{ name = "StrokeApplyMode", fn = VirtualStroke.setVirtualApplyMode },
		{ name = "StrokeBorderOffset", fn = VirtualStroke.setVirtualBorderOffset },
		{ name = "StrokeBorderPosition", fn = VirtualStroke.setVirtualBorderPosition },
		{ name = "StrokeColor", fn = VirtualStroke.setVirtualColor },
		{ name = "StrokeLineJoinMode", fn = VirtualStroke.setVirtualLineJoinMode },
		{ name = "StrokeSizingMode", fn = VirtualStroke.setVirtualSizingMode },
		{ name = "StrokeThickness", fn = VirtualStroke.setVirtualThickness },
		{ name = "StrokeTransparency", fn = VirtualStroke.setVirtualTransparency },
	},
	virtualWriteable = {
		{ name = "CornerRadius", fn = VirtualCorners.setVirtual },

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

		{ name = "ListLayoutEnabled", fn = VirtualListLayout.setVirtualEnabled },
		{ name = "ListFillDirection", fn = VirtualListLayout.setVirtualFillDirection },
		{ name = "ListHorizontalAlignment", fn = VirtualListLayout.setVirtualHorizontalAlignment },
		{ name = "ListHorizontalFlex", fn = VirtualListLayout.setVirtualHorizontalFlex },
		{ name = "ListItemLineAlignment", fn = VirtualListLayout.setVirtualItemLineAlignment },
		{ name = "ListPadding", fn = VirtualListLayout.setVirtualPadding },
		{ name = "ListVerticalAlignment", fn = VirtualListLayout.setVirtualVerticalAlignment },
		{ name = "ListVerticalFlex", fn = VirtualListLayout.setVirtualVerticalFlex },
		{ name = "ListWraps", fn = VirtualListLayout.setVirtualWraps },

		{ name = "GridLayoutEnabled", fn = VirtualGridLayout.setVirtualEnabled },
		{ name = "GridCellSize", fn = VirtualGridLayout.setVirtualCellSize },
		{ name = "GridCellPadding", fn = VirtualGridLayout.setVirtualCellPadding },
		{ name = "GridFillDirection", fn = VirtualGridLayout.setVirtualFillDirection },
		{ name = "GridFillDirectionMaxCells", fn = VirtualGridLayout.setVirtualFillDirectionMaxCells },
		{ name = "GridHorizontalAlignment", fn = VirtualGridLayout.setVirtualHorizontalAlignment },
		{ name = "GridStartCorner", fn = VirtualGridLayout.setVirtualStartCorner },
		{ name = "GridVerticalAlignment", fn = VirtualGridLayout.setVirtualVerticalAlignment },

		{ name = "StrokeEnabled", fn = VirtualStroke.getVirtualEnabled },
		{ name = "StrokeApplyMode", fn = VirtualStroke.getVirtualApplyMode },
		{ name = "StrokeBorderOffset", fn = VirtualStroke.getVirtualBorderOffset },
		{ name = "StrokeBorderPosition", fn = VirtualStroke.getVirtualBorderPosition },
		{ name = "StrokeColor", fn = VirtualStroke.getVirtualColor },
		{ name = "StrokeLineJoinMode", fn = VirtualStroke.getVirtualLineJoinMode },
		{ name = "StrokeSizingMode", fn = VirtualStroke.getVirtualSizingMode },
		{ name = "StrokeThickness", fn = VirtualStroke.getVirtualThickness },
		{ name = "StrokeTransparency", fn = VirtualStroke.getVirtualTransparency },
	},
}

CanvasGroup.funcs = {
	_onPointerEvent = onPointerEvent,
}

return CanvasGroup
