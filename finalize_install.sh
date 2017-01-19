#!/bin/bash

    echo "Checking for required SDK files..."
    if [ ! -f /home/vagrant/NAO/NAOSDKs/naoqi-sdk-2.1.4.13-linux64.tar.gz ]; then
        echo "Error: SDK not found."
        echo "Please download the Linux SDK from www.aldebaran.com and"
        echo "place the archived files in the NAOSDKs directory, then re-run this script."
        echo
        exit
    fi
    if [ ! -f /home/vagrant/NAO/NAOSDKs/ctc-linux64-atom-2.1.4.13.zip ]; then 
        echo "Error: Cross-Compiler not found."
        echo "Please download the Linux Cross-Compiler from www.aldebaran.com and"
        echo "place the archived files in the NAOSDKs directory, then re-run this script."
        echo 
        exit
    fi

    # Extract the SDK 
    cd /home/vagrant/NAO/NAOSDKs
    echo "Extracting the SDK..."
    tar -zxf naoqi-sdk-2.1.4.13-linux64.tar.gz -C /home/vagrant/NAO/devtools/ 
    echo "Done! Cleaning up..."
    echo

    # Extract the cross compiler
    cd /home/vagrant/NAO/NAOSDKs
    echo "Extracting the Aldebaran Cross Compiler..."
    unzip -o /home/vagrant/NAO/NAOSDKs/ctc-linux64-atom-2.1.4.13.zip -d /home/vagrant/NAO/devtools/ > /dev/null 2>&1
    echo "Done! Cleaning up..."
    echo
    
    # Cleaning up the SDK directory
    cd /home/vagrant/NAO/ && rm -rf NAOSDKs
    rm /home/vagrant/NAO/setup.sh
    rm /home/vagrant/NAO/get_sdks.sh
    
    # Ask to configure git
    echo "Configuring git..."
    echo -n "Please enter the email you used for your github account: "
    read email
    echo -n "Please enter your github username: "
    read username
    
    git config --global user.email "$email"
    git config --global user.name "$username"
    git config --global core.editor "vim"
    git config --global credential.helper 'cache --timeout 900'

    echo "Done with git configuration."
    echo 
    echo "Cloning NAO-Engine repository"

    # Clone the main repository
    cd /home/vagrant/NAO 
    git clone https://github.com/DU-RoboCup/NAO-engine.git
    
    # Install the modern cross-compiler
    echo "Done."
    echo
    echo "Downloading and installing the GCC6 cross compiler..."
    
    sudo mkdir -p /var/persistent
    sudo chown vagrant:vagrant /var/persistent
    cd /var/persistent/
    git clone https://github.com/DU-RoboCup/cross-compiler.git
    mv /var/persistent/cross-compiler/cross-atom .
    rm -rf /var/persistent/cross-compiler
    echo "GCC6 Cross compiler installed."
    echo
    
    cd /home/vagrant/NAO/NAO-engine

    # Install and configure QiBuild for the HAL
    echo "Installing QiBuild..."
    echo
    pip install QiBuild -q
    echo "PATH=\$PATH:\$HOME/.local/bin" >> /home/vagrant/bashrc
    source /home/vagrant/bashrc

    echo "Done."
    echo

    # Create the toolchain for the HAL 
    echo "Creating QiBuild toolchain for HAL..."
    cd /home/vagrant/NAO/NAO-engine/naoqi_modules/halagent
    qibuild init
    qitoolchain create linux64 /home/vagrant/NAO/devtools/ctc-linux64-atom-2.1.4.13/toolchain.xml
    qibuild add-config linux64 --toolchain linux64
    echo "Please confiure QIBuild as instructed on the wiki"
    echo
    qibuild configure -c linux64
    qibuild config --wizard
    echo "Done."
    echo


    echo "Configuring Complete!"
    echo

    rm /home/vagrant/NAO/finalize_install.sh
    
    read -p "Do you want to configure VIM now? (y/N)" REPLY
    case "$REPLY" in
        y|Y ) {
        echo "Setting up an awesome VIM configuration"
        echo
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
    };;
        * ) echo "Vim is basic. Like your mother.";;
    esac
    
    
    
    echo "Done! Finished setup process! Try building some of the programs in core with:"
    echo "./build local"
    echo
    
    echo "To use qtcreator please do the following:"
    echo "1. Kill yourself."
