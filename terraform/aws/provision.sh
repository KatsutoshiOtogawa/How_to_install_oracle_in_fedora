#!/bin/bash

dnf install -y https://s3.region.amazonaws.com/amazon-ssm-region/latest/linux_amd64/amazon-ssm-agent.rpm

systemctl status amazon-ssm-agent

systemctl enable amazon-ssm-agent

systemctl start amazon-ssm-agent