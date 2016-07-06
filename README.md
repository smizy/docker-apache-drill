# docker-apache-drill

[![](https://imagelayers.io/badge/smizy/apache-drill:1.6-alpine.svg)](https://imagelayers.io/?images=smizy/apache-drill:1.6-alpine 'Get your own badge on imagelayers.io')

Apache Drill docker image based on alpine

## Usage
### Small setup 
```
# network
docker network create vnet

# generate docker-compose.yml (zookeeper:1, drill:1)
zookeeper=1 drillbit=1 ./make_docker_compose_yml.sh drill  > docker-compose.yml

# config test
docker-compose config

# load docker env as needed
eval $(docker-machine env default)

# run containers
docker-compose up -d

$ docker-compose ps
   Name                  Command               State              Ports             
-----------------------------------------------------------------------------------
drillbit-1    entrypoint.sh drillbit           Up      0.0.0.0:32773->8047/tcp       
zookeeper-1   entrypoint.sh -server 1 1 vnet   Up      2181/tcp, 2888/tcp, 3888/tcp

# run query from web ui (adjust drillbit exposed port)
open http://$(docker-machine ip default):32773/query
// Submit "SELECT * FROM cp.`employee.json` LIMIT 20" 

# run query from drill shell client
docker exec -it drillbit-1 drill-conf

0: jdbc:drill:> SELECT employee_id, full_name, position_id, position_title FROM cp.`employee.json` LIMIT 5;
+--------------+------------------+--------------+-------------------------+
| employee_id  |    full_name     | position_id  |     position_title      |
+--------------+------------------+--------------+-------------------------+
| 1            | Sheri Nowmer     | 1            | President               |
| 2            | Derrick Whelply  | 2            | VP Country Manager      |
| 4            | Michael Spence   | 2            | VP Country Manager      |
| 5            | Maya Gutierrez   | 2            | VP Country Manager      |
| 6            | Roberta Damstra  | 3            | VP Information Systems  |
+--------------+------------------+--------------+-------------------------+
5 rows selected (0.25 seconds)

# cleanup
docker-compose stop
docker-compose rm

```

### Setup with HDFS

```
# generate docker-compose.yml 
./make_docker_compose_yml.sh hdfs drill  > docker-compose.yml

# config test
docker-compose config

# run containers
docker-compose up -d

$ docker-compose ps
    Name                   Command               State                 Ports                
-------------------------------------------------------------------------------------------
datanode-1      entrypoint.sh datanode           Up      50010/tcp, 50020/tcp, 50075/tcp    
datanode-2      entrypoint.sh datanode           Up      50010/tcp, 50020/tcp, 50075/tcp    
datanode-3      entrypoint.sh datanode           Up      50010/tcp, 50020/tcp, 50075/tcp    
drillbit-1      entrypoint.sh drillbit           Up      0.0.0.0:32774->8047/tcp             
journalnode-1   entrypoint.sh journalnode        Up      8480/tcp, 8485/tcp                 
journalnode-2   entrypoint.sh journalnode        Up      8480/tcp, 8485/tcp                 
journalnode-3   entrypoint.sh journalnode        Up      8480/tcp, 8485/tcp                 
namenode-1      entrypoint.sh namenode-1         Up      0.0.0.0:32771->50070/tcp, 8020/tcp 
namenode-2      entrypoint.sh namenode-2         Up      0.0.0.0:32772->50070/tcp, 8020/tcp 
zookeeper-1     entrypoint.sh -server 1 3 vnet   Up      2181/tcp, 2888/tcp, 3888/tcp       
zookeeper-2     entrypoint.sh -server 2 3 vnet   Up      2181/tcp, 2888/tcp, 3888/tcp       
zookeeper-3     entrypoint.sh -server 3 3 vnet   Up      2181/tcp, 2888/tcp, 3888/tcp


# Query json data on hdfs 
docker exec -it -u hdfs datanode-1 bash

bash-4.3$ hdfs dfs -mkdir -p /user/hdfs/output
bash-4.3$ echo '{ a:1, b:2, c:3}' > /tmp/test.json
bash-4.3$ hdfs dfs -put /tmp/test.json /user/hdfs/output/

# update dfs storage setting (adjust drillbit exposed port)
open http://$(docker-machine ip default):32774/storage/dfs

{
  "type": "file",
  "enabled": true,
  "connection": "hdfs://namenode-1.vnet:8020/",
  "config": null,
  "workspaces": {
    "root": {
      "location": "/user/hdfs",
      "writable": false,
      "defaultInputFormat": null
    },
    "tmp": {
      "location": "/tmp",
      "writable": true,
      "defaultInputFormat": null
    }
  },
  :
  :
  
# run query from web ui
select * from dfs.root.`output/test.json`

```

* You can run multi-host distributed hdfs/drill cluster with overlay "vnet" network
(instead of bridge network) and swarm(v1.1) setup.
 

## mustache.sh LICENSE
* BSD License. See LICENSE.mustache.
* Source: https://github.com/rcrowley/mustache.sh
* Copyright 2011 Richard Crowley. All rights reserved.