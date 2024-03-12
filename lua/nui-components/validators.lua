local M = {}

function M.min_length(min)
  return function(arg)
    return #arg >= min
  end
end

M.is_not_empty = M.min_length(1)

function M.max_length(max)
  return function(arg)
    return #arg <= max
  end
end

function M.contains(pattern)
  return function(arg)
    return string.find(arg, pattern)
  end
end

function M.equals(value)
  return function(arg)
    return vim.deep_equal(value, arg)
  end
end

function M.compose(...)
  local tbl = { ... }

  return function(value)
    for _, fn in ipairs(tbl) do
      if not fn(value) then
        return false
      end
    end

    return true
  end
end

return M
