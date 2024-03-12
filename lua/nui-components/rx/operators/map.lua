local Observable = require("nui-components.rx.observable")
local fn = require("nui-components.utils.fn")

function Observable:map(callback)
  return Observable.create(function(observer)
    callback = callback or fn.identity

    local function on_next(...)
      return fn.try_with_observer(observer, function(...)
        return observer:on_next(callback(...))
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
