# Introduction

This is the backend for my [portfolio](https://github.com/mortonprod/welcome-page-react). 

# Setup 

You must install the frontend portfolio in the "client" directory.

It sends the pre-rendered routes to speed up the loading of the page. Routes served from the route "__*" bypasses the service worker. The server will compress the assets with every request.

The contact page is linked using nodemailer which sends an email to my contact email from another default email.

The node application is controlled by environmental variables set in the package.json. The standard robot.txt and sitemap is set as routes in node.

Currently "sendClient.sh" will send the client code to the write place on your server. 
*Not very versatile...*

# Building

You have to build the portfolio image. The steps:

* Get node image 
* Set environmental variables to link inside our node application
* Use expose to let the user of the image know what port to use.
* Build working directory.

Build using

```
npm run build
```

# Running

Create node image using 

```
npm run start
```

This will attach the projects code to work in the node environment you created.
A mongo db is started exposing it's default port and linking an external volume to the default
location mongodb reads and writes it's database. 


*Note the name of the database service in the docker file is reached from the node service through the service name.*

This will build the image and start everything, connect to [localhost](http://localhost:3000/)
to see it running. 


If you need to remove the old portfolio image

```
npm run delete:image
```


If you only want to stop the background processes to start a new one run:

```
npm run delete
```

**IMPORTANT: This command will kill ALL running docker processes.**

# Security 

To run node security project you will need to install it globally.
```
npm i nsp -g
```

Then run it

```
nsp check
``` 

# References

if you would like to learn more then you might want to read

[Docker Best Practices](https://github.com/nodejs/docker-node/blob/master/docs/BestPractices.md)


[Express Best Practices](https://expressjs.com/en/advanced/best-practice-security.html)

