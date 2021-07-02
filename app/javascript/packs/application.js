// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.

require("@rails/ujs").start()
require("turbolinks").start()
require("@rails/activestorage").start()
require("channels")
require("jquery")

require('animate.css')

require("chart.js")
require("chartkick").use(require("highcharts"))

require('datatables.net')

import 'controllers'

// import '../stylesheets/application.scss'
require("../stylesheets/application.scss")

window.Highcharts = require('highcharts')

window.dispatchMapsEvent = function (...args) {
    const event = document.createEvent("Events")
    event.initEvent("google-maps-callback", true, true)
    event.args = args
    window.dispatchEvent(event)
}

$(document).on('turbolinks:load', function(event){
  $(".loader-wrapper").fadeOut("slow");
})
import "controllers"
