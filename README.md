# presta-deploy is a dev deployment environment for [Prestashop project](https://www.prestashop-project.org/)

This project is used to encapsulate **prestashop** in a convenient environment.

Thanks to it, it should be easy to deploy a ``dev``, ``demo``, ``test``, ... environment and to use it.

Thereby, presta-deploy manages environment, setup and dependencies questions for **Prestashop** purpose.


## Requirements

In order to use this project on your environment, you need

* [Docker Engine](https://docs.docker.com/engine/)
* [Docker-compose](https://docs.docker.com/compose/)
* [git](https://git-scm.com/)
* [make](https://en.wikipedia.org/wiki/Make_(software))


## Deployment

### Local install

1. For first install, pre-configure your environment 
    1. ``cp infra/env/deploy.env.template infra/env/deploy.env``
    2. Edit ``deploy.env`` values.
    3. ``make env-init``
    4. Edit all required ``infra/env/data/${DEPLOY_ENV}/*.env`` values and customize what you want.
2. Then initialize your environment : ``infra-init``

> :point_up: Connect to your install (take `PROXY_BASE_HOSTNAME` from `PROXY_BASE_HOSTNAME_LIST`): 
> - **auto-setup** : https://{PROXY_BASE_HOSTNAME}/install-dev/index.php
> - **front-office** : https://{PROXY_BASE_HOSTNAME}/index.php
> - **back-office** : https://{PROXY_BASE_HOSTNAME}/admin-dev/index.php

> :point_up: Take a look to `Makefile` commands. Usefull to understand Prestashop install/deployment.

> :point_up: Please notice that `presta-deploy` uses git submodules.

> :point_up: If you configured custom host with `PROXY_BASE_HOSTNAME_LIST`, you may want to [edit your `hosts` file](https://www.howtogeek.com/howto/27350/beginner-geek-how-to-edit-your-hosts-file/).

> :point_up: By default, a SMTP server is configured on your local machine. You can access it over [http://localhost:8080/#/](http://localhost:8080/#/) link.


### Docker usage

**TODO**
* build / login / deploy
* environment variables
* Docker registry


## Development

### Contributing

If you want to use this project for Prestashop organization projects contribution, please start reading official guidelines :
* [Contributing](https://github.com/PrestaShop/PrestaShop/blob/develop/CONTRIBUTING.md)
* [Contribution guidelines](https://devdocs.prestashop.com/1.7/contribute/contribution-guidelines/)
* [Coding Standards](https://devdocs.prestashop.com/1.7/development/coding-standards/)
* [Submitting code changes](https://devdocs.prestashop.com/8/contribute/contribute-pull-requests/)
* [Writing a good commit message](https://devdocs.prestashop.com/1.7/contribute/contribution-guidelines/writing-a-good-commit-message/)
* [Create a pull request](https://devdocs.prestashop.com/1.7/contribute/contribute-pull-requests/create-pull-request/)

Once you are aware about Prestashop expectations, you may want to adapt your git configuration to push your local modifications to your own forks.
Please take a look at [Development setup](doc/development_setup.md)



## Usefull documentation

>:point_up: Please notice that you can find some internal documentation under ``doc/`` directory of this repository. 

* [Docker development best practices](https://docs.docker.com/develop/dev-best-practices/)
* [Docker-compose reference](https://docs.docker.com/compose/compose-file/compose-file-v3/)
* [Install Docker Engine](https://docs.docker.com/engine/install/)
* [Install Docker Compose](https://docs.docker.com/compose/install/)

### Dev and stack documentation

* [How To Debug PHP using Xdebug, VS Code and Docker](https://php.tutorials24x7.com/blog/how-to-debug-php-using-xdebug-visual-studio-code-and-docker-on-ubuntu)

## Todo

* Genericity and automation
  * [ ] Multi prestashop version management
    * [ ] Solve git flow with versionned submodules
      * Take a look at https://git-scm.com/docs/git-update-index#_skip_worktree_bit option
        > :warning: Take a look at git version and submodule specific behaviors. This option may be tricky.
        >
        > :question: Can I still work inside submodule project with this option ?
    * [ ] Add `INFRA_SRC_PSH_BASE_BRANCH` parameter to `infra/env/deploy.env.template` (default value defined in Makefile : `develop`)
      * Create `src/prestashop/{INFRA_SRC_PSH_BASE_BRANCH}` submodules
      * update `INFRA_SRC_PSH` and `INFRA_ENV_PATH` with `INFRA_SRC_PSH_BASE_BRANCH`
    * [ ] Branch naming convention
      * Convention : `{INFRA_SRC_PSH_BASE_BRANCH}/{type}/{issue #}/{specific_label}` 
      * Create a dedicated command (script ?) `psh-dev-prepare-branch`
        > ```sh
        > cd $INFRA_SRC_PSH
        > git diff --exit-code
        > git checkout {INFRA_SRC_PSH_BASE_BRANCH}
        > git fetch ...; git rebase; # should we force push {INFRA_SRC_PSH_BASE_BRANCH} ?
        > # Add a script to define new branch name (product/bugfix/feature/tmp/... type, issue # and specific label)
        > git checkout -b {new_branch_name}
        > ```
    * [ ] Organize project with source version dependant scripts (install / update / backup / ...) may change with versions.
  * [ ] Rename all containers name to be project dependant (I want to be able install several instances of the project on my PC) => review `env-docker-clean` command to clean only project docker objects.
  * Enhance fixtures management 
    * [ ] Prestashop backup / restore commands
    * [ ] Allow init with data (tests / demo / dev / ...)
      * https://forums.docker.com/t/we-cant-push-a-docker-volume-so-now-what/56160
  * [ ] Add a warning to env commands (Y/n option)
  * [ ] Add php, node and mysql version to project variables (deploy.env)
    * [ ] Create php version dedicated Dockerfiles.
* Optimisation and project architecture
  * [ ] Check `psh-clean-cache` command (it looks it breaks something, does it ?)
  * [ ] Create a dedicated Docker image for all dev tools : composer / node / gh / phpmyadmin
      - https://github.com/trussworks/docker-gh/blob/master/Dockerfile#L44-L48
      - :point_up: prestashop cli commands should be run from `psh.app`
      - Should node version be configurable as well ? :thinking:
  * [ ] Script / command refactoring & enhancement
    * Take a look at https://github.com/jolelievre/ps-install-tools
    * Take a look at https://github.com/SD1982/dockerQA
    * Take a look at src/prestashop/.github for CI actions / commands
  * [/] Add SMTP management
    * [x] create a [MailDEv](https://maildev.github.io/maildev/) container
      https://github.com/maildev/maildev
    * [x] sync maildev & prestashop
    * [ ] manage smtp configuration by dedicated variables.
  * [ ] Add some cache for phpstan and php_cs dev usage (specific reset for "env cache" and not reset during psh-dev-reset)
  * [/] Add node/npm cache persistent volume (It looks the used volume isn't enough)
    * [ ] We may enhance "reinstall" process using this trick : https://github.com/jolelievre/ps-install-tools/blob/master/tools/tools.sh#L120-L150
  * [ ] Docker images build
    * [/] Take a look at multi-stage builds. Use docker-compose `build` section with `context`, `target`, `args`
          doc : 
            https://docs.docker.com/develop/develop-images/multistage-build/
            https://docs.docker.com/compose/compose-file/build/
          example : https://stackoverflow.com/questions/36362233/can-a-dockerfile-extend-another-one
    * [ ] Consider new multiple build context docker feature
          doc :
            https://www.docker.com/blog/dockerfiles-now-support-multiple-build-contexts/
    * [ ] naming depending on php version, OS, etc.
    * [ ] Create a deploy.env variable for php base image tag
    * [ ] Create dedicated "composer" image for composer commands ?
      * Take a look at some tools
        * https://github.com/nenes25/prestashop_console
        * https://github.com/friends-of-presta/fop_console
  * [ ] Study BindFS configuration for right management.
        https://www.fullstaq.com/knowledge-hub/blogs/docker-and-the-host-filesystem-owner-matching-problem
* Prestashop sources
  * [ ] Clean Prestashop src to ensure dedicated directories for install
    * [ ] Remove those directories from root source repository :
      * admin-dev/autoupgrade app/config app/logs app/Resources/translations cache config download img log mails modules override themes translations upload var
* Documentation and assets
  * [ ] Consider adding prestashop devdoc to ./doc/prestashop (cf. https://github.com/PrestaShop/devdocs-site/blob/main/.gitmodules)
  * [ ] Add proxy configuration documentation (`infra/env/data/${DEPLOY_ENV}/proxy.env` and `infra/env/data/${DEPLOY_ENV}/proxy/etc/nginx` specific behavior)
* Proxy
  * [ ] Create timeout parameter to overwrite `infra/env/template/proxy/etc/nginx/vhost.d/prestashop.proxy` (take a look to php.ini as well)
  
