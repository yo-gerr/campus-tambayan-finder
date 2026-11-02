# Shared Agent Instructions

These instructions are for any coding agent working in this repository, including GitHub Copilot and OpenCode.

## Before working

1. Read this file, `docs/PROJECT_BRIEF.md`, and `docs/ARCHITECTURE.md`.
2. Read the latest entry in `docs/AGENT_HANDOFF.md` for recent changes and outstanding work.
3. Check the current repository state before editing. Preserve existing work, follow decisions recorded in the project brief, and do not infer unconfirmed details.

## Project principles

- Treat Android as the agreed target platform and Filipino (Tagalog) and English as agreed language support; the framework, programming language, and service providers remain undecided. See `docs/PROJECT_BRIEF.md` for current decisions.
- Treat a public landing or product-information page as outside the current agreed class-demo scope; distinguish it from this contributor-facing README and only add one if the team later requests it.
- Keep shared product/domain concepts independent from platform-specific interface and infrastructure decisions.
- Prefer feature-oriented boundaries when application code is introduced; see `docs/ARCHITECTURE.md`.
- Do not add dependencies, application scaffolding, or speculative product features before they are needed or confirmed.
- Keep documentation factual. Label proposals and assumptions, and record significant decisions in the project brief or architecture notes.
- For each feature change, assess whether it affects personal or precise location data, mood data, nicknames or other identifiers, listing accuracy, user reports, or consumer-facing price/service claims. Apply the privacy, accuracy, and legal considerations in `docs/PROJECT_BRIEF.md`; minimize data, make permissions and limitations clear, and update relevant docs or tests when behavior changes.
- Treat references to Philippine laws in the project brief as issues the team must review, not as a complete legal analysis. Do not claim that the app, a feature, or its terms are legally compliant. For legal interpretation or final terms, flag the question for review by a qualified professional and use current authoritative sources when researching.
- Use `docs/REFERENCES.md` for curated external product or codebase references. Link to original sources, document why each is relevant and how ideas could be adapted, and verify license terms before proposing reuse. Do not copy external code, assets, or substantial text into this repository without confirming permissions and attribution requirements.
- Keep documentation aligned with meaningful changes in the same task. Update only the documents affected:
  - Update `docs/PROJECT_BRIEF.md` when confirmed requirements, scope, or product decisions change.
  - Update `docs/ARCHITECTURE.md` when module boundaries, dependencies, data flow, platform assumptions, or other architectural decisions change.
  - Update `README.md` when project status, setup instructions, available commands, or contributor navigation change.
  - Update feature-specific documentation when its documented behavior or implementation contract changes.
- Do not change architecture or other documentation merely because code changed. If no durable documented fact or guidance is affected, leave those documents alone.
- Make related documentation updates alongside the implementation, then check that the docs and code agree.
- Follow the repository's existing conventions and run relevant checks when available. Report checks that could not be run.

## Git and review workflow

When working in a Git repository, follow these conventions unless the owner or repository workflow says otherwise:

- Use Conventional Commit messages: `<type>(optional-scope): <imperative description>`, for example `docs(architecture): clarify feature boundaries`. Prefer the established types `feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`, `build`, `ci`, `chore`, and `revert`.
- Use descriptive branch prefixes such as `feature/`, `bugfix/`, `hotfix/`, `refactor/`, `docs/`, and `release/`. Do not switch branches or create commits unless the task or owner asks for it.
- Before proposing a pull request, run applicable build and test checks, review the diff for unrelated or commented-out code, and update relevant documentation.
- For UI changes, include screenshots when useful and verify relevant responsive layouts and accessibility. Check dark mode only if the product supports it. Do not require UI-specific checks for non-UI work.
- Follow readable, maintainable code: prefer clear names, focused functions, composition where appropriate, and comments that explain why rather than restating what the code does.
- Keep project documentation useful and accurate. Add or update overview, features, screenshots, tech stack, installation, structure, architecture, roadmap, or license information when applicable and confirmed; do not invent stack details or add empty sections just to satisfy a template.

## Product and design decisions

When the owner proposes an idea or feature but is unsure whether it fits the product, do not treat the suggestion as approval to build it. Help the owner decide first:

1. Clarify the user problem and how the idea fits the confirmed project goals. State important assumptions.
2. Present practical options, including keeping the current scope or deferring the idea when appropriate. For each, briefly describe a realistic usage scenario, advantages, and tradeoffs or caveats.
3. Give a clear recommendation and explain why it best fits the known goals and constraints. Distinguish evidence from assumptions.
4. Ask the owner to choose or explicitly approve a direction before implementing a new feature or making a consequential product, architecture, platform, or paid-service decision. If approval is not available, stop at analysis and record the open decision in the relevant project documentation or handoff.

Do not ask for extra approval for routine implementation details that are already determined by an approved requirement and do not materially change scope, user experience, cost, privacy, or architecture.

## Handoff at the end of a task

For each meaningful task, add a newest-first entry to `docs/AGENT_HANDOFF.md` containing:

- Date and a short task summary.
- Files or behavior changed.
- Validation performed and its result (or why it was not run).
- Remaining work, blockers, or decisions needed.

Keep the handoff concise and update it as part of the task. Do not claim that files are automatically synchronized: agents should maintain the handoff explicitly. Do not copy the full handoff into the README.
