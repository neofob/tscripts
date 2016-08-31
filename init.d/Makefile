# Simple Makefile to install init scripts
#
all: install

SRC=e1000 zram

help:
	@echo "Available targets:"
	@echo
	@echo "  help - This help message"
	@echo
	@echo "  install - Install init scripts \`$(SRC)\`"
	@echo "\t\tsudo make install"
	@echo
	@echo "__author__: tuan t. pham"

install:
	-@for s in $(SRC); do			\
		echo Installing $$s;		\
		install $$s;			\
		update-rc.d $$s defaults;	\
		update-rc.d $$s enable;		\
		echo Done;			\
	done
