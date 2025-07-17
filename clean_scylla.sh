#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

# --- Configuration ---
# List of your ScyllaDB nodes.
# Make sure you have passwordless SSH access to these nodes for the user running this script.
NODES=("node6" "node7" "node8")

# The SSH user for connecting to the nodes.
# --- End of Configuration ---

echo "Starting ScyllaDB cleanup process..."

for node in "${NODES[@]}"; do
  echo ""
  echo "-----------------------------------------------------"
  echo "Cleaning up node: $node"
  echo "-----------------------------------------------------"

  # Use ssh to execute the cleanup commands on the remote node.
  # The '-t' flag allocates a pseudo-tty, which is often required for running sudo commands.
  ssh -t ${node} '
    # Exit immediately if a command fails on the remote node
    set -e

    echo "--> Stopping ScyllaDB services (if they are running)..."
    # Use "|| true" to prevent the script from failing if the service is not found
    sudo systemctl stop scylla-server || true
    sudo systemctl stop scylla-node-exporter || true
    echo "Services stopped."

    echo "--> Purging the scylla package and its configuration..."
    # Purge removes the package and all its configuration files.
    # This is the key step to ensure a truly clean state.
    sudo apt-get purge -y scylla
    echo "Scylla package purged."

    echo "--> Cleaning up unused dependencies..."
    sudo apt-get autoremove -y
    echo "Dependencies cleaned."

    echo "--> Removing remaining ScyllaDB data directories..."
    # Purge might not remove directories in /var/lib, so we do it manually.
    sudo rm -rf /var/lib/scylla/*
    echo "Data directories removed."

    echo "Purge complete for node: '$node'"
  
  '
done

echo ""
echo "-----------------------------------------------------"
echo "All nodes have been cleaned."
echo "-----------------------------------------------------"
