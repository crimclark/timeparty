local TapeDelay = include('stepdad/lib/stepdad_softcut')
local Pages = include('stepdad/lib/Pages')

-- todo: not DRY uses same values as delay times
local timeDivs = {0.1875, 0.25, 0.333, 0.375, 0.5, 0.667, 0.75, 1}
timeDivs.index = #timeDivs


function init()
  TapeDelay.init()
  Pages:init()
  redraw()
end

function redraw()
  Pages:redraw()
end


function update_rate(delta)
  timeDivs.index = util.clamp(timeDivs.index + delta, 1, 8)
  Pages.active.sequencer:update_rate(timeDivs[timeDivs.index])
end

function change_length(delta)
  Pages.active.sequencer:set_length_offset(delta)
end

local seqParamSetters = {
  change_length,
  update_rate
}
seqParamSetters.index = 1

function key(num, z)
  if num == 3 and z == 1 then
    Pages:update_selected_param()
    redraw()
  end
end

function enc(num, delta)
  if num == 2 then
    local newIndex = Pages:active_index() + util.clamp(delta, -1, 1)
    Pages:new_page(newIndex)
  end

  if num == 3 then

    Pages:update_param(delta)
    redraw()
  end
end
