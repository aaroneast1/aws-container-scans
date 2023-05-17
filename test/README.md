# Testing Sysdig Secure Cloud Connector

Two services have been enabled for container scanning ECS and ECR.

## How to test ECR scanning is being performed

### Login to ECR

```sh
export aws_account_id=
export region=

aws ecr get-login-password --region ${region} | docker login --username AWS --password-stdin ${aws_account_id}.dkr.ecr.${region}.amazonaws.com
```

### Pull down a container and publish it

```sh
export aws_account_id=
export region=
export image_id=
export image_name=
export image_tag=

docker pull ${image_name}:${image_tag}
docker tag ${image_id} ${aws_account_id}.dkr.ecr.${region}.amazonaws.com/${image_name}:${image_tag}
docker push ${aws_account_id}.dkr.ecr.${region}.amazonaws.com/${image_name}:${image_tag}

## Sample event message from sqs

```json
{
  "account": "123456789000",
  "detail": {
    "action-type": "PUSH",
    "image-digest": "sha256:3c949327e32569aff0c532905dcb9626892e4c9b109be08027bb1e44f7f96518",
    "image-tag": "20-alpine3.16",
    "repository-name": "node",
    "result": "SUCCESS",
    "manifest-media-type": "application/vnd.oci.image.manifest.v1+json",
    "artifact-media-type": "application/vnd.oci.image.config.v1+json"
  },
  "detail-type": "ECR Image Action",
  "id": "4f5ec4d5-4de4-7aad-a046-56d5cfe1df0e",
  "region": "eu-central-1",
  "resources": [],
  "source": "aws.ecr",
  "time": "2023-05-08T15:13:09Z",
  "version": "0"
}
```
