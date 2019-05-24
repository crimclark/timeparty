local clk = require 'beatclock'.new()

function unrequire(name)
  package.loaded[name] = nil
  _G[name] = nil
end
unrequire('stepdad/lib/stepdad_softcut')
unrequire('stepdad/lib/sequencers')

local TapeDelay = require 'stepdad/lib/stepdad_softcut'
local Sequencers = require 'stepdad/lib/sequencers'

local pages = { time, rate, feedback, mix }

local visible_seq = 1

function init()
  start_clock()
  TapeDelay.init()
  -- init sets grid key handler and redraw
  Sequencers.time:init()
  Sequencers.time.visible = true
  redraw()
end

function redraw()
  screen.clear()
  screen.move(0, 10)
  screen.level(15)
  screen.text(visible_seq)
  screen.update()
end

function enc(num, delta)
  local newIndex = visible_seq + util.clamp(delta, -1, 1)
  visible_seq = util.clamp(newIndex, 1, 2)

  if (visible_seq == 2) then
    Sequencers.rate:init()
    Sequencers.update_visible('time', 'rate')
    Sequencers.rate:count(clk)
  end

  if (visible_seq == 1) then
    Sequencers.time:init()
    Sequencers.update_visible('rate', 'time')
    Sequencers.time:count(clk)
  end

  redraw()
end

function start_clock()
  local clk_midi = midi.connect()
  clk_midi.event = clk.process_midi
  clk:add_clock_params()
  -- todo: find better way to do this
  Sequencers.time:count(clk)
  clk.on_select_internal = function() clk:start() end
  clk.on_select_external = function() print('external') end
  clk:start()
end

function new_page(num)
  local page = pages[num]
  page[seq]:count(clk)
  page[seq]:init()
end

