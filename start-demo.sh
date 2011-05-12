#!/bin/bash

rm -rf 'in' out processing ruote-storage
#lib/demo_workflow.rb &
#echo $! > demo_workflow.pid
lib/demo_workflow.rb restart
lib/amqp_runners/amqp_file_type_service_runner.rb restart
sleep 5
cp -a test-items in/.
mv in/test-items in/test-items_ready

