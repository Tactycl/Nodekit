--!strict

type DefaultEventTypes = 
	"PointerMoved" | "PointerLeave" | "PointerEnter" | "PointerMoved" | "PointerWheel" |
	"PointerBegan" | "PointerChanged" | "PointerEnded" | "PointerClick" |
	"InputBegan" | "InputChanged" | "InputEnded"

export type EventType = DefaultEventTypes | string
export type EventPayload = {[any]: any}

export type Event = {
	type: EventType,
	payload: EventPayload,
	_isConsumed: boolean,

	create: (self: any, type: EventType, payload: EventPayload) -> (Event),
	consume: (self: Event) -> (Event),
	isConsumed: (self: Event) -> (boolean),
}

local Event = {}
Event.__index = Event

function Event:create(type: EventType, payload: EventPayload): Event
	local inst = setmetatable({}, Event)

	inst.type = type
	inst.payload = payload
	inst._isConsumed = false

	return (inst:: unknown):: Event
end

function Event:consume(): Event
	self._isConsumed = true
	return self
end

function Event:isConsumed(): boolean
	return self._isConsumed == true
end

return Event
