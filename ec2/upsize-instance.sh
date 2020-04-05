#!/bin/bash
aws ec2 stop-instances --instance-ids i-00c1e0195543743f4

sleep 40

aws ec2 modify-instance-attribute --instance-id i-00c1e0195543743f4 --instance-type "{\"Value\": \"t2.small\"}"

sleep 5

aws ec2 start-instances --instance-ids i-00c1e0195543743f4

