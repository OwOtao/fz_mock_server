# -*- coding: utf-8 -*-
"""
协议层: 请求解析 + 响应构造 + 签名
==================================
与 BaseHttp.lua 对齐:

请求(客户端 -> 服务端):
  body: hex(魔数 + AES-CBC(JSON)) 或明文 JSON
  头  : uuid/userid/sig/time/nouce/device/ver/hotver/platform/... (见 getHeaders)

响应(服务端 -> 客户端):
  body  : {"status":0,"errcode":0,"errmsg":"","data":...}
          整体可选加密(ENCRYPT_RESPONSE)
  头    : time/nonce/signature/vercode
  signature = md5( time & nonce & 响应体密文 & T_TOKEN )   # BaseHttp.lua L112-113
  其中 get_time/get_token/report_cheat/getWebConfig 不校验签名
"""

import hashlib
import json
import random
import string
import time

import config


def make_nonce(length=6):
    """与 BaseHttp:getNouceAndSig 相同字符集(去掉歧义字符 e)。"""
    chars = "".join(c for c in string.ascii_uppercase + string.ascii_lowercase
                    if c not in "eE")
    return "".join(random.choice(chars) for _ in range(length))


def sign_response(body_text, cur_time=None, nonce=None):
    """生成响应签名头。body_text 为实际下发的响应体原文(密文或明文)。"""
    cur_time = cur_time or str(int(time.time()))
    nonce = nonce or make_nonce()
    sig = hashlib.md5(
        "&".join([cur_time, nonce, body_text, config.T_TOKEN]).encode("utf-8")
    ).hexdigest()
    return cur_time, nonce, sig


def is_skip_sign(url):
    """URL 是否命中客户端签名白名单。"""
    return any(s in url for s in config.SKIP_SIGN_URLS)


def _normalize_cipher_candidate(text):
    """兼容密文被当成 form 时带尾部 '=' 的情况。"""
    if not isinstance(text, str):
        return ""
    candidate = text.strip()
    if not candidate:
        return ""
    # form-urlencoded 常见: <cipherhex>=
    if candidate.endswith("=") and "&" not in candidate and candidate.count("=") == 1:
        candidate = candidate[:-1].strip()
    return candidate


def _decrypt_text_to_plain(text):
    """尝试解密密文, 成功返回明文 str, 失败返回 None。"""
    candidate = _normalize_cipher_candidate(text)
    if not candidate or not jm_crypto.is_encrypted(candidate):
        return None
    candidates = [None] + list(config.KEY_GROUPS.keys())
    for group_name in candidates:
        try:
            return jm_crypto.decrypt(candidate, group_name).decode("utf-8")
        except Exception:
            continue
    return None


def decode_request_body(body_bytes):
    """解析请求体: 返回 (明文str, 是否加密)。按魔数自动识别密钥组。"""
    if not body_bytes:
        return "", False
    try:
        text = body_bytes.decode("utf-8")
    except UnicodeDecodeError:
        text = body_bytes.decode("latin-1")
    # 常规密文, 或密文被 Content-Type=form 且尾部带 '='
    plain = _decrypt_text_to_plain(text)
    if plain is not None:
        return plain, True
    if jm_crypto.is_encrypted(text):
        return "", True
    return text, False


def _looks_like_form(body_text, content_type=""):
    ct = (content_type or "").lower()
    text = (body_text or "").strip()
    if not text or text[:1] in "{[":
        return False
    # 整包密文即使 Content-Type 是 form, 也不当 form 解析
    if _decrypt_text_to_plain(text) is not None or jm_crypto.is_encrypted(_normalize_cipher_candidate(text)):
        return False
    if "application/x-www-form-urlencoded" in ct:
        return True
    return ("=" in text) and ("&" in text or text.count("=") == 1)


def _try_parse_form_value(value):
    """对单个 form 值尝试: 解密 -> JSON -> 原样字符串。"""
    if value is None:
        return ""
    if not isinstance(value, str):
        return value
    text = value.strip()
    if not text:
        return ""
    # 值本身是加密串
    plain = _decrypt_text_to_plain(text)
    if plain is not None:
        return _try_parse_form_value(plain)
    # 值是 JSON
    if text[:1] in "{[":
        try:
            return json.loads(text)
        except (ValueError, TypeError):
            pass
    return text


def parse_request_json(body_text, content_type=""):
    """把请求体转成 Python 对象(dict/list)。

    兼容:
      1) 明文/解密后 JSON
      2) application/x-www-form-urlencoded 键值
      3) form 值内嵌加密串或 JSON
      4) 整包密文被 Content-Type 标成 form, 甚至变成 cipher=
    """
    body_text = (body_text or "").strip()
    if not body_text:
        return {}
    # 0) 整包密文优先解密
    plain = _decrypt_text_to_plain(body_text)
    if plain is not None:
        body_text = plain.strip()
    # 1) JSON 优先
    try:
        return json.loads(body_text)
    except (ValueError, TypeError):
        pass
    # 2) form-urlencoded
    if _looks_like_form(body_text, content_type):
        from urllib.parse import parse_qs
        parsed = parse_qs(body_text, keep_blank_values=True)
        result = {}
        for key, values in parsed.items():
            # 兼容: 单字段 key 是密文, value 为空
            if (
                len(parsed) == 1
                and (not values or (len(values) == 1 and values[0] == ""))
            ):
                key_plain = _decrypt_text_to_plain(key)
                if key_plain is not None:
                    try:
                        return json.loads(key_plain)
                    except (ValueError, TypeError):
                        return _try_parse_form_value(key_plain)
            if not values:
                result[key] = ""
            elif len(values) == 1:
                result[key] = _try_parse_form_value(values[0])
            else:
                result[key] = [_try_parse_form_value(v) for v in values]
        # 单字段且值已是 dict/list 时展开, 兼容整包塞进一个字段
        if len(result) == 1:
            only_value = next(iter(result.values()))
            if isinstance(only_value, dict):
                merged = dict(only_value)
                only_key = next(iter(result.keys()))
                if only_key not in merged:
                    merged.setdefault("_form_key", only_key)
                return merged
            if isinstance(only_value, list):
                return {"data": only_value}
        return result
    return {}


def build_response_body(data, errcode=0, errmsg="", status=0):
    """构造响应 JSON 字典。data 会原样放入 data 字段。"""
    return {"status": status, "errcode": errcode, "errmsg": errmsg, "data": data}


def make_response(payload, encrypt=None, skip_sign=None, group_name=None):
    """组装 HTTP 响应。

    返回: (body_text, headers_dict)
      payload : dict, 如 build_response_body(...) 的返回值
      encrypt : 是否加密响应体, None 取 config.ENCRYPT_RESPONSE
      skip_sign: 是否跳过签名头, None 时由调用方保证
    """
    if encrypt is None:
        encrypt = config.ENCRYPT_RESPONSE
    raw = json.dumps(payload, ensure_ascii=False, separators=(",", ":"))
    body = jm_crypto.encrypt(raw, group_name) if encrypt else raw

    headers = {
        "Content-Type": "text/plain; charset=utf-8",
        "vercode": "0",
    }
    if not skip_sign:
        t, n, sig = sign_response(body)
        headers["time"] = t
        headers["nonce"] = n
        headers["signature"] = sig
    return body, headers


# 延迟 import, 避免循环(protocol 依赖 jm_crypto, config 不依赖 protocol)
import jm_crypto  # noqa: E402
