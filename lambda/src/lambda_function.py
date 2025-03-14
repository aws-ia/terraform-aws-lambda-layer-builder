"""
AWS Lambda Layer Creation Module

This module provides functionality to create AWS Lambda Layers containing Python packages and modules.
It supports installing packages from pip and/or including custom Python modules from a zip file.

The main workflow:
1. Takes input parameters specifying layer name, pip packages, and/or Python modules
2. Creates a temporary working directory with the correct Lambda layer structure
3. Installs specified pip packages and/or extracts provided Python modules
4. Creates a zip file of the layer contents
5. Uploads the zip file to S3

Key Functions:
    - format_requirements: Formats a list of pip packages into requirements.txt format
    - pip_install: Installs pip packages into a specified directory
    - s3_download: Downloads an object from S3
    - s3_upload: Uploads an object to S3
    - unzip_file: Extracts contents of a zip file
    - zip_directory: Creates a zip file from a directory
    - lambda_handler: Main Lambda function that orchestrates the layer creation process

Required Environment Variables:
    - s3_bucket_name: S3 bucket to store layer zip file
    - lambda_architecture: Target Lambda architecture (x86_64, arm64)
    - lambda_runtime: Target Lambda runtime (e.g. python3.9)

Dependencies:
    - boto3: AWS SDK for Python
    - aws_lambda_powertools: Utilities for AWS Lambda functions
"""

import inspect
import os
import subprocess
import zipfile
from typing import TYPE_CHECKING, Any, Dict, List

import boto3
from aws_lambda_powertools import Logger

if TYPE_CHECKING:
    from aws_lambda_powertools.utilities.typing import LambdaContext
    from mypy_boto3_s3 import S3Client
else:
    LambdaContext = object
    S3Client = object

# Initialize Logger
logger = Logger(__name__)
boto3.set_stream_logger(level=logger.log_level)
boto3.set_stream_logger("botocore", level=logger.log_level)

# Define constants
TMP_DIR = "/tmp/"
WORKING_DIR = TMP_DIR + "lambda-layer/"


def format_requirements(packages: List[str]) -> str:
    """
    Converts a list of packages into a multi-line string
    :param packages: List of pip packages to install
    :return: Multi-line string of pip packages to install
    """

    logger.info("Formatting Requirements")
    requirements = ""
    for p in packages:
        requirements += p
        requirements += "\n"

    return requirements


def pip_install(requirements: str, install_dir: str) -> None:
    """
    Creates requirements.txt from a multi-line packages string, and runs pip into a predefined installation directory.
    :param requirements: multi-line string of requirements/packages
    :param install_dir: directory in which to pip install packages into
    """

    req_path = "/tmp/requirements.txt"
    with open(req_path, "w", encoding="utf-8") as f:
        f.write(requirements)

    logger.info("Downloading packages - ")
    subprocess.call("cat " + req_path)

    retcode = subprocess.call(
        "pip3 install -r " + req_path + " --target " + install_dir
    )

    if retcode != 0:
        raise Exception(
            "pip install did not complete successfully - return code " + str(retcode)
        )


def s3_download(
    s3_client: S3Client, bucket_name: str, key_name: str, file_path: str
) -> None:
    """
    Gets an object from S3 and downloads to the specified path
    :param bucket_name: S3 Bucket from which to download the object from
    :param key_name: S3 Object to download
    :param file_path: Destination path for the downloaded S3 Object
    :return: True if object was present and downloaded, False if the object did not exist
    """

    logger.info(f"Downloading s3://{bucket_name}/{key_name} to {file_path}")
    s3_client.download_file(bucket_name, key_name, file_path)
    logger.info("Download completed successfully")


def s3_upload(
    s3_client: S3Client, file_path: str, bucket_name: str, s3_key: str
) -> None:
    """
    Uploads an object to S3 from the specified path
    :param file_path: Source path of the object being uploaded
    :param bucket_name: S3 Bucket to which to upload the object to
    :param s3_key: Destination S3 Key name
    """

    logger.info(f"Uploading {file_path} to s3://{bucket_name}/{s3_key}")
    s3_client.upload_file(Filename=file_path, Bucket=bucket_name, Key=s3_key)
    logger.info(f"Successfully uploaded file to s3://{bucket_name}/{s3_key}")


