#!/bin/sh
# spDE Installer

clear
echo "            ____  _____ "
echo "  ___ _ __ |  _ \| ____|"
echo " / __| '_ \| | | |  _|  "
echo " \__ \ |_) | |_| | |___ "
echo " |___/ .__/|____/|_____|"
echo "     |_|                "
echo "spDE is licensed under the MIT license. Visit the repository for more information."
echo "$(<name)"
echo "Version: $(<ver)"

repo="https://github.com/speediegamer/spDE-resources"

if [[ $LOGNAME = "root" ]]; then
	echo "Running as root, this is necessary!"
else
	echo "Not running as root, please run me as root! Did you run the wrong script? Run ./install.sh" && exit 1
fi

echo -n "Which user would you like to install dwm for? " && read user

if [[ -d "/home/$user" ]]; then
        echo "Ok, installing for $user!"
else
        echo "Invalid user, exiting.." && exit 1
fi

if [[ -f "/usr/bin/emerge" ]]; then
	echo "Found distro: Gentoo" && distro=gentoo
elif [[ -f "/usr/bin/apt" ]]; then
	echo "Found distro: Debian" && distro=debian
elif [[ -f "/usr/bin/pacman" ]]; then
	echo "Found distro: Arch Based Distro" && distro=arch
elif [[ -f "/usr/bin/rpm" ]]; then
	echo "Found distro: RedHat" && distro=redhat
fi

# Gentoo
if [[ -f "/usr/bin/emerge" ]]; then
        echo "You seem to be a based /g/entoo user. Emerging might take a good while so please make sure your make.conf is optimized!!"
        mkdir -pv /etc/portage/package.use || exit 1
	echo "x11-libs/cairo X" > /etc/portage/package.use/cairo || exit 1
	echo "media-plugins/alsa-plugins pulseaudio" > /etc/portage/package.use/alsa-plugins || exit 1
	echo "x11-libs/cairo X" > /etc/portage/package.use/cairo || exit 1
	echo "x11-base/xorg-server udev -minimal" > /etc/portage/package.use/xorg-server || exit 1
	echo "media-libs/libvpx postproc" > /etc/portage/package.use/libvpx || exit 1
	echo "media-libs/harfbuzz icu" > /etc/portage/package.use/harfbuzz || exit 1
	echo "media-libs/libglvnd X" > /etc/portage/package.use/libglvnd || exit 1
        emerge --sync || exit 1
	emerge --autounmask --verbose xrdb x11-libs/libXinerama media-fonts/terminus-font neovim media-fonts/fontawesome picom x11-misc/xclip moc alsa-utils htop firefox-bin maim feh dev-vcs/git xorg-server xinit newsboat zsh yt-dlp && echo "Installed dependencies"
fi

# Debian
if [[ -f "/usr/bin/apt" ]]; then
        apt update || exit 1
	apt install libc6 libx11-6 xorg-xrdb libxinerama1 make gcc suckless-tools doas xfonts-terminus compton neovim moc alsa-utils fonts-font-awesome xclip maim firefox git feh htop xorg-server xinit newsboat && apt build-dep dwm zsh yt-dlp && echo "Installed dependencies"
fi

# Arch
if [[ -f "/usr/bin/pacman" ]]; then
	if if $(< /etc/os-release | grep "Artix"); then
		echo "Found Artix"
		pacman -Sy || exit 1
		pacman -S libxinerama xorg-server terminus-font ttf-font-awesome base-devel picom alsa-utils firefox maim git xclip feh neovim xorg-server xorg-xinit newsboat htop zsh yt-dlp && echo "Installed dependencies"
        else
	echo "Found Arch"
        pacman-key --init ; pacman-key --populate archlinux # Snippet by @jornmann
        pacman -Sy || exit 1
	pacman -S libxinerama xorg-xrdb terminus-font ttf-font-awesome base-devel picom moc alsa-utils firefox maim git xclip feh neovim xorg-server xorg-xinit newsboat htop zsh yt-dlp && echo "Installed dependencies"
	fi
fi

# RedHat/Fedora
if [[ -f "/usr/bin/yum" ]]; then
        yum install -y newsboat xrdb libXinerama-devel fontpackages-devel fontawesome-fonts-web xclip picom moc alsa-utils firefox maim feh git neovim xorg-xinit xorg-server htop zsh yt-dlp && echo "Installed dependencies"
