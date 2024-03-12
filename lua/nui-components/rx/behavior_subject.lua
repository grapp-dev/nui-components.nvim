local Observer = require("nui-components.rx.observer")
local Subject = require("nui-components.rx.subject")
local fn = require("nui-components.utils.fn")

local BehaviorSubject = setmetatable({}, Subject)

BehaviorSubject.__index = BehaviorSubject
BehaviorSubject.__tostring = fn.always("BehaviorSubject")

function BehaviorSubject.create(...)
  local self = {
    observers = {},
    stopped = false,
  }

  if select("#", ...) > 0 then
    self.value = fn.pack(...)
  end

  return setmetatable(self, BehaviorSubject)
end

function BehaviorSubject:subscribe(on_next, on_error, on_completed)
  local observer

  if fn.isa(on_next, Observer) then
    observer = on_next
  else
    observer = Observer.create(on_next, on_error, on_completed)
  end

  local subscription = Subject.subscribe(self, observer)

  if self.value then
    observer:on_next(fn.unpack(self.value))
  end

  return subscription
end

function BehaviorSubject:on_next(...)
  self.value = fn.pack(...)
  return Subject.on_next(self, ...)
end

function BehaviorSubject:get_value()
  if self.value ~= nil then
    return fn.unpack(self.value)
  end
end

BehaviorSubject.__call = BehaviorSubject.on_next

return BehaviorSubject
