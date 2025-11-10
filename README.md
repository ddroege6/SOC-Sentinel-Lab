# 🛰️ FTC SOC Sentinel Lab  
**Modern Security Operations Lab | Microsoft Sentinel + Fluent Bit + Azure Integration**

> _A hands-on cybersecurity learning environment demonstrating how cloud-native tools can collect, normalize, and analyze security telemetry from hybrid sources._

---

## 🎯 Project Overview

This lab showcases how **Microsoft Sentinel**, **Azure Log Analytics**, and **Fluent Bit** can be used together to create an intelligent, scalable, and modern **Security Operations Center (SOC)** data ingestion pipeline.

The goal is simple:
> Learn, build, and demonstrate real-world SOC workflows that help detect, analyze, and respond to incidents using cloud-native and open-source tools.

### 🌐 Why This Matters
Security teams today face a flood of data from multiple systems.  
This project shows how to:
- Collect logs from **both Azure** and **custom local sources**  
- Normalize and enrich data at the edge using **Fluent Bit**  
- Ingest into **Microsoft Sentinel** for analysis, detection, and visualization  
- Prepare the foundation for **automated threat correlation** and **AI-assisted triage**

---

## ⚙️ Architecture

🧭 **High-Level Flow**

```
+------------------+         +----------------------+         +----------------------+
|  Local System    |  --->   |  Fluent Bit (Agent)  |  --->   |  Azure Log Analytics |
|  (Custom Logs)   |         |  Parse + Enrich + TX |         |  Sentinel Workspace  |
+------------------+         +----------------------+         +----------------------+
        ▲                                                           |
        |                                                           ▼
        |                                                Microsoft Sentinel SIEM
        |                                                - Incidents
        |                                                - Workbooks
        |                                                - KQL Analytics
```

🧩 **Key Components**
| Component | Purpose |
|------------|----------|
| **Microsoft Sentinel** | Cloud-native SIEM and SOAR platform for correlation, alerts, and incident response. |
| **Azure Log Analytics** | Centralized data store for telemetry, metrics, and custom logs. |
| **Fluent Bit** | Lightweight, high-performance log processor and forwarder for structured/unstructured data. |
| **PowerShell + KQL** | Used for setup automation and analysis queries. |

---

## 🧱 Lab Configuration

### 🔧 Fluent Bit Setup

- Installed locally on Windows  
- Input: `tail` mode from `C:\fluentbit-logs\app.log`  
- Filter: `modify` filter adds metadata (`environment=lab`, `source=fluentbit-demo`)  
- Output: `azure` plugin sends data to Sentinel workspace using environment variables  

```ini
[INPUT]
    Name        tail
    Path        C:\fluentbit-logs\app.log
    Parser      json

[FILTER]
    Name        modify
    Add         environment lab
    Add         source      fluentbit-demo

[OUTPUT]
    Name        azure
    Match       *
    Customer_ID ${WORKSPACE_ID}
    Shared_Key  ${SHARED_KEY}
```

Sensitive credentials are securely stored in:
```
fluent-bit/secrets.local.env
```

_(Excluded via `.gitignore` for security.)_

---

### 💾 Log Example

```json
{
  "ts": "2025-11-09T18:40:30Z",
  "app": "demo-api",
  "user": "testuser",
  "severity": "INFO",
  "clientIp": "127.0.0.1",
  "msg": "Test log event from Fluent Bit lab"
}
```

Once ingested, logs appear in Sentinel as:
| TimeGenerated | app | user | severity | environment_s | source_s |
|----------------|------|-------|-----------|----------------|-----------|
| 2025-11-09 18:40 | demo-api | testuser | INFO | lab | fluentbit-demo |

---

## 🧠 What’s Happening Behind the Scenes

