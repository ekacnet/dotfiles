#!/usr/bin/env bash
#
# Usage: ./update.sh repo

set -e
dir_bundle=$HOME/.vim/bundle
dir_autload=$HOME/.vim/autoload


repo=$1
plugin="$(basename $repo | sed -e 's/\.git$//')"

if [ "$plugin" = "vim-pathogen" ]; then
  dir=$dir_autload
else
  dir=$dir_bundle
fi


mkdir -p "$dir"
[ "$plugin" = "vim-styled-jsx" ] && plugin="000-vim-styled-jsx" # https://goo.gl/tJVPja
dest="$dir/$plugin"
rm -rf "$dest"
(
  git clone --depth=1 -q "https://github.com/$repo" "$dest"
  rm -rf "$dest/.git"
  echo "· Cloned $repo"
  [ "$plugin" = "onehalf" ] && (mv "$dest" "$dest.TEMP" && mv "$dest.TEMP/vim" "$dest" && rm -rf "$dest.TEMP")
  [ "$plugin" = "vim-pathogen" ] && (mv "$dest/autoload/pathogen.vim" "$dir" && rm -rf "$dest")
  [ "$plugin" = "LanguageClient-neovim" ] && (cd "$dest/LanguageClient-neovim" && ./install.sh)
) &
wait
