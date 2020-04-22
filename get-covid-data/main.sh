#!/usr/bin/env sh

# Input:
#     --output  Output bucket/folder
#     --params  Json containing integer "seed"
#

# Get the source
git clone --depth=1 \
    https://github.com/kennethchu-statcan/covid19/ \
    /tmp/covid19 || exit 1
mv /tmp/covid19/005-test-kubeflow/pipeline-test/image-loadData/src /src



while test -n "$1"; do
    case "$1" in
        --data)
            shift
            DATA="$1"
            ;;

        --output)
            shift
            OUTPUT="$1"
            ;;

        --params)
            shift
            JSON="$1"
            ;;

        *)
            echo "Invalid option $1; allowed: --params --options" >&2
            exit 1
            ;;
    esac
    shift
done


#########################
###  Fetch the Data  ####
#########################
echo "MINIO: -> _${S3_ENDPOINT}_"
mc config host add daaas \
    "http://$S3_ENDPOINT" "$AWS_ACCESS_KEY_ID" "$AWS_SECRET_ACCESS_KEY"

echo mc cp -r "daaas/$DATA" /data
mc cp -r "daaas/$DATA" /data


echo "Input: "
echo "$JSON" | jq '.' | tee /output/in.json

#############
# This is where the single-run modelling R command can go ... ?
#############

mkdir -p /output

  dataDIR=/data
  codeDIR=/src
outputDIR=/output

 myRscript=${codeDIR}/main.R
stdoutFile=${outputDIR}/stdout.R.`basename ${myRscript} .R`
stderrFile=${outputDIR}/stderr.R.`basename ${myRscript} .R`
R --no-save --args ${dataDIR} ${codeDIR} ${outputDIR} < ${myRscript} > ${stdoutFile} 2> ${stderrFile}

#############
#############


echo mc cp -r /output "daaas/$OUTPUT"
mc cp -r /output "daaas/$OUTPUT"

echo "Done."
