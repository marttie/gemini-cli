/**
 * @license
 * Copyright 2025 Google LLC
 * SPDX-License-Identifier: Apache-2.0
 */

import { describe, it, expect } from 'vitest';
import { execSync } from 'node:child_process';

describe('lint.js', () => {
  describe('platform support', () => {
    it('should skip actionlint on unsupported platform (win32/x64)', () => {
      const result = execSync(
        `node -e "
          Object.defineProperty(process, 'platform', { value: 'win32' });
          Object.defineProperty(process, 'arch', { value: 'x64' });
          process.argv = ['node', 'lint.js', '--actionlint'];
          await import('./scripts/lint.js');
        "`,
        { cwd: process.cwd(), encoding: 'utf-8' },
      );
      expect(result).toContain('Skipping actionlint (unsupported platform)');
    });

    it('should skip shellcheck on unsupported platform (win32/x64)', () => {
      const result = execSync(
        `node -e "
          Object.defineProperty(process, 'platform', { value: 'win32' });
          Object.defineProperty(process, 'arch', { value: 'x64' });
          process.argv = ['node', 'lint.js', '--shellcheck'];
          await import('./scripts/lint.js');
        "`,
        { cwd: process.cwd(), encoding: 'utf-8' },
      );
      expect(result).toContain('Skipping shellcheck (unsupported platform)');
    });

    it('should warn about unsupported platform during setup', () => {
      try {
        execSync(
          `node -e "
            Object.defineProperty(process, 'platform', { value: 'win32' });
            Object.defineProperty(process, 'arch', { value: 'x64' });
            process.argv = ['node', 'lint.js', '--setup'];
            await import('./scripts/lint.js');
          "`,
          { cwd: process.cwd(), encoding: 'utf-8', stdio: 'pipe' },
        );
      } catch (error) {
        // Setup may fail due to missing python/yamllint on Windows, but should warn
        expect(error.stderr || error.stdout).toContain(
          'Warning: Platform win32/x64 is not supported for actionlint and shellcheck',
        );
      }
    });

    it('should run actionlint on supported platform (linux/x64)', () => {
      const result = execSync(
        `node -e "
          Object.defineProperty(process, 'platform', { value: 'linux' });
          Object.defineProperty(process, 'arch', { value: 'x64' });
          process.argv = ['node', 'lint.js', '--actionlint'];
          await import('./scripts/lint.js');
        "`,
        { cwd: process.cwd(), encoding: 'utf-8' },
      );
      expect(result).toContain('Running actionlint');
      expect(result).not.toContain('Skipping');
    });

    it('should run shellcheck on supported platform (linux/x64)', () => {
      const result = execSync(
        `node -e "
          Object.defineProperty(process, 'platform', { value: 'linux' });
          Object.defineProperty(process, 'arch', { value: 'x64' });
          process.argv = ['node', 'lint.js', '--shellcheck'];
          await import('./scripts/lint.js');
        "`,
        { cwd: process.cwd(), encoding: 'utf-8' },
      );
      expect(result).toContain('Running shellcheck');
      expect(result).not.toContain('Skipping');
    });
  });
});
