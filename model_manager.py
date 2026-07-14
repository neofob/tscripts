#!/usr/bin/env python3
"""
AI Model Manager

A modular CLI tool for downloading Hugging Face models, converting them to
GGUF format, and importing them into a local Ollama server.

Default target: nvidia/NVIDIA-Nemotron-3-Ultra-550B-A55B-NVFP4

Usage:
  python3 model_manager.py --download
  python3 model_manager.py --convert
  python3 model_manager.py --import
  python3 model_manager.py --full
  python3 model_manager.py --full --dry-run
"""

import argparse
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

try:
    from huggingface_hub import snapshot_download
except ImportError:
    print("Error: huggingface_hub not installed. Run: pip install huggingface_hub")
    sys.exit(1)

# ---------------------------------------------------------------------------
# Defaults
# ---------------------------------------------------------------------------

DEFAULT_REPO_ID = "nvidia/NVIDIA-Nemotron-3-Ultra-550B-A55B-NVFP4"
DEFAULT_MODEL_ROOT = Path("/home/tuan/models")
DEFAULT_MODEL_NAME = "nemotron-ultra-550b"
# NVFP4 at 550B: ~4 bits/param → ~275 GB; add overhead → 300 GB estimate
DEFAULT_ESTIMATED_GB = 300.0

LLAMA_CPP_SEARCH_PATHS = [
    Path.home() / "llama.cpp",
    Path("/opt/llama.cpp"),
    Path("/usr/local/lib/llama.cpp"),
]


# ---------------------------------------------------------------------------
# HFDownloader
# ---------------------------------------------------------------------------

class HFDownloader:
    """Download model weights from Hugging Face Hub with resume support."""

    def __init__(self, model_root: Path = DEFAULT_MODEL_ROOT):
        self.model_root = model_root
        self.model_root.mkdir(parents=True, exist_ok=True)

    def local_dir(self, repo_id: str) -> Path:
        """
        Resolve local storage path for a given repo_id.

        'nvidia/NVIDIA-Nemotron-3-Ultra-550B-A55B-NVFP4'
            -> /home/tuan/models/nvidia--NVIDIA-Nemotron-3-Ultra-550B-A55B-NVFP4
        """
        safe_name = repo_id.replace("/", "--")
        return self.model_root / safe_name

    def _check_disk_space(self, required_gb: float) -> None:
        """Warn and confirm if available disk space is below required_gb."""
        usage = shutil.disk_usage(self.model_root)
        available_gb = usage.free / (1024 ** 3)
        print(
            f"[HFDownloader] Disk space: {available_gb:.1f} GB available, "
            f"{required_gb:.1f} GB estimated required."
        )
        if available_gb < required_gb:
            print(
                "[HFDownloader] Warning: Available disk space may be insufficient."
            )
            answer = input("Continue anyway? [y/N]: ").strip().lower()
            if answer != "y":
                print("[HFDownloader] Aborted by user.")
                sys.exit(1)

    def download_model(self, repo_id: str, estimated_gb: float = DEFAULT_ESTIMATED_GB) -> Path:
        """
        Download all files from a Hugging Face repository.

        Relies on huggingface_hub's built-in caching: interrupted downloads
        resume automatically on the next invocation.

        Args:
            repo_id:      HF repository ID, e.g. 'nvidia/NVIDIA-Nemotron-3-...'
            estimated_gb: Estimated download size in GB for the disk space check.

        Returns:
            Path to the local directory containing the downloaded weights.
        """
        self._check_disk_space(estimated_gb)
        local_path = self.local_dir(repo_id)
        print(f"[HFDownloader] Downloading '{repo_id}' -> {local_path} ...")
        try:
            snapshot_download(repo_id=repo_id, local_dir=str(local_path))
        except KeyboardInterrupt:
            print("\n[HFDownloader] Download interrupted. Re-run to resume.")
            sys.exit(1)
        except Exception as exc:
            print(f"[HFDownloader] Download failed: {exc}")
            sys.exit(1)
        print(f"[HFDownloader] Download complete: {local_path}")
        return local_path


