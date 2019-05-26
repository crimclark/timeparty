local clk = require 'beatclock'.new()

local TapeDelay = include('stepdad/lib/stepdad_softcut')
local Pages = include('stepdad/lib/Pages')

function init()
  start_clock()
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

-- todo: need new way of defining bpm so can get rid of this
function start_clock()
  local clk_midi = midi.connect()
  clk_midi.event = clk.process_midi
  clk:add_clock_params()
  clk.on_select_internal = function() clk:start() end
  clk.on_select_external = function() print('external') end
end
