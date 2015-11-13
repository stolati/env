# Goal
This is my environment files, rules: 
- only the common configuration should be there (between different computers)
- no private key, no password, no ip adresses, only public informations


# Uses with

There is multiples uses:
- `wget https://raw.githubusercontent.com/stolati/env/master/install.bash | bash`
- `wget https://raw.githubusercontent.com/stolati/env/master/portable.bash | bash`


#To me load :
# - aptitude install git ssh xclip
# - ssh-keygen -t rsa -b 4096 -C "stolati@gmail.com"
# - git config --global user.name "Mickael Kerbrat"
# - git config --global user.email "stolati@gmail.com"
# - xclip -sel clip < ~/.ssh/id_rsa.pub
# - paste into github stuff
# - git clone git@github.com:stolati/env.git
# - ./env/install.bash
