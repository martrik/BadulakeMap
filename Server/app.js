var express = require('express');
var bodyParser = require('body-parser');
var timeout = require('connect-timeout');

var routes = require('./routes/index');
var badulake = require('./routes/badulake');

var app = express()

// Config
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: false }));
app.use(express.static(__dirname + '/public'));
app.use(timeout('20s'));


// Routes
app.use('/', routes);
app.use('/badulake', badulake);

// Timeout
module.exports = app;
