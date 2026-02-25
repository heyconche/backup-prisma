# 📊 Commvault Observability & Centralized Analytics

This project automates the collection of backup metadata from Commvault environments and transforms it into actionable executive dashboards on Google Cloud Platform (GCP).

## 🎯 Project Vision
The objective is to bridge the gap between complex backup operations and high-level business validation. By decoupling data from the CommServe, we provide:
1.  **Centralized Visibility:** A single source of truth for hybrid backup environments.
2.  **Technical Decoupling:** Stakeholders can validate backup health (Success/Failure rates) without direct access to the CommServe or technical training.
3.  **Governance & Compliance:** Historical tracking of job statuses for audit and health monitoring.

---

## 🏗️ Architecture Components

### 1. Infrastructure (Terraform)
* **Google Cloud SQL (MySQL):** Managed database instance to store historical backup metadata.
* **IAM & Security:** Service accounts and roles for secure API interaction and database access.
* **Networking:** Cloud Firewall configuration for secure communication between the collector and the database.

### 2. Configuration & Automation (Ansible)
* **Environment Setup:** Automates Python environment preparation and library dependencies (`pymysql`, `requests`).
* **Collector Deployment:** Provisions the data extraction script and manages environment variables.

### 3. Data Pipeline (Python & API)
* **REST API Integration:** Custom collector utilizing Long-Lived Access Tokens and Auto-Refresh logic.
* **Service Account (Prisma):** Dedicated Commvault user for secure, non-interactive data extraction.

---

## 🛠️ Technology Stack
* **IaC:** Terraform
* **Configuration Management:** Ansible
* **Cloud:** Google Cloud Platform (GCP)
* **Database:** Cloud SQL for MySQL
* **Language:** Python 3.x
* **API:** Commvault REST API
* **Visualization:** Google Looker Studio