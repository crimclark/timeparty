local ModVals = {}
local MusicUtil = require "musicutil"

local function map(tbl, cb)
  local new = {}
  for _,v in ipairs(tbl) do
    table.insert(new, cb(v))
  end
  return new
end

local function divide(v) return v/2 end
local function mult_by_4(v) return v*4 end

function ModVals.new(grid)
  local create_beat_divisions = function(grid, initial)
    local next = {initial[1], initial[2], initial[3]}
    while #initial < grid.rows do
      for i = 3,1,-1 do
        table.insert(initial, 1, next[i] / 2)
      end
      next = {initial[1], initial[2], initial[3]}
    end
    return initial
  end

  local beat_divisions = function(grid)
    local divisions = {0.375, 0.5, 0.667}
    local multiplier = 2
    while #divisions  < grid.rows do
      for i = 1, 3 do
        table.insert(divisions, divisions[i] * multiplier)
      end
      multiplier = multiplier * 2
    end
    return divisions
  end

  local reverse_table = function(tbl)
    local reversed = {}
    for i = #tbl, 1, -1 do
      table.insert(reversed, tbl[i])
    end
    return reversed
  end

  local create_equal_divisions = function(grid)
    local divisions = {}
    for i = grid.rows, 1, -1 do
      table.insert(divisions, i / grid.rows)
    end
    return divisions
  end

  return {
--    beatDivisions = create_beat_divisions(grid),
    timeVals = create_beat_divisions(grid, {1.333, 1.5, 2}),
--    rateVals = create_beat_divisions(grid, {0.375, 0.75, 1}),
    rateVals = reverse_table(beat_divisions(grid)),
    equalDivisions = create_equal_divisions(grid),
    major = MusicUtil.intervals_to_ratios({12,11,9,7,5,4,2,0}),
    minor = MusicUtil.intervals_to_ratios({12,10,8,7,5,3,2,0}),
    perfect = map(MusicUtil.intervals_to_ratios({29,24,19,17,12,7,5,0}), divide),
}
end

return ModVals
