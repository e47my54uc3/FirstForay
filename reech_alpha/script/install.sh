	set -e
	function say_green
	{
		echo -e '\E[00;32m'"\033[1m$@\033[0m"
	}
	function say_red
	{
		echo -e '\E[00;31m'"\033[1m$@\033[0m"
	}
	function say_cyan
	{
		echo -e '\E[00;36m'"\033[1m$@\033[0m"
	}
	function say_yellow
	{
		echo -e '\E[01;33m'"\033[1m$@\033[0m"
	}

	function  install_java
	{
    d=`pwd`
    sudo mkdir -p /usr/lib/jvm
    cd /usr/lib/jvm
    say_cyan " Downloading jdk-6u29-linux-i586.bin in your /usr/lib/jvm folder"
    sudo wget https://s3.amazonaws.com/reech-repo/jdk/jdk-6u29-linux-i586.bin
    sudo chmod +x jdk-6u29-linux-i586.bin
    sudo ./jdk-6u29-linux-i586.bin
    sudo update-alternatives --install "/usr/bin/java" "java" "/usr/lib/jvm/jdk1.6.0_29/bin/java" 1
    sudo update-alternatives --install "/usr/bin/javac" "javac" "/usr/lib/jvm/jdk1.6.0_29/bin/javac" 1
    sudo update-alternatives --install "/usr/lib/mozilla/plugins/libjavaplugin.so" "mozilla-javaplugin.so" "/usr/lib/jvm/jdk1.6.0_29/jre/lib/i386/libnpjp2.so" 1
    sudo update-alternatives --install "/usr/bin/javaws" "javaws" "/usr/lib/jvm/jdk1.6.0_29/bin/javaws" 1
    sudo update-alternatives --config java
    sudo update-alternatives --config javac
    sudo update-alternatives --config mozilla-javaplugin.so
    sudo update-alternatives --config javaws
    say_green "JDK 6.0 Update 29 Installation complete"
    sudo echo "export JAVA_HOME=/usr/lib/jvm/jdk1.6.0_29" >> ~/.bashrc
    sudo echo "export JRE_HOME=/usr/lib/jvm/jdk1.6.0_29/jre" >> ~/.bashrc
    say_yellow "Added JAVA PATH variables  to ~/.bashrc"
    export PATH=$PATH:/usr/lib/jvm/jdk1.6.0_29/bin

    cd $d
    source ~/.bashrc		
	}

	function get_essentials
	{
		say_green "Updating apt-get"
    sudo apt-get update
    say_green "Installing development packages"
    sudo apt-get install build-essential bison openssl libreadline5 libreadline-dev curl git zlib1g zlib1g-dev libssl-dev libsqlite3-0 libsqlite3-dev sqlite3 libxml2-dev
    sudo apt-get install g++-multilib
    sudo apt-get install libxslt-dev libxml2-dev
    say_green "Installing ImageMagik"
    sudo apt-get install imagemagick
    #ImageMagick Patch
    sudo apt-get install libmagickwand-dev
    export LD_LIBRARY_PATH=/usr/local/lib
    say_green "Installing Memcached"
    sudo apt-get install memcached
    say_green "Installing GIT and SVN"
    sudo apt-get install git-core subversion
    sudo echo "export PS1='\u \w $(__git_ps1 "\[\033[01;34m\]%s \[\033[00m\]")$ '"  >> ~/.bashrc
    #Patch for RVM GCC Issues
		sudo echo "export CFLAGS='-O2 -fno-tree-dce -fno-optimize-sibling-calls'" >> ~/.bashrc
		sudo echo "export CC='/usr/bin/gcc'" >> ~/.bashrc
		sudo echo "source ~/.bashrc" >> /etc/profile
	}

	function install_rvm_ruby
	{
		say_yellow "Installing RVM & REE Ruby"
    \curl -L https://get.rvm.io | bash -s stable
    source ~/.bashrc
    rvm install 1.9.3
    rvm --default use 1.9.3
    gem update --system 2.0.7 # => Important
    say_green "RVM + REE Installation Complete"
    echo "source $HOME/.rvm/scripts/rvm" >> ~/.bash_profile
    echo "source $HOME/.rvm/scripts/rvm" >> ~/.bashrc
    #RVM Patch
    export CFLAGS='-O2 -fno-tree-dce -fno-optimize-sibling-calls'
    export CC='/usr/bin/gcc'
    source ~/.bashrc

	}

	function install_rails3
	{	
		say_yellow "Installing Rails 3.2.13"
    gem install --version 3.2.13 rails --no-rdoc --no-ri
    say_green "Rails 3.2.13 Installation Complete"
	}

	function install_myql
	{
		say_yellow "Installing MySQL"
    sudo apt-get install libmysqlclient-dev 
    sudo apt-get install mysql-server-5.5 mysql-client-5.5
    gem install mysql2 -v=0.3.11 --no-rdoc --no-ri
    say_green "MySQL Installation Complete"

	}

	function  install_apache2
	{
		say_yellow "Installing Apache2"
		sudo apt-get install apache2 apache2-mpm-prefork apache2-prefork-dev	
		say_green "Completed installing Apache2"
	}

	function install_passenger_rails
	{
		say_yellow "Installing Passenger Mod Rails gem"
    sudo apt-get install libcurl4-openssl-dev
    gem install passenger -v 3.0.19
    say_green "Completed installing Passenger Mod Rails gem"
    say_yellow "Installing Apache2 Module for passenger,"
    say_cyan "Please take note at the end of this module installation Passenger will ask you to copy three Config Lines to /etc/apache2/apach2.conf "
    say_cyan "Please copy  those three lines while installation proceeds so that you can paste them in apache2.conf at the end of this installation script"
    passenger-install-apache2-module
    say_green "Completed installing Apache2 Module for passenger"
	}

	function setup
	{
		if  [ "$1" == "amazonbox" ]; then
			if [ $(id -un) == "ubuntu" ]; then
				say_cyan "Setting Up Enviromnet for $1"
				say_green "sudo chmod 775 /etc/profile"
				sudo chmod 775 /etc/profile
				get_essentials
				source /etc/profile
				install_java
				install_rvm_ruby
				install_rails3
				install_myql
				install_apache2
				install_passenger_rails
				say_red "Sourcing ~/.bashrc"
		    source ~/.bashrc
		    source /etc/profile
				say_green "Installation Complete"
			else
				say_red "Interrupted:: You must be logged in as User named ubuntu in your Amazon EC2 Instance Server Box to run this script"
			fi
		elif [ "$1" == "localbox" ];then
			say_cyan "Setting Up Enviromnet for $1"
			get_essentials
			install_java
			install_rvm_ruby
			install_rails3
			install_myql
			install_apache2
			install_passenger_rails
			say_red "Sourcing ~/.bashrc"
	    source ~/.bashrc
			say_green "Installation Complete"
		else
			say_red "please pass either 'localbox' or 'amazonbox' as argument"
		fi
	}
	#Calling Setup Function with Argument :localbox or :amamzonbox
	setup $1
