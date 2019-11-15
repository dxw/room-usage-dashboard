#resource "aws_kms_key" "app_ssm" {
#  description             = "app SSM key ${terraform.workspace}"
#  deletion_window_in_days = 10
#}
#
#resource "aws_kms_alias" "app_ssm" {
#  name          = "alias/app-ssm-${terraform.workspace}"
#  target_key_id = "${aws_kms_key.app_ssm.key_id}"
#}
