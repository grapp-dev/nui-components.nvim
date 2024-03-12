local Box = require("nui-components.box")
local fn = require("nui-components.utils.fn")

local Rows = Box:extend("Rows")

function Rows:init(props)
  Rows.super.init(self, fn.merge(props, { direction = "column" }))
end

return Rows
