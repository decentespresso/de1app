# DE1 App Tests

Test suite using Tcl's built-in `tcltest` package.

## Running Tests

From the project root (`decent de1/`):

```
undroidwish-win64.exe run_tests.tcl
```

On Windows, undroidwish is a GUI-only interpreter and doesn't write to the console.
Results are written to `de1app/de1plus/tests/test_results.txt`.

After running:

```
type de1app\de1plus\tests\test_results.txt
```

Exit code is 0 on success, 1 if any test fails.

## Test Files

| File | Sources | Covers |
|------|---------|--------|
| `test_safe_write.tcl` | `safe_write.tcl`, `safe_load.tcl` | Atomic write_file (R1), .bak retention (R2), corruption recovery (R3), translation defensive loading (R3) |

## Architecture

Production code that needs testing lives in small, side-effect-free files:

- `safe_write.tcl` — `fast_write_open` and `write_file` procs
- `safe_load.tcl` — `load_settings_recover` proc

These are sourced by the main app files (`updater.tcl`, `utils.tcl`) and also sourced
directly by the test suite.

## Adding Tests

1. Create a new `.tcl` file in this directory.
2. `package require tcltest 2.5` and `namespace import ::tcltest::*`
3. Source the production file(s) you're testing (define mocks for their dependencies first).
4. Use `tcltest::test` for each test case.
5. Call `cleanupTests` at the end.
6. Add a `source` call in `run_tests.tcl` if you want the wrapper to run it.
