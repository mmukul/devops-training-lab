resource "aws_security_group" "lab" {
  name        = "${var.project_name}-sg"
  description = "Minimal access for the one-student lab"
  vpc_id      = aws_vpc.lab.id

  # Phase 1A.2 browser terminal will use HTTPS on 443.
  # SSH is intentionally NOT exposed.
  ingress {
    description = "Browser terminal HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.project_name}-sg" }
}
