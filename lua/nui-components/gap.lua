local Component = require("nui-components.component")
local Layout = require("nui.layout")
local fn = require("nui-components.utils.fn")

local Gap = Component:extend("Gap")

function Gap:init(props)
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
    {
      focusable = false,
      zindex = 100,
    }
  )
end

function Gap:render()
  return Layout.Box(self, { size = self:get_size() })
end

return Gap
