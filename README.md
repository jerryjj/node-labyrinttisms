WARNING: Under development, simple SMS sending and receiving works
==================================================================

2-way SMS Gateway library
=========================

For use with Finnish Labyrintti Media's SMS Gateway.
Written with CoffeeScript

Installation
============

    git clone git://github.com/jerryjj/node-labyrinttisms.git
    cd node-labyrinttisms
    ./compile_all.sh
    sudo npm link

Usage
=====

Examples in CoffeeScript

Client
======

    labyrinttisms = require 'labyrinttisms'

    Config = labyrinttisms.Config
    Client = labyrinttisms.Client
    messages = labyrinttisms.messages

    config = new Config
      user: "YOUR_USERNAME"
      password: "YOUR_PASSWORD"
 
    c = new Client config, (err) ->
      console.log "Error sending message"
      console.log err

    msg = new messages.SMS "+358123456789", "Hello, World! from node-labyrinttisms" # receiver, message
    c.send msg, (status, response) ->
      console.log "status: %s", status # 200
      console.log "response: %s", response # +358123456789 OK 1 message accepted for sending

Server (receive sms reports and incoming SMS)
=============================================

Server works with plain node or with framework like express


    labyrinttisms = require 'labyrinttisms'

    Config = labyrinttisms.Config
    Server = labyrinttisms.Server

    config = new Config
      user: "YOUR_USERNAME"
      password: "YOUR_PASSWORD"

    labserver = new Server config

    port = 6767
    s = http.createServer (req, resp) ->
      s.emit req.url, req, resp    
    s.listen port
    s.url = 'http://localhost:' + port

    s.on '/report', (req, res) ->
      labserver.receiveReportMessage req, res, (report) ->
        console.log "Received Delivery report of sms"
        console.log "recipient: %s", report.recipient
        console.log "state: %s", report.state    
        console.log "isDelivered: %s", report.isDelivered()
    
    s.on '/incoming_sms', (req, res) ->
      labserver.receiveSMS req, res, (msg) ->
        console.log "Received SMS"
        console.log "sender: %s", msg.sender
        console.log "keywords: %s", msg.keywords
        console.log "text: %s", msg.text
        