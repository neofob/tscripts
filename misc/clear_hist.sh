#!/usr/bin/env bash

RHOSTS=${RHOSTS:-"openvpn"}

for h in ${RHOSTS}; do
	ssh $h "echo > .bash_history"
done
