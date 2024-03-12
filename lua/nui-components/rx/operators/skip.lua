local Observable = require("nui-components.rx.observable")

function Observable:skip(n)
  n = n or 1

  return Observable.create(function(observer)
    local i = 1

    local function on_next(...)
      if i > n then
        observer:on_next(...)
      else
        i = i + 1
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
