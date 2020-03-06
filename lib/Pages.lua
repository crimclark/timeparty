local Pages = {}
Pages.__index = Pages

local SCREEN_LEVELS = {DIMMER = 1, DIM = 4, BRIGHT = 15}

function Pages.new(sequencers)
  local pages = {
    create_page('T i m e', sequencers.time),
    create_page('R a t e', sequencers.rate),
    create_page('F e e d b a c k', sequencers.feedback),
    create_page('F i l t e r C u t', sequencers.cutoff),
    create_page('A u t o p a n', sequencers.pan),
    create_page('R e v e r b', sequencers.reverb),
    create_page('P o s i t i o n', sequencers.position),
  }
  local index = {}
  for i,page in ipairs(pages) do index[page] = i end
  pages.index = index
  pages.active = pages[1]

  setmetatable(pages, Pages)
  setmetatable(pages, {__index = Pages})

  return pages
end

function update_div(seq, delta)
  seq.div = util.clamp(seq.div + delta, 1, 16)
end

function change_length(seq, delta)
  seq:set_length_offset(delta)
end

function change_direction(seq, delta)
  seq.direction = util.clamp(seq.direction + delta, 1, #seq.directions)
end

function shift(seq, delta)
  local param = seq.name .. '_' .. 'shift'
  local val = util.clamp(params:get(param) + delta, 1, 20)
  params:set(param, val)
  seq.valOffset = val
--  seq.valOffset = util.clamp(seq.valOffset + delta, 1, 20)
end

function create_page(title, seq)
  local page = {
    title = title,
    sequencer = seq,
    params = {
      create_param('Length', function() return seq:length() end, change_length),
      create_param('Div', function() return seq.div end, update_div),
      create_param('Direction', function() return seq.directions[seq.direction] end, change_direction),
      create_param('Shift', function()
        local param = seq.name .. '_' .. 'shift'
        return params:get(param)
      end, shift),
    },
    selectedParam = 1,
  }
  return page
end

function create_param(label, get, set)
  return {label = label, get = get, set = set}
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

function Pages:update_selected_param()
  local activeIndex = self:active_index()
  local page = self[activeIndex]
  page.selectedParam = page.selectedParam % #page.params + 1
end

function Pages:update_param(delta)
  local activeIndex = self:active_index()
  local page = self[activeIndex]
  local activeSeq = self.active.sequencer
  page.params[page.selectedParam].set(activeSeq, delta)
  activeSeq:redraw()
end

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
  for i=1,#page.params do
    local param = page.params[i]
    self:draw_param(param.label, param.get(), i, margin, lineHeight)
    lineHeight = lineHeight + 10
  end
  screen.update()
end

return Pages
