# Simple cloud connector container for vulnerability scanning

This simply polls a queue and takes messages off which it then triggers a job.

## How to build the container

```sh
# Build
docker buildx build -f Dockerfile -t cloudconnector .

# Tag
image_id=
image_tag=
docker tag ${image_id} aaroneast1/cloudconnector:${image_tag}

# Publish
docker push aaroneast1/cloudconnector:${image_tag}

# Run container
docker run -e AWS_ACCESS_KEY_ID=${value} -e AWS_SECRET_ACCESS_KEY=${value}  -e AWS_DEFAULT_REGION="${value} " -e REGION="${value} " -e ACCOUNT_ID="${value} " -e SQS_QUEUE_NAME="${value} " -e CODEBUILD_PROJECT_NAME="${value} " cloudconnector:latest
# Run container interactive
docker run -it cloudconnector:latest /bin/sh
```

## Sample message

```json
{
    "Messages": [
        {
            "MessageId": "2630668f-6752-4e9d-90f0-941af8af4f35",
            "ReceiptHandle": "AQEB6qReJx7K1H+9T1Vs4hVm5PuV3GK+EU9BFUK2sHETUhvqf0vozNqBiWxgs5hTFAJfWgIf1FY7jikvwGACCtc0t4p2Tqo9985s4ndlYBc2M0aUJzfZiyZIzynroSnOYbnxVpUWQ1IUnRLXxjzzbMdA7JLto5LZP0pOag94471GmpbNzPIF/b83sGck0ZK/n6SyvbUz85PUlPfgQqKxSXE2witXGfMz77JtTp1j2KDKU6c7ST8tpF3ndU6G3y0DesS6Y/7MzkcqR/1Z/T9r69WTprUMr7cIoT5oC84oE/rGctI4K4VaUmQnTNeXp69J6wDaVeSdxAEzNo2m6kDZ/wVSO7mD106AVxMBW9F1JbUCKcAmKGtNiVWISaJjSYIm5C0mcqKaIzACZqCXf4z/H/Q2aA==",
            "MD5OfBody": "00342b3b17659ae180d32f69f937d7ac",
            "Body": "{\"version\":\"0\",\"id\":\"80c8d58b-dd98-ea69-0801-c469f50c6cab\",\"detail-type\":\"ECR Image Action\",\"source\":\"aws.ecr\",\"account\":\"123456789000\",\"time\":\"2023-05-17T14:23:59Z\",\"region\":\"eu-central-1\",\"resources\":[],\"detail\":{\"result\":\"SUCCESS\",\"repository-name\":\"node\",\"image-digest\":\"sha256:edec877779e61fd11f29fa067e3667ab15ed317b13a1112f804003a4e52e45c0\",\"action-type\":\"PUSH\",\"artifact-media-type\":\"application/vnd.docker.container.image.v1+json\",\"image-tag\":\"17-bullseye-slim\",\"manifest-media-type\":\"application/vnd.docker.distribution.manifest.v2+json\"}}"
        }
    ]
}
```
