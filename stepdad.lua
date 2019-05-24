local clk = require 'beatclock'.new()
local TapeDelay = require 'stepdad/lib/stepdad_softcut'

-- todo: move grid and clock into classes

local gridWidth, gridHeight = 16, 8
local positionX = 1
local steps = {}

local buttonLevels = { BRIGHT = 15, MEDIUM = 4, DIM = 2 }

-- set rate level as function of bpm

-- 60 / bpm is quarter note in seconds
-- 240 / bpm is whole note

-- whole * 1.5, 1.33,
-- multiply by 1.5 for dotted values and .667 for triplets.

--Half Note = 2
--dotted quarter = 1.5
--quarter triplet = 1.334
--Quarter Note = 1
--Dotted Eighth Note = 0.75
--eighth triplet = .667?
--Eighth Note = 0.5
--16th Note = .25

-- 16th to half note
-- this order for loop end
local delay_times = {0.25, 0.333, 0.375, 0.5, 0.667, 0.75, 1, 1.333, 1.5, 2 }

-- todo: multiply by 2?
-- reverse order for rate
--local delay_times = {2, 1.5, 1.333, 1, 0.75, 0.667, 0.5, 0.375, 0.333, 0.25 }
-- create dynamically by multiplying 1st 3?

--  do modes? octave vs delay_times vs musical intervals?

local myGrid = grid.connect()

function init()
  print(myGrid.cols)
  print(myGrid.rows)
  init_steps()
  init_clock()
  clk:start()
  TapeDelay.init()
  grid_redraw()
end

function init_steps()
  for i=1,gridWidth do
    table.insert(steps, 8)
  end
end

function init_clock()
  local clk_midi = midi.connect()
  clk_midi.event = clk.process_midi

  clk.on_step = count
  clk.on_select_internal = function() clk:start() end
  clk.on_select_external = function() print('external') end
  clk:add_clock_params()
end

myGrid.key = function(x,y,z)
  if z == 1 then
    steps[x] = y
    grid_redraw()
  end
end

function grid_redraw()
  -- set all to 0 brightness
  myGrid:all(0)
  grid_draw_columns()
  myGrid:refresh()
end

function calculate_delay_time(bpm, beatDivision)
  return (60 / bpm) * beatDivision
end

function count()
  positionX = (positionX % gridWidth) + 1
  grid_redraw()
end

function grid_draw_columns()
  for i,y in ipairs(steps) do
    -- count down from bottom row 8 to current height
    for j=gridHeight,y,-1 do
      myGrid:led(i, j, buttonLevels.DIM)
      if i == positionX then
--        print(y)
--        local invertedY = gridHeight % y + 1
        -- octaves
--        softcut.rate(1, (invertedY / 8) * 2)

--        softcut.rate(1, calculate_delay_time(params:get('bpm'), delay_times[y]))
        local delay_time = calculate_delay_time(params:get('bpm'), delay_times[y])
        softcut.loop_end(1, delay_time + 1 )
--        print(params:get('delay_rate'))
        myGrid:led(i, y, buttonLevels.BRIGHT)
      end
    end
  end
end

-- time wave
-- feedback mountain
-- position wave
-- mix mountain

-- hold PAGE? smaller sequence - play direction / position?

--bottom row: navigate, divide, hold, change sequence length

-- each page has division

-- feedback
-- time (loop length)
-- octave/rate (modes?)
-- mix

-- on time and rate - allow transpose/shift values?

-- on each page:
-- change sequence length
-- change beat division
-- show values as they change?

-- hold page?
-- scrub audio a la glut
-- reverse?

