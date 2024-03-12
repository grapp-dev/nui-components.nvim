local Observable = require("nui-components.rx.observable")
local fn = require("nui-components.utils.fn")

function Observable:tap(_on_next, _on_error, _on_completed)
  _on_next = _on_next or fn.ignore
  _on_error = _on_error or fn.ignore
  _on_completed = _on_completed or fn.ignore

  return Observable.create(function(observer)
    local function on_next(...)
      fn.try_with_observer(observer, function(...)
        _on_next(...)
      end, ...)

      return observer:on_next(...)
    end

    local function on_error(message)
      fn.try_with_observer(observer, function()
        _on_error(message)
      end)

      return observer:on_error(message)
    end

    local function on_completed()
      fn.try_with_observer(observer, function()
        _on_completed()
      end)

      return observer:on_completed()
    end

    return self:subscribe(on_next, on_error, on_completed)
  end)
end
