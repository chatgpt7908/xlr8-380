#!/bin/bash

USER="kristendelgado"

echo "=============================================="
echo " EX380 – LDAP AUTH VALIDATION"
echo "=============================================="
echo

# Check if user exists in OpenShift
echo "[*] Checking if user '$USER' exists in OpenShift..."

if oc get user "$USER" &>/dev/null; then
    echo "[OK] User '$USER' exists in OpenShift."
else
    echo "[FAIL] User '$USER' does NOT exist in OpenShift."
    echo "       LDAP authentication may not be configured correctly."
    exit 1
fi

echo
echo "[*] Checking identity mapping..."

IDENTITY=$(oc get identity -o jsonpath="{.items[?(@.user.name=='$USER')].metadata.name}")

if [ -n "$IDENTITY" ]; then
    echo "[OK] Identity mapped for user '$USER'."
    echo "     Identity: $IDENTITY"
else
    echo "[FAIL] No identity mapping found for user '$USER'."
    exit 1
fi

echo
echo "[*] Validation successful."
echo " LDAP authentication appears to be working correctly."
echo "=============================================="

