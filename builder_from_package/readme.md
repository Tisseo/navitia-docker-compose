# About

This project aims at building a set of docker images for navitia.

This will create 8 images :

 - navitia/kraken:version
 - navitia/jormungandr:version
 - navitia/tyr-beat:version
 - navitia/tyr-web:version
 - navitia/tyr-worker:version
 - navitia/instances-configurator:version
 - navitia/mock-kraken:version
 - navitia/eitri:version

The images are based on the navitia/debian[8|10]_dev docker image defined in https://github.com/hove-io/navitia_docker_images.

In order to build the different images, the navitia debian packages are retreived from github using (https://github.com/hove-io/core_team_ci_tools).

The `version` tag is determined from `git describe` called on the navitia source code used for building the images.

The script `build.sh` retreive the navitia source code along with the debian packages, and then launch docker build on each Dockerfile-*.


# Usage

Note: for debian8 based images, you need an internet access, and an access to the internal Hove apt repository http://apt.canaltp.local/debian/repositories (works when on VPN)

Usage
```
./build.sh -o github_oauth_token -d debian_version -b branch [-t tag] [-r -u dockerhub_user -p dockerhub_password] [-n]

```
where :

 - `github_oauth_token` is an oauth token to access github repositories with the `repo` scope. See https://docs.github.com/en/free-pro-team@latest/github/extending-github/git-automation-with-oauth-tokens
 - `branch` is either `dev` or `release`. It will fetch code and packages from the head of hove-io/navitia branch dev\release to build the images
 - `debian_version` is either `debian8` or `debian10`. It is the base image used to build all navitia images.
 - if the optional `tag` is provided, then the images will also be tagged as `navitia/component:tag` besides the default tag `navitia/component:version`
 - if the optional `-r -u dockerhub_user -p dockerhub_password` is given, the built images will be push to dockerhub. Note that if `-t tag` is present, then the `navitia/component:tag` images will be pushed to dockerhub along with the `navitia/component:version` ones.
 - if the optional `-n` is provided, then the script assume we are in github action CI and navitia debian packages are already present, and the download of theses packages will be skipped
