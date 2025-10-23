#!/bin/bash
##### Variaveis #####
GRUPO_SEGURANCA_WEB="nr-security-web"
GRUPO_SEGURANCA_DB="nr-security-db"
GRUPO_SEGURANCA_JAVA="nr-security-java"

CHAVE_WEB="key-web"
CHAVE_DB="key-db"
CHAVE_JAVA="key-java"

WEB_SERVER="nr-web-server"
DB_SERVER="nr-db-server"
JAVA_SERVER="nr-java-server"

IMAGEM_EC2="ami-0360c520857e3138f"
TIPO_EC2="t3.small"

##### Captura dos Ids #####
echo "Recuperando Ip da VPC..."
ID_VPC=$(aws ec2 describe-vpcs \
  --filter "Name=is-default,Values=true" \
  --query "Vpcs[0].[VpcId]" \
  --output text)

echo "Recuperando Ip da Subnet..."
ID_SUBNET=$(aws ec2 describe-subnets \
  --query "Subnets[0].[SubnetId]" \
  --output text)

##### Criação dos grupos de Seguranca #####
SG_ID_WEB=$(aws ec2 describe-security-groups \
  --group-names "$GRUPO_SEGURANCA_WEB" \
  --query "SecurityGroups[*].[GroupId]" \
  --output text \
  2>/dev/null)

if [ -z "$SG_ID_WEB" ]; then
  echo "Criando grupo de Seguranca $GRUPO_SEGURANCA_WEB..."
  aws ec2 create-security-group \
    --vpc-id "$ID_VPC" \
    --group-name "$GRUPO_SEGURANCA_WEB" \
    --description "$GRUPO_SEGURANCA_WEB created $(date +%F)" \
    --tag-specifications "ResourceType=security-group,Tags=[{Key=Name,Value=sg-web-server-prod}]"

  aws ec2 authorize-security-group-ingress \
    --group-name "$GRUPO_SEGURANCA_WEB" \
    --ip-permissions \
    IpProtocol=tcp,FromPort=80,ToPort=80,IpRanges='[{CidrIp=0.0.0.0/0}]' \
    IpProtocol=tcp,FromPort=22,ToPort=22,IpRanges='[{CidrIp=0.0.0.0/0}]'

  SG_ID_WEB=$(aws ec2 describe-security-groups \
    --group-names "$GRUPO_SEGURANCA_WEB" \
    --query "SecurityGroups[*].[GroupId]" \
    --output text \
    2>/dev/null)
else
  echo "Grupo de Segurança $GRUPO_SEGURANCA_WEB já existe!"
fi

SG_ID_DB=$(aws ec2 describe-security-groups \
  --group-names "$GRUPO_SEGURANCA_DB" \
  --query "SecurityGroups[*].[GroupId]" \
  --output text \
  2>/dev/null)

if [ -z "$SG_ID_DB" ]; then
  echo "Criando grupo de Seguranca $GRUPO_SEGURANCA_DB..."
  aws ec2 create-security-group \
    --vpc-id "$ID_VPC" \
    --group-name "$GRUPO_SEGURANCA_DB" \
    --description "$GRUPO_SEGURANCA_DB created $(date +%F)" \
    --tag-specifications "ResourceType=security-group,Tags=[{Key=Name,Value=sg-db-server-prod}]"

  aws ec2 authorize-security-group-ingress \
    --group-name "$GRUPO_SEGURANCA_DB" \
    --ip-permissions \
    IpProtocol=tcp,FromPort=3306,ToPort=3306,IpRanges='[{CidrIp=0.0.0.0/0}]' \
    IpProtocol=tcp,FromPort=22,ToPort=22,IpRanges='[{CidrIp=0.0.0.0/0}]'

  SG_ID_DB=$(aws ec2 describe-security-groups \
    --group-names "$GRUPO_SEGURANCA_DB" \
    --query "SecurityGroups[*].[GroupId]" \
    --output text \
    2>/dev/null)
else
  echo "Grupo de Segurança $GRUPO_SEGURANCA_DB já existe!"
fi

SG_ID_JAVA=$(aws ec2 describe-security-groups \
  --group-names "$GRUPO_SEGURANCA_JAVA" \
  --query "SecurityGroups[*].[GroupId]" \
  --output text \
  2>/dev/null)

if [ -z "$SG_ID_JAVA" ]; then
  echo "Criando grupo de Seguranca $GRUPO_SEGURANCA_JAVA..."
  aws ec2 create-security-group \
    --vpc-id "$ID_VPC" \
    --group-name "$GRUPO_SEGURANCA_JAVA" \
    --description "$GRUPO_SEGURANCA_JAVA created $(date +%F)" \
    --tag-specifications "ResourceType=security-group,Tags=[{Key=Name,Value=sg-db-server-prod}]"

  aws ec2 authorize-security-group-ingress \
    --group-name "$GRUPO_SEGURANCA_JAVA" \
    --ip-permissions \
    IpProtocol=tcp,FromPort=3306,ToPort=3306,IpRanges='[{CidrIp=0.0.0.0/0}]' \
    IpProtocol=tcp,FromPort=22,ToPort=22,IpRanges='[{CidrIp=0.0.0.0/0}]'

  SG_ID_JAVA=$(aws ec2 describe-security-groups \
    --group-names "$GRUPO_SEGURANCA_JAVA" \
    --query "SecurityGroups[*].[GroupId]" \
    --output text \
    2>/dev/null)
else
  echo "Grupo de Segurança $GRUPO_SEGURANCA_JAVA já existe!"
