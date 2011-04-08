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

labyrinttisms = require '../main'

Config = labyrinttisms.Config
Client = labyrinttisms.Client
messages = labyrinttisms.messages

TEST_USER = "test"
TEST_PASSWORD = "password"
TEST_RECEIVER = "1234567890"

test_config = new Config
  user: TEST_USER
  password: TEST_PASSWORD

# Client tests
vows.describe('SMS Client').addBatch
  'creating without arguments':
    topic: () ->      
      new Client
    'should be ok': (topic) ->
      assert.instanceOf topic, Client
  'creating with config, but without error callback':
    topic: () ->
      tc = new Config
        user: "user"
        password: "password"      
      new Client tc
    'user equals to user': (topic) ->
      assert.equal topic.config.options.user, "user"
    'password equals to password': (topic) ->
      assert.equal topic.config.options.password, "password"
  'creating with config and error callback':
    topic: () ->
      tc = new Config
        user: "user"
        password: "password"
      new Client tc
        , (err) -> return
    'error callback should be set': (topic) ->
      assert.isFunction topic.error_cb
  'trigger error callback':
    topic: () ->
      tc = new Config
        user: "user"
        password: "password"
      c = new Client tc
      , this.callback
      c.error_cb("Error")
    'should trigger': (err, _) ->
      assert.equal err, "Error"
  'Connect to service':
    topic: () ->
      new Client test_config
    'service url':
      'is set': (topic) ->
        uri = topic.getServiceUrl()
        assert.isNotNull uri
        assert.isString uri
      'matches': (topic) ->
        assert.equal topic.getServiceUrl(), "http://gw.labyrintti.com:28080/sendsms"
#Enable following test only if you have correct username and password for service
  # 'Send normal SMS':
  #   topic: () ->
  #     _s = this
  #     c = new Client test_config, (err) ->
  #       console.log "Error sending message"
  #       console.log err
  #       _s.callback(0, null)
  #     msg = new messages.SMS TEST_RECEIVER, "Hello, World! from node-labyrinttisms"
  #     c.send(msg, this.callback)
  #     return
  #   'status is int': (status, _) ->
  #     assert.isNotNull status
  #     assert.isNumber status
  #   'response is string': (_, response) ->
  #     assert.isNotNull response
  #     assert.isString response
  #     assert.equal response.trim(), TEST_RECEIVER + " OK 1 message accepted for sending"
      
.export module, error: false

