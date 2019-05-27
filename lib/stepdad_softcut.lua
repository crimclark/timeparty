local sc = {}

function sc.init()
    -- use for wet dry
    audio.level_monitor(0)
    audio.level_cut(1.0)
    audio.level_adc_cut(1)
    audio.level_eng_cut(1)
    softcut.level(1,1.0)
    softcut.level_slew_time(1,0.25)
    softcut.level_input_cut(1, 1, 1.0)
    softcut.level_input_cut(2, 1, 1.0)
    softcut.pan(1, 0.5)

    softcut.play(1, 1)
    -- todo: sequence rate as octaves instead?
    softcut.rate(1, 1)
    -- add to params, control from rate page
    --  softcut.rate_slew_time(1,0.25)
    -- todo: sequence loop length - delay time
    softcut.loop_start(1, 1)
    softcut.loop_end(1, 1.5)
    softcut.loop(1, 1)
    softcut.fade_time(1, 0.1)
    -- turn off record to "hold"?
    softcut.rec(1, 1)
    softcut.rec_level(1, 1)
    -- sequence 2
    softcut.pre_level(1, 0.75)

    -- sequence position?
    -- line down the middle - above forwards, below reverse? v2?
    softcut.position(1, 1)
    softcut.enable(1, 1)

    softcut.filter_dry(1, 0.125);
    softcut.filter_fc(1, 1200);
    softcut.filter_lp(1, 0);
    softcut.filter_bp(1, 1.0);
    softcut.filter_rq(1, 2.0);

    params:add_separator()

    -- todo remove these? or allow manual mode (turn off sequencers)?
--    params:add{
--        id = "delay",
--        name = "delay",
--        type = "control",
--        controlspec = controlspec.new(0,1,'lin',0,1,""),
--        action = function(x) softcut.level(1,x) end
--    }
--    params:add{
--        id = "delay_rate",
--        name = "delay rate",
--        type = "control",
--        controlspec = controlspec.new(0.125,16,'lin',0,1,""),
--        action = function(x) softcut.rate(1,x)
--        end
--    }
--    params:add{
--        id = "delay_feedback",
--        name = "delay feedback",
--        type = "control",
--        controlspec = controlspec.new(0,1.0,'lin',0,0.75,""),
--        action = function(x) softcut.pre_level(1,x) end
--    }
end

return sc
