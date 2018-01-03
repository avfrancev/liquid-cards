import './styles.sass'
import {TimelineMax, TweenMax, Power4, Elastic, Linear, Expo} from 'gsap'

export default {
  functional: true
  render: (createElement, context) ->
    data = {
      context.data...
      props:
        name: 'avf-transition'
        tag: 'div'
        # css: true
        # appear: true
      on:
        enter: (el, done) ->
          id = el.getAttribute 'avf-id'
          tl = new TimelineMax
          tl.from el, 1, {
            opacity: 0
          }
          tl.from el, 1, {
            y: 30
            ease: Elastic.easeOut.config(1, 0.3)
            onComplete: done
          }, '-=1'
    }
    createElement 'transition-group', data, context.children
}
