#!/bin/bash

#PID=`cat demo_workflow.pid`
#kill $PID
#rm demo_workflow.pid
lib/demo_workflow.rb stop
lib/amqp_runners/amqp_file_type_service_runner.rb stop
