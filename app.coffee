
express = require("express")
app 		= express()
server  = require("http").createServer(app).listen(9001)
io      = require("socket.io").listen(server)
exphbs 	= require("express3-handlebars")
StockProcess 	= require(__dirname + "/lib/stock_process.coffee")
DataAccess         = require( __dirname + '/lib/data_access.coffee');

process.env.NODE_ENV = process.env.NODE_ENV || 'development'

app.use express.compress()
app.use express.basicAuth (user, pass) ->
  user == 'raymond' and pass == 'Google'

if process.env.NODE_ENV is "production"
  # Set the default layout and locate layouts and partials
  app.engine "handlebars", exphbs(
    defaultLayout: "main"
    layoutsDir: "dist/views/layouts/"
    partialsDir: "dist/views/partials/"
  )
  app.set "views", __dirname + "/dist/views"
  app.use express.static(__dirname + "/dist/assets")
  app.use express.bodyParser()
else
  app.engine "handlebars", exphbs(
    defaultLayout: "main"
    layoutsDir: "views/layouts/"
    partialsDir: "views/partials/"
  )
  app.set "views", __dirname + "/views"
  app.use express.static(__dirname + "/assets")
  app.use express.bodyParser()

app.set "view engine", "handlebars"

st = new StockProcess(io, (new DataAccess()))
st.init()

app.get "/", (request, response, next) ->
  response.render "index"
  return
app.post "/add_stock", (req,res,next) ->
  res.writeHead(200,{"content-type":"text/html;charset=UTF8;"})
  res.end('ok')
  st.add_stock(req.body)


st.start_message_loop 1000 * 10


#app.listen(9000) 

