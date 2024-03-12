local SignalValue = require("nui-components.signal.value")

local fn = require("nui-components.utils.fn")

local Props = {}

Props.__index = Props
Props.__tostring = fn.always("Props")

function Props.create(object)
  local self = {
    _private = {
      on_next = function(_, _) end,
      object = object,
    },
  }

  self._private.object.instance = setmetatable(self, Props)

  local signal_values = fn.kreduce(object, function(acc, prop, key)
    if fn.isa(prop, SignalValue) then
      local observer = self:_create_observer(prop, key)
      self._private.object[key] = nil
      acc[key] = observer
    end

    return acc
  end, {})

  self._private.signal_values = signal_values

  setmetatable(self._private.object, {
    __index = function(t, key)
      local signal_value = self._private.signal_values[key]

      if signal_value then
        return signal_value:get_observer_value()
      end

      return rawget(t, key)
    end,
    __newindex = function()
      -- readonly
    end,
  })

  return self._private.object
end

function Props:_create_observer(signal_value, key)
  return signal_value:observe(function(value)
    self._private.on_next(value, key)
  end)
end

function Props:add_signal_value(key, signal_value)
  self._private.signal_values[key] = self:_create_observer(signal_value, key)
  self._private.object[key] = nil
end

function Props:is_signal(key)
  return self._private.signal_values[key] ~= nil
end

function Props:on_next(next_fn)
  self._private.on_next = next_fn
end

function Props:unmount()
  fn.ieach(self._private.signal_values, function(signal_value)
    signal_value:unsubscribe()
  end)
end

return Props
