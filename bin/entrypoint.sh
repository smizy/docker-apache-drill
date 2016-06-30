#!/bin/bash

set -eo pipefail

if [ "$1" == "drillbit" ]; then
    shift
    
    cat conf/drill-override.drillbit.conf.mustache | mustache.sh > conf/drill-override.conf
    
    echo "`date` Starting drillbit on `hostname`" 
    echo "`ulimit -a`"  2>&1
    
    exec su-exec drill bin/runbit drillbit "$@" start

fi

exec "$@"