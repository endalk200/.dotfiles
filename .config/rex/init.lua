local function is_neovim(ctx)
  local process = rex.block.call('com.superlogical.terminal', 'process', { block_id = ctx.block_id })
  local foreground = process and process.foreground
  if not foreground then
    return false
  end

  local executable = (foreground.argv0 or ''):match '[^/]+$'
  return foreground.name == 'nvim' or executable == 'nvim'
end

local directions = {
  h = 'left',
  j = 'down',
  k = 'up',
  l = 'right',
}

for key, direction in pairs(directions) do
  local shortcut = 'ctrl+' .. key

  rex.bind(shortcut, function(ctx)
    -- Neovim handles its splits, then asks Rex to move at the edge.
    if is_neovim(ctx) then
      return false
    end

    local result = rex.session.focus_direction { direction = direction, wrap = false }
    return result ~= nil
  end)
end
