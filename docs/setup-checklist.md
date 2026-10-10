# Lab Setup Checklist

## Phase 1: Network Verification

### On Ubuntu Target (192.168.56.110)
- [ ] Machine has static IP 192.168.56.110 on Host-only Network
- [ ] Can ping 192.168.56.10 (Kali Attack)
- [ ] Can ping 192.168.0.105 (Wazuh Server)
- [ ] SSH service running and listening on port 22
- [ ] Firewall allows SSH connections

**Run verification:**
```bash
cd /path/to/wazuh-os-auth-detection
bash scripts/ubuntu-target/0-verify-network.sh
```

### On Kali Attack (192.168.56.10)
- [ ] Machine has static IP 192.168.56.10 on Host-only Network
- [ ] Can ping 192.168.56.110 (Ubuntu Target)
- [ ] Can ping 192.168.0.105 (Wazuh Server)
- [ ] SSH service installed and running (for reverse shell tests)
- [ ] netcat/nc installed

**Run verification:**
```bash
cd /path/to/wazuh-os-auth-detection
bash scripts/kali-attack/0-verify-network.sh
```

### On Wazuh Server (192.168.0.105)
- [ ] Machine has static IP 192.168.0.105 on Bridged/LAN Network
- [ ] Can ping 192.168.56.10 (Kali Attack)
- [ ] Can ping 192.168.56.110 (Ubuntu Target)
- [ ] Wazuh Manager running and listening on ports 1514-1515
- [ ] Wazuh Indexer running on port 9200
- [ ] Firewall allows agent connections (1514-1515)

**Run verification:**
```bash
cd /path/to/wazuh-os-auth-detection
bash scripts/wazuh-server/0-verify-network.sh
```

## Phase 2: Ubuntu Target Setup

### Baseline Configuration
- [ ] SSH service configured with password authentication enabled
- [ ] Test user `labuser` created with password
- [ ] Secondary users created (testuser1, testuser2, testuser3)
- [ ] Sudoers file in default restrictive state
- [ ] /etc/passwd and /etc/sudoers permissions correct
- [ ] System logs available in /var/log/auth.log

**Run setup:**
```bash
sudo bash scripts/ubuntu-target/2-baseline-config.sh
```

### FIM & Monitoring Configuration
- [ ] Wazuh Agent installed from repository
- [ ] Agent registered with Wazuh Manager (192.168.0.105)
- [ ] Agent service running and auto-enabled

**Run installation:**
```bash
sudo bash scripts/ubuntu-target/1-install-wazuh-agent.sh
```

### FIM Policy Configuration
- [ ] FIM configured to monitor /etc directory
- [ ] FIM configured to monitor /etc/sudoers.d
- [ ] FIM configured to monitor /var/spool/cron
- [ ] FIM configured to monitor /home directory
- [ ] Real-time monitoring enabled
- [ ] Wazuh Agent restarted

**Run configuration:**
```bash
sudo bash scripts/ubuntu-target/3-fim-monitoring.sh
```

### Verify Ubuntu Target Setup
```bash
# Verify Wazuh Agent is connected
sudo systemctl status wazuh-agent

# Check agent communication logs
sudo tail -20 /var/ossec/logs/ossec.log

# Verify auth.log is being collected
ls -la /var/log/auth.log
```

## Phase 3: Kali Attack Setup

### Install Attack Tools
- [ ] hydra installed for brute-force
- [ ] nmap installed for port scanning
- [ ] curl installed for HTTP testing
- [ ] hping3 installed for DoS testing
- [ ] jq installed for JSON processing
- [ ] openssh-client for SSH operations

**Run installation:**
```bash
sudo bash scripts/kali-attack/install-tools.sh
```

### Verify Tools
```bash
which hydra nmap curl hping3 jq ssh nc
hydra -h | head
nmap --version
```

## Phase 4: Wazuh Server Setup

### Verify Manager Connection
- [ ] Check manager status
- [ ] Verify agent registration in manager
- [ ] Check manager is accepting connections on 1514-1515

**Commands:**
```bash
sudo /var/ossec/bin/wazuh-control status
sudo /var/ossec/bin/wazuh-control info wazuh
```

### Deploy Custom Rules
- [ ] Backup original rules directory
- [ ] Copy custom-rules.xml to /var/ossec/etc/rules/
- [ ] Verify rule syntax
- [ ] Restart Wazuh Manager

**Commands:**
```bash
sudo cp scripts/wazuh-server/custom-rules.xml /var/ossec/etc/rules/
sudo /var/ossec/bin/wazuh-control restart
```

### Verify Rules Loaded
```bash
sudo grep -r "os-auth-detection" /var/ossec/etc/rules/
```

## Phase 5: Final Integration Test

### From Kali, attempt SSH to Ubuntu Target
```bash
# Should succeed with correct credentials
ssh labuser@192.168.56.110

# Should fail and be logged
ssh nonexistent@192.168.56.110
```

### Check Wazuh Dashboard
1. Open browser to https://192.168.0.105:443
2. Login with Wazuh credentials
3. Verify Ubuntu Target is listed as connected agent
4. Check alerts for SSH connection attempts

### Verify Logs Flow
```bash
# On Ubuntu Target
sudo tail -20 /var/log/auth.log

# On Wazuh Server - check if agent is sending logs
sudo tail -50 /var/ossec/logs/alerts/alerts.json | jq '.'
```

## Ready for Scenario Testing

Once all checkpoints are complete:
- [ ] All Phase 1-5 items checked
- [ ] Network connectivity verified
- [ ] Wazuh Agent connected and sending logs
- [ ] Custom rules deployed
- [ ] Dashboard showing agent activity

**Proceed to:**
- Scenario 1: SSH Brute-force Attack
- Scenario 2: SSH Password Spraying
- Scenario 3: Account Manipulation
- Scenario 4: Sudo Misconfiguration
- Scenario 5: SUID Exploitation
