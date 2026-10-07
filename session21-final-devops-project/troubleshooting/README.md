# Failure recovery demonstration

Kartikey · 24bcs10121

Run `bash troubleshooting/run-challenge.sh` from the final-project directory on the disposable local helpdesk deployment. It records Pod descriptions, events, Service endpoints and logs, restores each fault, and finishes with an HTTP readiness check. Do not run it concurrently with the monitoring outage exercise.

| Fault | Diagnostic signal | Repair |
|---|---|---|
| Missing image tag | ImagePullBackOff and registry errors in Pod events | Restore the original image |
| Wrong Service selector | No matching EndpointSlice addresses despite running Pods | Match the backend Pod label |
| Wrong readiness path | HTTP 404 probe failures; new Pods remain unready | Restore `/ready` |

If Argo CD manages the deployment, temporarily pause automated synchronization before injecting faults. Otherwise self-healing will repair them before the diagnostics can be captured. Save and restore the existing policy:

```bash
POLICY_FILE=$(mktemp)
kubectl get application campus-helpdesk -n argocd -o json | python3 -c 'import json,sys; a=json.load(sys.stdin); print(json.dumps({"spec":{"syncPolicy":a["spec"]["syncPolicy"]}}))' > "$POLICY_FILE"
kubectl patch application campus-helpdesk -n argocd --type=merge -p '{"spec":{"syncPolicy":{"automated":null}}}'
bash troubleshooting/run-challenge.sh
# Always restore this policy, including after an interrupted exercise:
kubectl patch application campus-helpdesk -n argocd --type=merge --patch-file "$POLICY_FILE"
rm "$POLICY_FILE"
```

The script also registers an EXIT handler to restore the application image, selector and readiness path if a command fails. [Recorded output](../evidence/final-troubleshooting.txt) and [screenshot](../screenshots/final-troubleshooting.jpg) show the completed exercise.
