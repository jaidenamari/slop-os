# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

## [Unreleased]

### Added

### Fixed

### Changed
- Phase 6: Skills and Meta — meta-agent, /new-agent, project skills (#29)
- Create vdd-workflow skill (SKILL.md + convergence reference) (#33)
- Create context/architecture.md for this project (#32)
- Create /new-agent command (#31)
- Create meta-agent.md (sonnet, agent builder with archetype library) (#30)
- Phase 5: Hooks and Polish — post-write-lint, /review, /scout commands (#25)
- Create /scout command (invoke scout, present findings) (#28)
- Create /review command (ad-hoc validator invocation) (#27)
- Create post-write-lint.sh hook (auto-lint after writes) (#26)
- Phase 4: The Sieve — Sarcasmotron setup, ROAST_ME generation (#21)
- Practice the Roast loop on a real critical task and refine (#24)
- Write Sarcasmotron setup guide (context/sarcasmotron-setup.md) (#23)
- Update /build to generate ROAST_ME.md for critical tasks after validator PASS (#22)
- Phase 3: Testing Integration — test-writer agent, critical-path TDD (#16)
- End-to-end test: critical task with red-phase tests -> builder greens -> validator confirms (#20)
- Create testing-strategy.md context file (#19)
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
