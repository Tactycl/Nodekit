# NodeKit

**A Cocos2d-x-inspired UI DSL for Roblox.**

NodeKit is an imperative, game-engine-style UI framework for Roblox. It wraps Roblox GUI objects in a structured node tree and adds fluent properties, scenes, layers, transitions, lifecycle hooks, actions, tweens, and centralized input handling.

Instead of treating your UI as a collection of unrelated `Instance`s, NodeKit gives it a consistent runtime model:

```text
Director
└── Scene
    └── Layer
        ├── Node
        ├── Node
        └── Node
```

If you like the scene graph and action-oriented style of frameworks such as Cocos2d-x, NodeKit is designed to provide a similar workflow while still using Roblox's native UI system underneath.

> [!IMPORTANT]
> NodeKit is currently under active development. APIs may change as the framework matures.

## Features

* **Fluent UI construction** with chainable `set<Property>()` / `get<Property>()` methods
* **Scene management** with push, pop, replace, and transition-aware navigation
* **Layers** with update scheduling, pause/resume behavior, and event blocking
* **Node tree management** with IDs, types, tags, attributes, child queries, and lifecycle hooks
* **Virtual properties** for common Roblox UI helpers such as corners, padding, scale, gradients, strokes, layouts, constraints, and more
* **Custom tween system** that can animate both native and virtual NodeKit properties
* **Composable actions** with delays, callbacks, sequences, and parallel execution
* **Centralized input dispatch** for pointer, click, touch, mouse, and general input events
* **Extensible classes** through NodeKit's inheritance/delegation model
* **Custom transitions** built using the same public NodeKit primitives as the rest of your UI

## Quick Look

```luau
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local NodeKit = require(ReplicatedStorage.Packages.Nodekit)

local Director = NodeKit.Director
local Scene = NodeKit.Scene
local Layer = NodeKit.Layer
local Node = NodeKit.Node

local director = Director:init()

local scene = Scene:create("MainScene")
local layer = Layer:create("MainLayer")

local card = Node.Frame:create()
    :setId("Card")
    :setSize(UDim2.fromOffset(420, 180))
    :setPosition(UDim2.fromScale(0.5, 0.5))
    :setAnchorPoint(Vector2.new(0.5, 0.5))
    :setBackgroundColor3(Color3.fromRGB(30, 32, 38))
    :setCornerRadius(UDim.new(0, 16))
    :setPadding(UDim.new(0, 20))

local title = Node.Label:create("Hello from NodeKit")
    :setSize(UDim2.fromScale(1, 1))
    :setBackgroundTransparency(1)
    :setTextColor3(Color3.new(1, 1, 1))
    :setTextScaled(true)

card:addChild(title)
layer:addChild(card)
scene:addChild(layer)

director:runWithScene(scene)
```

The underlying UI is still Roblox UI. NodeKit provides the higher-level structure and behavior around it.

## Installation

NodeKit is currently distributed directly through this repository.

1. Clone or download the repository.
2. Place or sync the `Nodekit` module tree into your Roblox project.
3. Require the root `Nodekit` module from your client code.

The examples in this repository assume a structure similar to:

```text
ReplicatedStorage
└── Packages
    └── Nodekit
```

and therefore use:

```luau
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local NodeKit = require(ReplicatedStorage.Packages.Nodekit)
```

If you place NodeKit elsewhere, adjust the require path accordingly.

> [!NOTE]
> NodeKit is a client-side UI framework. The `Director` manages UI through the local player's `PlayerGui`.

## Core Model

### Director

The `Director` is the top-level controller for NodeKit's UI runtime.

It owns the root UI tree and manages the currently running scene and scene stack.

```luau
local director = NodeKit.Director:init()

director:runWithScene(scene)
director:pushScene(otherScene)
director:popScene()
director:replaceScene(nextScene)
```

You can inspect the current state as well:

```luau
local runningScene = director:getRunningScene()
local nextScene = director:getNextScene()
local sceneCount = director:getNumberOfRunningScenes()

local winSize = director:getWinSize()
local absoluteWinSize = director:getAbsoluteWinSize()
```

`Director:init()` is singleton-oriented. Use `Director:getInstance()` to access the active instance and `Director:destroyInstance()` when you need to tear it down.

### Scene

A `Scene` represents a top-level UI state such as:

* Main menu
* Inventory
* Store
* Settings
* Match HUD
* Loading screen

```luau
local scene = NodeKit.Scene:create("InventoryScene")
```

Scenes are managed through the `Director` rather than being manually attached to `PlayerGui`.

### Layer

A `Layer` is a logical subdivision inside a scene.

