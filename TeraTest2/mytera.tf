provider "aws" {
    region = "ap-south-1"
    profile = "ankush"
}

// Creating aws security resource
resource "aws_security_group" "mySecGrp" {
  name        = "mySecGrp"
  description = "Allow TCP inbound traffic"
  vpc_id      = "vpc-4ae4f922"

  ingress {
    description = "TCP from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
   ingress {
    description = "SSH from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "mySecGrp"
  }
}

resource "aws_instance" "myInstOne" {
    depends_on = [
        aws_security_group.mySecGrp,
    ]

    ami = "ami-0447a12f28fddb066"
    instance_type = "t2.micro"
    key_name = "cankush625"
    vpc_security_group_ids = ["${aws_security_group.mySecGrp.id}"]
    subnet_id = "subnet-2f0b3147"
    tags = {
        Name = "myTeraInst"
    }

    connection {
        type = "ssh"
        user = "ec2-user"
        private_key = file("~/Desktop/cankush625.pem")
        host = aws_instance.myInstOne.public_ip
    }

    provisioner "remote-exec" {
        inline = [
            "sudo yum install httpd git -y",
            "sudo systemctl restart httpd",
            "sudo systemctl enable httpd",
            "sudo git clone http://github.com/cankush625/Web.git /var/www/html",
        ]
    }
}

// Privisioner local exec
resource "null_resource" "myNullOne" {
    depends_on = [
        aws_instance.myInstOne,
    ]

    provisioner "local-exec" {
        command = "google-chrome https://${aws_instance.myInstOne.public_ip}:80"
    }
}

// Priting all of the instance information
# output "myInstOut" {
#     value = aws_instance.myInstOne
# }

// Creating variable in terraform
# variable "x" {
#     type = string
#     default = "Ankush"
# }

// Printing value of variable x
# output "xout" {
#     value = var.x
# }