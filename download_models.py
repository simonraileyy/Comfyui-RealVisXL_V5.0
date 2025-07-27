import os

import requests
from huggingface_hub import hf_hub_download, snapshot_download
from tqdm import tqdm


def read_models():
    """Read model configurations from models.txt"""
    if not os.path.exists("models.txt"):
        print("No models.txt found, skipping model download")
        return []

    with open("models.txt", "r") as f:
        lines = f.readlines()

    models = []
    for line in lines:
        line = line.strip()
        if line and not line.startswith("#"):
            parts = line.split("|")
            if len(parts) >= 2:
                model_config = {
                    "repo_id": parts[0].strip(),
                    "local_path": parts[1].strip(),
                    "filename": parts[2].strip() if len(parts) > 2 else None,
                }
                models.append(model_config)

    return models


def download_file_with_progress(url, local_path):
    """Download a file with progress bar"""
    response = requests.get(url, stream=True)
    total_size = int(response.headers.get("content-length", 0))

    with (
        open(local_path, "wb") as f,
        tqdm(
            desc=os.path.basename(local_path),
            total=total_size,
            unit="B",
            unit_scale=True,
            unit_divisor=1024,
        ) as pbar,
    ):
        for chunk in response.iter_content(chunk_size=8192):
            if chunk:
                f.write(chunk)
                pbar.update(len(chunk))


def download_model(model_config):
    """Download a model from Hugging Face"""
    repo_id = model_config["repo_id"]
    local_path = model_config["local_path"]
    filename = model_config.get("filename")

    print(f"Downloading: {repo_id}")

    try:
        # Create local directory
        os.makedirs(local_path, exist_ok=True)

        if filename:
            # Download specific file
            print(f"  → Downloading {filename}")
            downloaded_path = hf_hub_download(
                repo_id=repo_id,
                filename=filename,
                local_dir=local_path,
            )
            print(f"  ✓ Downloaded to {downloaded_path}")
        else:
            # Download entire repository
            print("  → Downloading entire repository")
            snapshot_download(
                repo_id=repo_id,
                local_dir=local_path,
                ignore_patterns=["*.git*", "README.md", "*.txt"],
            )
            print(f"  ✓ Downloaded repository to {local_path}")

        return True

    except Exception as e:
        print(f"  ✗ Error downloading {repo_id}: {e}")
        return False


def main():
    print("=== Downloading Models ===")

    # Read model configurations
    models = read_models()

    if not models:
        print("No models to download")
        return

    print(f"Found {len(models)} models to download")

    success_count = 0
    for model_config in models:
        if download_model(model_config):
            success_count += 1
        print()  # Empty line for readability

    print("=== Download Complete ===")
    print(f"Successfully downloaded: {success_count}/{len(models)} models")

    # Show disk usage
    print("\nDisk usage:")
    os.system("du -sh models/")


if __name__ == "__main__":
    main()
