local Component = require("nui-components.component")

local Line = require("nui.line")

local fn = require("nui-components.utils.fn")

local Paragraph = Component:extend("Paragraph")

local function get_max_width(lines)
  return fn.ireduce(lines, function(acc, line)
    return math.max(acc, line:width())
  end, 0)
end

function Paragraph:init(props, popup_options)
  Paragraph.super.init(
    self,
    fn.merge({
      lines = "",
      align = "left",
    }, props),
    fn.deep_merge({
      buf_options = {
        filetype = props.filetype or "",
      },
    }, fn.default_to(popup_options, {}))
  )
end

function Paragraph:prop_types()
  return {
    lines = { "table", "string" },
    align = "string",
  }
end

function Paragraph:_calculate_gap_width(max_width, text_width)
  local align = self:get_props().align

  local gap_width = max_width - text_width
  if align == "left" then
    return 0, gap_width
  elseif align == "center" then
    return math.floor(gap_width / 2), math.ceil(gap_width / 2)
  elseif align == "right" then
    return gap_width, 0
  end

  return 0, 0
end

function Paragraph:_truncate_text(text, max_length)
  if vim.api.nvim_strwidth(text) > max_length then
    return string.sub(text, 1, max_length - 1) .. "…"
  end

  return text
end

function Paragraph:_truncate_line(line, max_width)
  local width = line:width()
  local last_part_idx = #line._texts

  while width > max_width do
    local extra_width = width - max_width
    local last_part = line._texts[last_part_idx]

    if last_part:width() <= extra_width then
      width = width - last_part:width()
      line._texts[last_part_idx] = nil
      last_part_idx = last_part_idx - 1

      if last_part:width() == extra_width then
        last_part = line._texts[last_part_idx]
        last_part:set(self:_truncate_text(last_part:content() .. " ", last_part:width()))
      end
    else
      last_part:set(self:_truncate_text(last_part:content(), last_part:width() - extra_width))
      width = width - extra_width
    end
  end
end

function Paragraph:get_content()
  if not vim.api.nvim_buf_is_valid(self.bufnr) then
    return ""
  end

  local lines = vim.api.nvim_buf_get_lines(self.bufnr, 0, -1, false)
  return table.concat(lines, "\n")
end

function Paragraph:clear()
  self:modify_buffer_content(function()
    vim.api.nvim_buf_set_lines(self.bufnr, 0, -1, false, {})
  end)
end

function Paragraph:get_lines()
  local props = self:get_props()
  local lines = props.lines

  if type(props.lines) == "string" then
    lines = fn.imap(vim.split(lines, "\n"), function(text)
      local line = Line()
      line:append(text)
      return line
    end)
  end

  if props.prepare_lines then
    return props.prepare_lines(lines, self)
  end

  return lines
end

function Paragraph:set_hl_group(lines, hl_group)
  fn.ieach(lines, function(line)
    fn.ieach(line._texts, function(text)
      text.extmark = { hl_group = hl_group }
    end)
  end)
end

function Paragraph:on_layout()
  local lines = self:get_lines()
  local max_width = get_max_width(lines)
  local parent = self:get_parent()
  local direction = parent and parent:get_direction() or "column"
  local is_row_direction = direction == "row"

  return {
    width = is_row_direction and math.max(1, max_width) or nil,
    height = is_row_direction and nil or math.max(1, #lines),
  }
end

function Paragraph:on_update()
  self:modify_buffer_content(function()
    local renderer = self:get_renderer()
    local lines = self:get_lines()
    local size = self:get_size()

    if not self:is_hidden() then
      self._private.last_width = size.width
    end

    local width = self._private.last_width or size.width

    fn.ieach(lines, function(line, index)
      local new_line = Line()

      local left_gap_width, right_gap_width = self:_calculate_gap_width(width, line:width())

      if left_gap_width > 0 then
        new_line:append(string.rep(" ", left_gap_width))
      end

      self:_truncate_line(line, width)
      new_line:append(line)

      if right_gap_width > 0 then
        new_line:append(string.rep(" ", right_gap_width))
      end

      new_line:render(self.bufnr, -1, index)
    end)

    if #lines > 0 then
      vim.schedule(function()
        renderer:redraw()
      end)
    end
  end)
end

return Paragraph
