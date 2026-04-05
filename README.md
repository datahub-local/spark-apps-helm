# spark-apps-helm

Helm chart repository for deploying SparkApplication resources with shared runtime defaults, packaged scripts, and shared ConfigMaps and Secrets.

## Getting Started

Install the Spark Operator before installing the chart. The local CI helpers do this automatically when you run `devbox run start_k8s`.

The chart is published as an OCI artifact in GHCR:

```shell
helm pull oci://ghcr.io/datahub-local/spark-apps/spark-apps --version 0.1.1 --untar
```

## :rocket: Deployment

To deploy the Helm Chart:

1. Install the release from GHCR:

```shell
helm upgrade --install spark-apps oci://ghcr.io/datahub-local/spark-apps/spark-apps \
	--version 0.1.1 \
	--namespace spark-apps \
	--create-namespace \
	--values my-values.yaml
```

2. If you want to start from the repository examples, clone the repo and copy one of the sample values files:

```shell
git clone https://github.com/datahub-local/spark-apps-helm.git
cd spark-apps-helm
cp spark-apps/examples/values-example.yaml my-values.yaml
```

For environment-specific overrides, start from one of the examples in `spark-apps/examples/` and keep a separate values file per environment.

## Development

The repository ships with `devbox` commands for local validation:

```shell
devbox run test_unit
devbox run lint
devbox run start_k8s
devbox run test_install
devbox run test_delete
devbox run stop_k8s
```

Chart-specific values and examples live in [spark-apps/README.md](spark-apps/README.md) and `spark-apps/examples/`.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for the project workflow and contribution guidelines.
