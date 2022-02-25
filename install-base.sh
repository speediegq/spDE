
# spDE Installer

echo "            ____  _____ "
echo "  ___ _ __ |  _ \| ____|"
echo " / __| '_ \| | | |  _|  "
echo " \__ \ |_) | |_| | |___ "
echo " |___/ .__/|____/|_____|"
echo "     |_|                "
echo "$(cat name)"
echo "Version: $(cat ver)"

user="$(whoami)"
repo="https://github.com/speediegamer/configurations"

if [[ $user = "root" ]]; then
	echo "Running as root, this is necessary!"
else
	echo "Not running as root, please run me as root! Did you run the wrong script? Run ./install.sh" && exit 1
fi

echo -n "Which user would you like to install dwm for? " && read user && echo "Ok, installing for $user!"

echo "Checking system"

if [[ -f "/usr/bin/git" ]]; then
	echo "Found git" && git=/usr/bin/git
else
	echo "Git not found" && git=null
fi


distro=null

if [[ -f "/usr/bin/emerge" ]]; then
	echo "Found distro: Gentoo" && distro=gentoo && installdwmdep="emerge x11-libs/libXinerama x11-libs/libXft media-fonts/terminus-font media-fonts/fontawesome picom xclip" && installgit="emerge git" && installfeh="emerge feh"
elif [[ -f "/usr/bin/apt" ]]; then
	echo "Found distro: Debian" && distro=debian && installdwmdep="apt install libc6 libx11-6 libxinerama1 make gcc suckless-tools xfonts-terminus picom && apt build-dep dwm fonts-font-awesome xclip" && installgit="apt install git" && installfeh="apt install feh"
elif [[ -f "/usr/bin/pacman" ]]; then
	echo "Found distro: Arch" && distro=arch && installdwmdep="pacman -S libxft libxinerama terminus-font ttf-font-awesome base-devel picom" && installgit="pacman -S git xclip" && installfeh="pacman -S feh"
elif [[ -f "/usr/bin/rpm" ]]; then
	echo "Found distro: RedHat" && distro=redhat && installdwmdep="yum install -y libXft-devel libXinerama-devel fontpackages-devel fontawesome-fonts-web xclip picom" && installgit="yum install -y git" && installfeh="yum install -y feh"
fi

if [[ $distro = "null" ]]; then
	echo "Your distro is not currently supported, please install the configurations manually!" && exit 1
elif [[ $distro = "redhat" ]]; then
	echo "This distro has not been tested. Please report any bugs you find!"
fi

if [[ $git = "null" ]]; then
	$installgit && echo "Installed git"
fi

$installdwmdep && echo "Installed dependencies" && $installfeh && echo "Installed feh"

mkdir -pv /usr/local/bin/.spDE && echo "Created /usr/local/bin/.spDE" && cd /usr/local/bin/.spDE || exit 1

# Clone repository
git clone $repo && echo "Cloned repository"

cd configurations/

cp .wallpaper.png "/usr/local/bin/.spDE/bg.png"

cd .config

cp -r dwm slstatus st dmenu /usr/local/bin/.spDE && echo "Copied source code"

cd /usr/local/bin/.spDE/dwm && make install && echo "Compiled dwm" && echo "Installed dwm"

cd /usr/local/bin/.spDE/st && make install && echo "Compiled st" && echo "Installed st"

cd /usr/local/bin/.spDE/dmenu && make install && echo "Compiled dmenu"

cd /usr/local/bin/.spDE/slstatus && make install && echo "Compiled slstatus" && echo "Installed slstatus"

cp -r /usr/local/bin/.spDE/dmenu/dmenu /usr/bin && echo "Copied dmenu binary"
cp -r /usr/local/bin/.spDE/dmenu/dmenu_run /usr/bin && echo "Copied dmenu_run binary"
cp -r /usr/local/bin/.spDE/dmenu/dmenu_path /usr/bin && echo "Copied dmenu_path binary"
cp -r /usr/local/bin/.spDE/dmenu/stest /usr/bin && echo "Copied stest binary"

