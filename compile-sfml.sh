#!/bin/bash

set -euo pipefail

get_brew() {
	echo "Homebrew not found. Installing now..."
	/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
}

verify_brew() {
	if command -v brew >/dev/null 2>&1; then
		return 0
	else
		return 1
	fi
}

setup() {
	if [[ -f /opt/homebrew/bin/brew ]]; then
		eval "$(/opt/homebrew/bin/brew shellenv)"
	elif [[ -f /usr/local/bin/brew ]]; then
		eval "$(/usr/local/bin/brew shellenv)"
	fi

	if verify_brew; then
		brew update || true
		brew install sfml@2 gcc || true
	fi
}

compile() {
	if verify_brew; then
		export SFPATH="/opt/homebrew/Cellar/sfml@2/2.6.2_1"
	else
		export SFPATH="$HOME/sfml/SFML-2.6.2"
	fi

	export INCLUDE="$SFPATH/include"
	export LIB="$SFPATH/lib"

	g++ *.cpp -I "$INCLUDE" -L "$LIB" -lsfml-graphics -lsfml-audio -lsfml-window -lsfml-system -lsfml-network -o app

	read -r -p "Run game? [Y/n]: " run
	if [[ -z "$run" || "$run" == "y" || "$run" == "Y" ]]; then
		./app
	fi
	exit 0
}

read -r -p "Homebrew or manual(H/M)?: " horm
if [[ "$horm" == "H" || "$horm" == "h" || -z horm ]]; then
	echo "Welcome to compile SFML!"
	if ! verify_brew; then
		get_brew
		eval "$(/opt/homebrew/bin/brew shellenv)" || true
		echo 'export PATH="/opt/homebrew/bin:$PATH"' >> ~/.bashrc
	fi
else
	curl -fsSLO https://www.sfml-dev.org/files/SFML-2.6.2-macOS-clang-arm64.tar.gz
	mkdir -p "$HOME/sfml"
	tar xf SFML-2.6.2-macOS-clang-arm64.tar.gz -C "$HOME/sfml"
	rm -rf SFML-2.6.2-macOS-clang-arm64.tar.gz
fi

setup
compile

