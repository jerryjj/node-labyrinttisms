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
CoffeeScript = require 'coffee-script'

messages = require 'gwmessages'

class Client
  @mmsuri = "/sendmms"
  @smsuri = "/sendsms"
  
  constructor: (@config, @error_cb) ->
    return
  
  setReportUrl: (url) ->
    @config.options.client.report_url = url
  
  send: (message, callback) ->
    console.log "send message: %s; to: ", message.text, message.recipients
    # console.log message
    if not message?
      if @error_cb
        return @error_cb "No message set"
      return
    
    url = @getServiceUrl message.type
    
    #callback 200, "+358123456789 OK 1 message accepted for sending"
    
    request
      uri: url
      , method: 'POST'
      , body: @_generatePostData(message)
      , headers:
        'content-type': 'application/x-www-form-urlencoded'
      , (error, response, body) ->
        if !error && response.statusCode == 200
            callback response.statusCode, body
        else
          if @error_cb
            @error_cb error
    
    return
  
  getServiceUrl: (type="sms") ->
    url = "http://"
    if @config.options.secure
      url = "https://"
    url += @config.options.host + ":" + @config.options.port
    if type is "sms"
      url += Client.smsuri
    else if type is "mms"
      url += Client.mmsuri
    return url
    
  _generatePostData: (msg) ->
    data = 
      user: @config.options.user
      password: @config.options.password
    
    if @config.options.client.report_url
      data['report'] = @config.options.client.report_url
    
    data = CoffeeScript.helpers.merge data, msg.getPostDataParts()
    
    querystring.stringify data
  
module.exports = Client