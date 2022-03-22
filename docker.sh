 #!/bin/bash
 sudo yum update -y && sudo yum install -y docker
 sudo systemctl start docker
 sudo docker run -d -p 8989:80 nginx:alpine