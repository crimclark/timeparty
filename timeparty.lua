-- TIME PARTY
--
-- It's Party Time!

local TapeDelay = include('timeparty/lib/TapeDelay')
local Pages = include('timeparty/lib/Pages')

function init()
  TapeDelay.init()
  Pages:init()
  redraw()
end

function redraw()
  Pages:redraw()
end

function key(num, z)
  if num == 3 and z == 1 then
    Pages:update_selected_param()
    redraw()
  end
end

function enc(num, delta)
  if num == 2 then
    local newIndex = Pages:active_index() + util.clamp(delta, -1, 1)
    Pages:new_page(newIndex)
  end

  if num == 3 then
    Pages:update_param(delta)
    redraw()
  end
end
