local Box = require("nui-components.box")
local fn = require("nui-components.utils.fn")

local Columns = Box:extend("Columns")

function Columns:init(props)
  Columns.super.init(self, fn.merge(props, { direction = "row" }))
end

return Columns