1. **Fluent Bit** tails local JSON log files in near real-time.  
2. It enriches them with contextual tags (environment, source).  
3. It authenticates to Azure via a shared workspace key (stored locally).  
4. Logs are transmitted to **Azure Log Analytics**, which automatically creates a **custom table (`MyAppLogs_CL`)**.  
5. **Microsoft Sentinel** indexes, visualizes, and correlates that data with other telemetry (Entra ID, AzureActivity, etc.).  
6. From there, **analytic rules** and **incidents** can trigger alerts or SOAR playbooks.

---

## 🔍 Example KQL Queries

### 🔸 Check Custom Tables
```kusto
union withsource=SrcTable *
| summarize count() by SrcTable
| sort by count_ desc
```

### 🔸 View Custom Logs
```kusto
MyAppLogs_CL
| sort by TimeGenerated desc
| take 20
```

### 🔸 Parse and Visualize Data
```kusto
MyAppLogs_CL
| extend parsed = parse_json(log_s)
| project TimeGenerated, parsed.app, parsed.user, parsed.severity, environment_s, source_s
| summarize TotalLogs = count() by parsed.app, environment_s
| render piechart
```

---

## 📸 Visual Showcase

- [ ] Sentinel Incident Page (`Suspicious Resource Group Creation`)
- [ ] KQL Query showing `MyAppLogs_CL`
- [ ] Fluent Bit console output
- [ ] Sentinel Workbook visualizations


---

## 🧩 Why a Company Might Use This

Organizations benefit from this setup because it:

- 🌩 **Bridges cloud and on-prem data** without heavy infrastructure  
- ⚡ **Enables near real-time log forwarding** at scale with minimal overhead  
- 🧠 **Supports advanced correlation** in Sentinel using KQL  
- 🔐 **Follows strong security posture**, keeping keys out of code  
- 💡 **Improves visibility** into custom applications that might not have native connectors  

This mirrors real-world SOC workflows — blending **open-source flexibility** with **enterprise-grade analytics**.

---

## 🚀 Lessons Learned

- Azure automatically provisions a custom table for new data sources.  
- Fluent Bit’s config must reference environment variables correctly — sessions reset them!  
- Sentinel’s query language (KQL) is powerful for exploratory data analysis.  
- The connection pipeline can be extended to non-Azure environments.  

---

## 🧭 Future Add-Ons (Roadmap)

| Planned Feature | Description | Benefit |
|------------------|--------------|----------|
| **OpenCTI Integration** | Connect to threat intelligence feeds for enrichment | Add context to alerts, automate tagging of IOC data |
| **AI/Agentic Triage Assistant** | Leverage LLMs to summarize alerts and correlate indicators | Reduce analyst fatigue, faster triage |
| **Elastic or Splunk Ingestion Branch** | Compare pipeline efficiency and cost | Showcase interoperability and performance optimization |
| **Data Normalization (ASIM)** | Apply Azure’s standard schema mapping | Enable advanced cross-source correlations |
| **Anomaly Detection Workbooks** | KQL + ML workbook for behavioral insights | Early detection of anomalies or lateral movement |

---

## 🧾 Repository Structure

```
ftc-soc-sentinel-lab/
├── fluent-bit/
│   ├── fluent-bit.conf
│   ├── fluent-bit-test.conf
│   ├── secrets.local.env     # (ignored)
│   └── app.log               # sample logs
├── sentinel/
│   ├── kql/
│   │   ├── detect_suspicious_resource_group_creation.kql
│   │   └── myapplogs_queries.kql
│   └── workbook_screenshots/
├── README.md
└── .gitignore
```

---

## 🤝 Acknowledgments

Special thanks to:
- **Fluent Bit community** for powerful open-source logging tech  
- **Microsoft Sentinel team** for building an elegant, extensible SIEM  
- **OpenCTI** and **MITRE ATT&CK** projects for advancing collaborative defense

---

## 🧩 Author Notes

> _This lab was created as part of my ongoing cybersecurity engineering learning journey — bridging cloud security, SOC operations, and automation. The focus is on experimentation, continuous improvement, and sharing reproducible knowledge for others to learn from._


---

_**Last Updated:** November 2025_  
_**Status:** Active Learning Lab_