```luau
local backgroundLayer = NodeKit.Layer:create("Background")
local contentLayer = NodeKit.Layer:create("Content")
local modalLayer = NodeKit.Layer:create("Modal")

scene:add(
    backgroundLayer,
    contentLayer,
    modalLayer
)
```

Layers can also participate in frame updates:

```luau
local layer = NodeKit.Layer:create("AnimatedLayer")

function layer:update(dt)
    -- Called every Heartbeat while scheduled and running.
end

layer:scheduleUpdate()
```

Updates can be controlled at runtime:

```luau
layer:pause()
layer:resume()
layer:unscheduleUpdate()
```

Layers can additionally block event propagation to lower layers:

```luau
modalLayer:setBlocksEventsBelow(true)
```

This is useful for modal dialogs, pause menus, overlays, and similar UI states.

### Node

`Node` is the base abstraction for UI elements.

NodeKit currently includes these built-in node types:

| NodeKit type          | Roblox UI class  |
| --------------------- | ---------------- |
| `Node.Frame`          | `Frame`          |
| `Node.Label`          | `TextLabel`      |
| `Node.Button`         | `TextButton`     |
| `Node.Image`          | `ImageLabel`     |
| `Node.ImageButton`    | `ImageButton`    |
| `Node.TextBox`        | `TextBox`        |
| `Node.ScrollingFrame` | `ScrollingFrame` |
| `Node.CanvasGroup`    | `CanvasGroup`    |
| `Node.ScreenGui`      | `ScreenGui`      |

Creation is intentionally concise:

```luau
local frame = NodeKit.Node.Frame:create()

local label = NodeKit.Node.Label:create("NodeKit")

local button = NodeKit.Node.Button:create("Continue")

local image = NodeKit.Node.Image:create("rbxassetid://...")
```

## Fluent Properties

NodeKit maps supported Roblox properties into dynamic getters and setters.

Instead of:

```luau
local frame = Instance.new("Frame")
frame.Size = UDim2.fromOffset(300, 120)
frame.Position = UDim2.fromScale(0.5, 0.5)
frame.AnchorPoint = Vector2.new(0.5, 0.5)
frame.BackgroundTransparency = 0.2
```

you can write:

```luau
local frame = Node.Frame:create()
    :setSize(UDim2.fromOffset(300, 120))
    :setPosition(UDim2.fromScale(0.5, 0.5))
    :setAnchorPoint(Vector2.new(0.5, 0.5))
    :setBackgroundTransparency(0.2)
```

Readable properties use the same convention:

```luau
local size = frame:getSize()
local position = frame:getPosition()
local transparency = frame:getBackgroundTransparency()
```

Setters return the node, so configuration can remain fluent.

NodeKit also validates supported native property assignments and reports invalid property names or mismatched value types instead of silently accepting invalid calls.

## Virtual Properties

A major goal of NodeKit is to hide repetitive Roblox UI plumbing without hiding Roblox itself.

Many features that normally require helper instances are exposed as properties directly on a node.

For example:

```luau
local panel = Node.Frame:create()
    :setCornerRadius(UDim.new(0, 12))
    :setPadding(UDim.new(0, 16))
    :setScale(1)
    :setGradientEnabled(true)
    :setStrokeEnabled(true)
    :setStrokeThickness(2)
```

Depending on the node type, virtual properties include concepts such as:

* Corner radius
* UI scale
* Padding
* Aspect ratio
* Flex item behavior
* Gradients
* Size constraints
* List layouts
* Grid layouts
* Strokes
* Text-size constraints

This keeps common UI composition declarative while NodeKit manages the supporting Roblox UI objects internally.

## Node Trees

Nodes form a managed hierarchy.

```luau
local root = Node.Frame:create()
local header = Node.Frame:create():setId("Header")
local body = Node.Frame:create():setId("Body")

root:add(header, body)
```

Or add one child at a specific ordering position:

```luau
root:addChild(header)
root:addChild(body, 0)
```

Common tree operations include:

```luau
root:getParent()
root:getChildren()
root:getDescendants()

root:getChildById("Header")
root:getChildByType("Frame")
root:getChildrenByType("Button")
root:getDescendantsByType("Label")

root:querySelector("Header Body")
```

Nodes can also carry NodeKit IDs and types:

```luau
node:setId("InventoryItem")
node:addType("Interactive")
node:addType("Draggable")

print(node:getId())
print(node:getType())
print(node:isA("Interactive"))
```

## Tags and Attributes

NodeKit integrates node-level metadata with Roblox.

```luau
node:addTag("Inventory")
node:addTag("Interactive")

node:setAttribute("ItemId", "sword_01")
node:setAttribute("Selected", false)
```

Read them back through NodeKit:

```luau
if node:hasTag("Interactive") then
    print(node:getAttribute("ItemId"))
end
```

## Tweens

NodeKit includes its own tween abstraction.

