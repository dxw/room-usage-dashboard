[
  {
    "essential": true,
    "memoryReservation": null,
    "image": "${image}",
    "name": "${container_name}",
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "${log_group}",
        "awslogs-region": "${log_region}"
      }
    },
    "portMappings": [
      {
        "hostPort": 0,
        "protocol": "tcp",
        "containerPort": ${container_port}
      }
    ],
    "entrypoint": ${entrypoint},
    "environment": [
      {
        "name": "SSM_PATH_SUFFIX",
        "value": "app"
      }
    ]
  }
]
