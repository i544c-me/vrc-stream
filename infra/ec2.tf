data "aws_ami" "ubuntu" {
  owners      = ["self"]
  most_recent = true

  filter {
    name   = "name"
    values = ["vrc-stream-ubuntu-arm64-*"]
  }
}

resource "aws_instance" "app" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t4g.micro"
  subnet_id              = aws_subnet.public_1.id
  vpc_security_group_ids = [aws_security_group.app.id]
  iam_instance_profile   = aws_iam_instance_profile.ec2.id

  tags = {
    Name = "${local.project}-app"
  }
}

resource "aws_security_group" "app" {
  name   = "${local.project}-app"
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${local.project}-app"
  }
}

resource "aws_security_group_rule" "app-ingress-rtmp" {
  security_group_id = aws_security_group.app.id
  type              = "ingress"
  from_port         = "1935"
  to_port           = "1935"
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "app-ingress-rtspt" {
  security_group_id = aws_security_group.app.id
  type              = "ingress"
  from_port         = "554"
  to_port           = "554"
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "app-egress" {
  security_group_id = aws_security_group.app.id
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = -1
  cidr_blocks       = ["0.0.0.0/0"]
}

### SSM ###

resource "aws_iam_role" "ec2" {
  name = "${local.project}-ec2"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

data "aws_iam_policy" "ssm_managed_instance_core" {
  arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

data "aws_iam_policy" "cloud_watch_agent_server_policy" {
  arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_iam_role_policy_attachment" "ssm_managed_instance_core" {
  role       = aws_iam_role.ec2.name
  policy_arn = data.aws_iam_policy.ssm_managed_instance_core.arn
}

resource "aws_iam_role_policy_attachment" "cloud_watch_agent_server_policy" {
  role       = aws_iam_role.ec2.name
  policy_arn = data.aws_iam_policy.cloud_watch_agent_server_policy.arn
}

resource "aws_iam_instance_profile" "ec2" {
  name = "${local.project}-ec2"
  role = aws_iam_role.ec2.name
}