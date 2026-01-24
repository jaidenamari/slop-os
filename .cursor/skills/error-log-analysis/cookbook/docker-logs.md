# Docker Logs Analysis Cookbook

Patterns for analyzing Docker container and orchestration logs.

## Accessing Docker Logs

### Single Container

```bash
# View logs
docker logs {container_name}

# Follow logs
docker logs -f {container_name}

# Last N lines
docker logs --tail 100 {container_name}

# Since timestamp
docker logs --since "2024-01-15T10:00:00" {container_name}

# With timestamps
docker logs -t {container_name}
```

### Docker Compose

```bash
# All services
docker compose logs

# Specific service
docker compose logs {service_name}

# Follow all
docker compose logs -f

# Last N lines per service
docker compose logs --tail 50
```

### Kubernetes

```bash
# Pod logs
kubectl logs {pod_name}

# Specific container in pod
kubectl logs {pod_name} -c {container_name}

# Previous instance (after restart)
kubectl logs {pod_name} --previous

# Follow
kubectl logs -f {pod_name}

# All pods with label
kubectl logs -l app=myapp
```

## Common Log Patterns

### Application Startup

```
# Successful startup
[2024-01-15 10:00:00] INFO: Server listening on port 3000
[2024-01-15 10:00:00] INFO: Connected to database
[2024-01-15 10:00:00] INFO: Application ready

# Failed startup
[2024-01-15 10:00:00] ERROR: Failed to connect to database
[2024-01-15 10:00:00] FATAL: Cannot start application
```

### Health Check Failures

```
# Container unhealthy
healthcheck: unhealthy
HEALTHCHECK failed: curl -f http://localhost:3000/health

# Kubernetes probe failures
Liveness probe failed: HTTP probe failed with statuscode: 503
Readiness probe failed: connection refused
```

### Resource Issues

```
# OOMKilled
State: OOMKilled
Exit Code: 137

# CPU throttling (Kubernetes)
Container was throttled for 5.234s
```

### Networking Issues

```
# DNS resolution
Could not resolve host: database.internal
getaddrinfo ENOTFOUND

# Connection refused
connect ECONNREFUSED 10.0.0.5:5432

# Timeout
ETIMEDOUT connecting to redis:6379
```

## Analysis Workflow

### Step 1: Check Container Status

```bash
# Docker
docker ps -a
docker inspect {container} --format='{{.State.Status}} {{.State.ExitCode}}'

# Docker Compose
docker compose ps

# Kubernetes
kubectl get pods
kubectl describe pod {pod_name}
```

### Step 2: Get Recent Logs

```bash
# Last 100 lines with timestamps
docker logs --tail 100 -t {container}

# Errors only (if structured logging)
docker logs {container} 2>&1 | grep -i error
```

### Step 3: Check Events (Kubernetes)

```bash
# Pod events
kubectl describe pod {pod_name}

# Cluster events
kubectl get events --sort-by='.lastTimestamp'

# Events for specific resource
kubectl get events --field-selector involvedObject.name={pod_name}
```

### Step 4: Resource Analysis

```bash
# Docker stats
docker stats {container}

# Kubernetes resource usage
kubectl top pod {pod_name}
kubectl top node

# Resource limits
kubectl describe pod {pod_name} | grep -A5 "Limits\|Requests"
```

### Step 5: Compare with Working State

```bash
# Check if image changed
docker inspect {container} --format='{{.Config.Image}}'

# Check environment variables
docker inspect {container} --format='{{.Config.Env}}'

# Kubernetes configmaps/secrets
kubectl get configmap {name} -o yaml
```

## Common Docker Issues

### Container Exits Immediately

```bash
# Check exit code
docker inspect {container} --format='{{.State.ExitCode}}'

# Exit codes:
# 0   - Normal exit
# 1   - Application error
# 137 - OOMKilled or SIGKILL
# 139 - Segmentation fault
# 143 - SIGTERM

# Check what CMD/ENTRYPOINT runs
docker inspect {container} --format='{{.Config.Cmd}} {{.Config.Entrypoint}}'
```

### OOMKilled (Exit 137)

```bash
# Check memory limit
docker inspect {container} --format='{{.HostConfig.Memory}}'

# Increase memory or fix memory leak
docker run -m 2g {image}
```

### Permission Denied

```
Error: EACCES: permission denied, open '/app/data/file.txt'
```

Check:
- Volume mount permissions
- User in container vs host
- SELinux/AppArmor policies

### Cannot Connect to Other Services

```bash
# Check network
docker network ls
docker network inspect {network}

# Check service discovery
docker exec {container} nslookup {service_name}
docker exec {container} ping {service_name}

# Kubernetes
kubectl exec {pod} -- nslookup {service_name}
```

## Kubernetes-Specific Issues

### Pod Pending

```bash
kubectl describe pod {pod_name}

# Common reasons:
# - Insufficient resources
# - Node selector/affinity not matching
# - PVC not bound
# - Image pull error
```

### CrashLoopBackOff

```bash
# Check previous logs
kubectl logs {pod_name} --previous

# Check restart count
kubectl get pod {pod_name} -o jsonpath='{.status.containerStatuses[0].restartCount}'

# Usually:
# - Application crash on startup
# - Missing config/secrets
# - Failing health checks
```

### ImagePullBackOff

```bash
kubectl describe pod {pod_name}

# Check:
# - Image name/tag exists
# - Registry credentials (imagePullSecrets)
# - Network access to registry
```

## Log Aggregation

If using centralized logging:

### Loki/Grafana

```
# Query example
{container="myapp"} |= "error"
{namespace="production"} | json | level="error"
```

### ELK Stack

```
# Kibana query
container.name: "myapp" AND level: "error"
kubernetes.pod_name: "myapp-*" AND message: *exception*
```

### CloudWatch (AWS)

```
# Log Insights query
fields @timestamp, @message
| filter @message like /error/i
| sort @timestamp desc
| limit 100
```

## Output Template

```markdown
## Docker/Container Log Analysis

### Container Info
- **Name**: {container/pod name}
- **Image**: {image:tag}
- **Status**: {running/exited/crashed}
- **Exit Code**: {code if applicable}
- **Restarts**: {count}

### Events Timeline
| Time | Event |
|------|-------|
| {timestamp} | {event description} |

### Error Logs
```
{relevant error logs}
```

### Resource Status
- Memory: {usage} / {limit}
- CPU: {usage} / {limit}
- Disk: {relevant if applicable}

### Root Cause
{Analysis of what caused the issue}

### Resolution
1. {Immediate fix}
2. {Configuration change}
3. {Prevention measure}

### Commands Used
```bash
{diagnostic commands that were helpful}
```
```

## Prevention Checklist

- [ ] Proper resource limits set
- [ ] Health checks configured
- [ ] Graceful shutdown handling
- [ ] Log rotation configured
- [ ] Alerts on container restarts
- [ ] Image versioning (not :latest in prod)
