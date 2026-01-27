#!/bin/bash

PASS=true
ROUTE_URL="http://super.apps.ocp4.example.com"

echo "🔎 Validating Question 5..."

# 1. Project check
if ! oc project dbz &>/dev/null; then
  echo "❌ Project dbz not accessible"
  PASS=false
else
  echo "✅ Project dbz exists"
fi

# 2. Deployment check
READY=$(oc get deploy super -n dbz -o jsonpath='{.status.readyReplicas}' 2>/dev/null)

if [[ "$READY" == "3" ]]; then
  echo "✅ Deployment super has 3 ready replicas"
else
  echo "❌ Deployment super not fully ready (ready=$READY)"
  PASS=false
fi

# 3. Pod status check
NOT_RUNNING=$(oc get pods -n dbz --no-headers | awk '$3!="Running"{print $1}')

if [[ -z "$NOT_RUNNING" ]]; then
  echo "✅ All pods are Running"
else
  echo "❌ Some pods are not running:"
  echo "$NOT_RUNNING"
  PASS=false
fi

# 4. Service check
if oc get svc super -n dbz &>/dev/null; then
  echo "✅ Service super exists"
else
  echo "❌ Service super missing"
  PASS=false
fi

# 5. Route check
if oc get route super -n dbz &>/dev/null; then
  echo "✅ Route super exists"
else
  echo "❌ Route super missing"
  PASS=false
fi

# 6. Route accessibility check
echo "🌐 Checking route accessibility..."

HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "$ROUTE_URL")

if [[ "$HTTP_CODE" == "200" ]]; then
  echo "✅ Route is accessible (HTTP 200)"
else
  echo "❌ Route not accessible (HTTP $HTTP_CODE)"
  PASS=false
fi

# FINAL RESULT
echo
echo "=============================="
if [[ "$PASS" == "true" ]]; then
  echo "🎉 RESULT: ROUTES OK ✅"
else
  echo "❌ RESULT: VALIDATION FAILED"
fi
echo "=============================="

