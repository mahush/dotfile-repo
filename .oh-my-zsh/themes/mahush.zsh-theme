# vim:ft=zsh ts=2 sw=2 sts=2
#
# agnoster's Theme - https://gist.github.com/3712874
# A Powerline-inspired theme for ZSH
#
# # README
#
# In order for this theme to render correctly, you will need a
# [Powerline-patched font](https://github.com/Lokaltog/powerline-fonts).
# Make sure you have a recent version: the code points that Powerline
# uses changed in 2012, and older versions will display incorrectly,
# in confusing ways.
#
# In addition, I recommend the
# [Solarized theme](https://github.com/altercation/solarized/) and, if you're
# using it on Mac OS X, [iTerm 2](http://www.iterm2.com/) over Terminal.app -
# it has significantly better color fidelity.
#
# # Goals
#
# The aim of this theme is to only show you *relevant* information. Like most
# prompts, it will only show git information when in a git working directory.
# However, it goes a step further: everything from the current user and
# hostname to whether the last call exited with an error to whether background
# jobs are running in this shell will all be displayed automatically when
# appropriate.

### Segment drawing
# A few utility functions to make it easy and re-usable to draw segmented prompts

#CURRENT_BG='NONE'

# Special Powerline characters

() {
  local LC_ALL="" LC_CTYPE="en_US.UTF-8"
  # NOTE: This segment separator character is correct.  In 2012, Powerline changed
  # the code points they use for their special characters. This is the new code point.
  # If this is not working for you, you probably have an old version of the
  # Powerline-patched fonts installed. Download and install the new version.
  # Do not submit PRs to change this unless you have reviewed the Powerline code point
  # history and have new information.
  # This is defined using a Unicode escape sequence so it is unambiguously readable, regardless of
  # what font the user is viewing this source code in. Do not replace the
  # escape sequence with a single literal character.  # Do not change this! Do not make it '\u2b80'; that is the old, wrong code point.  SEGMENT_SEPARATOR=$'\ue0b0' } 
# Begin a segment
# Takes two arguments, background and foreground. Both can be omitted,
# rendering default background/foreground.
# escape sequence with a single literal character.
# Do not change this! Do not make it '\u2b80'; that is the old, wrong code point.
  SEGMENT_SEPARATOR=$'\ue0b0'

  BACKGROUND_COLOR="253;246;227"
  COLOR_CYAN="42;161;152"
  COLOR_BLACK="88;110;117"
  COLOR_WHITE="255;255;255"
  COLOR_YELLOW="181;137;0"
  COLOR_RED="220;50;47"
}

CURRENT_BG="$BACKGROUND_COLOR"
CURRENT_FG="None"
local seperator_pending=0

setColors() { # BG, FG 
   local background=$1
   local foreground=$2
   echo -n "%{\x1b[38;2;${foreground}m%}" #foreground
   echo -n "%{\x1b[48;2;${background}m%}" #background

   CURRENT_BG=$1
   CURRENT_FG=$2
}

prompt_seperator() {

  seperator_pending=1
}

prompt_text() { # BG, FG, (TEXT)

  # print seperator
  if [[ $seperator_pending == 1 ]]; then
    seperator_pending=0

    setColors "$1" "$CURRENT_BG"
    echo -n "$SEGMENT_SEPARATOR"
  fi

  # apply colors and print text
  setColors $1 $2 
  echo -n "$3"
}

# End the prompt, closing any open segments
prompt_end() {

  # force possibly pending seperator to be printed
  prompt_text "$BACKGROUND_COLOR" "$CURRENT_FG" ""
   
  # reset colors
  echo -n "%{\x1b[0m%}"
  CURRENT_BG="$BACKGROUND_COLOR"
}

### Prompt components
# Each component will draw itself, and hide itself if no information needs to be shown

# Context: user@hostname (who am I and where am I)
prompt_context() { # BG, FG
  if [[ "$USER" != "$DEFAULT_USER" || -n "$SSH_CLIENT" ]]; then

    prompt_text "$1" "$2" " %{%B%}$USER%{%b%}"
    prompt_text "$1" "$2" "@%m"
  fi
}

# Status
prompt_status() { # BG, FG

  local background_color="$1"
  local foreground_color="$2"
  local text='*'

  [[ $RETVAL -ne 0 ]] && background_color=$COLOR_RED && foreground_color=$COLOR_WHITE
  [[ $UID -eq 0 ]] && text="⚡"
  [[ $(jobs -l | wc -l) -gt 0 ]] && text="⚙"

  prompt_text "$background_color" "$foreground_color" " ${VIMODE}$text "
}

# Dir: current working directory
prompt_dir() { # BG, FG
  prompt_text "$1" "$2" " %~ "
}

# Git: branch/detached head, dirty status
prompt_git() {

  local PL_BRANCH_CHAR
  () {
    local LC_ALL="" LC_CTYPE="en_US.UTF-8"
    PL_BRANCH_CHAR=$'\ue0a0'         # 
  }
  local ref mode repo_path
  repo_path=$(git rev-parse --git-dir 2>/dev/null)

  if $(git rev-parse --is-inside-work-tree >/dev/null 2>&1); then
    ref=$(git symbolic-ref HEAD 2> /dev/null) || ref="➦ $(git rev-parse --short HEAD 2> /dev/null)"

    if [[ -e "${repo_path}/BISECT_LOG" ]]; then
      mode=" <B>"
    elif [[ -e "${repo_path}/MERGE_HEAD" ]]; then
      mode=" >M<"
    elif [[ -e "${repo_path}/rebase" || -e "${repo_path}/rebase-apply" || -e "${repo_path}/rebase-merge" || -e "${repo_path}/../.dotest" ]]; then
      mode=" >R>"
    fi

    setopt promptsubst
    autoload -Uz vcs_info

    zstyle ':vcs_info:*' enable git
    zstyle ':vcs_info:*' get-revision true
    zstyle ':vcs_info:*' check-for-changes true
    zstyle ':vcs_info:*' stagedstr '✚'
    zstyle ':vcs_info:*' unstagedstr '●'
    zstyle ':vcs_info:*' formats ' %u%c'
    zstyle ':vcs_info:*' actionformats ' %u%c'
    vcs_info

    prompt_seperator 
    prompt_text "$COLOR_BLACK" "$COLOR_WHITE" " "
    
    prompt_text "$COLOR_CYAN" "$COLOR_BLACK" 


    echo -n " ${ref/refs\/heads\//$PL_BRANCH_CHAR }${vcs_info_msg_0_%% }${mode}"
  fi
}

## Main prompt
build_prompt_left() {
  RETVAL=$?

  prompt_context "$COLOR_BLACK" "$COLOR_WHITE" 
  prompt_seperator 
  prompt_status "$COLOR_CYAN" "$COLOR_BLACK"
  prompt_seperator 
  prompt_end
}

build_prompt_right() {
  prompt_seperator 
  prompt_git
  prompt_seperator 
  prompt_dir "$COLOR_BLACK" "$COLOR_WHITE" 
  prompt_end
}

PROMPT='$(build_prompt_left) '
RPROMPT='$(build_prompt_right)'


