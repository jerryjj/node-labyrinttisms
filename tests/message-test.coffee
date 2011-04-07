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

messages = laryrinttisms.messages

SMS = messages.SMS

# Message tests
vows.describe('SMS Message').addBatch
  'creating without arguments':
    topic: () ->      
      new SMS
    'should be ok': (topic) ->
      assert.instanceOf topic, SMS
  'creating with receiver':
    topic: () ->
      new SMS "+358123456789"
    'receiver should be set':
      'recipients equals to one': (topic) ->
        assert.equal topic.recipients.length, 1
      'first recipients number should match': (topic) ->
        assert.equal topic.recipients[0], "+358123456789"
    'content is null': (topic) ->
      assert.isNull topic.text
  'creating with content':
    topic: () ->
      new SMS "+358123456789", "Hello, World!"
    'content is set': (topic) ->
      assert.isNotNull topic.text
      assert.equal topic.text, "Hello, World!"
.export(module)