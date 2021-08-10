import subprocess
from minio import Minio
import os
import json
import s3fs

def __get_minio_client__(tenant):
    """ Get the variables out of vault to create Minio Client. """

    if tenant not in ("standard", "premium"):
        print("Not a valid resource! Options are")
        print("standard, premium")
        print("We will try anyway...")

    #vault = f"/vault/secrets/minio-{tenant}-tenant-1"

    with open(f'/vault/secrets/minio-{tenant}-tenant-1.json') as f:
        creds = json.load(f)
        minio_url = creds['MINIO_URL']

    import re
    # Get rid of http:// in minio URL
    http = re.compile('^https?://')

    # Create the minio client.
    client = Minio(
        http.sub("", creds['MINIO_URL']),
        access_key=creds['MINIO_ACCESS_KEY'],
        secret_key=creds['MINIO_SECRET_KEY'],
        secure=minio_url.startswith('https'),
        region="us-west-1"
    )

    return client


# def get_standard_client():
#     """Get a connection to the minimal Minio tenant"""
#     return __get_minio_client__("standard")

# def get_premium_client():
#     """Get a connection to the premium Minio tenant"""
#     return __get_minio_client__("premium")


# __get_minio_client__('standard')
