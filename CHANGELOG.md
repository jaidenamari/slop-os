# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

## [Unreleased]

### Added

### Fixed

### Changed
- Update /build command to invoke test-writer for critical tasks only (#18)
- Create test-writer.md agent (sonnet, red-phase TDD for critical logic) (#17)
- Phase 2: Planning and Specs — spec-analyst, /spec, /plan commands (#10)
- End-to-end test: /spec -> /plan -> /build pipeline (#15)
- Create critical-paths.md context file (what must be tested and roasted) (#14)
- Create /plan command (decompose spec into chainlink issues with triage tags) (#13)
- Create /spec command (invoke spec-analyst, write spec.md) (#12)
- Create spec-analyst.md agent (opus, structured spec writer) (#11)
- Phase 1: Foundation — Core agents and build loop (#1)
- End-to-end test: create issue, /build, verify builder->validator chain (#9)
- E2E smoke test: create a hello-world script (#34)
- Create validate-scope.sh hook (block destructive commands) (#8)
- Create /status command (dashboard) (#7)
- Create /build command (the Forge pipeline) (#6)
- Create /prime command (session init, chainlink status, test health) (#5)
- Create validator.md agent (opus, adversarial mechanical reviewer) (#4)
- Create builder.md agent (sonnet, single-task implementer) (#3)
- Create scout.md agent (haiku, read-only codebase explorer) (#2)
