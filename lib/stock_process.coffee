class StockProcess
  constructor: (io,dao)->
    @io = io
    @dao = dao
    @io.configure "production", ->
      io.enable "browser client minification"
      io.enable "browser client etag"
      io.enable "browser client gzip"
      io.set "log level", 1
      io.set "origins", "*:*"
      io.set "transports", ["websocket", "flashsocket", "htmlfile", "xhr-polling", "jsonp-polling"]

    @io.configure "development", ->
      io.set "origins", "*:*"
      io.set "transports", ["websocket", "flashsocket", "htmlfile", "xhr-polling", "jsonp-polling"]

    @_ = require('underscore')
    @date = require("date-utils")
    @http = require('http')

  init: ()=>
    @io.sockets.on "connection", (socket) ->
      socket.emit('connected','hello,client. -- from server')

  start_message_loop: (internal_time)=>
    time = internal_time || 2000
    #console.log time
    #@data_access.welcome()
    @timer = setInterval @process_data, time

  stop: =>
    window.clearInterval(@timer) if @timer

  process_data: =>
    @dao.get_cache 'stock', (err,data)=>
      throw err if err
      s_io = @io
      if data and data != ''
        list = JSON.parse(data)
        #list = list.sort (a,b)->
        #return (a.key.replace(/[^\d]+/,'') > (a.key.replace(/[^\d]+/,'')

        @_.each list, (item) =>
          @get_http_data item.key, (dt)->
            s_io.sockets.emit('stock::update',dt)

  get_http_data: (key, callback) =>
    options = 
      host: 'hq.sinajs.cn'
      port: 80
      path: "/list=#{key}"
    Iconv = require('iconv').Iconv
    req = @http.request options, (res) =>
      html = ""
      res.setEncoding "binary"
      res.on "data", (chunk) ->
        html += chunk
      res.on "end", ->
        buf = new Buffer(html,'binary')
        gbk_to_utf8_iconv = new Iconv('GBK', 'UTF-8//TRANSLIT//IGNORE')
        utf8_buffer = gbk_to_utf8_iconv.convert(buf)
        s_array = utf8_buffer.toString().split '='
        target = s_array[1].replace("\"\";","").replace(/[\s\\n]*/,'')

        if target != ''
          val = s_array[1].split(',')
          diff = (parseFloat(val[3]) - parseFloat(val[1])).toFixed(2)
          cls = 'red'
          prefix = ''
          if diff  >=0
            if diff > 0
              cls = 'red'
              prefix = '+'
            else
              cls = 'grey'
          else
            cls = 'green'
            prefix = '-'

          s_v = 
            key: key
            name: val[0].replace "\"",""
            opening_price: val[1]
            closing_price: val[2]
            current_price: val[3]
            up_down_val: prefix + (Math.abs((parseFloat(val[3]) - parseFloat(val[2])).toFixed(2))).toString()
            cls: cls
          callback(s_v)
        else
          callback(null)

    req.on "error", (e) ->
      console.log ("Read failed: " + e.message).red
    req.end()

  add_stock: (body)=>
    console.log body,'..ok'
    key = body.stock_key
    @dao.get_cache 'stock', (err,data)=>
      throw err if err
      if data and data != ''
        list = JSON.parse(data)
      else
        list = []
      find_item = @_.find list, (item)->
        item.key == key
      if typeof find_item == 'undefined'
        @get_http_data key, (dt)=>
          if dt != null
            list.push {key: key}
            @dao.set_cache('stock', list)
            console.log list


module.exports = StockProcess
