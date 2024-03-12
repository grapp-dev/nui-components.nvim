local Component = require("nui-components.component")
local fn = require("nui-components.utils.fn")

local Box = Component:extend("Box")

function Box:init(props)
  Box.super.init(
    self,
    fn.merge(
      {
        size = 1,
      },
      fn.merge(props, {
        is_focusable = false,
      })
    ),
    {
      focusable = false,
    }
  )
end

return Box
