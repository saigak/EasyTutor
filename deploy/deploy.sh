#!/usr/bin/env bash
scp -i /home/saigak/.ssh/key.pem /home/saigak/EasyTutor/target/easytutor.war ec2-user@ec2-54-68-142-11.us-west-2.compute.amazonaws.com:/home/ec2-user/
ssh -i /home/saigak/.ssh/key.pem ec2-user@ec2-54-68-142-11.us-west-2.compute.amazonaws.com 'cd /home/ec2-user/glassfish4/glassfish/bin/; ./asadmin undeploy easytutor; ./asadmin deploy /home/ec2-user/easytutor.war;'