local FXSequencer = include('timeparty/lib/FXSequencer')
local modVals = include('timeparty/lib/modVals')

local voice = 1

local SequencersContainer = {}
SequencersContainer.__index = SequencersContainer

function calculate_rate(bpm, beatDivision)
  return (bpm / 60) * beatDivision
end

local state = {
  loop_start = 1,
  loop_end = 2,
}

function SequencersContainer.new(GRID)
  local container = {
    sequencers = {
      time = FXSequencer.new{
        grid = GRID,
        modVals = {0.375, 0.5, 0.666, 0.75, 1, 1.333, 1.5, 2},
        set_fx = function(value, shiftAmt)
          state.loop_end = (value / shiftAmt) + state.loop_start
          softcut.loop_end(voice, state.loop_end)
        end,
        visible = true,
      },

      rate = FXSequencer.new{
        grid = GRID,
        modVals = modVals.perfect,
        set_fx = function(value, shiftAmt)
          local rate = calculate_rate(params:get('bpm'), value * shiftAmt)
          params:set('rate', math.min(rate, 65))
        end,
      },

      feedback = FXSequencer.new{
        grid = GRID,
        modVals = modVals.equalDivisions,
        set_fx = function(value, shiftAmt)
          softcut.pre_level(voice, util.clamp(value + shiftAmt / 100, 0, 1))
        end,
      },

      cutoff = FXSequencer.new{
        grid = GRID,
        modVals = {120, 240, 480, 960, 1920, 3840, 7680, 12000},
        set_fx = function(value, shiftAmt)
          params:set('filter_cutoff', util.clamp(value + shiftAmt * 100, 0, 12000))
        end,
      },


      pan = FXSequencer.new{
        grid = GRID,
        modVals = {8, 4, 2, 1, 0.5, 0.25, 0.125, 0.0625},
        set_fx = function(value, shiftAmt)
          local freq =  value * ((shiftAmt * 2))  * (params:get('bpm') / 120)
          params:set('autopan_freq', freq)
        end,
      },

      position = FXSequencer.new{
        grid = GRID,
        -- todo: update these
        modVals = {8, 7, 6, 5, 4, 3, 2, 1},
        inactive = true,
        set_fx = function(value, shiftAmt)
          local loopLn = state.loop_end - state.loop_start
          local div = loopLn / 8
          local pos = (value * div) - div + state.loop_start
          softcut.position(voice, util.clamp(pos + shiftAmt / 100, state.loop_start, state.loop_end))
        end,
      },

      reverb = FXSequencer.new{
        grid = GRID,
        modVals = {5, 0, -5, -10, -20, -30, -40, -50},
        set_fx = function(value, shiftAmt)
          audio.level_cut_rev(util.clamp(util.dbamp(value + shiftAmt), -50, 7))
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
  for _, seq in pairs(self.sequencers) do
    seq:update_tempo(params:get('bpm'))
  end
end

function SequencersContainer:start()
  for _, seq in pairs(self.sequencers) do seq:start() end
end

function SequencersContainer:stop()
  for _, seq in pairs(self.sequencers) do seq.metro:stop() end
end

function SequencersContainer:count()
  for _, seq in pairs(self.sequencers) do seq:count()() end
end

function SequencersContainer:update_rate_mode(mode)
  self.sequencers.rate.modVals = modVals[mode]
end

function SequencersContainer:bang()
  for _, seq in pairs(self.sequencers) do
    if seq.steps[1].on == 1 then
      seq.set_fx(seq.modVals[8], seq.valOffset)
    end
  end
end

return SequencersContainer
