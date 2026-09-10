data "aws_ssm_parameter" "al2023_kernel_618" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-6.18-x86_64"
}

resource "aws_instance" "lab" {
  ami                         = data.aws_ssm_parameter.al2023_kernel_618.value
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.lab.id
  vpc_security_group_ids      = [aws_security_group.lab.id]
  iam_instance_profile        = aws_iam_instance_profile.lab.name
  associate_public_ip_address = true
  credit_specification {
    cpu_credits = "standard"
  }
  root_block_device {
    volume_type = "gp3"
    volume_size = var.lab_volume_size
    encrypted   = true
  }
  user_data = file("${path.module}/../scripts/bootstrap.sh")
  user_data_replace_on_change = true

  tags = {
    Name      = "${var.project_name}-${var.student_id}"
    Project   = var.project_name
    Student   = var.student_id
    LabState  = "STOPPED"
  }
}
