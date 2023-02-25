source "amazon-ebs" "ami-region1" {
  region = var.regions.region1   
  access_key = var.access_key
  secret_key = var.secret_key
  ami_name = local.image-name
  source_ami  = var.ami[var.regions.region1]
  instance_type = "t2.micro"
  ssh_username = "ec2-user"
  tags = {
    Name = local.image-name
    project = var.project
    env =  var.environment
  }  
}

source "amazon-ebs" "ami-region2" {
  region = var.regions.region2   
  access_key = var.access_key
  secret_key = var.secret_key
  ami_name = local.image-name
  source_ami  = var.ami[var.regions.region2]
  instance_type = "t2.micro"
  ssh_username = "ec2-user"
  tags = {
    Name = local.image-name
    project = var.project
    env =  var.environment
  }  
}

build {
  sources = [ "source.amazon-ebs.ami-region1" , "source.amazon-ebs.ami-region2"]
  provisioner "shell" {
    script = "./site-setup.sh"
    execute_command  = "sudo  {{.Path}}"
  }    
}
