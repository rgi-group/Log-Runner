module "microservice" {
  source    = "../../../../../../build/terraform/aws/lambda"
  appconfig = module.appconfig

  config = {
    name        = "microservice"
    description = "Substation node that acts as an asynchronous microservice"
    image_uri   = "${module.ecr.url}:v1.2.0"
    image_arm   = true

    memory  = 128
    timeout = 10
    env = {
      "SUBSTATION_CONFIG" : "http://localhost:2772/applications/substation/environments/example/configurations/microservice"
      "SUBSTATION_LAMBDA_HANDLER" : "AWS_SQS"
      "SUBSTATION_DEBUG" : true
    }
  }

  depends_on = [
    module.appconfig.name,
    module.ecr.url,
  ]
}

resource "aws_lambda_event_source_mapping" "microservice" {
  event_source_arn                   = module.sqs.arn
  function_name                      = module.microservice.arn
  maximum_batching_window_in_seconds = 10
  batch_size                         = 100
}
