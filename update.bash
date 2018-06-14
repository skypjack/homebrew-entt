#!/bin/bash

# only argument should be the version to upgrade to
if [ $# != 1 ]
then
  echo "Expected version to update to"
  exit 1
fi

VERSION="$1"
URL="https://github.com/skypjack/entt/archive/v$VERSION.tar.gz"
FORMULA="entt.rb"

# download the repo at the version
# exit with error messages if curl fails
curl "$URL" --location --fail --silent --show-error --output archive.tar.gz
if [ $? != 0 ]
then
  exit 1
fi

# compute sha256 hash
HASH="$(openssl sha256 archive.tar.gz | cut -d " " -f 2)"

# delete the archive
rm archive.tar.gz

# change the url in the formula file
# the slashes in the URL must be escaped
ESCAPED_URL="$(sed -e 's/[\/&]/\\&/g' <<< "$URL")"
sed -i -e '/url/s/".*"/"'$ESCAPED_URL'"/' $FORMULA

# change the hash in the formula file
sed -i -e '/sha256/s/".*"/"'$HASH'"/' $FORMULA

# delete temporary file created by sed
rm "$FORMULA-e"

# run checks with homebrew
# print error message and exit if the checks fail
AUDIT_ERRORS="$(brew audit --strict $FORMULA)"
if [ -n "$AUDIT_ERRORS" ]
then
  echo "$AUDIT_ERRORS"
  exit 1
fi

# update remote repo
git add entt.rb
git commit -m "Update to v$VERSION"
git push origin master
