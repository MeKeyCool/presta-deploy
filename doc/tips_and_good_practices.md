# Tips and good practices 


## Configuring your browser

If you encounter some troubles with HTTP/HTTPS redirect policy, take a look to [Disable HTTPS Redirect in Firefox](https://itadminguide.com/disable-https-redirect-in-firefox/). Changing web browser or testing with curl may help.



## Docker

If you need to investigate docker network for ssl/redirect configurations, you can use : `curl -v --insecure https://${PROXY_BASE_HOSTNAME}/install-dev/index.php`
> :point_up: take `PROXY_BASE_HOSTNAME` from `PROXY_BASE_HOSTNAME_LIST`. (cf. your `proxy.env` file)

Clean all your local Docker environment
```sh
docker stop $(docker ps -a -q)
docker rm -v $(docker ps -a -q)
docker volume rm $(docker volume ls -q -f dangling=true)
docker network rm $(docker network ls -q --filter type=custom)
docker rmi $(docker images -a -q) -f
docker builder prune -f
docker system prune -a -f
```


## Git

Use case : you want to rebase a branch from a fork to Prestashop/develop branch (and you have a recommanded [develomment setup](development_setup.md))
Go to src/prestashop repository : `cd src/prestashop` and run followinf commands :
```sh
git remote add mf git@github.com:{my_fork}/PrestaShop.git
git fetch mf
git checkout mf/my_branch
git rebase -i develop
git push -f origin develop
```

Use case : you need to solve conflicts during a rebase.
```sh
Resolve all conflicts manually, mark them as resolved with
"git add/rm <conflicted_files>", then run "git rebase --continue".
You can instead skip this commit: run "git rebase --skip".
To abort and get back to the state before "git rebase", run "git rebase --abort".
```

Use case : you want to change an old commit OR you want to add a commit in history after a commit.
* ```sh
    git rebase --interactive '{commit id}^'
    ```
    > :point_up: Please note the caret `^` at the end of the command, because you need actually to rebase back to the commit before the one you wish to modify.
* In the default editor, modify `pick` to `edit` in the line mentioning '{commit id}'.
* Save the file and exit.
    > :point_up: At this point, '{commit id}' is your last commit (like if you just had created) and you can easily amend it.
* Make your changes :
  * If you want to change previous commit, use `git commit --amend`
  * If you want to add a new commit at this history point, use classical `git commit`
* To end, run `git rebase --continue`

> :point_up: More information :
> - [Rewriting-history](https://backlog.com/git-tutorial/rewriting-history/) 
> - [How to modify a specified commit?](https://stackoverflow.com/questions/1186535/how-to-modify-a-specified-commit)


Use case : you want to find the commit that induced a regression
> **TODO** `git bisect`

Use case : [Inserting a new commit in the Git history](https://blog.frankel.ch/inserting-new-commit-git-history/)





