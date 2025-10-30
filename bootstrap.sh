#go sketchy bash one liner
wget -q -O - https://git.io/vQhTU | bash 

#older version https://gist.github.com/paulgmiller/860cf63a582ddb2c02c4891d0935ade1
 # Docker
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
# Add the repository to Apt sources:
echo   "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
$(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" |   sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo groupadd docker
docker run hello-world


#Githb cli.
(type -p wget >/dev/null || (sudo apt update && sudo apt install wget -y)) \
	&& sudo mkdir -p -m 755 /etc/apt/keyrings \
	&& out=$(mktemp) && wget -nv -O$out https://cli.github.com/packages/githubcli-archive-keyring.gpg \
	&& cat $out | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null \
	&& sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg \
	&& sudo mkdir -p -m 755 /etc/apt/sources.list.d \
	&& echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
	&& sudo apt update \
	&& sudo apt install gh -y
sudo apt update
sudo apt install gh


# make  and jq
apt install make jq 

#git config
git config --add --global user.name "Paul Miller"
git config --add --global user.email "pmiller@microsoft.com"

#install azure cli
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
#install kubectl 
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

#kubectl aliases
curl https://raw.githubusercontent.com/ahmetb/kubectl-aliases/master/.kubectl_aliases > .kubectl_aliases 

#git credential manager
# https://github.com/git-ecosystem/git-credential-manager/blob/release/docs/install.md
# fails with yes/no curl -L https://aka.ms/gcm/linux-install-source.sh | sh
#curl -L https://aka.ms/gcm/linux-install-source.sh > install-gcm.sh
#chmod +x ./install-gcm.sh
#./install-gcm.sh
#https://github.com/git-ecosystem/git-credential-manager/blob/release/docs/credstores.md
#sudo apt install pass
#gpg --gen-key
#use second line of pub 
#pass init <gpg-id> #37195816B671757C13ED153D9F43456D849B9500
#git config --global credential.credentialStore gpg


#holyshit gcm doesn't work on wsl unless it execs into windows becasue there is no secret store? Yikes!
#Wants us to call out to a windows binary? no thank youhttps://github.com/git-ecosystem/git-credential-manager/blob/release/docs/wsl.md
#I think this might also work with gcm and cache instead of gpg but didn't go back and test it. 
go install github.com/hickford/git-credential-azure@latest
git config --global credential.helper "cache --timeout 21600"
git config --global --add credential.helper "azure -device"
git config --global credential.useHttpPath true
# 2) URL rewrite: map legacy prefix to modern prefix (org-specific)
git config --global url."https://dev.azure.com/msazure/".insteadof \
  https://msazure.visualstudio.com/DefaultCollection/



#go proxy  

#zsh omyzsh is more personal prefernce
sudo apt install zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"



# Go get your github repos and plop 
gh repo list --limit 10 --json nameWithOwner --jq '.[].nameWithOwner'   | xargs -n1 gh repo clone