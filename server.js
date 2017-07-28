const express = require("express");
const path = require('path');
const bodyParser = require('body-parser');
const fs = require('fs');
const MongoClient = require('mongodb').MongoClient;
const stringToObject = require('mongodb').ObjectID
const mongoStoreFactory = require("connect-mongo");
const compression = require('compression');
const helmet = require('helmet');
const url = require('url');


var app = express();

app.use(helmet());  
//Compress here since we do not want to change the build tools. 
//This will use a bit more CPU as it needs to compress each request and response.
app.use(compression())
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: false }));
app.set("port", process.env.PORT || 3001);
console.log("Port: " + process.env.PORT + " mode:  " + process.env.NODE_ENV);


/**
    __ specifies to service worker to overlook cache and always look to server.
    Map __documentation to static files. Indes will be served first and every other file will be served with the
    url in src/href prepended with __documentation/frontend ... 
*/
app.use("/__documentation/frontend", express.static("client/documentation"));
/**
    Don't need to serve index.html about.html since specifying static files will be enough
*/
app.use("/", express.static("client/build"));



var accountsCollection = null; 
/**
    We don't need to specify index since this will be served automatically with static files. 
*/
MongoClient.connect("mongodb://db:27017", function(err, db) {
  if(!err) {
    console.log("We are connected");
    db.collection('accounts', function(err, collection) {
        if(!err){
            console.log("Accessed account collection");
            accountsCollection = collection

        }
    });
	app.listen(app.get("port"), () => {});

  }
});