chmod +x /usr/local/bin/.spDE/dmenu/dmenu && echo "Made dmenu binary executable"
chmod +x /usr/local/bin/.spDE/dmenu/dmenu_run && echo "Made dmenu_run binary executable"
chmod +x /usr/local/bin/.spDE/dmenu/dmenu_path && echo "Made dmenu_path binary executable"
chmod +x /usr/local/bin/.spDE/dmenu/stest && echo "Made stest binary executable"

echo "Installed dmenu" && echo "Installed software"

mkdir -pv /home/$user/.spDE

echo "Your config files will be in /home/$user/.spDE"

echo "/usr/local/bin/.spDE/slstatus/slstatus &" >> /usr/bin/spDE
echo "picom &" >> /usr/bin/spDE
echo "feh --bg-fill /usr/local/bin/.spDE/bg.png" >> /usr/local/bin/.spDE/wallpaper
echo "/usr/local/bin/.spDE/wallpaper &" >> /usr/bin/spDE
echo "/usr/local/bin/.spDE/dwm/dwm" >> /usr/bin/spDE

curl -o /usr/bin/sfetch-base https://raw.githubusercontent.com/speediegamer/sfetch/main/sfetch && echo "Downloaded sfetch"

chmod +x /usr/local/bin/.spDE/wallpaper && echo "Made wallpaper binary executable"
chmod +x /usr/bin/spDE && echo "Made spDE executable"
chmod +x /usr/bin/sfetch && echo "Made sfetch executable"

ln -sf /usr/local/bin/.spDE/dmenu/config.h /home/$user/.spDE/menu-config
ln -sf /usr/local/bin/.spDE/st/config.h /home/$user/.spDE/terminal-config
ln -sf /usr/local/bin/.spDE/dwm/config.h /home/$user/.spDE/wm-config
ln -sf /usr/local/bin/.spDE/slstatus/config.h /home/$user/.spDE/status-config
ln -sf /usr/local/bin/.spDE/wallpaper /home/$user/.spDE/wallpaper

echo "#!$SHELL" > /usr/bin/sfetch && echo "Added $SHELL to /usr/bin/sfetch"
cat /usr/bin/sfetch-base >> /usr/bin/sfetch && echo "Added sfetch code to /usr/bin/sfetch"

echo "/usr/bin/sfetch" >> /home/$user/.zshrc && echo "Added sfetch to /home/$user/.zshrc"
echo "/usr/bin/sfetch" >> /home/$user/.bashrc && echo "Added sfetch to /home/$user/.bashrc"

echo "Installed sfetch"

usermod -a -G wheel,audio,video $user && echo "Added user to audio, video and wheel groups"

echo "/usr/bin/spDE" >> /home/$user/.xinitrc && echo "Added /usr/bin/spDE to .xinitrc"

echo "NOTE: If you don't use xinit, please add /usr/bin/spDE to your display manager"

clear
echo " _____ _                 _                        _ "
echo "|_   _| |__   __ _ _ __ | | __  _   _  ___  _   _| |"
echo "  | | | '_ \ / _` | '_ \| |/ / | | | |/ _ \| | | | |"
echo "  | | | | | | (_| | | | |   <  | |_| | (_) | |_| |_|"
echo "  |_| |_| |_|\__,_|_| |_|_|\_\  \__, |\___/ \__,_(_)"
echo "                                |___/               "
echo "spDE has been successfully installed!"
echo "If you have xinit and xorg-server you can just run startx"
echo "Otherwise install it and run startx!"
echo
echo "For advanced users:"
echo "Your config files are in /home/$user/.spDE/"
echo "Simply edit them with a text editor."
echo
echo "The source code itself is in /usr/local/bin/.spDE."
echo "You must recompile it by running make after performing changes!"
echo
echo "If you enjoy this, please go support suckless.org!"
echo
echo "Have a good day!
exit 0
