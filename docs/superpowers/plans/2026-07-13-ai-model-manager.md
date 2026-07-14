# AI Model Manager Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Create a modular Python CLI tool to download Hugging Face models, convert them to GGUF, and import them into Ollama.

**Architecture:** Class-based modular design featuring `HFDownloader`, `ModelConverter`, `OllamaImporter`, and `ModelManagerCLI`.

**Tech Stack:** Python 3, `huggingface_hub` library, `subprocess` for CLI wrappers.

## Global Constraints
- Use absolute paths where possible.
- Model root directory: `/home/tuan/models/`.
- Must check disk space before large operations.
- Support resumable downloads via `huggingface_hub`.
- No emojis in code or logs.

---

### Task 1: Project Scaffolding and CLI Interface

**Files:**
- Create: `model_manager.py`

**Interfaces:**
- Produces: `ModelManagerCLI` class with `run()` method taking arguments from `argparse`.

- [ ] **Step 1: Setup basic imports and argument parser**
    - Implement `argparse` with flags: `--download`, `--convert`, `--import`, `--full`, and positional argument for model repo/name.
    - Create placeholders for the four main classes.

- [ ] **Step 2: Implement base directory logic**
    - Ensure `/home/tuan/models/` exists.
    - Implement a helper method to resolve local paths based on repo ID.

- [ ] **Step 3: Basic execution loop**
    - Connect the CLI flags to internal methods that will be implemented in later tasks.

- [ ] **Step 4: Test CLI parsing**
    - Run `python3 model_manager.py --help` and verify output.
    - Verify that flags are correctly captured.

### Task 2: HFDownloader Implementation

**Files:**
- Modify: `model_manager.py` (Add `HFDownloader` class)

**Interfaces:**
- Produces: `HFDownloader.download_model(repo_id, local_dir)` -> returns path to downloaded folder.

- [ ] **Step 1: Implement disk space check**
    - Use `shutil.disk_usage()` to verify available space in `/home/tuan/models/` before download begins.

- [ ] **Step 2: Implement managed download**
    - Use `huggingface_hub.snapshot_download(repo_id=repo_id, local_dir=local_dir)` to ensure resumes and caching.
    - Wrap in try-except block for network errors.

- [ ] **Step 3: Verify downloader with a tiny model**
    - Use a small repo (e.g., `gpt2`) to verify that the folder is created and files are downloaded.
    - Run: `python3 model_manager.py --download gpt2`

### Task 3: ModelConverter Implementation

**Files:**
- Modify: `model_manager.py` (Add `ModelConverter` class)

**Interfaces:**
- Consumes: Local path from `HFDownloader`.
- Produces: `ModelConverter.convert(source_dir, output_file)` -> returns path to `.gguf` file.

- [ ] **Step 1: Dependency validation**
    - Implement check for `convert-hf-to-gguf.py` in PATH or a known location.
    - Print warning if missing.

- [ ] **Step 2: Implementation of conversion wrapper**
    - Use `subprocess.run()` to execute the conversion script.
    - Pass required arguments (model path, output path).

- [ ] **Step 3: RAM check/warning**
    - Implement a check for available system memory; print warning if converting large models (~550B) without sufficient swapping or hardware.

- [ ] **Step 4: Verify conversion logic (mock)**
    - Since actual conversion takes hours, implement a "dry run" mode or use a tiny model to ensure the subprocess call is formatted correctly.

### Task 4: OllamaImporter Implementation

**Files:**
- Modify: `model_manager.py` (Add `OllamaImporter` class)

**Interfaces:**
- Consumes: Path to `.gguf` file from `ModelConverter`.
- Produces: Execution of `ollama create`.

- [ ] **Step 1: Modelfile generator**
    - Implement method to write a temporary `Modelfile` with the content: `FROM /path/to/model.gguf`.

- [ ] **Step 2: Ollama registration wrapper**
    - Use `subprocess.run(["ollama", "create", model_name, "-f", modelfile_path])`.
    - Implement cleanup to delete the temporary Modelfile regardless of success or failure (use `try...finally`).

- [ ] **Step 3: Verify import with existing GGUF**
    - Use a small existing `.gguf` file and verify that `ollama list` shows the new model.

### Task 5: Full Pipeline Integration and Final Verification

**Files:**
- Modify: `model_manager.py` (Complete `ModelManagerCLI.run()`)

**Interfaces:**
- Orchestrates: `HFDownloader` $\rightarrow$ `ModelConverter` $\rightarrow$ `OllamaImporter`.

- [ ] **Step 1: Implement `--full` pipeline**
    - Link the methods so indices pass seamlessly from one class to another.

- [ ] **Step 2: End-to-end test with small model**
    - Run the full flow for a tiny compatible model to ensure plumbing is correct.

- [ ] **Step 3: Final polish and docstring addition**
    - Add clear docstrings to all classes and methods.
    - Ensure consistent logging format.
