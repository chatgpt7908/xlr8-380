#!/bin/bash
set -e

echo "🚀 Starting logging-forward lab environment..."
echo

############################################
# 1. START LAB (utility syslog ready)
############################################
lab start logging-forward

echo
echo "⏳ Waiting for environment to stabilize..."
sleep 10


############################################
# 2. PRINT QUESTION (STUDENT VIEW)
############################################
echo "📘 QUESTION 5"
echo "=============================================="
echo
cat <<'EOF'
Configure OpenShift Logging in the cluster to forward logs to an external
syslog server according to the following requirements:

External syslog server:
  utility.lab.example.com

Syslog service:
  - TCP port 514

Log collector:
  - Vector

Logs to be forwarded:
  - Kubernetes API audit logs
  - Kubernetes events
  - CoreOS journal logs
  - CoreOS audit logs
  - Infrastructure container logs
  - Application container logs with label: logging=critical

Syslog tagging requirements:
  - Application logs: msgID = apps, procID = vector
  - Infrastructure logs: msgID = infra, procID = vector
  - Audit logs: msgID = audit, procID = vector
  - facility: user

Additional requirements:
  - Use the OpenShift Logging operator
  - Deploy the Event Router to capture Kubernetes events
  - Do NOT modify the syslog server configuration

Images for Eventts:
registry.ocp4.example.com:8443/openshift-logging/eventrouter-rhel9:v0.4

Verification:
  - Logs must be available on the syslog server under:
    /var/log/openshift/

EOF

echo
echo "=============================================="
echo "✅ Environment READY. Solve Question 6."
echo "=============================================="

