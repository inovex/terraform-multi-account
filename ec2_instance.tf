resource "aws_autoscaling_group" "ec2_webtier" {
  name                 = "ec2-"
  availability_zones   = ["eu-central-1a"]
  min_size             = "1"
  max_size             = "3"
  desired_capacity     = "1"
  health_check_type    = "EC2"
  launch_configuration = "${aws_launch_configuration.ec2_instance.name}"
  vpc_zone_identifier  = ["${aws_subnet.subnet.id}"]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_launch_configuration" "ec2_instance" {
  name_prefix                 = "ec2-"
  image_id                    = "${var.ec2_ami}"
  instance_type               = "${var.ec2_node_type}"
  security_groups             = [""]
  associate_public_ip_address = false                                             # set to true
  user_data                   = "${data.template_file.provision_ubuntu.rendered}"

  ebs_block_device {
    device_name           = "/dev/xvdz"
    volume_size           = "${var.ec2_volume_size}"
    volume_type           = "gp2"
    delete_on_termination = true
  }

  lifecycle {
    create_before_destroy = true
  }
}
