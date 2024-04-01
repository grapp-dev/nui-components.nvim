local Component = require("nui-components.component")
local Signal = require("nui-components.signal")
local event = require("nui.utils.autocmd").event
local fn = require("nui-components.utils.fn")

---@class NuiComponents.TextInput: NuiComponents.Component
---@overload fun(_, props: table<string, any>, popup_options: NuiPopupOptions): NuiComponents.TextInput
---@field super NuiComponents.Component
local TextInput = Component:extend("TextInput")

function TextInput:init(props, popup_options)
  props = fn.merge({
    size = 1,
    autoresize = false,
    max_lines = nil,
    value = "",
    on_change = fn.ignore,
    border_style = "rounded",
  }, props)

  if props.max_lines then
    props.max_lines = math.max(1, props.max_lines)
  end

  if props.autoresize then
    local signal = Signal.create({ size = props.size })

    self._private = {
      text_input_signal = signal,
      text_input_initial_size = props.size,
    }

    props.size = self._private.text_input_signal.size
  end

  TextInput.super.init(
    self,
    props,
    fn.deep_merge({
      buf_options = {
        filetype = props.filetype or "",
      },
      win_options = {
        wrap = props.wrap,
      },
    }, popup_options)
  )
end

function TextInput:prop_types()
  return {
    on_change = "function",
    max_lines = { "number", "nil" },
    value = { "string", "nil" },
    autoresize = { "boolean", "nil" },
    wrap = { "boolean", "nil" },
    filetype = { "string", "nil" },
  }
end

function TextInput:_attach_change_listener()
  local props = self:get_props()

  vim.api.nvim_buf_attach(self.bufnr, false, {
    on_lines = self:if_not_mounting_phase_wrap(function()
      local lines = vim.api.nvim_buf_get_lines(self.bufnr, 0, -1, false)
      local value = table.concat(lines, "\n")

      self:set_current_value(value)
      props.on_change(value, self)

      if props.autoresize then
        self._private.text_input_signal.size = math.max(#lines, self._private.text_input_initial_size)
      end
    end),
  })
end

function TextInput:_is_next_line_allowed()
  local props = self:get_props()
  local lines = self:get_lines()

  if type(props.max_lines) == "number" then
    if props.max_lines <= #lines then
      return false
    end
  end

  return true
end

function TextInput:_patch_cursor_position()
  local lines = self:get_lines()
  vim.api.nvim_win_set_cursor(self.winid, { math.max(1, #lines - 1), 0 })
  vim.api.nvim_win_set_cursor(self.winid, { #lines, 0 })
end

function TextInput:initial_value()
  local props = self:get_props()
  return props.value
end

function TextInput:get_lines()
  return vim.split(self:get_current_value(), "\n")
end

function TextInput:get_current_value()
  local props = self:get_props()

  if props.instance:is_signal("value") then
    return props.value
  end

  return TextInput.super.get_current_value(self)
end

function TextInput:mappings()
  return {
    {
      mode = { "i" },
      key = "<CR>",
      handler = function()
        if self:_is_next_line_allowed() then
          local props = self:get_props()

          vim.api.nvim_feedkeys("\n", "insert", false)

          if props.autoresize then
            local renderer = self:get_renderer()

            renderer:schedule(function()
              self:_patch_cursor_position()
            end)
          end
        end
      end,
    },
  }
end

function TextInput:events()
  return {
    {
      event = event.BufEnter,
      handler = vim.schedule_wrap(function()
        local has_cmp, cmp = pcall(require, "cmp")

        vim.api.nvim_command("startinsert!")

        if has_cmp then
          cmp.setup.buffer({ enabled = false })
        end

        vim.schedule(function()
          self:if_mounted(function()
            local lines = self:get_lines()

            pcall(function()
              vim.api.nvim_win_set_cursor(self.winid, { #lines, #lines[#lines] })
            end)
          end)
        end)
      end),
    },
    {
      event = event.BufLeave,
      handler = function()
        vim.api.nvim_command("stopinsert")
      end,
    },
  }
end

function TextInput:on_update()
  local mode = vim.fn.mode()
  local current_winid = vim.api.nvim_get_current_win()

  if not (current_winid == self.winid and mode == "i") then
    vim.schedule(function()
      if self:_is_next_line_allowed() then
        local lines = self:get_lines()
        vim.api.nvim_buf_set_lines(self.bufnr, 0, #lines, false, lines)
      end
    end)
  end
end

function TextInput:on_mount()
  self:_attach_change_listener()
end

return TextInput
