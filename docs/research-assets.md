# Research assets

The mock server's supporting material is kept inside this repository so paths
remain stable while runtime code stays separate from large local artifacts.

## Layout

- `tools/decrypt.py`: decrypt a JM ciphertext file or hex string.
- `tools/decrypt_fzjh_lua.py`: decrypt Lua files from the APK.
- `tools/frida/`: Frida hooks, runners, APK, patched SO, and captures.
- `research/crypto_tests/`: protocol-key and cipher experiments.
- `research/so_analysis/`: native symbol and disassembly scripts.
- `research/binaries/`: native binaries used by the analysis scripts.
- `research/samples/`: captured ciphertext and extracted reference data.
- `research/updatePath_android_2.1.02/`: captured update-package snapshot.
- `research/legacy/`: recoverable bundles for superseded repositories.
- `docs/encryption-keys.md`: known JM key groups and their provenance.
- `docs/native-crypto-analysis.md`: native crypto analysis notes.

Large APK, SO, HAR, update-package, local-save, and Git bundle artifacts are
kept on disk but ignored by Git. The active Lua reference tree remains in
`fzjh_lua/`, and active packet captures/native libraries remain in `so/`.

## Common commands

```bash
python tools/decrypt.py research/samples/test.md
python tools/decrypt_fzjh_lua.py --single encrypted.lua -o decrypted.lua
python -m unittest test_state test_update_proxy
```
