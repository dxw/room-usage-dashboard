locals {
  app_github_owner = "dxw"
  app_github_repo  = "room-usage-dashboard"
  app_service_name = "app-${var.environment}"

  app_container_entrypoint = ["./docker-entrypoint.sh"]
  app_container_command    = ["rackup","--host","0.0.0.0","-p"]
}
