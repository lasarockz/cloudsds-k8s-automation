module "kubernetes" {
  source = "../modules/kubernetes/"

  aws_region           = "us-west-2"
  cluster_name         = "cloudsds-k8s-1"
  master_instance_type = "t2.medium"
  worker_instance_type = "t2.medium"
  ssh_public_key       = "~/.ssh/id_rsa.pub"
  ssh_access_cidr      = ["0.0.0.0/0"]
  api_access_cidr      = ["0.0.0.0/0"]
  min_worker_count     = 1
  max_worker_count     = 6
  hosted_zone          = "k8s5.colabit.store"
  hosted_zone_private  = false
  vpc_id               = "${module.vpc.vpc_id}"

  master_subnet_id = "${module.vpc.subnet_ids[0]}"
  worker_subnet_ids = "${module.vpc.private_subnet_ids}"

  # Tags
  tags = {
    Application = "cloudsds"
  }

  # Tags in a different format for Auto Scaling Group
  tags2 = [
    {
      key                 = "Application"
      value               = "cloudsds"
      propagate_at_launch = true
    },
  ]

  addons = [
    "https://raw.githubusercontent.com/lasarockz/cloudsds-k8s-automation/master/modules/kubernetes/addons/ingress.yaml",
    "https://raw.githubusercontent.com/lasarockz/cloudsds-k8s-automation/master/modules/kubernetes/addons/metrics-server.yaml",
    "https://raw.githubusercontent.com/lasarockz/cloudsds-k8s-automation/master/modules/kubernetes/addons/dashboard.yaml",
    "https://raw.githubusercontent.com/lasarockz/cloudsds-k8s-automation/master/modules/kubernetes/addons/external-dns.yaml",
    "https://raw.githubusercontent.com/lasarockz/cloudsds-k8s-automation/master/modules/kubernetes/addons/autoscaler.yaml",
    "https://raw.githubusercontent.com/lasarockz/cloudsds-k8s-automation/master/modules/kubernetes/addons/ingress.yaml"
  ]
}

module "vpc" {
  source = "../modules/vpc"

  aws_region = "us-west-2"
  aws_zones = ["us-west-2a","us-west-2b", "us-west-2c"]
  vpc_name = "cloudsds-vpc"
  vpc_cidr = "10.0.0.0/16"
  private_subnets = "true"

  ## Tags
  tags = {
    cluster = "cloudsds-k8s"
  }
}

output "vpc" {
  value = "${module.vpc.vpc_id}"
}

output "subnets" {
  value = "${module.vpc.subnet_ids}"
}

output "private_subnets" {
  value = "${module.vpc.private_subnet_ids}"
}

terraform {
  backend "s3" {
  bucket="sds-k8s-terraform"
  key="cloudsds/remote_state/terraform.tfstate"
  region="us-west-2"
}