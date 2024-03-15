local Box = require("nui-components.box")
local Columns = require("nui-components.columns")
local Form = require("nui-components.form")
local Gap = require("nui-components.gap")
local Line = require("nui.line")
local Rows = require("nui-components.rows")
local Select = require("nui-components.select")
local Tab = require("nui-components.tab")
local Tabs = require("nui-components.tabs")

local SignalValue = require("nui-components.signal.value")
local fn = require("nui-components.utils.fn")

local M = {}

local function normalize_layout_props(constructor)
  return function(props, ...)
    local children = { ... }

    if not props.size and not props.flex then
      table.insert(children, 1, props)

      return constructor({ flex = 1, children = children })
    end

    if type(props) == "number" then
      return constructor({ flex = props, children = children })
    end

    return constructor(fn.merge(props, { children = children }))
  end
end

local function add_children_prop(constructor)
  return function(props, ...)
    props = props or {}
    props.children = { ... }
    return constructor(props)
  end
end

function M.is_active_factory(value)
  local is_signal_value = fn.isa(value, SignalValue)

  return function(arg1)
    if is_signal_value then
      return value:dup():map(function(arg0)
        return arg0 == arg1
      end)
    end

    return value == arg1
  end
end

M.create_renderer = require("nui-components.renderer").create
M.text_input = require("nui-components.text-input")
M.prompt = require("nui-components.prompt")
M.select = Select
M.option = Select.option
M.separator = Select.separator
M.tree = require("nui-components.tree")
M.button = require("nui-components.button")
M.checkbox = require("nui-components.checkbox")
M.paragraph = require("nui-components.paragraph")
M.spinner = require("nui-components.spinner")

M.tabs = add_children_prop(Tabs)
M.tab = add_children_prop(Tab)

function M.gap(props)
  if type(props) == "number" then
    props = { size = props }
  end

  return Gap(props)
end

M.box = normalize_layout_props(Box)
M.columns = normalize_layout_props(Columns)
M.rows = normalize_layout_props(Rows)
M.form = add_children_prop(Form)

M.text = require("nui.text")

function M.line(...)
  local count = select("#", ...)
  local texts = {}

  if count == 1 then
    texts = fn.pack(...)
  else
    texts = { ... }
  end

  texts = fn.imap(texts, function(text)
    if type(text) == "string" then
      return M.text(text)
    end

    return text
  end)

  return Line(texts)
end

M.create_signal = require("nui-components.signal").create
M.validator = require("nui-components.validators")

return M
