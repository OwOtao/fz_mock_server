# -*- coding: utf-8 -*-
"""解密 HAR 中的 checkUpdate 响应, 看正常返回内容 (default 组 JHHU02)"""
import sys

sys.path.insert(0, r"F:\AI\fzjh\fz_mock_server")
sys.stdout.reconfigure(encoding="utf-8")

import jm_crypto

# 8/24 HAR 响应 (364字节密文, hotver=0 时请求)
R_0824 = "4a484855303277bc688206e0caff53629799fed0575a2e058196b99264f8c678ca3bf2fe85e034eae458299d71a78a2cfb6eeafe159571ca4c0059659d8ffdfa67003863152cd0e68d8d7af076ccc300c02f581389cfce9a46c23f22e0aa20b34220bd0795eddb776d5a2c78e37603d58906c5083189be9e5df3a37b237185d3fb96617c5bd2510572f5a90ea4304a2580d7a851f163cfe1896477bdd9d12538c66a3cdec8dd4da70d3f82c2b17d66494c09627a1735"

# 8/26 HAR 响应 (76字节密文, hotver=14087 时请求)
R_0826 = "4a4848553032b6bc85b252aa03668b9a6640e38419ddcdd392d37d50e25c9254e185c17bff7e"

# 8/27 HAR 响应 (364字节密文)
R_0827 = "4a484855303277bc688206e0caff53629799fed0575a2e058196b99264f8c678ca3bf2fe85e034eae458299d71a78a2cfb6eeafe159571ca4c0059659d8ffdfa67003863152cb6dc7cbcedd53e9bc951a1e79b93adeee30a839e2824d432a35d943a20f83519039fbbce23a350849803632e2908ae6dda9d4f0eef53b19d06b0b0f5b6ef6eb681533714cfb01de381e14ec3947ab4c4e26410fbdf4f71b0c8f6a94d67c24b30e5b0b2fa77a2fc788bd4a72298220f92"

for name, cipher in (("8/24 (hotver=0)", R_0824), ("8/26 (hotver=14087)", R_0826), ("8/27 (hotver=14087)", R_0827)):
    print("=" * 70)
    print(name)
    for group in ("default", "FZJH02"):
        try:
            plain = jm_crypto.decrypt(cipher, group).decode("utf-8")
            print("  [%s组] 明文: %s" % (group, plain))
            break
        except Exception as e:
            print("  [%s组] 解密失败: %s" % (group, e))
