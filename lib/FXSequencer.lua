local FXSequencer = {}
FXSequencer.__index = FXSequencer

local buttonLevels = { BRIGHT = 15, MEDIUM = 7, DIM = 3 }

function FXSequencer.new(options)
  local seq = {
    grid = options.grid,
    modVals = options.modVals,
    set_fx = options.set_fx,
    visible = options.visible or false,
    direction = 1,
    currentVal = 1,
    lengthOffset = 0,
    valOffset = 1,
    minVal = options.minVal or 0,
    maxVal = options.maxVal or 1,
    rate = 1.0,
    steps = {},
    positionX = 1,
--    positionY = 8,
    prevPositionX = 0,
    metro = metro.init(),
    held = {x = 0, y = 0 },
    directions = {'forward', 'reverse', 'pendulum', 'random', 'drunk'},
  }
  setmetatable(seq, FXSequencer)
  setmetatable(seq, {__index = FXSequencer})
  seq:init_steps()
  seq.metro.event = seq:count()
  return seq
end

function FXSequencer:start()
  self:update_tempo(params:get('bpm'))
  self.metro:start()
end

function FXSequencer:init()
  self:redraw()
  self.grid.key = function(x,y,z)
    if z == 1 then
      if self.held.y == y then
        local first,last = math.min(x, self.held.x), math.max(x, self.held.x)
        for i=first,last do self.steps[i] = {y = y, on = 1} end
      else
        self.steps[x] = {y = y, on = 1}
      end
      self.held = {x = x, y = y}
      self:redraw()
    end
    if z == 0 then self.held = {x = 0, y = 0} end
  end
end

function FXSequencer:update_tempo(bpm)
  self.metro.time = 60 / bpm / self.rate
end

function FXSequencer:update_rate(val)
  self.rate = val
  self:update_tempo(params:get('bpm'))
end

function FXSequencer:set_length_offset(delta)
  self.lengthOffset = util.clamp(self.lengthOffset - delta, 0, self.grid.cols - 1)
end

function FXSequencer:length()
  return self.grid.cols - self.lengthOffset
end

function FXSequencer:count()
  return function()
    local pos = self.positionX
    self.positionX = self:get_next_step()
    self.prevPositionX = pos
    self:redraw()
--    self.set_fx(self.currentVal, self.valOffset)
  end
end

function FXSequencer:forward()
  return self.positionX % self:length() + 1
end

function FXSequencer:reverse()
  return (self.positionX - 2) % self:length() + 1
end

function FXSequencer:pendulum()
  if self.positionX == 1 or (self.positionX > self.prevPositionX and self.positionX < self:length()) then
    return self:forward()
  end
  return self:reverse()
end

function FXSequencer:drunk()
  return math.random(0, 1) == 0 and self:forward() or self:reverse()
end

function FXSequencer:get_next_step()
  local dirs = {
    self:forward(),
    self:reverse(),
    self:pendulum(),
    math.random(16),
    self:drunk(),
  }
  return dirs[self.direction]
end

--function FXSequencer:redraw()
--  local visible = self.visible
--
--  if visible then self.grid:all(0) end
--
--  for i = 1, self:length() do
--    local y = self.steps[i]
--    -- count down from bottom row 8 to current height
--    for j = self.grid.rows, y, -1 do
--
--      if visible then self.grid:led(i, j, buttonLevels.MEDIUM) end
--
--      if i == self.positionX then
--        self.currentVal = self.modVals[y]
----        self.set_fx(self.currentVal, self.valOffset)
--
--        if visible then self.grid:led(i, j, buttonLevels.BRIGHT) end
--      end
--    end
--  end
--
--  if self.visible then self.grid:refresh() end
--end
function FXSequencer:redraw()
  local visible = self.visible

  if visible then self.grid:all(0) end

  for i = 1, self:length() do
    local y = self.steps[i].y
    -- count down from bottom row 8 to current height
    for j = self.grid.rows, y, -1 do

    if visible then self.grid:led(i, j, buttonLevels.DIM) end
    if visible and self.steps[i].on ~= 0 then self.grid:led(i, y, buttonLevels.MEDIUM) end

    end
      if i == self.positionX then
        self.currentVal = self.modVals[y]
        if visible then
          if self.steps[i].on == 1 then
            self.grid:led(i, y, buttonLevels.BRIGHT)
            self.positionY = y
          else
            self.grid:led(i, y, 5)
          end
        end

        --        self.set_fx(self.currentVal, self.valOffset)

      end
  end
  if self.visible then self.grid:refresh() end
end

function FXSequencer:init_steps()
  for i = 1, self.grid.cols do
    table.insert(self.steps, {y = 8, on = 0})
  end
end

return FXSequencer
