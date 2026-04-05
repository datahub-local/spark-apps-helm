{{- define "spark-apps.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "spark-apps.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{- define "spark-apps.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "spark-apps.scriptsConfigMapName" -}}
{{- default (printf "%s-scripts" (include "spark-apps.fullname" .)) .Values.scripts.configMapName -}}
{{- end -}}

{{- define "spark-apps.serviceAccountName" -}}
{{- if .Values.serviceAccount.name -}}
{{- .Values.serviceAccount.name -}}
{{- else -}}
{{- include "spark-apps.fullname" . -}}
{{- end -}}
{{- end -}}

{{- define "spark-apps.serviceAccountRoleName" -}}
{{- printf "%s-role" (include "spark-apps.serviceAccountName" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "spark-apps.serviceAccountRoleBindingName" -}}
{{- printf "%s-binding" (include "spark-apps.serviceAccountName" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "spark-apps.sharedConfigMapName" -}}
{{- $root := index . "root" -}}
{{- $index := index . "index" -}}
{{- $config := index . "config" -}}
{{- coalesce $config.name (printf "%s-config-%d" (include "spark-apps.fullname" $root) $index) -}}
{{- end -}}

{{- define "spark-apps.sharedSecretName" -}}
{{- $root := index . "root" -}}
{{- $index := index . "index" -}}
{{- $secret := index . "secret" -}}
{{- coalesce $secret.name (printf "%s-secret-%d" (include "spark-apps.fullname" $root) $index) -}}
{{- end -}}

{{- define "spark-apps.labels" -}}
helm.sh/chart: {{ include "spark-apps.chart" . }}
app.kubernetes.io/name: {{ include "spark-apps.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{- define "spark-apps.sparkVersion" -}}
{{- default .Chart.AppVersion .Values.spark.sparkVersion -}}
{{- end -}}

{{- define "spark-apps.sparkImage" -}}
{{- $sparkVersion := include "spark-apps.sparkVersion" . -}}
{{- $tag := default $sparkVersion .Values.spark.tag -}}
{{- printf "%s:%s" .Values.spark.image $tag -}}
{{- end -}}

{{- define "spark-apps.sparkPullPolicy" -}}
{{- default "IfNotPresent" .Values.spark.pullPolicy -}}
{{- end -}}
