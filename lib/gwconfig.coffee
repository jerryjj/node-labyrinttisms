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

class Config
  defaults:
    user: null
    password: null
    host: "gw.labyrintti.com"
    port: 28080
    secure: false
    client:
      report_url: null
    server:
      allowed_ips: []
      response_report_url: null
  
  constructor: (options) ->
    @options = CoffeeScript.helpers.merge @defaults, options
    
module.exports = Config