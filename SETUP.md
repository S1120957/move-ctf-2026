# Setup

You need three things: the **IOTA CLI**, **git** (the Move packages fetch the
framework over git), and — for challenges 3–5 — access to **devnet**.

## 1. Install the IOTA CLI

Use a recent release (Account Abstraction, used in Challenge 5, is a newer feature, older CLIs won't have it). Full instructions:
<https://docs.iota.org/developer/getting-started/install-iota>.

**macOS / Linux (Homebrew):**

```bash
brew install iotaledger/tap/iota
```

**Windows:**

> **Windows prerequisites at a glance.** You do **not** need Rust to *run* the CLI —
> just the **prebuilt `iota.exe`** (on your PATH) plus **git**. The Microsoft Visual
> C++ Redistributable is usually already installed and is only needed if `iota.exe`
> refuses to launch (a missing-DLL error). Rust + the Visual Studio C++ Build Tools
> are required **only** if you build the CLI from source with `cargo`. For
> Challenge 5 you'll additionally want **`jq`**, **`python3`**, and a Unix shell
> (**Git Bash**, bundled with Git for Windows, or **WSL**) — the CLI itself needs
> none of these.

- **Prebuilt binary (recommended):** download the latest Windows archive from
  <https://github.com/iotaledger/iota/releases>, unzip it, and add the folder that
  contains `iota.exe` to your `Path` (e.g. move it to `C:\Program Files\iota\` and
  add that directory to the system `Path` environment variable). Open a new
  terminal afterwards.
- **From source:** install [Rust](https://rustup.rs) and the *Visual Studio C++
  Build Tools*, then run the cargo command below in PowerShell.

**Windows: add `iota` to your PATH**

If you used the prebuilt binary, Windows needs to know where `iota.exe` lives so you
can run `iota` from any terminal. Assuming you put it in `C:\Program Files\iota\`:

- **GUI:** press Start, search *"Edit the system environment variables"* →
  **Environment Variables…** → under *User variables* select **Path** → **Edit** →
  **New** → enter `C:\Program Files\iota` → **OK** every dialog. Open a *new* terminal.

- **PowerShell (current user, permanent):**

  ```powershell
  [Environment]::SetEnvironmentVariable("Path", $env:Path + ";C:\Program Files\iota", "User")
  ```

  Then close and reopen the terminal so the change is picked up.

- **Confirm it worked:**

  ```powershell
  where.exe iota      # should print C:\Program Files\iota\iota.exe
  ```

  (Installing from source with cargo instead puts `iota` in `%USERPROFILE%\.cargo\bin`,
  which `rustup` already adds to your PATH.)

**Verify (PowerShell, cmd, or a Unix shell):**

```bash
iota --version          # expect a recent 1.x version
git --version           # needed to resolve the framework dependency
```

For Challenge 5 you'll also want `jq` and `python3` (the helper commands use them to
massage keys and bytes).

> **Windows shell note:** the helper scripts (`scripts/*.sh`) and the multi-step
> command snippets in the challenge READMEs are written for a Unix shell and use
> tools like `jq`, `python3`, `od`, `base64`, and `cut`. On Windows, run them in
> **Git Bash** (ships with [Git for Windows](https://git-scm.com/download/win)) or
> **WSL**, where those tools are available. Plain `iota` commands work in PowerShell
> or cmd too.

**Installing these on Windows:**

- **git** — [git-scm.com/download/win](https://git-scm.com/download/win) (also
  provides Git Bash and `od`/`base64`/`cut`). Or: `winget install Git.Git`.
- **jq** — [jqlang.github.io/jq/download](https://jqlang.github.io/jq/download/). Or:
  `winget install jqlang.jq` (Chocolatey: `choco install jq`).
- **python3** — [python.org/downloads/windows](https://www.python.org/downloads/windows/);
  tick **"Add python.exe to PATH"** in the installer. Or:
  `winget install Python.Python.3.12`.


### 1.1. Optional: VS Code editor support

If you use **VS Code** (or a VS Code–based editor like Cursor), install the official
**IOTA Move** extension for a much nicer Move experience — syntax highlighting, code
completion, inline compiler diagnostics, go-to-definition, type-on-hover, inlay hints,
and trace-debugging of Move unit tests.

- **Marketplace:**
  <https://marketplace.visualstudio.com/items?itemName=iotaledger.iota-move>
- **From inside VS Code:** open the Extensions view (`Ctrl+Shift+X` / `Cmd+Shift+X`),
  search **"IOTA Move"** (publisher *iotaledger*), and click **Install**.
- **From the command line:**

  ```bash
  code --install-extension iotaledger.iota-move
  ```

It installs its own `move-analyzer` language server automatically (into `~/.iota/bin`,
or `C:\Users\<you>\.iota\bin` on Windows). It uses the **IOTA CLI** from step 1 for
building and testing, so make sure `iota` is on your PATH — if it isn't, point the
extension at it via the `move.iota.path` setting.

## 2. Create a key / address

```bash
iota client                       # first run walks you through creating a key
iota client active-address        # your address
iota keytool list                 # your keys
```

The default Ed25519 key is perfect for this workshop.

## 3. Connect to devnet

```bash
iota client new-env --alias devnet --rpc https://api.devnet.iota.cafe
iota client switch --env devnet
iota client faucet                # request test tokens
iota client gas                   # confirm you received coins
```

## 4. The framework dependency (and how to pin it)

Every `Move.toml` in this kit depends on the framework like this:

```toml
[dependencies]
Iota = { git = "https://github.com/iotaledger/iota.git", subdir = "crates/iota-framework/packages/iota-framework", rev = "framework/devnet" }
```

- `rev = "framework/devnet"` tracks the framework currently deployed on devnet.
- The first `iota move build` clones the IOTA repo into `~/.move` (a few hundred MB,
  one time). Subsequent builds are fast.
- **For a reproducible pin** (recommended if you cut the kit for a specific event),
  replace the branch with a full 40-character commit hash, e.g.
  `rev = "<full-commit-sha>"`, and commit the resulting `Move.lock`.
- If you target **testnet** or **mainnet**, switch the branch to `framework/testnet`
  or `framework/mainnet` so the source matches the deployed framework.

## 5. Smoke test

```bash
cd challenges/01-checkpoint
iota move build      # resolves the framework, compiles (warnings are fine here)
iota move test       # fails until you implement get_flag — that's expected
```

If `iota move build` succeeds, your environment is ready. Head to
[`challenges/01-checkpoint`](challenges/01-checkpoint/).
