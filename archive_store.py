# -*- coding: utf-8 -*-
"""按 userid 分文件保存真实 RoleData 存档。

目录结构:
  archives/
    <userid>.json

文件格式:
  {
    "schema": "fzjh.role_archive.v1",
    "userid": 9048162373,
    "updated_at": 1710000000,
    "dataVer": 3,
    "role": { ...真实 RoleData... },
    "record": { ...PlayerRecord... },
    "upload": { "uType": "kaishi", "cheatType": "3" }
  }

说明:
  - role 字段保持真实 RoleData 结构, 便于下载覆盖/手工替换/切号回放
  - 新注册账号默认无存档文件(空号)
  - 后续注册体系可在 StateStore.accounts 扩展, 不把账号信息塞进 role
"""

from __future__ import annotations

import copy
import json
import logging
import os
import tempfile
import time


log = logging.getLogger("mock_server.archive")

SCHEMA = "fzjh.role_archive.v1"
META_KEYS = ("_recordInfo", "_uploadMeta", "dataVer")
_REPLACE_RETRY_DELAYS = (0.02, 0.04, 0.08, 0.16)


def _now():
    return int(time.time())


def _userid(value):
    try:
        userid = int(value)
    except (TypeError, ValueError):
        raise ValueError("invalid userid")
    if userid <= 0:
        raise ValueError("invalid userid")
    return userid


def _replace_with_retry(source, target):
    """Retry transient Windows sharing/access errors during atomic replace."""
    for attempt in range(len(_REPLACE_RETRY_DELAYS) + 1):
        try:
            os.replace(source, target)
            return
        except PermissionError:
            if attempt >= len(_REPLACE_RETRY_DELAYS):
                raise
            delay = _REPLACE_RETRY_DELAYS[attempt]
            log.warning(
                "archive replace temporarily blocked; retrying in %.3fs (%d/%d): %s",
                delay,
                attempt + 1,
                len(_REPLACE_RETRY_DELAYS),
                target,
            )
            time.sleep(delay)


def _atomic_write_json(path, payload):
    directory = os.path.dirname(os.path.abspath(path))
    os.makedirs(directory, exist_ok=True)
    fd, temp_path = tempfile.mkstemp(prefix=".archive-", suffix=".tmp", dir=directory)
    try:
        with os.fdopen(fd, "w", encoding="utf-8", newline="\n") as handle:
            json.dump(payload, handle, ensure_ascii=False, indent=2, sort_keys=True)
            handle.write("\n")
            handle.flush()
            os.fsync(handle.fileno())
        _replace_with_retry(temp_path, path)
    except Exception:
        try:
            os.unlink(temp_path)
        except OSError:
            pass
        raise


def _read_json(path):
    with open(path, "r", encoding="utf-8") as handle:
        return json.load(handle)


def normalize_role(role, userid=None):
    if not isinstance(role, dict):
        raise TypeError("role must be a dict")
    value = copy.deepcopy(role)
    # 清理服务端内部字段, 保持真实 RoleData 结构
    value.pop("_recordInfo", None)
    value.pop("_uploadMeta", None)
    if userid is not None:
        value["userid"] = _userid(userid)
    elif "userid" in value:
        try:
            value["userid"] = _userid(value.get("userid"))
        except ValueError:
            pass
    return value


def extract_data_ver(role, fallback=0):
    if not isinstance(role, dict):
        return int(fallback or 0)
    candidates = [
        role.get("dataVer"),
        (role.get("serverActionSystem") or {}).get("dataVersion") if isinstance(role.get("serverActionSystem"), dict) else None,
    ]
    values = []
    for item in candidates:
        try:
            if item is not None:
                values.append(int(item))
        except (TypeError, ValueError):
            pass
    if values:
        return max(values)
    try:
        return int(fallback or 0)
    except (TypeError, ValueError):
        return 0


def apply_data_ver(role, data_ver):
    role = normalize_role(role)
    data_ver = int(data_ver)
    role["dataVer"] = data_ver
    system = role.get("serverActionSystem")
    if not isinstance(system, dict):
        system = {}
    system = dict(system)
    system["dataVersion"] = data_ver
    system.setdefault("requestId", 1)
    role["serverActionSystem"] = system
    return role


def wrap_document(userid, role, record=None, upload=None, data_ver=None, updated_at=None):
    userid = _userid(userid)
    role = normalize_role(role, userid=userid)
    if data_ver is None:
        data_ver = extract_data_ver(role, 1)
    role = apply_data_ver(role, data_ver)
    if not role.get("primeryKey"):
        role["primeryKey"] = str(userid)
    doc = {
        "schema": SCHEMA,
        "userid": userid,
        "updated_at": int(updated_at or _now()),
        "dataVer": int(data_ver),
        "role": role,
        "record": copy.deepcopy(record) if isinstance(record, dict) else {},
        "upload": copy.deepcopy(upload) if isinstance(upload, dict) else {},
    }
    return doc


