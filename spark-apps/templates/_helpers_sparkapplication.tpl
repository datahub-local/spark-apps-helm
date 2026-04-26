{{- define "spark-apps.sparkApplicationSpec" -}}
{{- $root := index . "root" -}}
{{- $app := index . "app" -}}
{{- $sparkVersion := index . "sparkVersion" -}}
{{- $sparkImage := index . "sparkImage" -}}
{{- $sparkPullPolicy := index . "sparkPullPolicy" -}}
{{- $selectedConfigRefs := index . "selectedConfigRefs" -}}
{{- $selectedSecretRefs := index . "selectedSecretRefs" -}}
{{- $selectAllConfigs := index . "selectAllConfigs" -}}
{{- $selectAllSecrets := index . "selectAllSecrets" -}}
{{- $hasAutoVolumes := index . "hasAutoVolumes" -}}
{{- $hasDriverAutoEnvFrom := index . "hasDriverAutoEnvFrom" -}}
{{- $hasExecutorAutoEnvFrom := index . "hasExecutorAutoEnvFrom" -}}
{{- $hasDriverAutoVolumeMounts := index . "hasDriverAutoVolumeMounts" -}}
{{- $hasExecutorAutoVolumeMounts := index . "hasExecutorAutoVolumeMounts" -}}
{{- $renderSuspend := index . "renderSuspend" -}}
{{- if and $renderSuspend (hasKey $app "suspend") }}
suspend: {{ $app.suspend }}
{{- else if and $renderSuspend (not (hasKey $app "suspend")) }}
suspend: true
{{- end }}
type: {{ $app.type }}
mode: {{ $app.mode }}
sparkVersion: {{ $sparkVersion | quote }}
image: {{ $sparkImage | quote }}
imagePullPolicy: {{ $sparkPullPolicy }}
mainApplicationFile: {{ $app.mainApplicationFile | quote }}
{{- with $root.Values.spark.pullSecrets }}
imagePullSecrets:
  {{- range $imagePullSecret := . }}
  - {{ if kindIs "map" $imagePullSecret }}{{ required "spark.pullSecrets[].name is required when using object entries" $imagePullSecret.name | quote }}{{ else }}{{ $imagePullSecret | quote }}{{ end }}
  {{- end }}
{{- end }}
{{- with $app.mainClass }}
mainClass: {{ . | quote }}
{{- end }}
{{- with $app.arguments }}
arguments:
  {{- toYaml . | nindent 2 }}
{{- end }}
{{- with $app.sparkConf }}
sparkConf:
  {{- toYaml . | nindent 2 }}
{{- end }}
{{- with $app.hadoopConf }}
hadoopConf:
  {{- toYaml . | nindent 2 }}
{{- end }}
{{- if or $app.volumes $hasAutoVolumes }}
volumes:
  {{- with $app.volumes }}
  {{- toYaml . | nindent 2 }}
  {{- end }}
  {{- if $root.Values.scripts.enabled }}
  - name: spark-scripts
    configMap:
      name: {{ include "spark-apps.scriptsConfigMapName" $root }}
      defaultMode: {{ $root.Values.scripts.defaultMode }}
  {{- end }}
  {{- range $configIndex, $config := $root.Values.sharedConfigMaps }}
  {{- $configRefKey := coalesce $config.id $config.name (printf "%s-config-%d" (include "spark-apps.fullname" $root) $configIndex) -}}
  {{- $configEnabled := or (not (hasKey $config "enabled")) $config.enabled -}}
  {{- if and (or $selectAllConfigs (has $configRefKey $selectedConfigRefs)) $configEnabled $config.mountPath }}
  - name: {{ default (printf "shared-config-%d" $configIndex) $config.volumeName }}
    configMap:
      name: {{ include "spark-apps.sharedConfigMapName" (dict "root" $root "index" $configIndex "config" $config) }}
      {{- with $config.items }}
      items:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- if hasKey $config "optional" }}
      optional: {{ $config.optional }}
      {{- end }}
  {{- end }}
  {{- end }}
  {{- range $secretIndex, $secret := $root.Values.sharedSecrets }}
  {{- $secretRefKey := coalesce $secret.id $secret.name (printf "%s-secret-%d" (include "spark-apps.fullname" $root) $secretIndex) -}}
  {{- $secretEnabled := or (not (hasKey $secret "enabled")) $secret.enabled -}}
  {{- if and (or $selectAllSecrets (has $secretRefKey $selectedSecretRefs)) $secretEnabled $secret.mountPath }}
  - name: {{ default (printf "shared-secret-%d" $secretIndex) $secret.volumeName }}
    secret:
      secretName: {{ include "spark-apps.sharedSecretName" (dict "root" $root "index" $secretIndex "secret" $secret) }}
      {{- with $secret.items }}
      items:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- if hasKey $secret "optional" }}
      optional: {{ $secret.optional }}
      {{- end }}
  {{- end }}
  {{- end }}
{{- end }}
{{- with $app.deps }}
deps:
  {{- toYaml . | nindent 2 }}
{{- end }}
{{- with $app.restartPolicy }}
restartPolicy:
  {{- toYaml . | nindent 2 }}
{{- end }}
{{- with $app.monitoring }}
monitoring:
  {{- toYaml . | nindent 2 }}
{{- end }}
{{- with $app.batchScheduler }}
batchScheduler: {{ . }}
{{- end }}
{{- with $app.timeToLiveSeconds }}
timeToLiveSeconds: {{ . }}
{{- end }}
{{- with $app.pythonVersion }}
pythonVersion: {{ . | quote }}
{{- end }}
{{- with $app.proxyUser }}
proxyUser: {{ . | quote }}
{{- end }}
{{- with $app.sparkConfigMap }}
sparkConfigMap: {{ . | quote }}
{{- end }}
{{- with $app.hadoopConfigMap }}
hadoopConfigMap: {{ . | quote }}
{{- end }}
{{- with $app.memoryOverheadFactor }}
memoryOverheadFactor: {{ . | quote }}
{{- end }}
{{- with $app.batchSchedulerOptions }}
batchSchedulerOptions:
  {{- toYaml . | nindent 2 }}
{{- end }}
{{- with $app.sparkUIOptions }}
sparkUIOptions:
  {{- toYaml . | nindent 2 }}
{{- end }}
{{- with $app.driverIngressOptions }}
driverIngressOptions:
  {{- toYaml . | nindent 2 }}
{{- end }}
{{- with $app.dynamicAllocation }}
dynamicAllocation:
  {{- toYaml . | nindent 2 }}
{{- end }}
{{- with $app.nodeSelector }}
nodeSelector:
  {{- toYaml . | nindent 2 }}
{{- end }}
{{- with $app.tolerations }}
tolerations:
  {{- toYaml . | nindent 2 }}
{{- end }}
{{- with $app.affinity }}
affinity:
  {{- toYaml . | nindent 2 }}
{{- end }}
driver:
  cores: {{ $app.driver.cores }}
  {{- with $app.driver.coreLimit }}
  coreLimit: {{ . | quote }}
  {{- end }}
  memory: {{ $app.driver.memory | quote }}
  {{- with $app.driver.coreRequest }}
  coreRequest: {{ . | quote }}
  {{- end }}
  {{- with $app.driver.memoryLimit }}
  memoryLimit: {{ . | quote }}
  {{- end }}
  {{- with $app.driver.memoryOverhead }}
  memoryOverhead: {{ . | quote }}
  {{- end }}
  {{- with $app.driver.javaOptions }}
  javaOptions: {{ . | quote }}
  {{- end }}
  {{- with $app.driver.kubernetesMaster }}
  kubernetesMaster: {{ . | quote }}
  {{- end }}
  serviceAccount: {{ default (include "spark-apps.serviceAccountName" $root) $app.driver.serviceAccount }}
  {{- with $app.driver.serviceAnnotations }}
  serviceAnnotations:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- with $app.driver.serviceLabels }}
  serviceLabels:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- with $app.driver.ports }}
  ports:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- with $app.driver.priorityClassName }}
  priorityClassName: {{ . | quote }}
  {{- end }}
  {{- with $app.driver.labels }}
  labels:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- with $app.driver.annotations }}
  annotations:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- with $app.driver.image }}
  image: {{ . | quote }}
  {{- end }}
  {{- with $app.driver.gpu }}
  gpu:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- with $app.driver.env }}
  env:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- if or $app.driver.envFrom $hasDriverAutoEnvFrom }}
  envFrom:
    {{- with $app.driver.envFrom }}
    {{- toYaml . | nindent 4 }}
    {{- end }}
    {{- range $configIndex, $config := $root.Values.sharedConfigMaps }}
    {{- $configRefKey := coalesce $config.id $config.name (printf "%s-config-%d" (include "spark-apps.fullname" $root) $configIndex) -}}
    {{- $configEnabled := or (not (hasKey $config "enabled")) $config.enabled -}}
    {{- if and (or $selectAllConfigs (has $configRefKey $selectedConfigRefs)) $configEnabled $config.envFrom (or (not (hasKey $config "attachToDriver")) $config.attachToDriver) }}
    {{- $configRef := dict "name" (include "spark-apps.sharedConfigMapName" (dict "root" $root "index" $configIndex "config" $config)) }}
    {{- if hasKey $config "optional" }}{{- $_ := set $configRef "optional" $config.optional -}}{{- end }}
    - configMapRef:
{{- toYaml $configRef | nindent 8 }}
    {{- end }}
    {{- end }}
    {{- range $secretIndex, $secret := $root.Values.sharedSecrets }}
    {{- $secretRefKey := coalesce $secret.id $secret.name (printf "%s-secret-%d" (include "spark-apps.fullname" $root) $secretIndex) -}}
    {{- $secretEnabled := or (not (hasKey $secret "enabled")) $secret.enabled -}}
    {{- if and (or $selectAllSecrets (has $secretRefKey $selectedSecretRefs)) $secretEnabled $secret.envFrom (or (not (hasKey $secret "attachToDriver")) $secret.attachToDriver) }}
    {{- $secretRef := dict "name" (include "spark-apps.sharedSecretName" (dict "root" $root "index" $secretIndex "secret" $secret)) }}
    {{- if hasKey $secret "optional" }}{{- $_ := set $secretRef "optional" $secret.optional -}}{{- end }}
    - secretRef:
{{- toYaml $secretRef | nindent 8 }}
    {{- end }}
    {{- end }}
  {{- end }}
  {{- if or $app.driver.volumeMounts $hasDriverAutoVolumeMounts }}
  volumeMounts:
    {{- with $app.driver.volumeMounts }}
    {{- toYaml . | nindent 4 }}
    {{- end }}
    {{- if $root.Values.scripts.enabled }}
    - name: spark-scripts
      mountPath: {{ $root.Values.scripts.mountPath | quote }}
      readOnly: true
    {{- end }}
    {{- range $configIndex, $config := $root.Values.sharedConfigMaps }}
    {{- $configRefKey := coalesce $config.id $config.name (printf "%s-config-%d" (include "spark-apps.fullname" $root) $configIndex) -}}
    {{- $configEnabled := or (not (hasKey $config "enabled")) $config.enabled -}}
    {{- if and (or $selectAllConfigs (has $configRefKey $selectedConfigRefs)) $configEnabled $config.mountPath (or (not (hasKey $config "attachToDriver")) $config.attachToDriver) }}
    - name: {{ default (printf "shared-config-%d" $configIndex) $config.volumeName }}
      mountPath: {{ $config.mountPath | quote }}
      readOnly: true
    {{- end }}
    {{- end }}
    {{- range $secretIndex, $secret := $root.Values.sharedSecrets }}
    {{- $secretRefKey := coalesce $secret.id $secret.name (printf "%s-secret-%d" (include "spark-apps.fullname" $root) $secretIndex) -}}
    {{- $secretEnabled := or (not (hasKey $secret "enabled")) $secret.enabled -}}
    {{- if and (or $selectAllSecrets (has $secretRefKey $selectedSecretRefs)) $secretEnabled $secret.mountPath (or (not (hasKey $secret "attachToDriver")) $secret.attachToDriver) }}
    - name: {{ default (printf "shared-secret-%d" $secretIndex) $secret.volumeName }}
      mountPath: {{ $secret.mountPath | quote }}
      readOnly: true
    {{- end }}
    {{- end }}
  {{- end }}
  {{- with $app.driver.configMaps }}
  configMaps:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- with $app.driver.secrets }}
  secrets:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- with $app.driver.affinity }}
  affinity:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- with $app.driver.tolerations }}
  tolerations:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- with $app.driver.podSecurityContext }}
  podSecurityContext:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- with $app.driver.securityContext }}
  securityContext:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- with $app.driver.schedulerName }}
  schedulerName: {{ . | quote }}
  {{- end }}
  {{- with $app.driver.sidecars }}
  sidecars:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- with $app.driver.initContainers }}
  initContainers:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- with $app.driver.dnsConfig }}
  dnsConfig:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- with $app.driver.terminationGracePeriodSeconds }}
  terminationGracePeriodSeconds: {{ . }}
  {{- end }}
  {{- with $app.driver.hostAliases }}
  hostAliases:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- if hasKey $app.driver "hostNetwork" }}
  hostNetwork: {{ $app.driver.hostNetwork }}
  {{- end }}
  {{- if hasKey $app.driver "shareProcessNamespace" }}
  shareProcessNamespace: {{ $app.driver.shareProcessNamespace }}
  {{- end }}
  {{- with $app.driver.template }}
  template:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- with $app.driver.lifecycle }}
  lifecycle:
    {{- toYaml . | nindent 4 }}
  {{- end }}
