# -*- coding: utf-8 -*-
import json
import sys
import urllib.request
from pathlib import Path

ROOT = Path(__file__).resolve().parent
sys.path.insert(0, str(ROOT))
import config  # noqa: E402
import jm_crypto  # noqa: E402


def decrypt_response(text):
    if jm_crypto.is_encrypted(text):
        return jm_crypto.decrypt(text, "FZJH03").decode("utf-8")
    return text


def request(method, path, payload=None, headers=None, encrypt=True):
    url = "http://127.0.0.1:8080/%s%s" % (config.API_PREFIX, path)
    data = None
    if payload is not None:
        raw = json.dumps(payload, ensure_ascii=False, separators=(",", ":"))
        body = jm_crypto.encrypt(raw, "FZJH03") if encrypt else raw
        data = body.encode("utf-8")
    req = urllib.request.Request(url, data=data, method=method)
    req.add_header("Content-Type", "text/plain")
    for key, value in (headers or {}).items():
        req.add_header(key, str(value))
    with urllib.request.urlopen(req, timeout=15) as resp:
        text = resp.read().decode("utf-8")
        return json.loads(decrypt_response(text))


def main():
    seed = json.loads((ROOT.parent / "frida" / "local_save" / "RoleData.json").read_text(encoding="utf-8"))
    userid = int(seed["userid"])

    listed = request("GET", "get_archive_list", headers={"userid": userid, "uuid": "verify-1"})
    print("list_errcode", listed.get("errcode"), "count", len(listed.get("data") or []))
    print("list_names", [item.get("name") for item in (listed.get("data") or [])])

    switched = request("GET", "switch_archive/%d" % userid, headers={"userid": userid, "uuid": "verify-1"})
    print("switch", switched)

    downloaded = request("GET", "download_user_file_2", headers={"userid": userid, "uuid": "verify-1"})
    print("download_errcode", downloaded.get("errcode"))
    role = (downloaded.get("data") or [None])[0]
    print("download_role", None if not isinstance(role, dict) else {
        "userid": role.get("userid"),
        "name": role.get("name"),
        "lv": role.get("lv"),
        "dataVer": role.get("dataVer"),
        "primeryKey": role.get("primeryKey"),
        "keys": len(role),
        "has_items": isinstance(role.get("items"), list),
        "has_skills": isinstance(role.get("skills"), dict),
    })

    uploaded = request(
        "POST",
        "upload_user_file_3/kaishi/3",
        payload=[seed, {"jingMaxRecord": {"value": 1, "part": "body"}}],
        headers={"userid": userid, "uuid": "verify-1"},
    )
    print("upload", uploaded)

    archived = json.loads((ROOT / "archives" / ("%d.json" % userid)).read_text(encoding="utf-8"))
    print("disk_schema", archived.get("schema"), "disk_name", archived.get("role", {}).get("name"), "disk_dataVer", archived.get("dataVer"))


if __name__ == "__main__":
    main()
