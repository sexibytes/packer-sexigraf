echo "Intialise SexiMenu"
cat >/root/.bashrc <<"EOL"
export LS_OPTIONS='--color=auto'
eval "`dircolors`"
alias ls='ls $LS_OPTIONS'
alias ll='ls $LS_OPTIONS -l'
export PYTHONSTARTUP=~/.pythonrc
if ! [ -z "$PS1" ]; then
  /root/seximenu/seximenu.sh
fi
EOL

# update seximenu for storage left fix
sed -i 's/sda1/dm-0/' /root/seximenu/seximenu.sh
exit 0
