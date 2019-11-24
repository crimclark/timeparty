local FXSequencer = include('timeparty/lib/FXSequencer')
local MusicUtil = require 'musicutil'
local GRID = grid.connect()

local voice = 1
local sequencersContainer = {}
sequencersContainer.__index = sequencersContainer

local function map(tbl, cb)
  local new = {}
  for _,v in ipairs(tbl) do table.insert(new, cb(v)) end
  return new
end

local function divide(v) return v/2 end
local function divide_table(tbl) return map(tbl, divide) end

function calculate_rate(bpm, beatDivision)
  return (bpm / 60) * beatDivision
end

local rateModes = {
  perfect = divide_table(MusicUtil.intervals_to_ratios({29,24,19,17,12,7,5,0})),
  major = divide_table(MusicUtil.intervals_to_ratios({12,11,9,7,5,4,2,0})),
  minor = divide_table(MusicUtil.intervals_to_ratios({12,10,8,7,5,3,2,0})),
}

local state = {loop_start = 1, loop_end = 2, rate = 1}

function sequencersContainer:init()
  self.sequencers = {
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
      modVals = rateModes.perfect,
      set_fx = function(value, shiftAmt)
        local rate = calculate_rate(params:get('bpm'), value * shiftAmt)
        print('setting rate')
        state.rate = rate
        params:set('rate', math.min(rate, 65))
      end,
    },

    feedback = FXSequencer.new{
      grid = GRID,
      modVals = {1.0, 0.875, 0.75, 0.625, 0.5, 0.375, 0.25, 0.125},
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
  }
end

function sequencersContainer:update_tempo()
  for _, seq in pairs(self.sequencers) do seq:update_tempo(params:get('bpm')) end
end

function sequencersContainer:start()
  for _, seq in pairs(self.sequencers) do seq:start() end
end

function sequencersContainer:stop()
  for _, seq in pairs(self.sequencers) do seq.metro:stop() end
end

function sequencersContainer:count()
  for _, seq in pairs(self.sequencers) do seq:count()() end
end

function sequencersContainer:update_rate_mode(mode)
  self.sequencers.rate.modVals = rateModes[mode]
end

return sequencersContainer
