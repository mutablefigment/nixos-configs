#!/usr/bin/env bash
# Helper script for common deployment tasks

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

function print_help() {
    cat <<EOF
NixOS Homelab Deployment Helper

Usage: $0 <command> [options]

Commands:
    build-iso               Build the installer ISO image
    deploy [MACHINE...]     Deploy to specified machines (or all if none specified)
    deploy-servers          Deploy to all servers (@server tag)
    deploy-desktops         Deploy to all desktops (@desktop tag)
    deploy-laptops          Deploy to all laptops (@laptop tag)
    check                   Check health of all deployed machines
    dry-run [MACHINE...]    Show what would be deployed without making changes
    update-flake            Update flake.lock
    test-ssh MACHINE        Test SSH connection to a machine

Examples:
    $0 build-iso
    $0 deploy describe gumshoe
    $0 deploy-servers
    $0 check
    $0 dry-run describe
    $0 test-ssh describe

Machines:
    - describe (desktop)
    - gumshoe (desktop)
    - traveler (laptop)
    - pve (server)

EOF
}

function build_iso() {
    echo -e "${GREEN}Building installer ISO...${NC}"
    nix build .#iso
    echo -e "${GREEN}ISO built successfully!${NC}"
    echo "Location: ./result/iso/"
    ls -lh ./result/iso/*.iso
}

function deploy() {
    local machines=("$@")
    if [ ${#machines[@]} -eq 0 ]; then
        echo -e "${YELLOW}Deploying to ALL machines...${NC}"
        nix run .#deploy-homelab
    else
        local machine_list=$(IFS=,; echo "${machines[*]}")
        echo -e "${YELLOW}Deploying to: ${machine_list}${NC}"
        nix run .#deploy-homelab -- --on "$machine_list"
    fi
    echo -e "${GREEN}Deployment complete!${NC}"
}

function deploy_by_tag() {
    local tag=$1
    echo -e "${YELLOW}Deploying to all ${tag}s...${NC}"
    nix run .#deploy-homelab -- --on "@${tag}"
    echo -e "${GREEN}Deployment complete!${NC}"
}

function check_health() {
    echo -e "${YELLOW}Checking health of deployed machines...${NC}"
    nix run .#check-homelab
}

function dry_run() {
    local machines=("$@")
    if [ ${#machines[@]} -eq 0 ]; then
        echo -e "${YELLOW}Dry run for ALL machines...${NC}"
        nix run .#deploy-homelab -- --dry-run
    else
        local machine_list=$(IFS=,; echo "${machines[*]}")
        echo -e "${YELLOW}Dry run for: ${machine_list}${NC}"
        nix run .#deploy-homelab -- --dry-run --on "$machine_list"
    fi
}

function update_flake() {
    echo -e "${YELLOW}Updating flake.lock...${NC}"
    nix flake update
    echo -e "${GREEN}Flake updated!${NC}"
    echo "Review changes and commit flake.lock if everything looks good."
}

function test_ssh() {
    local machine=$1
    if [ -z "$machine" ]; then
        echo -e "${RED}Error: Please specify a machine name${NC}"
        exit 1
    fi
    
    # Try to get hostname from morph config
    local hostname="${machine}.local"
    
    echo -e "${YELLOW}Testing SSH connection to ${machine} (${hostname})...${NC}"
    if ssh -o ConnectTimeout=5 "root@${hostname}" "echo 'SSH connection successful!'" 2>/dev/null; then
        echo -e "${GREEN}✓ SSH connection to ${machine} is working${NC}"
    else
        echo -e "${RED}✗ Failed to connect to ${machine}${NC}"
        echo "Make sure:"
        echo "  1. The machine is reachable at ${hostname}"
        echo "  2. SSH is enabled and running"
        echo "  3. You have the correct SSH keys configured"
        exit 1
    fi
}

# Main script logic
if [ $# -eq 0 ]; then
    print_help
    exit 0
fi

case "$1" in
    build-iso)
        build_iso
        ;;
    deploy)
        shift
        deploy "$@"
        ;;
    deploy-servers)
        deploy_by_tag "server"
        ;;
    deploy-desktops)
        deploy_by_tag "desktop"
        ;;
    deploy-laptops)
        deploy_by_tag "laptop"
        ;;
    check)
        check_health
        ;;
    dry-run)
        shift
        dry_run "$@"
        ;;
    update-flake)
        update_flake
        ;;
    test-ssh)
        if [ $# -lt 2 ]; then
            echo -e "${RED}Error: test-ssh requires a machine name${NC}"
            print_help
            exit 1
        fi
        test_ssh "$2"
        ;;
    help|--help|-h)
        print_help
        ;;
    *)
        echo -e "${RED}Unknown command: $1${NC}"
        print_help
        exit 1
        ;;
esac
