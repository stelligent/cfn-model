#!/bin/bash -l

rvm use 2.2.1
rvm --force gemset delete cfn_model
rvm gemset use cfn_model --create

gem uninstall cfn-model -x
gem build cfn-model.gemspec
gem install cfn-model-0.0.0.gem --no-ri --no-rdoc

mkdir aws_sample_templates || true
pushd aws_sample_templates
wget https://s3-eu-west-1.amazonaws.com/cloudformation-examples-eu-west-1/AWSCloudFormation-samples.zip
rm *.template
rm -rf aws-cloudformation-templates
unzip AWSCloudFormation-samples.zip
git clone https://github.com/awslabs/aws-cloudformation-templates.git
templates=$(find . -name \*.template -o -name \*.yml -o -name \*.json -o -name \*.yaml)

for template in ${templates}
do
  cfn_parse ${template}
done
popd
