#!/usr/bin/env bash
set -euo pipefail

echo "[*] Lab Network Connectivity Verification"
echo "=========================================="

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "\n[*] Checking local IP configuration:"
ip addr show | grep "192.168.56\|192.168.0" || echo "No matching IPs found"

echo -e "\n[*] Testing connectivity to Kali Attack (192.168.56.10):"
if ping -c 1 192.168.56.10 &> /dev/null; then
  echo -e "${GREEN}✓ Kali reachable${NC}"
else
  echo -e "${RED}✗ Kali unreachable${NC}"
fi

echo -e "\n[*] Testing connectivity to Wazuh Server (192.168.0.105):"
if ping -c 1 192.168.0.105 &> /dev/null; then
  echo -e "${GREEN}✓ Wazuh reachable${NC}"
else
  echo -e "${RED}✗ Wazuh unreachable${NC}"
fi

echo -e "\n[*] Checking SSH service status:"
if sudo systemctl is-active ssh &> /dev/null; then
  echo -e "${GREEN}✓ SSH is running${NC}"
else
  echo -e "${RED}✗ SSH is not running${NC}"
fi

echo -e "\n[*] Current routing table:"
ip route show | grep -E "192.168.56|192.168.0" || echo "No matching routes"

echo -e "\n[*] SSH port listening check:"
if sudo netstat -ln | grep -q ":22 "; then
  echo -e "${GREEN}✓ SSH listening on port 22${NC}"
else
  echo -e "${RED}✗ SSH not listening on port 22${NC}"
fi

echo -e "\n[*] Verification complete."
