data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
    }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
    }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "web" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"

  tags = {
    Name = "HelloNetology"
  }
  lifecycle {
    create_before_destroy = true
  }
}
resource "aws_vpc" "my_vpc" {
  cidr_block = "172.31.0.0/16"
}
resource "aws_subnet" "my_subnet" {
  vpc_id            = "${aws_vpc.my_vpc.id}"
  cidr_block        = "172.31.10.0/24"
  availability_zone = "us-west-2a"

  tags = {
    Name = "tf-example"
  }
}

resource "aws_network_interface" "foo" {
  subnet_id   = aws_subnet.my_subnet.id
  private_ips = ["172.31.10.100"]

  tags = {
    Name = "primary_network_interface"
  }
}
provider "aws" {
  region = var.region

  default_tags {
    tags = {
      Hashicorp-Learn = "aws-iam-policy"
    }
  }

}

resource "random_pet" "red_hat" {
  length    = 3
  separator = "-"
}

#resource "aws_iam_user" "redhat37" {
#  name = "redhat37"
#}

locals {
  web_instance_count_map = {
    stage = 1
    prod = 2
  }
}

resource "aws_s3_bucket" "bucket" {
  bucket = "tf-bucket-${count.index}-${terraform.workspace}"
  #acl    = "private"
  tags = {
    Name        = "My_bucket${count.index}"
    Environment = terraform.workspace
  }
  count = local.web_instance_count_map[terraform.workspace]
}

locals {
  backets_ids = toset([
  "e1",
  "e2",
  ])
}
resource "aws_s3_bucket" "bucket_e" {
  for_each = local.backets_ids
  bucket = "tf-bucket-${each.key}-${terraform.workspace}"
  #acl    = "private"
  tags = {
    Name        = "My_bucket ${each.key}"
    Environment = terraform.workspace
  }
}

data "aws_iam_policy_document" "example" {
  statement {
    actions   = ["s3:ListAllMyBuckets"]
    resources = ["arn:aws:s3:::*"]
    effect = "Allow"
  }
  statement {
    actions   = ["s3:*"]
    resources = ["aws_s3_bucket.bucket.arn"]
    effect = "Allow"
  }
}

resource "aws_iam_policy" "policy" {
  name        = "tf-bucket-${terraform.workspace}-policy"
  description = "My test policy"

  policy = <<EOT
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:ListAllMyBuckets"
      ],
      "Effect": "Allow",
      "Resource": "*"
    },
    {
      "Action": [
        "ec2:*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    },
    {
      "Action": [
        "dynamodb:*"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:dynamodb:us-west-2:951728628080:table/Books"
    },
    {
      "Action": [
        "cloudwatch:*",
        "iam:*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": "iam:CreateServiceLinkedRole",
        "Resource": "arn:aws:iam::*:role/aws-service-role/events.amazonaws.com/AWSServiceRoleForCloudWatchEvents*",
            "Condition": {
                "StringLike": {
                    "iam:AWSServiceName": "events.amazonaws.com"
                }
            }
    },
    {
      "Action": [
        "s3:*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]

}
EOT
}