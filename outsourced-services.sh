#!/bin/bash

usage() {
    echo "Usage: $0 {deploy|start|stop}"
    exit 1
}

if [ $# -ne 1 ]; then
    usage
fi

case "$1" in
    deploy)
        ansible-playbook -i inventory.ini deploy.yml
        ;;
    start)
        ansible-playbook -i inventory.ini start-cluster.yml
        ;;
    stop)
        ansible-playbook -i inventory.ini stop-cluster.yml
        ;;
    *)
        usage
        ;;
esac