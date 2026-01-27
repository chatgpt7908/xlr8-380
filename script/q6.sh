#!/bin/bash

echo "📌 Setting up Question 5 environment..."

# 1. Switch to default project
oc project default >/dev/null 2>&1

# 2. Remove old deployment if exists
oc delete deployment super --ignore-not-found=true

# 3. Taint all worker nodes (break scheduling)
echo "⚠️  Tainting worker nodes to block scheduling..."
oc adm taint node $(oc get nodes -l node-role.kubernetes.io/worker \
  -o name | awk -F/ '{print $2}') goku=power:NoSchedule --overwrite

# 4. Create or switch to dbz project
oc new-project dbz >/dev/null 2>&1 || oc project dbz

# 5. Create deployment (INTENTIONALLY missing tolerations)
echo "🚀 Creating deployment with scheduling issue..."
oc create deployment super \
  --image=quay.io/redhattraining/hello-world-nginx:v1.0 \
  --replicas=3

# 6. Expose deployment as service
oc expose deployment super --port=8080

# 7. Create BROKEN route (wrong target service/port behavior)
echo "❌ Creating broken route..."
oc expose svc super --hostname=super.apps.ocp4.example.com

# 8. Show current broken state
echo
echo "🔍 Current state:"
oc get deployment super
oc get pods -o wide
oc get svc
oc get route

echo
echo "✅ Question 5 environment ready."
echo "Student must fix scheduling + routing issues."

