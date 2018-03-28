#!/bin/bash

###
# // small setup 
# $ zookeeper=1 drillbit=1 ./make_docker_compose_yml.sh drill > docker-compose.yml
#
# // hdfs+hbase+drill setup 
# ./make_docker_compose_yml.sh hdfs hbase drill > docker-compose.yml
#
# ./make_docker_compose_yml.sh [hdfs] [hbase] [yarn] [drill]
###

DEBUG=${DEBUG:-0}

# docker network name
network_name=${network_name:-"vnet"}

# zookeeper scale size
zookeeper=${zookeeper:-3}

# hdfs scale size
journalnode=${journalnode:-3}
namenode=${namenode:-2}
datanode=${datanode:-3}

# yarn scale size
resourcemanager=${resourcemanager:-1}
historyserver=${historyserver:-1}
nodemanager=${nodemanager:-${datanode}}

# hbase scale size
hmaster=${hmaster:-2}
regionserver=${regionserver:-${datanode}}

# drill scale size
drillbit=${drillbit:-1}

# drill heap size
drill_heap=${drill_heap:-512M}

# drill max direct memory size
drill_max_direct_memory=${drill_max_direct_memory:-1G}

debug() {
  [ ${DEBUG} -gt 0 ] && echo "[DEBUG] $@" 1>&2
}
 
services=()

zk_quorum=()

for z in `seq ${zookeeper}`; do
    zk_quorum+=("zookeeper-$z.${network_name}:2181")
done
ZOOKEEPER_QUORUM="$(IFS=,; echo "${zk_quorum[*]}")"

zookeeper_arg=0
for component in $@; do 
    if [ "${component}" == "zookeeper" ]; then
        zookeeper_arg=1
        break
    fi
done   

if [ $zookeeper_arg -eq 0 ]; then
    set -- zookeeper $@
fi

for component in $@; do 
    template=services.${component}.yml.tpl
    if [ ! -e ${template} ]; then
        continue
    fi
    debug "Template: $template ..."
    
    service_keys=$(cat $template | sed -e '/^## /!d' | sed -e 's/^##[ ]*//g' )

    for k in $service_keys; do
        part=$(cat $template \
            | sed -e '/^## '${k}'/,/^##\/ '${k}'/!d' \
            | sed -e '/^##/d' \
        )  
        
        KK=$(echo $k | tr '[a-z]' '[A-Z]')

        debug $k $KK
        
        scale_size=${!k}
        debug $KK scale_size: $scale_size
        
        for i in `seq 1 ${scale_size}`; do 
            swarm_filter="SWARM_FILTER_${KK}_${i}" 
            debug $swarm_filter
            # replace template variable
            filter=""
            if [ "${!swarm_filter}" != "" ]; then
                filter="- ${!swarm_filter}"            
            fi
            _part=$(echo "$part" \
                | sed -e 's/${i}/'$i'/g' \
                      -e 's/${network_name}/'$network_name'/g'  \
                      -e 's/${scale_size}/'$scale_size'/g' \
                      -e 's/${ZOOKEEPER_QUORUM}/'$ZOOKEEPER_QUORUM'/g' \
                      -e 's/${drill_heap}/'$drill_heap'/g' \
                      -e 's/${drill_max_direct_memory}/'$drill_max_direct_memory'/g' \
                | sed -e 's/${'${swarm_filter}'}/'"${filter}"'/g' \
            )
            services+=("$_part" "")
        done
    done
done

# join 
docker_compose_services="$(IFS=$'\n'; echo "${services[*]}")"

# output docker-compose.yml v2 format
cat <<EOD
version: "2"
services:

$docker_compose_services

networks:
  $network_name:
    external:
      name: $network_name 
EOD

