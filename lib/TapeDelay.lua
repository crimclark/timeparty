local sc = {}

function sc.init()
--  audio.level_monitor(0)
  audio.level_cut(1.0)
  audio.level_adc_cut(1)
  audio.level_eng_cut(1)
  softcut.level(1,1.0)
  softcut.level_slew_time(1,0.25)
  softcut.level_input_cut(1, 1, 1.0)
  softcut.level_input_cut(2, 1, 1.0)
  softcut.pan(1, 0)

  softcut.play(1, 1)
  softcut.rate(1, 1)
  softcut.loop_start(1, 1)
  softcut.loop_end(1, 2)
  softcut.loop(1, 1)
  softcut.fade_time(1, 0.01)
  softcut.rec(1, 1)
  softcut.rec_level(1, 1)
  softcut.pre_level(1, 0.75)
  softcut.position(1, 1)
  softcut.enable(1, 1)

  softcut.post_filter_dry(1, 0)
  softcut.filter_fc(1, 1200)
  softcut.filter_fc_mod(1, 1)
  softcut.post_filter_lp(1, 1)
  softcut.post_filter_rq(1, 5)
  softcut.post_filter_hp(1, 0)
  softcut.post_filter_bp(1, 0)
  softcut.post_filter_br(1, 0)

  softcut.pan_slew_time(1, 0.1)
end

return sc
