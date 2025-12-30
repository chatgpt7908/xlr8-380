#!/bin/bash

clear
echo "=============================================="
echo " EX380  EXAM – QUESTION 4"
echo " CLIENT CERTIFICATE (AUDIT ACCESS)"
echo "=============================================="
echo

echo "[*] Lab environment ready (no pre-lab command required)"
echo

cat <<'EOF'
Deploy the OpenShift GitOps operator according to the following requirements: 

The operator is installed in the openshift-gitops-operator project. 

The ArgoCD instance deployed by the operator has TLS enabled with reencrypt termination. 

The admin user is a member of the ocpadmins group. 

The ocpadmins group is the only group configured as role:admin with RBAC key policy. 

An ArgoCD instance Git repository exists at http://git.ocp4.example.com/ocp-gitops with skip server verification enabled. 

An application named machineconfig-motd-deploy exists in the Git repository with the Sync Policy configured as Manual. 

The Git repository http://git.ocp4.example.com/ocp-gitops.git contains two MachineConfig resources: 

71-master-sshd-motd.yaml 

Uses the latest Ignition version 
Path: /etc/motd 
Filesystem: root 
Overwrite: true 
Applied only on nodes with label machineconfiguration.openshift.io/role: master 

71-worker-sshd-motd.yaml 

Uses the latest Ignition version 

Path: /etc/motd 

Filesystem: root 

Overwrite: true 

Applied only on nodes with label machineconfiguration.openshift.io/role: worker 

In both MachineConfig resources: 

Set permissions on /etc/motd to r-- r-- r-- (0444) on all nodes 
EOF

echo
echo "----------------------------------------------"
echo " Start working on Question 4"
echo "----------------------------------------------"

