#!/usr/bin/env bash
{ # This ensures the entire script is downloaded.
update_plugins=${1-1}
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
function linkall() {
  local base=$1
  local where=$2
  pushd $base &>/dev/null
  for item in $(dir -1) ; do
    case "$item" in
      .|..|.git|*.swp)
        continue
        ;;
      *)
        if [ "$where" != "$HOME" ]; then
          dest="$where/$item"
        else
          dest="$where/.$item"
        fi
        if [ -f $item ]; then
            symlink "$base/$item" $dest
        fi
        if [ -d $item ]; then
          test -e $dest || mkdir -p $dest
          linkall $base/$item $dest
        fi
        ;;
    esac
  done
  popd &>/dev/null
}
linkall $basedir $HOME


grep -q ".bashrc.d/bashrc_append" $HOME/.bashrc
if [ $? -ne 0 ];then
  echo "source $HOME/.bashrc.d/bashrc_append" >>$HOME/.bashrc
fi

repos=(
  tpope/vim-pathogen
  junegunn/fzf.vim
  mileszs/ack.vim
  sheerun/vim-polyglot
  dense-analysis/ale
  autozimu/LanguageClient-neovim.git
  Shougo/deoplete.nvim
  roxma/nvim-yarp
  roxma/vim-hug-neovim-rpc
)

other_repos=(
  airblade/vim-gitgutter
  alampros/vim-styled-jsx
  ap/vim-css-color
  docunext/closetag.vim
  ervandew/supertab
  haya14busa/incsearch.vim
  itchyny/lightline.vim
  jparise/vim-graphql
  junegunn/goyo.vim
  nfnty/vim-nftables
  qpkorr/vim-bufkill
  scrooloose/nerdtree
  statico/vim-inform7
  tpope/vim-commentary
  tpope/vim-endwise
  tpope/vim-eunuch
  tpope/vim-fugitive
  tpope/vim-repeat
  tpope/vim-rhubarb
  tpope/vim-sleuth
  tpope/vim-surround
  tpope/vim-unimpaired
  vim-scripts/openvpn
  wellle/targets.vim

  altercation/vim-colors-solarized
  arcticicestudio/nord-vim
  nanotech/jellybeans.vim
  rakr/vim-one
  sonph/onehalf
  tomasr/molokai
  vim-scripts/wombat256.vim
)

vim_update=$HOME/.vim/bin/update.sh
if [ $update_plugins -eq 1 ] && [ -x $vim_update ]; then
  echo "Setting up vim plugins..."

  for repo in ${repos[@]}; do
    sh $vim_update $repo
  done

fi
set +e
tmp_path=$(grep TMUX_PLUGIN_MANAGER_PATH $HOME/.tmux.conf)
set -e
which tmux &>/dev/null
if [ $? -eq 0 ] && [ -e $HOME/.tmux ] && [ x"$tmp_path" != x"" ]; then
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
  if [ "a$fzf" != "a" -a -e $fzf -a ! -e "$HOME/.vim/bundle/fzf/autoload/fzf.vim" ]; then
    mkdir -p "$HOME/.vim/bundle/fzf/autoload"
    ln -s $fzf "$HOME/.vim/bundle/fzf/autoload"
  fi
fi


if which clang-format >/dev/null 2>&1; then
  echo "Setting up clang-format ..."
  clang_format=$(dpkg -L clang-format 2>&1|grep clang-format.py |head -1)
  if [ "a$clang-format" == "a" ]; then
    clang_format=$(rpm -ql clang-format 2>&1|grep clang-format.py |head -1)
  fi
  if [ "a$clang_format" != "a" -a -e $clang_format ]; then
    ln -fs $clang_format "$HOME/.vim/bin"
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
