const express = require("express");
const path = require('path');
const bodyParser = require('body-parser');
const fs = require('fs');
const MongoClient = require('mongodb').MongoClient;
const stringToObject = require('mongodb').ObjectID
const mongoStoreFactory = require("connect-mongo");
const compression = require('compression')


var app = express();
//Compress here since we do not want to change the build tools. 
//This will use a bit more CPU as it needs to compress each request and response.
app.use(compression())
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: false }));
app.set("port", process.env.PORT || 3001);
console.log("Port: " + process.env.PORT + " mode:  " + process.env.NODE_ENV);
app.use(express.static("client/build"));

var accountsCollection = null; 
//Hostname(db) comes from service name provide in docker.compose.
MongoClient.connect("mongodb://db:27017", function(err, db) {
  if(!err) {
    console.log("We are connected");
    db.collection('accounts', function(err, collection) {
        if(!err){
            console.log("Accessed account collection");
            accountsCollection = collection

        }
    });
	app.get('/', function (req, res) {
	    res.sendFile(path.join(__dirname+'/client/build/index.html'));
	});
	app.get('/about', function (req, res) {
	    res.sendFile(path.join(__dirname+'/client/build/about.html'));
	});
	app.get('/services', function (req, res) {
	    res.sendFile(path.join(__dirname+'/client/build/services.html'));
	});
	app.get('/work', function (req, res) {
	    res.sendFile(path.join(__dirname+'/client/build/work.html'));
	});
	app.get('/skills', function (req, res) {
	    res.sendFile(path.join(__dirname+'/client/build/skills.html'));
	});

	app.listen(app.get("port"), () => {});

  }
});




