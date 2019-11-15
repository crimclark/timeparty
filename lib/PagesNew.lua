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

  local pages = { timePage, ratePage, feedbackPage, panPage, posPage, revPage }
  local index = {}
  for i, v in ipairs(pages) do index[v] = i end
  pages.index = index
  pages.active = timePage

  setmetatable(pages, Pages)
  setmetatable(pages, {__index = Pages})

  return pages
end


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

--local timePage = create_page{
--  title = 'T i m e',
--  sequencer = sequencers.time,
--}
--
--local ratePage = create_page{
--  title = 'R a t e',
--  sequencer = sequencers.rate,
--}
--
--local feedbackPage = create_page{
--  title = 'F e e d b a c k',
--  sequencer = sequencers.feedback,
--}
--
--local mixPage = create_page{
--  title = 'M i x',
--  sequencer = sequencers.mix,
--}
--
--local Pages = { timePage, ratePage, feedbackPage, mixPage }

function Pages:new_page(index)
  self.active.sequencer.visible = false
  local newIndex = util.clamp(index, 1, #self)
  print(#self)
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
