#!/bin/bash

#
# Generates a inventory file based on the terraform output.
# After provisioning a cluster, simply run this command and supply the terraform state file
# Default state file is terraform.tfstate
#

set -e

TF_STATE_FILE=${1}

if [[ ! -f "${TF_STATE_FILE}" ]]; then
  echo "ERROR: state file ${TF_STATE_FILE} doesn't exist" >&2
  usage
fi

TF_OUT=$(terraform output -state "${TF_STATE_FILE}" -json)

DOMAIN=${2}
MASTERS=$(jq -r '.instance_group_masters_private_ips.value | to_entries[]'  <(echo "${TF_OUT}"))
MASTERS_COUNT=$(jq -r '.instance_group_masters_count.value'  <(echo "${TF_OUT}"))
WORKERS=$(jq -r '.instance_group_workers_private_ips.value | to_entries[]'  <(echo "${TF_OUT}"))
WORKERS_COUNT=$(jq -r '.instance_group_workers_count.value'  <(echo "${TF_OUT}"))
INGRESSES=$(jq -r '.instance_group_ingresses_private_ips.value | to_entries[]'  <(echo "${TF_OUT}"))
INGRESSES_COUNT=$(jq -r '.instance_group_ingresses_count.value'  <(echo "${TF_OUT}"))

echo "[all]"

# Generate master hosts
for ((i=1; i<=${MASTERS_COUNT}; i++)); do
  private_ip=$(jq -r '. | select( .key=='${i}-1' ) | .value'  <(echo "${MASTERS}"))
  echo "master-${i}.${DOMAIN} ansible_host=${private_ip} ip=${private_ip}"
done

# Generate worker hosts
for ((i=1; i<=${WORKERS_COUNT}; i++)); do
  private_ip=$(jq -r '. | select( .key=='${i}-1' ) | .value'  <(echo "${WORKERS}"))
  echo "node-${i}.${DOMAIN} ansible_host=${private_ip} ip=${private_ip}"
done

# Generate ingress hosts
for ((i=1; i<=${INGRESSES_COUNT}; i++)); do
  private_ip=$(jq -r '. | select( .key=='${i}-1' ) | .value'  <(echo "${INGRESSES}"))
  echo "ingress-${i}.${DOMAIN} ansible_host=${private_ip} ip=${private_ip}"
done

echo ""
echo "[kube_control_plane]"
for ((i=1; i<=${MASTERS_COUNT}; i++)); do
  echo "master-${i}.${DOMAIN}"
done

echo ""
echo "[etcd]"
for ((i=1; i<=${MASTERS_COUNT}; i++)); do
  echo "master-${i}.${DOMAIN}"
done

echo ""
echo "[kube_node]"
for ((i=1; i<=${WORKERS_COUNT}; i++)); do
  echo "node-${i}.${DOMAIN}"
done
for ((i=1; i<=${INGRESSES_COUNT}; i++)); do
  echo "ingress-${i}.${DOMAIN}"
done

echo ""
echo "[kube_ingress]"
for ((i=1; i<=${INGRESSES_COUNT}; i++)); do
  echo "ingress-${i}.${DOMAIN}"
done


echo ""
echo "[calico_rr]"


echo ""
echo "[k8s_cluster:children]"
echo "kube_node"
echo "kube_control_plane"
echo "kube_ingress"
echo "calico_rr"
