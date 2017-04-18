---
License: MIT
LicenseFile: LICENSE
LicenseColor: yellow
---
# {{.Name}}

{{template "license/shields" .}}

{{pkgdoc}}

# Usage

```sh
export GHTOKEN=`gh-api-cli get-auth -n release`

vagrant up cli

vagrant rsync cli && vagrant ssh cli -c "export GHTOKEN=$GHTOKEN; sh /vagrant/vagrant-run.sh"

vagrant destroy cli -f
```

# See also

https://github.com/mh-cbon/go-bin-deb#recipes