import Vue from 'vue'
import App from './App'
import VueYandexMetrika from 'vue-yandex-metrika'

Vue.config.productionTip = false

Vue.use VueYandexMetrika,
  id: 47209410
  # env: 'production'
  env: process.env.NODE_ENV

console.log process.env.NODE_ENV



new Vue(
  el: '#app'
  template: '<App/>'
  components: App: App)
