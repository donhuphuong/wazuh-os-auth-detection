#!/usr/bin/env bash
set -euo pipefail

echo "[*] Lab Network Connectivity Verification (Wazuh Server)"
echo "========================================================="

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "\n[*] Checking local IP configuration:"
ip addr show | grep "192.168.0" || echo "No matching IP found"

echo -e "\n[*] Testing connectivity to Kali Attack (192.168.56.10):"
if ping -c 1 192.168.56.10 &> /dev/null; then
  echo -e "${GREEN}✓ Kali reachable${NC}"
else
  echo -e "${RED}✗ Kali unreachable${NC}"
fi

echo -e "\n[*] Testing connectivity to Ubuntu Target (192.168.56.110):"
if ping -c 1 192.168.56.110 &> /dev/null; then
  echo -e "${GREEN}✓ Target reachable${NC}"
else
  echo -e "${RED}✗ Target unreachable${NC}"
fi

echo -e "\n[*] Checking Wazuh services:"
for service in wazuh-manager wazuh-indexer filebeat; do
  if sudo systemctl is-active $service &> /dev/null; then
    echo -e "${GREEN}✓ $service is running${NC}"
  else
    echo -e "${RED}✗ $service is not running${NC}"
  fi
done

echo -e "\n[*] Checking Wazuh listening ports:"
for port in 1514 1515 443 9200; do
  if sudo netstat -ln | grep -q ":$port "; then
    echo -e "${GREEN}✓ Port $port listening${NC}"
  else
    echo -e "${RED}✗ Port $port not listening${NC}"
  fi
done

echo -e "\n[*] Verification complete."