Tween goals use the same property vocabulary as nodes:

```luau
local tween = panel:tween(
    0.25,
    Enum.EasingStyle.Quad,
    Enum.EasingDirection.Out
)
    :toPosition(UDim2.fromScale(0.5, 0.5))
    :toBackgroundTransparency(0)

tween:play()
```

Completion callbacks are chainable:

```luau
panel:tween(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    :toScale(1.05)
    :onComplete(function()
        print("Finished")
    end)
    :play()
```

Tweens support both native properties and compatible virtual properties.

Currently supported interpolation value types include:

* `number`
* `Color3`
* `Vector2`
* `UDim`
* `UDim2`

You can also provide a custom easing function:

```luau
local function easing(alpha, direction)
    return alpha * alpha
end

panel:tween(0.3, easing)
    :toScale(1.2)
    :play()
```

Tweens can be paused, resumed, cancelled, or stopped through the owning node.

## Actions

NodeKit provides small composable actions inspired by game-engine action systems.

### Delay

```luau
node:delay(0.5)
    :onComplete(function()
        print("Half a second passed")
    end)
    :play()
```

### Call

```luau
node:call(function()
    print("Called")
end):play()
```

### Sequence

```luau
node:sequence(
    node:tween(0.2):toScale(1.1),
    node:delay(0.1),
    node:tween(0.2):toScale(1),
    node:call(function()
        print("Sequence complete")
    end)
):play()
```

### Parallel

```luau
node:parallel(
    node:tween(0.25):toPosition(UDim2.fromScale(0.5, 0.5)),
    node:tween(0.25):toBackgroundTransparency(0)
):play()
```

Actions support completion callbacks and cancellation, and the node tracks active actions for cleanup.

## Input and Events

NodeKit includes an `EventDispatcher` for centralized user input handling.

Create and bind one after initializing the Director:

```luau
local Director = NodeKit.Director
local EventDispatcher = NodeKit.EventDispatcher

local director = Director:init()

local dispatcher = EventDispatcher:create(director)
    :bindUserInput()

director:setEventDispatcher(dispatcher)
```

Interactive nodes receive pointer events through callbacks.

For hit testing, make the GUI node active:

```luau
local button = Node.Button:create("Play")
    :setActive(true)

function button:onMouseEnter(payload)
    self:tween(0.1):toScale(1.05):play()
end

function button:onMouseLeave(payload)
    self:tween(0.1):toScale(1):play()
end

function button:onPress(payload)
    self:setScale(0.97)
end

function button:onRelease(payload)
    self:setScale(1)
end

function button:onClick(payload)
    print("Play clicked")
end
```

Pointer callbacks currently include:

```text
onMouseEnter
onMouseLeave
onMouseMoved
onMouseWheelForward
onMouseWheelBackward
onPress
onRelease
onClick
```

At the broader event level, NodeKit dispatches events such as:

```text
PointerEnter
PointerLeave
PointerMoved
PointerWheel
PointerBegan
PointerChanged
PointerEnded
PointerClick

InputBegan
InputChanged
InputEnded
```

Custom events can also use `NodeKit.Event`:

```luau
local event = NodeKit.Event:create("InventoryChanged", {
    itemId = "sword_01",
})

dispatcher:dispatch(event)
```

Events may be consumed to stop propagation:

```luau
event:consume()
```

## Scene Transitions

The Director supports scene operations with custom transitions:

```luau
director:replaceSceneWithTransition(
    0.4,
    transition,
    nextScene
)
```

The same pattern is available for push and pop navigation:

```luau
director:pushSceneWithTransition(0.4, transition, nextScene)
director:popSceneWithTransition(0.4, transition)
```

A transition implements:

```luau
transition:run(duration, incoming, outgoing, finish)
```

Call `finish()` when the transition has completed so the Director can finalize scene state.

The repository contains example transitions in [`ExampleClasses/Transitions`](./ExampleClasses/Transitions), including fade and movement-based transitions.

## Lifecycle

Nodes participate in a lifecycle as they enter and leave the active scene tree.

You can override or assign hooks such as:

```luau
function node:onActivated()
    print("Activated")
end

function node:onEnter()
    print("Entered running tree")
end

function node:onExit()
    print("Exited running tree")
end

function node:onEnterTransitionDidFinish()
    print("Transition in complete")
end

function node:onExitTransitionDidStart()
    print("Transition out started")
end

function node:onDestroyed()
    print("Destroyed")
end
```

Destruction is recursive and automatically cleans up children, active tweens, registration state, tags, attributes, and the underlying Roblox instance.

```luau
node:destroy()
```

## Custom Nodes

NodeKit is designed to be extended with application-specific UI classes.

