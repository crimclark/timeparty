local clk = require 'beatclock'.new()

local TapeDelay = include('stepdad/lib/stepdad_softcut')
--local Sequencers = require 'stepdad/lib/sequencers'
local Pages = include('stepdad/lib/Pages')

local visibleSeq = 1

function init()
  start_clock()
  TapeDelay.init()
  -- init sets grid key handler and redraw
--  Sequencers[visibleSeq]:redraw()
--  Sequencers[visibleSeq]:init()

  Pages:init()
  redraw()
end

function redraw()
  local activeIndex = Pages:active_index()
  screen.clear()
  screen.move(6, 55)
  screen.font_size(70)
  screen.font_face(1)
  screen.level(15)
  screen.text(activeIndex)
  screen.font_face(9)
  screen.font_size(11)
  screen.move(50, 10)
  screen.text(Pages[activeIndex].title)
  screen.update()
end

function enc(num, delta)
--  local newIndex = visibleSeq + util.clamp(delta, -1, 1)
--  visibleSeq = util.clamp(newIndex, 1, 4)
--  Sequencers[visibleSeq]:init()
--  Sequencers.update_visible(visibleSeq, delta)

  local newIndex = Pages:active_index() + util.clamp(delta, -1, 1)
  Pages:new_page(newIndex)
  redraw()
end
--

-- todo: need new way of defining bpm so can get rid of this
function start_clock()
  local clk_midi = midi.connect()
  clk_midi.event = clk.process_midi
  clk:add_clock_params()
  clk.on_select_internal = function() clk:start() end
  clk.on_select_external = function() print('external') end
end

--function new_page(num)
--  local page = pages[num]
--  page[seq]:count(clk)
--  page[seq]:init()
--end

