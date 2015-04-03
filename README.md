# replicatingperfection

## Project Description
Project contains cloud configuration to run a prebuilt netrunner Docker container in the cloud.  The netrunner code is taken from [jinteki.net](http://jinteki.net) and authored by mtgred.  A few minor modifications have been made to support remote mongodb and game servers.

## Running a server in the cloud

* Setup [Google Container Engine](https://cloud.google.com/container-engine/docs/hello-wordpress) account and cluster.
* Setup a Mongod instance. The [Mongo Lab](https://mongolab.com/) free tier should be sufficient
* Set the Mongod variables in frontend-controller.json flagged as <SET_*>
* Launch the game service
```
gcloud preview container kubectl create -f game-controller.json
gcloud preview container kubectl create -f game-service.json
```
* Launch the frontend service
```
gcloud preview container kubectl create -f frontend-controller.json
gcloud preview container kubectl create -f frontend-service.json
```
* Verify the services are running
```
gcloud preview container kubectl get rc
gcloud preview container kubectl get pods
gcloud preview container kubectl get services
```
* Look at the log message
```
gcloud preview container kubectl log game-controller-<pod_extension> game
gcloud preview container kubectl log frontend-controller-<pod_extension> jinteki
```
* Get the external ip (IP_ADDRESS) - it may take several minutes before it is fully setup
```
gcloud compute forwarding-rules list
```
* Wait 5 minutes, then visit http://<IP_ADDRESS>

