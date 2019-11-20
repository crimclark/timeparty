local FXSequencer = include('timeparty/lib/FXSequencer')

local voice = 1

local SequencersContainer = {}
SequencersContainer.__index = SequencersContainer

function calculate_rate(bpm, beatDivision)
  return (bpm / 60) * beatDivision
end

local rate = 1

function SequencersContainer.new(options)
  local GRID = options.GRID
  local modVals = options.modVals

  local container = {
    sequencers = {
      time = FXSequencer.new{
        grid = GRID,
        modVals = {0.375, 0.5, 0.666, 0.75, 1, 1.333, 1.5, 2},
        set_fx = function(value, shiftAmt)
          softcut.loop_end(voice, (value / shiftAmt) + 1)
        end,
        visible = true,
      },

      rate = FXSequencer.new{
        grid = GRID,
        modVals = modVals.perfect,
        set_fx = function(value, shiftAmt)
          local newRate = calculate_rate(params:get('bpm'), value * shiftAmt)
          local truncated = math.floor(newRate * 100) / 100
          if truncated ~= math.abs(rate) then
            rate = truncated
            softcut.rate(voice, math.min(rate, 65))
          end
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
        set_fx = function(value)
          params:set('filter_cutoff', value)
        end,
      },


      pan = FXSequencer.new{
        grid = GRID,
        modVals = {8, 4, 2, 1, 0.5, 0.25, 0.125, 0.0625},
        set_fx = function(value)
          params:set('autopan_freq', value * (params:get('bpm')/120))
        end,
      },

      position = FXSequencer.new{
        grid = GRID,
        -- todo: update these
        modVals = {1, 1, 1, 1, 0, 0, 0, 0},
        set_fx = function(value)
--          local newPos = value - 0.125 + 1
          softcut.position(voice, value)
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


crow.input[2].mode('change', 1, 0.05, 'rising')
crow.input[2].change = function(s)
  rate = -rate
  softcut.rate(voice, rate)
end

return SequencersContainer
