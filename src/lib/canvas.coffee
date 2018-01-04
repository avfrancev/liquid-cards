import {TweenMax, Power0, Elastic} from 'gsap'

rand = (min,max) ->
  min + Math.floor( Math.random() * (max - min))

getOffset = (el) ->
  _x = 0
  _y = 0
  while el and !isNaN(el.offsetLeft) and !isNaN(el.offsetTop)
    _x += el.offsetLeft - (el.scrollLeft)
    _y += el.offsetTop - (el.scrollTop)
    el = el.offsetParent
  {
    top: _y
    left: _x
  }

pixelate = (canvas, ctx, img, ind, v) ->
  # ctx.mozImageSmoothingEnabled = false
  # ctx.webkitImageSmoothingEnabled = false
  # ctx.imageSmoothingEnabled = false
  size = v * 0.01
  w = Math.floor canvas.width * size
  h = Math.floor canvas.height * size
  ctx.drawImage img, 0, 0, w, h
  ctx.drawImage canvas, 0, 0, w, h, 0, 0, w,h

  imageData = ctx.getImageData 0,0,w,h
  pixelArray = imageData.data
  length = pixelArray.length / 4

  data = {
    size: {w,h}
    arr: []
  }
  i = 0
  r = 0
  c = 0
  while i < length
    index = 4 * i
    r = pixelArray[index]
    g = pixelArray[++index]
    b = pixelArray[++index]
    a = pixelArray[++index]
    data.arr.push {r,g,b,a}
    i++

  return data


export class Canvas
  constructor: (@card) ->
    @OFFSET = 300
    @SPREAD = 300
    @$image = new Image
    @$image.crossOrigin = "Anonymous"
    @$image.onload = @init.bind @
    @$image.src = @card.image_src

  init: (e)	->
    @c = document.createElement 'canvas'
    @ctx = @c.getContext '2d'
    @$card__image = document.querySelector "#card-#{@card.id} .thumb"
    @hCanvas = document.createElement 'canvas'
    @hCanvas.width = @$card__image.offsetWidth
    @hCanvas.height = @$card__image.offsetHeight
    hCtx = @hCanvas.getContext '2d'
    colorData = pixelate @hCanvas, hCtx, @$image, 1, 10
    {@w,@h} = colorData.size
    @colors = colorData.arr.map (x) -> "rgba(#{x.r},#{x.g},#{x.b},#{x.a})"

    do @prepareCanvas
    # document.body.appendChild @c
    @card.$card.parentElement.appendChild @c


  prepareCanvas: ->
    @imgPos = @$card__image.getBoundingClientRect()
    @c.style.position = 'absolute'

    @c.width = @imgPos.width + @OFFSET*2
    @c.height = @imgPos.height + @OFFSET*2
    {left,@top} = getOffset @$card__image

    @c.style.top = "#{@top-@OFFSET}px"
    @c.style.left = "#{left-@OFFSET}px"
    @c.style.display = 'none'

    @circles = []

    k = 0
    @ctx.clearRect 0,0,@c.width,@c.height
    for i in [0...@h]
      for j in [0...@w]
        @ctx.fillStyle = @colors[k]
        @ctx.beginPath()
        c = {
          x: j*@hCanvas.width/@w + @OFFSET + @hCanvas.width/@w/2
          y: i*@hCanvas.height/@h + @OFFSET + @hCanvas.width/@w/2
          r: @hCanvas.width/@w/2*Math.random()*2
          progress: 0
          height: 0
          alpha: 1
          dAlpha: 0.97
          color: @colors[k]
        }
        c.dx = rand c.x-@SPREAD, c.x+@SPREAD
        c.dy = rand c.y-@SPREAD, c.y+@SPREAD
        @circles.push c
        @ctx.arc c.x, c.y, c.r, 0, 2 * Math.PI, false
        @ctx.fill()
        k++

    do @onReady if typeof @onReady is 'function'
    return


  animate: () ->
    @ctx.clearRect(0,0,@c.width,@c.height)
    for c,i in @circles
      @ctx.globalAlpha = 1 - c.progress
      @ctx.fillStyle = c.color
      @ctx.beginPath()
      @ctx.arc c.x, c.y, c.r*(1-c.progress), 0, 2 * Math.PI, false
      @ctx.fill()
