local Component = require("nui-components.component")
local Line = require("nui.line")
local SignalValue = require("nui-components.signal.value")
local Subject = require("nui-components.rx.subject")
local fn = require("nui-components.utils.fn")

local AnimatedText = Component:extend("AnimatedText")

function AnimatedText:init(props, popup_options)
  props = fn.merge(
    {
      is_running = true,
      text = "",
      interval = 60,
      on_complete = fn.ignore,
    },
    fn.merge(props, {
      is_focusable = false,
    })
  )
  AnimatedText.super.init(
    self,
    props,
    fn.deep_merge({
      focusable = false,
    }, popup_options)
  )

  self._private.current_frame = 1

  self._private.lines = vim.split(props.text, "\n")
  self._private.max_width = fn.ireduce(self._private.lines, function(acc, chars)
    local line = Line()
    line:append(chars)
    return math.max(acc, line:width())
  end, 0)
  self._private.subject = Subject.create()

  if fn.isa(props.is_running, SignalValue) then
    self._private.subscription = self._private.subject
      :combine_latest(props.is_running:dup():get_observable())
      :subscribe(function(current_frame, is_running)
        if is_running then
          self._private.current_frame = current_frame
          self:redraw()
        end
      end)
  elseif props.is_running then
    self._private.subscription = self._private.subject:subscribe(function(current_frame)
      self._private.current_frame = current_frame
      self:redraw()
    end)
  end
end

function AnimatedText:prop_types()
  return {
    is_running = "boolean",
    text = "string",
    interval = "number",
    on_complete = "function",
  }
end

function AnimatedText:on_mount()
  if self._private.subject then
    self._private.subject(1)
  end
end

function AnimatedText:on_unmount()
  if self._private.subscription then
    self._private.subscription:unsubscribe()
  end
end

function AnimatedText:on_update()
  local props = self:get_props()
  local current_frame = self._private.current_frame

  fn.ieach(self._private.lines, function(text, index)
    local line = Line()
    line:append(string.sub(text, 1, current_frame), self:hl_group())
    line:render(self.bufnr, -1, index)
  end)
  --
  if self._private.subject then
    vim.defer_fn(function()
      local next_frame = current_frame + 1
      if next_frame > self._private.max_width then
        self._private.subject:on_completed()
        props.on_complete()
      else
        self._private.subject(next_frame)
      end
    end, props.interval)
  end
end

function AnimatedText:on_layout()
  local parent = self:get_parent()
  local direction = parent and parent:get_direction() or "column"
  local is_row_direction = direction == "row"

  return {
    width = is_row_direction and math.max(1, self._private.max_width) or nil,
    height = is_row_direction and nil or #self._private.lines,
  }
end

return AnimatedText