fi

# Void Linux
if [[ -f "/usr/bin/xbps-install" ]]; then
        xbps-install -S base-devel libX11-devel xrdb newsboat libXinerama-devel freetype-devel terminus-font font-awesome zsh alsa-utils xorg-server xinit firefox maim moc git xclip feh fontconfig-devel htop picom xf86-input-libinput neovim yt-dlp && echo "Installed dependencies"
fi

# Check if we even installed anything..
if [[ -f "/usr/bin/git" ]]; then
	echo "Git found :D"
else
        clear && echo "Git was not found. This script is therefore probably broken. What a shame!" && exit
fi

# Prepare 'n stuff

mkdir -pv /usr/local/bin/.spDE && echo "Created /usr/local/bin/.spDE" && cd /usr/local/bin/.spDE || exit 1

# Clone repository
git clone $repo && echo "Cloned repository"

cd spDE-resources || exit 1

cp .wallpaper.png "/usr/local/bin/.spDE/bg.png"

cd .config || exit 1

cp -r dwm slstatus st dmenu /usr/local/bin/.spDE && echo "Copied source code"

cd /usr/local/bin/.spDE || exit 1

# libXft-bgra fixes st, dwm and dmenu crashing
git clone https://github.com/uditkarode/libxft-bgra || exit 1
cd libxft-bgra || exit 1
sh autogen.sh --sysconfdir=/etc --prefix=/usr --mandir=/usr/share/man
make install && echo "Installed libXft-bgra"

cd /usr/local/bin/.spDE/dwm && make clean && make && echo "Compiled dwm" && echo "Installed dwm"
cd /usr/local/bin/.spDE/st && make clean && make install && echo "Compiled st" && echo "Installed st"
cd /usr/local/bin/.spDE/dmenu && make clean && make install && echo "Compiled dmenu"
cd /usr/local/bin/.spDE/slstatus && make clean && make && echo "Compiled slstatus" && echo "Installed slstatus"

cp -r /usr/local/bin/.spDE/dmenu/dmenu /usr/bin && echo "Copied dmenu binary"
cp -r /usr/local/bin/.spDE/dmenu/dmenu_run /usr/bin && echo "Copied dmenu_run binary"
cp -r /usr/local/bin/.spDE/dmenu/dmenu_path /usr/bin && echo "Copied dmenu_path binary"
cp -r /usr/local/bin/.spDE/dmenu/stest /usr/bin && echo "Copied stest binary"

chmod +x /usr/bin/dmenu && echo "Made dmenu binary executable"
chmod +x /usr/bin/dmenu_run && echo "Made dmenu_run binary executable"
chmod +x /usr/bin/dmenu_path && echo "Made dmenu_path binary executable"
chmod +x /usr/bin/stest && echo "Made stest binary executable"

rm -rf /usr/local/bin/dmenu && echo "Removed old dmenu binary"
rm -rf /usr/local/bin/dmenu_run && echo "Removed old dmenu_run binary"
rm -rf /usr/local/bin/dmenu_path && echo "Removed old dmenu_path binary"
rm -rf /usr/local/bin/stest && echo "Removed old stest binary"

chmod +x /usr/local/bin/.spDE/slstatus/slstatus && echo "Made slstatus executable"
chmod +x /usr/local/bin/.spDE/st/st && echo "Made st executable"
chmod +x /usr/local/bin/.spDE/dwm/dwm && echo "Made dwm executable"

if [[ -f /usr/bin/firefox-bin ]]; then
        cp /usr/bin/firefox-bin /usr/bin/firefox
elif [[ -f /usr/bin/scrot ]]; then
        mkdir /home/$user/Screenshots && touch /home/$user/Screenshots/.TempScreenshot.png
fi

if [[ -f /usr/bin/compton ]]; then
       cp /usr/bin/compton /usr/bin/picom
fi

echo "Installed dmenu" && echo "Installed software"

mkdir -pv /home/$user/.spDE

echo "Your config files will be in /home/$user/.spDE"

