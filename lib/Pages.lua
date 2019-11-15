local GRID = grid.connect()
local modVals = include('timeparty/lib/ModVals').new(GRID)
local container = include('timeparty/lib/SequencersNew').new{GRID = GRID, modVals = modVals}
local sequencers = container.sequencers


-- todo: initialize all this in timeparty.lua, move init_params to main timeparty.lua
-- todo: pass sequencers to Pages

function init_params()
  params:add_number('bpm', 'bpm', 40, 240, 120)
  params:set_action('bpm', function() container:update_tempo() end)
  params:add_control('rate_slew', 'Rate Slew', controlspec.new(0, 5.0, 'lin'))
  params:set_action('rate_slew', function()
    softcut.rate_slew_time(1, params:get('rate_slew'))
  end)
end

init_params()
container:start()

local timeDivs = {0.1875, 0.25, 0.333, 0.375, 0.5, 0.667, 0.75, 1}
timeDivs.index = #timeDivs

function update_rate(Pages, delta)
  timeDivs.index = util.clamp(timeDivs.index + delta, 1, 8)
  Pages.active.sequencer:update_rate(timeDivs[timeDivs.index])
end

function change_length(Pages, delta)
  Pages.active.sequencer:set_length_offset(delta)
end

function create_page(options)
  local page = {
    title = options.title,
    sequencer = options.sequencer,
    params = { change_length, update_rate },
    selectedParam = 1,
  }
  return page
end

local timePage = create_page{
  title = 'T i m e',
  sequencer = sequencers.time,
}

local ratePage = create_page{
  title = 'R a t e',
  sequencer = sequencers.rate,
}

local feedbackPage = create_page{
  title = 'F e e d b a c k',
  sequencer = sequencers.feedback,
}

local panPage = create_page{
  title = 'P a n',
  sequencer = sequencers.pan,
}

local Pages = { timePage, ratePage, feedbackPage, panPage }

function Pages:new_page(index)
  self.active.sequencer.visible = false
  local newIndex = util.clamp(index, 1, #Pages)
  self.active = self[newIndex]
  self.active.sequencer.visible = true
  self.active.sequencer:init()
  self:redraw()
end

local index = {}
for i, v in ipairs(Pages) do
  index[v] = i
end
Pages.index = index

Pages.active = timePage

function Pages:active_index()
  return self.index[self.active]
end

function Pages:init()
  self.active.sequencer:redraw()
  self.active.sequencer:init()
end

function Pages:update_selected_param()
  local activeIndex = self:active_index()
  local page = self[activeIndex]
  page.selectedParam = page.selectedParam % #page.params + 1
end

function Pages:update_param(delta)
  local activeIndex = self:active_index()
  local page = self[activeIndex]
  page.params[page.selectedParam](self, delta)
end

function Pages:redraw()
  local activeIndex = self:active_index()
  local page = self[activeIndex]

  screen.clear()
  screen.move(6, 55)
  screen.font_size(70)
  screen.font_face(1)
  screen.level(15)
  screen.text(activeIndex)
  screen.font_face(9)
  screen.font_size(11)
  screen.move(50, 10)
  screen.text(page.title)

  screen.font_size(10)
  screen.font_face(4)
  screen.level(4)
  screen.move(50, 30)

  if page.selectedParam == 1 then
    screen.level(15)
  end

  screen.text('LENGTH: ')
  screen.move(95, 30)
  screen.text(page.sequencer:length())
  screen.level(4)

  if page.selectedParam == 2 then
    screen.level(15)
  end

  screen.move(50, 45)
  screen.text('DIV: ')
  screen.move(95, 45)
  screen.text(page.sequencer.rate)
  screen.level(4)
  screen.update()
end

return Pages
