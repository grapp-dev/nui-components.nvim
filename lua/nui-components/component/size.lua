local fn = require("nui-components.utils.fn")

local Size = {}

Size.__index = Size
Size.__tostring = fn.always("Size")

function Size.create(component)
  local self = {
    _private = {
      component = component,
    },
  }

  return setmetatable(self, Size)
end

function Size:_of(width, height)
  return {
    width = width,
    height = height,
  }
end

function Size:_get_children_content_size()
  local component = self._private.component
  local children = component:get_children()
  local direction = component:get_direction()

  return fn.ireduce(children, function(acc, child)
    local props = child:get_props()
    local on_layout_value = child:on_layout()
    local border_delta_size = child:get_border_delta_size()

    if on_layout_value then
      local height = on_layout_value.height + border_delta_size.height

      if direction == "column" then
        return acc + height
      end

      return math.max(acc, height)
    end

    if props.size then
      return math.max(acc, props.size)
    end

    return acc
  end, 0)
end

function Size:_get_siblings_total_size()
  local component = self._private.component
  local parent = component:get_parent()
  local children = parent:get_children()
  local direction = parent:get_direction()

  return fn.ireduce(children, function(acc, child)
    local props = child:get_props()
    local size

    if not (child:get_id() == component:get_id()) and not child:is_hidden() then
      if props.flex then
        if props.flex == 0 then
          size = child:get_size()
        end
      else
        size = child:get_size()
      end
    end

    if size then
      return acc + (direction == "row" and size.width or size.height)
    end

    return acc
  end, 0)
end

function Size:_get_siblings_total_flex()
  local component = self._private.component
  local parent = component:get_parent()
  local children = parent:get_children()

  return fn.ireduce(children, function(acc, child)
    local props = child:get_props()

    if props.flex and not child:is_hidden() then
      return acc + props.flex
    end

    return acc
  end, 0)
end

function Size:_include_border_size(size)
  local component = self._private.component
  local parent = component:get_parent()

  if parent then
    local parent_direction = parent:get_direction()
    local border_delta_size = component:get_border_delta_size()
    return size + (parent_direction == "row" and border_delta_size.width or border_delta_size.height)
  end

  return size
end

function Size:_use_content()
  local component = self._private.component
  local children = component:get_children()

  if children then
    local parent = component:get_parent()
    local parent_direction = parent:get_direction()
    local parent_size = parent:get_size()
    local children_content_size = self:_get_children_content_size()

    if parent_direction == "column" then
      return self:_of(parent_size.width, children_content_size)
    end

    return self:_of(children_content_size, parent_size.height)
  end

  return error("component " .. component:get_id() .. " has no children")
end

function Size:_use_flex()
  local component = self._private.component
  local props = component:get_props()
  local parent = component:get_parent()
  local parent_direction = parent:get_direction()
  local parent_size = parent:get_size()

  local parent_children = parent:get_children()

  local siblings_total_size = self:_get_siblings_total_size()
  local siblings_total_flex = self:_get_siblings_total_flex()

  local calculate = function(value)
    return math.floor((value - siblings_total_size) / siblings_total_flex * props.flex + 0.5)
  end

  local size = parent_direction == "row" and parent_size.width or parent_size.height
  local flex = calculate(size)

  local id = component:get_id()
  local is_last_child = parent_children[#parent_children]:get_id() == id

  if is_last_child then
    local siblings_size = fn.ireduce(parent_children, function(acc, child)
      if child:get_id() == id then
        return acc
      end

      local child_size = child:get_size()
      return acc + (parent_direction == "row" and child_size.width or child_size.height)
    end, 0)

    local total = siblings_size + flex

    if total > size then
      local diff_size = total - size
      flex = flex - diff_size
    end
  end

  if parent_direction == "row" then
    return self:_of(flex, parent_size.height)
  end

  return self:_of(parent_size.width, flex)
end

function Size:_use_size()
  local component = self._private.component
  local on_layout_value = component:on_layout()
  local props = component:get_props()

  local parent = component:get_parent()
  local parent_direction = parent:get_direction()
  local parent_size = parent:get_size()

  if on_layout_value then
    if parent_direction == "row" then
      return self:_of(self:_include_border_size(on_layout_value.width), parent_size.height)
    end

    return self:_of(parent_size.width, self:_include_border_size(on_layout_value.height))
  end

  local size = self:_include_border_size(props.size)

  if parent_direction == "row" then
    return self:_of(size, parent_size.height)
  end

  return self:_of(parent_size.width, size)
end

function Size:get()
  local component = self._private.component
  local renderer = component:get_renderer()
  local parent = component:get_parent()
  local is_hidden = component:is_hidden()

  if is_hidden then
    return self:_of(0, 0)
  end

  if not parent then
    local renderer_layout_options = renderer:get_layout_options()
    return self:_of(renderer_layout_options.size.width, renderer_layout_options.size.height)
  end

  local props = component:get_props()

  if type(props.flex) == "number" then
    if props.flex == 0 then
      return self:_use_content()
    end

    return self:_use_flex()
  end

  return self:_use_size()
end

return Size
