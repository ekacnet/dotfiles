#!/usr/bin/env bash
{ # This ensures the entire script is downloaded.

set -eo pipefail

# Assume that install.sh is in the same folder that the one that contains dotfiles
basedir="$(readlink -f $(dirname $0)/dotfiles)"
if [ ! -e $basedir ]; then
  echo "$basedir didn't seems to exists, sorry"
  exit 1
fi
#repourl="git://github.com/statico/dotfiles.git"

function symlink() {
  src="$1"
  dest="$2"

  if [ -e "$dest" ]; then
    if [ -L "$dest" ]; then
      if [ ! -e "$dest" ]; then
        echo "Removing broken symlink at $dest"
        rm "$dest"
      else
        # Already symlinked -- I'll assume correctly.
        return 0
      fi
    else
      # Rename files with a ".old" extension.
      echo "$dest already exists, renaming to $dest.old"
      backup="$dest.old"
      if [ -e "$backup" ]; then
        echo "Error: "$backup" already exists. Please delete or rename it."
        exit 1
      fi
      mv -v "$dest" "$backup"
    fi
  fi
  ln -sf "$src" "$dest"
}

echo "Creating symlinks..."
pushd $basedir &>/dev/null
for item in * ; do
  case "$item" in
    .|..|.git|*.swp)
      continue
      ;;
    *)
      symlink "$basedir/$item" "$HOME/.$item"
      ;;
  esac
done
popd &>/dev/null

if [ -e $HOME/.bashrc.d/bashrc_append ]; then
	cat $HOME/.bashrc.d/bashrc_append >>$HOME/.bashrc
fi

vim_update=$HOME/.vim/update.sh
if [ -x $vim_update ]; then
	echo "Setting up vim plugins..."
	echo sh $HOME/.vim/update.sh
fi
exit 0

if which tmux >/dev/null 2>&1 ; then
  echo "Setting up tmux..."
  tpm="$HOME/.tmux/plugins/tpm"
  if [ -e "$tpm" ]; then
    pushd "$tpm" >/dev/null
    git pull -q origin master
    popd >/dev/null
  else
    git clone -q https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
  fi
  $tpm/scripts/install_plugins.sh >/dev/null
  $tpm/scripts/clean_plugins.sh >/dev/null
  $tpm/scripts/update_plugin.sh >/dev/null
else
  echo "Skipping tmux setup because tmux isn't installed."
fi

if which fzf >/dev/null 2>&1; then
  echo "Setting up fzf ..."
  fzf=$(dpkg -L fzf 2>&1|grep fzf.vim |head -1)
  if [ "a$fzf" == "a" ]; then
    fzf=$(rpm -ql fzf 2>&1|grep fzf.vim |head -1)
  fi
  if [ "a$fzf" != "a" -a -e $fzf ]; then
    mkdir -p "$HOME/.vim/bundle/fzf/autoload"
    ln -s $fzf "$HOME/.vim/bundle/fzf/autoload"
  fi
  fzf_vim="$HOME/.tmux/plugins/fzf.vim"
  if [ -e "$fzf_vim" ]; then
    pushd "$fzf_vim" >/dev/null
    git pull -q origin master
    popd >/dev/null
  else
    git clone -q https://github.com/junegunn/fzf.vim.git  "$HOME/.vim/bundle/fzf.vim"
  fi
fi


postinstall="$HOME/.postinstall"
if [ -e "$postinstall" ]; then
  echo "Running post-install..."
  . "$postinstall"
else
  echo "No post install script found. Optionally create one at $postinstall"
fi

echo "Done."

} # This ensures the entire script is downloaded.
