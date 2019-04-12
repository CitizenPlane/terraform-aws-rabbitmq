# Rabbitmq AWS Module

This repository is a set of two modules, one to create an Auto Scaling Group that will bind rabbitmq nodes together using the rabbitmq plugins:
  ![rabbitmq_peer_discovery_aws](https://www.rabbitmq.com/cluster-formation.html#peer-discovery-aws)

The other is will declare two new entries on a private route53 zone, and bind them to a load balencer for the web interface management plugin, 
and the default rabbitmq TCP port so we can open new connections and chanels

## How to use this Module

This module purpose is only to create a  Rabbitmq Cluster and the routes to access it. 
It does not include the creation of a *VPC* nor the *route53* zone used to access the Load balancer.

I let you refer to our other modules if you want to use them, otherwise it should be easy enough to plug this module in an already exisiting VPC (the alb beeing optional too)

Apart from the network there is not much configuration to do as you can see in the example folder here the main settings:

```hcl
  

```

##
