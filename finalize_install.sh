#!/bin/bash

    if [ ! -f /home/vagrant/NAO/NAOSDKs/naoqi-sdk-2. 1.4.13-linux64.tar.gz]; then
        echo "Error: SDKs not found."
        echo "Please download the Linux and Cross-Compiler SDKs from www.aldebaran.com and \nplace the archived files in the NAOSDKs directory, then re-run this script."
        exit
    fi
    
    cd /home/vagrant/NAO/NAOSDKs
    echo "\nDone! Extracting the SDKs..."
    tar -zxf naoqi-sdk-2.1.4.13-linux64.tar.gz -C /home/vagrant/NAO/devtools/ &
    wait %1 %2
    
    echo "Done! Cleaning up.."
    
    cd /home/vagrant/NAO/ && rm -rf NAOSDKs
    rm /home/vagrant/NAO/setup.sh
    rm /home/vagrant/NAO/get_sdks.sh
    
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
    

    echo "Done..."
        
    echo "\n Downloading and installing the cross compiler..."
    cd /var/persistent/
    git clone https://github.com/DU-RoboCup/cross-compiler.git
    mv /var/persistent/cross-compiler/cross-atom .
    rm -rf /var/persistent/cross-compiler
    echo "\n Cross compiler installed."
    
    cd /home/vagrant/NAO/NAO-engine

    echo "\nConfiguring..."
    
    rm /home/vagrant/NAO/finalize_install.sh
    
    read -p "\nDo you want to configure VIM now?" -n 1 -r
    echo    # (optional) move to a new line
    if [[ $REPLY =~ ^[Yy]$ ]]
    then
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
    fi
    
    
    
    echo "Done! Finished setup process. Try building some of the programs in core with:"
    echo "mkdir build && cd build"
    echo "cmake ../ -DUSE_CROSS=NO"
    echo "make"
    
    echo "To use qtcreator please do the following"
    echo "Kill yourself."


