# -*- coding: utf-8 -*-
"""
HTTP 服务器框架: 路由分发 + 请求解密 + 响应签名
==============================================
零第三方依赖, 基于 http.server。用法:
    python run.py

路由注册:
    from server import route
    @route(["POST"], "login")
    def handle_login(ctx): ...

ctx 字段:
    method    HTTP 方法
    path      URL 路径(不含域名与查询串)
    query     查询串 dict
    headers   请求头 dict(小写键)
    body      请求体明文 dict(自动解密 JSON)
    raw_body  请求体明文 str
    encrypted 请求体是否加密

handler 返回 build_response_body 同构 dict:
    {"status":0, "errcode":0, "errmsg":"", "data":...}
    返回 None 表示未处理 -> 404。
"""

import json
import logging
import threading
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from urllib.parse import urlparse, parse_qs

import config
import protocol
from state import StateStore

log = logging.getLogger("mock_server")

ROUTES = {}   # pattern -> (methods, handler)


def route(methods, pattern):
    """装饰器: 注册接口。pattern 不含 api/v5/ 前缀与首尾斜杠。"""
    def deco(fn):
        ROUTES[pattern] = (methods, fn)
        return fn
    return deco


def strip_prefix(path):
    p = path.strip("/")
    if p.startswith(config.API_PREFIX.strip("/")):
        p = p[len(config.API_PREFIX.strip("/")):]
    elif p.startswith("api/"):
        p = p[4:]
    return p.strip("/")


def match_route(path):
    """先精确匹配, 再最长前缀匹配(支持 xxx/123 这类带参数 URL)。"""
    key = strip_prefix(path)
    if key in ROUTES:
        return ROUTES[key], key, None
    parts = key.split("/")
    for i in range(len(parts) - 1, 0, -1):
        cand = "/".join(parts[:i])
        if cand in ROUTES:
            return ROUTES[cand], cand, key
    return None, key, None


def route_parts(key, matched):
    if not matched:
        return []
    prefix = matched.strip("/").split("/")
    parts = key.strip("/").split("/")
    return parts[len(prefix):]


class Handler(BaseHTTPRequestHandler):
    server_version = "FZJH-Mock/0.1"

    def _dispatch(self, method):
        parsed = urlparse(self.path)
        path = parsed.path
        query = {k: v[0] for k, v in parse_qs(parsed.query).items()}
        headers = {k.lower(): v for k, v in self.headers.items()}

        length = int(self.headers.get("Content-Length") or 0)
        body_bytes = self.rfile.read(length) if length else b""
        transfer_encoding = headers.get("transfer-encoding", "")
        content_type = headers.get("content-type", "")

        raw_body, encrypted = protocol.decode_request_body(body_bytes)
        body = protocol.parse_request_json(raw_body, content_type=content_type)

        entry, matched, full = match_route(path)
        if entry is None:
            self._respond_json(protocol.build_response_body(
                None, errcode=404, errmsg="no such api: %s" % path), path)
            return

        allowed, fn = entry
        if method not in allowed:
            self._respond_json(protocol.build_response_body(
                None, errcode=405, errmsg="method not allowed"), path)
            return

        ctx = {
            "method": method,
            "path": path,
            "query": query,
            "headers": headers,
            "body": body,
            "raw_body": raw_body,
            "encrypted": encrypted,
            "raw_bytes": body_bytes,
            "content_length": length,
            "state": self.server.state,
            "route": matched,
            "route_tail": route_parts(strip_prefix(path), matched),
        }

        if matched != "report_gain_log":
            preview_limit = 2000 if matched == "upload_acquisition_log" else 500
            body_preview = json.dumps(body, ensure_ascii=False)[:preview_limit]
            log.info("[%s] %s %s encrypted=%s userid=%s cl=%s te=%s ct=%s body=%s",
                     method, path, matched, encrypted,
                     headers.get("userid"), length, transfer_encoding, content_type, body_preview)
            if length and (not isinstance(body, dict) or not body):
                log.warning("empty parsed body path=%s cl=%s ct=%s raw=%r",
                            path, length, content_type, (raw_body or "")[:300])
        if "upload_user_file" in (matched or ""):
            magic = body_bytes[:16]
            log.info("upload_raw path=%s bytes=%s magic=%r head_hex=%s",
                     path, len(body_bytes), magic, body_bytes[:32].hex() if body_bytes else "")
        if encrypted and not raw_body:
            log.warning("decrypt failed: path=%s magic=%s len=%s",
                        path, (body_bytes[:12] if body_bytes else b""), length)
        if length == 0 and method == "POST" and "upload_user_file" in (matched or ""):
            log.warning("empty upload body headers=%s",
                        {k: headers.get(k) for k in (
                            "userid", "uuid", "content-type", "content-length",
                            "transfer-encoding", "sig", "time", "nouce", "ver", "hotver"
                        )})

        try:
            result = fn(ctx)
        except Exception as e:
            log.exception("handler error: %s", e)
            result = protocol.build_response_body(None, errcode=500,
                                                  errmsg="mock server error: %s" % e)

        if result is None:
            self._respond_json(protocol.build_response_body(
                None, errcode=404, errmsg="not handled"), path)
            return
        self._respond_json(result, path)

    def _respond_json(self, payload, path=None):
        url = self.path or ""
        if url.split("?", 1)[0].strip("/").startswith("api/v1/"):
            body = json.dumps(payload, ensure_ascii=False, separators=(",", ":"))
            self.send_response(200)
            self.send_header("Content-Type", "application/json; charset=utf-8")
            self.send_header("Content-Length", str(len(body.encode("utf-8"))))
            self.end_headers()
            self.wfile.write(body.encode("utf-8"))
            return
        skip_sign = protocol.is_skip_sign(url)
        key = (path or url).strip("/")
        group_name = config.RESPONSE_GROUP_BY_PATH.get(key, config.RESPONSE_GROUP)
        body, headers = protocol.make_response(
            payload, skip_sign=skip_sign, group_name=group_name)
        self.send_response(200)
        for k, v in headers.items():
            self.send_header(k, v)
        self.send_header("Content-Length", str(len(body.encode("utf-8"))))
        self.end_headers()
        self.wfile.write(body.encode("utf-8"))

    def do_GET(self):
        self._dispatch("GET")

    def do_POST(self):
        self._dispatch("POST")

    def log_message(self, fmt, *args):
        if urlparse(self.path).path.endswith("/report_gain_log"):
            return
        log.info("%s - %s", self.address_string(), fmt % args)


def create_server(host=None, port=None, state=None):
    host = host or config.HOST
    port = port or config.PORT
    srv = ThreadingHTTPServer((host, port), Handler)
    if state is None:
        state = StateStore(
            json_path=getattr(config, "STATE_JSON_PATH", None),
            autosave=getattr(config, "STATE_AUTOSAVE", True),
            archives_dir=getattr(config, "ARCHIVES_DIR", None),
        )
        if getattr(config, "SEED_IMPORT_ON_START", False):
            seed_path = getattr(config, "SEED_ROLEDATA_PATH", None)
            try:
                doc = state.import_seed_roledata(seed_path, overwrite=False)
                if doc:
                    log.info("seed archive ready: userid=%s name=%s path=%s",
                             doc.get("userid"), (doc.get("role") or {}).get("name"), seed_path)
            except Exception:
                log.exception("seed archive import failed: %s", seed_path)
    srv.state = state
    log.info("mock server listening on http://%s:%d", host, port)
    return srv


def serve_forever(host=None, port=None, state=None):
    srv = create_server(host, port, state)
    srv.serve_forever()
