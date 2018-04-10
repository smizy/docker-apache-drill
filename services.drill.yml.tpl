version: "2"

services:

## drillbit
  drillbit-${i}:
    container_name: drillbit-${i}
    networks: ["${network_name}"]
    hostname: drillbit-${i}.${network_name}
    image: sant/apache-drill:1.13.0-alpine
    ports: 
      - 8047
    depends_on: ["zookeeper-1"]  
    environment:
      - SERVICE_8047_NAME=drillbit
      - DRILL_HEAP=${drill_heap} 
      - DRILL_MAX_DIRECT_MEMORY=${drill_max_direct_memory}   
      - DRILL_ZOOKEEPER_QUORUM=${ZOOKEEPER_QUORUM}
      - S3_BUCKET=${s3_bucket}
      - S3_ROOT_LOCATION=${s3_root_location}
      - S3_ACCESS_KEY=${s3_access_key}
      - S3_SECRET_KEY=${s3_secret_key}
      - S3_CONNECTION_TIMEOUT=${s3_connection_timeout} 
      ${SWARM_FILTER_DRILLBIT_${i}}
##/ drillbit