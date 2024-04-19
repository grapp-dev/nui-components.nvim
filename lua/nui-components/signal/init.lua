local Rx = require("nui-components.rx")
local SignalValue = require("nui-components.signal.value")

local fn = require("nui-components.utils.fn")

local Signal = {}

Signal.__index = Signal
Signal.__tostring = fn.always("Signal")

function Signal.create(object)
  object = vim.deepcopy(object) or {}

  local self = {
    _private = {
      subject = Rx.BehaviorSubject.create(object),
      proxy = {},
    },
  }

  setmetatable(self, Signal)

  self._private.proxy[self.__index] = object

  setmetatable(self._private.proxy, {
    __index = function(t, key)
      if key == "observe" then
        return function(_, ...)
          return self:observe(...)
        end
      end

      if key == "get_value" then
        return function(_)
          return self:get_value()
        end
      end

      if key == "set_value" then
        return function(_, o)
          t[self.__index] = vim.deepcopy(o)
          self._private.subject(t[self.__index])
        end
      end

      return SignalValue.create(self._private.subject, key)
    end,
    __newindex = function(t, key, value)
      t[self.__index][key] = value
      self._private.subject(t[self.__index])
    end,
  })

  return self._private.proxy
end

function Signal:observe(next_fn, debounce_ms)
  debounce_ms = debounce_ms or 0

  return self._private.subject
    :debounce(debounce_ms)
    :scan(function(acc, value)
      return { acc[2], vim.deepcopy(value) }
    end, {})
    :skip(1)
    :subscribe(function(value)
      next_fn(fn.unpack(value))
    end)
end

function Signal:get_value()
  return self._private.subject:get_value()
end

return Signal
