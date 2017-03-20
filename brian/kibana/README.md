# VANDA - Kibana Container

_This readme is only intended for being part of the VANDA Deap Learning Stack!_ 

Runs [Kibana 5.2.X](https://www.elastic.co/guide/en/kibana/5.2/index.html) from the official [docker.elastic.co/kibana/kibana](https://github.com/elastic/kibana-docker) docker image.

## Dockerfile

[`docker.elastic.co/kibana/kibana` Dockerfile](https://github.com/elastic/kibana-docker/blob/master/build/kibana/Dockerfile)

## How to use this image

Run a new container instance without

```
$ docker run -d -t -p 5601:5601 --name vanda-kibana_inst --link vanda-kibana_inst docker.elastic.co/kibana/kibana:5.2.1
```

or with an interactive bash session for inspecting the image.

```
$ docker run --rm -t -i -p 5601:5601 --name vanda-elasticsearch_inst docker.elastic.co/kibana/kibana:5.2.1 -- bash -l
```

```
$ docker ps
CONTAINER ID        IMAGE                                       COMMAND             CREATED                  STATUS              PORTS                                              NAMES
c8f421d459ce        docker.elastic.co/kibana/kibana:5.2.1       "kibana"            Less than a second ago   Up 2 minutes        0.0.0.0:5601->5601/tcp                             vanda-kibana_inst
```

Once the container is running you can open the web interface under the attached host port (i.e. [localhost:5601](http://localhost:5601))