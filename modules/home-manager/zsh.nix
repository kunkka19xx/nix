{ lib
, config
, pkgs
, commands
, ...
}:

with lib;

let
  cfg = config.within.zsh;
in
{
  options.within.zsh.enable = mkEnableOption "Enables ZSH Settings";

  config = mkIf cfg.enable {
    home.packages = [
      pkgs.bat
      pkgs.ripgrep #grep string telescope
      pkgs.zsh-powerlevel10k
    ];
    programs.fzf = {
      enable = true;
      enableZshIntegration = true;
    };

    programs.zsh = {
      plugins = [{
        name = "fzf-tab";
        src = "${pkgs.zsh-fzf-tab}/share/fzf-tab";
      }];
      enable = true;
      # autosuggestion Configuration Options
      autosuggestion.enable = true;
      autosuggestion.strategy = [
        "history"
        "completion"
      ];
      enableCompletion = true;
      syntaxHighlighting.enable = true;
      oh-my-zsh = {
        enable = true;
        theme = "robbyrussell";
        plugins = [
          "git"
        ];
      };
      history = {
        size = 50000;
        save = 50000;
        path = "${config.xdg.dataHome}/zsh/history";
        append = true;
        expireDuplicatesFirst = true;
        share = true;
      };
      shellAliases = {
        dc = "docker-compose";
        rm = "rm -i";
        k = "kubectl";
        v = "nvim";
        f = "fzf";
        fp = "fzf --preview='bat --color=always {}'";
        fv = "nvim $(fzf -m --preview='bat --color=always {}')";
        gcof = "git fetch && git checkout $(git branch | fzf | sed 's/^..//')";
        lzd = "lazydocker";
        slzd = "sudo lazydocker";
      };
      initExtra = ''
        bindkey -v
        bindkey '^F' autosuggest-accept
        gpup() {
          local branch=$(git rev-parse --abbrev-ref HEAD)
          git push --set-upstream origin "$branch"
        }
        opg() {
          local base="$HOME/Documents/git"
          local dir
          dir=$(find "$base" -mindepth 1 -maxdepth 1 \( -type d -o -type l \) -exec test -d {} \; -print | fzf)
          if [[ -n "$dir" ]]; then
            cd "$dir"
          else
            cd "$base"
          fi
        }
        op() {
          local user_dir="$HOME"
          local dir
          dir=$(find "$user_dir" -mindepth 1 -maxdepth 1 -type d ! -name '.*' | fzf) && cd "$dir"
        }
        qss() {
          local nix_dir="$HOME/nix"
          local git_base="$HOME/Documents/git"

          if ! tmux has-session -t nix 2>/dev/null; then
            # Window 1: Vim
            tmux new-session -d -s nix -c "$nix_dir" "vim"

            # Window 2: bash
            tmux new-window -t nix -c "$nix_dir"
          fi

          local dir
          local base="$HOME/Documents/git"

          dir=$(find "$base" -mindepth 1 -maxdepth 1 -type d ! -name '.*' | fzf)

          local name="$(basename "$dir")"

          if ! tmux has-session -t "$name" 2>/dev/null; then
            # Window 1: Vim
            tmux new-session -d -s "$name" -c "$dir" "vim"

            # Window 2: bash
            tmux new-window -t "$name:" -c "$dir"
            tmux select-window -t "$name:1" # select vim window
          fi
           if [[ -n "$TMUX" ]]; then
            tmux switch-client -t "$name"
          else
            tmux attach-session -t "$name"
          fi       
        }
      '';
    };
  };
}
