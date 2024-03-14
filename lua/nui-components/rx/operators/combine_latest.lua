local Observable = require("nui-components.rx.observable")
local Subscription = require("nui-components.rx.subscription")
local fn = require("nui-components.utils.fn")

function Observable:combine_latest(...)
  local sources = { ... }
  local combinator = table.remove(sources)
  if type(combinator) ~= "function" then
    table.insert(sources, combinator)
    combinator = function(...)
      return ...
    end
  end

  table.insert(sources, 1, self)

  return Observable.create(function(observer)
    local latest = {}
    local pending = { fn.unpack(sources) }
    local completed = {}
    local subscription = {}

    local function on_next(i)
      return function(value)
        latest[i] = value
        pending[i] = nil

        if not next(pending) then
          fn.try_with_observer(observer, function()
            observer:on_next(combinator(fn.unpack(latest)))
          end)
        end
      end
    end

    local function on_error(e)
      return observer:on_error(e)
    end

    local function on_completed(i)
      return function()
        table.insert(completed, i)

        if #completed == #sources then
          observer:on_completed()
        end
      end
    end

    for i = 1, #sources do
      subscription[i] = sources[i]:subscribe(on_next(i), on_error, on_completed(i))
    end

    return Subscription.create(function()
      for i = 1, #sources do
        if subscription[i] then
          subscription[i]:unsubscribe()
        end
      end
    end)
  end)
end
