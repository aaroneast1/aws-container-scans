#!/bin/bash

set -e

echo "Starting container"

su - sysdig

x=1
sleeptime=60

while [ $x -le 2 ]
do
  echo "Checking sqs queue every 5 mins"
  sqs_message_arr=$(aws sqs receive-message --queue-url "https://sqs.${REGION}.amazonaws.com/${ACCOUNT_ID}/${SQS_QUEUE_NAME}" --output json)

  echo "${sqs_message_arr}"

  if [ -n "$sqs_message_arr" ]; then
    echo "Messages found"
    sqs_message=$(echo "$sqs_message_arr" | jq -r '.Messages[0].Body' | jq '.')
    sqs_repo_name=$(echo "$sqs_message" | jq -r '.detail."repository-name"')
    sqs_imagetag=$(echo "$sqs_message" | jq -r '.detail."image-tag"')
    sqs_receipt_handle=$(echo "$sqs_message_arr" | jq -r '.Messages[0].ReceiptHandle')

    REPOSITORY="${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com/${sqs_repo_name}"
    VERSION="${sqs_imagetag}"

    codebuild_response_arr=$(aws codebuild start-build --region "${REGION}" --project-name "${CODEBUILD_PROJECT_NAME}" --out json --environment-variables-override "[{\"name\":\"REPOSITORY\",\"value\":\"${REPOSITORY}\",\"type\":\"PLAINTEXT\"},{\"name\":\"VERSION\",\"value\":\"${VERSION}\",\"type\":\"PLAINTEXT\"}]")
    echo "${codebuild_response_arr}"

    echo "sqs_receipt_handle=${sqs_receipt_handle}"
    aws sqs delete-message --queue-url "https://sqs.${REGION}.amazonaws.com/${ACCOUNT_ID}/${SQS_QUEUE_NAME}" --receipt-handle "${sqs_receipt_handle}"
    
    unset sqs_del_response_arr
    unset sqs_message
    unset sqs_repo_name
    unset sqs_imagetag
    unset sqs_receipt_handle
    unset REPOSITORY
    unset VERSION

  else
    echo "No messages found..."
  fi
  
  sleep $sleeptime
done
