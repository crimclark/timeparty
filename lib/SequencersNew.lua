local FXSequencer = include('timeparty/lib/FXSequencer')

local voice = 1

local SequencersContainer = {}
SequencersContainer.__index = SequencersContainer

function calculate_rate(bpm, beatDivision)
  return (bpm / 60) * beatDivision
end

function calculate_lfo_freq (bpm, rate)
  return rate * bpm * .01
end

local rate = 1
local position = 0
local reverb = 0

function SequencersContainer.new(options)
  local GRID = options.GRID
  local modVals = options.modVals

  local container = {
    sequencers = {
      time = FXSequencer.new{
        grid = GRID,
        modVals = {0.375, 0.5, 0.666, 0.75, 1, 1.333, 1.5, 2},
        set_fx = function(value) softcut.loop_end(voice, value + 1) end,
        visible = true,
      },

      rate = FXSequencer.new{
        grid = GRID,
        modVals = modVals.perfect,
        set_fx = function(value)
          local newRate = calculate_rate(params:get('bpm'), value)
          local truncated = math.floor(newRate * 100) / 100
          if truncated ~= math.abs(rate) then
            rate = truncated
            softcut.rate(voice, rate)
          end
        end,
      },

      feedback = FXSequencer.new{
        grid = GRID,
        modVals = modVals.equalDivisions,
        set_fx = function(value) softcut.pre_level(voice, value) end,
      },

      pan = FXSequencer.new{
        grid = GRID,
        modVals = {8, 4, 2, 1, 0.5, 0.25, 0.125, 0.625},
        set_fx = function(value)
          params:set('1lfo_freq', calculate_lfo_freq(params:get('bpm'), value))
        end,
      },

      position = FXSequencer.new{
        grid = GRID,
        modVals = modVals.equalDivisions,
        set_fx = function(value)
          local newPos = value - 0.125 + 1
          if newPos ~= position then
            print(position)
            position = newPos
            softcut.position(voice, position)
          end
        end,
      },

      reverb = FXSequencer.new{
        grid = GRID,
        modVals = {5, 0, -5, -10, -20, -30, -40, -50},
        set_fx = function(value)
          audio.level_cut_rev(util.dbamp(value))
        end,
      },
    },
  }
  container.visible = container.sequencers.timeSequencer

  setmetatable(container, SequencersContainer)
  setmetatable(container, {__index = SequencersContainer})

  return container
end

function SequencersContainer:update_tempo()
  for _, v in pairs(self.sequencers) do
    v:update_tempo(params:get('bpm'))
  end
end

function SequencersContainer:start()
  for _, v in pairs(self.sequencers) do v:start() end
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

return SequencersContainer
