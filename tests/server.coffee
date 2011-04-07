http = require 'http'

exports.createServer = (port) ->
  port = port || 6767
  s = http.createServer (req, resp) ->
    s.emit req.url, req, resp
  s.listen port
  
  s.url = 'http://localhost:'+port  
  return s