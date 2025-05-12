- Use this as a sub module using sub tree
  [refer atlassian](https://www.atlassian.com/git/tutorials/git-subtree)
  [refer git](https://docs.github.com/en/get-started/using-git/about-git-subtree-merges)

1. Add remote in the parent repo

```shell
git remote add nvim https://github.com/kunkka19xx/nvim.git
```

```shell
git fetch nvim
```

2. Add prefix

Please remove the old nvim in the parent repo

```shell
git subtree add --prefix=nvim/.config/nvim nvim main --squash
```

- This command adds child repo (remote name, main branch) into the `nvim/.config/nvim` directory in the parent repo

_in the nix repo_

```shell
git subtree add --prefix=dotfiles/nvim nvim main --squash
```

3. Push changes from parent repo

Be careful with the prefix (this should be correct)

```shell
git subtree push --prefix=nvim/.config/nvim nvim main
```

or (nix repo)

```shell
git subtree push --prefix=dotfiles/nvim nvim main
```

- If you want to sync anyway, remove --squash from 2nd step

4. Pull changes from child repo

- fetch remote
- pull with right prefix

```shell
git fetch nvim
git subtree pull --prefix=nvim/.config/nvim nvim main --squash
```

or (nix repo)

```shell
git fetch nvim
git subtree pull --prefix=dotfiles/nvim nvim main --squash

```
