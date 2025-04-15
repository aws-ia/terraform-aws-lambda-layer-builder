FROM public.ecr.aws/codebuild/amazonlinux2-x86_64-standard:4.0
ENV TERRAFORM_VERSION=1.4.2
RUN cd /tmp && \
    wget https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
    unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip -d /usr/local/bin && chmod 755 /usr/local/bin/terraform

RUN curl -s https://raw.githubusercontent.com/aquasecurity/tfsec/master/scripts/install_linux.sh | bash

RUN pip3 install checkov
COPY ./config/.checkov.yaml ./
