local Observable = require("nui-components.rx.observable")
local Subscription = require("nui-components.rx.subscription")
local fn = require("nui-components.utils.fn")

local function schedule(action, delay)
  local timer = vim.loop.new_timer()
  timer:start(delay, 0, vim.schedule_wrap(action))
  return Subscription.create(function()
    timer:stop()
  end)
end

function Observable:debounce(time)
  time = time or 0

  return Observable.create(function(observer)
    local debounced = {}

    local function wrap(key)
      return function(...)
        if debounced[key] then
          debounced[key]:unsubscribe()
        end

        local values = fn.pack(...)

        debounced[key] = schedule(function()
          return observer[key](observer, fn.unpack(values))
        end, time)
      end
    end

    local subscription = self:subscribe(wrap("on_next"), wrap("on_error"), wrap("on_completed"))

    return Subscription.create(function()
      if subscription then
        subscription:unsubscribe()
      end
      for _, timeout in pairs(debounced) do
        timeout:unsubscribe()
      end
    end)
  end)
end
