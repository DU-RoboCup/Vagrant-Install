# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure(2) do |config|

  config.vm.box = "ubuntu/trusty64"
 
  # config.vm.box_check_update = false
  # config.vm.network "forwarded_port", guest: 80, host: 8080
  # config.vm.network "private_network", ip: "192.168.33.10"
  # config.vm.network "public_network"
  
  # Share an additional folder to the guest VM. The first argument is
  # the path on the host to the actual folder. The second argument is
  # the path on the guest to mount the folder. And the optional third
  # argument is a set of non-required options.
  # config.vm.synced_folder "../data", "/vagrant_data"

  # Provider-specific configuration so you can fine-tune various
  # backing providers for Vagrant. These expose provider-specific options.
  # Example for VirtualBox:
  #
  config.vm.provider "virtualbox" do |vb|
# # Enable Symbolic links between shared folders
  	vb.customize ["setextradata", :id, "VBoxInternal2/SharedFoldersEnableSymlinksCreate/v-root", "1"]
   
#   # Display the VirtualBox GUI when booting the machine
  #   vb.gui = true
  #
  #   # Customize the amount of memory on the VM:
    vb.memory = "2048"

  end
  #
  # View the documentation for the provider you are using for more
  # information on available options.

  
  # Enable provisioning with a shell script. Additional provisioners such as
  config.vm.provision "shell", inline: <<-SHELL
    echo "Updating files..." 
    sudo apt-get update && sudo apt-get upgrade
    
    echo "\nDone! Installing dependencies for the build system. This may take a couple minutes..." 
    sudo apt-get install -y build-essential cmake python-pip git gcc-multilib libc6-dev libc6-i386 xinit qtcreator zip lua5.1 liblua5.1-dev wget vim-nox doxygen python2.7-dev python3-dev libboost1.55-all-dev
    clear && echo "\nDone! Setting up build environment..."
    mkdir -p NAO
    mkdir -p NAO/{devtools,NAOSDKs}
    echo "Done! Updating permissions and downloading setup files..."
    echo 

    cd /home/vagrant/NAO/
    wget -nv --no-check-certificate https://raw.githubusercontent.com/DU-RoboCup/Vagrant-Install/master/setup.sh -O setup.sh
    wget -nv --no-check-certificate https://raw.githubusercontent.com/DU-RoboCup/Vagrant-Install/master/finalize_install.sh -O finalize_install.sh
  
    sudo chown -R vagrant:vagrant /home/vagrant/
    sudo chmod -R u+rw /home/vagrant/
    sudo chmod +x /home/vagrant/NAO/setup.sh
    sudo chmod +x /home/vagrant/NAO/finalize_install.sh
 
    echo "Vagrant Setup complete. To setup the build environment follow the online instructions!"
    echo
     
  SHELL

  #Setup Shared Folder
  config.vm.synced_folder "NAO/", "/home/vagrant/NAO"
  
  #Enable X over ssh
  config.ssh.forward_agent = true
  config.ssh.forward_x11 = true

  end