# ---------------------------------------------------------------------------
# ModelConverter
# ---------------------------------------------------------------------------

class ModelConverter:
    """Convert Hugging Face weights to GGUF format using llama.cpp tools."""

    def __init__(self, llama_cpp_path: Path = None):
        self.llama_cpp_path = llama_cpp_path or self._find_llama_cpp()

    def _find_llama_cpp(self) -> Path:
        """Search well-known locations for a llama.cpp installation."""
        for candidate in LLAMA_CPP_SEARCH_PATHS:
            if (candidate / "convert-hf-to-gguf.py").exists():
                return candidate
        return None

    def _validate_dependencies(self) -> None:
        """Ensure the conversion script is present."""
        if self.llama_cpp_path is None:
            print(
                "[ModelConverter] Error: llama.cpp not found.\n"
                "  Clone it from https://github.com/ggerganov/llama.cpp\n"
                "  and provide the path with --llama-cpp-path."
            )
            sys.exit(1)
        script = self.llama_cpp_path / "convert-hf-to-gguf.py"
        if not script.exists():
            print(f"[ModelConverter] Error: conversion script not found at {script}")
            sys.exit(1)
        print(f"[ModelConverter] Using conversion script: {script}")

    def _check_ram(self, model_size_gb: float, dry_run: bool = False) -> None:
        """Warn if available system RAM is likely too low for conversion."""
        try:
            mem_info = Path("/proc/meminfo").read_text()
            available_kb = int(
                next(
                    line.split()[1]
                    for line in mem_info.splitlines()
                    if line.startswith("MemAvailable")
                )
            )
            available_gb = available_kb / (1024 ** 2)
        except Exception:
            print("[ModelConverter] Warning: could not read /proc/meminfo; skipping RAM check.")
            return

        # Heuristic: conversion typically requires ~2x the model size in RAM.
        required_gb = model_size_gb * 2
        print(
            f"[ModelConverter] RAM: {available_gb:.1f} GB available, "
            f"~{required_gb:.0f} GB estimated required for conversion."
        )
        if available_gb < required_gb:
            print(
                f"[ModelConverter] Warning: converting a {model_size_gb:.0f} GB model "
                f"with only {available_gb:.1f} GB RAM may fail or rely on heavy swap."
            )
            if dry_run:
                print("[ModelConverter] Dry-run: skipping RAM confirmation prompt.")
                return
            answer = input("Continue anyway? [y/N]: ").strip().lower()
            if answer != "y":
                print("[ModelConverter] Aborted by user.")
                sys.exit(1)

    def convert(
        self,
        source_dir: Path,
        output_file: Path,
        outtype: str = "f16",
        model_size_gb: float = DEFAULT_ESTIMATED_GB,
        dry_run: bool = False,
    ) -> Path:
        """
        Convert HF weights to a GGUF file.

        Args:
            source_dir:    Directory containing the downloaded HF weights.
            output_file:   Desired path for the output .gguf file.
            outtype:       Output quantization type (f32, f16, q4_k_m, ...).
            model_size_gb: Estimated model size for the RAM check.
            dry_run:       Print the command without executing it.

        Returns:
            Path to the .gguf file (created or would-be-created on dry-run).
        """
        self._validate_dependencies()
        self._check_ram(model_size_gb, dry_run=dry_run)

        output_file = Path(output_file).resolve()
        output_file.parent.mkdir(parents=True, exist_ok=True)
        script = self.llama_cpp_path / "convert-hf-to-gguf.py"

        cmd = [
            "python3", str(script),
            str(source_dir),
            "--outfile", str(output_file),
            "--outtype", outtype,
        ]

        print(f"[ModelConverter] Command: {' '.join(cmd)}")
        if dry_run:
            print("[ModelConverter] Dry-run: command not executed.")
            return output_file

        try:
            subprocess.run(cmd, check=True)
        except subprocess.CalledProcessError as exc:
            print(f"[ModelConverter] Conversion failed (exit {exc.returncode}).")
            sys.exit(exc.returncode)

        print(f"[ModelConverter] Conversion complete: {output_file}")
        return output_file


