local Box = require("nui-components.box")
local fn = require("nui-components.utils.fn")

local Columns = Box:extend("Columns")

function Columns:init(props, popup_options)
  Columns.super.init(self, fn.merge(props, { direction = "row" }), popup_options)
end

return Columns
