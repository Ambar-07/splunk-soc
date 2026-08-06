# AI-Assisted SIEM Threat Detection Platform

A minimal, educational **Security Information and Event Management (SIEM)** dashboard built on **Splunk Enterprise**, designed to demonstrate how a SIEM collects logs, detects attacks, and maps detections to the **MITRE ATT&CK** framework.

> Built as a teaching tool, not a commercial SOC clone. Every panel answers one of three questions: **What happened? Is it suspicious? Which MITRE ATT&CK technique does it map to?**

---

## Table of Contents

- [Features](#features)
- [Dashboard Panels](#dashboard-panels)
- [MITRE ATT&CK Mapping](#mitre-attck-mapping)
- [Architecture](#architecture)
- [Requirements](#requirements)
- [Installation](#installation)
  - [1. Deploy the Dashboard](#1-deploy-the-dashboard)
  - [2. Set Up Log Monitoring](#2-set-up-log-monitoring)
- [Generating Test Data](#generating-test-data)
- [Project Structure](#project-structure)
- [Troubleshooting](#troubleshooting)
- [Roadmap](#roadmap)

---

## Features

- **4 KPI cards** — current totals only, no misleading percentages
- **Event Timeline** — when security events occurred
- **Recent Events table** — live parsed Linux auth/sudo/SSH logs
- **MITRE ATT&CK Mapping** — auto-classifies real events into attack techniques
- **AI Summary** — dynamic text generated from actual indexed log counts
- **Dark, professional theme** — native Splunk colors, no animations or hacker aesthetics
- **Fully data-driven** — zero hardcoded metrics; every panel queries live Splunk data

## Dashboard Panels

| Section | Panel | Purpose |
|---------|-------|---------|
| Overview | Total Events | How much log data do we have? |
| Overview | Failed Logins | Authentication failures detected |
| Overview | Successful Logins | Valid account activity |
| Overview | Active Log Sources | How many hosts are reporting |
| Timeline | Event Timeline | When did events occur (hourly line chart) |
| Recent Events | Recent Events Table | Live view of parsed events: Time, Event, User, Source IP, Status |
| ATT&CK | MITRE ATT&CK Mapping | Maps real events to techniques + IDs + status |
| Summary | AI Summary | Auto-generated plain-text analysis of current data |

## MITRE ATT&CK Mapping

The dashboard maps **real log patterns** to MITRE ATT&CK techniques dynamically — nothing is hardcoded.

| Log Pattern | Event | Technique | Technique ID | Status |
|-------------|-------|-----------|--------------|--------|
| `Failed password` (SSH) | Failed SSH Login | Brute Force | T1110 | Detected |
| `Accepted password` / `session opened` | Successful Login | Valid Accounts | T1078 | Monitored |
| `COMMAND=` (sudo) | Privilege Escalation | Abuse Elevation Control Mechanism | T1548 | Detected |

## Architecture

```
Linux logs (auth/sudo/sshd)
        │
        ▼
Splunk monitor input  ──►  index=main, sourcetype=save
        │
        ▼
Splunk Enterprise search  ──►  Splunk dashboard (Simple XML)
        │
        ▼
Panels: KPIs • Timeline • Events • ATT&CK Map • AI Summary
```

- **Log collection:** Splunk monitor inputs watch `/var/log/splunk-monitor/*.log`
- **Parsing:** SPL `rex` commands extract `user`, `source IP`, and event status
- **Classification:** SPL `case()` / `eval` statements map events to ATT&CK techniques
- **Presentation:** Native Splunk Simple XML dashboard (`siem_dashboard.xml`)

## Requirements

- **Splunk Enterprise** installed at `/opt/splunk` (any recent free tier)
- Linux environment (Kali/Debian tested)
- A file-based log source (auth logs, sudo logs, etc.)

## Installation

### 1. Deploy the Dashboard

Copy the dashboard into Splunk's search app views folder:

```bash
sudo mkdir -p /opt/splunk/etc/apps/search/local/data/ui/views/
sudo cp siem_dashboard.xml /opt/splunk/etc/apps/search/local/data/ui/views/siem_dashboard.xml
sudo /opt/splunk/bin/splunk restart
```

Open the dashboard:

```
http://localhost:8000/en-US/app/search/siem_dashboard
```

### 2. Set Up Log Monitoring

Run the setup script to configure a monitor input (auto-indexes any log you drop in):

```bash
sudo bash setup_monitor.sh
```

This:
1. Creates `/var/log/splunk-monitor/`
2. Writes `inputs.conf` pointing that folder → `index=main`, `sourcetype=save`
3. Restarts Splunk

**Adding logs later** is just:

```bash
sudo cp yourfile.log /var/log/splunk-monitor/
```

Splunk indexes it within seconds — no upload wizard needed.

> Alternative manual method: in the Splunk UI go to **Settings → Data → Data inputs → Upload**, select your file, set **sourcetype = `save`** and **index = `main`**.

## Generating Test Data

Generate a realistic auth log with **today's date** (required — old dates fall outside the visible range):

```bash
bash generate_test_logs.sh
```

Produces `test_auth_<date>.log` containing:
- 6 failed SSH logins (→ T1110 Brute Force)
- 4 successful logins + sessions (→ T1078 Valid Accounts)
- 3 sudo privilege-escalation commands (→ T1548)

Then index it:

```bash
sudo cp test_auth_<date>.log /var/log/splunk-monitor/test_auth.log
```

A static sample (`sample_auth.log`) is also included for reference.

## Project Structure

```
├── siem_dashboard.xml        # Main Splunk dashboard (Simple XML)
├── setup_monitor.sh          # Configures Splunk monitor input for log folder
├── generate_test_logs.sh     # Creates fresh test logs with today's date
├── generate_mock_data.sh     # (Optional) HEC-based mock event generator
├── sample_auth.log           # Static sample auth/sudo/sshd logs
├── index.html                # (Optional) Static mock dashboard for Cloudflare Pages demo
└── README.md                 # This file
```

## Troubleshooting

| Problem | Fix |
|---------|-----|
| Dashboard 404 | Ensure `siem_dashboard.xml` is in `/opt/splunk/etc/apps/search/local/data/ui/views/` and Splunk was restarted. XML must be valid — any unescaped `&` (e.g. `ATT&CK`) breaks the whole file (must be `ATT&amp;CK`). |
| All zeros / no data | Check the index: run `index=main | stats count by sourcetype` in Splunk Search. If your data is in another index, update every `index=main` in the XML. |
| Timeline graph flat | Your logs are too old. Test logs must be dated **today** — regenerate with `generate_test_logs.sh`. |
| CLI says "Login failed" | Use the password you log into the web UI with. Do not use literal placeholder text like `YOURREALPASSWORD`. |
| No `main` index in upload dropdown | The wizard auto-guessed another index (e.g. `exim_main`). Use the monitor input method instead, or update the dashboard to your real index. |

## Roadmap

Planned future panels (layout already supports them, no redesign needed):

- Detection Rules
- Alert Panel
- Threat Intelligence
- MITRE ATT&CK Heatmap
- Risk Score
- Geographic Attack Map

---

*"This is the first prototype. Over the internship I'll extend it with live log ingestion, detection rules, alerts, AI summaries, and a full MITRE ATT&CK heatmap."*
