FROM java:8-jre-alpine
MAINTAINER smizy

ENV DRILL_VERSION           1.6.0
ENV DRILL_HOME              /usr/local/apache-drill-${DRILL_VERSION}
ENV DRILL_CONF_DIR          ${DRILL_HOME}/conf
ENV DRILL_STORAGE_CONF_DIR  ${DRILL_HOME}/storage.conf
ENV DRILL_LOG_DIR           /var/log/drill
ENV PATH                    $PATH:${DRILL_HOME}/bin
ENV DRILLBIT_LOG_PATH       ${DRILL_LOG_DIR}/drillbit.log
ENV DRILLBIT_LOG_OUT_PATH   ${DRILL_LOG_DIR}/drillbit.out
ENV DRILLBIT_QUERY_LOG_PATH ${DRILL_LOG_DIR}/drillbit_query.json
ENV DRILL_HEAP              4G
ENV DRILL_MAX_DIRECT_MEMORY 8G
ENV DRILL_CLUSTER_ID        drillbits1
ENV DRILL_ZOOKEEPER_QUORUM  localhost:2181

RUN set -x \
    && apk --no-cache add \
        bash \
        su-exec \ 
    && mirror_url=$( \
        wget -q -O - http://www.apache.org/dyn/closer.cgi/drill/ \
        | sed -n 's#.*href="\(http://ftp.[^"]*\)".*#\1#p' \
        | head -n 1 \
    ) \   
    && wget -q -O - ${mirror_url}/drill-${DRILL_VERSION}/apache-drill-${DRILL_VERSION}.tar.gz \
        | tar -xzf - -C /usr/local \
    ## user/dir/permmsion
    && adduser -D  -g '' -s /sbin/nologin -u 1000 docker \
    && adduser -D  -g '' -s /sbin/nologin drill \
    && mkdir -p \
        ${DRILL_LOG_DIR} \
        ${DRILL_STORAGE_CONF_DIR} \
    && chown -R drill:drill \
        ${DRILL_HOME} \
        ${DRILL_LOG_DIR} \
    && sed -i.bk 's/^\(DRILL\)/#\1/g' ${DRILL_CONF_DIR}/drill-env.sh 

COPY bin/*  /usr/local/bin/ 
COPY etc/*  ${DRILL_CONF_DIR}/
 
VOLUME ["${DRILL_LOG_DIR}", "${DRILL_STORAGE_CONF_DIR}"]

WORKDIR ${DRILL_HOME}

EXPOSE 8047

ENTRYPOINT ["entrypoint.sh"]
CMD ["drillbit" ]