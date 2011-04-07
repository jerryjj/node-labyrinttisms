###
Copyright 2011-2012 Jerry Jalava
 
    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at
 
        http://www.apache.org/licenses/LICENSE-2.0
 
    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
###

querystring = require 'querystring'
request = require 'request'

messages = require 'gwmessages'
Client = require 'gwclient'

class Server
  
  client: null
  constructor: (@config) ->
    @client = new Client @config
  
  setResponseReportUrl: (url) ->
    @config.options.server.response_reports_url = url
  
  receiveReportMessage: (req, res, cb) ->
    if !@_checkRemoteAddress(req)
      return @_errorResponse(res, 403, "Unallowed IP address")
    
    @_parseResponse req, (body) ->
      report = new messages.DeliveryReport body.dest,
        body['original-dest'],
        body.status,
        Number(body.code),
        body.message,
        body.msgid
      
      cb report
      Server.finalResponse(res)

  receiveSMS: (req, res, cb) ->
    if !@_checkRemoteAddress(req)
      return @_errorResponse(res, 403, "Unallowed IP address")
    
    @_parseResponse req, (body) ->
      msg = new messages.SMS
      msg.setSender body.source      
      msg.addRecipient body.dest      
      msg.operator = body.operator
      msg.keywords = body.keyword
      msg.parameters = body.params.split(" ")
      if body.header
        msg.header = body.header
      if body.text
        msg.setText body.text
      if body.binary
        msg.setBinary body.binary
      console.log "got message:"
      console.log msg
      cb msg
      Server.finalResponse(res)
        
  receiveMMS: (req, res, cb) ->
    console.log "Reading incoming MMS"
    # TODO: Implement
  
  _checkRemoteAddress: (req) ->
    # TODO: Implement
    if @config.options.server.allowed_ips.length == 0
      return true
    
    if req.headers['REMOTE_ADDR']
      console.log "req.headers REMOTE_ADDR: %s", req.headers["REMOTE_ADDR"]
    if req.headers['X-Client-IP']
      console.log "req.headers X-Client-IP: %s", req.headers["X-Client-IP"]
    
    return true
  
  _errorResponse: (res, code, message) ->
    res.writeHead code,
      'HTTP/1.1': String(code) + " " + message
      'Connection': 'close'
    res.end()
  
  @finalResponse: (res) ->
    res.writeHead 200, 'content-type': 'text/plain'
    res.end()
  
  _parseResponse: (req, cb) ->
    if req.body
      cb req.body
    
    full_body = ""
    req.on 'data', (chunk) ->
      full_body += chunk
    
    req.on 'end', () ->
      decoded_body = querystring.parse full_body
      cb decoded_body
      
module.exports = Server