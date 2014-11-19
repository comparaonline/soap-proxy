Simple SOAP Proxy
=================

The proxy will show you all communication with the proxied webservice.
It only supports HTTP.

## Instructions to run it on localhost

* Clone the repo in your machine.
* Install dependencies: ```$ npm install```
* Run the server ./index.js
  * If needed you can change the ports using the appropriate flags, check ```$ ./index.js --help```

## Instructions to run it as a Vagrant box

* Clone the repo in your machine
* Run ```$ vagrant up``` on the cloned folder
* Access the vagrant box (```$ vagrant ssh``` on the cloned folder)
* Go to `/vagrant`
* Run ```$ npm install```
* Run the server ./index.js
  * If needed you can change the ports using the appropriate flags, check ```$ ./index.js --help```

## Instructions to use it

* In the machine that is doing the request, modify the /etc/hosts to point to the soap-proxy's IP
  * If the request is done by your machine, make sure you run it in a Vagrant box
* Access the webui (default port: 8000)
