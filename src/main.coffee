import Vue from 'vue'
import App from './App'

Vue.config.productionTip = false

console.log __VERSION__

new Vue(
  el: '#app'
  template: '<App/>'
  components: App: App)
