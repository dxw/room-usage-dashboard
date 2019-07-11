[
  {
    "essential": true,
    "memoryReservation": null,
    "image": "${image}",
    "name": "${container_name}",
    "logConfiguration": {
      "logDriver": "json-file"
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
