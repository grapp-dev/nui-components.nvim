local Component = require("nui-components.component")
local Line = require("nui.line")
local SignalValue = require("nui-components.signal.value")
local Subject = require("nui-components.rx.subject")
local fn = require("nui-components.utils.fn")
local spinner_formats = require("nui-components.utils.spinner_formats")

local Spinner = Component:extend("Spinner")

function Spinner:init(props, popup_options)
  Spinner.super.init(
    self,
    fn.merge(
      {
        is_loading = false,
        frames = spinner_formats.default,
        interval = 100,
      },
      fn.merge(props, {
        is_focusable = false,
      })
    ),
    fn.deep_merge({
      focusable = false,
    }, popup_options)
  )

  self._private.current_frame = 1

  if fn.isa(props.is_loading, SignalValue) then
    self._private.subject = Subject.create()

    self._private.subscription = self._private.subject
      :combine_latest(props.is_loading:dup():get_observable())
      :subscribe(function(current_frame, is_loading)
        if is_loading then
          self._private.current_frame = current_frame
          self:redraw()
        end
      end)
  end
end

function Spinner:prop_types()
  return {
    is_loading = "boolean",
    frames = "table",
    interval = "number",
  }
end

function Spinner:on_mount()
  if self._private.subject then
    self._private.subject(1)
  end
end

function Spinner:on_unmount()
  if self._private.subscription then
    self._private.subscription:unsubscribe()
  end
end

function Spinner:on_update()
  local props = self:get_props()
  local current_frame = self._private.current_frame

  local line = Line()
  line:append(props.frames[current_frame])
  line:render(self.bufnr, -1, 1)

  if self._private.subject then
    vim.defer_fn(function()
      local next_frame = current_frame + 1
      self._private.subject(next_frame > #props.frames and 1 or next_frame)
    end, props.interval)
  end
end

function Spinner:on_layout()
  local props = self:get_props()
  local parent = self:get_parent()
  local direction = parent and parent:get_direction() or "column"
  local is_row_direction = direction == "row"

  local max_width = fn.ireduce(props.frames, function(acc, value)
    return math.max(acc, #value)
  end, 0)

  return {
    width = is_row_direction and math.max(1, max_width) or nil,
    height = is_row_direction and nil or 1,
  }
end

return Spinner
