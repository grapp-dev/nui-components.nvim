local Component = require("nui-components.component")
local fn = require("nui-components.utils.fn")

---@class NuiComponents.Box: NuiComponents.Component
---@overload fun(_, props: table<string, any>, popup_options: NuiPopupOptions): NuiComponents.Box
---@field super NuiComponents.Component
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
