# https://snakemake.readthedocs.io/en/stable/executing/cloud.html#executing-a-snakemake-workflow-via-tibanna-on-amazon-web-services

### Install Snakemake into conda environment
# conda activate base
# mamba create -c conda-forge -c bioconda -n snakemake snakemake
# conda activate snakemake
### Install Tibanna into conda environment
# git clone https://github.com/4dn-dcic/tibanna
# cd tibanna
# git checkout v1.8.1
# python setup.py install
### Configure AWS credentials
### https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-sso.html#sso-configure-profile
# aws configure sso
# export AWS_PROFILE=<profile_name>
# aws sso login
### Deploy Tibanna Unicorn to AWS
# tibanna deploy_unicorn -g <group_name> -b <bucket>
### End of install steps

### Run these commands before executing this script
# export TIBANNA_DEFAULT_STEP_FUNCTION_NAME=tibanna_unicorn_<group_name>
# export DEFAULT_REMOTE_PREFIX=<bucket>/<subdir>
# export AWS_PROFILE=<profile_name>
# aws sso login

snakemake \
-p \
--snakefile 'Snakefile_aws' \
--use-conda \
--jobs 50 \
--tibanna \
--tibanna-sfn $TIBANNA_DEFAULT_STEP_FUNCTION_NAME \
--tibanna-config mem=60 \
--default-remote-prefix $DEFAULT_REMOTE_PREFIX \
--default-resources
