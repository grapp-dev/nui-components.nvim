local Layout = require("nui.layout")
local Popup = require("nui.popup")
local Props = require("nui-components.component.props")
local Size = require("nui-components.component.size")
local Text = require("nui.text")

local event = require("nui.utils.autocmd").event
local fn = require("nui-components.utils.fn")

local Component = Popup:extend("Component")

function Component:init(props, popup_options)
  popup_options = fn.deep_merge({
    enter = false,
    focusable = true,
    win_options = {
      winblend = 0,
    },
    zindex = 100,
  }, fn.default_to(popup_options, {}))

  props = fn.merge({
    hidden = false,
    mappings = fn.always({}),
    events = fn.always({}),
    is_focusable = true,
    direction = "row",
    on_focus = fn.ignore,
    on_blur = fn.ignore,
    on_mount = fn.ignore,
    on_unmount = fn.ignore,
    id = tostring(math.random()),
  }, props)

  if props.border_label and not props.border_style then
    props.border_style = "rounded"
  end

  if props.border_style and not (props.border_style == "none") then
    popup_options = fn.deep_merge(popup_options, {
      border = {
        style = props.border_style,
        text = {
          top = "",
          top_align = "left",
        },
      },
    })
  end

  if props.padding then
    popup_options = fn.deep_merge(popup_options, {
      border = {
        padding = props.padding,
      },
    })
  end

  self._private = self._private or {}
  self._private.id = props.id
  self._private.props = Props.create(props)
  self._private.size = Size.create(self)
  self._private.current_value = nil

  Component.super.init(self, popup_options)

  self:_set_border_label()

  local errors = self:_validate_prop_types()

  if errors then
    vim.notify(vim.inspect({ self.class.name .. ":" .. self:get_id(), errors }))
  end
end

function Component:on_renderer_initialization(renderer, parent, children)
  local layout_props = { "hidden", "flex", "size", "padding" }

  self._private.parent = parent
  self._private.renderer = renderer
  self._private.children = children
  self._private.props.children = nil

  self._private.props.instance:on_next(function(_, key)
    local is_layout_prop = fn.isome(layout_props, function(prop)
      return prop == key
    end)

    if is_layout_prop then
      if key == "hidden" then
        self:on_visibility_change()
      end

      renderer:redraw()
    else
      self:redraw()
    end
  end)

  self:_set_initial_value()
  self:_split_mappings()
end

function Component:mount()
  local props = self:get_props()

  self._private.is_mount_pending = true

  Component.super.mount(self)

  self:on_mount()

  self:_attach_events()
  self:_attach_mappings()
  self:_set_initial_focus()

  self:redraw()

  vim.schedule(function()
    props.on_mount(self)
    self._private.is_mount_pending = false
  end)
end

function Component:unmount()
  local props = self:get_props()

  Component.super.unmount(self)

  self:on_unmount()
  props.instance:unmount()

  vim.schedule(function()
    props.on_unmount(self)
    vim.api.nvim_command("stopinsert")
  end)
end

function Component:redraw()
  self:on_update()
end

function Component:_default_prop_types()
  return {
    size = "number",
    flex = { "number", "nil" },
    hidden = "boolean",
    mappings = "function",
    events = "function",
    is_focusable = "boolean",
    direction = "string",
    on_focus = "function",
    on_blur = "function",
    on_mount = "function",
    on_unmount = "function",
    id = "string",
    border_label = { "string", "table", "nil" },
    border_style = { "string", "nil" },
    children = { "table", "nil" },
    focus_key = { "table", "string", "nil" },
    padding = { "table", "number", "nil" },
    autofocus = { "boolean", "nil" },
    validate = { "function", "nil" },
  }
end

function Component:_validate_prop_types()
  local props = self:get_props()
  local prop_types = fn.merge(self:_default_prop_types(), self:prop_types())
  local errors = fn.kreduce(props, function(errors, value, key)
    if not (key == "instance") then
      if not prop_types[key] then
        table.insert(errors, { message = "Unexpected property '" .. key .. "' in table.", key = key })
      else
        local is_table = type(prop_types[key]) == "table"
        local is_type_correct = true

        if is_table then
          is_type_correct = fn.isome(prop_types[key], function(prop_type)
            return type(value) == prop_type
          end)
        else
          is_type_correct = type(value) == prop_types[key]
        end

        if not is_type_correct then
          table.insert(errors, { message = "Property '" .. key .. "' has incorrect type.", key = key })
        end
      end
    end

    return errors
  end, {})

  return #errors > 0 and errors or nil
end

function Component:_set_border_label()
  local props = self:get_props()

  if props.border_style and not (props.border_style == "none") then
    local label = fn.default_to(props.border_label, "")
    local edge = "top"
    local align = "left"

    local function is_nui_text(value)
      return value.class and value.class.name == "NuiText"
    end

    if type(props.border_label) == "table" then
      if is_nui_text(props.border_label) then
        label = props.border_label
      else
        local icon = props.border_label.icon and " " .. props.border_label.icon or ""

        if is_nui_text(props.border_label.text) then
          label = Text(icon .. " " .. props.border_label.text:content() .. " ", props.border_label.text.extmark)
        else
          label = icon .. " " .. props.border_label.text .. " "
        end

        edge = fn.default_to(props.border_label.edge, edge)
        align = fn.default_to(props.border_label.align, align)
      end
    end

    self:set_border_text(edge, label, align)
  end
end

