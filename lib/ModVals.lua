local ModVals = {}

function ModVals.new(grid)
  local create_beat_divisions = function(grid)
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

  local create_equal_divisions = function(grid)
    local divisions = {}
    for i = grid.rows, 1, -1 do
      table.insert(divisions, i / grid.rows)
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

  local beatDivisions = create_beat_divisions(grid)

  return {
    beatDivisions = beatDivisions,
    beatDivisionsReversed = reverse_table(beatDivisions),
    equalDivisions = create_equal_divisions(grid)
  }
end

return ModVals
