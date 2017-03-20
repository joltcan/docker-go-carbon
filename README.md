# go-carbon

The awesome [go-carbon](https://github.com/lomik/go-carbon) from lomic, dockerized by me.

## Why diz?

I only need the binary, not all a full UI, so I :
* Compile go-carbon with golang docker
* Copy the static binary to a [scratch](https://hub.docker.com/_/scratch/) image.

## How do I get it rolling?

* docker pull jolt/go-carbon
* choose which ports to map:
  * 2003 for carbon
  * 2004 for carbon-pickle
  * 7002 for carbonlink
  * 7007 for pprof
  * 8008 for carbonserver
* In short ```docker run -d --name go-carbon -p 2003:2003 -p 8008:8008 --volume /srv/carbon:/srv/carbon jolt/go-carbon ```
* create the whisper storage directory (mkdir -p /srv/carbon/whisper)
* set the directory permission to UID 206 (chown 206 /srv/carbon/whisper)
* Edit the go-carbon.conf file to your liking.
* (Don't forget to modify sysctl settings per the [go-carbon](https://github.com/lomik/go-carbon#os-tuning) example if you use this config)

## Thanks to

[bodsch](https://github.com/bodsch/docker-go-carbon), who created the Dockerfile/Makefile that I started out with.
