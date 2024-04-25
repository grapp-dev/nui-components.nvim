local Tree = require("nui-components.tree")

local Line = require("nui.line")
local NuiTree = require("nui.tree")

local is_type = require("nui.utils").is_type
local fn = require("nui-components.utils.fn")

local Select = Tree:extend("Select")

local function pred_selected_fn(node_or_id)
  return function(item)
    if item then
      return item.id == node_or_id._id
    end

    return false
  end
end

function Select.option(content, data)
  if not data then
    if is_type("table", content) and content.text then
      data = content
    else
      data = { text = content }
    end
  else
    data.text = content
  end

  data._type = "option"
  data._id = data.id or tostring(math.random())

  return NuiTree.Node(data)
end

function Select.separator(content)
  return NuiTree.Node({
    _id = tostring(math.random()),
    _type = "separator",
    text = fn.default_to(content, ""),
  })
end

function Select:init(props, popup_options)
  props = fn.merge({
    size = 1,
    selected = {},
    border_style = "rounded",
    data = {},
  }, props)

  Select.super.init(self, props, popup_options)
end

function Select:prop_types()
  return fn.merge(Select.super.prop_types(self), {
    selected = { "table", "nil" },
    multiselect = { "boolean", "nil" },
  })
end

function Select:initial_value()
  local props = self:get_props()
  return props.selected
end

function Select:get_current_value()
  local props = self:get_props()
  local nodes = Select.super.get_current_value(self)

  if props.instance:is_signal("selected") then
    nodes = props.selected
  end

  local function map_fn(node_or_id)
    if type(node_or_id) == "string" then
      return { id = node_or_id }
    end

    return node_or_id
  end

  if props.multiselect then
    return fn.imap(nodes, map_fn)
  end

  return map_fn(nodes)
end

function Select:actions()
  local props = self:get_props()

  return {
    prepare_node = function(node)
      local current_value = self:get_current_value()
      local is_selected_fn = pred_selected_fn(node)
      local is_selected = props.multiselect and fn.isome(current_value, is_selected_fn) or is_selected_fn(current_value)

      if props.prepare_node then
        return props.prepare_node(is_selected, node, self)
      end

      local line = Line()

      if is_selected then
        line:append(node.text, self:hl_group("OptionSelected"))
      else
        local is_separator = node._type == "separator"
        line:append(node.text, self:hl_group(is_separator and "Separator" or "Option"))
      end

      return line
    end,
    should_skip_item = function(node)
      local is_separator = node._type == "separator"

      if props.should_skip_item then
        return props.should_skip_item(node, is_separator)
      end

      return is_separator
    end,
    on_select = function()
      local current_value = self:get_current_value()
      local tree = self:get_tree()
      local focused_node = self:get_focused_node()

      local obj = vim.deepcopy(focused_node)
      local is_selected_fn = pred_selected_fn(focused_node)

      if props.multiselect then
        local index = fn.find_index(current_value, is_selected_fn)

        if index then
          table.remove(current_value, index)
        else
          table.insert(current_value, obj)
        end
      else
        local is_selected = is_selected_fn(current_value)
        current_value = is_selected and nil or obj
      end

      self:set_current_value(current_value)
      tree:render()
      props.on_select(current_value, self)
    end,
  }
end

return Select
