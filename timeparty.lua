-- *TimeParty*
--
-- Grid based interstellar party starter
--
-- E2 : change sequence
-- E3 : change param
-- K3 : select param
-- K2 : Freeze
--

local TapeDelay = include('lib/TapeDelay')
local GRID = grid.connect()
local modVals = include('lib/ModVals').new(GRID)
local container = include('lib/Sequencers').new{GRID = GRID, modVals = modVals}
local sequencers = container.sequencers
local Pages = include('lib/Pages').new(sequencers)
local lfo = include('lib/hnds')

local crowClock = false

local lastTapTime = 0
local lastTapDelta = 1

local function sync()
  local t = util.time()
  lastTapDelta = t - lastTapTime
  lastTapTime = t
  params:set('bpm', 60/lastTapDelta)
end

local function crow_clock()
  local crowSync = false
  for i=1,2 do
    if params:get('crow_input'..i) == 3 then
      crowSync = true
    end
  end
  for _, v in pairs(sequencers) do v:count()() end
  if not crowSync then sync() end
end

local function toggle_freeze()
  params:set('freeze', params:get('freeze') == 2 and 1 or 2)
  redraw()
end

local function toggle_reverse()
  params:set('rate', -params:get('rate'))
end

local crowOptions = {'off', 'clock', 'sync', 'reverse', 'freeze'}
local crowFunctions = {function() end, crow_clock, sync, toggle_reverse, toggle_freeze}
local toggle = {'on', 'off'}
local rateModes = {'perfect', 'major', 'minor'}

function init()
  init_params()
  lfo[1].lfo_targets = {'pan'}
  lfo.init()
  TapeDelay.init()
  Pages:init()
  container:bang()
  container:start()

  for i=1,2 do
    crow.input[i].mode('change', 1, 0.05, 'rising')
    crow.input[i].change = function(s)
      local fnIdx = params:get('crow_input'..i)
      crowFunctions[fnIdx]()
    end
  end

  redraw()
end

function update_crow_input()
  local hasCrowClock = false
  for i=1,2 do
    if crowOptions[params:get('crow_input'..i)] == 'clock' then hasCrowClock = true end
  end

  if hasCrowClock and not crowClock then
    crowClock = true
    container:stop()
  elseif crowClock then
    crowClock = false
    container:start()
  end
end

function init_params()
  params:add_number('bpm', 'bpm', 20, 999, 120)
  params:set_action('bpm', function() container:update_tempo() end)
  for i=1,2 do
    params:add_option('crow_input'..i, 'crow input '..i, crowOptions, 1)
    params:set_action('crow_input'..i, update_crow_input)
  end
  params:add_control("rate", "rate", controlspec.new(-65, 65, "lin", 0.01, 1, ""))
  params:set_action("rate", function(x) softcut.rate(1, x) end)
  params:add_option('rate_mode', 'rate mode', rateModes, 1)
  params:set_action('rate_mode', function(i) sequencers.rate.modVals = modVals[rateModes[i]] end)
  params:add_control('rate_slew', 'rate slew', controlspec.new(0, 1, "lin", 0, 0.1, ""))
  params:set_action('rate_slew', function() softcut.rate_slew_time(1, params:get('rate_slew')) end)
  params:add_option('freeze', 'freeze', toggle, 2)
  params:set_action('freeze', function(i) softcut.rec(1, i - 1) end)
  params:add_control('pan', 'pan', controlspec.new(-1.0, 1.0, "lin", 0.01, 0.01, ""))
  params:set_action('pan', function(v) softcut.pan(1, v) end)
  params:add_control("filter_cutoff", "filter cutoff", controlspec.new(10, 12000, 'exp', 1, 12000, "Hz"))
  params:set_action("filter_cutoff", function(x) softcut.post_filter_fc(1, x) softcut.pre_filter_fc(1, x) end)
  params:add_control("filter_q", "filter q", controlspec.new(0.0005, 8.0, 'exp', 0, 5.0, ""))
  params:set_action("filter_q", function(x) softcut.post_filter_rq(1, x) softcut.pre_filter_rq(1, x) end)
  params:add_control("low_pass", "low pass", controlspec.new(0, 1, 'lin', 0, 1, ""))
  params:set_action("low_pass", function(x) softcut.post_filter_lp(1, x) softcut.pre_filter_lp(1, x) end)
  params:add_control("high_pass", "high pass", controlspec.new(0, 1, 'lin', 0, 0, ""))
  params:set_action("high_pass", function(x) softcut.post_filter_hp(1, x) softcut.pre_filter_hp(1, x) end)
  params:add_control("band_pass", "band pass", controlspec.new(0, 1, 'lin', 0, 0, ""))
  params:set_action("band_pass", function(x) softcut.post_filter_bp(1, x) softcut.pre_filter_bp(1, x) end)
  params:add_option("autopan_shape", "autopan shape", lfo.options.lfotypes, 1)
  params:set_action("autopan_shape", function(value) lfo[1].waveform = lfo.options.lfotypes[value] end)
  params:add_number("autopan_depth", "autopan depth", 0, 100, 100)
  params:set_action("autopan_depth", function(value) lfo[1].depth = value end)
  params:add_control("autopan_freq", "autopan freq", controlspec.new(0.001, 25, "lin", 0.001, 0, ""))
  params:set_action("autopan_freq", function(value) lfo[1].freq = value end)
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

  if num == 2 and z == 1 then
    toggle_freeze()
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
