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

vows = require 'vows'
assert = require 'assert'

laryrinttisms = require '../main'

request = require 'request'
querystring = require 'querystring'
server = require './server'

Config = laryrinttisms.Config
Server = laryrinttisms.Server
messages = laryrinttisms.messages

TEST_USER = "test"
TEST_PASSWORD = "password"
TEST_RECEIVER = "1234567890"

test_config = new Config
  user: TEST_USER
  password: TEST_PASSWORD
  
ws = server.createServer()

dataAsString = (data) ->
  querystring.stringify data

# Server tests
vows.describe('SMS Server').addBatch
  'creating without arguments':
    topic: () ->      
      new Server
    'should be ok': (topic) ->
      assert.instanceOf topic, Server
  'creating with config':
    topic: () ->
      tc = new Config
        user: "user"
      new Server tc
    'user equals to user': (topic) ->
      assert.equal topic.config.options.user, "user"
      
  'handling delivery report':
    topic: () ->
      srv = new Server test_config
      
      cb = this.callback
      
      ws.on '/report', (req, res) ->
        srv.receiveReportMessage req, res, cb
      
      request 
        uri: ws.url + '/report'
        method: "POST"
        headers:
          'content-type': 'application/x-www-form-urlencoded'
        body: dataAsString
          dest: TEST_RECEIVER
          'original-dest': TEST_RECEIVER
          status: "OK"
          code: "0"
          message: "Message delivered"
          msgid: 1
        , (err, res, body) ->
          console.log "ws response"
          console.log err
          console.log res
          console.log body
          if err
            throw err
      
      return
      
    'result is DeliveryReport instance': (report) ->
      assert.instanceOf report, messages.DeliveryReport
      
    'report has valid message_id': (report) ->
      assert.equal report.message_id, 1

    'report has valid recipient': (report) ->
      assert.equal report.recipient, TEST_RECEIVER
      
    'report status is OK': (report) ->
      assert.equal report.state, "OK"
      
    'report error is 0': (report) ->
      assert.equal report.error, 0
      
    'report isDelivered equals true': (report) ->
      assert.equal report.isDelivered(), true
      
    'report isDelayed equals false': (report) ->
      assert.equal report.isDelayed(), false
      
    'report isFailed equals false': (report) ->
      assert.equal report.isFailed(), false
  
  'handling íncoming SMS':
    topic: () ->
      srv = new Server test_config
    
      cb = this.callback
    
      ws.on '/incoming_sms', (req, res) ->
        srv.receiveSMS req, res, cb
      
      request 
        uri: ws.url + '/incoming_sms'
        method: "POST"
        headers:
          'content-type': 'application/x-www-form-urlencoded'
        body: dataAsString
          source: TEST_RECEIVER
          operator: "nodejs"
          dest: "12345"
          keyword: "TEST"
          params: "sample message"
          text: "test sample message"
        , (err, res, body) ->
          if err
            throw err
    
      return
    
    'result is SMSMessage instance': (msg) ->
      assert.instanceOf msg, messages.SMS
    
    'message has valid message_id': (msg) ->
      assert.isNotNull msg.id
      assert.isString msg.id

    'message has valid sender': (msg) ->
      assert.equal msg.sender, TEST_RECEIVER
      
    'message has valid keyword': (msg) ->
      assert.equal msg.keywords, "TEST"
      
    'message has valid params': (msg) ->
      assert.equal msg.parameters.length, 2
      
    'message has valid text': (msg) ->
      assert.equal msg.text, "test sample message"
      
    # 'message has valid receiver': (msg) ->
    #   assert.isTrue msg.hasRecipient "12345"
      
      
.export module, error: false