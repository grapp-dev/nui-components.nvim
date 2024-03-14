local Component = require("nui-components.component")
local Layout = require("nui.layout")
local fn = require("nui-components.utils.fn")

local Gap = Component:extend("Gap")

function Gap:init(props, popup_options)
  Gap.super.init(
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
      zindex = 99,
    }, popup_options)
  )
end

function Gap:render()
  return Layout.Box(self, { size = self:get_size() })
end

return Gap
