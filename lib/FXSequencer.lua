local FXSequencer = {}
FXSequencer.__index = FXSequencer

local buttonLevels = { BRIGHT = 15, MEDIUM = 4, DIM = 2 }

-- sequencers file needs to be aware of grid - would have to import it in multiple places
--local grid = grid.connect()

function FXSequencer.new(options)
  local seq = {
    -- todo: do i need to pass in grid?
    grid = options.grid,
    modVals = options.modVals,
    set_fx = options.set_fx,
    id = options.id,
    steps = {},
    visible = false,
    positionX = 1
  }
  setmetatable(seq, FXSequencer)
  setmetatable(seq, {__index = FXSequencer})
  seq:init_steps()
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

--function FXSequencer:count(clock)
--  clock.on_step = function()
--    self.positionX = (self.positionX % self.grid.cols) + 1
--    if self.visible then self:redraw()
--    else self:grid_draw()
--    end
--  end
--end

function FXSequencer:count(clock)
  clock.on_step = function()
    self.positionX = (self.positionX % self.grid.cols) + 1
    self:redraw()
  end
end

function FXSequencer:count_test(clock)
  clock.on_step = function()
    self.positionX = (self.positionX % self.grid.cols) + 1
    self:grid_draw()
  end
end

function FXSequencer:redraw()
  self.grid:all(0)
  self:grid_draw()
  self.grid:refresh()
end

-- todo: set self.active instead of passing in visible?
function FXSequencer:grid_draw()
  for i, y in ipairs(self.steps) do
    -- count down from bottom row 8 to current height
    for j = self.grid.rows, y, -1 do

      if self.visible then self.grid:led(i, j, buttonLevels.DIM) end

      if i == self.positionX then
        -- todo: why is this not a : method
        self.set_fx(self.modVals[y])

        if self.visible then self.grid:led(i, y, buttonLevels.BRIGHT) end
      end
    end
  end
end

function FXSequencer:init_steps()
  for i = 1, self.grid.cols do
    table.insert(self.steps, self.grid.rows)
  end
end

return FXSequencer
