#!/bin/bash -ex
export minor_version="0.6"
set -o pipefail

gem_name=cfn-model

set +x
if [[ -z ${rubygems_api_key} ]];
then
  echo rubygems_api_key must be set in the environment
  exit 1
fi
set -x

git config --global user.email "build@build.com"
git config --global user.name "build"

set +ex
mkdir ~/.gem
echo :rubygems_api_key: ${rubygems_api_key} > ~/.gem/credentials
set -ex
chmod 0600 ~/.gem/credentials

current_version=$(ruby -e 'tags=`git tag -l v#{ENV["minor_version"]}.*`' \
                       -e 'p tags.lines.map { |tag| tag.sub(/v#{ENV["minor_version"]}./, "").chomp.to_i }.max')

if [[ ${current_version} == nil ]];
then
  new_version="${minor_version}.0"
else
  new_version="${minor_version}.$((current_version+1))"
fi

sed -i.bak "s/9\.9\.9/${new_version}/g" ${gem_name}.gemspec

# publish rubygem to rubygems.org, https://rubygems.org/gems/cfn-model
gem build ${gem_name}.gemspec
gem push ${gem_name}-*.gem

echo "::set-output name=${gem_name/-/_}_version::${new_version}"
