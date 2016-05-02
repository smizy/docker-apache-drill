#!/bin/bash

set -eo pipefail

if [ "$1" == "drillbit" ]; then
    shift
    
    . mustache.sh
    cat conf/drill-override.drillbit.conf.mustache | mustache >  conf/drill-override.conf
    
    echo "`date` Starting drillbit on `hostname`" 
    echo "`ulimit -a`"  2>&1
    
    exec su-exec drill bin/runbit drillbit "$@"

fi

exec "$@"