window.Ruler =
  drag_start: false
  nav_fixed: false
  max_index: -1
  rules: []
  step: 0.01
  joyride_started: false

  init: (translations = {})->
    @translations = translations
    @role_tpl = $('@rule:last-child').clone()
    @role_tpl.find('@value').val(100)
    @role_tpl.find('@url'  ).val('')
    @probability_sum = $('.probability-sum')
    (@initialize_rule $(rule) for rule in $('@rule'))
    @max_index = @rules.length - 1
    @initialize_events()
    @validate()

  initialize_events: ->
    $('#rules').hammer(   ).on 'touch',     '@increse',       (e) => @increase_touch $(e.currentTarget),   @step
    $('#rules').hammer(   ).on 'touch',     '@decrese',       (e) => @increase_touch $(e.currentTarget), - @step
    $('#rules').hammer(   ).on 'release',   '@decrese, @increse', -> $(this).data('touched', false).data('drag-lock', false)
    $('#rules').hammer(   ).on 'dragstart', '@decrese, @increse', -> $(this).data('touched', false) unless $(this).data('drag-lock')
    $('#rules'            ).on 'click',     '@increse',       (e) => @increse($(e.currentTarget).data('index'),   @step); @validate()
    $('#rules'            ).on 'click',     '@decrese',       (e) => @increse($(e.currentTarget).data('index'), - @step); @validate()
    $('#rules'            ).on 'click',     '@locker',        (e) => @toggle_lock($(e.currentTarget).data('index'))
    $('@stabilize'        ).on 'click',                           => @stabilize()
    $('@add-rule'         ).on 'click',                           => @add_rule()
    @joyride_starter = $('@joyride-starter')
    @joyride_starter.on        'click',                       (e) => @joyride_toggle();

    @fix_navigation()

  window_resize: ->
    wh = $(window).height()
    nh = $('#top-nav').outerHeight()
    fh = $('footer').outerHeight()
    ih= $('#in_content').height()
    $content = $('#content')
    pd = parseInt($content.css('padding'))
    fo = if @nav_fixed then 0 else fh

    $content.css('height', wh - nh - fo)
    $('#in_content').height(wh - nh - fh - (pd * 2)) if ih + nh + fh + pd * 2 < wh


  fix_navigation: ->
    @nav_fixed = true
    $('body'            ).css 'overflow',   'hidden'
    $('body'            ).css 'height',     '100%'
    $('#content'        ).css 'overflow',   'scroll'
    $('#content'        ).css 'overflow',   '-moz-scrollbars-vertical'
    $('#content'        ).css 'overflow-x', 'hidden'
    $('#content'        ).css 'overflow-y', 'scroll'
    $('#content_wrapper').css 'height',     '100%'
    $(window).resize()
    $(document).scrollTop(0)

  unfix_navigation: ->
    @nav_fixed = false
    $('body'            ).css 'overflow', 'visible'
    $('body'            ).css 'height',   'inherit'
    $('#content'        ).css 'overflow', 'visible'
    $('#content_wrapper').css 'height',   'inherit'
    $('#content'        ).css 'height',   $('#in_content').outerHeight()
    $(window).resize()

  add_rule: ->
    rule = @role_tpl.clone()
    $('#rules').append rule
    @initialize_rule rule
    $(window).trigger 'resize'
    @validate()

  initialize_rule: (rule) ->
    @max_index += 1
    result =
      slider:  rule.find('@slider' ).data('index', @max_index).attr('id', "slider_#{@max_index}")
      value:   rule.find('@value'  ).data('index', @max_index)
      locker:  rule.find('@locker' ).data('index', @max_index).attr('id', "locker_#{@max_index}")
      increse: rule.find('@increse').data('index', @max_index)
      decrese: rule.find('@decrese').data('index', @max_index)
    @initialize_slider result.slider, result.value
    @rules[@max_index] = result

  initialize_slider: ($element, $value)->
    $element.noUiSlider
      range: [0, 100]
      start: parseFloat($value.val())
      handles: 1
      step: @step
      behaviour: "drag"
      serialization:
        to: $value
        resolution: @step
      slide: ->
        Ruler.slide this
    $element.find('.noUi-base').prepend(@translations.probability)

  slide: (slider)->
    index = slider.data('index')
    @validate()

  toggle_lock: (index)->
    locker = @rules[index].locker
    locker.children('i').toggleClass('fi-unlock').toggleClass('fi-lock')
    @rules[index].slider.toggleClass('locked')
    @validate()

  is_locked: (index)->
    @rules[index].slider.hasClass('locked')

  stabilize: () ->
    locked_sum = @locked_sum()
    return if locked_sum  > 100 || @sum() == 100
    unlocked = @max_index + 1 - @locked_count()
    diff = parseInt(100 / @step - locked_sum / @step)
    part = (diff - diff % unlocked) / unlocked
    @div =  diff - part * unlocked

    @locked_do ((rule) =>
      rule.slider.val(part * @step + (if @div > 0 then @step else 0))
      @div -= 1
    ), true
    @validate()

  validate: ->
    sum = @round(@sum())
    valid_sum = sum == 100
    valid_locked = @round(@locked_sum()) <= 100
    @probability_sum.html(parseFloat("#{sum}".slice(0,6)) + '%')
    if valid_locked then $('@stabilize').removeClass('alert') else $('@stabilize').addClass('alert')
    if valid_sum then $('@stabilize').addClass('success') else $('@stabilize').removeClass('success')
    for rule, index in @rules
      if valid_sum || (valid_locked && @is_locked(index))
        rule.slider.removeClass('alert_slider')
      else
        rule.slider.addClass('alert_slider')

  round: (float) ->
    Math.round(float / @step) * @step

  sum: ->
    @array_sum(parseFloat(rule.slider.val()) for rule in @rules)

  locked_sum: ->
    @array_sum(@locked_do (rule) -> parseFloat(rule.slider.val()))

  locked_do: (func, un=false) ->
    for rule, index in @rules
      is_locked = @is_locked(index)
      func(rule) if (!un && is_locked ) || (un && !is_locked)

  locked_count: ->
    @array_sum(@locked_do (rule) -> 1)

  array_sum: (array) ->
    sum = 0
    (sum += i if i) for i in array
    sum

  touch_increse: ($element, index, step, delay) ->
    return unless $element.data('touched')
    $element.data('drag-lock', true)
    val = @rules[index].slider.val()
    return unless (if step == @step then val < 100 else val > 0)
    @increse(index, step)
    delay -= parseInt(delay / 5) if delay > 25
    step = step * 10 if (delay == 164 || delay == 29) && step < 1
    @validate()

    setTimeout ( => @touch_increse $element, index, step, delay ), delay

  increase_touch: ($element, step) ->
    $element.data('touched', true)
    setTimeout ( => @touch_increse $element, $element.data('index'), step, 500 ), 250

  increse: (index, step)->
    slider = @rules[index].slider
    slider.val(parseFloat(slider.val()) + step)
  joyride_toggle: (to_start = true)->
    if @joyride_started && !to_start
      @joyride_started = false
      @fix_navigation()
      $('.joyride-close-tip').click()
    else if !@joyride_started && to_start
      @joyride_started = true
      @unfix_navigation()
      $(document).foundation 'joyride', 'start'
    else
      return

    @joyride_starter.toggle()