echo "/usr/local/bin/.spDE/slstatus/slstatus &" > /usr/bin/spDE
echo "/usr/bin/picom &" >> /usr/bin/spDE
echo "/usr/bin/xrdb ~/.Xresources" >> /usr/bin/spDE
echo "#!/bin/sh" > /usr/local/bin/setwallpaper-wm
echo "feh --bg-fill /usr/local/bin/.spDE/bg.png" > /usr/local/bin/setwallpaper-wm
ln -s "/usr/local/bin/setwallpaper-wm" "/usr/local/bin/.spDE/wallpaper"
echo "/usr/local/bin/.spDE/wallpaper" >> /usr/bin/spDE
echo "/usr/bin/xclip &" >> /usr/bin/spDE
echo "/usr/local/bin/.spDE/dwm/dwm" >> /usr/bin/spDE

echo "startx" > /home/$user/.zprofile
echo "startx" > /home/$user/.bash_profile

mkdir -pv /home/$user/.config/newsboat && echo "Created newsboat directory"

echo 'browser "firefox"' > /home/$user/.config/newsboat/config
echo 'player "mpv"' >> /home/$user/.config/newsboat/config
echo 'download-path "~/Downloads/%n"' >> /home/$user/.config/newsboat/config
echo 'save-path "~/Downloads"' >> /home/$user/.config/newsboat/config
echo 'reload-threads 20' >> /home/$user/.config/newsboat/config
echo 'cleanup-on-quit yes' >> /home/$user/.config/newsboat/config
echo 'text-width 74' >> /home/$user/.config/newsboat/config
echo 'auto-reload yes' >> /home/$user/.config/newsboat/config && echo "Created newsboat config file"

echo '__/twitter' > /home/$user/.config/newsboat/urls
echo 'https://nitter.net/spdgmr/rss' >> /home/$user/.config/newsboat/urls
echo 'https://nitter.net/project081/rss' >> /home/$user/.config/newsboat/urls
echo '__/blogs' >> /home/$user/.config/newsboat/urls
echo 'https://raw.githubusercontent.com/spdgmr/posts/main/rss.xml' >> /home/$user/.config/newsboat/urls
echo '__/wikis' >> /home/$user/.config/newsboat/urls

if [[ -f "/usr/bin/emerge" ]]; then
        echo 'https://planet.gentoo.org/rss20.xml' >> /home/$user/.config/newsboat/urls
elif [[ -f "/usr/bin/pacman" ]]; then
        echo 'https://archlinux.org/feeds/packages/x86_64/' >> /home/$user/.config/newsboat/urls
elif [[ -f "/usr/bin/xbps-install" ]]; then
        echo 'https://github.com/void-linux/void-packages/commits/master.atom' >> /home/$user/.config/newsboat/urls
elif [[ $(cat /etc/os-release) =~ "artix" ]]; then
        echo 'https://artixlinux.org/feed.php' >> /home/$user/.config/newsboat/urls
fi

echo "Created newsboat urls file"
curl -o /usr/bin/sfetch https://raw.githubusercontent.com/speediegamer/sfetch/main/sfetch && echo "Downloaded sfetch"
echo "Installed sfetch"

curl -o /usr/bin/fff https://raw.githubusercontent.com/dylanaraps/fff/master/fff && echo "Downloaded fff file manager"
curl -o /usr/bin/setwallpaper https://raw.githubusercontent.com/speediegamer/setwallpaper/main/setwallpaper && echo "Downloaded setwallpaper"

chmod +x /usr/local/bin/.spDE/wallpaper && echo "Made wallpaper binary executable"
chmod +x /usr/local/bin/setwallpaper-wm && echo "Made other wallpaper binary executable"
chmod +x /usr/bin/spDE && echo "Made spDE executable"
chmod +x /usr/bin/sfetch && echo "Made sfetch executable"
chmod +x /usr/bin/fff && echo "Made fff executable"
chmod +x /usr/bin/setwallpaper && echo "Made setwallpaper executable"

mkdir -pv /home/$user/.config/st
mkdir -pv /home/$user/.config/dwm
mkdir -pv /home/$user/.config/dmenu
mkdir -pv /home/$user/.config/slstatus

