# presta-deploy is a dev deployment environment for [Prestashop project](https://www.prestashop-project.org/)

This project is used to encapsulate **prestashop** in a convenient environment.

Thanks to it, it should be easy to deploy a ``dev``, ``demo``, ``test``, ... environment and to use it.

Thereby, presta-deploy manages environment, setup and dependencies questions for **Prestashop** purpose.


## Requirements

In order to use this project properly, you need

* [Docker Engine](https://docs.docker.com/engine/)
* [Docker-compose](https://docs.docker.com/compose/)
* [git](https://git-scm.com/)
* [make](https://en.wikipedia.org/wiki/Make_(software))


## Deployment

### Local run

1. For first install, configure your local environment 
    1. ``cp infra/env/deploy.env.template infra/env/deploy.env``
    2. Edit ``deploy.env`` values.
    3. ``make config-prepare-env``
    4. Edit all ``*.env`` values you need.
    5. ``make config-apply-env``
    > :point_up: For more information, read [TODO : add documentation]()
2. Up your environment : ``make env-init``

**UNDER WORK** : add / review / comment install steps
- Connect to your install : ${PROXY_BASE_HOSTNAME}/install-dev/ | ${PROXY_BASE_HOSTNAME}/install/




> :point_up: Take a look to `Makefile` commands. USefull for prestashop stack deployment.

> :point_up: Please notice that `presta-deploy` uses git submodules.


### Docker usage

**TODO**
* build / login / deploy
* environment variables
* Docker registry


## Development

### Tools and commands

You may need to clean all your local Docker environment :
```sh
docker stop $(docker ps -a -q)
docker rm -v $(docker ps -a -q)
docker volume rm $(docker volume ls -qf dangling=true)
docker network rm $(docker network ls -q --filter type=custom)
docker rmi $(docker images -a -q) -f
docker builder prune -f
```

## Usefull documentation

>:point_up: Please notice that you can find some internal documentation under ``doc/`` directory of this repository. 

* [Docker development best practices](https://docs.docker.com/develop/dev-best-practices/)
* [Docker-compose reference](https://docs.docker.com/compose/compose-file/compose-file-v3/)
* [Install Docker Engine](https://docs.docker.com/engine/install/)
* [Install Docker Compose](https://docs.docker.com/compose/install/)

### Prestashop specific documentation

* [Contributing](https://github.com/PrestaShop/PrestaShop/blob/develop/CONTRIBUTING.md)
* [Coding Standards](https://devdocs.prestashop.com/1.7/development/coding-standards/)

## Todo

* [ ] Enhance TODO list
* [ ] Find a way to make gitmodule "url" compliant with prestashop contributing (parameterize to remove 'git@github.com:MeKeyCool/PrestaShop.git')
* [ ] Ensure environment variables are used before *.env files => **TO CHECK**.
* [ ] Use dedicated "composer" image for composer commands ? 
* [ ] Solve "assets" subjects
  * https://devdocs.prestashop.com/8/basics/installation/localhost/#javascript-and-css-dependencies
  * Should be use a dedicated node docker image to run some commands ?
* [ ] Enhance install with data (tests / demo / dev / ...)
  * https://forums.docker.com/t/we-cant-push-a-docker-volume-so-now-what/56160
* [ ] Add composer cache local volume
* [ ] Remove those directories from root source repository :
    * admin-dev/autoupgrade app/config app/logs app/Resources/translations cache config download img log mails modules override themes translations upload var
* [ ] Add tests commands
* [ ] Add proxy for custom hostname
