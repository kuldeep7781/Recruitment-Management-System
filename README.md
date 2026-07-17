# Recruitment Management System

A Salesforce-based Recruitment Management System developed to streamline the hiring process. The application manages candidates, job positions, job applications, interviews, and approvals while demonstrating Salesforce Admin and Apex development concepts.

---

## Features

- Candidate, Department, Job Position, Job Application and Interview Management
- Trigger Framework using Trigger → Handler → Service architecture
- Candidate Dashboard built with Lightning Web Components (LWC)
- Approval Process for Offer Release workflow
- Apex REST API for Candidate creation
- Queueable Apex for asynchronous notification processing
- Batch Apex for stale application updates
- Scheduled Apex for automatic batch execution
- Reports and Dashboards

---

## Tech Stack

- Salesforce CRM
- Apex
- Lightning Web Components (LWC)
- SOQL
- REST API
- Queueable Apex
- Batch Apex
- Scheduled Apex
- Approval Process

---

## Architecture

```text
LWC
 │
 ▼
Apex Controller
 │
 ▼
Service Layer
 │
 ▼
Trigger Handler
 │
 ▼
Trigger
 │
 ▼
Salesforce Database
```

---

## Business Flow

```text
Candidate
    │
    ▼
Job Application
    │
    ▼
Interview
    │
    ▼
Approval Process
    │
    ▼
Offer Accepted / Offer Rejected
```

---

## Project Structure

```text
force-app
├── classes
├── triggers
├── lwc
├── objects
└── layouts
```

---

## Deployment

```bash
sf project deploy start
```

---

## Screenshots

Screenshots will be added soon.

---

## Author

**Kuldeep Patel**