#!/bin/bash

### Echo errro function
echoerr() { echo "$@" 1>&2; }

### Select jruby version from latest jruby 9  version
jruby_versions=$(rvm ls | grep 'jruby-9' | sed -r 's/^.*(jruby-9[^ ]+).*$/\1/')
jruby_version=""

for candidate in $jruby_versions; do
  if [[ candidate > $jruby_version ]]; then
    jruby_version=$candidate
  fi
done

if [[ $jruby_version == "" ]]; then
  echoerr "Couldn't find jruby 9. Download it using 'rvm install'"
  exit 1
fi

### Getting gem name
gemset_name=$(cat '.ruby-gemset')
echo "Test for gem '$gemset_name' : Running with $jruby_version"

# ### Backup old gemfile lock
mv Gemfile.lock Gemfile.old

### Check if a folder for de ruby version and gemset doesn't exists
if [ ! -d $HOME/.rvm/gems/$jruby_version@$gemset_name/wrappers/ ]; then
  ### create gemset
  rvm $jruby_version do rvm gemset create $gemset_name

  ### Set jruby 9
  $HOME/.rvm/gems/$jruby_version@$gemset_name/wrappers/gem install bundler
fi

### Bundle and run tests
$HOME/.rvm/gems/$jruby_version@$gemset_name/wrappers/bundle
JRUBY_OPTS="--debug" $HOME/.rvm/gems/$jruby_version@$gemset_name/wrappers/bundle exec rake 

# ### Restore old gemfile lock
rm Gemfile.lock
mv Gemfile.old Gemfile.lock

### Restore original gemset
cd .