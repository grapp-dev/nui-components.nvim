local Text = require("nui.text")
local TextInput = require("nui-components.text-input")
local fn = require("nui-components.utils.fn")

local Prompt = TextInput:extend("Gap")

function Prompt:init(props, popup_options)
  Prompt.super.init(
    self,
    fn.merge(
      {
        on_submit = fn.ignore,
        prefix = "",
        submit_key = "<CR>",
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
    prefix = "string",
    submit_key = { "table", "string" },
  })
end

function Prompt:_attach_change_listener()
  local props = self:get_props()

  vim.api.nvim_buf_attach(self.bufnr, false, {
    on_lines = self:if_not_mounting_phase_wrap(function()
      local prefix_length = self._private.prefix:length()
      local value_with_prompt = vim.api.nvim_buf_get_lines(self.bufnr, 0, 1, false)[1]
      local value = string.sub(value_with_prompt, prefix_length + 1)

      self:set_current_value(value)
      props.on_change(value, self)

      self:_update_placeholder()

      if prefix_length > 0 then
        vim.schedule(function()
          self._private.prefix:highlight(self.bufnr, self.ns_id, 1, 0)
        end)
      end
    end),
  })
end

function Prompt:on_renderer_initialization(...)
  Prompt.super.on_renderer_initialization(self, ...)

  local props = self:get_props()
  local function is_nui_text(value)
    return value.class and value.class.name == "NuiText"
  end

  self._private.prefix = is_nui_text(props.prefix) and props.prefix or Text(props.prefix, self:hl_group("Prefix"))
  vim.fn.prompt_setprompt(self.bufnr, self._private.prefix:content())
end

function Prompt:mappings()
  local props = self:get_props()

  return {
    {
      mode = { "i", "n" },
      key = props.submit_key,
      handler = function()
        props.on_submit(self:get_current_value())
      end,
    },
  }
end

return Prompt
