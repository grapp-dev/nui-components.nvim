local Component = require("nui-components.component")
local SignalValue = require("nui-components.signal.value")
local fn = require("nui-components.utils.fn")

local Tabs = Component:extend("Tabs")

function Tabs:init(props)
  Tabs.super.init(
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

  local is_signal_value = fn.isa(props.active_tab, SignalValue)

  if is_signal_value then
    self._private.active_tab = props.active_tab
  end
end

function Tabs:prop_types()
  return {
    active_tab = "string",
  }
end

function Tabs:on_renderer_initialization(...)
  Tabs.super.on_renderer_initialization(self, ...)

  if self._private.active_tab then
    local children = self:get_flatten_children()

    fn.ieach(children, function(child)
      if child.class.name == "Tab" then
        local props = child:get_props()
        local id = child:get_id()

        props.instance:add_signal_value(
          "hidden",
          self._private.active_tab:clone():map(function(tab_id)
            return not (tab_id == id)
          end)
        )
      end
    end)
  end
end

return Tabs