function Component:_set_initial_focus()
  if self:get_props().autofocus then
    self:focus()
  end
end

function Component:_attach_events()
  local renderer = self:get_renderer()
  local props = self:get_props()

  local default_events = {
    {
      event = event.BufEnter,
      callback = vim.schedule_wrap(function()
        self:if_mounted(function()
          self._private.focused = true
          renderer:set_last_focused_component(self)
          props.on_focus(self)
        end)
      end),
    },
    {
      event = event.BufLeave,
      callback = vim.schedule_wrap(function()
        self:if_mounted(function()
          self._private.focused = false
          renderer:set_last_focused_component(self)
          props.on_blur(self)
        end)
      end),
    },
  }

  local events = fn.concat(default_events, props.events(self), self:events())

  fn.ieach(events, function(tbl)
    self:on(tbl.event, tbl.callback)
  end)
end

function Component:_split_mappings()
  local props = self:get_props()
  local renderer = self:get_renderer()
  local default_global_mappings = {}

  if props.focus_key then
    table.insert(default_global_mappings, {
      mode = { "n", "i", "v" },
      key = props.focus_key,
      handler = function()
        self:focus()
      end,
    })
  end

  local m = fn.concat(props.mappings(self), self:mappings())

  local mappings = fn.ireduce(m, function(acc, mapping)
    table.insert(mapping.global and acc.global or acc.props, mapping)
    return acc
  end, { global = default_global_mappings, props = {} })

  renderer:add_mappings(mappings.global)
  self._private.props_mappings = mappings.props
end

function Component:_attach_mappings()
  local renderer = self:get_renderer()

  local mappings = fn.concat(renderer:get_mappings(self), self._private.props_mappings)

  local map = function(mode, key, handler)
    self:map(mode, key, handler, { noremap = true, silent = true })
  end

  fn.ieach(mappings, function(mapping)
    if type(mapping.mode) == "table" then
      return fn.ieach(mapping.mode, function(mode)
        map(mode, mapping.key, mapping.handler)
      end)
    end

    map(mapping.mode, mapping.key, mapping.handler)
  end)
end

function Component:_set_initial_value()
  self:set_current_value(self:initial_value())
end

function Component:render()
  local children = self:get_children()

  if children then
    return Layout.Box(
      fn.ireduce(children, function(acc, child)
        if not child:is_hidden() then
          table.insert(acc, child:render())
        end

        return acc
      end, {}),
      {
        size = self:get_size(),
        dir = self:get_direction(),
      }
    )
  end

  return Layout.Box(self, { size = self:get_size() })
end

function Component:focus()
  if not self.winid then
    return
  end

  if vim.api.nvim_win_is_valid(self.winid) and self:is_focusable() then
    vim.api.nvim_set_current_win(self.winid)
  end
end

function Component:if_not_mounting_phase_wrap(callback_fn)
  return function(...)
    if not self._private.is_mount_pending then
      return callback_fn(...)
    end
  end
end

function Component:if_not_mounting_phase(callback_fn)
  if not self._private.is_mount_pending then
    return callback_fn()
  end
end

function Component:events()
  return {}
end

function Component:mappings()
  return {}
end

function Component:initial_value()
  return nil
end

function Component:modify_buffer_content(modify_fn)
  self:set_buffer_option("modifiable", true)
  vim.schedule(function()
    modify_fn()
    vim.schedule(function()
      self:set_buffer_option("modifiable", false)
    end)
  end)
end

function Component:hl_group(name)
  return "NuiComponents" .. self.class.name .. (name or "")
end

function Component:if_mounted(call_fn)
  if self:is_mounted() then
    call_fn()
  end
end

function Component:is_hidden()
  local parent = self:get_parent()
  local props = self:get_props()

  if parent then
    return props.hidden or parent:is_hidden()
  end

  return props.hidden
end

function Component:is_focused()
  return self._private.focused
end

function Component:is_focusable()
  return self:get_props().is_focusable
end

function Component:is_mounted()
  return self._.mounted
end

function Component:get_id()
  return self._private.id
end

function Component:get_direction()
  return self:get_props().direction
end

function Component:get_children()
  return self._private.children
end

function Component:get_flatten_children()
  local function rec(components, initial_value)
    return fn.ireduce(components, function(acc, component)
      local children = component:get_children()

      if children then
        rec(children, acc)
      end

      table.insert(acc, component)

      return acc
    end, initial_value)
  end

  return rec(self._private.children, {})
end

function Component:get_only_child()
  return self:get_children()[1]
end

function Component:get_parent()
  return self._private.parent
end

function Component:get_renderer()
  return self._private.renderer
end

function Component:get_props()
  return self._private.props
end

function Component:get_current_value()
  return self._private.current_value
end

function Component:get_focus_index()
  return self._private.focus_index
end

function Component:get_border_delta_size()
  return self.border._.size_delta
end

function Component:get_size()
  return self._private.size:get()
end

function Component:set_border_text(edge, text, align)
  self.border:set_text(edge, text, align)
end

function Component:set_buffer_option(key, value)
  vim.api.nvim_set_option_value(key, value, { buf = self.bufnr })
end

function Component:set_current_value(value)
  self._private.current_value = value
end

function Component:set_focus_index(index)
  self._private.focus_index = index
end

function Component:prop_types()
  return {}
end

function Component:on_update() end

function Component:on_mount() end

function Component:on_unmount() end

function Component:on_layout() end

function Component:on_visibility_change() end

return Component
