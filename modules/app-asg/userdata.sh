#!/bin/bash

ansible-pull -i localhost, -U https://github.com/DevOps-Iteration2/expense-ansible get-secrets.yml -e env=${env} -e role_name=${component} -e vault_token=${vault_token} &>>/opt/ansible.log
ansible-pull -i localhost, -U https://github.com/DevOps-Iteration2/expense-ansible expense.yml -e env=${env} -e role_name=${component} -e @~/secrets.json &>>/opt/ansible.log