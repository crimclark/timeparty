-- *TimeParty*
--
-- Grid based delay sequencer/interstellar party starter
--
-- E2 : change sequence/page
-- E3 : change param
-- K3 : select param
-- K2 : freeze
--
-- v1 by @crim
-- llllllll.co/t/22837

local delay = include('lib/delay')
local seqContainer = include('lib/sequencers')
local Pages = include('lib/Pages')
local lfo = include('lib/hnds')

local CROW_TRIGGER_STEP = 'trigger step'
local crowOptions1 = {'off', 'reverse', 'freeze'}
local crowOptions2 = {'off', 'reverse', 'freeze', CROW_TRIGGER_STEP}
local toggle = {'on', 'off'}
local rateModes = {'perfect', 'major', 'minor'}

local hasCrowTrigger = false

function crow_trigger()
  seqContainer:count()
end

function toggle_freeze()
  params:set('freeze', params:get('freeze') == 2 and 1 or 2)
  redraw()
end

function toggle_reverse()
  params:set('rate', -params:get('rate'))
end

local crowFunctionsInput1 = {function() end, toggle_reverse, toggle_freeze}
local crowFunctionsInput2 = {function() end, crow_trigger, toggle_reverse, toggle_freeze}
local crowFunctions = {crowFunctionsInput1, crowFunctionsInput2 }
local pages = {}

function init()
  norns.enc.sens(2,3)
  norns.enc.sens(3,2)
  init_params()
  lfo[1].lfo_targets = {'pan'}
  lfo.init()
  delay.init()
  seqContainer:init()
  seqContainer:start()
  pages = Pages.new(seqContainer.sequencers)
  pages:init()

  for i=1,2 do
    crow.input[i].mode('change', 1, 0.05, 'rising')
    crow.input[i].change = function()
      local fnIdx = params:get('crow_input'..i)
      crowFunctions[i][fnIdx]()
    end
  end

  redraw()
end

function update_crow_input2(i)
  if crowOptions2[i] == CROW_TRIGGER_STEP then
    hasCrowTrigger = true
    seqContainer:stop()
  elseif hasCrowTrigger then
    hasCrowTrigger = false
    seqContainer:start()
  end
end

function init_params()
  params:add_group('internal', 4)
  params:hide('internal')
  params:add_control('rate', 'rate', controlspec.new(-65, 65, 'lin', 0.01, 1, ''))
  params:set_action('rate', function(x) softcut.rate(1, x) end)
  params:add_control('pan', 'pan', controlspec.new(-1.0, 1.0, 'lin', 0.01, 0.01, ''))
  params:set_action('pan', function(v) softcut.pan(1, v) end)
  params:add_control('filter_cutoff', 'filter cutoff', controlspec.new(10, 12000, 'exp', 1, 12000, 'Hz'))
  params:set_action('filter_cutoff', function(x) softcut.post_filter_fc(1, x) end)
  params:add_control('autopan_freq', 'autopan freq', controlspec.new(0.001, 25, 'lin', 0.001, 0, ''))
  params:set_action('autopan_freq', function(value) lfo[1].freq = value end)

  params:add_option('crow_input1', 'crow input 1', crowOptions1, 1)
  params:add_option('crow_input2', 'crow input 2', crowOptions2, 1)
  params:set_action('crow_input2', update_crow_input2)
  params:add_option('rate_mode', 'rate mode', rateModes, 1)
  params:set_action('rate_mode', function(i) seqContainer:update_rate_mode(rateModes[i]) end)
  params:add_control('rate_slew', 'rate slew', controlspec.new(0, 1, 'lin', 0, 0.1, ''))
  params:set_action('rate_slew', function() softcut.rate_slew_time(1, params:get('rate_slew')) end)
  params:add_option('freeze', 'freeze', toggle, 2)
  params:set_action('freeze', function(i) softcut.rec(1, i - 1) end)
  params:add_control('filter_q', 'filter q', controlspec.new(0.0005, 8.0, 'exp', 0, 1.0, ''))
  params:set_action('filter_q', function(x) softcut.post_filter_rq(1, x) softcut.pre_filter_rq(1, x) end)
  params:add_control('low_pass', 'low pass', controlspec.new(0, 1, 'lin', 0, 1, ''))
  params:set_action('low_pass', function(x) softcut.post_filter_lp(1, x) softcut.pre_filter_lp(1, x) end)
  params:add_control('high_pass', 'high pass', controlspec.new(0, 1, 'lin', 0, 0, ''))
  params:set_action('high_pass', function(x) softcut.post_filter_hp(1, x) softcut.pre_filter_hp(1, x) end)
  params:add_control('band_pass', 'band pass', controlspec.new(0, 1, 'lin', 0, 0, ''))
  params:set_action('band_pass', function(x) softcut.post_filter_bp(1, x) softcut.pre_filter_bp(1, x) end)
  params:add_option('autopan_shape', 'autopan shape', lfo.options.lfotypes, 1)
  params:set_action('autopan_shape', function(value) lfo[1].waveform = lfo.options.lfotypes[value] end)
  params:add_number('autopan_depth', 'autopan depth', 0, 100, 100)
  params:set_action('autopan_depth', function(value) lfo[1].depth = value end)
end

function lfo.process()
  params:set('pan', lfo.scale(lfo[1].slope, -1.0, 1.0, -100, 100) * 0.01)
end

function redraw() pages:redraw() end

function key(num, z)
  if num == 3 and z == 1 then
    pages:update_selected_param()
    redraw()
  elseif num == 2 and z == 1 then
    toggle_freeze()
  end
end

function enc(num, delta)
  if num == 2 then
    local newIndex = pages:active_index() + util.clamp(delta, -1, 1)
    pages:new_page(newIndex)
  elseif num == 3 then
    pages:update_param(delta)
    redraw()
  end
end
