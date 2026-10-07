# Notes Helm mini-project

**Name:** Kartikey
**Roll number:** 24bcs10121

The complete chart is in `notes-chart/`, with `Chart.yaml`, development and production values, and ConfigMap/Deployment/Service templates. Run the [session workflow](../run-lab.sh) for install, two upgrades, verification, rollback and uninstall. [Observed output](../evidence/helm-workflow.txt) records revisions 1 through 4.

The second upgrade intentionally uses `broken-tag-does-not-exist`. The new Pod reaches `ImagePullBackOff`; rollback to revision 2 restores three production replicas. The script verifies `ENVIRONMENT=production` before uninstalling the release.
