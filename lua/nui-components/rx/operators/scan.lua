local Observable = require("nui-components.rx.observable")
local fn = require("nui-components.utils.fn")

function Observable:scan(accumulator, seed)
  return Observable.create(function(observer)
    local result = seed
    local first = true

    local function on_next(...)
      if first and seed == nil then
        result = ...
        first = false
      else
        return fn.try_with_observer(observer, function(...)
          result = accumulator(result, ...)
          observer:on_next(result)
        end, ...)
      end
    end

    local function on_error(e)
      return observer:on_error(e)
    end

    local function on_completed()
      return observer:on_completed()
    end

    return self:subscribe(on_next, on_error, on_completed)
  end)
end
