# VANDA - Elasticsearch Container

_This readme is only intended for being part of the VANDA Deap Learning Stack!_ 
Runs [Elasticsearch 5.2.X](https://www.elastic.co/guide/en/elasticsearch/reference/5.2/index.html) from the official [docker.elastic.co/elasticsearch/elasticsearch](https://github.com/elastic/elasticsearch-docker) docker image.

## Dockerfile

[`docker.elastic.co/elasticsearch/elasticsearch` Dockerfile](https://github.com/elastic/elasticsearch-docker/blob/master/build/elasticsearch/Dockerfile)


## How to use this image

Run a new container instance without

```
$ docker run -d -t -p 9200 -p 9300 --name vanda-elasticsearch_inst docker.elastic.co/elasticsearch/elasticsearch:5.2.1
```

or with an interactive bash session for inspecting the image.

```
$ docker run --rm -t -i -p 9200 -p 9300 --name vanda-elasticsearch_inst docker.elastic.co/elasticsearch/elasticsearch:5.2.1 --bash -l
```

```
$ docker ps
CONTAINER ID        IMAGE                                                   COMMAND             CREATED                  STATUS              PORTS                                              NAMES
e46a689d75a8        docker.elastic.co/elasticsearch/elasticsearch:5.2.1     "elasticsearch"     Less than a second ago   Up 11 seconds       0.0.0.0:32780->9200/tcp, 0.0.0.0:32779->9300/tcp   vanda-elasticsearch_inst
```

Once the container is running you can open the web interface under the attached host port (i.e. [localhost:32780](http://localhost:32780))

## Import/export data over elasticsearch snapshots and shared drives

First you must activate your drive as shared drive in the Docker Engine. 

Now you can mount the Docker container with:
```
$ docker run -d -t -p 9200 -p 9300 --name vanda-elasticsearch_inst -v /path/to/local/elasticsearch/data:/backup_elasticsearch docker.elastic.co/elasticsearch/elasticsearch:5.2.1
```

All following instructions are from [Elasticsearch References](https://www.elastic.co/guide/en/elasticsearch/reference/current/modules-snapshots.html)
Now you must configure the Shared File System Repository in Elasticsearch:
```
$ docker exec e46a689d75a8 curl --user elastic:changeme -XPUT 'http://elasticsearch:9200/_snapshot/backup_elasticsearch' -d'
{
    "type": "fs",
    "settings": {
        "location": "/backup_elasticsearch",
        "compress": true
    }
}'
```

Create a Snapshot with:
```
$ docker exec e46a689d75a8 curl --user elastic:changeme -XPUT 'http://elasticsearch:9200/_snapshot/backup_elasticsearch/vanda_articles?wait_for_completion=true' -d '
{
  "indices": "vanda_articles",
  "ignore_unavailable": true,
  "include_global_state": false
}'
```

And restore Snapshot with:
```
$ docker exec e46a689d75a8 curl --user elastic:changeme -XPOST http://elasticsearch:9200/_snapshot/backup_elasticsearch/vanda_articles/_restore
```


## Clustering

For a Elasticsearch cluster use a [Docker composer configuration](https://www.elastic.co/guide/en/elasticsearch/reference/current/docker.html).
