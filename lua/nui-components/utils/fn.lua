local M = {}

function M.kpairs(t)
  local index
  return function()
    local value
    while true do
      index, value = next(t, index)
      if type(index) ~= "number" or math.floor(index) ~= index then
        break
      end
    end
    return index, value
  end
end

function M.ireduce(tbl, func, acc)
  for i, v in ipairs(tbl) do
    acc = func(acc, v, i)
  end
  return acc
end

function M.kreduce(tbl, func, acc)
  for i, v in pairs(tbl) do
    if type(i) == "string" then
      acc = func(acc, v, i)
    end
  end
  return acc
end

function M.reduce(tbl, func, acc)
  for i, v in pairs(tbl) do
    acc = func(acc, v, i)
  end
  return acc
end

function M.find_index(tbl, func)
  for index, item in ipairs(tbl) do
    if func(item, index) then
      return index
    end
  end

  return nil
end

function M.isome(tbl, func)
  for index, item in ipairs(tbl) do
    if func(item, index) then
      return true
    end
  end

  return false
end

function M.ifind(tbl, func)
  for index, item in ipairs(tbl) do
    if func(item, index) then
      return item
    end
  end

  return nil
end

function M.find_last_index(tbl, func)
  for index = #tbl, 1, -1 do
    if func(tbl[index], index) then
      return index
    end
  end
end

function M.slice(tbl, startIndex, endIndex)
  local sliced = {}
  endIndex = endIndex or #tbl

  for index = startIndex, endIndex do
    table.insert(sliced, tbl[index])
  end

  return sliced
end

function M.concat(...)
  local concatenated = {}

  for _, tbl in ipairs({ ... }) do
    for _, value in ipairs(tbl) do
      table.insert(concatenated, value)
    end
  end

  return concatenated
end

function M.kmap(tbl, func)
  return M.kreduce(tbl, function(new_tbl, value, key)
    table.insert(new_tbl, func(value, key))
    return new_tbl
  end, {})
end

function M.imap(tbl, func)
  return M.ireduce(tbl, function(new_tbl, value, index)
    table.insert(new_tbl, func(value, index))
    return new_tbl
  end, {})
end

function M.ieach(tbl, func)
  for index, element in ipairs(tbl) do
    func(element, index)
  end
end

function M.keach(tbl, func)
  for key, element in M.kpairs(tbl) do
    func(element, key)
  end
end

function M.keys(tbl)
  local keys = {}
  for key, _ in M.kpairs(tbl) do
    table.insert(keys, key)
  end
  return keys
end

function M.indexes(tbl)
  local indexes = {}
  for key, _ in ipairs(tbl) do
    table.insert(indexes, key)
  end
  return indexes
end

function M.bind(func, ...)
  local boundArgs = { ... }

  return function(...)
    return func(M.unpack(boundArgs), ...)
  end
end

function M.ifilter(tbl, pred_fn)
  return M.ireduce(tbl, function(new_tbl, value, index)
    if pred_fn(value, index) then
      table.insert(new_tbl, value)
    end
    return new_tbl
  end, {})
end

function M.ireject(tbl, pred_fn)
  return M.ifilter(tbl, function(value, index)
    return not pred_fn(value, index)
  end)
end

function M.kfilter(tbl, pred_fn)
  return M.kreduce(tbl, function(new_tbl, value, key)
    if pred_fn(value, key) then
      new_tbl[key] = value
    end
    return new_tbl
  end, {})
end

function M.kreject(tbl, pred_fn)
  return M.kfilter(tbl, function(value, index)
    return not pred_fn(value, index)
  end)
end

function M.switch(param, t)
  local case = t[param]
  if case then
    return case()
  end
  local defaultFn = t["default"]
  return defaultFn and defaultFn() or nil
end

function M.trim(str)
  return (str:gsub("^%s*(.-)%s*$", "%1"))
end

function M.ignore() end

function M.always(value)
  return function()
    return value
  end
end

function M.identity(value)
  return value
end

function M.debounce(fn, ms)
  local timer = vim.loop.new_timer()

  local function wrapped_fn(...)
    local args = { ... }
    timer:stop()
    timer:start(ms, 0, function()
      pcall(
        vim.schedule_wrap(function(...)
          fn(...)
          timer:stop()
        end),
        select(1, M.unpack(args))
      )
    end)
  end
  return wrapped_fn, timer
end

M.pack = table.pack or function(...)
  return { n = select("#", ...), ... }
end

---@diagnostic disable-next-line: deprecated
M.unpack = table.unpack or unpack

function M.eq(x, y)
  return x == y
end

function M.constant(x)
  return function()
    return x
  end
end

function M.clamp(value, min, max)
  return math.min(math.max(value, min), max)
end

function M.isa(object, class)
  local mt = getmetatable(object)

  if mt and object then
    return type(object) == "table" and mt.__index == class
  end

  return false
end

function M.try_with_observer(observer, fn, ...)
  local success, result = pcall(fn, ...)
  if not success then
    observer:on_error(result)
  end
  return success, result
end

function M.default_to(value, default_value)
  return vim.F.if_nil(value, default_value)
end

function M.merge(fst, snd)
  return vim.tbl_extend("force", fst, M.default_to(snd, {}))
end

function M.deep_merge(fst, snd)
  return vim.tbl_deep_extend("force", fst, M.default_to(snd, {}))
end

function M.preserve_cursor_position(fn)
  local line, col = M.unpack(vim.api.nvim_win_get_cursor(0))

  fn()

  vim.schedule(function()
    local lastline = vim.fn.line("$")

    if line > lastline then
      line = lastline
    end

    vim.api.nvim_win_set_cursor(0, { line, col })
  end)
end

function M.log(...)
  local is_fidget_installed, fidget = pcall(require, "fidget")
  local debug_value = vim.inspect({ ... })

  if is_fidget_installed then
    return fidget.notify(debug_value)
  end

  vim.notify(debug_value)
end

return M
