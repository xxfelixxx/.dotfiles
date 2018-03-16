# shellcheck disable=SC1091 # Don't follow
# shellcheck disable=SC2148 # Add a shebang.

# If not running interactively, don't do anything
[[ "$-" != *i* ]] && return

# Source global definitions
if [ -f /etc/bashrc ]; then
        . /etc/bashrc
fi

# felixthecat image
if [ -f ~/.felix/felix.txt ]; then
        cat ~/.felix/felix.txt
fi

DIR=$( dirname "${BASH_SOURCE[-1]}" )
unalias grep
GREP=$( command -v grep )

# some functions
if [ -f "$DIR/.bash_install_functions" ]; then
    # shellcheck disable=SC1090 # Don't follow
    . "$DIR/.bash_install_functions"
fi

# PS4 will output linenumbers when running a bash script as
# bash -x foo.sh
export PS4='+(${BASH_SOURCE}:${LINENO}): ${FUNCNAME[0]:+${FUNCNAME[0]}(): }'
export VISUAL=emacs
export EDITOR=emacs
export GIT_EDITOR=emacs

# Do it this way so that long lines don't get messed up
RED_0=$(    tput setaf 1)
GREEN_0=$(  tput setaf 2)
YELLOW_0=$( tput setaf 3)
BLUE_0=$(   tput setaf 4)
PURPLE_0=$( tput setaf 5)
CYAN_0=$(   tput setaf 6)
RESET_0=$(  tput sgr0   )

RED="\\[$RED_0\\]"
GREEN="\\[$GREEN_0\\]"
YELLOW="\\[$YELLOW_0\\]"
BLUE="\\[$BLUE_0\\]"
PURPLE="\\[$PURPLE_0\\]"
CYAN="\\[$CYAN_0\\]"
RESET="\\[$RESET_0\\]"

if is_freebsd; then
    RED_0='\e[1;31m'
    GREEN_0='\e[1;32m'
    YELLOW_0='\e[1;33m'
    BLUE_0='\e[1;34m'
    PURPLE_0='\e[1;35m'
    CYAN_0='\e[1;36m'
    RESET_0='\e[0m'

    RED="\\[$RED_0\\]"
    GREEN="\\[$GREEN_0\\]"
    YELLOW="\\[$YELLOW_0\\]"
    BLUE="\\[$BLUE_0\\]"
    PURPLE="\\[$PURPLE_0\\]"
    CYAN="\\[$CYAN_0\\]"
    RESET="\\[$RESET_0\\]"

fi

CHECK="${GREEN}o"
CROSS="${RED}x"

# Bash completion
[[ -f /etc/bash_completion ]] && . /etc/bash_completion

# History Options
#
# Don't put duplicate lines in the history.
export HISTCONTROL=$HISTCONTROL${HISTCONTROL+,}ignoredups
#
# Ignore some controlling instructions
# HISTIGNORE is a colon-delimited list of patterns which should be excluded.
# The '&' is a special pattern which suppresses duplicate entries.
# export HISTIGNORE=$'[ \t]*:&:[fb]g:exit'
export HISTIGNORE=$'[ \t]*:&:[fb]g:exit:ls' # Ignore the ls command as well

alias sqlplus='rlwrap -b "" -f $HOME/sql.dict /usr/lib/oracle/11.2/client64/bin/sqlplus'
alias df='df -h'
alias du='du -h'
alias diff='/usr/bin/colordiff'
alias less='less -r'                           # raw control characters
alias grep='grep --color --exclude=\*~'        # show differences in colour
alias egrep='egrep --color=auto --exclude=\*~' # show differences in colour
alias fgrep='fgrep --color=auto --exclude=\*~' # show differences in colour
alias fix='stty sane'                          # fix borked display, no clear

alias e='emacs -nw --no-site-file'
alias ls='ls --color=auto -B'

# echo "some message" | tb
alias tb="nc termbin.com 9999"
alias termbin="nc termbin.com 9999"

alias functions="declare -F | cut -b12-"       # Cutoff the declare -f
alias show_functions="declare -f"
alias variables="declare -p | perl -pe 's|^declare [-\\w]+ ||;'"

if command -v dmidecode 2>&1 >/dev/null; then
    BIOS_VERSION=$(sudo dmidecode -s system-version 2>/dev/null)
else
    BIOS_VERSION='amazon' # Force a check...
