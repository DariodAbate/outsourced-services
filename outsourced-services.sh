#!/bin/bash


VALID_SERVICES=("etcd" "scylla" "redpanda")

usage() {
    echo "Usage: $0 {deploy|start|stop} [service...]"
    echo "Manages the lifecycle of specified services."
    echo "If no services are specified, the action applies to all."
    echo "Available services: ${VALID_SERVICES[*]}"
    exit 1
}

if [ "$#" -lt 1 ]; then
    usage
fi

ACTION="$1"
shift 

PLAYBOOK=""
case "$ACTION" in
    deploy)
        PLAYBOOK="deploy-cluster.yml"
        ;;
    start)
        PLAYBOOK="start-cluster.yml"
        ;;
    stop)
        PLAYBOOK="stop-cluster.yml"
        ;;
    *)
        echo "Error: Invalid action '$ACTION'."
        usage
        ;;
esac

TAG_STRING=""
if [ "$#" -gt 0 ]; then
    for service in "$@"; do
        if ! [[ " ${VALID_SERVICES[*]} " =~ " ${service} " ]]; then
            echo "Error: Invalid service name '$service'."
            usage
        fi
    done
    TAG_STRING=$(IFS=,; echo "$*")
fi


CMD="ansible-playbook -i inventory.ini $PLAYBOOK"

if [ -n "$TAG_STRING" ]; then
    CMD="$CMD --tags \"$TAG_STRING\""
fi

echo "Executing: $CMD"

eval $CMD