ln -sf /usr/local/bin/.spDE/dmenu/config.def.h /home/$user/.spDE/menu-config
ln -sf /usr/local/bin/.spDE/st/config.def.h /home/$user/.spDE/terminal-config
ln -sf /usr/local/bin/.spDE/dwm/config.def.h /home/$user/.spDE/wm-config
ln -sf /usr/local/bin/.spDE/slstatus/config.def.h /home/$user/.spDE/status-config
ln -sf /usr/local/bin/.spDE/wallpaper /home/$user/.spDE/wallpaper
ln -sf /usr/local/bin/.spDE/st/st /home/$user/.config/st/st
ln -sf /usr/local/bin/.spDE/dwm/dwm /home/$user/.config/dwm/dwm
ln -sf /usr/local/bin/.spDE/dmenu/dmenu /home/$user/.config/dmenu/dmenu
ln -sf /usr/local/bin/.spDE/dmenu/dmenu_run /home/$user/.config/dmenu/dmenu_run
ln -sf /usr/local/bin/.spDE/dmenu/dmenu_path /home/$user/.config/dmenu/dmenu_path
ln -sf /usr/local/bin/.spDE/dmenu/stest /home/$user/.config/dmenu/stest
ln -sf /usr/local/bin/.spDE/slstatus/slstatus /home/$user/.config/slstatus/slstatus

echo "/usr/bin/sfetch" >> /home/$user/.zshrc && echo "Added sfetch to /home/$user/.zshrc"
echo "/usr/bin/sfetch" >> /home/$user/.bashrc && echo "Added sfetch to /home/$user/.bashrc"

echo "Installed sfetch"

curl -o /home/$user/.zshrc https://raw.githubusercontent.com/speediegamer/spDE-resources/main/.zshrc_spDE
curl -o /home/$user/.Xresources https://raw.githubusercontent.com/speediegamer/spDE-resources/main/.Xresources && echo "Downloaded .Xresources"
curl -o /usr/local/bin/.spDE/welcome https://raw.githubusercontent.com/speediegamer/spDE-resources/main/.config/welcome.sh
curl -o /usr/local/bin/.spDE/ver https://raw.githubusercontent.com/speediegamer/spDE/main/ver && echo "Write version info"
chmod +x /usr/local/bin/.spDE/welcome && echo "Installed welcome script"

ln -s /home/$user/.zshrc /root/.zshrc && echo "Created .zshrc alias for root user"

usermod -a -G wheel $user && echo "Added user to wheel group"
usermod -a -G audio $user && echo "Added user to audio group"
usermod -a -G video $user && echo "Added user to video group"

chown -R $user /home/$user && echo "Changed owner of /home/$user"
chmod -R 777 /home/$user && echo "Changed permissions of /home/$user to 777"
chmod -R 777 /usr/local/bin && echo "Changed permissions of /usr/local/bin"
chown -R $user /usr/local/bin && echo "Changed owner of /usr/local/bin"

echo "/usr/bin/spDE" >> /home/$user/.xinitrc && echo "Added /usr/bin/spDE to .xinitrc"

echo "NOTE: If you don't use xinit, please add /usr/bin/spDE to your display manager"

chsh -s /bin/zsh $user && echo "Changed shell to zsh"

echo '/usr/local/bin/.spDE/welcome && rm /usr/local/bin/.spDE/welcome && echo "clear && $FETCH" >> /home/$(whoami)/.zshrc' >> /home/$user/.zshrc && echo "Edited .zshrc"

clear
echo " _____ _                 _                        _ "
echo "|_   _| |__   __ _ _ __ | | __  _   _  ___  _   _| |"
echo "  | | | '_ \ / _  | '_ \| |/ / | | | |/ _ \| | | | |"
echo "  | | | | | | (_| | | | |   <  | |_| | (_) | |_| |_|"
echo "  |_| |_| |_|\__,_|_| |_|_|\_\  \__, |\___/ \__,_(_)"
echo "                                |___/               "
echo "spDE has been successfully installed!"
echo "Xorg server and xinit has also been installed."
echo "spDE should automatically run when you log in as $user"
echo "If not, just run 'startx'."
echo
echo "If it fails, you probably need a graphics driver."
echo "The package should be 'xf86-video-something'"
echo "If it 'freezes', you will need 'xf86-input-libinput'."
echo
echo "For advanced users:"
echo "Your config files are in /home/$user/.spDE/"
echo "Simply edit them with a text editor (NeoVim or nvim comes preinstalled."
echo
echo "The source code itself is in /usr/local/bin/.spDE."
echo "You must recompile it by running make after performing changes!"
echo
echo "If you enjoy this, please go support suckless.org!"
echo
echo "Have a good day!"

exit 0
