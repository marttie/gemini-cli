# Contributing

Thanks for wanting to contribute to gemini-cli! This file provides a quick,
beginner-friendly guide to making changes and opening a pull request.

## Getting started

1. Fork the repository on GitHub.
2. Clone your fork locally:
   ```bash
   git clone https://github.com/<your-username>/gemini-cli.git
   ```
3. Create a branch for your work:
   ```bash
   git checkout -b your-branch-name
   ```
4. Make small, focused changes. Run checks locally (see below) before pushing.

## Local checks (recommended)

- Use Node 20 and a safe npm version (11.6.2) for this repo:
  ```bash
  nvm use 20
  corepack prepare npm@11.6.2 --activate
  ```
- Install dependencies and build:
  ```bash
  npm ci
  npm run build
  ```
- Run formatting and linting:
  ```bash
  npm run format
  npm run lint
  ```
- Run tests:
  ```bash
  npm run test
  ```

## Opening a pull request

1. Push your branch to your fork:
   ```bash
   git push -u origin your-branch-name
   ```
2. Open a pull request on GitHub from your branch to the upstream main branch.
3. Provide a clear title and a short description of what you changed and why.
4. Address review comments and push fixes to the same branch.

Thank you for contributing! If you need help, open an issue and ask —
maintainers and contributors will be happy to assist.
