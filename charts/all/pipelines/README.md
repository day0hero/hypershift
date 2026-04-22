# cluster-pipelines

![Version: 0.0.2](https://img.shields.io/badge/Version-0.0.2-informational?style=flat-square)

A Helm chart that deploys cluster provisioning pipelines

This chart is used to serve as the template for Validated Patterns Charts

## Notable changes

### XRD dashboard image build (`build-xrd-dashboard-images`)

When `xrdDashboardBuild.enabled` is true (default), the chart installs:

- **Pipeline** `build-xrd-dashboard-images` — clones a Git repo, creates **ImageStreams** `gateway`, `frontend`, `query`, and `watch` in `xrdDashboardBuild.targetNamespace`, then **buildah**-builds and pushes each image to the integrated registry (`internalRegistry` / namespace / name : `imageTag`).
- **Tasks** `xrd-dashboard-git-clone`, `xrd-dashboard-create-imagestreams`, `xrd-dashboard-buildah-push`.
- **Role** in `xrd-dashboard` so the `provisioner` service account can create/update ImageStreams and push layers.

**Prerequisites**

1. Namespace `xrd-dashboard` must exist before this chart syncs the Role (same ordering as the `xrd-dashboard` application / pattern namespaces).
2. Buildah runs **privileged**; grant SCC once, for example:  
   `oc adm policy add-scc-to-user privileged -n cluster-provisioning -z provisioner`
3. Set `xrdDashboardBuild.gitUrl` in hub values (or pass `git-url` on the PipelineRun) to the repository that contains your `Dockerfile`s under the context dirs (defaults: `gateway/`, `frontend/`, `query/`, `watch/`).

**Start a build** (from the OpenShift console: Pipelines → `build-xrd-dashboard-images` → Start, or):

```yaml
apiVersion: tekton.dev/v1
kind: PipelineRun
metadata:
  generateName: build-xrd-dashboard-images-
  namespace: cluster-provisioning
spec:
  pipelineRef:
    name: build-xrd-dashboard-images
  serviceAccountName: provisioner
  params:
    - name: git-url
      value: https://github.com/yourorg/your-dashboard-repo.git
    - name: git-revision
      value: main
  workspaces:
    - name: source
      volumeClaimTemplate:
        spec:
          accessModes: [ReadWriteOnce]
          resources:
            requests:
              storage: 5Gi
```

Optional: set `xrdDashboardBuild.samplePipelineRun: true` and `xrdDashboardBuild.sampleGitUrl` to have Helm create a sample PipelineRun (usually leave off and start runs manually).

## Values

| Key                              | Type   | Default                                                                                  | Description |
| -------------------------------- | ------ | ---------------------------------------------------------------------------------------- | ----------- |
| awsCliImage                      | string | `"amazon/aws-cli:latest"`                                                                |             |
| externalSecrets.awsCreds.key     | string | `"secret/data/hub/aws"`                                                                  |             |
| externalSecrets.azureCreds.key   | string | `"secret/data/hub/azure"`                                                                |             |
| externalSecrets.gcpCreds.key     | string | `"secret/data/hub/gcp"`                                                                  |             |
| externalSecrets.pullSecret.key   | string | `"pushsecrets/global-pull-secret"`                                                       |             |
| externalSecrets.secretStore.kind | string | `"ClusterSecretStore"`                                                                   |             |
| externalSecrets.secretStore.name | string | `"vault-backend"`                                                                        |             |
| hcpImage                         | string | `"image-registry.openshift-image-registry.svc:5000/cluster-provisioning/hcp-cli:latest"` |             |
| hive.defaultControlPlaneReplicas | string | `"3"`                                                                                    |             |
| hive.defaultWorkerReplicas       | string | `"3"`                                                                                    |             |
| hypershift.baseDomain            | string | `""`                                                                                     |             |
| hypershift.defaultInstanceType   | string | `"m5.xlarge"`                                                                            |             |
| hypershift.defaultReplicas       | int    | `2`                                                                                      |             |
| pipelineNamespace                | string | `"cluster-provisioning"`                                                                 |             |
| serviceAccount.create            | bool   | `true`                                                                                   |             |
| serviceAccount.name              | string | `"provisioner"`                                                                          |             |
| serviceAccount.namespace         | string | `"cluster-provisioning"`                                                                 |             |
| toolsImage                       | string | `"image-registry.openshift-image-registry.svc:5000/openshift/tools"`                     |             |

---

Autogenerated from chart metadata using [helm-docs v1.14.2](https://github.com/norwoodj/helm-docs/releases/v1.14.2)
