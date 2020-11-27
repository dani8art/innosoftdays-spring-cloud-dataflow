#!/bin/bash

mongodb_release_name=mongodb
mongodb_namespace=default
database_name=innosoft-demo
database_username=innosoft-demo-user

if ! helm status -n "${mongodb_namespace}" "${mongodb_release_name}" > /dev/null; then
    echo "Install bitnami/mongodb mongodb_release_name=${mongodb_release_name} mongodb_namespace=${mongodb_namespace}"

    helm install --wait mongodb bitnami/mongodb \
        --set auth.database=${database_name} \
        --set auth.username=${database_username} \
        --set auth.password=rDWuDtGG7b
fi
echo "A release of  bitnami/mongodb, ${mongodb_release_name}, is running on ${mongodb_namespace} namespace"

echo "Mongodb password:  k get secrets mongodb -o=jsonpath='{.data.mongodb-password}' | base64 --decode"
