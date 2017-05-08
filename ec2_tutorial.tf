resource "aws_key_pair" "ec2_tuter_key" {
  key_name = "ec2_tuter"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDwv5lj/UsNhHzEmjCjdAvmogX++dXfHab54+12UGeksq3HfAbVxIUej19PKDzFWPirs5je+hk09ufgETSXHwta7aX/qKRDHCicgts0ojO5j60hepe7Aud4K/2h39Iv02W4sigzPNzwdlve63twv1ifPh5VbzwuqisxV9wBqNy80i2BWitW4QUpYijpkJ9rB79wLU3XZ9uTmelLyUHcT+KZUwN6s98JWWSfD6EIJSarONt2GQCVMbaInR/MwZcCcSQ7oBR6EwGA6oZvOHW9bVPidamzTDLXFGqaHx7TYosYHUOmNrUNbBSuDg5gOOZiDg3KIzSB54i8pOH87J2TLS9X riku.onuma@livesense.co.jp"
  # public keyはデフォルトだと644なので注意
}

resource "aws_instance" "ec2_tuter" {
  ami = "ami-4836a428" # amazon linuxのami
  instance_type = "t2.micro"
  key_name = "${aws_key_pair.ec2_tuter_key.id}"
  subnet_id = "${aws_subnet.vpc_tuter_subnet.id}"
  vpc_security_group_ids = ["${aws_security_group.vpc_tuter_security_group.id}"]
  associate_public_ip_address = true
}

resource "aws_instance" "ec2_tuter_another" {
  ami = "ami-4836a428" # amazon linuxのami
  instance_type = "t2.micro"
  key_name = "${aws_key_pair.ec2_tuter_key.id}"
  subnet_id = "${aws_subnet.vpc_tuter_subnet_another.id}"
  vpc_security_group_ids = ["${aws_security_group.vpc_tuter_security_group.id}"]
  associate_public_ip_address = true
}


resource "aws_alb" "alb_tuter" {
  subnets = [
    "${aws_subnet.vpc_tuter_subnet.id}",
    "${aws_subnet.vpc_tuter_subnet_another.id}"
  ]
  internal = false
  security_groups = ["${aws_security_group.vpc_tuter_security_group.id}"]
}

resource "aws_alb_target_group" "alb_tuter_group" {
  name = "default"
  port = 80
  protocol =  "HTTP"
  vpc_id = "${aws_vpc.vpc_tuter.id}"
}

resource "aws_alb_target_group_attachment" "alb_tuter_attachment" {
  target_group_arn = "${aws_alb_target_group.alb_tuter_group.arn}"
  target_id = "${aws_instance.ec2_tuter.id}"
  port = 80
}

resource "aws_alb_target_group_attachment" "alb_tuter_attachment_another" {
  target_group_arn = "${aws_alb_target_group.alb_tuter_group.arn}"
  target_id = "${aws_instance.ec2_tuter_another.id}"
  port = 80
}

resource "aws_alb_listener" "alb_tuter_listner" {
  load_balancer_arn = "${aws_alb.alb_tuter.arn}"
  port = 80
  protocol = "HTTP"

  default_action {
    target_group_arn = "${aws_alb_target_group.alb_tuter_group.arn}"
    type = "forward"
  }
}
