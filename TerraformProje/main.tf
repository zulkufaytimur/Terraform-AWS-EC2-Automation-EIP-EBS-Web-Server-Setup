# 1. Data Source: Default VPC
data "aws_vpc" "default" {
  default = true
}

# 2. Data Source: Subnets of Default VPC
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# 3. Data Source: First Subnet Details (to get AZ)
data "aws_subnet" "first" {
  id = data.aws_subnets.default.ids[0]
}

# 4. Security Group (in Default VPC)
resource "aws_security_group" "web_sg" {
  name        = "${var.project_name}-web-sg"
  description = "Allow inbound traffic"
  vpc_id      = data.aws_vpc.default.id

  dynamic "ingress" {
    for_each = var.allowed_ports
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-web-sg"
  }
}

# 5. Data Source for AMI
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# ==========================================
# INSTANCE 1: Docker + Nginx + EIP + EBS
# ==========================================

resource "aws_instance" "node_one" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.instance_type
  subnet_id              = data.aws_subnet.first.id
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  key_name               = var.key_pair_name

  user_data = <<-EOF
              #!/bin/bash
              yum update -y

              # ---- Docker Kurulumu ----
              amazon-linux-extras install docker -y
              systemctl enable docker
              systemctl start docker

              # ---- Nginx Container ----
              docker run -d --name webapp -p 80:80 nginx

              # ---- Web Sayfası ----
              echo "<h1>Terraform + Docker + Nginx (Node 1)</h1>" > index.html
              docker cp index.html webapp:/usr/share/nginx/html/index.html

              # ---- EBS Otomatik Mount ----
              DEVICE="/dev/sdh"
              MOUNT_POINT="/data"

              mkdir -p $MOUNT_POINT
              while [ ! -e $DEVICE ]; do echo "Waiting for disk..."; sleep 5; done

              if ! blkid $DEVICE; then
                  mkfs -t xfs $DEVICE
              fi

              mount $DEVICE $MOUNT_POINT

              UUID=$(blkid -s UUID -o value $DEVICE)
              if ! grep -q "$UUID" /etc/fstab; then
                  echo "UUID=$UUID $MOUNT_POINT xfs defaults,nofail 0 2" >> /etc/fstab
              fi

              chmod 777 $MOUNT_POINT
              EOF

  tags = {
    Name = "${var.project_name}-node-1-docker-nginx"
  }
}

# Elastic IP for Node 1
resource "aws_eip" "node_one_eip" {
  domain   = "vpc"
  instance = aws_instance.node_one.id

  tags = {
    Name = "${var.project_name}-node-1-eip"
  }
}

# EBS Volume for Node 1
resource "aws_ebs_volume" "node_one_vol" {
  availability_zone = data.aws_subnet.first.availability_zone
  size              = 10
  type              = "gp3"

  tags = {
    Name = "${var.project_name}-node-1-volume"
  }
}

# EBS Attachment for Node 1
resource "aws_volume_attachment" "node_one_att" {
  device_name = "/dev/sdh"
  volume_id   = aws_ebs_volume.node_one_vol.id
  instance_id = aws_instance.node_one.id
}

# ==========================================
# INSTANCE 2: Simple Apache Node
# ==========================================

resource "aws_instance" "node_two" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.instance_type
  subnet_id              = data.aws_subnet.first.id
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  key_name               = var.key_pair_name

  associate_public_ip_address = true

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd
              systemctl start httpd
              systemctl enable httpd
              echo "<h1>Node 2 (Apache - Simple)</h1>" > /var/www/html/index.html
              EOF

  tags = {
    Name = "${var.project_name}-node-2-simple"
  }
}
