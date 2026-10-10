# Network Setup Guide for 3-Machine Lab

## Objective
Establish network connectivity between:
- Kali Attack: 192.168.56.10
- Ubuntu Target: 192.168.56.110
- Wazuh Server: 192.168.0.105

## Network Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                      HOST MACHINE                              │
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐  │
│  │           192.168.56.0/24 (Host-only Network 2)         │  │
│  │                                                         │  │
│  │  ┌──────────────────┐         ┌──────────────────────┐ │  │
│  │  │  Kali Attack     │◄───────►│  Ubuntu Target       │ │  │
│  │  │  192.168.56.10   │         │  192.168.56.110      │ │  │
│  │  │  (SSH port 22)   │         │  (SSH port 22)       │ │  │
│  │  └──────────────────┘         └──────────────────────┘ │  │
│  │           │                            │                 │  │
│  └───────────┼────────────────────────────┼─────────────────┘  │
│              │                            │                    │
│  ┌───────────┼────────────────────────────┼─────────────────┐  │
│  │           │                            │                 │  │
│  │  ┌────────▼──────────────────────────────────────────┐  │  │
│  │  │   192.168.0.0/24 (Bridge / LAN Network)          │  │  │
│  │  │                                                  │  │  │
│  │  │   ┌──────────────────────────────────────────┐  │  │  │
│  │  │   │  Wazuh Server (SIEM/SOAR)               │  │  │  │
│  │  │   │  192.168.0.105                          │  │  │  │
│  │  │   │  (Port 1514-1515 agent communication)  │  │  │  │
│  │  │   │  (Port 443 Dashboard)                  │  │  │  │
│  │  │   └──────────────────────────────────────────┘  │  │  │
│  │  └──────────────────────────────────────────────────┘  │  │
│  └─────────────────────────────────────────────────────────┘  │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

## Machine Configuration

### 1. Kali Attack Machine (192.168.56.10)
**Network Adapters:**
- Adapter 1: Host-only Network 2 → 192.168.56.10/24
- Adapter 2: NAT (optional for internet access)

**Verify connectivity:**
```bash
ip addr show | grep "192.168.56"
ping -c 2 192.168.56.110
ping -c 2 192.168.0.105
```

**SSH Service (for reverse validation):**
```bash
sudo systemctl status ssh
sudo systemctl start ssh
```

### 2. Ubuntu Target Machine (192.168.56.110)
**Network Adapters:**
- Adapter 1: Host-only Network 2 → 192.168.56.110/24
- Adapter 2: NAT (optional)

**Verify connectivity:**
```bash
ip addr show | grep "192.168.56"
ping -c 2 192.168.56.10
ping -c 2 192.168.0.105
```

**SSH Service:**
```bash
sudo systemctl status ssh
sudo systemctl start ssh
sudo systemctl enable ssh
```

**Firewall (if enabled, allow SSH):**
```bash
sudo ufw allow 22/tcp
```

### 3. Wazuh Server Machine (192.168.0.105)
**Network Adapters:**
- Adapter 1: Bridged / LAN Network → 192.168.0.105/24
- Adapter 2: NAT (optional)

**Verify connectivity:**
```bash
ip addr show | grep "192.168.0"
ping -c 2 192.168.56.10
ping -c 2 192.168.56.110
```

**Wazuh Services:**
```bash
sudo systemctl status wazuh-manager
sudo systemctl status wazuh-indexer
sudo systemctl status filebeat
```

## Network Connectivity Test

### From Kali (192.168.56.10):
```bash
# Test SSH to Ubuntu Target
ssh -v labuser@192.168.56.110

# Test connectivity to Wazuh Server
nmap -p 1514-1515,443,9200 192.168.0.105
```

### From Ubuntu Target (192.168.56.110):
```bash
# Test SSH connection from Kali
ssh -v labuser@192.168.56.10

# Test connectivity to Wazuh Server
nmap -p 1514-1515,443,9200 192.168.0.105
```

### From Wazuh Server (192.168.0.105):
```bash
# Test connectivity to both machines
ping -c 2 192.168.56.10
ping -c 2 192.168.56.110

# Verify Wazuh agent communication ports are open
sudo netstat -ln | grep "1514\|1515"
```

## SSH Configuration for Lab

On Ubuntu Target, ensure SSH is properly configured:

```bash
sudo nano /etc/ssh/sshd_config
```

Required settings for lab:
```
Port 22
PasswordAuthentication yes
PermitRootLogin yes
PermitEmptyPasswords no
X11Forwarding no
UsePAM yes
```

Restart SSH:
```bash
sudo systemctl restart ssh
```

## Lab User Accounts

### Ubuntu Target - Create test users:
```bash
# Main lab user
sudo useradd -m -s /bin/bash labuser
sudo echo 'labuser:LabPass123!' | sudo chpasswd

# Secondary users for password spraying tests
sudo useradd -m -s /bin/bash testuser1
sudo echo 'testuser1:Password1!' | sudo chpasswd

sudo useradd -m -s /bin/bash testuser2
sudo echo 'testuser2:Password2!' | sudo chpasswd

sudo useradd -m -s /bin/bash testuser3
sudo echo 'testuser3:Password3!' | sudo chpasswd
```

## Firewall Rules

On Ubuntu Target (if UFW is enabled):
```bash
# Allow SSH from Kali
sudo ufw allow from 192.168.56.10 to any port 22

# Allow Wazuh agent communication (from Wazuh server)
sudo ufw allow from 192.168.0.105 to any port 1514
sudo ufw allow from 192.168.0.105 to any port 1515
```

On Kali (if UFW is enabled):
```bash
# Allow SSH service
sudo ufw allow 22/tcp

# Allow outbound to Wazuh (if needed for agent)
sudo ufw allow out to 192.168.0.105 port 1514
sudo ufw allow out to 192.168.0.105 port 1515
```

## Troubleshooting

### Cannot ping between machines
1. Verify both are on the same network segment
2. Check `ip route` to ensure proper routing
3. Verify firewall rules on each machine

### SSH connection refused
1. Verify SSH service is running: `sudo systemctl status ssh`
2. Check SSH config: `sudo sshd -T`
3. Look at SSH logs: `sudo tail -f /var/log/auth.log`

### Wazuh agent cannot connect
1. Verify Wazuh server is running: `sudo systemctl status wazuh-manager`
2. Check firewall on Wazuh server allows 1514-1515
3. Verify agent has correct manager IP in `/var/ossec/etc/ossec.conf`
4. Check agent logs: `sudo tail -f /var/ossec/logs/ossec.log`

## Next Steps

Once network is verified:
1. Run `1-install-wazuh-agent.sh` on Ubuntu Target
2. Run `2-baseline-config.sh` on Ubuntu Target
3. Run `install-tools.sh` on Kali Attack
4. Deploy custom rules on Wazuh Server
5. Begin scenario testing
