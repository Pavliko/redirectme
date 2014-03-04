$body = $ 'body'
$container = $ '<div role="alerts-container" id="alerts_container" />'
$container.appendTo $body

class Alert
  constructor: (container, text, extra_classes = '', is_fading = false ) ->
    @speed = if is_fading then 4000 else 300
    @container = container
    @body = $ """
            <div data-alert class="alert-box #{extra_classes}">
              #{text}
              <a href="#" class="close">&times;</a>
            </div>
            """
    @show()
    @fading() if is_fading
    this
  show: ->
    @container.show().append(@body).foundation('alert', {animation_speed: @speed, speed: @speed, callback: => @check_container() })
  fading: ->
    self = this
    @body.delay(1000).hover(-> $(this).stop().fadeIn().mouseout(-> $(this).stop().fadeOut(self.speed, -> self.check_container()))).find('.close').click().hide()
  check_container: ->
    @container.hide() if @container && @container.find('[data-alert]:visible').length == 0

$.alert = (text, extra_classes = '', fading = false) ->
  new Alert($container, text, extra_classes, fading).show()

$.fading_alert = (text, extra_classes = '') ->
  @alert(text, extra_classes, true)

