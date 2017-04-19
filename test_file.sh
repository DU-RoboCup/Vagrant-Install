#!/bin/bash
set -e

printf "Welcome to the DU Robocup on-guest provision. This may take a while... (But you shouldn't see this message anyways as you've gone for coffee) \n"

# First, update and upgrade
printf "Updating System... \n"
sudo apt-get -qq update && sudo apt-get -qq upgrade --y

# Next, install the build dependencies
printf "Installing Dependencies... \n"
sudo apt-get -qq install -y build-essential cmake python-pip git gcc-multilib libc6-dev libc6-i386 xinit qtcreator zip lua5.1 liblua5.1-dev wget vim-nox doxygen python2.7-dev python3-dev libboost1.55-all-dev
printf "Done! \n"

# Change to the NAO directory
cd /home/vagrant/NAO

# We need to download the CTC and the SDK if they're DU students (confirmed)
if [ "$3" == "true" ]; then
  printf "Downloading the CTC and SDK. Hang tight! \n"
  wget -nv --no-check-certificate https://www.googledrive.com/host/0B2nZJSCqTexAajNyVU15NzlHZTA/ -O naoqi-sdk-2.1.4.13-linux64.tar.gz &
  wget -nv --no-check-certificate https://www.googledrive.com/host/0B2nZJSCqTexAb1hhR0FCLUZIRTg/ -O ctc-linux64-atom-2.1.4.13.zip &
  wait %1 %2
fi

# Now, extract the zip and tar.gz files (CTC and SDK) to /home/vagrant/NAO/devtools
printf "Extracting the CTC and SDK... \n"
mkdir -p "/home/vagrant/NAO/devtools/
tar -zxf naoqi-sdk-2.1.4.13-linux64.tar.gz -C /home/vagrant/NAO/devtools/
unzip -o /home/vagrant/NAO/NAOSDKs/ctc-linux64-atom-2.1.4.13.zip -d /home/vagrant/NAO/devtools/ > /dev/null 2>&1
rm -f ctc-linux64-atom-2.1.4.13.zip
rm -f naoqi-sdk-2.1.4.13-linux64.tar.gz
printf "Done! \n"

# Configure Git
printf "Configuring git... \n"
git config --global user.email "$1"
git config --global user.name "$2"
git config --global core.editor "vim"
git config --global credential.helper 'cache --timeout 900'
printf "Done! \n"

# Clone the main repository
printf "Installing main repository... \n"
git clone https://github.com/DU-RoboCup/NAO-engine.git > /dev/null 2>&1

# Install the cross-compiler
printf "Done! Installing GCC5.2 Cross-Compiler... \n"
sudo mkdir -p /var/persistent
sudo chown vagrant:vagrant /var/persistent
cd /var/persistent/
git clone https://github.com/DU-RoboCup/cross-compiler.git
mv /var/persistent/cross-compiler/cross-atom .
rm -rf /var/persistent/cross-compiler
cd /home/vagrant/NAO
printf "Done! \n"

# Install QIBuild for the HAL module
printf "Installing QiBuild... \n"
pip install QiBuild -q
echo "PATH=\$PATH:\$HOME/.local/bin" >> /home/vagrant/.bashrc
source /home/vagrant/.bashrc
printf "Done! \n"

# Install HAL toolchain
printf "Installing the HAL toolchain... \n"
cd /home/vagrant/NAO/NAO-engine/naoqi_modules/halagent
qibuild init
qitoolchain create linux64 /home/vagrant/NAO/devtools/ctc-linux64-atom-2.1.4.13/toolchain.xml
qibuild add-config linux64 --toolchain linux64
qibuild configure -c linux64
# Something needs to go here with the qibuild config (wizard)
printf "Done! \n"

# Check for VIM install
if [ "$4" == "true" ]; then
  printf "Setting up an awesome VIM configuration \n"
  git clone https://github.com/amix/vimrc.git ~/.vim_runtime
  sh /home/vagrant/.vim_runtime/install_awesome_vimrc.sh 
  cd /home/.vim_runtime
  git clone https://github.com/Valloric/YouCompleteMe.git sources_non_forked/YouCompleteMe
  cd sources_non_forked/YouCompleteMe
  git submodule update --init --recursive
  ./install.py --clang-completer
  cd ~/.vim_runtime/vimrcs
  echo "let g:ycm_global_ycm_extra_conf = '~/.vim_runtime/.ycm_extra_conf.py'" >> plugins_config.vim
  cd ~/.vim_runtime
  wget https://raw.githubusercontent.com/JDevlieghere/dotfiles/master/.vim/.ycm_extra_conf.py -O .ycm_extra_conf.py
  cd ~/.vim_runtime/
  sh install_awesome_vimrc.sh
  printf "Done! \n"
fi

prinf "Done setting up the environment! It's ready to use! \n"



