#mocha --compilers coffee:coffee-script -R spec
chai = require 'chai'
chai.should()
DataAccess         = require('../lib/data_access.coffee');

describe 'Test Retrive Data', ->
  ac = new DataAccess()
  http = require('http')
  Iconv = require('iconv').Iconv
  it 'the redis should be work', (done)->
    ac.set_cache('test',{name: 'raymond'})
    ac.get_cache 'test', (err,val)->
      if err
        throw err
      #val.name.should.equal 'raymond'
      JSON.parse(val).name.should.equal 'raymond'
      done()

  it 'the stock cache is work', (done)->
    ac.get_cache 'stock', (err,val)->
      if err
        throw err
      list = JSON.parse(val)
      list.should.not.equal null
      
      console.log list[0].key
      done()

  it 'get data from sina is fine', (done) ->
    options = 
      host: 'hq.sinajs.cn'
      port: 80
      path: '/list=sz000100'

    req = http.request(options, (res) ->
      html = ""
      res.setEncoding "binary"
      
      res.on "data", (chunk) ->
        html += chunk

      res.on "end", ->
        buf = new Buffer(html,'binary')
        gbk_to_utf8_iconv = new Iconv('GBK', 'UTF-8//TRANSLIT//IGNORE')
        utf8_buffer = gbk_to_utf8_iconv.convert(buf)
        s_array = utf8_buffer.toString().split '='
        val = s_array[1].split(',')
        console.log val[0].replace "\"",""
        console.log val[1]
        console.log val[2]
        console.log val[3]
        stock = 
          key: 'sz000100'
          name: val[0].replace "\"",""
          opening_price: val[1]
          closing_price: val[2]
          current_price: val[3]
          is_upward: ((parseFloat(val[3]) - parseFloat(val[1])).toFixed(2) > 0)
          up_down_val: (parseFloat(val[3]) - parseFloat(val[1])).toFixed(2)

        console.log stock 

        done()

    )
    req.on "error", (e) ->
      console.log ("Read failed: " + e.message).red
      done()

    req.end()


