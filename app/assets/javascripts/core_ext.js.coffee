# Foundation.libs.joyride.defaults.tip_container = '#content_wrapper'
Foundation.libs.joyride.scroll_to = ->
      tip_height = @settings.$next_tip.outerHeight()
      el_top = @settings.$target.offset().top
      if @bottom()
        window_height = $(window).height()
        el_height = @settings.$target.outerHeight()
        diff = el_height + tip_height - window_height
        diff = 0 if diff > 0
      else if @top()
        diff = - tip_height
        console.log diff, el_height, tip_height
        diff = 0 if el_top + diff < 0
      else
        window_half = $(window).height() / 2
        diff = tip_height - window_half

      tipOffset = Math.ceil(el_top + diff)

      if tipOffset != 0
        $('html, body').animate({
          scrollTop: tipOffset
        }, @settings.scroll_speed, 'swing')

Foundation.libs.joyride.defaults.post_ride_callback = ->
  Ruler.joyride_toggle(false)

Foundation.libs.joyride.defaults.pre_ride_callback = ->
  Foundation.libs.joyride.show_modal() if Foundation.libs.joyride.settings.modal
  Ruler.joyride_toggle(true)
