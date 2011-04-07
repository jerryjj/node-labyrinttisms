#!/bin/sh
coffee -bc *.coffee && coffee -bc lib/*.coffee && coffee -bc tests/*.coffee
