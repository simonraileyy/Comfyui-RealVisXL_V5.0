import os
import subprocess
import sys
from urllib.parse import urlparse


def read_custom_nodes():
    """Read custom node URLs from custom_nodes.txt"""
    if not os.path.exists("custom_nodes.txt"):
        print("No custom_nodes.txt found, skipping custom node installation")
        return []

    with open("custom_nodes.txt", "r") as f:
        lines = f.readlines()

    # Filter out comments and empty lines
    urls = []
    for line in lines:
        line = line.strip()
        if line and not line.startswith("#"):
            urls.append(line)

    return urls


def get_repo_name(url):
    """Extract repository name from GitHub URL"""
    parsed = urlparse(url)
    path_parts = parsed.path.strip("/").split("/")
    if len(path_parts) >= 2:
        return path_parts[1]  # Repository name
    return None


def install_custom_node(url):
    """Clone and install a custom node"""
    print(f"Installing custom node: {url}")

    repo_name = get_repo_name(url)
    if not repo_name:
        print(f"Error: Could not extract repo name from {url}")
        return False

    node_path = f"custom_nodes/{repo_name}"

    try:
        # Clone the repository
        subprocess.run(["git", "clone", url, node_path], check=True)
        print(f"✓ Cloned {repo_name}")

        # Check for requirements.txt and install dependencies
        requirements_path = os.path.join(node_path, "requirements.txt")
        if os.path.exists(requirements_path):
            print(f"Installing requirements for {repo_name}...")
            subprocess.run(
                [sys.executable, "-m", "pip", "install", "-r", requirements_path],
                check=True,
            )
            print(f"✓ Installed requirements for {repo_name}")

        # Check for install.py and run it
        install_script = os.path.join(node_path, "install.py")
        if os.path.exists(install_script):
            print(f"Running install script for {repo_name}...")
            subprocess.run([sys.executable, install_script], cwd=node_path, check=True)
            print(f"✓ Ran install script for {repo_name}")

        return True

    except subprocess.CalledProcessError as e:
        print(f"✗ Error installing {repo_name}: {e}")
        return False
    except Exception as e:
        print(f"✗ Unexpected error installing {repo_name}: {e}")
        return False


def main():
    print("=== Installing Custom Nodes ===")

    # Create custom_nodes directory
    os.makedirs("custom_nodes", exist_ok=True)

    # Read custom node URLs
    urls = read_custom_nodes()

    if not urls:
        print("No custom nodes to install")
        return

    print(f"Found {len(urls)} custom nodes to install")

    success_count = 0
    for url in urls:
        if install_custom_node(url):
            success_count += 1

    print("\n=== Installation Complete ===")
    print(f"Successfully installed: {success_count}/{len(urls)} custom nodes")


if __name__ == "__main__":
    main()
