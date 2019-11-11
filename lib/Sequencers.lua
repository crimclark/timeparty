local FXSequencer = include('timeparty/lib/FXSequencer')

local GRID = grid.connect()
local modVals = include('timeparty/lib/ModVals').new(GRID)

print('OLD RATE VALS!!!!!!!!!!!!!')
for i,v in ipairs(modVals.beatDivisionsReversed) do print(v) end

local voice = 1

-- todo: set in function
params:add_number('bpm', 'bpm', 40, 240, 120)
params:set_action('bpm', function() update_tempo() end)

params:add_control('rate_slew', 'Rate Slew', controlspec.new(0, 5.0, 'lin'))
params:set_action('rate_slew', function() set_rate_slew() end)

function set_rate_slew()
  softcut.rate_slew_time(1, params:get('rate_slew'))
end

function calculate_rate(bpm, beatDivision)
  return (bpm / 60) * beatDivision
end

local timeSequencer = FXSequencer.new{
  grid = GRID,
  modVals = {0.375, 0.5, 0.667, 0.75, 1, 1.334, 1.5, 2},
  set_fx = function(value)
    softcut.loop_end(voice, value + 1)
  end,
  visible = true,
}

local rate = 1

local rateSequencer = FXSequencer.new{
  grid = GRID,
  modVals = modVals.beatDivisionsReversed,
  set_fx = function(value)
    local newRate = calculate_rate(params:get('bpm'), value)
    local truncated = math.floor(newRate * 100) / 100
    if truncated ~= math.abs(rate) then
      rate = truncated
      softcut.rate(voice, rate)
    end
  end,
}

local feedbackSequencer = FXSequencer.new{
  grid = GRID,
  modVals = modVals.equalDivisions,
  set_fx = function(value)
    softcut.pre_level(voice, value)
  end,
}

local mixSequencer = FXSequencer.new{
  grid = GRID,
  modVals = modVals.equalDivisions,
  set_fx = function(value)
    audio.level_cut(value)
    audio.level_monitor(1 - value)
  end,
}

local Sequencers = {
  time = timeSequencer,
  rate = rateSequencer,
  feedback = feedbackSequencer,
  mix = mixSequencer,
}

Sequencers.visible = timeSequencer

function update_tempo()
  for _, v in pairs(Sequencers) do
    v:update_tempo(params:get('bpm'))
  end
end

local t = 0 -- last tap time
local dt = 1 -- last tapped delta

crow.input[1].mode('change', 1, 0.05, 'rising')
crow.input[1].change = function(s)
  local t1 = util.time()
  dt = t1 - t
  t = t1
  params:set('bpm', 60/dt)
end

crow.input[2].mode('change', 1, 0.05, 'rising')
crow.input[2].change = function(s)
  rate = -rate
  softcut.rate(voice, rate)
end

return Sequencers
