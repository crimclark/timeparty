local FXSequencer = {}
FXSequencer.__index = FXSequencer

local buttonLevels = { BRIGHT = 15, MEDIUM = 4, DIM = 2 }

function FXSequencer.new(options)
  local seq = {
    grid = options.grid,
    modVals = options.modVals,
    set_fx = options.set_fx,
    visible = options.visible or false,
    steps = {},
    positionX = 1,
    metro = metro.init()
  }
  setmetatable(seq, FXSequencer)
  setmetatable(seq, {__index = FXSequencer})
  seq:init_steps()
  seq.metro.event = seq:count()
  seq.metro:start(0.5)
  return seq
end

function FXSequencer:init()
  self.grid.key = function(x,y,z)
    if z == 1 then
      self.steps[x] = y
      self:redraw()
    end
  end
end

function FXSequencer:update_tempo(bpm)
  self.metro.time = 60 / bpm
end

function FXSequencer:count()
  return function()
    self.positionX = (self.positionX % self.grid.cols) + 1
    self:redraw()
  end
end

function FXSequencer:redraw()
  local visible = self.visible

  if visible then self.grid:all(0) end

  for i, y in ipairs(self.steps) do
    -- count down from bottom row 8 to current height
    for j = self.grid.rows, y, -1 do

      if visible then self.grid:led(i, j, buttonLevels.DIM) end

      if i == self.positionX then
        self.set_fx(self.modVals[y])

        if visible then self.grid:led(i, y, buttonLevels.BRIGHT) end
      end
    end
  end

  if self.visible then self.grid:refresh() end
end

function FXSequencer:init_steps()
  for i = 1, self.grid.cols do
    table.insert(self.steps, self.grid.rows)
  end
end

return FXSequencer
