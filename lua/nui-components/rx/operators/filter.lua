local Observable = require("nui-components.rx.observable")
local fn = require("nui-components.utils.fn")

function Observable:filter(predicate)
  predicate = predicate or fn.identity

  return Observable.create(function(observer)
    local function on_next(...)
      fn.try_with_observer(observer, function(...)
        if predicate(...) then
          return observer:on_next(...)
        end
      end, ...)
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
