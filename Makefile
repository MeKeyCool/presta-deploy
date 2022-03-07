# Context variables
####################

# Useful to ensure files produced in volumes over docker-compose exec
# commands are not "root privileged" files.
export CURRENT_UID=$(shell id -u):$(shell id -g)

# PROJECT_NAME defaults to name of the current directory.
# should not be changed if you follow GitOps operating procedures.
export PROJECT_NAME = $(notdir $(PWD))

# export CURRENT_DATE = $(shell date +"%Y%m%d")

# export INFRA_SCRIPT_PATH = $(shell realpath ./scripts)
# export INFRA_DATA_BASE_PATH = $(shell realpath ./data/${DEPLOY_ENV})
export INFRA_DOCKER_PATH = $(shell realpath ./infra/docker)
export INFRA_ENV_BASE_PATH = $(shell realpath ./infra/env)
export INFRA_SRC_BASE_PATH = $(shell realpath ./src)


ifneq (,$(wildcard ${INFRA_ENV_BASE_PATH}/deploy.env))
    include ${INFRA_ENV_BASE_PATH}/deploy.env
    export
endif
export DOCKER_PSH_IMG=${DOCKER_REGISTRY_BASE_PATH}/${DOCKER_PSH_IMG_PATH}/${DOCKER_PSH_IMG_NAME}:${DOCKER_PSH_IMG_TAG}
# export INFRA_DOCKER_PROXY=${DOCKER_REGISTRY_BASE_PATH}/dockerhub
export INFRA_ENV_PATH = ${INFRA_ENV_BASE_PATH}/data/${DEPLOY_ENV}
export INFRA_SRC_PSH = ${INFRA_SRC_BASE_PATH}/prestashop

# Include services *.env files

ifneq (,$(wildcard ${INFRA_ENV_PATH}/networks.env))
    include ${INFRA_ENV_PATH}/networks.env
    export
endif

ifneq (,$(wildcard ${INFRA_ENV_PATH}/proxy.env))
    include ${INFRA_ENV_PATH}/proxy.env
    export
endif

ifneq (,$(wildcard ${INFRA_ENV_PATH}/presta.env))
    include ${INFRA_ENV_PATH}/presta.env
    export
endif


# Docker environment setup
export DOCKER_NETWORK = $(PROJECT_NAME)/network


## Meta commands used for internal purpose
############################################

# TODO : do we need better check ?
guard-%:
	@if [ -z '${${*}}' ]; then echo 'ERROR: variable $* not set' && exit 1; fi


## Infra
#########

infra-init: infra-run services-init-all
	# make services-reload-all

infra-run: guard-DOCKER_COMPOSE
	${DOCKER_COMPOSE} up -d --remove-orphans

infra-watch: infra-run logs

# stop containers and processes
infra-stop: guard-DOCKER_COMPOSE 
	${DOCKER_COMPOSE} stop

# we dissociate 'env' from 'infra' to avoid deployment "mistakes"; env is reserved for "risky" operations

# First local install (WARNING : needs pre-configuration, cf. Readme)
env-init: 
	git submodule update --init
	make docker-build-dev
	make infra-init

# Usefull for prestashop-deploy dev purpose : reset environment to fresh configured project 
env-reset: clean-all env-docker-clean config-restore
	rm -rf ${INFRA_SRC_PSH}
	
# Complete docker environment purge
# WARNING : This command will purge all docker environment (all projects) 
env-docker-clean:
	- docker stop $(shell docker ps -a -q)
	- docker rm -v $(shell docker ps -a -q)
	- docker volume rm $(shell docker volume ls -qf dangling=true)
	- docker network rm $(shell docker network ls -q --filter type=custom)
	- docker rmi $(shell docker images -a -q) -f
	# - docker builder prune -f
	# - docker system prune -a -f

# WARN this command should be used during dev only cause it prints some credentials
env-log:
	@printf '\n ==== Makefile ENV  ==== \n\n'
	@printenv | sort
	@printf '\n ==== psh.app ENV  ==== \n\n'
	make log-psh.app
	@printf "\n ==== psh.db ENV  ==== \n\n"
	@${EXEC_PSH_DB} 'printenv | sort'
	@printf '\n ==== psh.cli.php ENV  ==== \n\n'
	@${EXEC_PSH_CLI_PHP} 'printenv | sort'
	@printf '\n ==== psh.cli.npm ENV  ==== \n\n'
	@${EXEC_PSH_CLI_NPM} 'printenv | sort'


