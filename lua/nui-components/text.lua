local Component = require("nui-components.component")

local Line = require("nui.line")

local fn = require("nui-components.utils.fn")

local Text = Component:extend("Text")

function Text:init(props)
  Text.super.init(
    self,
    fn.merge({
      lines = "",
    }, props),
    {
      buf_options = {
        filetype = props.filetype or "",
      },
    }
  )
end

function Text:prop_types()
  return {
    lines = "string",
  }
end

function Text:get_content()
  if not vim.api.nvim_buf_is_valid(self.bufnr) then
    return ""
  end

  local lines = vim.api.nvim_buf_get_lines(self.bufnr, 0, -1, false)
  return table.concat(lines, "\n")
end

function Text:clear()
  self:modify_buffer_content(function()
    vim.api.nvim_buf_set_lines(self.bufnr, 0, -1, false, {})
  end)
end

function Text:get_lines()
  local props = self:get_props()
  local lines = vim.split(props.lines, "\n")

  if props.prepare_lines then
    return props.prepare_lines(lines, self)
  end

  return fn.imap(lines, function(text)
    local line = Line()
    line:append(text)
    return line
  end)
end

function Text:set_hl_group(lines, hl_group)
  fn.ieach(lines, function(line)
    fn.ieach(line._texts, function(text)
      text.extmark = { hl_group = hl_group }
    end)
  end)
end

function Text:on_layout()
  local lines = self:get_lines()

  local max_width = fn.ireduce(lines, function(acc, line)
    return math.max(acc, line:width())
  end, 0)

  return {
    width = math.max(1, max_width),
    height = math.max(1, #lines),
  }
end

function Text:on_update()
  self:modify_buffer_content(function()
    local renderer = self:get_renderer()
    local lines = self:get_lines()

    fn.ieach(lines, function(line, index)
      line:render(self.bufnr, -1, index)
    end)

    if #lines > 0 then
      vim.schedule(function()
        renderer:redraw()
      end)
    end
  end)
end

return Text
