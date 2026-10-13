# Video chapters and narration

[Download the presentation MP4](presentation.mp4).

Recorded 13 October 2026. This edited walkthrough uses synthesized macOS Samantha narration, not Kartikey’s voice. Slides come first. Browser captures and command output are from actual execution; waits are shortened and selected frames are held while explained. The application, Prometheus and Grafana segments include timed live captures. CLI output is displayed in a read-only local transcript viewer. The slide deck labels older 7 October screenshots; the walkthrough uses the fresh 13 October deployment. AWS was destroyed after capture.

Duration: 13:40. Resolution: 1600 × 900. H.264 video / AAC audio.

| Start | Chapter |
|---|---|
| 00:00 | slide 01 |
| 00:24 | slide 02 |
| 00:51 | slide 03 |
| 01:13 | slide 04 |
| 01:41 | slide 05 |
| 02:07 | slide 06 |
| 02:33 | slide 07 |
| 03:01 | slide 08 |
| 03:25 | slide 09 |
| 03:52 | slide 10 |
| 04:16 | slide 11 |
| 04:43 | slide 12 |
| 05:10 | code structure |
| 05:33 | code routes |
| 05:55 | push before |
| 06:09 | push during |
| 06:28 | pipeline second running |
| 06:45 | pipeline second success |
| 07:06 | security results |
| 07:29 | terraform plan |
| 07:49 | terraform apply |
| 08:05 | eks active |
| 08:23 | eks workers |
| 08:40 | vpc live |
| 08:57 | vpc subnets |
| 09:16 | gitops before |
| 09:36 | gitops promotion |
| 09:56 | gitops healthy |
| 10:17 | kubernetes pods |
| 10:35 | kubernetes services |
| 10:58 | app empty |
| 11:12 | app filled |
| 11:28 | app created |
| 11:43 | app live |
| 12:03 | metrics live |
| 12:22 | prometheus live |
| 12:42 | grafana live |
| 13:04 | cleanup |

## Narration

### slide 01

Campus Helpdesk is the DevOps capstone for Kartikey, roll number 24 B C S 10121. It tracks campus IT requests from reporting to resolution. This presentation uses synthetic narration with captures of the actual project and live verification. First, the slides explain the architecture. Then the walkthrough shows the system working.

### slide 02

The application uses React and Vite for the interface, FastAPI for the API, and PostgreSQL for persistence. SQLAlchemy maps the ticket model and Alembic manages database migrations. GitHub Actions tests and scans releases before publishing them. Terraform provisions AWS. Kubernetes, Helm and Argo CD manage deployment. Prometheus and Grafana provide metrics.

### slide 03

Traffic enters through the Ingress controller. The root path serves the React frontend through Nginx, and API routes go to FastAPI. The backend stores tickets in PostgreSQL on a persistent volume. Prometheus collects backend metrics, and Grafana queries Prometheus. Kubernetes can scale the backend between two and five replicas.

### slide 04

The API creates, lists, reads, updates and deletes tickets. It also groups counts by status. A separate migration job creates the database table before the backend becomes ready. Seventeen tests cover the API, validation, missing identifiers, readiness and metrics. Each test gets an isolated SQLite database. A separate smoke test verifies the real PostgreSQL path.

### slide 05

A push to main triggers the workflow. Tests, frontend compilation, Bandit, dependency audits and secret scanning run first. Both container images are built and scanned by Trivy. A high or critical vulnerability fails the job before publication. Successful images receive the exact Git commit SHA as their registry tag. A Kind deployment then verifies Helm, HTTP and ticket creation.

### slide 06

The backend uses Python Alpine and runs as user 10001. The frontend builds with Node and serves from unprivileged Nginx as user 101. An earlier Debian image failed the security gate. The runtime change removed affected packages without weakening the policy. A clean scan means no matching high or critical findings in that database at that time. It does not guarantee permanent security.

### slide 07

