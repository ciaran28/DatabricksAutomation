## TO DO

# Ingest The Data From Parameter File
# Iterate Through Each Job
# Cluster Name for Each Job
# Generate The Cluster ID
# Notebook Path



LIST_CLUSTERS=$(curl -X GET -H "Authorization: Bearer $TOKEN" \
                    -H "X-Databricks-Azure-SP-Management-Token: $MGMT_ACCESS_TOKEN" \
                    -H "X-Databricks-Azure-Workspace-Resource-Id: $WORKSPACE_ID" \
                    -H 'Content-Type: application/json' \
                    https://$DATABRICKS_INSTANCE/api/2.0/clusters/list )


echo 'clusterID'
clusterId=$( jq -r  '.clusters[] | select( .cluster_name | contains("dbx-sp-cluster")) | .cluster_id ' <<< "$listClusters")
echo $clusterId
#"0609-130637-9rhcw0m1"


# Below - The Job ID has hypens 0609-130637-9rhcw0m1 and has issues when you pass it to the api below. It is PARAMOUNT to use double quoutes
# and single quote around the variable so that it evaluates correctly. 











createDatabricksJob=$(curl -X POST -H "Authorization: Bearer $token" -H "X-Databricks-Azure-SP-Management-Token: $mgmt_access_token" -H "X-Databricks-Azure-Workspace-Resource-Id: $wsId" -H 'Content-Type: application/json' -d \
'{
"name": "unittestjob",
"existing_cluster_id": "'$clusterId'" ,
"notebook_task": {"notebook_path": "/Users/ce79c2ef-170d-4f1c-a706-7814efb94898/unittest"}
}' https://$workspaceUrl/api/2.1/jobs/create )



listJobs=$(curl -X GET -H "Authorization: Bearer $token" -H "X-Databricks-Azure-SP-Management-Token: $mgmt_access_token" -H "X-Databricks-Azure-Workspace-Resource-Id: $wsId" -H 'Content-Type: application/json' https://$workspaceUrl/api/2.1/jobs/list )
echo 'List Jobs'
echo $listJobs

jobID=$( jq -r  '.jobs[] | select( .settings.name | contains("unittestjob")) | .job_id ' <<< "$listJobs")
#854685009836639
echo 'List JobID'
echo $jobID


runJob=$(curl -X POST -H "Authorization: Bearer $token" -H "X-Databricks-Azure-SP-Management-Token: $mgmt_access_token" -H "X-Databricks-Azure-Workspace-Resource-Id: $wsId" -H 'Content-Type: application/json' -d \
'{
"job_id": "'$jobID'"
}' https://$workspaceUrl/api/2.1/jobs/run-now )

echo 'List runJob'
echo $runJob

#echo 'Create Secret Scope'
#echo $createDatabricksJob 













