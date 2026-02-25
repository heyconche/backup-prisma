# 🚀 Commvault External Exposure & Analytics Automation

This project automates the secure exposure of a Commvault CommServe environment on Google Cloud Platform (GCP). It uses a hybrid approach with **Terraform** for infrastructure and **Ansible** for guest-level configuration.

## 🎯 Project Vision
The primary goal is to transform Commvault from a "closed" backup tool into a **Data Source**. By exposing the Commvault REST API through a secure Load Balancer, we enable:
1.  **Automated Data Extraction:** Seamlessly pulling metadata via API.
2.  **Advanced Analytics:** Feeding data into **Google Looker** for executive dashboards.
3.  **Simplified Reporting:** Providing clients with high-level backup insights (Success rates, storage growth, compliance) without requiring technical expertise or direct access to the CommCell.

---

## 🏗️ Architecture Components

### 1. Infrastructure (Terraform)
* **Global HTTPS Load Balancer:** Handles incoming traffic with high availability.
* **Google-Managed SSL Certificate:** Provides automated encryption for the chosen domain.
* **Cloud Firewall Rules:** Specific rules for Google Health Checks and internal communication.
* **Unmanaged Instance Group:** Maps your existing CommServe VM to the Load Balancer backend.

### 2. Configuration (Ansible)
* **Tomcat Tuning:** Configures the Commvault Apache instance for secure proxying.
* **Registry Automation:** Automatically sets "Additional Settings" (CommandCenterURL, WebConsoleURL, ShowCommandCenterIcon).
* **Service Management:** Ensures the Web Console services are correctly restarted and healthy.

---

## 🛠️ Technology Stack
* **IaC:** Terraform
* **Configuration Management:** Ansible (targeting Windows/WinRM)
* **Cloud:** Google Cloud Platform (GCP)
* **API:** Commvault REST API
* **Visualization:** Google Looker / Looker Studio

---

## 🚀 Deployment Workflow

### 1. Provision Infrastructure
Navigate to the `terraform/` directory, update your `terraform.tfvars`, and run:
```bash
terraform init
terraform apply