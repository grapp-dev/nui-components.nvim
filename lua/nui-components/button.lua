local Paragraph = require("nui-components.paragraph")

local event = require("nui.utils.autocmd").event
local fn = require("nui-components.utils.fn")

local Button = Paragraph:extend("Button")

function Button:init(props)
  local lines = fn.default_to(props.label, "")
  props.label = nil

  Button.super.init(
    self,
    fn.merge({
      on_press = fn.ignore,
      press_key = { "<CR>", "<Space>" },
      lines = lines,
      is_active = false,
    }, props)
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
  local callback = vim.schedule_wrap(function()
    self:if_mounted(function()
      self:on_update()
    end)
  end)

  return {
    {
      event = event.BufEnter,
      callback = callback,
    },
    {
      event = event.BufLeave,
      callback = callback,
    },
  }
end

function Button:get_lines()
  local props = self:get_props()
  local lines = vim.split(props.lines, "\n")

  if props.prepare_lines then
    return props.prepare_lines(lines, self)
  end

  local is_focused = self:is_focused()
  local hl_group = self:hl_group(props.is_active and "Active" or (is_focused and "Focused" or ""))

  lines = Button.super.get_lines(self)

  self:set_hl_group(lines, hl_group)

  return lines
end

return Button