executor:
  instances: {{ $app.executor.instances }}
  cores: {{ $app.executor.cores }}
  memory: {{ $app.executor.memory | quote }}
  {{- with $app.executor.coreRequest }}
  coreRequest: {{ . | quote }}
  {{- end }}
  {{- with $app.executor.memoryLimit }}
  memoryLimit: {{ . | quote }}
  {{- end }}
  {{- with $app.executor.memoryOverhead }}
  memoryOverhead: {{ . | quote }}
  {{- end }}
  {{- with $app.executor.javaOptions }}
  javaOptions: {{ . | quote }}
  {{- end }}
  {{- with $app.executor.deleteOnTermination }}
  deleteOnTermination: {{ . }}
  {{- end }}
  {{- with $app.executor.ports }}
  ports:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- with $app.executor.priorityClassName }}
  priorityClassName: {{ . | quote }}
  {{- end }}
  {{- with $app.executor.labels }}
  labels:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- with $app.executor.annotations }}
  annotations:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- with $app.executor.image }}
  image: {{ . | quote }}
  {{- end }}
  {{- with $app.executor.gpu }}
  gpu:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- with $app.executor.env }}
  env:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- if or $app.executor.envFrom $hasExecutorAutoEnvFrom }}
  envFrom:
    {{- with $app.executor.envFrom }}
    {{- toYaml . | nindent 4 }}
    {{- end }}
    {{- range $configIndex, $config := $root.Values.sharedConfigMaps }}
    {{- $configRefKey := coalesce $config.id $config.name (printf "%s-config-%d" (include "spark-apps.fullname" $root) $configIndex) -}}
    {{- $configEnabled := or (not (hasKey $config "enabled")) $config.enabled -}}
    {{- if and (or $selectAllConfigs (has $configRefKey $selectedConfigRefs)) $configEnabled $config.envFrom (or (not (hasKey $config "attachToExecutor")) $config.attachToExecutor) }}
    {{- $configRef := dict "name" (include "spark-apps.sharedConfigMapName" (dict "root" $root "index" $configIndex "config" $config)) }}
    {{- if hasKey $config "optional" }}{{- $_ := set $configRef "optional" $config.optional -}}{{- end }}
    - configMapRef:
{{- toYaml $configRef | nindent 8 }}
    {{- end }}
    {{- end }}
    {{- range $secretIndex, $secret := $root.Values.sharedSecrets }}
    {{- $secretRefKey := coalesce $secret.id $secret.name (printf "%s-secret-%d" (include "spark-apps.fullname" $root) $secretIndex) -}}
    {{- $secretEnabled := or (not (hasKey $secret "enabled")) $secret.enabled -}}
    {{- if and (or $selectAllSecrets (has $secretRefKey $selectedSecretRefs)) $selectAllSecrets $secret.envFrom (or (not (hasKey $secret "attachToExecutor")) $secret.attachToExecutor) }}
    {{- $secretRef := dict "name" (include "spark-apps.sharedSecretName" (dict "root" $root "index" $secretIndex "secret" $secret)) }}
    {{- if hasKey $secret "optional" }}{{- $_ := set $secretRef "optional" $secret.optional -}}{{- end }}
    - secretRef:
{{- toYaml $secretRef | nindent 8 }}
    {{- end }}
    {{- end }}
  {{- end }}
  {{- if or $app.executor.volumeMounts $hasExecutorAutoVolumeMounts }}
  volumeMounts:
    {{- with $app.executor.volumeMounts }}
    {{- toYaml . | nindent 4 }}
    {{- end }}
    {{- if $root.Values.scripts.enabled }}
    - name: spark-scripts
      mountPath: {{ $root.Values.scripts.mountPath | quote }}
      readOnly: true
    {{- end }}
    {{- range $configIndex, $config := $root.Values.sharedConfigMaps }}
    {{- $configRefKey := coalesce $config.id $config.name (printf "%s-config-%d" (include "spark-apps.fullname" $root) $configIndex) -}}
    {{- $configEnabled := or (not (hasKey $config "enabled")) $config.enabled -}}
    {{- if and (or $selectAllConfigs (has $configRefKey $selectedConfigRefs)) $configEnabled $config.mountPath (or (not (hasKey $config "attachToExecutor")) $config.attachToExecutor) }}
    - name: {{ default (printf "shared-config-%d" $configIndex) $config.volumeName }}
      mountPath: {{ $config.mountPath | quote }}
      readOnly: true
    {{- end }}
    {{- end }}
    {{- range $secretIndex, $secret := $root.Values.sharedSecrets }}
    {{- $secretRefKey := coalesce $secret.id $secret.name (printf "%s-secret-%d" (include "spark-apps.fullname" $root) $secretIndex) -}}
    {{- $secretEnabled := or (not (hasKey $secret "enabled")) $secret.enabled -}}
    {{- if and (or $selectAllSecrets (has $secretRefKey $selectedSecretRefs)) $selectAllSecrets $secret.mountPath (or (not (hasKey $secret "attachToExecutor")) $secret.attachToExecutor) }}
    - name: {{ default (printf "shared-secret-%d" $secretIndex) $secret.volumeName }}
      mountPath: {{ $secret.mountPath | quote }}
      readOnly: true
    {{- end }}
    {{- end }}
  {{- end }}
  {{- with $app.executor.configMaps }}
  configMaps:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- with $app.executor.secrets }}
  secrets:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- with $app.executor.affinity }}
  affinity:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- with $app.executor.tolerations }}
  tolerations:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- with $app.executor.podSecurityContext }}
  podSecurityContext:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- with $app.executor.securityContext }}
  securityContext:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- with $app.executor.schedulerName }}
  schedulerName: {{ . | quote }}
  {{- end }}
  {{- with $app.executor.sidecars }}
  sidecars:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- with $app.executor.initContainers }}
  initContainers:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- if hasKey $app.executor "hostNetwork" }}
  hostNetwork: {{ $app.executor.hostNetwork }}
  {{- end }}
  {{- with $app.executor.dnsConfig }}
  dnsConfig:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- with $app.executor.terminationGracePeriodSeconds }}
  terminationGracePeriodSeconds: {{ . }}
  {{- end }}
  {{- with $app.executor.serviceAccount }}
  serviceAccount: {{ . | quote }}
  {{- end }}
  {{- with $app.executor.hostAliases }}
  hostAliases:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- if hasKey $app.executor "shareProcessNamespace" }}
  shareProcessNamespace: {{ $app.executor.shareProcessNamespace }}
  {{- end }}
  {{- with $app.executor.template }}
  template:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- with $app.executor.lifecycle }}
  lifecycle:
    {{- toYaml . | nindent 4 }}
  {{- end }}
{{- end -}}
