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

### Local run

1. For first install, configure your local environment 
    1. ``cp infra/env/deploy.env.template infra/env/deploy.env``
    2. Edit ``deploy.env`` values.
    3. ``make config-prepare-env``
    4. Edit all ``*.env`` values you need.
    5. ``make services-config-all``
    > :point_up: For more information, read [TODO : add documentation]()
2. Up your environment : ``make env-init``

**UNDER WORK** : add / review / comment install steps
- Connect to your install (take `PROXY_BASE_HOSTNAME` from `PROXY_BASE_HOSTNAME_LIST`): 
  - [auto-setup](${PROXY_BASE_HOSTNAME}/install-dev/index.php)
  - [front-office](${PROXY_BASE_HOSTNAME}/index.php)
  - [back-office](${PROXY_BASE_HOSTNAME}/admin-dev/index.php)


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
docker volume rm $(docker volume ls -q -f dangling=true)
docker network rm $(docker network ls -q --filter type=custom)
docker rmi $(docker images -a -q) -f
docker builder prune -f
docker system prune -a -f
```

If you want to rebase your current branch to Prestashop/develop :
```sh
git remote add ps git@github.com:PrestaShop/PrestaShop.git
git fetch ps
git rebase -i ps/develop
git push -f origin develop
```

If you need to solve conflicts during a rebase :
```sh
Resolve all conflicts manually, mark them as resolved with
"git add/rm <conflicted_files>", then run "git rebase --continue".
You can instead skip this commit: run "git rebase --skip".
To abort and get back to the state before "git rebase", run "git rebase --abort".
```

If you want to change an old commit :
> ```sh
> git rebase --interactive '{commit id}^'
> ```
> Please note the caret ^ at the end of the command, because you need actually to rebase back to the commit before the one you wish to modify.
> In the default editor, modify `pick` to `edit` in the line mentioning '{commit id}'.
> 
> Save the file and exit.
>
> At this point, '{commit id}' is your last commit (like if you just had created) and you can easily amend it.
>
> To end, run `git rebase --continue`
> 
> :point_up: More information :
> - [Rewriting-history](https://backlog.com/git-tutorial/rewriting-history/) 
> - [How to modify a specified commit?](https://stackoverflow.com/questions/1186535/how-to-modify-a-specified-commit)


> **TODO** git bisect


## Usefull documentation

>:point_up: Please notice that you can find some internal documentation under ``doc/`` directory of this repository. 

* [Docker development best practices](https://docs.docker.com/develop/dev-best-practices/)
* [Docker-compose reference](https://docs.docker.com/compose/compose-file/compose-file-v3/)
* [Install Docker Engine](https://docs.docker.com/engine/install/)
* [Install Docker Compose](https://docs.docker.com/compose/install/)

### Prestashop specific documentation

* [Contributing](https://github.com/PrestaShop/PrestaShop/blob/develop/CONTRIBUTING.md)
* [Contribution guidelines](https://devdocs.prestashop.com/1.7/contribute/contribution-guidelines/)
* [Coding Standards](https://devdocs.prestashop.com/1.7/development/coding-standards/)
* [Submitting code changes](https://devdocs.prestashop.com/8/contribute/contribute-pull-requests/)
* [Writing a good commit message](https://devdocs.prestashop.com/1.7/contribute/contribution-guidelines/writing-a-good-commit-message/)
* [Create a pull request](https://devdocs.prestashop.com/1.7/contribute/contribute-pull-requests/create-pull-request/)

### Dev and stack documentation

* [How To Debug PHP using Xdebug, VS Code and Docker](https://php.tutorials24x7.com/blog/how-to-debug-php-using-xdebug-visual-studio-code-and-docker-on-ubuntu)

## Todo

* Genericity and automation
  * [ ] Rename all containers anme to be project dependant (I want to be able install several instances of the project on my PC) => review `env-docker-clean` command to clean only project docker objects.
  * [ ] Make gitmodule "url" compliant with prestashop contributing (remove 'git@github.com:MeKeyCool/PrestaShop.git' from project dependency)
    1. Configure project to use main Prestashop project
    2. Configure your local git to replace Prestashop projects base url by your fork ones
       https://git-scm.com/docs/git-config#Documentation/git-config.txt-urlltbasegtinsteadOf
    > :point_up: Please add `-b <branch>` parameter to properly follow branches
  * [ ] Enhance install with data (tests / demo / dev / ...)
    * https://forums.docker.com/t/we-cant-push-a-docker-volume-so-now-what/56160
  * [ ] Add a complete cli install command
    * https://doc.prestashop.com/display/PS17/Installing+PrestaShop+using+the+command-line+script 
  * [ ] Add a warning to env commands
* Optimisation and project architecture
  * [ ] Script / command refactoring
    * Take a look at https://github.com/jolelievre/ps-install-tools
    * Take a look at src/prestashop/.github for CI actions / commands
  * [ ] Add some cache for phpstan and php_cs dev usage (not reset during psh-dev-reset)
  * [x] Add composer cache persistent volume
  * [/] Add node/npm cache persistent volume (It looks the used volume isn't the right one)
  * [/] Add tests commands (need some enhancement, genericity lacks)
  * [x] Add proxy for custom hostname
  * [ ] Solve git flow with versionned submodules
    * Take a look at https://git-scm.com/docs/git-update-index#_skip_worktree_bit option
      > :warning: Take a look at git version and submodule specific behaviors. This option may be tricky.
      >
      > :question: Can I still work inside submodule project with this option ?
  * [ ] Docker images build
    * [ ] Take a look at multi-stage builds. Use docker-compose `build` section with `context`, `target`, `args`
          doc : 
            https://docs.docker.com/develop/develop-images/multistage-build/
            https://docs.docker.com/compose/compose-file/build/
          example : https://stackoverflow.com/questions/36362233/can-a-dockerfile-extend-another-one
    * [ ] naming depending on php version, OS, etc.
    * [ ] Create a deploy.env variable for php base image tag
    * [ ] Create dedicated "composer" image for composer commands ? 
  * [ ] Remove `sudo` usage from Makefile => enhance docker volume usage => review Prestashop directories usage.
* Prestashop sources
  * [ ] Clean Prestashop src to ensure dedicated directories for install
    * [ ] Remove those directories from root source repository :
      * admin-dev/autoupgrade app/config app/logs app/Resources/translations cache config download img log mails modules override themes translations upload var
* Documentation and assets
  * [ ] Manage licensing
  * [ ] Review basic documentation on Prestashop-deploy project
* Proxy
  * [ ] Create timeout parameter to overwrite `infra/env/template/proxy/etc/nginx/vhost.d/prestashop.proxy` (take a look to php.ini as well)
  * [x] Find a proper setup to configure `infra/env/template/proxy/etc/nginx/vhost.d/prestashop.local` with ${PROXY_BASE_HOSTNAME} file name under ${INFRA_ENV_PATH}} directory and to replace environment variables.
  * [x] Remove hard coded `prestashop.local` in configurations (instead of ${PROXY_BASE_HOSTNAME})

