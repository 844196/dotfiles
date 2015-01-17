#!/bin/bash
#
#   @(#) Dotfiles setup scripts
#
#   Usage:
#       $ curl -sL 844196.com/dot | bash
#
#   Inspired:
#       https://github.com/Kuniwak/dotfiles/blob/master/setup.sh
#       https://github.com/b4b4r07/dotfiles/blob/master/etc/install
#
#   Author:
#       844196 (@84____)
#
#   License:
#       WTFPL
#


# initialize

    function printLogo() {
        clear
        local d="$(tput smso)  $(tput rmso)"
        cat <<-EOF
	
	                $d                    $d$d  $d  $d$d
	                $d            $d      $d          $d
	                $d    $d    $d$d$d  $d$d$d  $d    $d    $d$d    $d$d
	              $d$d  $d  $d    $d      $d    $d    $d  $d$d$d  $d$d
	            $d  $d  $d  $d    $d      $d    $d    $d  $d        $d$d
	              $d$d    $d      $d$d    $d    $d    $d    $d$d  $d$d
	
		EOF
    }
    printLogo

    # message wrapper
    function messageHeader() {
        local str="${*}"
        # shellcheck disable=2034
        local padding="$(
            for i in $( seq 0 $(( 78 - ${#str} )) )
            do
                printf " "
            done
        )"
        echo -en "\n$(tput smso) ${*}${padding}$(tput rmso)\n"
    }

    function messageSuccess() { echo "  $(tput setaf 2)✔ $(tput sgr0) ${*}"; }
    function messageArrow()   { echo "  $(tput setaf 6)➜ $(tput sgr0) ${*}"; }
    function messageError()   { echo "  $(tput setaf 1)✖ $(tput sgr0) ${*}" 1>&2; }

    # common function
    function executableCommand() {
        type "${1}" >/dev/null 2>&1
        return "${?}"
    }

    function existsFile() {
        [[ -e "${1}" ]]
        return "${?}"
    }

    function makeSymlink() {
        local from="${1}"
        local to="${2}"

        if existsFile "${to}"; then
            messageError "File already exists -- '${to}'"
            return 2
        else
            ln -s "${from}" "${to}" >/dev/null 2>&1
            if [[ "${?}" -eq 0 ]]; then
                messageSuccess "Successful make symboliclink -- '${to}'"
                return 0
            else
                messageError "Failed make symboliclink -- '${to}'"
                return 1
            fi
        fi
    }

    function cloneRepository() {
        local from="${1}"
        local to="${2}"
        local name="${3}"

        messageArrow "Downloading ${3}..."
        git clone -q "${from}" "${to}" >/dev/null
        if [[ "${?}" -eq 0 ]]; then
            messageSuccess "Successful download -- '${to}'"
            return 0
        else
            messageError "Failed download --'${name}'"
            return 1
        fi
    }


# check executable git

    if executableCommand "git"; then
        :
    else
        messageHeader "Check executable git command"
        messageError "This setup script required git"
        exit 1
    fi


# download dotfiles or sync

    if existsFile "${HOME}/dotfiles"; then
        messageHeader "Sync remote branch"
        messageArrow "Running... 'git pull --rebase'"
        (
            set -e
            cd "${HOME}/dotfiles"
            c="$(git rev-parse --abbrev-ref HEAD)"
            git checkout -q master >/dev/null
            git pull --rebase >/dev/null
            git checkout -q "${c}"
        )
        if [[ "${?}" -eq 0 ]]; then
            messageSuccess "Successful dotfiles sync"
        else
            messageError "Failed dotfiles sync"
            exit 1
        fi
    else
        messageHeader "Download dofiles"
        cloneRepository "https://github.com/844196/dotfiles" "${HOME}/dotfiles" "dotfiles" \
            || exit 1
    fi


# make symboliclink dotfiles

    # zsh
    function setupZshConfigurationFiles() {
        makeSymlink "${HOME}/dotfiles/.zshenv" "${HOME}/.zshenv"

        mkdir -p "${HOME}/.zsh"
        makeSymlink "${HOME}/dotfiles/.zshrc" "${HOME}/.zsh/.zshrc"
    }

    # need to keep in $HOME other files
    function setupOtherConfigurationFiles() {
        dotfiles=('.vimrc' '.gitconfig' '.tmux.conf')
        for file in "${dotfiles[@]}"
        do
            makeSymlink "${HOME}/dotfiles/${file}" "${HOME}/${file}"
        done
    }

    if existsFile "${HOME}/.zsh/.zshrc_local" || existsFile "${HOME}/.vim/.vimrc_local"; then
        :
    else
        messageHeader "Make symboliclink dotfiles"

        setupZshConfigurationFiles
        setupOtherConfigurationFiles
    fi


# install zsh-syntax-highlighting

    if existsFile "${HOME}/.zsh/zsh-syntax-highlighting"; then
        :
    else
        messageHeader "Install zsh-syntax-highlighting"

        mkdir -p "${HOME}/.zsh"
        cloneRepository \
            "https://github.com/zsh-users/zsh-syntax-highlighting" \
            "${HOME}/.zsh/zsh-syntax-highlighting" \
            "zsh-syntax-highlighting"
    fi


# install neobundle

    if existsFile "${HOME}/.vim/bundle/neobundle.vim"; then
        :
    else
        messageHeader "Install NeoBundle"

        mkdir -p ~/.vim/bundle
        cloneRepository \
            "https://github.com/Shougo/neobundle.vim" \
            "${HOME}/.vim/bundle/neobundle.vim" \
            "NeoBundle"
    fi


# mac only

    function isMacHomebrewUpdate() {
        messageHeader "Update Homebrew"

        messageArrow "Running... 'brew update && brew upgrade'"
        brew update >/dev/null && brew upgrade >/dev/null
        if [[ "${?}" -eq 0 ]]; then
            messageSuccess "Successful Homebrew update"
        else
            messageError "Failed homebrew update"
        fi
    }

    function isMac() {
        if executableCommand "brew"; then
            isMacHomebrewUpdate
        else
            messageHeader "Homebrew"
            messageError "This environment has not been introduced Homebrew"
            messageArrow "This setup script does not provide the installation process"
        fi
    }

    [[ "$(uname)" = "Darwin" ]] && isMac