```luau
local Node = NodeKit.Node

local Card = Node:inherit()

function Card:create()
    local instance = setmetatable(
        Node.Frame:create()
            :setCornerRadius(UDim.new(0, 12))
            :setPadding(UDim.new(0, 16)),
        Card
    )

    instance:addType("Card")

    return instance
end

function Card:setHighlighted(highlighted)
    self:setStrokeEnabled(highlighted)

    if highlighted then
        self:setStrokeThickness(2)
    end

    return self
end

return Card
```

Custom methods can follow the same fluent convention by returning `self`.

For a more complete example, see [`ExampleClasses/Nodes/FlippableImage.luau`](./ExampleClasses/Nodes/FlippableImage.luau).

## Custom Transitions

Transitions are extensible as well:

```luau
local Transition = NodeKit.Transition

local FadeTransition = Transition:inherit()

function FadeTransition:create()
    return setmetatable(Transition:create(), FadeTransition)
end

function FadeTransition:run(duration, incoming, outgoing, finish)
    local overlay = Node.Frame:create()
        :setSize(UDim2.fromScale(1, 1))
        :setBackgroundColor3(Color3.new(0, 0, 0))
        :setBackgroundTransparency(1)

    local parent = incoming:getParent()
    parent:addChild(overlay)

    overlay:tween(duration * 0.5)
        :toBackgroundTransparency(0)
        :onComplete(function()
            if outgoing then
                outgoing:setVisible(false)
            end

            incoming:setVisible(true)

            overlay:tween(duration * 0.5)
                :toBackgroundTransparency(1)
                :onComplete(function()
                    overlay:destroy()
                    finish()
                end)
                :play()
        end)
        :play()
end

return FadeTransition
```

See [`ExampleClasses/Transitions`](./ExampleClasses/Transitions) for working implementations.

## Error Diagnostics

NodeKit aims to make DSL mistakes fail clearly.

For example, using a property that does not exist:

```luau
frame:setPositoin(UDim2.fromScale(0.5, 0.5))
```

produces a NodeKit-specific property error instead of failing later as a generic nil call.

Native setter type mismatches are also validated:

```luau
frame:setSize(Vector2.new(100, 100))
```

will report that `Size` expects the type used by the underlying Roblox property.

Tween goals similarly validate whether a property is tweenable and whether its source and target value types are compatible.

## Design Philosophy

NodeKit is intentionally **imperative**.

It is not trying to replace Roblox UI with a React-style declarative renderer. Instead, it provides a scene graph and game-engine-oriented API over native Roblox UI.

The core ideas are:

1. **UI should have structure.** Scenes, layers, and nodes should communicate ownership and lifetime.
2. **Common operations should compose.** Setters, tweens, actions, and transitions should use a consistent vocabulary.
3. **Roblox plumbing should not dominate application code.** Common helper instances should be exposed as higher-level properties where practical.
4. **Extension should feel native.** Custom nodes and transitions should use the same APIs as built-in systems.
5. **Lifecycle should be explicit.** Entering, exiting, transitioning, pausing, and destruction should have defined behavior.

## Project Structure

```text
Nodekit/
├── Director.luau
├── Event.luau
├── EventDispatcher.luau
├── Layer.luau
├── Scene.luau
├── Transition.luau
├── init.luau
│
├── Node/
│   ├── Action.luau
│   ├── NodeRegistry.luau
│   ├── Tween.luau
│   ├── init.luau
│   └── NodeTypes/
│       ├── Funcs/
│       ├── Nodes/
│       └── Virtuals/
│
└── util/

ExampleClasses/
├── Nodes/
└── Transitions/
```

## Examples

Example extension classes are included in [`ExampleClasses`](./ExampleClasses):

* [`FlippableImage`](./ExampleClasses/Nodes/FlippableImage.luau)
* [`TransitionFade`](./ExampleClasses/Transitions/TransitionFade.luau)
* [`TransitionMoveIn`](./ExampleClasses/Transitions/TransitionMoveIn.luau)
* [`TransitionMoveOut`](./ExampleClasses/Transitions/TransitionMoveOut.luau)

## Current Status

NodeKit is still evolving.

The core architecture is in place, but additional work is expected around API hardening, type tooling, validation, performance profiling, documentation, and broader production testing.

If you use NodeKit in a project and encounter an issue, open a GitHub issue with a minimal reproduction when possible.

## Contributing

Issues, bug reports, design feedback, and pull requests are welcome.

When proposing an API change, try to preserve NodeKit's core goals:

* Fluent and predictable call sites
* Clear scene/node ownership
* Cocos2d-x-inspired game-engine semantics
* Strong interoperability with Roblox UI
* Minimal framework-specific ceremony in application code

---

**NodeKit** - structured Roblox UI with a game-engine mindset.
