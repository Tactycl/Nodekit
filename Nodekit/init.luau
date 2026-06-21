const Director = require("@self/Director")
const Scene = require("@self/Scene")
const Layer = require("@self/Layer")
const Node = require("@self/Node")
const Event = require("@self/Event")
const EventDispatcher = require("@self/EventDispatcher")
const Transition = require("@self/Transition")

-- Forward types
export type TweenEasingStyle = Node.TweenEasingStyle

export type EventType = Event.EventType
export type EventPayload = Event.EventPayload
export type Event = Event.Event

return {
	Director = Director,
	Scene = Scene,
	Layer = Layer,
	Node = Node,
	Event = Event,
	EventDispatcher = EventDispatcher,
	Transition = Transition,
}
