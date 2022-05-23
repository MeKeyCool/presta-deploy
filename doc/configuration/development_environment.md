# Development environment configuration


## Don't add your IDE files to VCS history

> Cf. [Setting up a global gitignore file](https://sebastiandedeyne.com/setting-up-a-global-gitignore-file/)

Edit `~/.gitignore` add some lines depending  :
```
.vscode # Required for [VSCode](https://code.visualstudio.com/)
.ide    # Required [IntelliJ IDEA](https://www.jetbrains.com/fr-fr/idea/)

...
```

Afetr completing your global `.gitignore` file, run `git config --global core.excludesfile ~/.gitignore`


## Don't work directly in Prestashop repositories

This project is setup to link main prestashop projects.
Please configure your environment to push your changes on your own forks instead of main repositories

Edit `~/.gitconfig` adding some lines :
```
[url "git@github.com:{MyGithubAccount}/"]
  pushInsteadOf = https://github.com/PrestaShop/
  pushInsteadOf = git@github.com:PrestaShop/
```

> Cf. [How to rewrite git URLs to clone faster and push safer](https://jonhnnyweslley.net/blog/how-to-rewrite-git-urls-to-clone-faster-and-push-safer/) for some explanations
> 
> :point_up: Please notice you'll need to fork the project you want to contribute before to push your local work.


## git and ssh configurations 

Use case : What ssh algorithm should I use for keys ?
[Comparing SSH Keys - RSA, DSA, ECDSA, or EdDSA?](https://goteleport.com/blog/comparing-ssh-keys/)

```
ssh-keygen -a 100 -t ed25519 -f ~/.ssh/id_ed25519 -C "my-email@my-company.com"
```

Use case : Use different key/identity for different projects 
[Switching SSH Keys Between Git Projects](https://www.codeconcisely.com/posts/switching-ssh-keys-between-git-projects/)


