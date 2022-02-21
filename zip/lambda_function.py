import datetime
import boto3
import json
import logging
import os

from datetime import date

logger = logging.getLogger()
logger.setLevel(logging.INFO)

DYNAMO_TABLE = os.environ['DYNAMO_TABLE']


def how_old_am_i(orig_date):
    current_date = date.today()
    wynik = current_date - orig_date
    return (wynik.days)


def convert_to_datetime(orig_date):
    splited = orig_date.split('-')
    return date (int(splited[0]),int(splited[1]),int(splited[2]))


def find_ami(ami_id):
    full_info = {}
    dynamodb = boto3.resource('dynamodb')
    db = dynamodb.Table(DYNAMO_TABLE)
    result = db.get_item(
            Key={
                'ami_id': ami_id
            }
            )
    try:
        full_info ['date'] = (convert_to_datetime((result['Item']['date'])))
        full_info ['description'] = result['Item']['description']
    except:
        full_info ['date'] = (date.today() + datetime.timedelta(days=1))
        full_info ['description'] = 'INVALID'
    return full_info

def show_me_my_state(age):
# ACTIVE
# DEPRECATED
# OBSOLETE
# DELETED
# INVALID
    if age < 0:
        return('INVALID')
    elif age <14:
        return ('ACTIVE')
    elif age <21:
        return('DEPRECATED')
    elif age < 28:
        return('OBSOLETE')
    else:
        return('DELETED')


def test_me_from_cli():
    do_testow = ['ami-0e9ab978cb2c45a55','ami-xxxxxxxxxxxxxxxxx','ami-yyyyyyyyyyyyyyyyyy','ami-wwwwwwwwwwwwwwwww','ami-yyyyyyyyyyyyyyyyyZ']
    for x in do_testow:
        find_me = find_ami(x)
        official = {}
        official['state'] =  show_me_my_state(how_old_am_i(find_me['date']))
        official['description'] = find_me['description']
        print (official)
        print('')
    return 0


def lambda_handler(event,context):
    find_me = find_ami(event['ami_id'])
    official = {}
    official['state'] =  show_me_my_state(how_old_am_i(find_me['date']))
    official['description'] = find_me['description']
    return official
