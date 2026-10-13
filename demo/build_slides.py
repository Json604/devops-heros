"""Build the capstone PDF slide deck: python -m pip install reportlab; python demo/build_slides.py."""
from pathlib import Path
from reportlab.pdfgen import canvas
from reportlab.lib.colors import HexColor, white
from reportlab.lib.utils import ImageReader
from reportlab.lib.styles import ParagraphStyle
from reportlab.platypus import Paragraph

ROOT = Path(__file__).resolve().parents[1]
PROJECT = ROOT / "session21-final-devops-project"
OUT = ROOT / "demo/slides.pdf"
W, H = 960, 540
c = canvas.Canvas(str(OUT), pagesize=(W, H))
c.setTitle("Campus Helpdesk - DevOps Capstone")
c.setAuthor("Kartikey - 24bcs10121")
NAVY, TEAL, INK = map(HexColor, ["#102E43", "#008D88", "#263746"])
style = ParagraphStyle("body", fontName="Helvetica", fontSize=19, leading=28, textColor=INK)
small = ParagraphStyle("small", parent=style, fontSize=11, leading=15)

def text(value, x, top, width=840, font=style):
    p = Paragraph(value, font)
    _, height = p.wrap(width, H)
    p.drawOn(c, x, H-top-height)
    return height

def page(title, number, source):
    c.setFillColor(white)
    c.rect(0, 0, W, H, fill=1, stroke=0)
    c.setFillColor(TEAL)
    c.rect(0, H-12, W, 12, fill=1, stroke=0)
    c.setFillColor(NAVY)
    c.setFont("Helvetica-Bold", 32)
    c.drawString(48, H-70, title)
    c.setStrokeColor(HexColor("#D5E2E8"))
    c.line(48, 44, W-48, 44)
    c.setFillColor(INK)
    c.setFont("Helvetica", 9)
    c.drawString(48, 27, source)
    c.drawRightString(W-48, 27, str(number))

def lines(items, x=48, top=118, width=840):
    for heading, detail in items:
        height = text(f"<b>{heading}</b><br/>{detail}", x, top, width)
        top += height + 23

def screenshot(name, x=455, top=115, width=455, height=330):
    img = ImageReader(str(PROJECT / "screenshots" / name))
    iw, ih = img.getSize()
    ratio = min(width/iw, height/ih)
    dw, dh = iw*ratio, ih*ratio
    c.drawImage(img, x+(width-dw)/2, H-top-dh, dw, dh)

page("Campus Helpdesk", 1, "Kartikey | 24bcs10121 | DevOps Final Capstone")
text("Campus IT requests, from report to resolution", 48, 112, 790)
screenshot("compose-current.png", 440, 185, 470, 265)
lines([("Purpose", "Track campus support requests with category, priority, assignee and status."),
       ("Submission", "React, FastAPI and PostgreSQL with a tested DevSecOps delivery workflow.")], top=190, width=340)
c.showPage()

page("Technology stack", 2, "Source: session21-final-devops-project/README.md")
lines([("Application", "React + Vite, FastAPI, SQLAlchemy, PostgreSQL and Alembic"),
       ("Delivery", "Pytest, Docker Compose, GitHub Actions, Trivy and GHCR"),
       ("Infrastructure and operations", "Terraform, AWS EKS, Kubernetes, Helm, Argo CD, Prometheus and Grafana")])
c.showPage()

page("Application architecture", 3, "Source: Helm templates, Compose configuration and monitoring values")
nodes = [(48,140,190,70,"Browser / Ingress"),(300,140,240,70,"React / Nginx"),
         (610,140,290,70,"FastAPI / 2-5 replicas"),(610,280,290,70,"PostgreSQL + PVC"),
         (48,280,230,70,"Prometheus"),(48,395,230,60,"Grafana")]
for x,y,w,h,label in nodes:
    c.setFillColor(NAVY)
    c.roundRect(x,H-y-h,w,h,8,fill=1,stroke=0)
    c.setFillColor(white); c.setFont("Helvetica-Bold",17)
    c.drawCentredString(x+w/2,H-y-h/2-6,label)
c.setStrokeColor(TEAL); c.setLineWidth(3)
for x1,y1,x2,y2 in [(238,175,300,175),(540,175,610,175),(755,210,755,280),
                       (610,230,163,230),(610,210,610,230),(163,230,163,280),(163,350,163,395)]:
    c.line(x1,H-y1,x2,H-y2)
