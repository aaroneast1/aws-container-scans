# Simple cloud connector container for vulnerability scanning

This simply polls a queue and takes messages off which it then triggers a job.

## How to build the container

```sh
# Build
docker buildx build -f Dockerfile -t cloudconnector .

# Tag
image_id=
image_tag=
repository=
docker tag ${image_id} ${repository}:${image_tag}

# Publish
docker push ${repository}:${image_tag}

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

```json
{
    "Messages": [
        {
            "MessageId": "e312a1c0-62c9-4fcd-8ff7-68e433821c6c",
            "ReceiptHandle": "AQEBkxTOL4GvoCQfzn66OhdS3JJbNd0IoKwS7kG4P3fLN6MRGEkCg/QzqAHqHzl56Z960LWKetYMVmiGh0DVLzxfo2n/KBX6kLldowlpdIbsbvHfoWQzPHMqXI8s5mGevSH4SAouvooJSRmqyBLYQ7I1pg1Xsus2kHxCl+070WXoxtBIPgJ3HQNsRWi8TFjiC6qu/HDMfU+KKEpFFFfAXlyX+uB2Dp/Zx1dgNnakoIYxb7NwoL1+VBqG/ju+d6F8wC+zwMr/yqjZLH5CzLZ0p6MdK/bnNVTV3b1vjWoGVNt086IYMNGdYCc8C8m8gu8gZeGCS/AHvhx1eCVr6CYM0B61ZdvTmq9SqpkJz5T1eDo3tZs4ueL/nSG1GK8BIIpFn2p8/mMbf8ZV0kdudG8fVWniJA==",
            "MD5OfBody": "5b0ddd2f958d49ebffe1940f4b6fee49",
            "Body": "{\"version\":\"0\",\"id\":\"1b6942a6-cd98-6448-c038-0c22636e3d53\",\"detail-type\":\"ECS Task State Change\",\"source\":\"aws.ecs\",\"account\":\"012345678900\",\"time\":\"2023-05-21T15:37:04Z\",\"region\":\"eu-central-1\",\"resources\":[\"arn:aws:ecs:eu-central-1:012345678900:task/scc-events-cluster/4ca7a4f90c6342e286b4e8bec7d9e4b6\"],\"detail\":{\"attachments\":[{\"id\":\"559a158e-a32a-4e9f-a8ab-5de14a26f7b8\",\"type\":\"eni\",\"status\":\"ATTACHED\",\"details\":[{\"name\":\"subnetId\",\"value\":\"subnet-039fe74af0bd92ce8\"},{\"name\":\"networkInterfaceId\",\"value\":\"eni-0db50053d31b6d2f4\"},{\"name\":\"macAddress\",\"value\":\"0a:df:4e:92:48:a4\"},{\"name\":\"privateDnsName\",\"value\":\"ip-10-0-3-202.eu-central-1.compute.internal\"},{\"name\":\"privateIPv4Address\",\"value\":\"10.0.3.202\"}]}],\"attributes\":[{\"name\":\"ecs.cpu-architecture\",\"value\":\"x86_64\"}],\"availabilityZone\":\"eu-central-1c\",\"clusterArn\":\"arn:aws:ecs:eu-central-1:012345678900:cluster/scc-events-cluster\",\"connectivity\":\"CONNECTED\",\"connectivityAt\":\"2023-05-21T15:36:26.097Z\",\"containers\":[{\"containerArn\":\"arn:aws:ecs:eu-central-1:012345678900:container/scc-events-cluster/4ca7a4f90c6342e286b4e8bec7d9e4b6/c064aa61-33d7-489b-9dc9-94e46aaeb4eb\",\"exitCode\":254,\"lastStatus\":\"STOPPED\",\"name\":\"CloudConnector\",\"image\":\"aaroneast1/cloudconnector:2.1\",\"imageDigest\":\"sha256:4a1a04d0211c88edc6a82e2a9efb96f5ad191de5570ff6228fb94d3a61e46d6b\",\"runtimeId\":\"4ca7a4f90c6342e286b4e8bec7d9e4b6-3705823409\",\"taskArn\":\"arn:aws:ecs:eu-central-1:012345678900:task/scc-events-cluster/4ca7a4f90c6342e286b4e8bec7d9e4b6\",\"networkInterfaces\":[{\"attachmentId\":\"559a158e-a32a-4e9f-a8ab-5de14a26f7b8\",\"privateIpv4Address\":\"10.0.3.202\"}],\"cpu\":\"0\"}],\"cpu\":\"256\",\"createdAt\":\"2023-05-21T15:36:22.437Z\",\"desiredStatus\":\"STOPPED\",\"enableExecuteCommand\":false,\"ephemeralStorage\":{\"sizeInGiB\":20},\"executionStoppedAt\":\"2023-05-21T15:36:54.807Z\",\"group\":\"service:scc-cloud-connector\",\"launchType\":\"FARGATE\",\"lastStatus\":\"DEPROVISIONING\",\"memory\":\"512\",\"overrides\":{\"containerOverrides\":[{\"name\":\"CloudConnector\"}]},\"platformVersion\":\"1.4.0\",\"pullStartedAt\":\"2023-05-21T15:36:34.708Z\",\"pullStoppedAt\":\"2023-05-21T15:36:44.023Z\",\"startedAt\":\"2023-05-21T15:36:45.965Z\",\"startedBy\":\"ecs-svc/9194611662556976510\",\"stoppingAt\":\"2023-05-21T15:37:04.849Z\",\"stoppedReason\":\"Essential container in task exited\",\"stopCode\":\"EssentialContainerExited\",\"taskArn\":\"arn:aws:ecs:eu-central-1:012345678900:task/scc-events-cluster/4ca7a4f90c6342e286b4e8bec7d9e4b6\",\"taskDefinitionArn\":\"arn:aws:ecs:eu-central-1:012345678900:task-definition/scc:9\",\"updatedAt\":\"2023-05-21T15:37:04.849Z\",\"version\":4}}"
        }
    ]
}
````

