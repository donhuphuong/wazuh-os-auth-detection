#!/usr/bin/env bash
set -euo pipefail

echo "[*] Lab Network Connectivity Verification (Kali)"
echo "================================================="

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "\n[*] Checking local IP configuration:"
ip addr show | grep "192.168.56\|192.168.0" || echo "No matching IPs found"

echo -e "\n[*] Testing connectivity to Ubuntu Target (192.168.56.110):"
if ping -c 1 192.168.56.110 &> /dev/null; then
  echo -e "${GREEN}✓ Target reachable${NC}"
else
  echo -e "${RED}✗ Target unreachable${NC}"
fi

echo -e "\n[*] Testing connectivity to Wazuh Server (192.168.0.105):"
if ping -c 1 192.168.0.105 &> /dev/null; then
  echo -e "${GREEN}✓ Wazuh reachable${NC}"
else
  echo -e "${RED}✗ Wazuh unreachable${NC}"
fi

echo -e "\n[*] Testing SSH port on target (port 22):"
if nc -zv 192.168.56.110 22 &> /dev/null; then
  echo -e "${GREEN}✓ Target SSH port open${NC}"
else
  echo -e "${RED}✗ Target SSH port closed${NC}"
fi

echo -e "\n[*] Testing Wazuh ports (1514-1515, 443):"
for port in 1514 1515 443; do
  if nc -zv 192.168.0.105 $port &> /dev/null; then
    echo -e "${GREEN}✓ Wazuh port $port open${NC}"
  else
    echo -e "${RED}✗ Wazuh port $port closed${NC}"
  fi
done

echo -e "\n[*] Current routing table:"
ip route show | grep -E "192.168.56|192.168.0" || echo "No matching routes"

echo -e "\n[*] Verification complete."
