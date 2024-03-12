local Component = require("nui-components.component")

local fn = require("nui-components.utils.fn")

local Tab = Component:extend("Tab")

function Tab:init(props)
  Tab.super.init(
    self,
    fn.merge(
      {
        flex = 1,
        direction = "column",
      },
      fn.merge(props, {
        is_focusable = false,
      })
    ),
    {
      focusable = false,
    }
  )
end

function Tab:on_visibility_change()
  self:if_not_mounting_phase(function()
    if self:is_hidden() then
      return self:_set_last_focused_component()
    end

    self:_restore_focus()
  end)
end

function Tab:_restore_focus()
  local renderer = self:get_renderer()

  renderer:schedule(function()
    local function fallback()
      local children = self:get_flatten_children()

      local autofocus_component = fn.ifind(children, function(child)
        local props = child:get_props()
        return props.autofocus
      end)

      local first_focusable_component = autofocus_component

      if not first_focusable_component then
        first_focusable_component = fn.ifind(children, function(child)
          local props = child:get_props()

          if props.autofocus then
            return true
          end

          return child:is_focusable() and not child:is_hidden()
        end)
      end

      if first_focusable_component then
        first_focusable_component:focus()
      end
    end

    if self._private.last_focused_component then
      local is_ok = pcall(function()
        self._private.last_focused_component:focus()
      end)

      if not is_ok then
        fallback()
      end
    else
      fallback()
    end
  end)
end

function Tab:_set_last_focused_component()
  local renderer = self:get_renderer()
  local last_focused_component = renderer:get_last_focused_component()

  if last_focused_component then
    local children = self:get_flatten_children()

    local is_inside_tab = fn.isome(children, function(child)
      return child:get_id() == last_focused_component:get_id()
    end)

    if is_inside_tab then
      self._private.last_focused_component = last_focused_component
    end
  end
end

return Tab
