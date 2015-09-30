#!/bin/bash


ssh-keygen -t rsa -b 4096 -C "keyforcoreos" -f ssh-keys/id_rsa_coreos -N ''
ssh-add ~/.ssh/id_rsa_coreos


#TODO add core* to .ssh/.config
