local TextInput = require("nui-components.text-input")
local fn = require("nui-components.utils.fn")

local Prompt = TextInput:extend("Gap")

function Prompt:init(props, popup_options)
  Prompt.super.init(
    self,
    fn.merge(
      {
        on_submit = fn.ignore,
      },
      fn.merge(props, {
        size = 1,
        max_lines = 1,
      })
    ),
    fn.deep_merge({
      buf_options = {
        buftype = "prompt",
      },
    }, popup_options)
  )
end

function Prompt:prop_types()
  return fn.merge(Prompt.super.prop_types(self), {
    on_submit = "function",
  })
end

function Prompt:mappings()
  local props = self:get_props()

  return {
    {
      mode = { "i", "n" },
      key = "<CR>",
      handler = function()
        props.on_submit(self:get_current_value())
      end,
    },
  }
end

return Prompt