text("Ingress routes / to frontend and /api to backend.<br/>Prometheus scrapes /metrics. Grafana queries Prometheus.",330,390,570,small)
c.showPage()

page("API, migrations and tests", 4, "Source: application/backend/app, tests and alembic/versions")
lines([("REST operations", "Create, list, read, update and delete tickets. Stats group requests by status."),
       ("Database lifecycle", "Alembic creates the tickets table. A migration job completes before API readiness."),
       ("17 isolated API tests", "CRUD, validation, missing IDs, readiness and metrics. Each test uses a fresh SQLite database.")])
c.showPage()

page("CI/CD flow", 5, "Source: .github/workflows/helpdesk.yml | Successful run: 37662449564")
lines([("1. Quality gates", "Pytest and frontend build, Bandit, dependency audits and Gitleaks"),
       ("2. Build and publish", "Build both images. Trivy blocks HIGH/CRITICAL findings. Publish GHCR tags using the Git SHA."),
       ("3. Deployment verification", "Install with Helm in Kind. Check readiness, frontend HTTP and ticket creation. Export release values.")])
c.showPage()

page("Container security", 6, "Source: security/README.md and evidence/main-ci-security-summary.txt")
lines([("Small, non-root runtime images", "Python Alpine backend and a multi-stage Node build with unprivileged Nginx runtime"),
       ("A real release gate", "An earlier Debian image failed its vulnerability scan. Changing the runtime removed affected packages."),
       ("Meaning of a clean scan", "Both recorded release images had zero HIGH/CRITICAL findings at scan time. New advisories can change that result.")])
c.showPage()

page("AWS infrastructure", 7, "Historical AWS deployment: 7 October 2026 | Source: evidence/aws-plan.txt and aws-apply.txt")
lines([("Terraform", "20 resources in ap-south-1. VPC, two public subnets and a managed EKS worker group."),
       ("Cluster access", "Two t3.medium workers. Private worker API access and a restricted administrator CIDR."),
       ("Storage", "EBS CSI uses Pod Identity to provision persistent PostgreSQL storage.")], width=355)
screenshot("aws-eks-active.png")
c.showPage()

page("Kubernetes and Helm", 8, "Source: helm/helpdesk and evidence/eks-verification.txt | Recorded EKS run")
lines([("Workloads", "Two frontend and two backend replicas, plus a PostgreSQL StatefulSet and PVC."),
       ("Traffic and health", "ClusterIP Services, Ingress routes, startup/liveness/readiness probes and CPU HPA."),
       ("Configuration", "ConfigMap for settings. Runtime Secret for the database password. Helm packages the deployment.")])
c.showPage()

page("GitOps release promotion", 9, "Source: gitops/README.md and evidence/eks-gitops-release.json | Recorded EKS run")
lines([("Desired state in Git", "Argo CD reads Helm values, synchronizes changes and repairs drift."),
       ("Immutable release", "Commit 9d7f9c4 promoted images built from 328f4c5. Argo reported Synced and Healthy."),
       ("Ownership", "Helm bootstraps the application. Argo owns reconciliation after handoff. HPA owns backend replica count.")])
c.showPage()

page("Prometheus and Grafana", 10, "Source: monitoring/ and screenshots/eks-grafana.png | Recorded EKS run")
lines([("Collection", "ServiceMonitor discovers both backend Pods. Both targets reported UP."),
       ("Dashboards", "Live request, CPU and memory panels. Metrics selectors match the Operator labels.")], width=355)
screenshot("eks-grafana.png")
c.showPage()

page("Recovery and cleanup", 11, "Source: troubleshooting/ and evidence/aws-destroy.txt, aws-cleanup.json")
lines([("Failure investigations", "Image pull, Service selector and readiness faults. Capture diagnostics, restore configuration and verify HTTP."),
       ("Cloud teardown", "The saved destroy plan removed all 20 project resources. Cleanup checks found no remaining project VPC, workers or volumes."),
       ("Evidence boundary", "AWS screenshots show the 7 October run. The EKS cluster is now deleted. A new live cloud demo requires redeployment.")])
c.showPage()

page("Key learnings and limits", 12, "Repository: https://github.com/Json604/devops-heros")
lines([("Readiness protects traffic", "A Running Pod may still be waiting for its database or migration."),
       ("GitOps changes operations", "Pause self-healing during deliberate failure exercises and restore it afterward."),
       ("Classroom scope", "No authentication or TLS. Monitoring storage is ephemeral. Production would need access control, backups and durable telemetry.")])
c.showPage()
c.save()
print(OUT)
