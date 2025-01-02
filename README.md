#  Threat Hunting & Automated Incident Response Lab

This repository serves as a practical demonstration of advanced Threat Hunting, SIEM detection engineering, and Automated Incident Response (Active Response). 

As highlighted in my professional portfolio:
> *"Architected a SIEM/EDR environment to detect multi-stage Defense Evasion campaigns (MITRE T1564), specifically targeting hidden files, registry-based hidden users, and rogue VirtualBox VMs. Executed advanced simulations using Atomic Red Team and MSFVENOM, mapping LOLBin execution chains and File/Registry Integrity Monitoring (FIM) events to custom detection rules. Engineered PowerShell and Python Active Response scripts triggered by SIEM alerts to automate threat containment, dynamically restoring registry ACL ownership, and extracting forensic data."*

##  Repository Structure

```text
SOC-Active-Response-Lab/
├── Active-Response-Scripts/
│   ├── Respond_T1564_001.ps1         # Automated containment for hidden files
│   ├── Respond_T1564_002.ps1         # Registry ACL restoration & user visibility script
│   └── Respond_T1564_002.py          # Python alternative for handling T1564.002 alerts
├── Attack-Simulations/
│   ├── T1564.001-HiddenFiles-Simulation.ps1  # Execution and Sysmon Threat Hunting
│   ├── T1564.002-HiddenUsers-Simulation.ps1  # Registry manipulation simulation
│   ├── T1564.006-2-Create.ps1                # Rogue VM creation and execution playbook
│   └── T1564.006-2-Cleanup.ps1               # Environment cleanup and VM deletion
├── Detection-Rules/
│   ├── T1564_Custom_Rules.xml        # Custom Wazuh rules mapping to MITRE ATT&CK
│   └── Wazuh_FIM_Registry_Config.xml # Syscheck configuration for File/Registry integrity
└── Incident-Reports/
    ├── T1564001.pdf                  # Incident Analysis: Hide Artifacts - Hidden Files
    ├── T1564002.pdf                  # Incident Analysis: Hidden Users & Registry Manipulation
    └── T1564006-2.pdf                # Incident Analysis: Rogue VirtualBox VM Creation

```

##  MITRE ATT&CK Coverage (Defense Evasion - T1564)

* **T1564.001: Hidden Files and Directories**
* **Simulation:** Using `attrib.exe` to hide payloads.
* **Detection:** Wazuh Syscheck (FIM) and Sysmon Event IDs (1, 11, 15).


* **T1564.002: Hidden Users**
* **Simulation:** Manipulating `SpecialAccounts\UserList` in the Windows Registry.
* **Detection:** Registry Integrity Monitoring and automated ACL restoration.


* **T1564.006: Hidden Virtual Machines**
* **Simulation:** Headless rogue VM creation using `VBoxManage`.
* **Detection:** Monitoring virtualization LOLBins and execution chains.




* **SIEM / EDR / Telemetry:** Wazuh, Splunk, Sysmon
* **Attack Simulation:** Atomic Red Team, VirtualBox CLI
* **Automation & Scripting:** PowerShell, Python (Active Response)
* **Framework:** MITRE ATT&CK

---

*Created by **RASHEED AL-RAJEHI @ SHADOW WOLF SECURITY** - Demonstrating End-to-End SOC Capabilities.*