Terraform manages twenty AWS resources in the Mumbai region. The VPC contains two public subnets and a managed EKS node group with two workers. The Kubernetes API permits private access for workers and restricts public access to the administrator address. EBS CSI uses Pod Identity for persistent storage. The screenshot here is the historical October seventh run. The walkthrough will show the fresh deployment.

### slide 08

The Helm chart defines two frontend replicas and an autoscaled backend. PostgreSQL runs as a StatefulSet with a persistent volume claim. ClusterIP Services give stable internal addresses. Startup and liveness probes check process health, while readiness checks the database. Settings use a ConfigMap and the database password comes from a runtime Secret outside Git.

### slide 09

Argo CD watches the Git repository and reconciles the Helm values. A release promotion commits immutable image tags after the pipeline has passed. Automated synchronization applies the change, self healing repairs drift, and pruning removes resources deleted from desired state. Helm bootstraps the deployment. Argo owns reconciliation after the handoff, while the HPA owns backend replica count.

### slide 10

The backend exposes Prometheus formatted metrics. A ServiceMonitor discovers both backend pods. The recorded EKS deployment showed both targets up. Grafana displays application request counts and rates together with CPU and memory. Dashboard selectors must match the labels generated by the Prometheus Operator. The walkthrough will show current targets and populated panels.

### slide 11

Troubleshooting exercises cover wrong image tags, broken Service selectors and readiness failures. Diagnostics establish the cause before configuration is restored. The previous cloud run destroyed all twenty resources after collecting evidence. Cleanup removes application storage while the CSI driver still runs, then removes the worker group, cluster and network. The fresh run will also be torn down after recording.

### slide 12

The main lesson is that a running pod is not necessarily ready to serve requests. GitOps changes operational ownership, so deliberate failure exercises must account for self healing. This is a classroom application with no authentication or TLS. Production use would need identity, access control, durable monitoring, backups and a recovery plan. The next section walks through the actual system.

### code structure

The codebase separates the application from delivery infrastructure. The backend folder contains routes, schemas, models and database setup. Tests and Alembic migrations sit beside it. The React frontend is separate. Helm, Terraform, monitoring and GitOps each have their own directory. The active workflow lives at repository root.

### code routes

Here are the actual FastAPI routes. Health checks report process health. Readiness queries the ticket table, so traffic waits for the database and migration. Ticket endpoints implement the complete create, read, update and delete lifecycle. Pydantic validates fields and the tests exercise invalid values as well as successful operations.

### push before

The next step triggers a real release pipeline. This capture begins before the commit and push. The change documents the fresh security results and distinguishes committed-source scanning from local secrets.

### push during

The commit succeeds and the push updates main and the submission branch. The new commit is 81797c5. The output shown here comes from the actual Git commands, with their exit statuses. No application image is promoted before its pipeline passes.

### pipeline second running

GitHub shows that this run was triggered by the push to main. The test and security job has already passed, while build, scan and deployment are still running. The wait has been shortened in this edited walkthrough. The full run remains available at the linked GitHub Actions URL.

### pipeline second success

The same run finishes successfully in three minutes and twenty two seconds. Both jobs are green. This includes frontend and backend image builds, the security gates, registry publication and the Kind Kubernetes smoke test. The run identifier is 38326250900.

### security results

The actual job logs show seventeen passing tests, no Bandit findings, no known Python dependency vulnerabilities and a clean committed-source secret scan. Both images were published with the complete commit SHA. The downloaded Trivy reports contain zero high or critical vulnerabilities. The deployment readiness request also passed.

### terraform plan

This is the fresh Terraform plan from October thirteenth. It creates twenty resources and changes or destroys none. The excerpt identifies the VPC, two public subnets, EKS cluster and managed node group. The full reviewed plan is committed as evidence, with the administrator address redacted.

### terraform apply

Terraform completed the apply with twenty resources added and no changes or destruction. The outputs identify the cluster and VPC. The same Terraform state will later drive cleanup, so the deployment and teardown remain reproducible.

### eks active

