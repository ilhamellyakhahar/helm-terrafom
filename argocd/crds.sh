#!/bin/sh
kubectl apply -f https://raw.githubusercontent.com/argoproj/argo-cd/refs/heads/master/manifests/crds/application-crd.yaml
kubectl apply -f https://raw.githubusercontent.com/argoproj/argo-cd/refs/heads/master/manifests/crds/applicationset-crd.yaml
kubectl apply -f https://raw.githubusercontent.com/argoproj/argo-cd/refs/heads/master/manifests/crds/appproject-crd.yaml

