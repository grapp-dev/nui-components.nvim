local Component = require("nui-components.component")
local fn = require("nui-components.utils.fn")

---@class NuiComponents.Form: NuiComponents.Component
---@overload fun(_, props: table<string, any>, popup_options: NuiPopupOptions): NuiComponents.Form
---@field super NuiComponents.Component
local Form = Component:extend("Form")

function Form:init(props, popup_options)
  Form.super.init(
    self,
    fn.merge(
      {
        flex = 1,
        submit_key = "<C-CR>",
        direction = "column",
        on_submit = fn.ignore,
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

function Form:prop_types()
  return {
    submit_key = "string",
    on_submit = "function",
  }
end

function Form:on_renderer_initialization(...)
  Form.super.on_renderer_initialization(self, ...)

  local children = self:get_flatten_children()
  local props = self:get_props()

  local form_mappings = {
    {
      mode = { "i", "n" },
      key = props.submit_key,
      handler = function()
        self:submit()
      end,
    },
  }

  fn.ieach(children, function(child)
    child._private.props_mappings = fn.concat(child._private.props_mappings, form_mappings)
  end)
end

function Form:validate()
  local children = self:get_flatten_children()

  for _, child in ipairs(children) do
    if not child:is_hidden() then
      local props = child:get_props()

      if props.validate then
        if not props.validate(child:get_current_value()) then
          return false
        end
      end
    end
  end

  return true
end

function Form:submit()
  local props = self:get_props()
  local is_valid = self:validate()
  props.on_submit(is_valid)
end

return Form
