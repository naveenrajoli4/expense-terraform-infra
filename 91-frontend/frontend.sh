#!/bin/bash

dnf install ansible -y

ansible-pull -i localhost, -U https://github.com/naveenrajoli4/ansible-roles-tf.git main.yaml -e COMPONENT=frontend -e ENVIRONMENT=$1