def coerce_document(raw, userid=None):
    """兼容:
    1) 新格式 {schema, role, record, ...}
    2) 直接 RoleData dict
    3) 旧 state.archives 内嵌带 _recordInfo 的 dict
    """
    if not isinstance(raw, dict):
        raise TypeError("archive must be a dict")
    if raw.get("schema") == SCHEMA and isinstance(raw.get("role"), dict):
        doc_userid = userid if userid is not None else raw.get("userid")
        return wrap_document(
            doc_userid,
            raw.get("role"),
            record=raw.get("record"),
            upload=raw.get("upload"),
            data_ver=raw.get("dataVer"),
            updated_at=raw.get("updated_at"),
        )
    role = dict(raw)
    record = role.pop("_recordInfo", None)
    upload = role.pop("_uploadMeta", None)
    data_ver = role.pop("dataVer", None)
    doc_userid = userid if userid is not None else role.get("userid")
    return wrap_document(doc_userid, role, record=record, upload=upload, data_ver=data_ver)


def document_to_role(doc):
    doc = coerce_document(doc)
    return copy.deepcopy(doc["role"])


def document_summary(doc):
    doc = coerce_document(doc)
    role = doc["role"]
    family = role.get("family") if isinstance(role.get("family"), dict) else {}
    return {
        "id": str(doc["userid"]),
        "userid": doc["userid"],
        "name": role.get("name") or ("存档%s" % doc["userid"]),
        "lv": role.get("lv"),
        "exp": role.get("exp"),
        "family": family.get("name"),
        "dataVer": doc.get("dataVer", 0),
        "primeryKey": role.get("primeryKey"),
        "updated_at": doc.get("updated_at"),
        "has_archive": True,
    }


class ArchiveStore:
    def __init__(self, root_dir):
        self.root_dir = os.fspath(root_dir)
        os.makedirs(self.root_dir, exist_ok=True)

    def path_for(self, userid):
        userid = _userid(userid)
        return os.path.join(self.root_dir, "%d.json" % userid)

    def exists(self, userid):
        return os.path.isfile(self.path_for(userid))

    def list_userids(self):
        values = []
        if not os.path.isdir(self.root_dir):
            return values
        for name in os.listdir(self.root_dir):
            if not name.endswith(".json"):
                continue
            stem = name[:-5]
            try:
                values.append(_userid(stem))
            except ValueError:
                continue
        values.sort()
        return values

    def load(self, userid):
        path = self.path_for(userid)
        try:
            raw = _read_json(path)
        except FileNotFoundError:
            return None
        except (OSError, ValueError, TypeError):
            log.warning("invalid archive file: %s", path)
            return None
        return coerce_document(raw, userid=userid)

    def save(self, userid, role, record=None, upload=None, data_ver=None):
        doc = wrap_document(userid, role, record=record, upload=upload, data_ver=data_ver)
        _atomic_write_json(self.path_for(userid), doc)
        return copy.deepcopy(doc)

    def delete(self, userid):
        path = self.path_for(userid)
        try:
            os.unlink(path)
            return True
        except FileNotFoundError:
            return False

    def import_role_file(self, src_path, userid=None, overwrite=True):
        raw = _read_json(src_path)
        if isinstance(raw, dict) and isinstance(raw.get("role"), dict) and raw.get("schema") == SCHEMA:
            doc = coerce_document(raw, userid=userid)
        else:
            doc = coerce_document(raw, userid=userid)
        path = self.path_for(doc["userid"])
        if os.path.exists(path) and not overwrite:
            return self.load(doc["userid"])
        _atomic_write_json(path, doc)
        return copy.deepcopy(doc)

    def migrate_from_mapping(self, archives_mapping):
        """把旧 state.json 内嵌 archives 拆成独立文件。"""
        if not isinstance(archives_mapping, dict):
            return 0
        count = 0
        for key, value in archives_mapping.items():
            try:
                userid = _userid(key if not isinstance(value, dict) else value.get("userid", key))
            except ValueError:
                continue
            if not isinstance(value, dict):
                continue
            if self.exists(userid):
                continue
            self.save(
                userid,
                value,
                record=value.get("_recordInfo"),
                upload=value.get("_uploadMeta"),
                data_ver=value.get("dataVer"),
            )
            count += 1
        return count
