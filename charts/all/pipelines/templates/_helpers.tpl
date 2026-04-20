{{- define "pipelines.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "pipelines.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{- define "pipelines.labels" -}}
helm.sh/chart: {{ printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
app.kubernetes.io/name: {{ include "pipelines.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Returns the string "true" or "false".
- If klusterletAddon.enabled is a boolean, that value wins (manual override).
- Else: true when clusterGroup.applications.acm exists and is not disabled, OR
        clusterGroup.namespaces.open-cluster-management exists and is not disabled.
Pattern hub values (e.g. values-prod.yaml) merge clusterGroup into this chart.
*/}}
{{- define "pipelines.klusterletAddonEnabled" -}}
{{- if and .Values.klusterletAddon (hasKey .Values.klusterletAddon "enabled") (kindIs "bool" .Values.klusterletAddon.enabled) }}
{{- if .Values.klusterletAddon.enabled }}true{{- else }}false{{- end }}
{{- else }}
{{- $cg := default dict .Values.clusterGroup }}
{{- $apps := default dict $cg.applications }}
{{- $ns := default dict $cg.namespaces }}
{{- if or (and (hasKey $apps "acm") (not (default false (index $apps "acm" | default dict).disabled))) (and (hasKey $ns "open-cluster-management") (not (default false (index $ns "open-cluster-management" | default dict).disabled))) }}true{{- else }}false{{- end }}
{{- end }}
{{- end }}
