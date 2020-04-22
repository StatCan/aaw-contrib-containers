
#!/usr/bin/env sh

# Compute pi.
#
# Input:
#     --output  Output bucket/folder
#     --params  Json containing integer "seed"
#
# Output:
#     in.json and out.json
#
#     out.json has as "result" field, which is 0 or 1, depending
#     on whether the random point is inside or outside the circle.
#
# Blair Drummond
#

while test -n "$1"; do
    case "$1" in
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


echo "MINIO: -> _${S3_ENDPOINT}_"
mc config host add daaas \
    "http://$S3_ENDPOINT" "$AWS_ACCESS_KEY_ID" "$AWS_SECRET_ACCESS_KEY"

echo mc cp -r /output "daaas/$OUTPUT"
mc cp -r /output "daaas/$OUTPUT"

echo "Done."
