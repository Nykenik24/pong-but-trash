---@class event_system
local event = { buffers = {} }
local buffer_methods = {}

---Create new buffer
---@param name string
---@return event_buffer
function event:newBuffer(name)
	---@class event_buffer
	self.buffers[name] = {
		event_types = {},
		addEvent = buffer_methods.addEvent,
		execEvent = buffer_methods.execEvent,
		newEventType = buffer_methods.newEventType,
		removeEvent = buffer_methods.removeEvent,
		popEvent = buffer_methods.popEvent,
		buffer = {},
	}
	return self.buffers[name]
end

---Get a buffer from the buffer list.
---@param name string
---@return event_buffer
function event:getBuffer(name)
	return self.buffers[name]
end

---Get events from a buffer.
---@param name string
---@return event_buffer
function event:getEvents(name)
	return self.buffers[name].buffer
end

---Add an event to a buffer.
---@param self event_buffer
---@param id string
---@return event_buffer
function buffer_methods.addEvent(self, id)
	table.insert(self.buffer, 1, id)
	return self
end

---Remove an event from a buffer.
---@param self event_buffer
---@param pos integer
---@return event_buffer
function buffer_methods.removeEvent(self, pos)
	table.remove(self.buffer, pos)
	return self
end

---Execute an event.
---@param self event_buffer
---@param id string
---@return event_buffer
function buffer_methods.execEvent(self, id)
	local types = self.event_types

	types[id]()

	return self
end

---Create an event type.
---@param self event_buffer
---@param id string
---@param func function
---@return event_buffer
function buffer_methods.newEventType(self, id, func)
	self.event_types[id] = func
	return self
end

---Execute and remove the last event from a buffer.
---@param self event_buffer
---@return event_buffer
function buffer_methods.popEvent(self)
	if #self.buffer == 0 then
		print("No events left in buffer!")
		return self
	end

	self:execEvent(self.buffer[#self.buffer])
	self:removeEvent(#self.buffer)
	return self
end

return event
