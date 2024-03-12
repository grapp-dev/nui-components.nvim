local Observable = require("nui-components.rx.observable")
local fn = require("nui-components.utils.fn")

function Observable:distinct_until_changed(comparator)
  comparator = comparator or fn.eq

  return Observable.create(function(observer)
    local first = true
    local currentValue = nil

    local function on_next(value, ...)
      local values = fn.pack(...)
      fn.try_with_observer(observer, function()
        if first or not comparator(value, currentValue) then
          observer:on_next(value, fn.unpack(values))
          currentValue = value
          first = false
        end
      end)
    end

    local function on_error(message)
      return observer:on_error(message)
    end

    local function on_completed()
      return observer:on_completed()
    end

    return self:subscribe(on_next, on_error, on_completed)
  end)
end
