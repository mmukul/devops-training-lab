## Build the image

docker build -t smilemukul/nginx-demo:v1.0 .

## Open the port permanently by specifying the port number and protocol

firewall-cmd --permanent --add-port=8081/tcp

## Reload Firewalld to apply changes

firewall-cmd --reload

## Build and deploy the container

docker run -d --name <name-container> -p 8081:80 <new_image_name:tag>

## Check if the container was successfully created

docker ps

## Verify that the container is running

<public_ip>:8081

## Login to your docker account

docker login -u <dockerhub_username> -p <dockerhub_password>

## Push docker image to Dockerhub

docker push smilemukul/nginx-demo:v1.0