# env-gen-conf:
# 	find ${INFRA_ENV_PATH}/*.env.template | sed 's/\.template//g' | xargs -I {} sh -c "cp {}.template {}"
# 	@echo "\nNOTICE : Please update generated *.env files \n 	 cf. ${INFRA_ENV_PATH}\n"

# env-restore-conf:
# 	find ${INFRA_ENV_PATH}/*.env.back | sed 's/\.back//g' | xargs -I {} sh -c "cp {}.back {}"


## Diagnostic
##############

logs:
	$(DOCKER_COMPOSE) ps
	$(DOCKER_COMPOSE) logs -f

# TODO : review npm log commands
log-psh.cli:
	${EXEC_PSH_CLI_PHP} 'composer show'
	${EXEC_PSH_CLI_PHP} 'composer status'
	${EXEC_PSH_CLI_PHP} 'composer diagnose'
	${EXEC_PSH_CLI_NPM} 'npm check'

# Log by service
log-psh.app:
	@${EXEC_PSH_APP} 'printenv | sort'
	# ${DOCKER_COMPOSE} logs -f psh.app

# TODO : manage all services
log-psh.app-env:
	${DOCKER_COMPOSE} exec psh.app printenv

log-system:
	printenv
	docker info
	df -h
	docker system df
	# docker stats

## Config
##########

