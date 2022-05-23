# Prests-deploy configuration

This documentation describes basic principles of **Presta-deploy** project configuration.

Configuration is managed at three different levels :
1. ***Local configuration*** level is defined for Presta-deploy itself.
    
    This configuration is managed by ``infra/env/deploy.env`` file and you can find a precise description of this file in ``infra/env/deploy.env.template``.
2. ***Environment configuration*** level is defined for ``$DEPLOY_ENV`` environment.
    
    This configuration is defined by ``infra/env/data/{$DEPLOY_ENV}/*.env`` files. You can find description in ``infra/env/template/*.env`` files.
    > :point_up: *Environment configuration* depends on *Local configuration*.
3. ***Services configuration*** level is defined for ``$DEPLOY_ENV`` environment for each service managed by **Presta-deploy**

    This configuration is defined by ``infra/env/data/{$DEPLOY_ENV}/{service_tag}/`` directories. You can find description in ``infra/env/template/{service_tag}/`` directories.
    > :point_up: *Services configuration* depends on *Environment configuration*.


## Configuration conventions

All configuration files are stored under ``infra/env/``

| ``env`` element        | Description                                                                                                               |
|------------------------|---------------------------------------------------------------------------------------------------------------------------|
| ``deploy.env``         | file used for presta-deploy self configuration.                                                                           |
| ``infra/env/template`` | prestashop configuration template (files list, directory structure, ...)                                          |
| ``infra/env/data``     | stores defined environment ( ``dev`` / ``development`` / ``test`` / ``demo`` / ... )                                      |
| ``infra/env/backup``   | stores cleaned/removed environments. This backup should give you a chance to restore a mistake due to ``make`` commandes. |


## Configuration process

In order to understand configuration usage, you can take a look at Makefile ``config-*`` commands.

For install, please follow this process :
1. *Local configuration*
    1. ``cp infra/env/deploy.env.template infra/env/deploy.env``
    2. Edit ``deploy.env`` values.
2. *Environment configuration*
    1. ``make config-prepare-env``
    2. Edit all ``*.env`` values you need.
3. *services configuration*
    1. ``make config-apply-env``


## Using environment variables

If you have *.env files, variables from env files are used.

If files not defined, variables are defined from environment.

If you don't have .env files neiher environment variables, you should encounter some weird behaviour.


## Xdebug configuration

Some usefull links :
- https://dev.to/jackmiras/xdebug-in-vscode-with-docker-379l
- https://php.tutorials24x7.com/blog/how-to-debug-php-using-xdebug-visual-studio-code-and-docker-on-ubuntu
- https://stackoverflow.com/questions/48546124/what-is-linux-equivalent-of-host-docker-internal/67158212#67158212

VSCode example :
```json
{
    "version": "0.2.0",
    "configurations": [
        {
            "name": "Listen psh",
            "type": "php",
            "request": "launch",
            "port": 9004,
            "pathMappings": {
                "/var/www/html": "${workspaceRoot}/src/prestashop"
            }
        },
    ]
}
```

> :notice: If you have any doubt, check `infra/docker/prestashop.docker-compose.yaml` and `infra/env/data/{DEPLOY_ENV}/prestashop/xdebug.ini` for parameter values

> :point_up: Take a look at https://code.visualstudio.com/docs/editor/debugging#_launch-configurations