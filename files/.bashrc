# rbenv
export PATH="$HOME/.rbenv/bin:$HOME/.rbenv/shims:$PATH"
/home/autocargo/.rbenv/shims/gem

eval "$(rbenv init -)"

export EDITOR="vim"

# Some aliases
alias ll='ls -lh'
alias la='ls -A'
alias l='ls -CF'

alias ..='cd ..'
alias ...='cd ..; ll'

alias peg='ps -ef | grep -i'
alias psg='ps aux | grep '

alias myip='curl -s http://checkrealip.com/ | grep "Current IP Address"'

alias be="bundle exec"
alias migrate="bundle exec rake db:migrate; APP_ENV=test RACK_ENV=test RAILS_ENV=test bundle exec rake db:migrate"
