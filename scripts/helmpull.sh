# !/bin/bash

## values
scriptpath=$(dirname $0)
cd $scriptpath

filename=data.json
scriptpath=`pwd`
chartspath="$scriptpath/charts"
filename="$scriptpath/$filename"
mainpath=`cd ..;pwd`

mkdir -p $chartspath
cd $chartspath


## repository
repo_keys=$(jq -r '.repo|keys[]' $filename)
IFS=$'\n' read -r -d '' -a repo_key_array <<< "$repo_keys"

for key in "${repo_key_array[@]}"; do
    value=$(jq -r --arg key "$key" '.repo[$key]' $filename)
    helm repo add $key $value
done

## charts
charts_keys=$(jq -r '.charts|keys[]' $filename)
IFS=$'\n' read -r -d '' -a charts_key_array <<< "$charts_keys"

for key in "${charts_key_array[@]}"; do
    value=$(jq -r --arg key "$key" '.charts[$key]' $filename)
    helm pull $value
done

## tar
for file in `ls $chartspath/*.tgz`; do
    echo $file
    tar zxvf $file -C $chartspath
    rm -f $file
done

## optional
cp -rf $chartspath/opentelemetry-collector $chartspath/opentelemetry-collector-statefulset
cp -rf $chartspath/opentelemetry-collector $chartspath/opentelemetry-collector-daemonset
rm -rf $chartspath/opentelemetry-collector

mv -f $chartspath $mainpath