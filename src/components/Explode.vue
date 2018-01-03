<template lang="pug">
  #explode
    avf-transition#cards(:style="{ display: cards.length > 0 ? 'grid' : 'none' }")
      .card(v-for="card,i in cards" :key="card.id" :id="'card-'+card.id" :avf-id="card.id")
        //- pre {{card}}
        .card__inner
          .card__image(:style="'background-image:url('+card.image_src+')'")
          h4 Card {{card.id}}
          button(@click="removeCard(card)") DEL
          //- button(@click="drawCanvas") DRAW
    #refresh(v-if="!loading && cards.length == 0")
      button(@click='fetchCards') refresh
</template>

<script lang="coffee">
  import {TimelineMax, TweenMax, Power4, Elastic, Linear, Expo} from 'gsap'
  import {Canvas} from '@/lib/canvas.coffee'
  import AVFTransition from '@/components/AVF-Transition/index.coffee'
  import axios from 'axios'

  export default {

    components: {'avf-transition': AVFTransition}

    data: ->
      cards: []
      cardsCount: 5

    created: ->
      do @fetchCards

    methods:
      fetchCards: ->
        @loading = true
        for i in [0...@cardsCount]
          do (i) =>
            axios.get("https://source.unsplash.com/random?sig=#{i}").then (x) =>
              img = new Image
              img.src = x.request.responseURL
              img.onload = =>
                @loading = false if i is @cardsCount - 1
                @cards.push
                  id: new Date().getTime()
                  image_src: x.request.responseURL


      addCard: (card) ->
        card.id = ++@nextCardId
        @cards.push card

      removeCard: (card) ->
        card.$card = @$el.querySelector "#card-#{card.id}"
        card.canvas = new Canvas card
        card.canvas.onReady = @animateRemove.bind @, card

      animateRemove: (card) ->
        el = card.$card
        clipMask =
          top: 0

        tl = new TimelineMax

        tl.set card.canvas.c, {display: 'block'}
        tl.set el, {transition: 'none'}

        tl.fromTo card.canvas.c, 1, {opacity:0}, {opacity:1}

        tl.to el.querySelector('.card__image'), 0.1, {
          opacity: 0
        }, '-=1'

        tl.to el, 1, {
          y:"-=#{el.offsetHeight/3}"
          scale: '0'
          opacity: -1
          ease: Expo.easeInOut
          # onComplete: -> console.log '---------'
          onComplete: =>
            # card.canvas.c.remove()
            tl.set el, {transition: '10.5s'}
            @cards.splice @cards.indexOf(card), 1
        }, '-=1'

        tl.to card.canvas.circles, 3, {
          x: (cind) => card.canvas.circles[cind].dx
          y: (cind) => card.canvas.circles[cind].dy
          # ease: Expo.easeInOut
          progress: 1
          onUpdate: card.canvas.animate.bind card.canvas
          onComplete: =>
            card.canvas.c.remove()
            if @cards.length < 3
              console.log @cardsCount = Math.floor(5 - Math.random()*5) or 2
              do @fetchCards
        }, '-=1'

  }
</script>





<style lang="sass">
  @import url('https://fonts.googleapis.com/css?family=Lobster&subset=cyrillic')
  @import '../colors.sass'
  @import '~sass-mq'

  canvas
    filter: url(#liquid)
    pointer-events: none

  #refresh
    height: 100vh
    display: grid
    justify-items: center
    align-items: center

    button
      -moz-box-shadow: 0px 10px 14px -7px #05a88a
      -webkit-box-shadow: 0px 10px 14px -7px #05a88a
      box-shadow: 0px 10px 14px -7px #05a88a
      background: -webkit-gradient(linear, left top, left bottom, color-stop(0.05, #02bd9b), color-stop(1, #15dbb7))
      background: -moz-linear-gradient(top, #02bd9b 5%, #15dbb7 100%)
      background: -webkit-linear-gradient(top, #02bd9b 5%, #15dbb7 100%)
      background: -o-linear-gradient(top, #02bd9b 5%, #15dbb7 100%)
      background: -ms-linear-gradient(top, #02bd9b 5%, #15dbb7 100%)
      background: linear-gradient(to bottom, #02bd9b 5%, #15dbb7 100%)
      filter: progid:DXImageTransform.Microsoft.gradient(startColorstr='#02bd9b', endColorstr='#15dbb7',GradientType=0)
      background-color: #02bd9b
      -moz-border-radius: 4px
      -webkit-border-radius: 4px
      border-radius: 4px
      border: 1px solid #18c9a9
      display: inline-block
      cursor: pointer
      color: #ffffff
      font-family: Arial
      font-size: 16px
      font-weight: bold
      padding: 8px 22px
      text-decoration: none
      text-shadow: 0px 1px 0px #00a688
      &:hover
        background: -webkit-gradient(linear, left top, left bottom, color-stop(0.05, #15dbb7), color-stop(1, #02bd9b))
        background: -moz-linear-gradient(top, #15dbb7 5%, #02bd9b 100%)
        background: -webkit-linear-gradient(top, #15dbb7 5%, #02bd9b 100%)
        background: -o-linear-gradient(top, #15dbb7 5%, #02bd9b 100%)
        background: -ms-linear-gradient(top, #15dbb7 5%, #02bd9b 100%)
        background: linear-gradient(to bottom, #15dbb7 5%, #02bd9b 100%)
        filter: progid:DXImageTransform.Microsoft.gradient(startColorstr='#15dbb7', endColorstr='#02bd9b',GradientType=0)
        background-color: #15dbb7
      &:active
        position: relative
        top: 1px

  #explode
    padding: 30px 0
    position: relative
    min-height: 100vh


  #cards
    // display: flex
    max-width: 80vw
    // flex-direction: row
    margin: 0 auto
    // height: 100%
    display: grid
    // display: inline-block
    // grid-template-columns: repeat(3, 1fr)
    grid-template-columns: 1fr 1fr
    grid-column-gap: 50px
    grid-row-gap: 50px
    // grid-template-columns: repeat(auto-fit, minmax(300px, 1fr))
    justify-items: center
    align-items: center
    // position: relative

    .card
      width: 100%
      color: $color1


    .card__inner
      font-family: 'Lobster', cursive
      overflow: hidden
      border-radius: 3px
      text-align: center
      background: $color5
      box-shadow: 0 12px 30px -10px rgba(#000,1)
      display: grid
      grid-template-rows: minmax(150px, calc(50vh - 140px)) auto
      // grid-template-rows: 2fr 1fr 1fr

    .card__image
      // min-height: 250px
      background-size: cover
      background-position: center
      background-repeat: no-repeat

    @include mq($until: tablet)
      grid-template-columns: 1fr
      .card__inner
        grid-template-rows: calc(100vh - 150px)
      .card__image
        height: calc(50vh - 30px)
    @include mq(tablet)
      grid-template-columns: 1fr 1fr
    @include mq(wide)
      grid-template-columns: 1fr 1fr 1fr


</style>
