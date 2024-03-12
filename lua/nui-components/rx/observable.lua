local Observer = require("nui-components.rx.observer")
local fn = require("nui-components.utils.fn")

local Observable = {}

Observable.__index = Observable
Observable.__tostring = fn.always("Observable")

function Observable.create(subscribe)
  local self = {
    _subscribe = subscribe,
  }

  return setmetatable(self, Observable)
end

function Observable:subscribe(on_next, on_error, on_completed)
  if type(on_next) == "table" then
    return self._subscribe(on_next)
  else
    return self._subscribe(Observer.create(on_next, on_error, on_completed))
  end
end

function Observable.empty()
  return Observable.create(function(observer)
    observer:on_completed()
  end)
end

function Observable.never()
  return Observable.create(function(_) end)
end

function Observable.throw(message)
  return Observable.create(function(observer)
    observer:on_error(message)
  end)
end

function Observable.of(...)
  local args = { ... }
  local argCount = select("#", ...)
  return Observable.create(function(observer)
    for i = 1, argCount do
      observer:on_next(args[i])
    end

    observer:on_completed()
  end)
end

function Observable.from_range(initial, limit, step)
  if not limit and not step then
    initial, limit = 1, initial
  end

  step = step or 1

  return Observable.create(function(observer)
    for i = initial, limit, step do
      observer:on_next(i)
    end

    observer:on_completed()
  end)
end

function Observable.from_table(t, iterator, keys)
  iterator = iterator or pairs
  return Observable.create(function(observer)
    for key, value in iterator(t) do
      observer:on_next(value, keys and key or nil)
    end

    observer:on_completed()
  end)
end

function Observable.defer(func)
  if not func or type(func) ~= "function" then
    error("Expected a function")
  end

  return setmetatable({
    subscribe = function(_, ...)
      local observable = func()
      return observable:subscribe(...)
    end,
  }, Observable)
end

function Observable.replicate(value, count)
  return Observable.create(function(observer)
    while count == nil or count > 0 do
      observer:on_next(value)
      if count then
        count = count - 1
      end
    end
    observer:on_completed()
  end)
end

function Observable:dump(name, formatter)
  name = name and (name .. " ") or ""
  formatter = formatter or tostring

  local on_next = function(...)
    print(name .. "on_next: " .. formatter(...))
  end
  local on_error = function(e)
    print(name .. "on_error: " .. e)
  end
  local on_completed = function()
    print(name .. "on_completed")
  end

  return self:subscribe(on_next, on_error, on_completed)
end

return Observable
