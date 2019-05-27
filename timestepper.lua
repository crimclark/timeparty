local clk = require 'beatclock'.new()

local TapeDelay = include('stepdad/lib/stepdad_softcut')
local Pages = include('stepdad/lib/Pages')

function init()
  TapeDelay.init()
  Pages:init()
  redraw()
end

function redraw()
  Pages:redraw()
end

function enc(num, delta)
  local newIndex = Pages:active_index() + util.clamp(delta, -1, 1)
  Pages:new_page(newIndex)
end
