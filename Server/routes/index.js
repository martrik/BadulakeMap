var express = require('express');
var pg = require('pg');
var router = express.Router();
var connectionString = process.env.DATABASE_URL || 'postgres://localhost:5432/badulakedb';


/* GET home page. */
router.get('/', function(req, res) {

    res.send("Read API reference to know about the end points");

});

module.exports = router;
