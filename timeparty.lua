-- *TimeParty*
--
-- Grid based delay sequencer
--
-- E2 : change sequence
-- E3 : change param
-- K3 : select param
--
-- It's Party Time.

local TapeDelay = include('lib/TapeDelay')
local GRID = grid.connect()
local modVals = include('lib/ModVals').new(GRID)
local container = include('lib/SequencersNew').new{GRID = GRID, modVals = modVals}
local Pages = include('lib/PagesNew').new(container.sequencers)
local lfo = include('lib/hnds')

function init()
  init_params()
  TapeDelay.init()
  Pages:init()
  container:start()
  lfo[1].lfo_targets = {'pan'}
  lfo.init()
  redraw()
end

function init_params()
  params:add_number('bpm', 'bpm', 40, 240, 120)
  params:set_action('bpm', function() container:update_tempo() end)
  params:add_control('rate_slew', 'rate slew', controlspec.new(0, 5.0, 'lin'))
  params:set_action('rate_slew', function()
    softcut.rate_slew_time(1, params:get('rate_slew'))
  end)
  params:add_control('pan', 'pan', controlspec.new(-1.0, 1.0, "lin", 0.01, 0.01, ""))
  params:set_action('pan', function(x)
    softcut.pan(1, x)
  end)
end

function lfo.process()
  params:set('pan', lfo.scale(lfo[1].slope, -1.0, 1.0, -100, 100) * 0.01)
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
