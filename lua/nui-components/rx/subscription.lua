local fn = require("nui-components.utils.fn")

local Subscription = {}

Subscription.__index = Subscription
Subscription.__tostring = fn.always("Subscription")

function Subscription.create(action)
  local self = {
    action = action or fn.ignore,
    unsubscribed = false,
  }

  return setmetatable(self, Subscription)
end

function Subscription:unsubscribe()
  if self.unsubscribed then
    return
  end
  self.action(self)
  self.unsubscribed = true
end

return Subscription
