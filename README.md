# DevOps Learning Journey

Welcome to my DevOps learning repository! On November 11th, 2025, I started my journey to learn DevOps, and this repository will document my progress and showcase the projects I build along the way.

## About This Repository

This is a hands-on learning repository where I'll be practicing and implementing various DevOps concepts, tools, and technologies. Each project represents a new skill or concept I'm learning, with practical implementations and documentation.

## Projects

### 1. Polyglot Microservices Architecture Demo
**Status:** ✅ Completed ⭐ **Updated: 2025-11-13**
**Location:** [`1-microservices_test/`](1-microservices_test/)

A demonstration of **polyglot microservices architecture** featuring services written in **Go, Node.js, and Python** communicating seamlessly via REST APIs:
- **Time Service** (Go) - Blazing fast compiled service for timestamps
- **System Info Service** (Python) - Detailed system information using psutil
- **Weather Service** (Node.js) - Async weather data fetching with caching
- **Dashboard Service** (Python) - Web UI aggregating all services

**Technologies:** Docker, Docker Compose, Go, Node.js, Python Flask, REST APIs, External API Integration

**Key Concepts Demonstrated:**
- **Polyglot architecture** - Multiple programming languages working together
- Language-agnostic communication via REST APIs and JSON
- Service-to-service communication across different runtimes
- Multi-stage Docker builds (Go service)
- Detailed system metrics (CPU cores, memory usage, architecture)
- Real-time weather integration using wttr.in API
- Health checks for all services
- Docker networking and container orchestration
- Cross-platform compatibility (Windows, Linux, macOS)
- **Performance optimizations** (parallel API calls, caching, reduced timeouts)
- Real-time updates with live clock
- Best tool for the job - each service uses optimal language

[View Project →](1-microservices_test/)

## Learning Roadmap

Here are the topics I plan to cover as I progress in my DevOps journey:

- [x] **Microservices Architecture** - Service-to-service communication (completed 2025-11-11)
- [x] **Polyglot Microservices** - Multi-language services (Go, Node.js, Python) (completed 2025-11-13)
- [ ] **Linux Administration** - System administration and shell scripting
- [ ] **Programming & Scripting** - Python, Bash, and automation scripts
- [ ] **Cloud Platforms** - AWS, Azure, or GCP
- [ ] **Infrastructure as Code (IaC)** - Terraform, CloudFormation
- [ ] **Configuration Management** - Ansible, Puppet, or Chef
- [ ] **CI/CD Pipelines** - Jenkins, GitLab CI, GitHub Actions
- [ ] **Container Orchestration** - Kubernetes
- [ ] **Monitoring & Logging** - Prometheus, Grafana, ELK Stack
- [ ] **Version Control** - Advanced Git workflows

## Repository Structure

```
devops-progress/
├── 1-microservices_test/    # First project: Microservices demo
├── 2-*/                      # Future projects will be added here
└── README.md                 # This file
```

## Progress Tracking

**Started:** November 11, 2025
**Last Updated:** November 13, 2025
**Projects Completed:** 1 (with polyglot enhancement)
**Current Focus:** Polyglot Microservices Architecture

---

*This is a living repository that will be continuously updated as I learn and grow in the DevOps field.*
