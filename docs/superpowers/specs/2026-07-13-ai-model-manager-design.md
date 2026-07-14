# Design Doc: AI Model Manager CLI

**Date:** 2026-07-13
**Topic:** Modular Python program for downloading, converting, and importing Hugging Face models to Ollama.
**Target Model:** NVIDIA-Nemotron-3-Ultra-550B-A55B-NVFP4

## 1. Overview
This utility provides a modular framework to handle the lifecycle of moving an AI model from Hugging Face to a local Ollama server. It focuses on extensibility, allowing for separate download, conversion, and import stages.

## 2. Architecture
The system is implemented as a set of specialized classes:

### 2.1 HFDownloader
- **Purpose**: Manage high-volume downloads from Hugging Face Hub.
- **Key Method**: `download_model(repo_id: str, local_dir: str)`
- **Implementation**: Uses `huggingface_hub.snapshot_download` for managed resumes and caching.

### 2.2 ModelConverter
- **Purpose**: Convert raw weights to GGUF format.
- **Key Method**: `convert(source_dir: str, output_file: str)`
- **Implementation**: Wraps `llama.cpp` conversion scripts (`convert-hf-to-gguf.py`). Validates dependencies before execution.

### 2.3 OllamaImporter
- **Purpose**: Register the converted GGUF with the local Ollama server.
- **Key Method**: `import_model(model_name: str, gguf_path: str)`
- **Implementation**: Generates a temporary `Modelfile` containing `FROM <gguf_path>` and runs `ollama create`.

### 2.4 ModelManagerCLI
- **Purpose**: CLI entry point and pipeline orchestrator.
- **Interface**: Uses `argparse` to support:
    - `--download`: Only download weights.
    - `--convert`: Only convert downloaded weights.
    - `--import`: Only import GGUF into Ollama.
    - `--full`: Execute all three steps sequentially.

## 3. Data Flow
1. **User** $\rightarrow$ `ModelManagerCLI` (Repo URL / Model Name).
2. `HFDownloader` $\rightarrow$ Downloads weights to local storage.
3. `ModelConverter` (Optional) $\rightarrow$ Transform raw weights $\rightarrow$ `.gguf`.
4. `OllamaImporter` $\rightarrow$ Creates Modelfile $\rightarrow$ `ollama create` $\rightarrow$ Ollama Server.

## 4. Error Handling & Constraints
- **Disk Space**: Check available space against estimated model size before starting.
- **Resumption**: Utilize `huggingface_hub` snapshot caching to avoid restarting downloads on failure.
- **Dependency Checks**: Validate presence of `ollama`, `llama.cpp` tools, and required Python libraries at startup.
- **RAM Warning**: Warn users about the high memory requirements for converting 550B parameter models.

## 5. File Structure
The utility will be implemented as a single script: `model_manager.py`.
