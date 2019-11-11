-- *TimeParty*
--
-- Grid based delay sequencer
--
-- E2 : change sequence
-- E3 : change param
-- K3 : select param
--
-- It's Party Time.

local TapeDelay = include('timeparty/lib/TapeDelay')
local GRID = grid.connect()
local modVals = include('timeparty/lib/ModVals').new(GRID)
local container = include('timeparty/lib/SequencersNew').new{GRID = GRID, modVals = modVals}
local Pages = include('timeparty/lib/PagesNew').new(container.sequencers)

function init()
  print('rate vals!!')
  for i,v in ipairs(modVals.rateVals) do print(v) end
  print('time vals!!')
  for i,v in ipairs(modVals.timeVals) do print(v) end
  init_params()
  TapeDelay.init()
  Pages:init()
  container:start()
  redraw()
end

function init_params()
  params:add_number('bpm', 'bpm', 40, 240, 120)
  params:set_action('bpm', function() container:update_tempo() end)
  params:add_control('rate_slew', 'Rate Slew', controlspec.new(0, 5.0, 'lin'))
  params:set_action('rate_slew', function()
    softcut.rate_slew_time(1, params:get('rate_slew'))
  end)
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
