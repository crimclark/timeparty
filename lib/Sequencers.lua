local FXSequencer = include('timeparty/lib/FXSequencer')

local GRID = grid.connect()
local modVals = include('timeparty/lib/ModVals').new(GRID)

local voice = 1

-- todo: set in function
params:add_number('bpm', 'bpm', 40, 240, 120)
params:set_action('bpm', function() update_tempo() end)

function calculate_delay_time(bpm, beatDivision)
  return (60 / bpm) * beatDivision
end

function calculate_rate(bpm, beatDivision)
  return (bpm / 60) * beatDivision
end

local timeSequencer = FXSequencer.new{
  grid = GRID,
  modVals = modVals.beatDivisions,
  set_fx = function(value)
    softcut.loop_end(voice, calculate_delay_time(params:get('bpm'), value) + 1)
  end,
  visible = true,
}

local rateSequencer = FXSequencer.new{
  grid = GRID,
  modVals = modVals.beatDivisionsReversed,
  set_fx = function(value)
    softcut.rate(voice, calculate_rate(params:get('bpm'), value))
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
  local start = 120 / params:get('bpm')
  softcut.loop_start(voice, start)
  for _, v in pairs(Sequencers) do
    v:update_tempo(params:get('bpm'))
  end
end

return Sequencers
