data "template_file" "provision_ubuntu" {
  template = "${file("ec2/provision.tpl")}"

  vars {
    volume_size = "${var.ec2_volume_size}"
  }
}
