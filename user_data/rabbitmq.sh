#!/bin/bash

set -e          # exit on command errors
set -o nounset  # abort on unbound variable
set -o pipefail # capture fail exit codes in piped commands

# ----------------------------------------
# Mount EBS additional storage
# ----------------------------------------
export MOUNT_POINT=/var/lib/rabbitmq

INSTANCE_TYPE=$(wget -qO- http://169.254.169.254/latest/meta-data/instance-type | cut -d '.' -f1)
[[ $INSTANCE_TYPE = "t2" ]] && EBS_NAME="xvdcz" || EBS_NAME="nvme"

# If nitro based instances
if [[ $EBS_NAME = "nvme" ]]; then
  # Test which block is the ebs added volume it's the one returning `data`
  # since it's not yet formated and mounted
  # disable failsafe pipefail here so IS_NOT_ROOT can return 0
  set +o pipefail
  IS_NOT_ROOT=$(file -s /dev/nvme0n1 | grep "data" | wc -l)
  set -o pipefail
  [[ $IS_NOT_ROOT = "1" ]] && EBS_NAME="nvme0n1" || EBS_NAME="nvme1n1"
fi

# Following AWS procadure (https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ebs-using-volumes.html)

mkfs -t xfs /dev/$EBS_NAME

# Where you which to mount the volume after (e.g: /var/lib/docker)
mkdir -p $MOUNT_POINT

# Mount the formated volume
mount /dev/$EBS_NAME $MOUNT_POINT

# Device is mounted now we shall protect against losing the device after reboot

EBS_UUID=$(blkid | grep $EBS_NAME | egrep '[0-9a-f]{8}-([0-9a-f]{4}-){3}[0-9a-f]{12}' -o)

echo "UUID=$EBS_UUID $MOUNT_POINT xfs defaults,nofail 0 2" >> /etc/fstab

# ----------------------------------------
# Setpu Rabbitmq Configuration
# ----------------------------------------

export RANDOM_START=$(( ( RANDOM % 30 )  + 1 ))
export AWS_REGION="${AWS_REGION}"
export VPC_ID="${VPC_ID}"
export ERL_SECRET_COOKIE="${ERL_SECRET_COOKIE}"
export AWS_SECRET_KEY="${AWS_SECRET_KEY}"
export AWS_ACCESS_KEY="${AWS_ACCESS_KEY}"
export CLUSTER_NAME=${CLUSTER_NAME}

mkdir -p /etc/rabbitmq

echo -n $ERL_SECRET_COOKIE > /var/lib/rabbitmq/.erlang.cookie
chmod 600 /var/lib/rabbitmq/.erlang.cookie

cat << EndOfConfig >> /etc/rabbitmq/rabbitmq.conf
##
## Security, Access Control
## ==============
##

loopback_users.guest                           = false

## Networking
## ====================
##
## Related doc guide: https://rabbitmq.com/networking.html.
##
## By default, RabbitMQ will listen on all interfaces, using
## the standard (reserved) AMQP 0-9-1 and 1.0 port.
##

listeners.tcp.default                          = 5672
management.listener.port                       = 15672
management.listener.ssl                        = false


hipe_compile                                   = false

##
## Clustering
## =====================
##

cluster_formation.peer_discovery_backend       = rabbit_peer_discovery_aws
cluster_formation.aws.region                   = ${AWS_REGION}
cluster_formation.aws.access_key_id            = ${AWS_ACCESS_KEY}
cluster_formation.aws.secret_key               = ${AWS_SECRET_KEY}
cluster_formation.aws.use_autoscaling_group    = true
EndOfConfig

RABBITMQ_PLUGINS="[rabbitmq_management,rabbitmq_peer_discovery_aws,rabbitmq_queue_master_balancer,rabbitmq_tracing]."

echo $RABBITMQ_PLUGINS > /etc/rabbitmq/enabled_plugins

# ----------------------------------------
# Install Rabbitmq
# ----------------------------------------

wget -O- https://packages.erlang-solutions.com/ubuntu/erlang_solutions.asc | sudo apt-key add -
echo "deb https://packages.erlang-solutions.com/ubuntu bionic contrib" | sudo tee /etc/apt/sources.list.d/erlang.list

wget -O- https://dl.bintray.com/rabbitmq/Keys/rabbitmq-release-signing-key.asc | sudo apt-key add -
wget -O- https://www.rabbitmq.com/rabbitmq-release-signing-key.asc | sudo apt-key add -
echo "deb https://dl.bintray.com/rabbitmq/debian $(lsb_release -sc) main" | sudo tee /etc/apt/sources.list.d/rabbitmq.list

sleep $RANDOM_START

apt-get update
apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common \
    erlang \
    rabbitmq-server


rabbitmqctl set_cluster_name ${CLUSTER_NAME}

