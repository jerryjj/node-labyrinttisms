#!/bin/sh
coffee -bc tests/*.coffee
vows tests/*-test.coffee --spec