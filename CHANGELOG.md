# Changelog

## [Unreleased]

### Added

*none*

### Changed

*none*

### Deprecated

*none*

### Removed

*none*

### Fixed

*none*

## [2.0.0] - 2026-10-21

### Added

- Integration coverage for interactive guestfish, image extraction, and
  virt-customize writes verified through guestfish read-back.
- A virt-builder image creation smoke test using a local CirrOS template.

### Changed

- Upgrade the image to Ubuntu 26.04 LTS while retaining all five build platforms.
- Upgrade yasu to 1.20.1, logr to 0.6.3, and bats-wrapper to 0.2.0.
- Upgrade GitHub Actions and migrate workflow outputs to environment files.
- Use IANA timezone names such as `Europe/Berlin`.

### Removed

- RISC-V images, retired in the 2.0.0 beta; the remaining five platforms
  continue to be built.

### Fixed

- Preserve stdin when the guestfish helper downloads its container wrapper.
- Correct disk format arguments and restore all four skipped integration tests.
- Preserve local Docker Bake contexts and clean apt package metadata.
- Correct workflow permissions, artifact conditions, and the release asset name.

## [2.0.0-beta.0] - 2023-03-07

- upgrade to Ubuntu 23.04
- drop support for linux/riscv64

## [1.3.0] - 2021-12-06

### Fixed

- support `--batsw:` style arguments also if script is downloaded and executed directly

## [1.2.1] — 2021-10-10

### Changed

- Configuration is now applied on each start; not just on build time

## [1.2.0] - 2021-09-26

### Changed

- Simplified usage of container
- Automated testing of scripts

## [1.1.0] - 2021-09-21

### Added

- Support for working with non-root user
- Automated testing of container using GitHub actions

## [1.0.0] - 2021-09-06

### Added

- Docker image containing libguestfs command line tools

[unreleased]: https://github.com/bkahlert/libguestfs/compare/v2.0.0...HEAD

[2.0.0]: https://github.com/bkahlert/libguestfs/compare/v2.0.0-beta.0...v2.0.0

[2.0.0-beta.0]: https://github.com/bkahlert/libguestfs/compare/v1.3.0...v2.0.0-beta.0

[1.3.0]: https://github.com/bkahlert/libguestfs/compare/v1.2.1...v1.3.0

[1.2.1]: https://github.com/bkahlert/libguestfs/compare/v1.2.0...v1.2.1

[1.2.0]: https://github.com/bkahlert/libguestfs/compare/v1.1.0...v1.2.0

[1.1.0]: https://github.com/bkahlert/libguestfs/compare/v1.0.0...v1.1.0

[1.0.0]: https://github.com/bkahlert/libguestfs/releases/tag/v1.0.0
