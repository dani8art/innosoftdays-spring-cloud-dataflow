#!/bin/bash

## Installing and configuring spring-cloud-dataflow
scdf_namespace="default"
scdf_release_name="scdf"

if ! helm status "${scdf_release_name}" > /dev/null; then
    echo "Install bitnami/spring-cloud-dataflow scdf_release_name=${scdf_release_name} scdf_namespace=${scdf_namespace}"

    helm upgrade --wait -n "${scdf_namespace}" --install "${scdf_release_name}" bitnami/spring-cloud-dataflow \
        --set metrics.enabled=true \
        --set metrics.serviceMonitor.enabled=true \
        --set metrics.serviceMonitor.namespace="${prometheus_namespace}" \
        --set server.configuration.grafanaInfo="http://grafana:3000" > /dev/null
else
    echo "A release of bitnami/spring-cloud-dataflow, ${scdf_release_name}, is running on ${scdf_namespace} namespace"

    MARIADB_ROOT_PASSWORD=$(kubectl get secret --namespace "${scdf_namespace}" "${scdf_release_name}-mariadb" -o jsonpath="{.data.mariadb-root-password}" | base64 --decode)
    RABBITMQ_PASSWORD=$(kubectl get secret --namespace "${scdf_namespace}" "${scdf_release_name}-rabbitmq" -o jsonpath="{.data.rabbitmq-password}" | base64 --decode)
    RABBITMQ_ERLANG_COOKIE=$(kubectl get secret --namespace "${scdf_namespace}" "${scdf_release_name}-rabbitmq" -o jsonpath="{.data.rabbitmq-erlang-cookie}" | base64 --decode)

    helm upgrade --wait -n "${scdf_namespace}" --install "${scdf_release_name}" bitnami/spring-cloud-dataflow \
        --set mariadb.rootUser.password=$MARIADB_ROOT_PASSWORD \
        --set rabbitmq.auth.password=$RABBITMQ_PASSWORD \
        --set rabbitmq.auth.erlangCookie=$RABBITMQ_ERLANG_COOKIE \
        --set metrics.enabled=true \
        --set metrics.serviceMonitor.enabled=true \
        --set metrics.serviceMonitor.namespace="${prometheus_namespace}" \
        --set server.configuration.grafanaInfo="http://grafana:3000" > /dev/null
fi


echo ""
echo "### Stack succesfully deployed ###"
echo ""
echo "Connect to Data Flow"
echo "    $ helm status ${scdf_release_name}"

echo "Grafana password"
echo "    $ kubectl -n monitoring get secret graf-grafana-admin -o jsonpath={.data.GF_SECURITY_ADMIN_PASSWORD} | base64 --decode"

echo "Forward grafana"
echo "    $ kubectl port-forward -n monitoring svc/graf-grafana 3000:3000"