The AWS Console now shows the actual new EKS cluster as Active in Mumbai. Its Kubernetes version is 1.35. These are current cloud resources created by the recorded Terraform apply, separate from the historical screenshots shown in the slide deck.

### eks workers

The AWS Console lists two ready worker nodes in the managed helpdesk workers group. This confirms that the control plane has actual compute capacity. The workloads in the next sections run on these nodes, rather than on the local verification cluster.

### vpc live

The VPC Console confirms the project network is available. Its address range is 10.21.0.0 slash 16 and the name is kartikey devops. Terraform created it rather than a manual Console operation.

### vpc subnets

The resource map shows a subnet in each of two availability zones, ap south one a and ap south one b, connected to the route table and internet gateway. The public subnet design avoids a NAT Gateway for this short classroom lab. EKS workers and control plane access still use the configured security controls.

### gitops before

Before promotion, Argo CD is already synchronized and healthy. Its source revision is current, while the release values still reference the older verified image SHA. This distinction matters: a repository commit and the image selected by its Helm values are separate identifiers.

### gitops promotion

The Git change replaces both old image tags with 81797c5, the release that just passed the complete pipeline. The Ingress hostname remains unchanged. Committing and pushing this values change lets Argo discover and apply the desired deployment without manually changing the running pods.

### gitops healthy

Argo CD reaches Synced and Healthy at promotion commit 400110b. Both backend and frontend Deployments now report two ready and two updated replicas using the full new image SHA. The migration hook completed successfully. The existing ticket remains in PostgreSQL across the rollout.

### kubernetes pods

These are fresh kubectl results from the EKS context. Both nodes are ready. Two backend pods and two frontend pods are running and ready, together with PostgreSQL. The migration pod is Completed, which is the correct terminal state for a successful one shot job.

### kubernetes services

The Services use ClusterIP addresses. Ingress routes the helpdesk hostname, the HPA has a real CPU measurement and maintains its minimum of two replicas, and the five gigabyte persistent volume is bound. Helm lists the successful bootstrap release. Argo owns subsequent reconciliation, so the Helm revision stays at its initial installation.

### app empty

The live application is reached through the EKS Ingress controller on a loopback port forward. The database starts empty for this new deployment. The interface exposes ticket filters and a request form.

### app filled

A new campus network request is entered through the browser. The form collects a title, details, category, priority, requester and assignee. This sends a real API request through Ingress to FastAPI and PostgreSQL.

### app created

The request appears immediately in the list and the counters update. This ticket was created before the image promotion. Its presence afterward confirms that replacing the application pods did not remove the persistent database record.

### app live

This recorded browser segment resolves the same request after the GitOps rollout. The UI sends an update to the API and moves the ticket into the resolved count. The operation succeeds against the live EKS deployment. The database smoke test also covers reading and deleting a separate temporary audit ticket.

### metrics live

The actual metrics endpoint returns Prometheus text exposition, including process memory, CPU time and HTTP request counters grouped by route, method and status. The command uses a port forward to the backend Service in EKS. The full response is saved with the submission evidence.

### prometheus live

Prometheus discovers two application targets through the Helpdesk ServiceMonitor. Both are up, and the recorded scrape timestamps update on the live Targets page. Each endpoint corresponds to a backend pod, so this verifies both replicas instead of only a single load balanced Service response.

### grafana live

Grafana displays real request rates, request counts, CPU use and memory while traffic reaches the app. The counter drops when the image promotion replaces pods because process counters reset. Rate calculations handle that reset. The dashboard is provisioned from source and uses the Operator labels for the backend Service.

### cleanup

The walkthrough ends with cleanup of the disposable cloud deployment. Application volumes were removed while the storage driver was still available. Terraform then destroyed all twenty managed resources. Independent checks confirm that the EKS cluster, project VPC, active instances, database volume and network interfaces are gone, and Terraform state is empty. The repository retains the source, evidence, slides and this video for review. The submission form has not been sent; the student must select the correct group and official name before the one shot submission.
