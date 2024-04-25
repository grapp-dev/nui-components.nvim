local Box = require("nui-components.box")
local fn = require("nui-components.utils.fn")

---@class NuiComponents.Columns: NuiComponents.Box
---@overload fun(_, props: table<string, any>, popup_options: NuiPopupOptions): NuiComponents.Columns
---@field super NuiComponents.Box
local Columns = Box:extend("Columns")

function Columns:init(props, popup_options)
  Columns.super.init(self, fn.merge(props, { direction = "row" }), popup_options)
end

return Columns
