# dev-infras

A starting point for learning Terraform basics. This is a small ecosystem for quick, consistent per-environment creation.

---

FORK THIS REPO TO YOUR OWN _**PERSONAL**_ GITHUB SPACE BEFORE EXPERIMENTING.

---

## Getting Started

Check the docs for [one-time setup steps].

You can follow along with [the slides] if you like.

You'll need to use your own SSH Key; here's how to [generate and upload] one. Change the value for `instance.tf` (file) > `aws_instance` (resource) > [key_name].

Extra credit: _**HOW WOULD YOU VARIABLIZE THIS VALUE?**_

HINT: this works best if your local (workstation) user and remote (IAM/Federated) user both expand to the same value as `$USER`.

---

Source-in the project variables to your environment:

`source build.env <stage|prod>`

`make tf-init`, `make plan` and `make apply`.

[one-time setup steps]:https://github.com/todd-dsm/dev-infras/blob/main/docs/one-time-setup-stuff.md
[the slides]:https://docs.google.com/presentation/d/1Z9rXUV2jKjjwbsBgN6fw0v1GC_bfCgmwEnDOwUxZkH8/edit?usp=sharing
[generate and upload]:https://github.com/todd-dsm/mac-ops/wiki/Install-awscli#openssh-keys
[key_name]:https://github.com/todd-dsm/dev-infras/blob/packer-ami-test/mods/compute/instance.tf#L45
