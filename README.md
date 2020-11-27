# Introduction to Spring Cloud Dataflow: Steaming apps and Bitnami Charts

You can see the slides [here](https://drive.google.com/file/d/1kU2MA0GrQY6PYZX4NDs3_Hu7lMI020nD/view?usp=sharing)
The recording of the talk [here](https://www.twitch.tv/videos/817214034), start at 1h 15min

## Requirements

- Kubernetes cluster using: [Minikube](https://minikube.sigs.k8s.io/docs/), [Docker Desktop](https://www.docker.com/products/docker-desktop) or any cloud provider.
- Helm [command line ](https://helm.sh/docs/)

## Installing charts

Install Bitnami charts repository

```console
$ helm repo add bitnami https://charts.bitnami.com/bitnami
```

### Install monitoring tools

```console
$ ./scripts/deploy-monitoring.sh
```

### Install dataflow

```console
$ ./scripts/deploy-dataflow.sh
```

### Install applications database

```console
$ ./scripts/deploy-mongodb.sh
```


## Stream DSLs

```
composed-data=trigger --payload="{ \"data\": { \"temperature\": 12 } }" --cron="*/1 * * * * *" | break-down: transform --expression=#jsonPath(payload,'$.data') > :sources
main=:sources > log
simple-data=trigger --payload="{ \"temperature\": 10 }" --cron="*/5 * * * * *" > :sources
```

### Get mongodb password

```console
$ k get secrets mongodb -o=jsonpath='{.data.mongodb-password}' | base64 --decode
```

```
composed-data=trigger --payload="{ \"data\": { \"temperature\": 12 } }" --cron="*/1 * * * * *" | break-down: transform --expression=#jsonPath(payload,'$.data') > :sources
main=:sources > mongodb --authentication-database=innosoft-demo --username=innosoft-demo-user --database=innosoft-demo --password=rDWuDtGG7b --port=27017 --host=mongodb.default.svc.cluster.local --collection=measures
simple-data=trigger --payload="{ \"temperature\": 10 }" --cron="*/5 * * * * *" > :sources
```

```
composed-data=trigger --payload="{ \"data\": { \"temperature\": 12 } }" --cron="*/1 * * * * *" | break-down: transform --expression=#jsonPath(payload,'$.data') > :sources
main=:sources > mongodb --authentication-database=innosoft-demo --username=innosoft-demo-user --database=innosoft-demo --password=rDWuDtGG7b --port=27017 --host=mongodb.default.svc.cluster.local --collection=measures
simple-data=trigger --payload="{ \"temperature\": 10 }" --cron="*/5 * * * * *" > :sources
expose-data=mongodb --authentication-database=innosoft-demo --username=innosoft-demo-user --database=innosoft-demo --password=rDWuDtGG7b --port=27017 --host=mongodb.default.svc.cluster.local --collection=measures | websocket
```

```
source-raw=trigger --payload="{ \"data\": { \"temperature\": 12 } }" --cron="*/1 * * * * *" | data-to-temperature: transform --expression=#jsonPath(payload,'$.data') > :sources
main=:sources > mongodb --authentication-database=innosoft-demo --username=innosoft-demo-user --database=innosoft-demo --password=rDWuDtGG7b --port=27017 --host=mongodb.default.svc.cluster.local --collection=measures
expose=:sources > websocket
source-json=trigger --payload="{ \"temperature\": 10 }" --cron="*/5 * * * * *" > :sources
```

### Forward port for websocket

```console
$ k port-forward pod/expose-data-websocket-v1-6b6b56d45f-skkfr 8888:9292
```
