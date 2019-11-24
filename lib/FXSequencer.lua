local FXSequencer = {}
FXSequencer.__index = FXSequencer

local buttonLevels = { BRIGHT = 14, MEDIUM = 8, LOW_MED = 5, DIM = 3 }

function FXSequencer.new(options)
  local seq = {
    grid = options.grid,
    modVals = options.modVals,
    set_fx = options.set_fx,
    visible = options.visible or false,
    inactive = options.inactive or false,
    direction = 1,
    lengthOffset = 0,
    valOffset = 1,
    div = 1,
    divCount = 1,
    steps = {},
    queuedSteps = {},
    positionX = 1,
    activeY = 8,
    prevPositionX = 1,
    metro = metro.init(),
    held = {x = 0, y = 0},
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
        for i=first,last do
          self.steps[i] = {y = y, on = 1}
        end
      else
        local step = self.steps[x]
        local on = (step == nil or step.on == 0 or y ~= step.y) and 1 or 0
        self.steps[x] = {y = y, on = on }
        self:add_queued_step(x, y)
      end
      self.held = {x = x, y = y}
      self:redraw()
    end
    if z == 0 then self.held = {x = 0, y = 0} end
  end
end

function FXSequencer:update_tempo(bpm)
  self.metro.time = 60 / bpm
end

function FXSequencer:set_length_offset(delta)
  self.lengthOffset = util.clamp(self.lengthOffset - delta, 0, self.grid.cols - 1)
end

function FXSequencer:length()
  return self.grid.cols - self.lengthOffset
end

function FXSequencer:count()
  return function()
    if self.grid.cols > 0 then
      self.divCount = self.divCount % self.div + 1
      if self.divCount == 1 then
        local pos = self.positionX
        self.positionX = self:get_next_step(pos)
        self.prevPositionX = pos
        local step = self.steps[self.positionX]
        if step ~= nil and step.on == 1 then
          self.set_fx(self.modVals[step.y], self.valOffset)
        end
        self:redraw()
      end
    end
  end
end

function FXSequencer:forward(x)
  return x % self:length() + 1
end

function FXSequencer:reverse(x)
  return (x - 2) % self:length() + 1
end

function FXSequencer:pendulum()
  if self.positionX == 1 or (self.positionX > self.prevPositionX and self.positionX < self:length()) then
    return self:forward(self.positionX)
  end
  return self:reverse(self.positionX)
end

function FXSequencer:drunk()
  return math.random(0, 1) == 0 and self:forward(self.positionX) or self:reverse(self.positionX)
end

function FXSequencer:get_next_step(x)
  local dirs = {
    self:forward(x),
    self:reverse(x),
    self:pendulum(x),
    math.random(self:length()),
    self:drunk(x),
  }
  return dirs[self.direction]
end

function FXSequencer:redraw()
  local visible = self.visible
  if visible then self.grid:all(0) end

  for i=1, self:length() do
    local currentStep = self.steps[i]
    if i == self.positionX then -- if on current positionX
      -- active highlighted step
      if currentStep ~= nil and currentStep.on == 1 then
        self.activeY = currentStep.y
        self.grid:led(i, currentStep.y, buttonLevels.BRIGHT)
      -- highlighted inactive
      elseif self.queuedSteps[i] ~= nil then
        if self.activeY ~= self.queuedSteps[i].y then
          -- update queued step
          self.queuedSteps[i].y = self.activeY
        end
        -- overwrite step with current queued step and draw
        self.steps[i] = self.queuedSteps[i]
        self.grid:led(i, self.steps[i].y, buttonLevels.LOW_MED)
        -- add next queued step
        self:add_queued_step(i, self.steps[i].y)
      end
    else
      -- if step is on but not highlighted
      if currentStep ~= nil and currentStep.on == 1 then
        self.grid:led(i, currentStep.y, buttonLevels.MEDIUM)
      -- if step is off and not highlighted
      elseif currentStep ~= nil then
        self.grid:led(i, currentStep.y, buttonLevels.DIM)
      end
    end
  end
  if visible then self.grid:refresh() end
end

function FXSequencer:add_queued_step(currentX, currentY)
  local nextX = self:get_next_step(currentX)
  if self.steps[nextX] == nil or self.steps[nextX].on == 0 then
    self.queuedSteps[nextX] = {y = currentY, on = 0}
  end
end

function FXSequencer:init_steps()
  local on = self.inactive == true and 0 or 1
  self.steps[1] = {y = 8, on = on }
  if on == 1 then
    self.set_fx(self.modVals[8], self.valOffset)
  end
  if self.grid.cols > 0 then
    self:add_queued_step(1, 8)
  end
end

return FXSequencer
