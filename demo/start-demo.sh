#!/bin/bash

#Run from the top level of the project, not from the demo directory

rm -rf 'in' out processing
mkdir 'in' out processing

lib/demo/demo_workflow.rb restart
lib/demo/runners/amqp_file_type_service_runner.rb restart
sleep 5
cp -a test-items in/.
mv in/test-items in/test-items_ready