fi
VM=""
if echo "$BIOS_VERSION" | "$GREP" -q amazon; then
    ZONE=$(curl -s  http://169.254.169.254/latest/meta-data/public-hostname \
           | perl -ne 'm|ec2-\d+-\d+-\d+-\d+\.(.+?).compute|; print $1;')
    ZONE_NAME=$("$GREP" "$ZONE" ~/.aws_regions | perl -ne 's|^\S+\s||g; print')
    VM="[$ZONE_NAME]"
fi

FANCY_PROMPT="$GREEN\\u$YELLOW@\\h$BLUE$VM:$PURPLE\\w$BLUE$ $CYAN$RESET"

_prompt_command() {
    # Show   red x if last command failed
    # Show green o if last command succeeded
    case $? in
        0) PS1="$CHECK $FANCY_PROMPT" ;;
        *) PS1="$CROSS $FANCY_PROMPT" ;;
    esac
    history -a
    true
}

export PROMPT_COMMAND="_prompt_command"


LS_COLORS='rs=0:di=01;34:ln=01;36:mh=00:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:su=37;41:sg=30;43:ca=30;41:tw=30;42:ow=34;42:st=37;44:ex=01;32:*.tar=01;31:*.tgz=01;31:*.arj=01;31:*.taz=01;31:*.lzh=01;31:*.lzma=01;31:*.tlz=01;31:*.txz=01;31:*.zip=01;31:*.z=01;31:*.Z=01;31:*.dz=01;31:*.gz=01;31:*.lz=01;31:*.xz=01;31:*.bz2=01;31:*.bz=01;31:*.tbz=01;31:*.tbz2=01;31:*.tz=01;31:*.deb=01;31:*.rpm=01;31:*.jar=01;31:*.war=01;31:*.ear=01;31:*.sar=01;31:*.rar=01;31:*.ace=01;31:*.zoo=01;31:*.cpio=01;31:*.7z=01;31:*.rz=01;31:*.jpg=01;35:*.jpeg=01;35:*.gif=01;35:*.bmp=01;35:*.pbm=01;35:*.pgm=01;35:*.ppm=01;35:*.tga=01;35:*.xbm=01;35:*.xpm=01;35:*.tif=01;35:*.tiff=01;35:*.png=01;35:*.svg=01;35:*.svgz=01;35:*.mng=01;35:*.pcx=01;35:*.mov=01;35:*.mpg=01;35:*.mpeg=01;35:*.m2v=01;35:*.mkv=01;35:*.webm=01;35:*.ogm=01;35:*.mp4=01;35:*.m4v=01;35:*.mp4v=01;35:*.vob=01;35:*.qt=01;35:*.nuv=01;35:*.wmv=01;35:*.asf=01;35:*.rm=01;35:*.rmvb=01;35:*.flc=01;35:*.avi=01;35:*.fli=01;35:*.flv=01;35:*.gl=01;35:*.dl=01;35:*.xcf=01;35:*.xwd=01;35:*.yuv=01;35:*.cgm=01;35:*.emf=01;35:*.axv=01;35:*.anx=01;35:*.ogv=01;35:*.ogx=01;35:*.aac=00;36:*.au=00;36:*.flac=00;36:*.mid=00;36:*.midi=00;36:*.mka=00;36:*.mp3=00;36:*.mpc=00;36:*.ogg=00;36:*.ra=00;36:*.wav=00;36:*.axa=00;36:*.oga=00;36:*.spx=00;36:*.xspf=00;36:';
export LS_COLORS

# Thanks Adeel!
mkdir -p ~/.emacs.d/eshell
# shellcheck disable=SC1117
alias | sed -E "s/^alias ([^=]+)='(.*)'$/alias \1 \2 \$*/g; s/'\\\''/'/g;" >~/.emacs.d/eshell/alias

export PATH="$HOME/.linuxbrew/bin:$PATH"
export LD_LIBRARY_PATH="$HOME/.linuxbrew/lib"

MB_OPT=(--install_base "$HOME/perl5")
PERL_MB_OPT="${MB_OPT[*]}"; export PERL_MB_OPT;
PERL_MM_OPT="INSTALL_BASE=$HOME/perl5"; export PERL_MM_OPT;

# colorize man pages
export LESS_TERMCAP_mb=$'\E[01;31m'
export LESS_TERMCAP_md=$'\E[01;31m'
export LESS_TERMCAP_me=$'\E[0m'
export LESS_TERMCAP_se=$'\E[0m'
export LESS_TERMCAP_so=$'\E[01;44;33m'
export LESS_TERMCAP_ue=$'\E[0m'
export LESS_TERMCAP_us=$'\E[01;32m'

# Fix colors
# shellcheck source=/dev/null
source "$DIR/.colors"
