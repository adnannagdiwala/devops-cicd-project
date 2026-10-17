# 🚀 DevOps CI/CD Pipeline — Microservice Deployment

A complete CI/CD pipeline project that automates the build, test, and deployment of a containerized microservice application to Kubernetes (Minikube) on AWS.

## 📐 Architecture

```
GitHub → Jenkins (EC2) → Docker Build → Docker Hub → Minikube (EC2)
                                                       ├── Frontend (Nginx)
                                                       ├── Backend (Flask API)
                                                       ├── MySQL Database
                                                       ├── Prometheus
                                                       └── Grafana
```

**Infrastructure**: AWS CLI (CloudShell) · **Configuration**: Ansible · **CI/CD**: Jenkins · **Container Registry**: Docker Hub · **Orchestration**: Minikube

---

## 🧰 Tech Stack

| Tool | Purpose |
|---|---|
| **AWS EC2** | Hosts Jenkins and Minikube |
| **AWS CLI** | Infrastructure provisioning (from CloudShell) |
| **Ansible** | Server configuration & app deployment |
| **Docker** | Containerization |
| **Docker Hub** | Container image registry |
| **Jenkins** | CI/CD pipeline automation |
| **Kubernetes (Minikube)** | Container orchestration |
| **Prometheus** | Metrics collection |
| **Grafana** | Monitoring dashboards |
| **MySQL** | Application database |
| **Flask (Python)** | Backend REST API |
| **Nginx** | Frontend web server + reverse proxy |

---

## 📂 Project Structure

```
├── app/                    # Application source code
│   ├── frontend/           # Nginx + HTML frontend
│   ├── backend/            # Flask REST API
│   └── docker-compose.yml  # Local development
├── aws-cli/                # AWS CLI scripts (run from CloudShell)
├── ansible/                # Ansible playbooks & config
│   ├── playbooks/          # All playbooks
│   └── inventory/          # Host inventory
├── kubernetes/             # K8s manifests
│   ├── frontend/           # Frontend deployment & service
│   ├── backend/            # Backend deployment & service
│   ├── database/           # MySQL deployment, service, PVC, secret
│   └── monitoring/         # Prometheus & Grafana
├── jenkins/                # Jenkinsfile pipeline
└── scripts/                # Helper scripts (rollback, health-check)
```

---

## 🚀 Quick Start

### 1. Provision Infrastructure (AWS CloudShell)
```bash
cd aws-cli
bash 01-create-vpc.sh
bash 02-create-subnets.sh
bash 03-create-security-groups.sh
bash 04-create-keypair.sh
bash 05-launch-jenkins-ec2.sh
bash 06-launch-app-ec2.sh
```

### 2. Configure Servers (Ansible)
```bash
# Update inventory with EC2 public IPs
vim ansible/inventory/hosts.ini

# Run all playbooks
cd ansible
ansible-playbook playbooks/site.yml
```

### 3. Setup Jenkins Pipeline
1. Open Jenkins at `http://<JENKINS_IP>:8080`
2. Install suggested plugins + Docker Pipeline + SSH Agent
3. Add credentials: Docker Hub, App Server SSH key
4. Create Pipeline job pointing to this repo's `jenkins/Jenkinsfile`
5. Configure GitHub webhook: `http://<JENKINS_IP>:8080/github-webhook/`

### 4. Push Code & Watch It Deploy!
```bash
git add . && git commit -m "feat: update app" && git push
# Jenkins automatically builds, tests, and deploys to Minikube!
```

---

## 🧹 Cleanup
```bash
# From CloudShell — destroys ALL AWS resources
cd aws-cli
bash 99-cleanup-all.sh
```

---

## 📊 Monitoring

| Service | URL |
|---|---|
| Frontend | `http://<APP_IP>:30080` |
| Prometheus | `http://<APP_IP>:30090` |
| Grafana | `http://<APP_IP>:30030` (admin/admin) |

---

## 👤 Author

**Your Name** — [GitHub](https://github.com/yourusername) · [LinkedIn](https://linkedin.com/in/yourprofile)
