local Component = require("nui-components.component")

local Line = require("nui.line")
local NuiTree = require("nui.tree")

local event = require("nui.utils.autocmd").event
local fn = require("nui-components.utils.fn")

local function focus_item(instance, direction, current_linenr)
  local actions = instance:get_actions()
  ---@type NuiTree
  local tree = instance:get_tree()

  local curr_linenr = current_linenr or vim.api.nvim_win_get_cursor(instance.winid)[1]
  local next_linenr = nil

  local function tree_height(node_id)
    local height = 1
    local node = tree:get_node(node_id)
    if node and node:has_children() and node:is_expanded() then
      for _, child in ipairs(node:get_child_ids()) do
        height = height + tree_height(child)
      end
    end
    return height
  end

  local height = fn.ireduce(tree:get_nodes(), function(acc, node)
    return acc + tree_height(node._id)
  end, 0)

  if direction == "next" then
    if curr_linenr == height then
      next_linenr = 1
    else
      next_linenr = curr_linenr + 1
    end
  elseif direction == "prev" then
    if curr_linenr == 1 then
      next_linenr = height
    else
      next_linenr = curr_linenr - 1
    end
  end

  local next_node = tree:get_node(next_linenr)

  if next_node then
    if actions.should_skip_item(next_node) then
      return focus_item(instance, direction, next_linenr)
    end
  end

  if next_linenr then
    vim.api.nvim_win_set_cursor(instance.winid, { next_linenr, 0 })
    actions.on_change(next_node)
  end
end

local Tree = Component:extend("Tree")

function Tree:init(props, popup_options)
  props = fn.merge({
    size = 1,
    on_select = fn.ignore,
    on_change = fn.ignore,
    data = {},
  }, props)

  popup_options = fn.deep_merge({
    win_options = {
      cursorline = true,
      scrolloff = 1,
      sidescrolloff = 0,
    },
    border = {
      style = props.style,
    },
  }, popup_options)

  Tree.super.init(self, props, popup_options)

  self._private.namespace = vim.api.nvim_create_namespace(self:get_id())
end

function Tree:prop_types()
  return {
    on_select = "function",
    on_change = "function",
    data = "table",
    prepare_node = { "function", "nil" },
    should_skip_item = { "function", "nil" },
  }
end

function Tree:on_renderer_initialization(...)
  Tree.super.on_renderer_initialization(self, ...)
  self:_set_actions()
end

function Tree:mappings()
  local function action(key)
    return function()
      local actions = self:get_actions()
      actions[key]()
    end
  end
  local mode = { "i", "n", "v" }

  return {
    { mode = mode, key = { "<CR>", "<Space>" }, handler = action("on_select") },
    { mode = mode, key = { "j", "<Down>" }, handler = action("on_focus_next") },
    { mode = mode, key = { "k", "<Up>" }, handler = action("on_focus_prev") },
  }
end

function Tree:get_focused_node()
  return self._private.focused_node
end

function Tree:set_focused_node(node)
  self._private.focused_node = node
end

function Tree:get_max_lines()
  return self._private.max_lines
end

function Tree:_set_max_lines()
  local tree = self:get_tree()

  local function rec(node_ids, initial_value)
    return fn.ireduce(node_ids, function(acc, node_id)
      local node = tree:get_node(node_id)

      if not node then
        return acc
      end

      local child_ids = node:get_child_ids()

      if #child_ids > 0 then
        return rec(child_ids, acc)
      end

      return acc + (node:get_depth() > 1 and 1 or 0)
    end, initial_value)
  end

  local nodes = tree:get_nodes()

  self._private.max_lines = rec(
    fn.imap(nodes, function(node)
      return node._id
    end),
    #nodes
  )
end

function Tree:get_actions()
  return self._private.actions
end

function Tree:events()
  return {
    {
      event = event.BufEnter,
      handler = vim.schedule_wrap(function()
        local tree = self:get_tree()

        self:_set_line_hl()

        if tree and self.winid then
          local focused_node = self:get_focused_node()
          local _, line = tree:get_node(focused_node and focused_node._id or 1)
          line = line or 1
          vim.api.nvim_win_set_cursor(self.winid, { line, 0 })
        end
      end),
    },
  }
end

function Tree:_set_actions()
  local props = self:get_props()

  local default_actions = {
    prepare_node = function(node)
      local line = Line()

      if props.prepare_node then
        return props.prepare_node(node, line, self)
      end

      return line
    end,
    should_skip_item = function(node)
      if props.should_skip_item then
        return props.should_skip_item(node)
      end

      return false
    end,
    on_focus_next = function()
      focus_item(self, "next")
    end,
    on_focus_prev = function()
      focus_item(self, "prev")
    end,
    on_change = function(node)
      self:set_focused_node(node)
      props.on_change(node, self)
    end,
    on_select = function()
      if props.on_select then
        props.on_select(self:get_focused_node(), self)
      end
    end,
  }

  self._private.actions = fn.merge(default_actions, self:actions())
end

function Tree:_set_line_hl()
  if not self.winid then
    return
  end

  if vim.api.nvim_win_is_valid(self.winid) then
    vim.api.nvim_set_hl(self._private.namespace, "CursorLine", { link = self:hl_group("NodeFocused") })
    vim.api.nvim_win_set_hl_ns(self.winid, self._private.namespace)
  end
end

function Tree:actions()
  return {}
end

function Tree:get_tree()
  return self._private.tree
end

function Tree:on_update()
  self:if_not_mounting_phase(function()
    local tree = self:get_tree()
    local props = self:get_props()

    if tree then
      local focused_node = self:get_focused_node()

      local _, line = tree:get_node(focused_node and focused_node._id or 1)
      line = line or 1

      if #props.data > 0 then
        tree:set_nodes(props.data)
        tree:render()
        self:_set_max_lines()
        self:set_focused_node(tree:get_node(line))
      else
        tree:set_nodes({})
        tree:render()
        self:_set_max_lines()
        self:set_focused_node(nil)
      end
    end
  end)
end

function Tree:on_mount()
  local props = self:get_props()
  local actions = self:get_actions()

  self._private.tree = NuiTree({
    bufnr = self.bufnr,
    ns_id = self.ns_id,
    nodes = props.data,
    get_node_id = function(node)
      if node._id == nil then
        if node.id then
          node._id = node.id
        else
          node._id = tostring(math.random())
        end
      end
      return node._id
    end,
    prepare_node = actions.prepare_node,
  })

  self._private.tree:render()
  self:_set_max_lines()
  self:set_focused_node(self._private.tree:get_node(1))
end

return Tree
