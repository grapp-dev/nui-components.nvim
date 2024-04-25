local NuiText = require("nui.text")
local Paragraph = require("nui-components.paragraph")

local fn = require("nui-components.utils.fn")

---@class NuiComponents.Checkbox: NuiComponents.Paragraph
---@overload fun(_, props: table<string, any>, popup_options: NuiPopupOptions): NuiComponents.Checkbox
---@field super NuiComponents.Paragraph
local Checkbox = Paragraph:extend("Checkbox")

function Checkbox:init(props, popup_options)
  local lines = fn.default_to(props.label, "")
  props.label = nil

  Checkbox.super.init(
    self,
    fn.merge({
      on_change = fn.ignore,
      press_key = { "<CR>", "<Space>" },
      value = false,
      checked_sign = "[x]",
      default_sign = "[ ]",
      lines = lines,
      truncate = true,
    }, props),
    popup_options
  )
end

function Checkbox:prop_types()
  return fn.merge(Checkbox.super.prop_types(self), {
    on_change = "function",
    press_key = { "table", "string" },
    value = "boolean",
    checked_sign = "string",
    default_sign = "string",
  })
end

function Checkbox:mappings()
  local props = self:get_props()

  local on_change = function()
    local value = not self:get_current_value()
    self:set_current_value(value)
    props.on_change(value, self)
  end

  return {
    { mode = { "n" }, key = props.press_key, handler = on_change },
  }
end

function Checkbox:initial_value()
  return self:get_props().value
end

function Checkbox:get_current_value()
  local props = self:get_props()

  if props.instance:is_signal("value") then
    return props.value
  end

  return Checkbox.super.get_current_value(self)
end

function Checkbox:is_checked()
  return self:get_current_value()
end

function Checkbox:get_lines()
  local props = self:get_props()
  local is_checked = self:is_checked()
  local lines = Checkbox.super.get_lines(self)

  if props.prepare_lines then
    return props.prepare_lines(is_checked, lines, self)
  end

  self:set_hl_group(lines, self:hl_group(is_checked and "LabelChecked" or "Label"))

  local sign = is_checked and NuiText(props.checked_sign, self:hl_group("IconChecked"))
    or NuiText(props.default_sign, self:hl_group("Icon"))

  local separator =
    NuiText(is_checked and (#props.checked_sign > 0 and " " or "") or (#props.default_sign > 0 and " " or ""))
  local padding = NuiText((" "):rep(sign:width() + separator:width()))

  fn.ieach(lines, function(line, index)
    if index == 1 then
      table.insert(line._texts, 1, separator)
      table.insert(line._texts, 1, sign)
    else
      table.insert(line._texts, 1, padding)
    end
  end)

  return lines
end

return Checkbox
