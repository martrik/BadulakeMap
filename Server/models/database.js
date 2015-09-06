var pg = require('pg');
var connectionString = process.env.DATABASE_URL || 'postgres://localhost:5432/badulakedb';

var client = new pg.Client(connectionString);
client.connect();
var query = client.query('CREATE TABLE badulakedb (id SERIAL PRIMARY KEY, name text, longitude float, latitude float, alwaysopened BOOLEAN)');
query.on('end', function() { client.end(); });