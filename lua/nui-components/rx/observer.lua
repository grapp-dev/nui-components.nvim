local fn = require("nui-components.utils.fn")

local Observer = {}
Observer.__index = Observer
Observer.__tostring = fn.always("Observer")

function Observer.create(on_next, on_error, on_completed)
  local self = {
    _on_next = on_next or fn.ignore,
    _on_error = on_error or error,
    _on_completed = on_completed or fn.ignore,
    stopped = false,
  }

  return setmetatable(self, Observer)
end

function Observer:on_next(...)
  if not self.stopped then
    self._on_next(...)
  end
end

function Observer:on_error(message)
  if not self.stopped then
    self.stopped = true
    self._on_error(message)
  end
end

function Observer:on_completed()
  if not self.stopped then
    self.stopped = true
    self._on_completed()
  end
end

return Observer
