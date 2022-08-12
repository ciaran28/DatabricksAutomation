# The Script Will Ingest Parameters File In Order To Determine Location Of Setup.py Files.
# Each Setup.py Relates To The Creation Of A New Wheel File, Which Will Be Saved In 
# DBFS In A Folder Corresponding To The Cluster The Wheel File Is To Be Uploaded To. 


# TO DO : MUST MAKE THE WHEEL FILES DYNAMIC

echo "Import Wheel Dependencies"
python -m pip install --upgrade pip
python -m pip install flake8 pytest pyspark pytest-cov requests
pip3 install -r ./src/pipelines/dbkframework/requirements.txt
python -m pip install --user --upgrade setuptools wheel
sudo apt-get install pandoc


echo "Ingest JSON Environment File"
JSON=$( jq '.' .github/workflows/Pipeline_Param/$environment.json)
echo "${JSON}" | jq


for row in $(echo "${JSON}" | jq -r '.WheelFiles[] | @base64'); do
    _jq() {
        echo ${row} | base64 --decode | jq -r ${1}
    }

    wheel_cluster=$(_jq '.wheel_cluster')
    setup_py_file_path=$(_jq '.setup_py_file_path')
    
    echo "Wheel File Destined For Cluster: $wheel_cluster "
    echo "Location Of Setup.py File For Wheel File Creation; $setup_py_file_path"

    # Create The Wheel File
    python "$setup_py_file_path" sdist bdist_wheel

    cd dist 
    wheel_file_name=$( ls )
    echo "Wheel File Name: $wheel_file_name"

    # Install Wheel File
    #pip uninstall -y "$setup_py_file_path/dist/$wheel_file_name"
    #pip install -y "$setup_py_file_path/dist/$wheel_file_name"

    # Upoload Wheel File To DBFS Folder. Wheel File Will Be Stored In A Folder Relating To The Cluster
    # It Is To Be Deployed To

    databricks fs rm dbfs:/FileStore/$wheel_cluster/$wheel_file_name
    databricks fs cp "$setup_py_file_path/dist/$wheel_file_name" dbfs:/FileStore/dev/$wheel_file_name --overwrite

    # Remove Wheel File From DevOps Agent
    ls
    rm -f $wheel_file_name

    



done