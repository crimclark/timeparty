local Pages = {}
Pages.__index = Pages

function Pages.new(sequencers)
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
    title = 'A u t o p a n',
    sequencer = sequencers.pan,
  }

  local posPage = create_page{
    title = 'P o s i t i o n',
    sequencer = sequencers.position,
  }

  local revPage = create_page{
    title = 'R e v e r b',
    sequencer = sequencers.reverb,
  }

  local cutoffPage = create_page{
    title = 'F i l t e r C u t',
    sequencer = sequencers.cutoff,
  }

  local pages = {timePage, ratePage, feedbackPage, panPage, posPage, revPage, cutoffPage}
  local index = {}
  for i,v in ipairs(pages) do index[v] = i end
  pages.index = index
  pages.active = timePage

  setmetatable(pages, Pages)
  setmetatable(pages, {__index = Pages})

  return pages
end


local timeDivs = {0.1875, 0.25, 0.333, 0.375, 0.5, 0.667, 0.75, 1}
timeDivs.index = #timeDivs

function update_rate(seq, delta)
  timeDivs.index = util.clamp(timeDivs.index + delta, 1, 8)
  seq:update_rate(timeDivs[timeDivs.index])
end

function change_length(seq, delta)
  seq:set_length_offset(delta)
end

function change_direction(seq, delta)
--  seq.direction = util.clamp(seq.direction + delta, 1, 5)
  seq.direction = util.clamp(seq.direction + delta, 1, #seq.directions)
  print(seq.direction)
end

function shift_fine(seq, delta)
  seq.valOffset = util.clamp(seq.valOffset + delta, 1, 200)
end

function create_page(options)
  local page = {
    title = options.title,
    sequencer = options.sequencer,
    params = { change_length, update_rate, change_direction, shift_fine },
    selectedParam = 1,
  }
  return page
end

function Pages:new_page(index)
  self.active.sequencer.visible = false
  local newIndex = util.clamp(index, 1, #self)
  self.active = self[newIndex]
  self.active.sequencer.visible = true
  self.active.sequencer:init()
  self:redraw()
end

function Pages:active_index()
  return self.index[self.active]
end

function Pages:init()
  self.active.sequencer:redraw()
  self.active.sequencer:init()
end

-- todo: methods below should all be instance methods on page, not Pages
function Pages:update_selected_param()
  local activeIndex = self:active_index()
  local page = self[activeIndex]
  page.selectedParam = page.selectedParam % #page.params + 1
end

function Pages:update_param(delta)
  local activeIndex = self:active_index()
  local page = self[activeIndex]
  local activeSeq = self.active.sequencer
  page.params[page.selectedParam](activeSeq, delta)
  activeSeq:redraw()
end

local SCREEN_LEVELS = {
  DIMMER = 1,
  DIM = 4,
  BRIGHT = 15,
}

function Pages:draw_title(index, margin)
  local page = self[index]

  screen.clear()
  screen.move(6, 34)
  screen.font_size(50)
  screen.font_face(1)
  screen.level(SCREEN_LEVELS.BRIGHT)
  screen.text(index)

  screen.font_size(9)
  screen.level(params:get('freeze') == 2 and SCREEN_LEVELS.DIMMER or SCREEN_LEVELS.BRIGHT)
  screen.move(3, 60)
  screen.font_face(17)
  screen.text('Freeze')

  screen.font_size(11)
  screen.font_face(9)
  screen.level(SCREEN_LEVELS.BRIGHT)
  screen.move(margin, 10)
  screen.text(page.title)
end

function Pages:draw_param(name, value, index, margin, lineHeight)
  local activeIndex = self:active_index()
  local page = self[activeIndex]
  screen.level(SCREEN_LEVELS.DIM)
  screen.move(margin, lineHeight)

  if page.selectedParam == index then screen.level(15) end
  screen.text(name .. ': ')
  screen.move(95, lineHeight)
  screen.text(value)
  screen.level(SCREEN_LEVELS.DIM)
end

function Pages:redraw()
  local activeIndex = self:active_index()
  local page = self[activeIndex]
  local margin = 45;
  self:draw_title(activeIndex, margin)

  screen.font_size(8)
  screen.font_face(2)

  local lineHeight = 23
  local inc = 10
  local seq = page.sequencer;

-- todo: associate params with page - do this in loop
  self:draw_param('Length', seq:length(), 1, margin, lineHeight)
  lineHeight = lineHeight + inc
  self:draw_param('Speed', seq.rate, 2, margin, lineHeight)
  lineHeight = lineHeight + inc
  self:draw_param('Direction', seq.directions[seq.direction], 3, margin, lineHeight)
  lineHeight = lineHeight + inc
  self:draw_param('Shift', seq.valOffset, 4, margin, lineHeight)
  screen.update()
end

return Pages
