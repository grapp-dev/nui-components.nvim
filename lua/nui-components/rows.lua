local Box = require("nui-components.box")
local fn = require("nui-components.utils.fn")

---@class NuiComponents.Rows: NuiComponents.Box
---@overload fun(_, props: table<string, any>, popup_options: NuiPopupOptions): NuiComponents.Rows
---@field super NuiComponents.Box
local Rows = Box:extend("Rows")

function Rows:init(props, popup_options)
  Rows.super.init(self, fn.merge(props, { direction = "column" }), popup_options)
end

return Rows
