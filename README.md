nCoda Linux Bundles
===================

Files to build the Linux distribution bundles for nCoda, including for Ubuntu-on-Windows.

A build script for Circle CI is forthcoming. Or maybe it's there already; take a look!

If you're not on Circle CI, then start up
[this Docker image](https://hub.docker.com/r/ncodamusic/linux-bundles/)
something like this:

```bash
$ sudo docker run -it ncodamusic/fedora-linux-bundles:26 bash
```

The copy the contents of this repository to `/root` (you only need the `*_RELEASE` files,
`ncoda_script`, and the `Makefile`). Then run the following commands in the `/root` directory:

```bash
$ make clone-repos
$ make build-venv
$ make finish-ncoda
$ make build-pex
$ make install-julius
$ make build-julius
$ make archive-http
$ make archive-electron
```

Your distribution bundles will be available at `/root/workdir/ncoda-electron.xz` and
`/root/workdir/ncoda-http.xz`.
