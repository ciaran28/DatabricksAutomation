roleNames=$( az role definition list )
Bool_Contains_DBX_Custom_Role_Exists=$( jq -r  ' [ .[].roleName | contains("DBX_Custom_Role_DSToolkit") ] | any ' <<< "$roleNames" )

echo "Does Custom Role Exist: $Bool_Contains_DBX_Custom_Role_Exists "

if [ $Bool_Contains_DBX_Custom_Role_Exists == false ]; then
    echo "Is it..."
    cd .github/workflows/RBAC_Role_Definition
    ls

    # Note the use of the single quotes around param_SubscriptionId below. This is necessary to esacape the initial single quote, thereby recognising param_SubscriptionID as a variable and not string literal
    updateJson=$(jq -r --arg param_SubscriptionId "$param_SubscriptionId" ' .assignableScopes[0] = "/subscriptions/'$param_SubscriptionId'" ' DBX_Custom_Role.json) && echo -E "${updateJson}" > DBX_Custom_Role.json
    updateJson=$(echo $updateJson | jq -r )
    
    echo $updateJson
    
    az role definition create \
        --role-definition "$updateJson"
fi