var express = require('express');
var pg = require('pg');
var router = express.Router();
var connectionString = process.env.DATABASE_URL || 'postgres://localhost:5432/badulakedb';

// Get all stored badulakes
router.get('/', function(req, res) {

    // Get a Postgres client from the connection pool
    pg.connect(connectionString, function(err, client, done) {

        var handleError = function(err) {
            if(!err) return false;

            done(client);
            res.status(500).json('An error occurred');
            return true;
        };

        // SQL Query
        var query = client.query("SELECT * FROM badulakedb ORDER BY id ASC;", function(err, result) {

            // Handle Errors
            if(handleError(err)) return;

            // Return client to pool and send result
            done();
            res.status(200).json(result["rows"]);
        });
    });
});

// Create new badualke
router.post('/', function(req, res, next) {

    // Check if all parameters are in request
	if (req.body.name && req.body.longitude && req.body.latitude && req.body.alwaysopened != undefined) {

		// Get a Postgres client from the connection pool
    	pg.connect(connectionString, function(err, client, done) {

            var handleError = function(err) {
                if(!err) return false;

                done(client);
                res.status(500).json('An error occurred');
                return true;
            };

        	// SQL Query
        	client.query("INSERT INTO badulakedb (name, longitude, latitude, alwaysopened) values($1, $2 , $3, $4)",
                [req.body.name, req.body.longitude, req.body.latitude, req.body.alwaysopened], function(err, result) {

                    // Handle Errors
                    if(handleError(err)) return;

                    // Return client to pool and send result
                    done();
                    res.status(201).json({"res": "Badulake added"});
                });

        });
    } else {
    	res.status(206).json({"res" : "Missing params"});
   }
});

// Modify existent badulake
router.put('/', function(req, res, next) {

    // Check if request has id
    if (req.body.id) {
        var reqParams = [["name", req.body.name], ["longitude", req.body.longitude], ["latitude", req.body.latitude], ["alwaysopened" ,req.body.alwaysopened]];
        var query = "UPDATE badulakedb SET";
        var queryParams = [];

        // Create query with changes
        for (i = 0; i<reqParams.length; i++) {
            if (reqParams[i][1] != undefined) {
                if (queryParams.length != 0) {
                    query = query + ",";
                }
                query = query + " " + reqParams[i][0] + "=$" + (queryParams.length + 1);
                queryParams.push(reqParams[i][1]);
            }
            // Last param
            if (i==reqParams.length-1) {
                query = query + " WHERE id=" + req.body.id;
            }
        }

        // Update Badulake's row
        if (queryParams.length > 0) {
            pg.connect(connectionString, function(err, client, done) {

                var handleError = function(err) {
                    if(!err) return false;

                    done(client);
                    res.status(500).json('An error occurred');
                    return true;
                };

                // SQL Query
                client.query(query, queryParams, function(err, result) {
                    // Handle Errors
                    if(handleError(err)) return;

                    // Return client to pool and send result
                    done();
                    res.status(201).json({"res" : "Changes: " + queryParams});
                });
            });
        } else {
            res.status(400).json({"res" : "No parameters to change."});
        }
    } else {
        res.status(400).json({"res" : "No id parameter to identify Badulake"});
    }
});

// Delete existent badulake
router.delete('/', function(req,res) {

    // Check if request has id
    if (req.body.id) {
        pg.connect(connectionString, function(err, client, done) {

            var handleError = function(err) {
                if(!err) return false;

                done(client);
                res.status(500).json('An error occurred');
                return true;
            };

            // SQL Query
            client.query("DELETE FROM badulakedb WHERE id=$1;", [req.body.id], function(err, result) {
                // Handle Errors
                if(handleError(err)) return;

                // Return client to pool and send result
                done();
                res.status(201).json({"res" : "Deleted badulake with id: " + req.body.id});
            });
        });
    } else {
        res.status(400).json({"res" : "No id parameter to identify Badulake"});
    }
});

module.exports = router;