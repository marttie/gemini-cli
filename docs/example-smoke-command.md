# Quick smoke test — run Gemini locally

This short example shows how to run a simple smoke test of the local gemini-cli
build.

## Prerequisites

- Node 20 (use nvm to switch)
- npm 11.6.2 (use corepack or npm install -g npm@11.6.2)
- gcloud auth or GOOGLE_APPLICATION_CREDENTIALS configured if you plan to call
  Gemini APIs

## Commands

1. Ensure Node and npm:

   ```bash
   nvm use 20
   corepack prepare npm@11.6.2 --activate
   ```

2. Install and build:

   ```bash
   npm ci
   npm run build
   ```

3. (Optional) Link to test the CLI globally:

   ```bash
   npm link
   which gemini  # On Windows use: where.exe gemini
   gemini --version
   ```

4. Run a quick smoke command:
   ```bash
   gemini "Hello, Gemini!"  # or use: node ./bundle/gemini.js "Hello, Gemini!"
   ```

## Notes

- If you are not authenticated to Google, the CLI will still show help and
  version but some commands that call APIs may fail until you configure
  credentials.
- For CI parity, run these commands in WSL/Ubuntu or in Linux where possible.
