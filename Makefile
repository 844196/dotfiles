MKDIR     = mkdir $(MKDIR_OPT)
MKDIR_OPT = -p
LN        = ln $(LN_OPT)
LN_OPT    = -sfn
RM        = rm $(RM_OPT)
RM_OPT    = -rf

define link
	$(MKDIR) $(dir $2)
	$(LN) $(realpath $1) $2
endef

git:
	$(call link,git,~/.config/git)
.PHONY: git

zsh:
	$(call link,zsh/.zshenv,~/.zshenv)
	$(call link,zsh,~/.zsh)
.PHONY: zsh

vim:
	$(call link,vim,~/.vim)
	$(MKDIR) ~/.vim/undo
.PHONY: vim

nvim:
	$(call link,vim,~/.config/nvim)
	$(call link,vim/vimrc,~/.config/nvim/init.vim)
.PHONY: nvim

tmux:
	$(call link,tmux/.tmux.conf,~/.tmux.conf)
.PHONY: tmux

dein: vim
	git clone \
		https://github.com/Shougo/dein.vim \
		~/.vim/plugins/repos/github.com/Shougo/dein.vim
.PHONY: dein

zplug: zsh
	git clone \
		https://github.com/zplug/zplug \
		~/.zsh/zplug
.PHONY: zplug

ctags:
	$(call link,etc/ctags,~/.ctags)
.PHONY: ctags

chunkwm:
	$(call link,chunkwm/chunkwmrc,~/.chunkwmrc)
	$(call link,chunkwm/khdrc,~/.khdrc)
.PHONY: chunkwm

local:
	$(MKDIR) ~/.local
	touch ~/.local/vimrc
	touch ~/.local/zshrc
.PHONY: local
