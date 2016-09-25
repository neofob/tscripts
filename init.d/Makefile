# Simple Makefile to install init scripts
#
all: install

SRC?=e1000 zram

help:
	@echo "\033[1;31mAvailable targets:\033[0m"
	@echo
	@echo "  \033[1;33mhelp\033[0m - This help message"
	@echo
	@echo "  \033[1;33minstall\033[0m - Install init scripts \`$(SRC)\`"
	@echo "\t\tsudo make install"
	@echo
	@echo "__author__: tuan t. pham"

install:
	-@for s in $(SRC); do				\
		echo Installing $$s to /etc/init.d;	\
		install $$s /etc/init.d;		\
		update-rc.d $$s defaults;		\
		update-rc.d $$s enable;			\
		echo Done;				\
	done
