output "instance_id" {
  value = tolist(aws_instance.instance[*].id)
}
