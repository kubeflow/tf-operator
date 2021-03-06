local params = std.extVar("__ksonnet/params").components.replica_restart_policy_never_v1;

local k = import "k.libsonnet";

local defaultTestImage = "gcr.io/kubeflow-images-staging/tf-operator-test-server:latest";

local parts(namespace, name, image) = {
  local actualImage = if image != "" then
    image
  else defaultTestImage,
  job:: {
    apiVersion: "kubeflow.org/v1",
    kind: "TFJob",
    metadata: {
      name: name,
      namespace: namespace,
    },
    spec: {
      tfReplicaSpecs: {
        PS: {
          replicas: 1,
          restartPolicy: "Never",
          template: {
            metadata: {
              annotations: {
                "sidecar.istio.io/inject": "false",
              },
            },
            spec: {
              containers: [
                {
                  name: "tensorflow",
                  image: actualImage,
                },
              ],
            },
          },
        },
        Worker: {
          replicas: 2,
          restartPolicy: "Never",
          template: {
            metadata: {
              annotations: {
                "sidecar.istio.io/inject": "false",
              },
            },
            spec: {
              containers: [
                {
                    name: "tensorflow",
                    image: actualImage,
                },
              ],
            },
          },
        },
      },
    },
  },
};

std.prune(k.core.v1.list.new([parts(params.namespace, params.name, params.image).job]))
