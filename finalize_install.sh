#!/bin/bash

    if [ ! -f /home/vagrant/NAO/NAOSDKs/naoqi-sdk-2. 1.4.13-linux64.tar.gz]; then
        echo "Error: SDKs not found."
        echo "Please download the Linux and Cross-Compiler SDKs from www.aldebaran.com and \nplace the archived files in the NAOSDKs directory, then re-run this script."
        exit
    fi
    
    cd /home/vagrant/NAO/NAOSDKs
    echo "\nDone! Extracting the SDKs..."
    tar -zxf naoqi-sdk-2.1.4.13-linux64.tar.gz -C /home/vagrant/NAO/devtools/ &
    unzip ctc-linux64-atom-2.1.4.13.zip -d /home/vagrant/NAO/devtools/ &
    wait %1 %2
    
    echo "Patching boost cmake files from the cross compiler."
    cd /home/vagrant/NAO/devtools/ctc-linux64-atom-2.1.4.13/boost/share
    git clone https://github.com/DU-RoboCup/ctc-patches.git
    rm -rf cmake
    mv ctc-patches/cmake/ cmake/
    mv 'ctc-patches/boost file patches/noncopyable.hpp' ../include/boost-1_55/boost/noncopyable.hpp
    rm -rf ctc-patches/
    
    echo "Downloading and installing LUA binaries"
    mkdir -p /home/vagrant/NAO/devtools/ctc-linux64-atom-2.1.4.13/dev-lang
    cd /home/vagrant/NAO/devtools/ctc-linux64-atom-2.1.4.13/dev-lang
    wget --no-check-certificate https://raw.githubusercontent.com/DU-RoboCup/Vagrant-Install/master/lua-5.1.4-r4.tbz2 -O lua-5.1.4-r4.tbz2 
    
    echo "Done! Cleaning up.."
    
    cd /home/vagrant/NAO/ && rm -rf NAOSDKs
    rm /home/vagrant/NAO/setup.sh
    rm /home/vagrant/NAO/get_sdks.sh
    
    sudo pip install qibuild
    echo "Configuring git."
    echo -n "Please enter the email you used for your github account: "
    read email
    echo -n "Please enter your github username: "
    read username
    
    git config --global user.email "$email"
    git config --global user.name "$username"
    git config --global core.editor "vim"
    git config --global credential.helper 'cache --timeout 900'
    cd ~/NAO 
    git clone https://github.com/DU-RoboCup/NAO-engine.git
    

    echo "Done...setting up your worktree"
    
    
    cd /home/vagrant/NAO/NAO-engine

    qibuild init
    echo "configuring..."

    
    echo -e "1\n2\nY\nY\nn\nn" | qibuild config --wizard    
  
    echo 'export NAO_WORKSPACE=/home/vagrant/NAO/NAO-engine alias naocd="cd  $ NAO_WORKSPACE"' >> ~/.bashrc
    echo "creating and setting as default linux64 toolchain"
    qitoolchain create linux64 ~/NAO/devtools/naoqi-sdk-2.1.4.13-linux64/toolchain.xml
    qibuild add-config linux64 -t linux64 --default
    
    echo "creating cross-atom toolchain for cross-compiling to the NAO robot"
    qitoolchain create cross-atom ~/NAO/devtools/ctc-linux64-atom-2.1.4.13/toolchain.xml
    qibuild add-config cross-atom -t cross-atom
    
    echo "Done configuring the worktree. Installing lua..."
    sudo cp /usr/share/cmake-2.8/Modules/FindLua51.cmake /usr/share/cmake-2.8/Modules/FindLUA.cmake
    
    echo "Adding lua to the cross-atom worktree"
    echo -e "n\nn\n" | qitoolchain import-package -c cross-atom --name lua /home/vagrant/NAO/devtools/ctc-linux64-atom-2.1.4.13/dev-lang/lua-5.1.4-r4.tbz2
    
    rm /home/vagrant/NAO/finalize_install.sh
    
    echo "Setting up an awesome VIM configuration"
    git clone https://github.com/amix/vimrc.git ~/.vim_runtime
    ./home/vagrant/.vim_runtime/install_awesome_vimrc.sh 
    cd ~/.vim_runtime
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
    
    
    echo "Done! Finished setup process. Try building some of the programs in core with:"
    echo "qisrc add ."
    echo "qibuild configure -c linux64"
    echo "qibuild make -c linux64"
    
    echo "To use qtcreator please do the following"
    echo "1. Enter the command: exit"
    echo "2. Enter the command: vagrant -Y ssh-config"
    echo "3. change directory to, for example one of the examples in NAO/NAO-engine/worktree/examples \n configured following the steps above, then type: qibuild open"
    echo "4. IMPORTANT: Change the build folder in qtcreator to build-linux64, then click configure"

