output "splunk_access_details" {
  value = {
    for instance in aws_instance.splunk_server :
    instance.tags["Name"] => {
      public_ip = instance.public_ip
      username  = "admin"
      password  = "admin123"
    }
  }
}

