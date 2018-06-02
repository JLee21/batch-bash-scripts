# batch-bash-scripts

Just an assortment of scripts through the years

## .bashrc

```bash
# F I L E S
#alias ll='ls -alF'
alias l='clear && ls -alhX'
alias d='du -sh *'

# G I T
alias gs='clear && git status'
alias gl='clear && git log --oneline --graph'
alias gb='clear && git branch -va'
alias gr='clear && git remote -v'
alias gg='clear && git add --all :confused: && git commit -m "housekeeping" && gs'
alias ggg='clear && git add --all :confused: && git commit -m "housekeeping" && git push origin master && gs'

# B A S H
alias b='vi ~/.bashrc'
alias h='clear && history'
alias brc='clear && source ~/.bashrc'
```
