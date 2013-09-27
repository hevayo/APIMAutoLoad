#!/bin/bash

#  Copyright (c) 2005-2010, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
#
#  WSO2 Inc. licenses this file to you under the Apache License,
#  Version 2.0 (the "License"); you may not use this file except
#  in compliance with the License.
#  You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.


# jmeter instalation directory
JMETER_PATH='~/apache-jmeter-2.9/bin/jmeter -n '

# jmeter properties file you need to enable summariser
JMETER_PROPERTIES='jmeter.properties'

# Time for each test to execute
if [ -z "$1" ]; then
    TEST_EXECUTION_TIME=300
else
    TEST_EXECUTION_TIME=$1
fi

# Set this a higher value than the servers could handle 
# It is request per minute
DEFAULT_MAX_TPUT=600000

# Threads to execute
THREADS=(100 200 300 400 500 600 700 800 900)

# Sleep the server to stabilize after each test
# Better to put a value higher than connection time out or API Suspention
if [ -z "$2" ]; then
    SLEEP_TIME=40
else
    SLEEP_TIME=$2
fi

# this function will run a test with the given arguments
# run_test file_name threads throughput
function run_test(){
    echo "Running $1 "
    echo "@ Users : $2  TPS : $3  TEST : $1 " 
    COMMAND="$JMETER_PATH -t scripts/$1 -p $JMETER_PROPERTIES -Jusers=$2 -Jduration=$TEST_EXECUTION_TIME -Jtput=$3 > ~/tmp_results"
    eval $COMMAND
    tail -n 3 ~/tmp_results > ~/tail_tmp_results
    DATA= `head -n 1 ~/tail_tmp_results`
    echo $DATA
    echo "$DATA" |grep -P '\d+ (?=/s AVG)' -o
    echo "$DATA" |grep -P '\d+ (?= Min)' -o
    echo "";
    rm ~/tmp_results
    rm ~/tail_tmp_results
    sleep $SLEEP_TIME # need to sleep to stabilize the server
}

function run_test_suite(){
    echo "====== Starting $1 Test Suite ====="
    for td in ${THREADS[@]} 
    do
        run_test $1 $td $tp $DEFAULT_MAX_TPUT
    done
    echo ""
}


run_test_suite t1_direct_api_invocation.jmx 

