# Setup Rust Action - User Guide

This composite action sets up a Rust build environment with caching, Protoc installation, and comprehensive diagnostics.

## Features

- **Parameterized Configuration**: Customize Protoc version, Rust toolchain, and caching behavior
- **Enhanced Diagnostics**: Optional detailed logging of system information and environment
- **Robust Error Handling**: Explicit failure modes with `continue-on-error: false`
- **Optimized Caching**: Platform and architecture-specific cache keys for better isolation
- **Multi-Platform Support**: Works on Ubuntu, macOS, and Windows runners
- **Output Variables**: Exports Rust/Cargo versions and cache status for downstream jobs

## Usage

### Basic Usage (with defaults)

```yaml
steps:
  - name: Setup Rust environment
    uses: ./.github/actions/setup-rust
```

### Advanced Usage with Custom Parameters

```yaml
steps:
  - name: Setup Rust environment
    id: rust-setup
    uses: ./.github/actions/setup-rust
    with:
      protoc-version: '25.1'           # Specific Protoc version
      rust-toolchain: 'nightly'        # Use nightly toolchain
      cache-enabled: 'true'            # Enable caching (default)
      enable-diagnostics: 'true'       # Enable diagnostics (default)

  - name: Use output variables
    run: |
      echo "Rust version: ${{ steps.rust-setup.outputs.rust-version }}"
      echo "Cargo version: ${{ steps.rust-setup.outputs.cargo-version }}"
      echo "Cache hit: ${{ steps.rust-setup.outputs.cache-hit }}"
```

## Inputs

| Input | Description | Required | Default |
|-------|-------------|----------|---------|
| `protoc-version` | Version of Protoc to install (e.g., "3.20.3", "latest") | No | `latest` |
| `cache-enabled` | Enable cargo caching | No | `true` |
| `rust-toolchain` | Rust toolchain to use (e.g., "stable", "nightly", "1.70.0") | No | `stable` |
| `enable-diagnostics` | Enable detailed diagnostic logging | No | `true` |

## Outputs

| Output | Description |
|--------|-------------|
| `rust-version` | Installed Rust version |
| `cargo-version` | Installed Cargo version |
| `cache-hit` | Whether cache was restored (`true`/`false`) |

## What Gets Cached

The action caches the following directories when `cache-enabled: 'true'`:
- `~/.cargo/bin/` - Cargo binaries
- `~/.cargo/registry/index/` - Registry index
- `~/.cargo/registry/cache/` - Downloaded crates
- `~/.cargo/git/db/` - Git dependencies
- `~/.cargo/.crates.toml` - Installed crates metadata
- `~/.cargo/.crates2.json` - Crates metadata v2
- `target/` - Build artifacts

Cache keys include:
- Operating system
- Architecture (x86_64, arm64, etc.)
- Rust toolchain version
- Hash of `Cargo.lock` files

## Diagnostics

When `enable-diagnostics: 'true'` (default), the action displays:
- OS and architecture information
- Relevant environment variables (RUST, CARGO, PATH)
- Available disk space
- Memory information
- Cache status (hit/miss)
- Final environment summary with all versions

## Error Handling

All critical steps use `continue-on-error: false` to ensure:
- Rust toolchain installation failures are caught
- Cache operation failures stop the workflow
- Protoc installation is verified
- Missing Protoc binary causes explicit failure

## Platform Support

The action supports all GitHub-hosted runners:
- **Linux**: Ubuntu 20.04, 22.04, latest
- **macOS**: macOS 11, 12, 13, latest
- **Windows**: Windows 2019, 2022, latest

Platform-specific diagnostics commands automatically adapt to the OS:
- Linux/macOS: Uses `free -h` for memory info
- macOS: Falls back to `vm_stat` if needed
- Windows: Uses appropriate commands or shows "not available"

## Examples

### Multi-Platform Build

```yaml
jobs:
  build:
    runs-on: ${{ matrix.os }}
    strategy:
      matrix:
        os: [ubuntu-22.04, macos-latest, windows-latest]
    steps:
      - uses: ./.github/actions/setup-rust
      - run: cargo build
```

### Testing Different Toolchains

```yaml
jobs:
  test:
    runs-on: ubuntu-22.04
    strategy:
      matrix:
        toolchain: [stable, nightly, 1.70.0]
    steps:
      - uses: ./.github/actions/setup-rust
        with:
          rust-toolchain: ${{ matrix.toolchain }}
      - run: cargo test
```

### Minimal Diagnostics for Speed

```yaml
steps:
  - uses: ./.github/actions/setup-rust
    with:
      enable-diagnostics: 'false'
  - run: cargo build --release
```

## Migration from Old Version

The enhanced action is backward compatible. If you're using the old version:

```yaml
# Old version - still works!
- uses: ./.github/actions/setup-rust
```

No changes needed! All new features use sensible defaults.

To opt into new features:

```yaml
# New version with explicit configuration
- uses: ./.github/actions/setup-rust
  with:
    protoc-version: '25.1'
    rust-toolchain: 'stable'
```

## Testing

See `.github/workflows/test-rust-setup.yml` for comprehensive test coverage including:
- Multi-platform validation
- Custom parameter testing
- Caching behavior verification
- Output variable validation
- Real project builds
