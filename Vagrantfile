# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'io/console'
require 'fileutils'

#First we're going to prompt for the information that we need in the configuration
vagrant_arg = ARGV[0]
if (Dir.glob("#{File.dirname(__FILE__)}/.vagrant/machines/default/virtualbox/*").empty? and vagrant_arg == 'up') or vagrant_arg == 'provision' or ARGV[1] == '--provision' then
    
    print "Welcome to the initialization for the DU robocup development environment! We're going to ask you a few questions before you get started to set the environment up to your liking! Keep in mind, that setting up this environment takes about 5GB of free space, and may take up to two hours depending on the speed of your internet, and of your computer.\n\n"
    
    print "First, please confirm that you want to install the dev environment on your host computer in the file #{File.dirname(__FILE__)} [y/N]: "
    confirm = STDIN.gets.chomp
    if confirm != "y" and confirm != "Y" then
        print "Cofirmation not recieved! Canceling!\n"
        exit
    end

    print "\nNext, we're going to get some info about your github account. If you don't have a github account, you can create one now at https://github.com \n"
    print "Please input your Github username: "
    $git_username = STDIN.gets.chomp
    print "Please input your Github email: "
    $git_email = STDIN.gets.chomp
    print "\n"

    print "Ok! Great! Now are you a DU Robocup team member? [y/N] "
    confirm = STDIN.gets.chomp
    if confirm.eql? "y" or confirm.eql? "Y" then
        print "Sweet! We're going to download the NAO CTC and SDK for you during installation! \n"
        $do_download = "true"

        unless File.directory?("NAO")
            FileUtils.mkdir_p("NAO")
        end

    else
        print "\nCool! Now we need you do something for us. Please download the C++ NAO SDK version 2.1.4 for Linux x64 (the file naoqi-sdk-2.1.4.13-linux64.tar.gz) and the NAO C++ cross-compile toolchain for Linux  x64(ctc-linux64-atom-2.1.4.13.zip) from the Aldebaran website. (Right now, you can get it by creating an account and going to: https://community.ald.softbankrobotics.com/en/resources/software/language/en-gb). Then, place them in the folder #{Dir.pwd} on your computer, and press enter. \n"
        $do_download = "false"
        x = STDIN.gets.chomp
        while not File.file?("#{File.dirname(__FILE__)}/naoqi-sdk-2.1.4.13-linux64.tar.gz") do
            print "Sorry! We didn't find the NAO SDK for C++ Linux x64. Make sure the file naoqi-sdk-2.1.4.13-linux64.tar.gz is in #{Dir.pwd} then press enter to try again! (Or ctrl-C to cancel installation) \n"
            x = STDIN.gets.chomp
        end

        while not File.file?("#{File.dirname(__FILE__)}/ctc-linux64-atom-2.1.4.13.zip") do
            print "Sorry! We didn't find the NAO Cross-Compile Toolchain for C++ Linux x64. Make sure the file ctc-linux64-atom-2.1.4.13.zip is in #{Dir.pwd} then press enter to try again! (Or ctrl-C to cancel installation) \n"
            x = STDIN.gets.chomp
        end

        # Create the NAO directory so we can do some setup tools
        unless File.directory?("NAO")
            FileUtils.mkdir_p("NAO")
        end
        FileUtils.mv('ctc-linux64-atom-2.1.4.13.zip', 'NAO/ctc-linux64-atom-2.1.4.13.zip')
        FileUtils.mv('naoqi-sdk-2.1.4.13-linux64.tar.gz', 'NAO/naoqi-sdk-2.1.4.13-linux64.tar.gz')
    end

    print "\nWicked Sick! Do you want to configure VIM now? [y/N] "
    confirm = STDIN.gets.chomp
    if confirm.eql? "y" or confirm.eql? "Y" then
        $do_vim = "true"
    else
        $do_vim = "false"
    end

    print "\nTotally rad! That's all we need for now! This provisioning and setup might take a while, so go grab some coffee, and it'll be done when you get back! \n"

end



Vagrant.configure(2) do |config|

    config.vm.box = "ubuntu/trusty64"
    config.vm.box_check_update = false

    config.ssh.shell = "bash -c 'BASH_ENV=/etc/profile exec bash'"

    config.vm.provider "virtualbox" do |vb|
        vb.customize ["setextradata", :id, "VBoxInternal2/SharedFoldersEnableSymlinksCreate/v-root", "1"]
        vb.memory = "2048"
        vb.cpus = "2"
        vb.name = "RobocupDevEnv"
    end
    config.vm.provision "shell" do |s|
        s.path = "https://raw.githubusercontent.com/DU-RoboCup/vagrant-install/master/vagrant_install.sh"
        s.args = ["#{$git_username}","#{$git_email}", "#{$do_download}", "#{$do_vim}"]
    end
    config.vm.synced_folder "NAO/", "/home/vagrant/NAO", create:true

end
