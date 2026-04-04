# spark-apps-helm

Helm chart repository for deploying SparkApplication resources with shared runtime defaults, packaged scripts, and shared ConfigMaps and Secrets.

## Getting Started

Clone the repository and use the chart from the `spark-apps/` directory:

```shell
git clone https://github.com/datahub-local/spark-apps-helm.git
cd spark-apps-helm
```

Install the Spark Operator before installing the chart. The local CI helpers do this automatically when you run `devbox run start_k8s`.

## :rocket: Deployment

To deploy the Helm Chart:

1. Add the Helm repository:

```shell
$ helm repo add garage-helm https://datahub-local.github.io/garage-helm
```

2. Install the release:

```shell
helm upgrade --install spark-apps ./spark-apps \
	--namespace spark-apps \
	--create-namespace \
	--values spark-apps/examples/values-example.yaml
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
