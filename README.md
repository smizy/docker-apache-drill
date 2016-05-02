# docker-apache-drill

[![](https://imagelayers.io/badge/smizy/apache-drill:1.6-alpine.svg)](https://imagelayers.io/?images=smizy/apache-drill:1.6-alpine 'Get your own badge on imagelayers.io')

apache-drill docker image based on java:8-jre-alpine

## run drill server without zookeeper
```
docker run \
--name drill-1 \
-p 8047:8047 \
-e DRILL_HEAP=512M \
-e DRILL_MAX_DIRECT_MEMEORY=1G \
-d smizy/apache-drill:1.6-alpine 
```

## run drill client shell
```
docker exec -it drill-1 drill-conf
```

## run drill server with zookeeper (distributed mode)
```
# network
docker create netwrok vnet

# zookeeper
for i in 1 2 3; do docker run \
--name zookeeper-$i \
--net vnet \
-h zookeeper-$i.vnet \
-d smizy/zookeeper:3.4-alpine \
-server $i 3 \
;done 

# drill
docker run \
--net vnet \
-p 8047:8047 \
-e DRILL_HEAP=512M \
-e DRILL_MAX_DIRECT_MEMEORY=1G \
-e DRILL_ZOOKEEPER_QUORUM=zookeeper-1.vnet:2181,zookeeper-2.vnet:2181,zookeeper-3.vnet:2181 \
-d smizy/apache-drill:1.6-alpine 
```

# mustache.sh LICENSE
* mustache.sh is BSD-license. See LICENSE.mustache. Copyright 2011 Richard Crowley. All rights reserved. 