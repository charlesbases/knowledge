#!/usr/bin/env bash

set -e

version_argocd=v2.3.17
version_tekton_pipeline=v0.46.0
version_tekton_dashboard=v0.34.0

files=(
# tekton-pipeline
"https://storage.googleapis.com/tekton-releases/pipeline/previous/$version_tekton_pipeline/release.yaml tekton.yaml"
# tekton-dashboard
"https://github.com/tektoncd/dashboard/releases/download/$version_tekton_dashboard/release.yaml tekton.yaml"
# argocd
"https://raw.githubusercontent.com/argoproj/argo-cd/$version_argocd/manifests/install.yaml argocd.yaml"
)

> argocd.yaml
> tekton.yaml

for (( i = 0; i < ${#files[@]}; i++ )); do
  args=(${files[i]})

  wget -O - ${args[0]} >> ${args[1]}
done

# argocd
cat argocd-custom.yaml >> argocd.yaml

# rekton
cat tekton-custom.yaml >> tekton.yaml