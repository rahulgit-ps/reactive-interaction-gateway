# Kubernetes

`rig_dns.yml` is an example configuration file for Kubernetes, configured to run RIG in distributed mode.

## Configuration

### Docker image

You can use your own Docker image if it's based on original RIG Docker image.

```yaml
image: accenture/reactive-interaction-gateway
```

### NODE_HOST

IP used to set Node host for each node. Automatically taken from Kubernetes Pod configuration.

```yaml
- name: NODE_HOST
  valueFrom:
    fieldRef:
      fieldPath: status.podIP
```

### DNS_NAME

Address upon which RIG will do DNS discovery. This has to point to Kubernetes headless service. `default` is namespaces where RIG runs.

```yaml
- name: DNS_NAME
  value: "reactive-interaction-gateway-service-headless.default.svc.cluster.local"
```

### Additional Configuration

When running in distributed mode, additional variables may be passed to the deployment in order to run the proper configuration. Updates to the kubernetes deployment can be made in ```rig_dns.yaml```
Changes to these variables are required in most production circumstances.

For more information on configuration variables, please view the [Operator's Guide to the RIG](https://accenture.github.io/reactive-interaction-gateway/docs/rig-ops-guide.html)

## Running locally with Minikube

If you want to use local image (either original RIG or your own based on original RIG):

1. Switch to Minikube context `eval $(minikube docker-env)`
1. Build your image `docker build -t rig .`
1. Check `docker images` => new image should be listed there
1. Change the image name to `rig` in the `rig_dns.yml` (line 74)
1. Add `imagePullPolicy: Never` just below the `image` line, so K8s won't try to pull the official image

Start RIG in Minikube:

1. `kubectl apply -f deployment/k8s/rig_dns.yml` (assuming you are in root directory)
1. `kubectl get po` should list running RIG app

**Note:** Other services should communicate with `reactive-interaction-gateway-service` which is reachable within Kubernetes cluster (but not outside of server) on port 4000 (by default). This service will load balance requests amongst replicas.

## Scaling

### Dashboard

1. Go to Kubernetes dashboard. (If you are on localhost run `minikube dashboard`)
1. Go to Deployments
1. Click 3 dots on the right side for RIG deployment
1. Select scale
1. Choose given number and press OK
1. `kubectl get po` should list new pods automatically connected to RIG cluster (and it should be also visible in dashboard)

### Command

1. Run `kubectl scale --replicas=number_of_replicas -f deployment/k8s/rig_dns.yml` (assuming you are in root directory)
1. `kubectl get po` should list new pods automatically connected to RIG cluster

You can also inspect logs of pods to see how they automatically rebalance Kafka consumers (if you are using Kafka) and adapt Proxy APIs from other nodes.
