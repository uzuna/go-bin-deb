#!/bin/sh -e

# this is an helper
# to use into your travis file
# it is limited to amd64/386 arch
#
# to use it
# curl -L https://raw.githubusercontent.com/mh-cbon/go-bin-deb/master/setup-deb-repository.sh \
# | GH=mh-cbon/gh-api-cli EMAIL=mh-cbon@users.noreply.github.com sh -xe

# GH=$1
# EMAIL=$2

REPO=`echo ${GH} | cut -d '/' -f 2`
USER=`echo ${GH} | cut -d '/' -f 1`

# clean up build.
rm -fr ${REPO}-*.rpm
rm -fr ${REPO}-*.deb

sudo apt-get install build-essential -y

if type "gh-api-cli" > /dev/null; then
  echo "gh-api-cli already installed"
else
  curl -L https://raw.githubusercontent.com/mh-cbon/latest/master/install.sh | GH=mh-cbon/gh-api-cli sh -xe
fi

git remote -v
git fetch --all
git config user.name "${USER}"
git config user.email "${EMAIL}"
if [ `git symbolic-ref --short -q HEAD | egrep 'gh-pages$'` ]; then
  echo "already on gh-pages"
else
  if [ `git branch -a | egrep 'remotes/origin/gh-pages$'` ]; then
    # gh-pages already exist on remote
    git checkout gh-pages
  else
    git checkout -b gh-pages
    find . -maxdepth 1 -mindepth 1 -not -name .git -exec rm -rf {} \;
    git commit -am "clean up"
  fi
fi

rm -fr apt
# mkdir -p apt/binary-{i386,amd64} # huh ... it won t work ?
mkdir -p apt/binary-i386
mkdir -p apt/binary-amd64
gh-api-cli dl-assets -o ${USER} -r ${REPO} --out apt/%r-%v_%a.%e -g "*deb" --ver latest


cd apt
dpkg-scanpackages -a amd64 . /dev/null | gzip -9c > binary-amd64/Packages.gz
dpkg-scanpackages -a 386 . /dev/null | gzip -9c > binary-i386/Packages.gz

cat <<EOT > ${REPO}.list
deb [trusted=yes] https://${USER}.github.io/${REPO}/apt/ /binary-\$(ARCH)/
EOT

git add -A
git commit -m "Created debian repository"

git status
git branch

set +x # disable debug output because that would display the token in clear text..
echo "git push --force --quiet https://GH_TOKEN@github.com/${GH}.git gh-pages"
git push --force --quiet "https://${GH_TOKEN}@github.com/${GH}.git" gh-pages \
 2>&1 | sed -re "s/${GH_TOKEN}/GH_TOKEN/g"