def unzip_file(file_path: str, directory_path: str) -> None:
    """
    Unzips a .zip file to a directory
    :param file_path: Path to zip file
    :param directory_path: Path to unzip to
    """

    logger.info("Unzipping " + file_path + " to " + directory_path)
    with zipfile.ZipFile(file_path, "r") as zip_ref:
        zip_ref.extractall(directory_path)


def zip_directory(dir_path: str) -> str:
    """
    Generates a .zip file for a specified directory
    :param dir_path: Path to directory to be zipped
    :return: Path to the zip file
    """
    zip_file_path = "/tmp/layer.zip"
    logger.info("Creating .zip file - " + zip_file_path)

    with zipfile.ZipFile(zip_file_path, "w", zipfile.ZIP_DEFLATED) as zip_file_handle:
        for root, _, files in os.walk(dir_path):
            for file in files:
                zip_file_handle.write(
                    os.path.join(root, file),
                    os.path.relpath(os.path.join(root, file), dir_path),
                )
    return zip_file_path


@logger.inject_lambda_context(log_event=True)
def lambda_handler(
    event: Dict[str, Any], context: LambdaContext  # pylint: disable=W0613
) -> Dict[str, str]:
    """
    Lambda handler that creates a Lambda Layer zip file containing Python packages and modules.

    Args:
        event (Dict[str, Any]): Lambda event containing:
            - layer_name (str): Name of the Lambda Layer
            - pip_packages (list, optional): List of pip packages to install
            - python_modules_zipfile (str, optional): S3 key of zip file containing Python modules
        context (LambdaContext): Lambda context object

    Returns:
        Dict[str, str]: Dictionary containing:
            - S3Bucket: Name of S3 bucket containing the layer zip
            - S3Key: S3 key of the layer zip file

    Raises:
        Exception: If required event parameters are missing or if pip install fails

    Environment Variables:
        - s3_bucket_name: S3 bucket to store layer zip file
        - lambda_architecture: Target Lambda architecture (e.g. x86_64, arm64)
        - lambda_runtime: Target Lambda runtime (e.g. python3.9)
    """
    try:
        boto_session = boto3.session.Session()
        s3_client: S3Client = boto_session.client("s3")

        s3_bucket_name = os.environ["s3_bucket_name"]
        lambda_architecture = os.environ["lambda_architecture"]
        lambda_runtime = os.environ["lambda_runtime"]

        # populate vars from event
        if "layer_name" in event.keys():
            layer_name = event["layer_name"]
        else:
            raise Exception("layer_name was not found in incoming event")

        if "pip_packages" in event.keys():
            logger.info("pip_packages key found. Will install packages from pip")
            install_from_pip = True
        else:
            logger.info(
                "pip_packages key NOT found. Will NOT install packages from pip"
            )
            install_from_pip = False

        if "python_modules_zipfile" in event.keys():
            logger.info(
                "python_modules_zipfile key found. Will include modules from .zip file"
            )
            include_modules = True
        else:
            logger.info(
                "python_modules_zipfile key NOT found. Will NOT include modules from .zip file"
            )
            include_modules = False

        if not install_from_pip and not include_modules:
            raise Exception(
                "Either one or both of the following keys must be present in event - 'pip_packages', "
                "'python_modules_zipfile'."
            )

        # general vars
        layer_path = "python/lib/" + lambda_runtime + "/site-packages"
        install_dir = WORKING_DIR + "/" + layer_path
        s3_key = layer_name + "_" + lambda_runtime + "_" + lambda_architecture + ".zip"

        # Run the workflow
        logger.info("Creating Directory - " + install_dir)
        os.makedirs(install_dir, exist_ok=True)
        

        if install_from_pip:
            pip_packages = event["pip_packages"]
            pip_install(format_requirements(pip_packages), install_dir)

        if include_modules:
            key_name = event["python_modules_zipfile"]
            layer_packages_path = TMP_DIR + "/" + key_name
            unzip_dir = WORKING_DIR + "/" + layer_path
            s3_download(s3_client, s3_bucket_name, key_name, layer_packages_path)
            unzip_file(layer_packages_path, unzip_dir)

        zip_file_path = zip_directory(WORKING_DIR)
        s3_upload(s3_client, zip_file_path, s3_bucket_name, s3_key)

        response_dict = {"S3Bucket": s3_bucket_name, "S3Key": s3_key}

        return response_dict

    except Exception as e:
        message = {
            "FILE": __file__.rsplit("/", maxsplit=1)[-1],
            "METHOD": inspect.stack()[0][3],
            "EXCEPTION": str(e),
        }
        logger.exception(message)
        raise
