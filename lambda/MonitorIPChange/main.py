#!/usr/bin/env python3

import logging, socket, os
from datetime import date
import boto3

root = logging.getLogger()
if root.handlers:
    for handler in root.handlers:
        root.removeHandler(handler)
logging.basicConfig(format='%(asctime)s - %(levelname)s - %(message)s',level=logging.INFO)


def lambda_handler(event, context):
  err_msg = None

  endpoint_url = os.environ.get('ENDPOINT_URL')
  if (not endpoint_url): 
    err_msg = 'A valid value must be specified in ENDPOINT_URL environment variable'

  target_group_arn = os.environ.get('NLB_TARGET_GROUP_ARN')
  if (not target_group_arn): 
    err_msg = 'A valid value must be specified in NLB_TARGET_GROUP_ARN environment variable'

  docdb_ip_param_name = os.environ.get('DOCDB_IP_PARAM_NAME')
  if (not docdb_ip_param_name): 
    err_msg = 'A valid value must be specified in DOCDB_IP_PARAM_NAME environment variable'

  if (err_msg): 
    logging.error(err_msg)
    return dict(
      statusCode = 500,
      headers = { 'Content-Type': 'application/json' }, 
      body = dict(
        err_code = 500, 
        err_message = err_msg
      )
    )

  ssm_client = boto3.client('ssm')
  ssmps_response = ssm_client.get_parameter(Name=docdb_ip_param_name)
  docdb_saved_ip_address = ssmps_response['Parameter']['Value']
  logging.info('Saved IP address value in Parameter Store: ' + docdb_saved_ip_address)
  
  endpoint_ip_address = socket.gethostbyname(endpoint_url) 
  logging.info('Endpoint URL and resolved IP address: %s [%s]' % (endpoint_url, endpoint_ip_address))

  nlb_client = boto3.client('elbv2')
  nlb_target_health = nlb_client.describe_target_health(
    TargetGroupArn = target_group_arn
  )

  nlb_current_targets = list(map(lambda x: dict(Id=x['Target']['Id']), nlb_target_health['TargetHealthDescriptions']))
  logging.info('Current NLB targets: ' + str(nlb_target_health))
  
  if docdb_saved_ip_address != endpoint_ip_address: 
    # docdb cluster ip address has changed since last execution
    logging.info('Saved IP address does not match resolved IP address.')

    # register the new ip
    logging.info('Registering resolved IP address as NLB target...')
    nlb_response = nlb_client.register_targets(
      TargetGroupArn = target_group_arn,
      Targets = [{'Id': endpoint_ip_address}]
    )
    logging.debug('Response from NLB: ' + str(nlb_response))

    # deregister the old ip
    logging.info('Deregistering prior target(s) attached to NLB...')
    nlb_response = nlb_client.deregister_targets(
      TargetGroupArn = target_group_arn,
      Targets = nlb_current_targets #[{'Id': 'string'}]
    )
    logging.debug('Response from NLB: ' + str(nlb_response))

    # save new ip to parameter store
    logging.info('Updating Parameter Store value with new resolved IP address...')
    ssmps_response = ssm_client.put_parameter(Name=docdb_ip_param_name, Value=endpoint_ip_address, Overwrite=True)
    logging.debug('Response from SSM: ' + str(ssmps_response))

  else: 
    # docdb cluster ip address is same as before 
    logging.info('Saved IP address matches resolved IP address. No action is taken.')

  return dict(
    statusCode = 200,
    headers = { 'Content-Type': 'application/json' }, 
    body = dict(
      endpoint_ip_address = endpoint_ip_address, 
      nlb_target_health = nlb_current_targets, 
      date = date.today().strftime("%Y-%m-%d")
    )
  )


# if called from terminal 
if __name__ == '__main__':
  print(lambda_handler(None, None))