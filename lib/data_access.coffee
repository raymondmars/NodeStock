class DataAccess
  constructor: ->
    @mongo_client = require("mongodb").MongoClient
    @env = process.env.NODE_ENV 
    #if @env == 'production'
      #@mongo_conn_str = "mongodb://127.0.0.1:27017/stock_production"
    #else
      #@mongo_conn_str = "mongodb://127.0.0.1:27017/stock_development"

    redis =  require("redis")
    @redis_client = redis.createClient()

  welcome: =>
    console.log('hello,world')

  get_data: (tb_name,query,sort_obj,call_back)=>
    @mongo_client.connect @mongo_conn_str, (err,db) =>
      if err
        console.log err
      else
        collection = db.collection(tb_name)
        if sort_obj
          collection.find(query).sort(sort_obj).toArray (e,results) ->
            db.close()
            call_back(results)
        else
          collection.find(query).toArray (e,results) ->
            db.close()
            call_back(results)

  get_cache: (key,call_back)=>
    @redis_client.get key, call_back
  set_cache: (key,val)=>
    if val.constructor == Object or val.constructor == Array
      val = JSON.stringify(val)
    @redis_client.set key,val

module.exports = DataAccess
