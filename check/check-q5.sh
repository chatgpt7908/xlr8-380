#!/bin/bash

echo "🔍 VALIDATION: Question 6 - OpenShift Logging + Syslog"
echo "===================================================="

fail() {
  echo "❌ $1"
  exit 1
}

pass() {
  echo "✅ $1"
}

# -------------------------------
# OpenShift side validation
# -------------------------------

echo "➡️ Checking OpenShift configuration..."

oc get clusterlogging instance -n openshift-logging &>/dev/null \
  || fail "ClusterLogging instance not found"

COLLECTOR=$(oc get clusterlogging instance -n openshift-logging \
  -o jsonpath='{.spec.collection.type}')

[ "$COLLECTOR" = "vector" ] \
  && pass "Vector log collector configured" \
  || fail "Vector collector NOT configured"

oc get clusterlogforwarder instance -n openshift-logging &>/dev/null \
  && pass "ClusterLogForwarder exists" \
  || fail "ClusterLogForwarder missing"

oc get deployment eventrouter -n openshift-logging &>/dev/null \
  && pass "Event Router deployed" \
  || fail "Event Router not found"

oc get daemonset collector -n openshift-logging &>/dev/null \
  && pass "Collector daemonset present" \
  || fail "Collector daemonset missing"

# -------------------------------
# Syslog server validation
# -------------------------------

echo
echo "➡️ Checking logs on syslog server (utility)..."

ssh lab@utility <<'EOF'
set -e

cd /var/log/openshift || exit 2

[ -f apps.log ]  || exit 10
[ -f infra.log ] || exit 11
[ -f audit.log ] || exit 12

[ -s apps.log ]  || exit 20
[ -s infra.log ] || exit 21
[ -s audit.log ] || exit 22
EOF

case $? in
  0)  pass "apps.log, infra.log, audit.log exist and contain logs" ;;
  10) fail "apps.log not found on syslog server" ;;
  11) fail "infra.log not found on syslog server" ;;
  12) fail "audit.log not found on syslog server" ;;
  20) fail "apps.log is empty" ;;
  21) fail "infra.log is empty" ;;
  22) fail "audit.log is empty" ;;
  *)  fail "Unable to verify logs on syslog server" ;;
esac

echo "===================================================="
echo "🎉 VALIDATION PASSED: Logging + Syslog forwarding OK"
echo "===================================================="

