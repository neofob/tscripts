#!/usr/bin/env python3

import argparse
import os
import subprocess
import sys
from pathlib import Path
from huggingface_hub import snapshot_download

# --- Configuration ---
MODEL_NAME = "deepseek-v4-flash"
HF_REPO = "deepseek-ai/DeepSeek-V4-Flash"
WEIGHTS_DIR = Path(f"./models/{MODEL_NAME}-weights")
GGUF_FILE = Path(f"./models/{MODEL_NAME}.gguf")
MODELFILE_PATH = Path("Modelfile")
LLAMA_CPP_PATH = Path("./llama.cpp")  # Assumes llama.cpp is cloned in the same directory

def check_env():
    """Check for necessary tools."""
    if not os.path.exists(LLAMA_CPP_PATH):
        print(f"Warning: llama.cpp not found at {LLAMA_CPP_PATH}. Conversion will fail unless it's installed.")

    try:
        subprocess.run(["ollama", "--version"], capture_output=True, check=True)
    except (subprocess.CalledProcessError, FileNotFoundError):
        print("Error: 'ollama' CLI not found in PATH. Import will fail.")

def download():
    """Download model weights from HuggingFace."""
    print(f"Downloading {HF_REPO} to {WEIGHTS_DIR}...")
    WEIGHTS_DIR.mkdir(parents=True, exist_ok=True)
    snapshot_download(repo_id=HF_REPO, local_dir=WEIGHTS_DIR)
    print("Download complete.")

def convert():
    """Convert HF weights to GGUF using llama.cpp."""
    if not WEIGHTS_DIR.exists() or not any(WEIGHTS_DIR.iterdir()):
        print("Error: Model weights not found. Run with --download first.")
        sys.exit(1)

    convert_script = LLAMA_CPP_PATH / "convert_hf_to_gguf.py"
    if not convert_script.exists():
        print(f"Error: Conversion script not found at {convert_script}.")
        sys.exit(1)

    print(f"Converting weights to GGUF...")
    cmd = [
        "python3", str(convert_script),
        str(WEIGHTS_DIR),
        "--outfile", str(GGUF_FILE),
        "--outtype", "f16" # Using f16 as a safe default; can be adjusted to q4_k_m etc.
    ]
    subprocess.run(cmd, check=True)
    print(f"Conversion complete: {GGUF_FILE}")

def create_modelfile():
    """Create the Ollama Modelfile."""
    if not GGUF_FILE.exists():
        print("Error: GGUF file not found. Run with --convert first.")
        sys.exit(1)

    print(f"Creating Modelfile...")
    content = f"""FROM {GGUF_FILE.absolute()}
TEMPLATE \"\"\"{{ .System }}\nUSER: {{ .Prompt }}\nASSISTANT: \"\"\"
PARAMETER stop \"<|end_of_text|>\"
PARAMETER stop \"USER:\"
"""
    with open(MODELFILE_PATH, "w") as f:
        f.write(content)
    print(f"Modelfile created at {MODELFILE_PATH}")

def import_to_ollama():
    """Import the model into Ollama."""
    if not MODELFILE_PATH.exists():
        print("Error: Modelfile not found. Run with --modelfile first.")
        sys.exit(1)

    print(f"Importing {MODEL_NAME} to Ollama...")
    cmd = ["ollama", "create", MODEL_NAME, "-f", str(MODELFILE_PATH)]
    subprocess.run(cmd, check=True)
    print(f"Model {MODEL_NAME} successfully imported into Ollama.")

def main():
    parser = argparse.ArgumentParser(description="DeepSeek-V4-Flash HF to Ollama Pipeline")
    parser.add_argument("--download", action="store_true", help="Download weights from HuggingFace")
    parser.add_argument("--convert", action="store_true", help="Convert weights to GGUF format")
    parser.add_argument("--modelfile", action="store_true", help="Generate Ollama Modelfile")
    parser.add_argument("--import", dest="import_model", action="store_true", help="Import model into Ollama")

    args = parser.parse_args()

    if not any(vars(args).values()):
        parser.print_help()
        return

    check_env()

    if args.download:
        download()
    if args.convert:
        convert()
    if args.modelfile:
        create_modelfile()
    if args.import_model:
        import_to_ollama()

if __name__ == "__main__":
    main()