# ---------------------------------------------------------------------------
# OllamaImporter
# ---------------------------------------------------------------------------

class OllamaImporter:
    """Register a GGUF model with a local Ollama server."""

    def _validate_ollama(self) -> None:
        """Confirm the ollama CLI is available in PATH."""
        try:
            subprocess.run(
                ["ollama", "--version"],
                capture_output=True,
                check=True,
            )
        except (FileNotFoundError, subprocess.CalledProcessError):
            print(
                "[OllamaImporter] Error: 'ollama' CLI not found in PATH.\n"
                "  Install Ollama from https://ollama.com/"
            )
            sys.exit(1)

    def import_model(self, model_name: str, gguf_path: Path) -> None:
        """
        Create a temporary Modelfile and register the model with Ollama.

        The temporary Modelfile is deleted regardless of whether the import
        succeeds or fails.

        Args:
            model_name: Name for the model in Ollama, e.g. 'nemotron-ultra-550b'.
            gguf_path:  Absolute path to the .gguf file.
        """
        self._validate_ollama()
        gguf_path = Path(gguf_path).resolve()

        if not gguf_path.exists():
            print(f"[OllamaImporter] Error: GGUF file not found at {gguf_path}")
            sys.exit(1)

        modelfile_content = f"FROM {gguf_path}\n"
        tmp_dir = tempfile.mkdtemp(prefix="ollama_import_")
        modelfile_path = Path(tmp_dir) / "Modelfile"

        try:
            modelfile_path.write_text(modelfile_content)
            print(f"[OllamaImporter] Modelfile: {modelfile_path}")
            print(f"[OllamaImporter] Importing '{model_name}' into Ollama...")

            cmd = ["ollama", "create", model_name, "-f", str(modelfile_path)]
            try:
                subprocess.run(cmd, check=True)
            except subprocess.CalledProcessError as exc:
                print(f"[OllamaImporter] Import failed (exit {exc.returncode}).")
                sys.exit(exc.returncode)

            print(f"[OllamaImporter] Import complete.")

            # Verify the model appears in ollama list
            result = subprocess.run(
                ["ollama", "list"], capture_output=True, text=True
            )
            if model_name in result.stdout:
                print(f"[OllamaImporter] Verified: '{model_name}' is listed in 'ollama list'.")
            else:
                print(
                    f"[OllamaImporter] Warning: '{model_name}' not seen in 'ollama list' "
                    "after import (may need a moment to appear)."
                )
        finally:
            shutil.rmtree(tmp_dir, ignore_errors=True)


# ---------------------------------------------------------------------------
# ModelManagerCLI
# ---------------------------------------------------------------------------

