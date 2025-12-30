#!/bin/bash
set -e

echo "=============================================="
echo " EX380 Q4 – GitOps MachineConfig VALIDATION"
echo "=============================================="

FAIL=0

pass() { echo "[PASS] $1"; }
fail() { echo "[FAIL] $1"; FAIL=1; }

echo
echo "[1] Checking OpenShift GitOps Operator namespace"
oc get ns openshift-gitops-operator &>/dev/null \
  && pass "openshift-gitops-operator namespace exists" \
  || fail "openshift-gitops-operator namespace missing"

echo
echo "[2] Checking ArgoCD instance"
oc get argocd -n openshift-gitops openshift-gitops &>/dev/null \
  && pass "ArgoCD instance exists" \
  || fail "ArgoCD instance missing"

echo
echo "[3] Checking ArgoCD Route TLS termination (reencrypt)"
TLS=$(oc get route openshift-gitops-server -n openshift-gitops -o jsonpath='{.spec.tls.termination}' 2>/dev/null || echo "")
[ "$TLS" = "reencrypt" ] \
  && pass "ArgoCD route uses reencrypt TLS" \
  || fail "ArgoCD TLS termination is NOT reencrypt"

echo
echo "[4] Checking gitops-admins group membership"
oc get group ocpadmins &>/dev/null \
  && pass "ocpadmins group exists" \
  || fail "ocpadmins group missing"

oc get group ocpadmins -o jsonpath='{.users}' | grep -q admin \
  && pass "admin is member of gitops-admins" \
  || fail "admin NOT in gitops-admins"

echo
echo "[5] Checking ArgoCD RBAC policy"
oc get cm argocd-rbac-cm -n openshift-gitops -o yaml | grep -q "ocpadmins" \
  && pass "ocpadmins configured in ArgoCD RBAC" \
  || fail "ocpadmins missing from ArgoCD RBAC"


echo

SYNC=$(oc get applications.argoproj.io machineconfig-motd-deploy -n openshift-gitops \
  -o jsonpath='{.spec.syncPolicy.automated}' 2>/dev/null || echo "")

[ -z "$SYNC" ] \
  && pass "Sync policy is MANUAL" \
  || fail "Sync policy is NOT manual"

echo
echo "[6] Checking MachineConfig objects"
oc get mc 71-master-sshd-motd &>/dev/null \
  && pass "Master MachineConfig exists" \
  || fail "71-master-sshd-motd missing"

oc get mc 71-worker-sshd-motd &>/dev/null \
  && pass "Worker MachineConfig exists" \
  || fail "71-worker-sshd-motd missing"

echo
echo "[7] Checking MachineConfig labels"
oc get mc 71-master-sshd-motd -o jsonpath='{.metadata.labels.machineconfiguration\.openshift\.io/role}' \
 | grep -q master \
  && pass "Master MC label correct" \
  || fail "Master MC label incorrect"

oc get mc 71-worker-sshd-motd -o jsonpath='{.metadata.labels.machineconfiguration\.openshift\.io/role}' \
 | grep -q worker \
  && pass "Worker MC label correct" \
  || fail "Worker MC label incorrect"

echo
echo "[8] Checking /etc/motd permissions on nodes"
for node in $(oc get nodes -o name); do
  MODE=$(oc debug $node -- chroot /host stat -c "%a" /etc/motd 2>/dev/null || echo "NA")
  [ "$MODE" = "444" ] \
    && pass "$node /etc/motd permission = 444" \
    || fail "$node /etc/motd permission NOT 444"
done

echo
echo "=============================================="
if [ $FAIL -eq 0 ]; then
  echo " ✅ Q4 VALIDATION PASSED"
else
  echo " ❌ Q4 VALIDATION FAILED"
fi
echo "=============================================="

exit $FAIL

