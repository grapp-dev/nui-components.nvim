local M = {}

local direction_matchers = {
  left = function(current, other)
    return other.x + other.width < current.x
  end,
  right = function(current, other)
    return other.x > current.x + current.width
  end,
  up = function(current, other)
    return other.y + other.height < current.y
  end,
  down = function(current, other)
    return other.y > current.y + current.height
  end,
}

function M.match_direction(direction, current_geometry, other_geometry)
  return direction_matchers[direction](current_geometry, other_geometry)
end

function M.win_get_geometry(winid)
  local y, x = unpack(vim.api.nvim_win_get_position(winid))
  return {
    width = vim.api.nvim_win_get_width(winid),
    height = vim.api.nvim_win_get_height(winid),
    x = x,
    y = y,
  }
end

function M.distance(a, b)
  return math.sqrt((a.x - b.x) ^ 2 + (a.y - b.y) ^ 2)
end

function M.distance_x(a, b)
  return math.abs(a.x - b.x)
end

function M.distance_y(a, b)
  return math.abs(a.y - b.y)
end

return M
