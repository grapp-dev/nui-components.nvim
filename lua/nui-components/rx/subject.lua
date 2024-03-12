local Observable = require("nui-components.rx.observable")
local Observer = require("nui-components.rx.observer")
local Subscription = require("nui-components.rx.subscription")
local fn = require("nui-components.utils.fn")

local Subject = setmetatable({}, Observable)

Subject.__index = Subject
Subject.__tostring = fn.always("Subject")

function Subject.create()
  local self = {
    observers = {},
    stopped = false,
  }

  return setmetatable(self, Subject)
end

function Subject:subscribe(on_next, on_error, on_completed)
  local observer

  if fn.isa(on_next, Observer) then
    observer = on_next
  else
    observer = Observer.create(on_next, on_error, on_completed)
  end

  table.insert(self.observers, observer)

  return Subscription.create(function()
    for i = 1, #self.observers do
      if self.observers[i] == observer then
        table.remove(self.observers, i)
        return
      end
    end
  end)
end

function Subject:on_next(...)
  if not self.stopped then
    for i = #self.observers, 1, -1 do
      self.observers[i]:on_next(...)
    end
  end
end

function Subject:on_error(message)
  if not self.stopped then
    for i = #self.observers, 1, -1 do
      self.observers[i]:on_error(message)
    end

    self.stopped = true
  end
end

function Subject:on_completed()
  if not self.stopped then
    for i = #self.observers, 1, -1 do
      self.observers[i]:on_completed()
    end

    self.stopped = true
  end
end

Subject.__call = Subject.on_next

return Subject
