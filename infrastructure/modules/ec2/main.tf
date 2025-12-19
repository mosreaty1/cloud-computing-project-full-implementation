# EC2 Module - Container hosts and Kafka cluster

# Security Group for Container Hosts
resource "aws_security_group" "container_hosts" {
  name        = "${var.project_name}-container-hosts-sg-${var.environment}"
  description = "Security group for container host EC2 instances"
  vpc_id      = var.vpc_id

  # Allow traffic from ALB (only when ALB is enabled)
  dynamic "ingress" {
    for_each = var.alb_security_group_id != "" ? [1] : []
    content {
      from_port       = 80
      to_port         = 80
      protocol        = "tcp"
      security_groups = [var.alb_security_group_id]
      description     = "HTTP from ALB"
    }
  }

  dynamic "ingress" {
    for_each = var.alb_security_group_id != "" ? [1] : []
    content {
      from_port       = 443
      to_port         = 443
      protocol        = "tcp"
      security_groups = [var.alb_security_group_id]
      description     = "HTTPS from ALB"
    }
  }

  dynamic "ingress" {
    for_each = var.alb_security_group_id != "" ? [1] : []
    content {
      from_port       = 8000
      to_port         = 8010
      protocol        = "tcp"
      security_groups = [var.alb_security_group_id]
      description     = "Service ports from ALB"
    }
  }

  # Allow direct access when ALB is disabled (for development/testing)
  dynamic "ingress" {
    for_each = var.alb_security_group_id == "" ? [1] : []
    content {
      from_port   = 8000
      to_port     = 8000
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "API Gateway direct access (no ALB)"
    }
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
    description = "Allow all within security group"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound"
  }

  tags = {
    Name        = "${var.project_name}-container-hosts-sg"
    Environment = var.environment
  }
}

# Security Group for Kafka Cluster
resource "aws_security_group" "kafka" {
  name        = "${var.project_name}-kafka-sg-${var.environment}"
  description = "Security group for Kafka cluster"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 9092
    to_port         = 9092
    protocol        = "tcp"
    security_groups = [aws_security_group.container_hosts.id]
    description     = "Kafka from container hosts"
  }

  ingress {
    from_port   = 2181
    to_port     = 2181
    protocol    = "tcp"
    security_groups = [aws_security_group.container_hosts.id]
    description = "Zookeeper from container hosts"
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
    description = "Allow all within Kafka cluster"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound"
  }

  tags = {
    Name        = "${var.project_name}-kafka-sg"
    Environment = var.environment
  }
}

# Launch Template for Container Hosts
resource "aws_launch_template" "container_host" {
  name_prefix   = "${var.project_name}-container-host-${var.environment}"
  image_id      = var.ami_id
  instance_type = var.instance_type

  iam_instance_profile {
    name = var.iam_instance_profile_name
  }

  vpc_security_group_ids = [aws_security_group.container_hosts.id]

  user_data = base64encode(templatefile("${path.module}/userdata/container-host.sh", {
    environment = var.environment
    region      = var.aws_region
  }))

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size           = 30
      volume_type           = "gp3"
      encrypted             = true
      delete_on_termination = true
    }
  }

  monitoring {
    enabled = true
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name        = "${var.project_name}-container-host"
      Environment = var.environment
      Type        = "ContainerHost"
    }
  }

  tags = {
    Name        = "${var.project_name}-container-host-lt"
    Environment = var.environment
  }
}

# Auto Scaling Group for Container Hosts
resource "aws_autoscaling_group" "container_hosts" {
  name                = "${var.project_name}-container-hosts-asg-${var.environment}"
  vpc_zone_identifier = var.private_subnet_ids
  target_group_arns   = var.target_group_arns

  desired_capacity = var.desired_capacity
  max_size         = var.max_size
  min_size         = var.min_size

  health_check_type         = "ELB"
  health_check_grace_period = 300

  launch_template {
    id      = aws_launch_template.container_host.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${var.project_name}-container-host"
    propagate_at_launch = true
  }

  tag {
    key                 = "Environment"
    value               = var.environment
    propagate_at_launch = true
  }
}

# Auto Scaling Policy - Target Tracking (CPU)
resource "aws_autoscaling_policy" "cpu_target_tracking" {
  name                   = "${var.project_name}-cpu-target-tracking-${var.environment}"
  autoscaling_group_name = aws_autoscaling_group.container_hosts.name
  policy_type            = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 70.0
  }
}

# Kafka Broker Instances
resource "aws_instance" "kafka" {
  count         = var.kafka_broker_count
  ami           = var.ami_id
  instance_type = var.kafka_instance_type
  subnet_id     = var.kafka_subnet_ids[count.index % length(var.kafka_subnet_ids)]

  vpc_security_group_ids = [aws_security_group.kafka.id]
  iam_instance_profile   = var.iam_instance_profile_name

  user_data = base64encode(templatefile("${path.module}/userdata/kafka-broker.sh", {
    broker_id   = count.index
    environment = var.environment
    region      = var.aws_region
  }))

  root_block_device {
    volume_size           = 20
    volume_type           = "gp3"
    encrypted             = true
    delete_on_termination = true
  }

  ebs_block_device {
    device_name           = "/dev/sdf"
    volume_size           = 100
    volume_type           = "gp3"
    encrypted             = true
    delete_on_termination = false
  }

  monitoring = true

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  tags = {
    Name        = "${var.project_name}-kafka-broker-${count.index + 1}"
    Environment = var.environment
    Type        = "KafkaBroker"
    BrokerId    = count.index
  }
}

# Zookeeper Instances
resource "aws_instance" "zookeeper" {
  count         = var.zookeeper_node_count
  ami           = var.ami_id
  instance_type = var.zookeeper_instance_type
  subnet_id     = var.kafka_subnet_ids[count.index % length(var.kafka_subnet_ids)]

  vpc_security_group_ids = [aws_security_group.kafka.id]
  iam_instance_profile   = var.iam_instance_profile_name

  user_data = base64encode(templatefile("${path.module}/userdata/zookeeper.sh", {
    node_id     = count.index + 1
    environment = var.environment
    region      = var.aws_region
  }))

  root_block_device {
    volume_size           = 20
    volume_type           = "gp3"
    encrypted             = true
    delete_on_termination = true
  }

  ebs_block_device {
    device_name           = "/dev/sdf"
    volume_size           = 20
    volume_type           = "gp3"
    encrypted             = true
    delete_on_termination = false
  }

  monitoring = true

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  tags = {
    Name        = "${var.project_name}-zookeeper-${count.index + 1}"
    Environment = var.environment
    Type        = "Zookeeper"
    NodeId      = count.index + 1
  }
}
