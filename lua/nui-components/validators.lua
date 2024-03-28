local M = {}

---@type fun(min: integer): fun(arg: string): boolean
function M.min_length(min)
  return function(arg)
    return #arg >= min
  end
end

---@type fun(arg: string): boolean
M.is_not_empty = M.min_length(1)

function M.max_length(max)
  return function(arg)
    return #arg <= max
  end
end

---@type fun(pattern: string): fun(arg: string): boolean
function M.contains(pattern)
  return function(arg)
    return string.find(arg, pattern) ~= nil
  end
end

---@type fun(value: any): fun(arg: any): boolean
function M.equals(value)
  return function(arg)
    return vim.deep_equal(value, arg)
  end
end

---@type fun(...: fun(arg: any): boolean): fun(arg: any): boolean
function M.none(...)
  local validators = { ... }
  return function(value)
    for _, fn in ipairs(validators) do
      if fn(value) then
        return false
      end
    end
    return true
  end
end

---@type fun(...: fun(arg: any): boolean): fun(arg: any): boolean
function M.any(...)
  local validators = { ... }
  return function(value)
    for _, fn in ipairs(validators) do
      if fn(value) then
        return true
      end
    end
    return false
  end
end

---@type fun(...: fun(arg: any): boolean): fun(arg: any): boolean
local function all(...)
  local validators = { ... }

  return function(value)
    for _, fn in ipairs(validators) do
      if not fn(value) then
        return false
      end
    end

    return true
  end
end

M.all = all

M.compose = all

return M
