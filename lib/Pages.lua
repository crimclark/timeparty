local Sequencers = include('stepdad/lib/sequencers')

function create_page(options)
  local page = {
    title = options.title,
    sequencer = options.sequencer,
--    params = options.params or {}
  }
  return page
end

local timePage = create_page{
  title = 'T i m e',
  sequencer = Sequencers.time,
}

local ratePage = create_page{
  title = 'R a t e',
  sequencer = Sequencers.rate,
}

local feedbackPage = create_page{
  title = 'F e e d b a c k',
  sequencer = Sequencers.feedback,
}

local mixPage = create_page{
  title = 'M i x',
  sequencer = Sequencers.mix,
}

local Pages = { timePage, ratePage, feedbackPage, mixPage }

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
--  self:redraw()
end

--todo: make instance method on page
function Pages:redraw()
  local activeIndex = self:active_index()
  screen.clear()
  screen.move(6, 55)
  screen.font_size(70)
  screen.font_face(1)
  screen.level(15)
  screen.text(activeIndex)
  screen.font_face(9)
  screen.font_size(11)
  screen.move(50, 10)
  screen.text(self[activeIndex].title)
  screen.update()
end

return Pages