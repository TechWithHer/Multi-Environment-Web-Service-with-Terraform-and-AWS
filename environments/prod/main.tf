terraform {
  required_version = ">= 1.6.0"

  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }

  backend "local" {
    path = "terraform.tfstate"
  }
}

provider "docker" {}

module "web" {
  source = "../../modules/web_service"

  service_name = var.service_name
  environment  = "prod"
  instances    = var.instances

  extra_labels = {
    cost-center = "engineering"
    tier        = "production"
  }
}
