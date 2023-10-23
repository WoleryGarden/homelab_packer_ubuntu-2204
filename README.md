# Packer template of ubuntu 22.04 to run on vSphere builder

This template is designed to be run in an automated pipeline, that uses [octomerge](https://github.com/BarfootThompson/octomerge). I'm running it on schedule from [awx](https://github.com/ansible/awx). This does not have to be used with Vault, all the variables can come from `vars.toml` but it makes sense to put sensitive information in Vault.

* Create `vars.toml` file see an example in `vars.toml.example` with your custom values. You can mix and match regular values and ones that will be read from vault.
* Run `octomerge vars.toml -x` to merge the variable values from `vars.toml` to respective templates (`variables.json.template` and `http/user-data.template`)
* Run `packer build -force -var-file variables.json ubuntu-2204-base.json`

The packer template serves the preseed file on a particular port, because in my case there is a firewall between packer and vSphere, so I need a particular port for the firewall rule. `preseed_http_ip` is usuful when the packer run is started from a container to specify the external IP, that packer otherwise would not know.

It is assumed that you have put the ISO file at the datastore and path you configured with `vcenter_iso_datastore` and `vcenter_iso_path` variables in `vars.toml`.

The `test` folder can be used for running this outside of an automated pipeline. Check `test.toml ` for the correct path to your `vars.toml` in vault. Copy all the files from there to the root of the repository and run `test.cmd`. You'll need to have `packer` and `octomerge` on your path and you need to be logged it to Vault.
