#!/bin/bash

echo "Please select an operation:"
echo "1) Install Rust and Cargo"
echo "2) Install Solana CLI and generate keypair"
echo "3) Install Ore CLI"
echo "4) Install nvm, Node.js, and globally install pm2"
echo "5) Run Ore miner with pm2"
echo "6) Check reward amount"
echo "7) Run Ore reward claiming with pm2"
read -p "Enter option [1-7]: " choice

default_rpc="https://api.mainnet-beta.solana.com"
default_threads=4

case $choice in
    1)
        echo "Installing Rust and Cargo..."
        curl https://sh.rustup.rs -sSf | sh
        source ~/.bashrc
        echo "Please run source .bashrc"
        ;;
    2)
        echo "Installing Solana CLI..."
        sh -c "$(curl -sSfL https://release.solana.com/v1.18.4/install)"
        echo "Generating Solana keypair..."
        export PATH="/root/.local/share/solana/install/active_release/bin:$PATH"
        solana-keygen new
        ;;
    3)
        echo "Installing Ore CLI..."
        apt-get update
        apt-get install build-essential
        cargo install ore-cli
        ;;
    4)
        echo "Installing nvm, Node.js, and globally installing pm2..."
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash
        export NVM_DIR="$HOME/.nvm"
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
        nvm install node # Install the latest version of Node.js and npm
        npm install pm2@latest -g
        export NVM_DIR="$HOME/.nvm"
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
        [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
        echo "Please run source .bashrc"

        ;;
    5)
        echo "Creating Ore miner run script..."
        read -p "Enter Ore RPC address [Press Enter for default: ${default_rpc}]: " rpc
        rpc=${rpc:-$default_rpc}
        read -p "Enter number of miner threads [Press Enter for default: ${default_threads}]: " threads
        threads=${threads:-$default_threads}
        echo "#!/bin/bash" > ore_miner.sh
        echo "ore --rpc ${rpc} --keypair ~/.config/solana/id.json --priority-fee 500000 mine --threads ${threads}" >> ore_miner.sh
        chmod +x ore_miner.sh
        echo "Starting Ore miner run script with pm2..."
        pm2 start ore_miner.sh --name ore-miner
        echo "Ore miner run script has been started in the background via pm2."
        ;;
    6)
        ore --rpc https://api.mainnet-beta.solana.com --keypair ~/.config/solana/id.json rewards
        ;;
    7)
        echo "Creating Ore claiming run script..."
        read -p "Enter Ore RPC address [Default: ${default_rpc}]: " rpc
        rpc=${rpc:-$default_rpc}
        echo "#!/bin/bash" > ore_miner.sh
        echo "ore --rpc ${rpc} --keypair ~/.config/solana/id.json --priority-fee 500000 claim" >> ore_claimer.sh
        chmod +x ore_claimer.sh
        echo "Starting Ore miner run script with pm2..."
        pm2 start ore_claimer.sh --name ore-claimer
        echo "Ore miner run script has been started in the background via pm2."
        ;;
    *)
        echo "Invalid option selected. Exiting."
        exit 1
      ;;
esac

echo "Operation completed."
