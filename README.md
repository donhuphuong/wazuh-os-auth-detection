# Wazuh Detection Engineering - OS & Authentication Attacks

## 📋 Tổng Quan Đề Tài

Hệ thống giám sát an toàn thông tin SIEM/SOAR sử dụng **Wazuh** để phát hiện và phản ứng tự động với 5 kịch bản tấn công về **OS & Authentication** (Chương 11.1).

## 🎯 5 Kịch Bản Thực Nghiệm

1. **SSH Brute-force Attack** (T1110.001) - Tấn công vũ phu SSH
2. **SSH Password Spraying** (T1110.003) - Tấn công phun mật khẩu
3. **Account Manipulation** (T1098) - Sửa trái phép /etc/passwd
4. **Sudo Misconfiguration** (T1548.003) - Khai thác cấu hình sudoers
5. **SUID Bit Exploitation** (T1548.001) - Khai thác SUID để leo quyền

## 🏗️ Kiến Trúc Lab

```
┌─────────────────────────────────────────────────────────┐
│                   NETWORK TOPOLOGY                      │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  ┌──────────────────┐         ┌─────────────────────┐  │
│  │  Kali Attack     │         │   Wazuh Server      │  │
│  │  192.168.56.10   │         │   192.168.0.105     │  │
│  │  (Host-only + NAT)         │   (Bridge + NAT)    │  │
│  └────────┬─────────┘         └──────────┬──────────┘  │
│           │                              │             │
│           │ Host-only 2                  │ Bridge      │
│           │ (192.168.56.0/24)           │             │
│           │                              │             │
│  ┌────────┴──────────────────────────────┴──────────┐  │
│  │                                                  │  │
│  │         ┌──────────────────────┐                │  │
│  │         │  Ubuntu Target       │                │  │
│  │         │  192.168.56.110      │                │  │
│  │         │  (Host-only + NAT)   │                │  │
│  │         └──────────────────────┘                │  │
│  │                                                  │  │
│  └──────────────────────────────────────────────────┘  │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

## 📊 Cấu Hình Hệ Thống

| Máy | OS | IP | Adapter | Vai Trò |
|-----|----|----|---------|---------|
| **Kali Linux** | Kali 2024 | 192.168.56.10 | Host-only 2 + NAT | Attacker |
| **Wazuh Server** | Ubuntu/Centos | 192.168.0.105 | Bridge + NAT | SIEM/SOAR |
| **Ubuntu Target** | Ubuntu 26.04.1 | 192.168.56.110 | Host-only 1 + NAT | Victim |

## 📁 Cấu Trúc Thư Mục

```
wazuh-os-auth-detection/
├── README.md
├── docs/
│   ├── lab-setup.md
│   ├── chapter-11-1-overview.md
│   ├── mapping-chain-template.md
│   ├── baseline-configuration.md
│   └── forensics-guide.md
│
├── scripts/
│   ├── ubuntu-target/
│   │   ├── 1-install-wazuh-agent.sh
│   │   ├── 2-baseline-config.sh
│   │   ├── 3-fim-monitoring.sh
│   │   ├── 4-sca-check.sh
│   │   └── wazuh-agent-ossec.conf
│   │
│   ├── kali-attack/
│   │   ├── 1-ssh-bruteforce.sh
│   │   ├── 2-password-spraying.sh
│   │   ├── 3-passwd-manipulation.sh
│   │   ├── 4-sudo-escalation.sh
│   │   └── 5-suid-exploit.sh
│   │
│   ├── wazuh-server/
│   │   ├── custom-rules.xml
│   │   ├── custom-decoders.xml
│   │   └── active-response/
│   │       ├── block-bruteforce-ip.sh
│   │       └── alert-log-changes.sh
│   │
│   └── helpers/
│       ├── install-attack-tools.sh
│       └── network-test.sh
│
├── logs/
│   ├── sample-alerts/
│   │   ├── ssh-bruteforce-alerts.json
│   │   ├── account-manipulation-alerts.json
│   │   ├── privilege-escalation-alerts.json
│   │   └── ...
│   └── raw-telemetry/
│       └── (Chứa raw log từ thực nghiệm)
│
├── results/
│   ├── scenario-1-ssh-bruteforce/
│   ├── scenario-2-password-spraying/
│   ├── scenario-3-account-manipulation/
│   ├── scenario-4-sudo-escalation/
│   └── scenario-5-suid-exploitation/
│
└── docs-output/
    ├── detection-matrix.md
    ├── false-positive-analysis.md
    └── forensics-summary.md
```

## 🚀 Quick Start

### 1️⃣ Setup Ubuntu Target
```bash
ssh user@192.168.56.110

git clone https://github.com/donhuphuong/wazuh-os-auth-detection.git
cd wazuh-os-auth-detection

bash scripts/ubuntu-target/1-install-wazuh-agent.sh
bash scripts/ubuntu-target/2-baseline-config.sh
bash scripts/ubuntu-target/3-fim-monitoring.sh
bash scripts/ubuntu-target/4-sca-check.sh
```

### 2️⃣ Deploy Custom Rules trên Wazuh Server
```bash
ssh user@192.168.0.105
sudo cp custom-rules.xml /var/ossec/etc/rules/
sudo /var/ossec/bin/wazuh-control restart
```

### 3️⃣ Chạy 5 Kịch Bản Tấn Công
```bash
ssh root@192.168.56.10
bash /path/to/1-ssh-bruteforce.sh 192.168.56.110
bash /path/to/2-password-spraying.sh 192.168.56.110
```

## 📖 Tài Liệu Chi Tiết

- **Lab Setup Guide**
- **Chapter 11.1 Overview**
- **Mapping Chain Template**
- **Baseline Configuration**

## 🔍 Quá Trình Thực Nghiệm (6 Bước)

Mỗi kịch bản sẽ được thực hiện theo **Sườn 6 bước**:

1. **Mapping Chain**
2. **Baseline**
3. **Attack & Covering Tracks**
4. **Forensics Analysis**
5. **Wazuh Detection & Active Response**
6. **False Positive & Hardening**

## 📊 Kết Quả Mong Đợi

- ✅ Detection Rate cao cho 5 kịch bản
- ✅ False Positive thấp
- ✅ Response Time nhanh
- ✅ Forensics artifacts rõ ràng
- ✅ Custom Rules tối ưu

---

**Status:** 🟡 In Progress - Phase 1: Ubuntu Target Setup
