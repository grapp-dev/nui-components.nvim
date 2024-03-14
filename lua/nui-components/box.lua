local Component = require("nui-components.component")
local fn = require("nui-components.utils.fn")

local Box = Component:extend("Box")

function Box:init(props, popup_options)
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
    fn.deep_merge({
      focusable = false,
    }, popup_options)
  )
end

return Box
