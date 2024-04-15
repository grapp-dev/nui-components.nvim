local Observable = require("nui-components.rx.observable")
local fn = require("nui-components.utils.fn")

function Observable:start_with(...)
  local values = fn.pack(...)

  return Observable.create(function(observer)
    observer:on_next(fn.unpack(values))
    return self:subscribe(observer)
  end)
end