fi

##### Criacao dos par de chaves #####
EXISTE_KEY_WEB=$(aws ec2 describe-key-pairs \
  --key-names "$CHAVE_WEB" \
  2>/dev/null)

if [ -z "$EXISTE_KEY_WEB" ]; then
  echo "Criando Par de Chaves $CHAVE_WEB..."
  aws ec2 create-key-pair \
    --key-name "$CHAVE_WEB" \
    --region us-east-1 \
    --query 'KeyMaterial' \
    --output text >"$CHAVE_WEB".pem
  chmod 400 "$CHAVE_WEB.pem"
else
  echo "Par de Chaves $CHAVE_WEB já existe!"
fi

EXISTE_KEY_DB=$(aws ec2 describe-key-pairs \
  --key-names "$CHAVE_DB" \
  2>/dev/null)

if [ -z "$EXISTE_KEY_DB" ]; then
  echo "Criando Par de Chaves $CHAVE_DB..."
  aws ec2 create-key-pair \
    --key-name "$CHAVE_DB" \
    --region us-east-1 \
    --query 'KeyMaterial' \
    --output text >"$CHAVE_DB".pem
  chmod 400 "$CHAVE_DB.pem"
else
  echo "Par de Chaves $CHAVE_DB já existe!"
fi

EXISTE_KEY_JAVA=$(aws ec2 describe-key-pairs \
  --key-names "$CHAVE_JAVA" \
  2>/dev/null)

if [ -z "$EXISTE_KEY_JAVA" ]; then
  echo "Criando Par de Chaves $CHAVE_JAVA..."
  aws ec2 create-key-pair \
    --key-name "$CHAVE_JAVA" \
    --region us-east-1 \
    --query 'KeyMaterial' \
    --output text >"$CHAVE_JAVA".pem
  chmod 400 "$CHAVE_JAVA.pem"
else
  echo "Par de Chaves $CHAVE_JAVA já existe!"
fi

##### Criacao das Instancias #####
EXISTE_WEB_SERV=$(aws ec2 describe-instances \
  --query "Reservations[*].Instances[*].[Tags[?Key=='Name'].Value|[0]]" \
  --filters "Name='tag:Name',Values='$WEB_SERVER'" \
  --output text \
  2>/dev/null)

if [ -z "$EXISTE_WEB_SERV" ]; then
  echo "Criando instancia $WEB_SERVER..."
  aws ec2 run-instances \
    --image-id "$IMAGEM_EC2" \
    --count 1 \
    --security-group-ids "$SG_ID_WEB" \
    --instance-type "$TIPO_EC2" \
    --subnet-id "$ID_SUBNET" \
    --key-name "$CHAVE_WEB" \
    --block-device-mappings '[{"DeviceName":"/dev/sda1","Ebs":{"VolumeSize":20,"VolumeType":"gp3","DeleteOnTermination":true}}]' \
    --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$WEB_SERVER}]" \
    --user-data "$(
      cat <<'EOF'
#!/bin/bash
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

sudo groupadd docker
sudo usermod -aG docker $USER
newgrp docker
EOF
    )"

else
  echo "Instancia $WEB_SERVER já existe!"
fi

EXISTE_DB_SERV=$(aws ec2 describe-instances \
  --query "Reservations[*].Instances[*].[Tags[?Key=='Name'].Value|[0]]" \
  --filters "Name='tag:Name',Values='$DB_SERVER'" \
  --output text \
  2>/dev/null)

if [ -z "$EXISTE_DB_SERV" ]; then
  echo "Criando instancia $DB_SERVER..."
  aws ec2 run-instances \
    --image-id "$IMAGEM_EC2" \
    --count 1 \
    --security-group-ids "$SG_ID_DB" \
    --instance-type "$TIPO_EC2" \
    --subnet-id "$ID_SUBNET" \
    --key-name "$CHAVE_DB" \
    --block-device-mappings '[{"DeviceName":"/dev/sda1","Ebs":{"VolumeSize":20,"VolumeType":"gp3","DeleteOnTermination":true}}]' \
    --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$DB_SERVER}]" \
    --user-data "$(
      cat <<'EOF'
#!/bin/bash
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

sudo groupadd docker
sudo usermod -aG docker $USER
newgrp docker
EOF
    )"
else
  echo "Instancia $DB_SERVER já existe!"
fi

EXISTE_JAVA_SERV=$(aws ec2 describe-instances \
  --query "Reservations[*].Instances[*].[Tags[?Key=='Name'].Value|[0]]" \
  --filters "Name='tag:Name',Values='$JAVA_SERVER'" \
  --output text \
  2>/dev/null)

if [ -z "$EXISTE_DB_SERV" ]; then
  echo "Criando instancia $JAVA_SERVER..."
  aws ec2 run-instances \
    --image-id "$IMAGEM_EC2" \
    --count 1 \
    --security-group-ids "$SG_ID_DB" \
    --instance-type "$TIPO_EC2" \
    --subnet-id "$ID_SUBNET" \
    --key-name "$CHAVE_JAVA" \
    --block-device-mappings '[{"DeviceName":"/dev/sda1","Ebs":{"VolumeSize":20,"VolumeType":"gp3","DeleteOnTermination":true}}]' \
    --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$JAVA_SERVER}]" \
    --user-data "$(
      cat <<'EOF'
#!/bin/bash
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

sudo groupadd docker
sudo usermod -aG docker $USER
newgrp docker
EOF
    )"
else
  echo "Instancia $JAVA_SERVER já existe!"
fi
