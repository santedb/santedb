#!/bin/bash
if [ -f .gitmodules ]; then
	git submodule update --remote
	for S in *; do
		if [ -d "${S}" ]; then
			cd "${S}"
			if [ -f .git ]; then
				git checkout master
				git pull
			fi
			cd ..
		fi
	done 
fi
