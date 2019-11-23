local MusicUtil = require "musicutil"
local GRID_ROWS = 8

local function map(tbl, cb)
  local new = {}
  for _,v in ipairs(tbl) do
    table.insert(new, cb(v))
  end
  return new
end

local function divide(v) return v/2 end

local create_beat_divisions = function(initial)
  local next = {initial[1], initial[2], initial[3]}
  while #initial < GRID_ROWS do
    for i = 3,1,-1 do
      table.insert(initial, 1, next[i] / 2)
    end
    next = {initial[1], initial[2], initial[3]}
  end
  return initial
end

local create_equal_divisions = function()
  local divisions = {}
  for i = GRID_ROWS, 1, -1 do
    table.insert(divisions, i / GRID_ROWS)
  end
  return divisions
end

return {
  timeVals = create_beat_divisions({1.333, 1.5, 2}),
  equalDivisions = create_equal_divisions(),
  major = map(MusicUtil.intervals_to_ratios({12,11,9,7,5,4,2,0}), divide),
  minor = map(MusicUtil.intervals_to_ratios({12,10,8,7,5,3,2,0}), divide),
  perfect = map(MusicUtil.intervals_to_ratios({29,24,19,17,12,7,5,0}), divide),
}
