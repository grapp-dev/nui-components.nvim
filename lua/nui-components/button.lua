local Paragraph = require("nui-components.paragraph")

local event = require("nui.utils.autocmd").event
local fn = require("nui-components.utils.fn")

---@class NuiComponents.Button: NuiComponents.Paragraph
---@overload fun(_, props: table<string, any>, popup_options: NuiPopupOptions): NuiComponents.Button
---@field super NuiComponents.Paragraph
local Button = Paragraph:extend("Button")

function Button:init(props, popup_options)
  local lines = fn.default_to(props.label, "")
  props.label = nil

  Button.super.init(
    self,
    fn.merge({
      on_press = fn.ignore,
      press_key = { "<CR>", "<Space>" },
      lines = lines,
      is_active = false,
      truncate = true,
    }, props),
    popup_options
  )
end

function Button:prop_types()
  return fn.merge(Button.super.prop_types(self), {
    on_press = "function",
    press_key = { "table", "string" },
    is_active = { "boolean", "nil" },
    global_press_key = { "table", "string", "nil" },
  })
end

function Button:mappings()
  local props = self:get_props()

  local on_press = function()
    props.on_press(self)
  end

  local mappings = {
    { mode = { "n" }, key = props.press_key, handler = on_press },
  }

  if props.global_press_key then
    table.insert(mappings, {
      global = true,
      mode = { "n", "i", "v" },
      key = props.global_press_key,
      handler = on_press,
    })
  end

  return mappings
end

function Button:events()
  local handler = vim.schedule_wrap(function()
    self:if_mounted(function()
      self:on_update()
    end)
  end)

  return {
    {
      event = event.BufEnter,
      handler = handler,
    },
    {
      event = event.BufLeave,
      handler = handler,
    },
  }
end

function Button:get_lines()
  local props = self:get_props()
  local lines = Button.super.get_lines(self)

  if props.prepare_lines then
    return props.prepare_lines(lines, self)
  end

  local is_focused = self:is_focused()
  local hl_group = self:hl_group(props.is_active and "Active" or (is_focused and "Focused" or ""))

  self:set_hl_group(lines, hl_group)

  return lines
end

return Button
