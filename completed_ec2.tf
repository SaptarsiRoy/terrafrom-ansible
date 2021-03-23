/*
This code will launch a ec2 instance with custom
created key pair and security group. It will also
create a ebs volume of 1 gib and take a snapshot of it
After creating ebs volume, it will attach to /var/www/html
directory. A s3 bucket will also be created with my image
and cloudfront will have access to it. After launching,
it will also display the public ip of the ec2 instance.
*/


//Describing Provider
provider "aws" {
  region  = "ap-south-1"
  profile = "Saptarsi"
}


//Creating Variable for AMI_ID
variable "ami_id" {
  type    = string
  default = "ami-0447a12f28fddb066"
}

//Creating Variable for AMI_Type
variable "ami_type" {
  type    = string
  default = "t2.micro"
}


//Creating Key
resource "tls_private_key" "tls_key" {
  algorithm = "RSA"
}


//Generating Key-Value Pair
resource "aws_key_pair" "generated_key" {
  key_name   = "rg-env-key"
  public_key = tls_private_key.tls_key.public_key_openssh


  depends_on = [
    tls_private_key.tls_key
  ]
}


//Saving Private Key PEM File
resource "local_file" "key-file" {
  content  = tls_private_key.tls_key.private_key_pem
  filename = "playbook/mykey.pem"


  depends_on = [
    tls_private_key.tls_key
  ]
}


//Creating Security Group
resource "aws_security_group" "web-SG" {
  name        = "Terraform-SG"
  description = "Web Environment Security Group"


  //Adding Rules to Security Group
  ingress {
    description = "SSH Rule"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  ingress {
    description = "HTTP Rule"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


//Creating a S3 Bucket for Terraform Integration
resource "aws_s3_bucket" "sappy20bucket" {
  bucket = "sappy-static-data-bucket"
  acl    = "public-read"
}

//Putting Objects in S3 Bucket
resource "aws_s3_bucket_object" "web-object1" {
  bucket       = aws_s3_bucket.sappy20bucket.bucket
  key          = "img.jpg"
  source       = "img.jpg"
  content_type = "image/jpeg"
  acl          = "public-read"
}

//Creating CloutFront with S3 Bucket Origin
resource "aws_cloudfront_distribution" "s3-web-distribution" {
  origin {
    domain_name = aws_s3_bucket.sappy20bucket.bucket_regional_domain_name
    origin_id   = aws_s3_bucket.sappy20bucket.id
  }


  enabled         = true
  is_ipv6_enabled = true
  comment         = "S3 Web Distribution"


  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = aws_s3_bucket.sappy20bucket.id


    forwarded_values {
      query_string = false


      cookies {
        forward = "none"
      }
    }


    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }


  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = ["IN"]
    }
  }


  tags = {
    Name        = "Web-CF-Distribution"
    Environment = "Production"
  }


  viewer_certificate {
    cloudfront_default_certificate = true
  }


  depends_on = [
    aws_s3_bucket.sappy20bucket
  ]
}

//Launching EC2 Instance
resource "aws_instance" "web" {
  ami             = var.ami_id
  instance_type   = var.ami_type
  key_name        = aws_key_pair.generated_key.key_name
  security_groups = ["${aws_security_group.web-SG.name}"]

  //Labelling the Instance
  tags = {
    Name = "Web-Env"
    env  = "webserver"
  }
  depends_on = [
    aws_security_group.web-SG,
    aws_key_pair.generated_key,
  ]
}


//Creating EBS Volume
resource "aws_ebs_volume" "web-vol" {
  availability_zone = aws_instance.web.availability_zone
  size              = 1

  tags = {
    Name = "ebs-vol"
  }
}


//Attaching EBS Volume to a Instance
resource "aws_volume_attachment" "ebs_att" {
  device_name  = "/dev/sdh"
  volume_id    = aws_ebs_volume.web-vol.id
  instance_id  = aws_instance.web.id
  force_detach = true
}


# public ip
output "DNS_name" {
  value = aws_instance.web.public_dns
}

resource "local_file" "variable_file2" {
  content  = "cf_address: ${aws_cloudfront_distribution.s3-web-distribution.domain_name}"
  filename = "playbook/vars.yml"
}

resource "null_resource" "run_playbook" {
  depends_on = [
    aws_cloudfront_distribution.s3-web-distribution,
    aws_volume_attachment.ebs_att,
    aws_instance.web,
  ]
  provisioner "local-exec" {
    command = "chmod 400 playbook/mykey.pem &&  ansible-playbook playbook/playbook.yml --private-key playbook/mykey.pem -i playbook/ec2.py"
  }
}
