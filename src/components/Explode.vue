<template lang="pug">
  #explode
    //- div(v-for="card in cards" :key="card.id")
    //-   pre {{card}}
    avf-transition#cards(:style="{ display: cards.length > 0 ? 'grid' : 'none' }")
      .card(v-for="card,i in cards" :key="card.id" :id="'card-'+card.id" :avf-id="card.id"  )
        //- pre {{card}}
        h1(v-if="!card.image_src" style="text-align:center")  😎
        .inner(v-if="card.image_src")
          section.thumb(:style="'background-image:url('+card.image_src+')'")
          //- div {{card.image_src}}
          section.btn-group
            button(@click="removeCard(card)") &#9992;
            button(@click="removeCard(card)") &#9829;
            button.remove(@click="removeCard(card)") &#10008;
          section.meta
            img.avatar(:src="card.avatar")
            .info
              .title {{card.title}}
              .author by {{card.author}}
          //- button(@click="drawCanvas") DRAW
    //- #refresh(v-if="!loading && cards.length == 0")
    //-   button(@click='fetchCards') refresh
</template>

<script lang="coffee">
  import {TimelineMax, TweenMax} from 'gsap'
  import {Canvas} from '@/lib/canvas.coffee'
  import AVFTransition from '@/components/AVF-Transition/index.coffee'
  import axios from 'axios'
  import faker from 'faker/locale/en'

  export default {

    components: {'avf-transition': AVFTransition}

    data: ->
      cards: []
      cardz: []
      cardsCount: 6

    created: ->
      do @fetchCards

    methods:
      fetchCards: ->
        @loading = true
        for i in [0...@cardsCount]
          id = new Date().getTime()+i
          # @cardz.push
          #   id: id
          @cards.push
            id: id
            author: faker.name.findName()
            avatar: faker.image.avatar()
            title: faker.lorem.words()
            image_src: false
          do (id) =>

            card = (_i for _i in @cards when _i.id is id)[0]

            axios.get("https://source.unsplash.com/random?sig=#{id}").then((x) =>
              img = new Image
              img.onload = =>
                @$set @cards, @cards.indexOf(card), {
                  card...
                  image_src: x.request.responseURL
                }
              img.src = x.request.responseURL
              return
            ).catch (err) =>
              console.log err
              @$delete @cards, @cards.indexOf(card)





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

        tl.to el.querySelector('.thumb'), 0.1, {
          opacity: 0
        }, '-=1'

        tl.to el, 1, {
          y:"-=#{el.offsetHeight/2}"
          scale: '0'
          opacity: -1
          # height: 0
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
            if @cards.length < 6
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

      &:hover
        section.thumb
          transform-origin: 100% 100%
          transform: perspective(500px) rotateY(10deg) rotateX(0deg) scale(1.05)
          // transform: rotateX(50deg)
          // background-size: 120%
        section.btn-group
          button
            transform: translateY(-20px)
            opacity: 1

    .inner
      // font-family: 'Lobster', cursive
      // position: relative
      overflow: hidden
      border-radius: 3px
      box-shadow: 0 12px 30px -10px rgba(#000,1)
      display: grid
      grid-template-rows: minmax(150px, calc(50vh - 140px)) auto

      // grid-template-rows: 2fr 1fr 1fr

    section.thumb
      background-size: cover
      background-position: center
      background-repeat: no-repeat
      transition: 0.4s
      transform-origin: 50% 30%
      // transition-timing-function: cubic-bezier(0.175, 0.885, 0.32, 1.275)
      transform: perspective(500px) rotateX(0deg)
      z-index: -1

    section.meta
      display: grid
      grid-template-columns: auto 1fr
      grid-column-gap: 10px
      background: $color5
      padding: 16px 12px

      img.avatar
        border-radius: 50%
        height: 40px

      .title
        font-weight: bold
        &:first-letter
          text-transform: capitalize

      .author
        font-size: 0.8em
        font-style: italic

    section.btn-group
      // position: absolute
      height: 0
      text-align: right
      button
        transition: transform 0.2s, opacity 0.2s, box-shadow 0.1s
        transition-timing-function: cubic-bezier(0.175, 0.885, 0.32, 1.275)
        // transition-timing-function: cubic-bezier(0.68, -0.55, 0.265, 1.55)
        opacity: 0
        cursor: pointer
        font-size: 1.5em
        height: 40px
        width: 40px
        border-radius: 50%
        margin-right: 15px
        box-shadow: 0 2px 15px -5px #000
        color: #fff
        background: $color4
        border: none
        &:hover
          background: darken($color4,10%)

        &.remove
          background: $color3
          &:hover
            background: darken($color3,10%)

        @for $i from 1 through 3
          &:nth-of-type(#{$i})
            transition-delay: #{50 * $i}ms



    @include mq($until: tablet)
      grid-template-columns: 1fr
      .inner
        grid-template-rows: calc(100vh - 150px)
      .thumb
        height: 100%
    @include mq(tablet)
      grid-template-columns: 1fr 1fr
    @include mq(wide)
      grid-template-columns: 1fr 1fr 1fr




</style>
