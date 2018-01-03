<template>
  <div id="app">
    <Explode/>
    <svg id="svg-liquid" xmlns="http://www.w3.org/2000/svg" version="1.1">
      <defs>
        <filter id="liquid">
          <feGaussianBlur in="SourceGraphic" stdDeviation="6" result="blur" />
          <feColorMatrix in="blur" mode="matrix" values="1 0 0 0 0  0 1 0 0 0  0 0 1 0 0  0 0 0 50 -10"/>
        </filter>
      </defs>
    </svg>
  </div>
</template>

<script>
import Explode from './components/Explode'

export default {
  name: 'app',
  components: {
    Explode
  }
}
</script>

<style lang="sass">

  @import './colors.sass'

  body
    background: $color1
    margin: 0

  #app
    font-family: 'Avenir', Helvetica, Arial, sans-serif
    -webkit-font-smoothing: antialiased
    -moz-osx-font-smoothing: grayscale
    overflow: hidden
    color: #fff

  #svg-liquid
    position: absolute
    top: -999px
    visibility: hidden

</style>
