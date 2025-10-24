# Third-party Dependencies

This folder manages third-party dependencies for the Crates Pro project. We utilize `Cargo.toml` to list all required crates.io dependencies across all Crates Pro modules. [Reindeer](https://github.com/facebookincubator/reindeer) is then used to to analyze these dependencies and generate Buck2 build rules in the `./BUCK` file. This setup allows you to reference depndencies using the format `//third-party:<package name>` in your own build rules.

## Usage

### Step 1: Add new dependencies

To add a new crates.io dependency, open the `Cargo.toml` file in this directory, then add the new dependency as you would in a standard Rust project.

If you encounter a _major version_ conflict with an existing dependency, use the renaming technique. For example, if "clap==4.5" already exists but you need "clap==3.0":

```diff
- clap = "4.5"
+ clap = { package = "clap", version = "4.5" }
+ clap-3 = { package = "clap", version = "3.0" }
```

You can then reference "clap==3.0" as `//third-party:clap-3` in your build rules.

### Step 2: Regenerate Build Rules

After adding or modifying dependencies, regenerate the `./BUCK` file to make your changes available. Run the following command:

```bash
./run.sh
```

This script will analyze the dependencies in `Cargo.toml` and generate the corresponding Buck2 build rules in `./BUCK`.

## Resolving Build Issues

When Reindeer-generated rules fail to build, we apply the following process:

1. Write fixups and patches
2. Regenerate rules
3. Attempt to build again

### Fixups

We use two types of fixups to resolve build issues:

1. Fixup files: Located in `./fixups/<package name>/fixups.toml`, where `<package name>` is the crate name without version information.
2. Script-based fixups: Implemented directly in the `./run.sh` script.

**Fixup files** are TOML files that provide additional configuration for Reindeer when generating build rules. They work in conjunction with `Cargo.toml` to refine the build rule. For more details on how to write a fixup, refer to the [Reindeer Manual](https://github.com/facebookincubator/reindeer/blob/main/docs/MANUAL.md).

**Script-based fixups** are located in `./run.sh`. This script executes Reindeer to generate an initial `BUCK` file, then add additional modifications to the `BUCK` file.

Fixups may be version-specific, always update them to match the package versions in the `BUCK` file. Refer to the "Maintenance" section below for deatils.

### Patches

Patches are stored in the `vendor` directory. Currently, there's a patch for the `utoipa-swagger-ui` crate.

## Maintenance

After generating the `BUCK` file, verify that all fixups and patches are valid. Follow these two steps:

### Step 1: Verify `./run.sh`

Check that these package versions in `./BUCK` match:

```
mime_guess==2.0.x
```

If versions differ, update `./run.sh`.

### Step 2: Verify `./fixups/*/fixups.toml` for package versions

Check that these package versions in `./BUCK` match:

```
libssh2-sys==0.3.1
rdkafka-sys==4.9.0+2.10.0
ring==0.17.14
```

If versions differ, update the corresponding `./fixups/<package name>/fixups.toml`.

### Step 3: Verify `./fixups/*/fixups.toml` for system software versions

The following fixup files depend on system libraries in the remote execution container:

```
bzip2-sys==0.1.13+1.0.8
libgit2-sys==0.16.2+1.7.2
openssl-sys (version varies)
```

Verify system library versions match the fixup files:

```bash
docker run --rm -it localhost:30500/almalinux:9.6-cratespro-20251023 /bin/bash

# Inside container:
bzip2 --version          # Expected: 1.0.8
rpm -q libgit2-devel     # Expected: 1.7.2
openssl version          # Expected: 3.2.2
```

If versions don't match:

1. Update `Cargo.toml` dependencies to match system library versions
2. Update corresponding `./fixups/<package name>/fixups.toml` files
3. Do not modify system library versions in the container image

### Step 4: Update patches

We currently maintain a patch for the `utoipa-swagger-ui` crate in the `vendor` directory.:

Patch location: `vendor/utoipa-swagger-ui-9.0.1-patch1`

How the patch works:

1. The original `build.rs` script downloads resources at build time, which can be problematic.
2. To avoid this, we pre-download the resources in the remote builder Docker image.
3. We then modify `src/lib.rs` to use these pre-downloaded resources instead of relying on `build.rs`.

When updating `utoipa-swagger-ui`:

1. Update the patch accordingly.
2. Ensure that the remote builder image downloads the correct version of resources.
3. Verify that `src/lib.rs` correctly references the pre-downloaded resources.

### Step 5: Verify Component Compilation

Follow these steps to ensure all components compile correctly:

1. Open the 'crates-pro-infra' project in VS Code using the devcontainer
2. Generate the BUCK file for third-party dependencies, then return to the project root and run the build script:

```bash
cd third-party/
./run.sh && ../build.sh
```

The build script will stop if it encounters any errors. A successful build will display a "done" message at the end. Make sure you see this "done" message before accepting any changes.
