# platina-goes-release
This is the 2.2 release branch for Platina Go-ES. This release targets
Debian 10 (Buster).

# About this release

The release build is done in a controlled environment created in `Dockerfile`.
This environment is used to ensure that we are building with the proper
tools and libraries.

The file `clone-github` in this directory is a shell script which does git
shallow clones of each of the build directories. You must edit this script
to add new packages, and to change which branch (or tag) is used to build
that package.

# Downloading build artifacts

After pushing to a release branch, that release will be built. Each build
produces artifacts, which are the Debian packages built, as well as a ZIP
archive used for the BMC firmware and a CPIO archive for the goes-boot
installer recovery image.

After a successful build, navigate to the Jenkins server on `platina4`, port
8080. Choose download artifacts, which will give you a ZIP file of all of the
build products.

# Using Aptly

There is an Aptly repository on `platina4` in `/home/kph/.aptly`. The new release
developer should make a copy of this and work with their own copy. Do not
start with a fresh Aptly repository, as you will have to re-add all of the
releases, which introduces the possiblity of breaking APT on our client systems
if there are any packages which have the same name but different contents.

This build is presently referred in Aptly as buster-unstable. This was created
in aptly by doing:

```console
aptly repo create -distribution=buster -component=main platina-buster-unstable
```

**Do not execute this command. I already did it. It'll probably give you an
error. I at least hope it doesn't wipe what you have there.**

Assuming you have downloaded the ZIP archive into an empty directory,
the following command will add the new archive into the repository:

```console
aptly repo add platina-buster-unstable *.deb
```

You will get some errors about duplicate packages. This means that the package
version has not changed, but the contents have. This is normal and expected
as not all of our packages follow the Debian rule of having nothing baked
in from runtime, like C will do if the package uses such things as `__DATE__`
and `__TIME__`. Likewise, the Golang compiler bakes all kinds of stuff into
the package based on date and time, so if the package has no changes,
you can ignore the error.

**Do not use Aptly's option to override package conflicts. This will break
APT on all of our client machines.** *Yes, I did that once...*

Aptly uses the concept of snapshots. A snapshot holds the package state
of a repo at a given time.

```console
aptly snapshot list
```

Will show you all of the current snapshots. These releases are based on
version numbers like 2.2~alpha.XXX - find the latest XXX and use one
more than that. Or switch to beta, or just versions like 2.2 for a
release.

As of this writing, the latest published version is 2.2~alpha.6.

To create the next alpha snapshot, do:

```console
aptly snapshot create platina-buster-unstable-2.2~alpha.7 from repo platina-buster-unstable
```

Once the new snapshot is created, unpublish what is there:

```console
aptly publish drop buster-unstable
```

Publish the new snapshot:

```console
aptly publish snapshot platina-buster-unstable-2.2~alpha.7
```

You will be asked to sign the release with your gpg key.

After you do this, use rsync to sync your `~/.aptly/public` folder contents
to `goesdeploy@platina.io:/srv/goes/debian/`.

# Publishing BMC firmware

The BMC server firmware must be copied using `scp` to platina.io:

```console
scp platina-mk1-bmc.zip goesdeploy@platina.io:/srv/goes/bmc/UNSTABLE/
```

# Publishing APT source locations and GPG keys

The build produces a package for APT source locations, and for GPG keys used
to sign those locations.

Debian packaging rules require APT source packages end with the string
`apt-source`. Likewise GPG keyring packages end with the string
`archive-keyring`.

If these packages change, you will need to update the versions at the top
of the debian distribution on `platina.io:/srv/goes/debian`. The names
of this are `platina-apt-source_buster-unstable.deb` and
`platina-archive-keyring-buster-unstable.deb`.

# Publishing new recovery versions of goes-boot

In the event that a goes-boot package can not be found on the sda or sdb
devices in a MK1, the boot firmware `goes-bootrom` will fetch one from
platina.io. This filename is baked into firmware (but can be overriden
in the UI for testing), so generally this should be the stable release
and not installed from unstable. There is no difference between the image
here and the one installed to the boot partition, so this is generally
not needed for testing.

However, to provide a new version, you must use `scp` and copy a new file
into `platina.io:/srv/goes/`.

```console
scp goes-boot-platina-mk1.cpio.xz goesdeploy@platina.io:/srv/goes/
```


# Publishing a new root file system for the goes-boot installer

**This is included here for completeness. The root file system is not
built as part of a MK1 release. It is a seperate build in the *buildroot*
project.**

The install command downloads `rootfs.cpio.xz` from `platina.io:/srv/goes`.
This is generated by buildroot and you should only need to change it if
you want to pick up new busybox versions or update the debootstrap script
used by the installer.
