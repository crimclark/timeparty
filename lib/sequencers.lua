local FXSequencer = include('stepdad/lib/FXSequencer')
local GRID = grid.connect()
local voice = 1

local delayTimes = {0.25, 0.333, 0.375, 0.5, 0.667, 0.75, 1, 1.333, 1.5, 2}

local equalDivisions = {}
for i = GRID.rows, 1, -1 do
  table.insert(equalDivisions, i / GRID.rows)
end

-- todo: set in function
params:add_number('bpm', 'bpm', 40, 240, 60)
params:set_action('bpm', function() update_tempo() end)

function calculate_delay_time(bpm, beatDivision)
  return (60 / bpm) * beatDivision
end

function reverse_table(tbl)
  local reversed = {}
  for i = #tbl, 1, -1 do
    table.insert(reversed, tbl[i])
  end
  return reversed
end

local timeSequencer = FXSequencer.new{
  grid = GRID,
  modVals = delayTimes,
  set_fx = function(value)
    softcut.loop_end(voice, calculate_delay_time(params:get('bpm'), value) + 1)
  end,
  visible = true,
}

local rateSequencer = FXSequencer.new{
  grid = GRID,
  modVals = reverse_table(delayTimes),
  set_fx = function(value)
    softcut.rate(voice, calculate_delay_time(params:get('bpm'), value))
  end,
}

local feedbackSequencer = FXSequencer.new{
  grid = GRID,
  modVals = equalDivisions,
  set_fx = function(value)
    softcut.pre_level(voice, value)
  end
}

local mixSequencer = FXSequencer.new{
  grid = GRID,
  modVals = equalDivisions,
  set_fx = function(value)
    audio.level_monitor(value)
  end
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

return Sequencers
