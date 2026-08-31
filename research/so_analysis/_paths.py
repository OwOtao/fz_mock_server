"""Stable paths for the standalone native-analysis scripts."""

import os


HERE = os.path.dirname(os.path.abspath(__file__))
MOCK_SERVER_ROOT = os.path.abspath(os.path.join(HERE, "..", ".."))
SO_PATH = os.path.join(
    MOCK_SERVER_ROOT,
    "research",
    "binaries",
    "libcocos2dlua_arm64_bootstrap.so",
)
APK_PATH = os.path.join(MOCK_SERVER_ROOT, "tools", "frida", "fzjh_base.apk")
FRIDA_DIR = os.path.join(MOCK_SERVER_ROOT, "tools", "frida")
