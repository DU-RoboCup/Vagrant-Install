#!/bin/bash
set -e

printf "Welcome to the DU Robocup on-guest provision. This may take a while... (But you shouldn't see this message anyways as you've gone for coffee) \n"

# First, update and upgrade
printf "Updating System... \n"
sudo add-apt-repository ppa:jonathonf/vim -y > /dev/null 2>&1
sudo apt-get -qq update > /dev/null 2>&1
sudo apt-get -qq upgrade -y > /dev/null 2>&1

# Next, install the build dependencies
printf "Installing Dependencies... \n"
sudo apt-get -qq install -y build-essential cmake python-pip git gcc-multilib libc6-dev libc6-i386 xinit qtcreator zip lua5.1 liblua5.1-dev wget vim vim-nox doxygen python2.7-dev python3-dev libboost1.55-all-dev ntp
printf "Done! \n"

# Change to the NAO directory
cd /home/vagrant/NAO

# We need to download the CTC and the SDK if they're DU students (confirmed)
if [ "$3" == "true" ]; then
  printf "Downloading the CTC and SDK. Hang tight! \n"
  sudo -u vagrant wget -nv --no-check-certificate https://cdn.iridescent.io/index.php/s/x2KjfposQRdU2U5/download -O files.zip
  sudo -u vagrant unzip -P "$5" files.zip
fi 
 
# Now, extract the zip and tar.gz files (CTC and SDK) to /home/vagrant/NAO/devtools
printf "Extracting the CTC and SDK... \n"
sudo -u vagrant mkdir -p "/home/vagrant/NAO/devtools/"
sudo -u vagrant tar -zxf naoqi-sdk-2.1.4.13-linux64.tar.gz -C /home/vagrant/NAO/devtools/
sudo -u vagrant unzip -o /home/vagrant/NAO/ctc-linux64-atom-2.1.4.13.zip -d /home/vagrant/NAO/devtools/ > /dev/null 2>&1
#rm -f ctc-linux64-atom-2.1.4.13.zip
#rm -f naoqi-sdk-2.1.4.13-linux64.tar.gz
printf "Done! \n"

# Configure Git
printf "Configuring git... \n"
printf "[user]\n" > /home/vagrant/.gitconfig
printf "\tname = $1\n" >> /home/vagrant/.gitconfig
printf "\temail = $2\n" >> /home/vagrant/.gitconfig
printf "[core]\n" >> /home/vagrant/.gitconfig
printf "\teditor = vim\n" >> /home/vagrant/.gitconfig
printf "[credential]\n" >> /home/vagrant/.gitconfig
printf "\thelper = cache --timeout 900\n" >> /home/vagrant/.gitconfig
sudo chown vagrant:vagrant /home/vagrant/.gitconfig
printf "Done! \n"

# Clone the main repository
printf "Installing main repository... \n"
sudo -u vagrant git clone https://github.com/DU-RoboCup/NAO-engine.git > /dev/null 2>&1

# Install the cross-compiler
printf "Done! Installing GCC 5.2 Cross-Compiler... \n"
sudo mkdir -p /var/persistent
sudo chown vagrant:vagrant /var/persistent
cd /var/persistent/
sudo -u vagrant git clone https://github.com/DU-RoboCup/cross-compiler.git > /dev/null 2>&1
mv /var/persistent/cross-compiler/cross-atom .
rm -rf /var/persistent/cross-compiler
cd /home/vagrant/NAO
printf "Done! \n"

# Install QIBuild for the HAL module
printf "Installing QiBuild... \n"
sudo pip install QiBuild -q
echo "PATH=\$PATH:\$HOME/.local/bin" >> /home/vagrant/.bashrc
source /home/vagrant/.bashrc
printf "Done! \n"

# Install HAL toolchain
printf "Installing the HAL toolchain... \n"
cd /home/vagrant/NAO/NAO-engine/naoqi_modules/halagent
qitoolchain create linux64 /home/vagrant/NAO/devtools/ctc-linux64-atom-2.1.4.13/toolchain.xml
qibuild add-config linux64 --toolchain linux64
sudo mkdir -p /home/vagrant/.config
sudo rm -rf /home/vagrant/.config/qi
sudo mv /root/.config/qi /home/vagrant/.config
sudo chown -R vagrant:vagrant /home/vagrant/.config
cd /home/vagrant/NAO
printf "Done! \n"



# Check for VIM install
if [ "$4" == "true" ]; then
  printf "Setting up an awesome VIM configuration. This takes forever FYI... \n"
  sudo -u vagrant git clone https://github.com/amix/vimrc.git /home/vagrant/.vim_runtime > /dev/null 2>&1
  sed -ie 's/~/\/home\/vagrant/g' /home/vagrant/.vim_runtime/install_awesome_vimrc.sh
  sudo -u vagrant sh /home/vagrant/.vim_runtime/install_awesome_vimrc.sh 
  cd /home/vagrant/.vim_runtime
  sudo -u vagrant git clone https://github.com/Valloric/YouCompleteMe.git sources_non_forked/YouCompleteMe > /dev/null 2>&1
  cd sources_non_forked/YouCompleteMe
  sudo -u vagrant git submodule update --init --recursive > /dev/null 2>&1
  sudo -u vagrant ./install.py --clang-completer > /dev/null 2>&1
  cd /home/vagrant/.vim_runtime/vimrcs
  echo "let g:ycm_global_ycm_extra_conf = '~/.vim_runtime/.ycm_extra_conf.py'" >> plugins_config.vim
  cd /home/vagrant/.vim_runtime
  sudo -u vagrant wget https://raw.githubusercontent.com/JDevlieghere/dotfiles/master/.vim/.ycm_extra_conf.py -O .ycm_extra_conf.py > /dev/null 2>&1
  cd /home/vagrant/.vim_runtime/
  sudo -u vagrant sh install_awesome_vimrc.sh
fi

printf "Done setting up the environment! It's ready to use! \n"