class ModelManagerCLI:
    """CLI entry point and pipeline orchestrator."""

    def build_parser(self) -> argparse.ArgumentParser:
        parser = argparse.ArgumentParser(
            prog="model_manager.py",
            description=(
                "AI Model Manager - Download, convert, and import Hugging Face "
                "models into a local Ollama server."
            ),
            formatter_class=argparse.RawDescriptionHelpFormatter,
            epilog=f"""
Examples:
  Download the default Nemotron-3-Ultra model:
    python3 model_manager.py --download

  Download a different repo:
    python3 model_manager.py --download --repo mistralai/Mistral-7B-v0.1 --estimated-size-gb 14

  Convert downloaded weights to GGUF (q4_k_m quantization):
    python3 model_manager.py --convert --outtype q4_k_m

  Import an existing GGUF into Ollama:
    python3 model_manager.py --import --model-name nemotron-ultra-550b

  Run the full pipeline:
    python3 model_manager.py --full

  Dry-run: show conversion command without executing:
    python3 model_manager.py --convert --dry-run

Defaults:
  --repo             {DEFAULT_REPO_ID}
  --model-name       {DEFAULT_MODEL_NAME}
  --model-root       {DEFAULT_MODEL_ROOT}
  --estimated-size-gb {DEFAULT_ESTIMATED_GB:.0f}
""",
        )

        # Configuration
        cfg = parser.add_argument_group("Configuration")
        cfg.add_argument(
            "--repo",
            default=DEFAULT_REPO_ID,
            metavar="REPO_ID",
            help="Hugging Face repository ID",
        )
        cfg.add_argument(
            "--model-name",
            default=DEFAULT_MODEL_NAME,
            metavar="NAME",
            help="Model name to register in Ollama",
        )
        cfg.add_argument(
            "--model-root",
            type=Path,
            default=DEFAULT_MODEL_ROOT,
            metavar="DIR",
            help="Base directory for storing model files",
        )
        cfg.add_argument(
            "--llama-cpp-path",
            type=Path,
            default=None,
            metavar="DIR",
            help="Path to llama.cpp directory (auto-detected if omitted)",
        )
        cfg.add_argument(
            "--outtype",
            default="f16",
            choices=["f32", "f16", "q8_0", "q4_k_m", "q4_k_s", "q5_k_m"],
            help="GGUF quantization type for --convert (default: f16)",
        )
        cfg.add_argument(
            "--estimated-size-gb",
            type=float,
            default=DEFAULT_ESTIMATED_GB,
            metavar="GB",
            help="Estimated model size for disk/RAM checks",
        )
        cfg.add_argument(
            "--dry-run",
            action="store_true",
            help="Print the conversion command without executing it",
        )

        # Actions
        actions = parser.add_argument_group("Actions (at least one required)")
        actions.add_argument(
            "--download",
            action="store_true",
            help="Download model weights from Hugging Face",
        )
        actions.add_argument(
            "--convert",
            action="store_true",
            help="Convert downloaded weights to GGUF (requires llama.cpp)",
        )
        actions.add_argument(
            "--import",
            dest="import_model",
            action="store_true",
            help="Import GGUF model into local Ollama server",
        )
        actions.add_argument(
            "--full",
            action="store_true",
            help="Run the complete pipeline: download -> convert -> import",
        )

        return parser

    def run(self) -> None:
        """Parse CLI arguments and execute the requested pipeline stages."""
        parser = self.build_parser()
        args = parser.parse_args()

        if not any([args.download, args.convert, args.import_model, args.full]):
            parser.print_help()
            sys.exit(0)

        # Instantiate components with user-provided configuration
        downloader = HFDownloader(model_root=args.model_root)
        converter = ModelConverter(llama_cpp_path=args.llama_cpp_path)
        importer = OllamaImporter()

        # Derive paths from configuration
        weights_dir = downloader.local_dir(args.repo)
        gguf_path = args.model_root / f"{args.model_name}.gguf"

        do_download = args.download or args.full
        do_convert = args.convert or args.full
        do_import = args.import_model or args.full

        if do_download:
            weights_dir = downloader.download_model(
                repo_id=args.repo,
                estimated_gb=args.estimated_size_gb,
            )

        if do_convert:
            gguf_path = converter.convert(
                source_dir=weights_dir,
                output_file=gguf_path,
                outtype=args.outtype,
                model_size_gb=args.estimated_size_gb,
                dry_run=args.dry_run,
            )

        if do_import:
            importer.import_model(
                model_name=args.model_name,
                gguf_path=gguf_path,
            )


# ---------------------------------------------------------------------------
# Entrypoint
# ---------------------------------------------------------------------------

if __name__ == "__main__":
    ModelManagerCLI().run()
