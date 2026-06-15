{{/*
─────────────────────────────────────────────────────────────────
  ShopWave Helm Helper Templates
─────────────────────────────────────────────────────────────────
*/}}

{{/* Chart name */}}
{{- define "shopwave.name" -}}
{{- .Chart.Name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/* Release-scoped full name */}}
{{- define "shopwave.fullname" -}}
{{- printf "%s-%s" .Release.Name .Chart.Name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/* Namespace from values */}}
{{- define "shopwave.namespace" -}}
{{- .Values.global.namespace }}
{{- end }}

{{/*
Common labels applied to every resource.
*/}}
{{- define "shopwave.labels" -}}
helm.sh/chart: {{ .Chart.Name }}-{{ .Chart.Version | replace "+" "_" }}
app.kubernetes.io/name: {{ include "shopwave.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels — used in matchLabels + Service selector.
Accepts a dict with "root" (.) and "component" (string).
Usage: {{ include "shopwave.selectorLabels" (dict "root" . "component" "backend") }}
*/}}
{{- define "shopwave.selectorLabels" -}}
app.kubernetes.io/name: {{ include "shopwave.name" .root }}
app.kubernetes.io/instance: {{ .root.Release.Name }}
app.kubernetes.io/component: {{ .component }}
{{- end }}

{{/*
MongoDB connection URI built from values.
*/}}
{{- define "shopwave.mongoUri" -}}
{{- printf "mongodb://mongo:27017/%s" .Values.mongo.database }}
{{- end }}