# This command moves current environment configuration to a backup directory. 
# TODO : should we allow silent backup remove ?
config-backup: guard-INFRA_ENV_BASE_PATH guard-DEPLOY_ENV
	-[ -d ${INFRA_ENV_PATH} ] && { rm -rf ${INFRA_ENV_BASE_PATH}/backup/${DEPLOY_ENV} && mkdir ${INFRA_ENV_BASE_PATH}/backup/${DEPLOY_ENV}; }
	-mv ${INFRA_ENV_PATH}/* ${INFRA_ENV_BASE_PATH}/backup/${DEPLOY_ENV}
	rm -rf ${INFRA_ENV_PATH}

# This command restores current environment configuration.
config-restore: guard-INFRA_ENV_BASE_PATH guard-DEPLOY_ENV
	rm -rf ${INFRA_ENV_PATH}
	mkdir ${INFRA_ENV_PATH}
	- cp -r ${INFRA_ENV_BASE_PATH}/backup/${DEPLOY_ENV}/* ${INFRA_ENV_PATH}

# This command builds "env files" and services configuration structures according template.
config-prepare-env:
	mkdir -p ${INFRA_ENV_PATH}
	cp -r ${INFRA_ENV_BASE_PATH}/template/* ${INFRA_ENV_PATH}

# Remove environment variable names from services configuration files to apply their values
# TODO : make envsubst quiet/silent
config-apply-env: guard-INFRA_ENV_PATH
	find ${INFRA_ENV_PATH} -type f | xargs -I {} sh -c "envsubst < {} | tee {}"



## Clean
#########

clean-config: config-backup
	rm -rf ${INFRA_ENV_PATH}

# clean-psh-cache:
# 	${DOCKER_COMPOSE} exec -u www-data:www-data -w ${DOCKER_PSH_WORKDIR} psh.app php bin/console ...
# 	cache:clear
# 	cache:pool:clear
# 	cache:pool:prune
# 	cache:warmup
# 	doctrine:cache:clear-*

clean-all: psh-clean clean-config


## Shell
#########

shell-psh.db: guard-EXEC_PSH_DB
	${EXEC_PSH_DB} '/bin/bash'

# TODO
# shell-psh.myql: guard-EXEC_PSH_DB
# 	${EXEC_PSH_DB} '??? -U presta -d presta'

shell-psh.app: guard-EXEC_PSH_APP
	${EXEC_PSH_APP} '/bin/bash'
	
shell-psh.cli.php: guard-EXEC_PSH_CLI_PHP
	${EXEC_PSH_CLI_PHP} '/bin/bash'

shell-psh.cli.npm: guard-EXEC_PSH_CLI_NPM
	${EXEC_PSH_CLI_NPM} '/bin/bash'
	
shell-psh.app-sudo: guard-DOCKER_COMPOSE
	${DOCKER_COMPOSE} exec -u root:root psh.app sh -c '/bin/bash'
	# ${DOCKER_COMPOSE} exec -u ${CURRENT_UID} psh.app sh -c '/bin/bash'


## Tests
#########

# test-all: test-phpunit test-sonarqube

# test-sonarqube: guard-SONAR_HOST_URL guard-SONAR_LOGIN guard-INFRA_SRC_PSH guard-INFRA_DOCKER_PROXY
# 	docker run --rm \
# 	-e SONAR_HOST_URL=${SONAR_HOST_URL} \
# 	-e SONAR_LOGIN=${SONAR_LOGIN} \
# 	-v "${INFRA_SRC_PSH}:/usr/src" \
# 	${INFRA_DOCKER_PROXY}/sonarsource/sonar-scanner-cli \
# 	-Dsonar.projectKey=prestashop -Dsonar.scm.disabled=true -Dsonar.exclusions=vendor/**,var/** \
# 	-Dsonar.php.coverage.reportPaths=var/logs/coverage-report.xml -Dsonar.php.tests.reportPath=var/logs/tests-report.xml

# For phpunit command line options : https://phpunit.readthedocs.io/fr/latest/textui.html
# TODO : take a look at ``--process-isolation`` arguments
# test-phpunit: guard-EXEC_PSH_CLI_PHP
# 	${EXEC_PSH_CLI_PHP} 'php vendor/phpunit/phpunit/phpunit --coverage-clover var/logs/coverage-report.xml --log-junit var/logs/tests-report.xml tests'
# 	# ${EXEC_PSH_CLI} 'php vendor/phpunit/phpunit/phpunit --debug --verbose tests'

## Docker
##########

#  TODO : review docker build directory (depends on environments ?)
docker-build-dev: guard-DOCKER_PSH_IMG guard-INFRA_DOCKER_PATH
	- docker image rm ${DOCKER_PSH_IMG}
	docker build \
		--build-arg working_dir=/var/www/html \
		-t ${DOCKER_PSH_IMG} -f ${INFRA_DOCKER_PATH}/build/Dockerfile.prestashop.7.4.dev ${INFRA_DOCKER_PATH}/build
	# docker build \
	# 	--build-arg working_dir=/var/www/html \
	# 	-t ${DOCKER_PSH_IMG} -f ${INFRA_DOCKER_PATH}/build/Dockerfile.prestashop.7.2.dev ${INFRA_DOCKER_PATH}/build

# docker-login-dev: guard-DOCKER_REGISTRY_TOKEN guard-DOCKER_REGISTRY_USER guard-DOCKER_REGISTRY_BASE_PATH
# 	@echo "Docker login (command not logged for security purpose)"
# 	@echo "${DOCKER_REGISTRY_TOKEN}" | docker login -u ${DOCKER_REGISTRY_USER} --password-stdin ${DOCKER_REGISTRY_BASE_PATH}

# docker-push-dev: guard-DOCKER_PSH_IMG
# 	make docker-login-dev
# 	docker push ${DOCKER_PSH_IMG}

# docker-publish-dev: docker-build-dev docker-push-dev


## Services admin
##################

# TODO separate services
# services-reload-all: guard-EXEC_PSH_APP
# 	${EXEC_PSH_APP} 'apachectl graceful'

services-init-all: psh-init

# # TODO
# services-backup-all:
# 	echo "todo"

# # TODO
# services-restore-all:
# 	echo "todo"


## Prestashop service admin
############################

# TODO : deep clean of directory structure (cache and logs)
psh-init: guard-EXEC_PSH_CLI_PHP guard-EXEC_PSH_CLI_NPM
	${EXEC_PSH_CLI_PHP} 'mkdir -p admin-dev/autoupgrade app/config app/logs app/Resources/translations cache config download img log mails modules override themes translations upload var'
	${EXEC_PSH_CLI_PHP} 'chmod -R a+w admin-dev/autoupgrade app/config app/logs app/Resources/translations cache config download img log mails modules override themes translations upload var'
	${EXEC_PSH_CLI_PHP} 'composer install'
	${EXEC_PSH_CLI_NPM} 'make assets'
	${EXEC_PSH_CLI_PHP} 'chmod -R a+w admin-dev/autoupgrade app/config app/logs app/Resources/translations cache config download img log mails modules override themes translations upload var'
	# ./tools/assets/build.sh
	# ${EXEC_PSH_CLI_PHP} 'php bin/console ...'

# TODO : how to clean / manage ${INFRA_SRC_PSH}/cache ? Not considered : admin-dev/autoupgrade app/config app/Resources/translations config img mails override
# TODO : find a way to remove sudos
# TODO : problem to fix with img
psh-clean: guard-INFRA_SRC_PSH guard-INFRA_DOCKER_PATH
	@echo "=== Remove install/dev artefacts"
	rm -rf ${INFRA_SRC_PSH}/themes/node_modules ${INFRA_SRC_PSH}/themes/core.js ${INFRA_SRC_PSH}/themes/core.js.map ${INFRA_SRC_PSH}/themes/core.js.LICENSE.txt
	rm -rf ${INFRA_SRC_PSH}/translations/fr-FR ${INFRA_SRC_PSH}/translations/sf-fr-FR.zip
	cd ${INFRA_SRC_PSH}; \
		sudo rm -rf app/logs log; mkdir -p app/logs log; \
		rm var/bootstrap.php.cache; \
		sudo rm app/config/parameters.php app/config/parameters.yml; \
		sudo rm -rf config/settings.inc.php config/themes/classic; \
		find app/Resources/translations -maxdepth 1 -mindepth 1 -type d ! -name 'default' -or -type f ! -name '.gitkeep' | xargs -I {} sh -c "sudo rm -rf {}"; \
		find download 	   -maxdepth 1 -mindepth 1 -type d -or -type f ! -name '.htaccess' ! -name 'index.php' | xargs -I {} sh -c "sudo rm -rf {}"; \
		find mails		   -maxdepth 1 -mindepth 1 -type d ! -name '_partials' ! -name 'themes' -or -type f ! -name '.htaccess' ! -name 'index.php' | xargs -I {} sh -c "sudo rm -rf {}"; \
		find modules 	   -maxdepth 1 -mindepth 1 -type d -or -type f ! -name '.htaccess' ! -name 'index.php' | xargs -I {} sh -c "sudo rm -rf {}"; \
		find translations  -maxdepth 1 -mindepth 1 -type d ! -name 'cldr' ! -name 'export' ! -name 'default' -or -type f ! -name 'index.php' | xargs -I {} sh -c "sudo rm -rf {}"; \
		find upload 	   -maxdepth 1 -mindepth 1 -type d -or -type f ! -name '.htaccess' ! -name 'index.php' | xargs -I {} sh -c "sudo rm -rf {}"; \
		find var/cache	   -maxdepth 1 -mindepth 1 -type d -or -type f ! -name '.gitkeep' 					   | xargs -I {} sh -c "sudo rm -rf {}"; \
		find var/logs 	   -maxdepth 1 -mindepth 1 -type d -or -type f ! -name '.gitkeep' 					   | xargs -I {} sh -c "sudo rm -rf {}"; \
		find var/sessions  -maxdepth 1 -mindepth 1 -type d -or -type f ! -name '.gitkeep' 					   | xargs -I {} sh -c "sudo rm -rf {}"; \
		find vendor 	   -maxdepth 1 -mindepth 1 -type d -or -type f ! -name '.htaccess'					   | xargs -I {} sh -c "sudo rm -rf {}"
	@echo "=== Remove npm and composer caches" 
	find ${INFRA_DOCKER_PATH}/prestashop/cache/npm      -maxdepth 1 -mindepth 1 -type d -or -type f ! -name '.gitignore' | xargs -I {} sh -c "rm -rf {}"
	find ${INFRA_DOCKER_PATH}/prestashop/cache/composer -maxdepth 1 -mindepth 1 -type d -or -type f ! -name '.gitignore' | xargs -I {} sh -c "rm -rf {}"

# TODO : test
psh-apply-guidelines: guard-EXEC_PSH_CLI_PHP guard-EXEC_PSH_CLI_NPM
	${EXEC_PSH_CLI_PHP} 'php ./vendor/bin/php-cs-fixer fix'
	${EXEC_PSH_CLI_NPM} 'npm run scss-lint'
	${EXEC_PSH_CLI_NPM} 'npm run scss-fix'