# -*- coding: utf-8 -*-

import copy
import json
import logging
import os
import tempfile
import threading
import time

from archive_store import ArchiveStore, coerce_document, document_summary, extract_data_ver


log = logging.getLogger("mock_server.state")


class StateStore:
    VERSION = 3
    DEFAULT_USER_ID = 1000000001

    def __init__(self, json_path=None, initial=None, autosave=True, archives_dir=None):
        self.json_path = os.fspath(json_path) if json_path else None
        self.autosave = bool(autosave)
        if archives_dir:
            self.archives_dir = os.fspath(archives_dir)
        elif self.json_path:
            self.archives_dir = os.path.join(os.path.dirname(os.path.abspath(self.json_path)), "archives")
        else:
            self.archives_dir = None
        self.archive_store = ArchiveStore(self.archives_dir) if self.archives_dir else None
        self._lock = threading.RLock()
        self._state = self._empty_state()
        if initial is not None:
            self._state = self._normalize_state(initial)
        elif self.json_path:
            self.load()
        self._migrate_embedded_archives()

    def _empty_state(self):
        return {
            "version": self.VERSION,
            "next_ids": {
                "userid": self.DEFAULT_USER_ID,
                "order_id": 1,
                "mail_id": 1,
                "fight_id": 1,
            },
            # accounts 预留注册扩展字段: username/password_hash/device_uuid/status...
            "accounts": {},
            "email_users": {},
            # archives 仅作兼容缓存; 真实 RoleData 落在 archives/<userid>.json
            "archives": {},
            "devices": {},
            "orders": {},
            "mail": {},
            "mail_deliveries": {},
            "inventory_items": {},
            "activities": {},
            "activity_users": {},
            "rankings": {},
            "biwu": {},
            "biwu_fights": {},
            "active_archive": {},
            "practice": {},
            "prestige": {},
            "daily_tasks": {},
            "hang_up": {},
            "fist": {},
            "teacher_build": {},
            "devote": {},
            "black_market": {},
            "homeland": {},
        }

    def _normalize_homeland(self, state):
        root = state.setdefault("homeland", {})
        if not isinstance(root, dict):
            root = {}
            state["homeland"] = root
        for key in ("users", "mid_owners", "dp_owners"):
            if not isinstance(root.get(key), dict):
                root[key] = {}
        try:
            root["next_mid"] = max(int(root.get("next_mid", 14751)), 1)
        except (TypeError, ValueError):
            root["next_mid"] = 14751
        return root

    def _normalize_state(self, value):
        state = self._empty_state()
        if isinstance(value, dict):
            for key in state:
                if key in value:
                    state[key] = copy.deepcopy(value[key])
        if not isinstance(state.get("next_ids"), dict):
            state["next_ids"] = self._empty_state()["next_ids"]
        for key, default in self._empty_state()["next_ids"].items():
            try:
                state["next_ids"][key] = int(state["next_ids"].get(key, default))
            except (TypeError, ValueError):
                state["next_ids"][key] = default
        for key in (
            "accounts",
            "email_users",
            "archives",
            "devices",
            "orders",
            "mail",
            "mail_deliveries",
            "inventory_items",
            "activities",
            "activity_users",
            "rankings",
            "biwu",
            "biwu_fights",
            "active_archive",
            "practice",
            "prestige",
            "daily_tasks",
            "hang_up",
            "fist",
            "teacher_build",
            "devote",
            "black_market",
            "homeland",
        ):
            if not isinstance(state.get(key), dict):
                state[key] = {}
        state["version"] = self.VERSION
        self._normalize_homeland(state)
        self._migrate_email_users(state)
        self._repair_counters(state)
        return state

    def _normalize_email(self, email):
        return str(email or "").strip().casefold()

    def _migrate_email_users(self, state):
        email_users = state["email_users"]
        for key, value in list(email_users.items()):
            email = self._normalize_email(key)
            try:
                userid = self._userid(value)
            except ValueError:
                email_users.pop(key, None)
                continue
            if email != key:
                email_users.pop(key, None)
            if email:
                email_users.setdefault(email, userid)
        for key, account in state["accounts"].items():
            if not isinstance(account, dict):
                continue
            email = self._normalize_email(account.get("email"))
            if email:
                account["email"] = email
                try:
                    email_users.setdefault(email, self._userid(account.get("userid", key)))
                except ValueError:
                    pass
            else:
                account["email"] = ""
        for key, device in state["devices"].items():
            if not isinstance(device, dict):
                continue
            email = self._normalize_email(device.get("email"))
            if not email:
                continue
            try:
                userid = self._userid(device.get("userid", key))
            except ValueError:
                continue
            device["email"] = email
            if device.get("bound") or device.get("is_logout"):
                email_users.setdefault(email, userid)
                account = state["accounts"].get(self._key(userid))
                if isinstance(account, dict):
                    account["email"] = email

    def _migrate_embedded_archives(self):
        if not self.archive_store:
            return
        with self._lock:
            embedded = self._state.get("archives") or {}
            if not embedded:
                return
            migrated = self.archive_store.migrate_from_mapping(embedded)
            if migrated:
                # 真实档已落到 archives/*.json, 清空内嵌大对象避免 state.json 膨胀
                self._state["archives"] = {}
                self._changed()
                log.info("migrated %s embedded archives to %s", migrated, self.archives_dir)

    def import_seed_roledata(self, path, overwrite=False):
        """导入真实 RoleData 种子档; 新注册仍保持空号, 不自动克隆。"""
        if not self.archive_store:
            raise RuntimeError("archives_dir is not configured")
        if not path or not os.path.isfile(path):
            return None
        doc = self.archive_store.import_role_file(path, overwrite=overwrite)
        userid = doc["userid"]
        with self._lock:
            account = self._state["accounts"].setdefault(self._key(userid), {
                "userid": userid,
                "created_at": self._now(),
                "updated_at": self._now(),
                "status": "active",
                "source": "seed",
            })
            account["userid"] = userid
            account["has_archive"] = True
            account["name"] = doc["role"].get("name")
            account["updated_at"] = self._now()
            self._state["next_ids"]["userid"] = max(
                int(self._state["next_ids"].get("userid", self.DEFAULT_USER_ID)),
                userid + 1,
            )
            self._changed()
        return copy.deepcopy(doc)

    def _repair_counters(self, state):
        next_ids = state["next_ids"]
        user_ids = []
        for key in state["accounts"]:
            try:
                user_ids.append(int(key))
            except (TypeError, ValueError):
                continue
        if user_ids:
            next_ids["userid"] = max(next_ids["userid"], max(user_ids) + 1)
        for key, collection in (
            ("order_id", state["orders"]),
            ("fight_id", state["biwu_fights"]),
        ):
            numbers = []
            for value in collection.values():
                if not isinstance(value, dict):
                    continue
                for field in ("order_id", "fight_id"):
                    candidate = value.get(field)
                    if isinstance(candidate, str) and candidate.startswith("mock-"):
                        candidate = candidate[5:]
                    try:
                        numbers.append(int(candidate))
                    except (TypeError, ValueError):
                        pass
            if numbers:
                next_ids[key] = max(next_ids[key], max(numbers) + 1)
        mail_numbers = []
        for messages in state["mail"].values():
            if not isinstance(messages, list):
                continue
            for message in messages:
                if isinstance(message, dict):
                    try:
                        mail_numbers.append(int(message.get("mail_id")))
                    except (TypeError, ValueError):
                        pass
        if mail_numbers:
            next_ids["mail_id"] = max(next_ids["mail_id"], max(mail_numbers) + 1)

    def _userid(self, userid):
        try:
            value = int(userid)
        except (TypeError, ValueError):
            raise ValueError("invalid userid")
        if value <= 0:
            raise ValueError("invalid userid")
        return value

    def _key(self, value):
        return str(value)

    def _now(self):
        return int(time.time())

    def _save_locked(self):
        if not self.json_path:
            return
        directory = os.path.dirname(os.path.abspath(self.json_path))
        os.makedirs(directory, exist_ok=True)
        fd, temp_path = tempfile.mkstemp(prefix=".state-", suffix=".tmp", dir=directory)
        try:
            with os.fdopen(fd, "w", encoding="utf-8", newline="\n") as handle:
                json.dump(self._state, handle, ensure_ascii=False, indent=2, sort_keys=True)
                handle.write("\n")
                handle.flush()
                os.fsync(handle.fileno())
            os.replace(temp_path, self.json_path)
        except Exception:
            try:
                os.unlink(temp_path)
            except OSError:
                pass
            log.exception("failed to save state: %s", self.json_path)
            raise

    def _changed(self):
        if self.autosave:
            self._save_locked()

    def load(self):
        if not self.json_path:
            return
        with self._lock:
            try:
                with open(self.json_path, "r", encoding="utf-8") as handle:
                    value = json.load(handle)
            except FileNotFoundError:
                return
            except (OSError, ValueError, TypeError):
                log.warning("invalid state file, using empty state: %s", self.json_path)
                self._state = self._empty_state()
                return
            self._state = self._normalize_state(value)

    def save(self):
        with self._lock:
            self._save_locked()

    def reset(self, preserve_seed=False):
        with self._lock:
            seed = None
            if preserve_seed:
                seed = copy.deepcopy(self._state.get("next_ids"))
            self._state = self._empty_state()
            if seed:
                self._state["next_ids"].update(seed)
            self._changed()

    def snapshot(self):
        with self._lock:
            return copy.deepcopy(self._state)

    def mutate(self, callback):
        with self._lock:
            result = callback(self._state)
            self._changed()
            return copy.deepcopy(result)

    def _next(self, name, prefix=None):
        value = self._state["next_ids"][name]
        self._state["next_ids"][name] = value + 1
        if prefix:
            return "%s-%d" % (prefix, value)
        return value

    def ensure_account(self, userid=None, defaults=None):
        with self._lock:
            if userid is None or int(userid) <= 0:
                userid = self._next("userid")
            userid = self._userid(userid)
            key = self._key(userid)
            account = self._state["accounts"].setdefault(key, {
                "userid": userid,
                "created_at": self._now(),
                "updated_at": self._now(),
                # 注册体系预留
                "username": None,
                "password_hash": None,
                "device_uuid": None,
                "email": "",
                "status": "active",
                "source": "auto",
                "has_archive": False,
            })
            if defaults:
                account.update(copy.deepcopy(defaults))
            account["email"] = self._normalize_email(account.get("email"))
            account["userid"] = userid
            if self.archive_store:
                account["has_archive"] = self.archive_store.exists(userid)
            account["updated_at"] = self._now()
            self._changed()
            return copy.deepcopy(account)

    def register_account(self, username=None, password_hash=None, device_uuid=None, userid=None, email=None):
        normalized_email = self._normalize_email(email)
        with self._lock:
            owner = self._state["email_users"].get(normalized_email) if normalized_email else None
            if owner is not None and (userid is None or int(owner) != int(userid)):
                raise ValueError("email already bound")
            defaults = {
                "username": username,
                "password_hash": password_hash,
                "device_uuid": device_uuid,
                "email": normalized_email,
                "status": "active",
                "source": "register",
                "has_archive": False,
            }
            account = self.ensure_account(userid=userid, defaults=defaults)
            if normalized_email:
                self._state["email_users"][normalized_email] = account["userid"]
                self._changed()
            return copy.deepcopy(account)

    def get_account(self, userid):
        userid = self._userid(userid)
        with self._lock:
            value = self._state["accounts"].get(self._key(userid))
            return copy.deepcopy(value) if value is not None else None

    def update_account(self, userid, patch):
        if not isinstance(patch, dict):
            raise TypeError("patch must be a dict")
        account = self.ensure_account(userid)
        account.update(copy.deepcopy(patch))
        account["userid"] = self._userid(userid)
        with self._lock:
            self._state["accounts"][self._key(userid)] = account
            self._changed()
            return copy.deepcopy(account)

    def get_archive(self, userid):
        """返回可直接给客户端回放的 RoleData(纯 role 表)。"""
        userid = self._userid(userid)
        with self._lock:
            if self.archive_store:
                doc = self.archive_store.load(userid)
                if doc is not None:
                    return copy.deepcopy(doc["role"])
            value = self._state["archives"].get(self._key(userid))
            if value is None:
                return None
            return coerce_document(value, userid=userid)["role"]

    def get_archive_document(self, userid):
        userid = self._userid(userid)
        with self._lock:
            if self.archive_store:
                doc = self.archive_store.load(userid)
                if doc is not None:
                    return copy.deepcopy(doc)
            value = self._state["archives"].get(self._key(userid))
            if value is None:
                return None
            return coerce_document(value, userid=userid)

    def put_archive(self, userid, archive, record=None, upload=None, data_ver=None):
        userid = self._userid(userid)
        if not isinstance(archive, dict):
            raise TypeError("archive must be a dict")
        with self._lock:
            self.ensure_account(userid)
            if data_ver is None:
                old = None
                if self.archive_store:
                    old = self.archive_store.load(userid)
                if old is None:
                    old_role = self._state["archives"].get(self._key(userid))
                    old = coerce_document(old_role, userid=userid) if isinstance(old_role, dict) else None
                current = extract_data_ver((old or {}).get("role") if old else None, 0)
                incoming = extract_data_ver(archive, 0)
                data_ver = max(current, incoming) + 1
            if self.archive_store:
                if record is None and isinstance(archive, dict):
                    record = archive.get("_recordInfo")
                if upload is None and isinstance(archive, dict):
                    upload = archive.get("_uploadMeta")
                doc = self.archive_store.save(
                    userid,
                    archive,
                    record=record,
                    upload=upload,
                    data_ver=data_ver,
                )
                # 内嵌 archives 不再存大对象
                self._state["archives"].pop(self._key(userid), None)
                account = self._state["accounts"].get(self._key(userid), {})
                account["has_archive"] = True
                account["name"] = doc["role"].get("name")
                account["updated_at"] = self._now()
                self._state["accounts"][self._key(userid)] = account
                self._changed()
                return copy.deepcopy(doc["role"])
            value = coerce_document(archive, userid=userid)
            if record:
                value["record"] = copy.deepcopy(record)
            if upload:
                value["upload"] = copy.deepcopy(upload)
            value = coerce_document(value, userid=userid)
            value["dataVer"] = int(data_ver)
            value["role"] = value["role"]
            self._state["archives"][self._key(userid)] = value["role"]
            self._changed()
            return copy.deepcopy(value["role"])

    def apply_skill_exp(self, userid, skill_gains, data_ver=None):
        """按客户端结算结果同步写落盘 skills.exp。
        skill_gains: {skillId: addExp, ...} 或 [(skillId, addExp), ...]
        返回 (role, applied_map, data_ver)
        """
        userid = self._userid(userid)
        if isinstance(skill_gains, dict):
            items = list(skill_gains.items())
        elif isinstance(skill_gains, (list, tuple)):
            items = list(skill_gains)
        else:
            items = []
        with self._lock:
            doc = self.get_archive_document(userid)
            if doc is None:
                return None, {}, 0
            role = copy.deepcopy(doc.get("role") or {})
            skills = role.get("skills")
            if not isinstance(skills, dict):
                skills = {}
            applied = {}
            for item in items:
                if isinstance(item, (list, tuple)) and len(item) >= 2:
                    skill_id, add_exp = item[0], item[1]
                else:
                    continue
                if not skill_id:
                    continue
                try:
                    add_exp = int(add_exp or 0)
                except (TypeError, ValueError):
                    add_exp = 0
                if add_exp <= 0:
                    continue
                skill_id = str(skill_id)
                skill = skills.get(skill_id)
                if not isinstance(skill, dict):
                    skill = {"id": skill_id, "exp": 0}
                try:
                    old_exp = int(skill.get("exp") or 0)
                except (TypeError, ValueError):
                    old_exp = 0
                new_exp = old_exp + add_exp
                skill["id"] = skill_id
                skill["exp"] = new_exp
                skills[skill_id] = skill
                applied[skill_id] = {"old": old_exp, "add": add_exp, "new": new_exp}
            role["skills"] = skills
            if data_ver is None:
                data_ver = extract_data_ver(role, doc.get("dataVer") or 0) + 1
            saved = self.put_archive(
                userid,
                role,
                record=doc.get("record"),
                upload=doc.get("upload"),
                data_ver=data_ver,
            )
            return saved, applied, int(data_ver)

    def delete_archive(self, userid):
        userid = self._userid(userid)
        with self._lock:
            removed = False
            if self.archive_store:
                removed = self.archive_store.delete(userid) or removed
            if self._state["archives"].pop(self._key(userid), None) is not None:
                removed = True
            account = self._state["accounts"].get(self._key(userid))
            if account is not None:
                account["has_archive"] = False
                account["updated_at"] = self._now()
            if removed:
                self._changed()
            return removed

    def list_archives(self):
        with self._lock:
            values = []
            seen = set()
            if self.archive_store:
                for userid in self.archive_store.list_userids():
                    doc = self.archive_store.load(userid)
                    if doc is None:
                        continue
                    values.append(document_summary(doc))
                    seen.add(userid)
            for key, archive in (self._state.get("archives") or {}).items():
                try:
                    userid = self._userid(key if not isinstance(archive, dict) else archive.get("userid", key))
                except ValueError:
                    continue
                if userid in seen:
                    continue
                values.append(document_summary(coerce_document(archive, userid=userid)))
            values.sort(key=lambda item: item["userid"])
            return copy.deepcopy(values)

    def set_active_archive(self, device_uuid, userid):
        userid = self._userid(userid)
        key = str(device_uuid or "")
        with self._lock:
            if self.get_archive(userid) is None:
                raise KeyError("archive not found")
            self._state["active_archive"][key] = {
                "userid": userid,
                "updated_at": self._now(),
            }
            self._changed()
            return copy.deepcopy(self._state["active_archive"][key])

    def get_active_archive(self, device_uuid):
        key = str(device_uuid or "")
        with self._lock:
            value = self._state["active_archive"].get(key)
            return copy.deepcopy(value) if value is not None else None

    def get_device(self, userid):
        userid = self._userid(userid)
        with self._lock:
            key = self._key(userid)
            value = self._state["devices"].setdefault(key, {
                "userid": userid,
                "email": "",
                "phone": "",
                "bound": False,
                "is_logout": False,
                "verify_code": "",
                "verify_expires_at": 0,
                "last_event_type": "",
                "updated_at": self._now(),
            })
            self._changed()
            return copy.deepcopy(value)

    def bind_device(self, userid, email=None, verify_code=None):
        userid = self._userid(userid)
        with self._lock:
            device = self.get_device(userid)
            normalized_email = self._normalize_email(email if email is not None else device.get("email"))
            owner = self._state["email_users"].get(normalized_email) if normalized_email else None
            if owner is not None and int(owner) != userid:
                raise ValueError("email already bound")
            old_email = self._normalize_email(device.get("email"))
            if old_email and old_email != normalized_email and self._state["email_users"].get(old_email) == userid:
                self._state["email_users"].pop(old_email, None)
            if email is not None:
                device["email"] = normalized_email
            if verify_code is not None:
                device["verify_code"] = str(verify_code)
            if normalized_email:
                self._state["email_users"][normalized_email] = userid
            account = self._state["accounts"].get(self._key(userid))
            if isinstance(account, dict):
                account["email"] = normalized_email
                account["updated_at"] = self._now()
            device["bound"] = True
            device["is_logout"] = False
            device["last_event_type"] = "bind"
            device["updated_at"] = self._now()
            self._state["devices"][self._key(userid)] = device
            self._changed()
            return copy.deepcopy(device)

    def unbind_device(self, userid):
        userid = self._userid(userid)
        with self._lock:
            device = self.get_device(userid)
            device["bound"] = False
            device["is_logout"] = True
            device["last_event_type"] = "logout"
            device["updated_at"] = self._now()
            self._state["devices"][self._key(userid)] = device
            self._changed()
            return copy.deepcopy(device)

    def set_email_code(self, userid, email, code, event_type=None, expires_at=None):
        userid = self._userid(userid)
        with self._lock:
            device = self.get_device(userid)
            target = self._normalize_email(email)
            device["verify_target"] = target
            device["verify_code"] = str(code or "")
            device["verify_expires_at"] = int(expires_at or self._now() + 600)
            device["last_event_type"] = str(event_type or "")
            device["updated_at"] = self._now()
            self._state["devices"][self._key(userid)] = device
            self._changed()
            return copy.deepcopy(device)

    def get_userid_by_email(self, email):
        normalized_email = self._normalize_email(email)
        if not normalized_email:
            return None
        with self._lock:
            userid = self._state["email_users"].get(normalized_email)
            if userid is not None:
                return self._userid(userid)
            for key, device in self._state["devices"].items():
                if not isinstance(device, dict):
                    continue
                if not device.get("bound") and not device.get("is_logout"):
                    continue
                if self._normalize_email(device.get("email")) != normalized_email:
                    continue
                userid = self._userid(device.get("userid", key))
                self._state["email_users"][normalized_email] = userid
                self._changed()
                return userid
            return None

    def validate_email_code(self, userid, email, code, now=None):
        userid = self._userid(userid)
        target = self._normalize_email(email)
        with self._lock:
            device = self.get_device(userid)
            expected_target = self._normalize_email(device.get("verify_target", device.get("email")))
            if not target or target != expected_target:
                raise ValueError("invalid verify target")
            if not code or str(code) != str(device.get("verify_code", "")):
                raise ValueError("invalid verify code")
            if int(device.get("verify_expires_at") or 0) <= int(now if now is not None else self._now()):
                raise ValueError("verify code expired")
            return copy.deepcopy(device)

    def get_email(self, userid):
        device = self.get_device(userid)
        return {
            "email": device.get("email", ""),
            "phone": device.get("phone", ""),
            "is_bind": bool(device.get("bound")),
            "is_logout": bool(device.get("is_logout")),
            "auth": device.get("auth", False),
        }

    def create_order(self, userid, payload=None):
        userid = self._userid(userid)
        with self._lock:
            order_id = self._next("order_id", "order")
            trans_id = self._next("order_id", "trans")
            value = {
                "order_id": order_id,
                "trans_id": trans_id,
                "userid": userid,
                "status": "pending",
                "payload": copy.deepcopy(payload or {}),
                "created_at": self._now(),
                "updated_at": self._now(),
            }
            self._state["orders"][trans_id] = value
            self._changed()
            return copy.deepcopy(value)

    def get_order(self, order_id):
        with self._lock:
            value = self._state["orders"].get(str(order_id))
            if value is None:
                for item in self._state["orders"].values():
                    if isinstance(item, dict) and order_id in (item.get("order_id"), item.get("trans_id")):
                        value = item
                        break
            return copy.deepcopy(value) if value is not None else None

    def update_order(self, order_id, patch):
        if not isinstance(patch, dict):
            raise TypeError("patch must be a dict")
        with self._lock:
            key = str(order_id)
            order = self._state["orders"].get(key)
            if order is None:
                for candidate_key, item in self._state["orders"].items():
                    if isinstance(item, dict) and order_id in (item.get("order_id"), item.get("trans_id")):
                        key = candidate_key
                        order = item
                        break
            if order is None:
                raise KeyError("order not found")
            order.update(copy.deepcopy(patch))
            order["updated_at"] = self._now()
            self._changed()
            return copy.deepcopy(order)

    def list_mail(self, userid):
        userid = self._userid(userid)
        with self._lock:
            return copy.deepcopy(self._state["mail"].get(self._key(userid), []))

    def add_mail(self, userid, mail):
        userid = self._userid(userid)
        if not isinstance(mail, dict):
            raise TypeError("mail must be a dict")
        with self._lock:
            value = copy.deepcopy(mail)
            value.setdefault("mail_id", self._next("mail_id", "mail"))
            value.setdefault("read", False)
            value.setdefault("claimed", False)
            value.setdefault("created_at", self._now())
            self._state["mail"].setdefault(self._key(userid), []).append(value)
            self._changed()
            return copy.deepcopy(value)

    def get_mail(self, userid, mail_id):
        key = str(self._userid(userid))
        mail_id = str(mail_id)
        with self._lock:
            for item in self._state["mail"].get(key, []):
                if str(item.get("mail_id")) == mail_id:
                    return copy.deepcopy(item)
        return None

    def get_inventory_item_count(self, userid, item_id):
        key = str(self._userid(userid))
        with self._lock:
            inventory = self._state["inventory_items"].get(key, {})
            try:
                value = int(inventory.get(str(item_id), 0))
            except (TypeError, ValueError):
                value = 0
            return max(value, 0)

    def get_mail_delivery(self, request_id):
        with self._lock:
            value = self._state["mail_deliveries"].get(str(request_id))
            return copy.deepcopy(value) if value is not None else None

    def record_mail_delivery(self, request_id, value):
        with self._lock:
            key = str(request_id)
            existing = self._state["mail_deliveries"].get(key)
            if existing is not None:
                return copy.deepcopy(existing)
            self._state["mail_deliveries"][key] = copy.deepcopy(value)
            self._changed()
            return copy.deepcopy(value)

    def update_mail(self, userid, mail_id, patch):
        userid = self._userid(userid)
        if not isinstance(patch, dict):
            raise TypeError("patch must be a dict")
        with self._lock:
            messages = self._state["mail"].get(self._key(userid), [])
            for message in messages:
                if str(message.get("mail_id")) == str(mail_id):
                    message.update(copy.deepcopy(patch))
                    self._changed()
                    return copy.deepcopy(message)
            raise KeyError("mail not found")

    def get_activities(self, activity_type=None):
        with self._lock:
            values = list(self._state["activities"].values())
            if activity_type is not None:
                values = [item for item in values if str(item.get("type")) == str(activity_type)]
            return copy.deepcopy(values)

    def put_activity(self, activity_id, activity):
        if not isinstance(activity, dict):
            raise TypeError("activity must be a dict")
        with self._lock:
            value = copy.deepcopy(activity)
            value["activity_id"] = str(activity_id)
            self._state["activities"][str(activity_id)] = value
            self._changed()
            return copy.deepcopy(value)

    def update_activity_user(self, userid, activity_id, patch):
        userid = self._userid(userid)
        if not isinstance(patch, dict):
            raise TypeError("patch must be a dict")
        with self._lock:
            user = self._state["activity_users"].setdefault(self._key(userid), {})
            value = user.setdefault(str(activity_id), {"point": 0, "claimed": []})
            value.update(copy.deepcopy(patch))
            self._changed()
            return copy.deepcopy(value)

    def get_rankings(self, board_type="default", page=1, page_size=20):
        try:
            page = max(1, int(page))
            page_size = max(1, int(page_size))
        except (TypeError, ValueError):
            raise ValueError("invalid page")
        with self._lock:
            values = list(self._state["rankings"].get(str(board_type), []))
            values.sort(key=lambda item: (-float(item.get("score", item.get("value", 0))), int(item.get("userid", 0))))
            start = (page - 1) * page_size
            result = copy.deepcopy(values[start:start + page_size])
            for index, item in enumerate(result, start=start + 1):
                item.setdefault("rank", index)
            return {
                "list": result,
                "page": page,
                "page_size": page_size,
                "total": len(values),
            }

    def upsert_ranking(self, board_type, userid, entry):
        userid = self._userid(userid)
        if not isinstance(entry, dict):
            raise TypeError("entry must be a dict")
        with self._lock:
            values = self._state["rankings"].setdefault(str(board_type), [])
            value = copy.deepcopy(entry)
            value["userid"] = userid
            for index, item in enumerate(values):
                if str(item.get("userid")) == str(userid):
                    values[index] = value
                    break
            else:
                values.append(value)
            self._changed()
            return copy.deepcopy(value)

    def get_biwu(self, userid):
        userid = self._userid(userid)
        with self._lock:
            value = self._state["biwu"].setdefault(self._key(userid), {
                "userid": userid,
                "stage": "idle",
                "watching": False,
                "current_fight_id": None,
                "fight_times_left": 0,
                "yuanbao_cost": {"join": 0, "challenge": 0},
                "fight_records": [],
                "rewards": [],
                "last_result": None,
            })
            self._changed()
            return copy.deepcopy(value)

    def update_biwu(self, userid, patch):
        userid = self._userid(userid)
        if not isinstance(patch, dict):
            raise TypeError("patch must be a dict")
        with self._lock:
            value = self.get_biwu(userid)
            value.update(copy.deepcopy(patch))
            value["userid"] = userid
            self._state["biwu"][self._key(userid)] = value
            self._changed()
            return copy.deepcopy(value)

    def add_biwu_fight(self, userid, fight):
        userid = self._userid(userid)
        if not isinstance(fight, dict):
            raise TypeError("fight must be a dict")
        with self._lock:
            value = copy.deepcopy(fight)
            value.setdefault("fight_id", self._next("fight_id", "fight"))
            value["userid"] = userid
            self._state["biwu_fights"][str(value["fight_id"])] = value
            self._state["biwu"].setdefault(self._key(userid), self.get_biwu(userid))
            self._state["biwu"][self._key(userid)]["fight_records"].append(copy.deepcopy(value))
            self._changed()
            return copy.deepcopy(value)

    def list_biwu_fights(self, userid=None, status=None):
        with self._lock:
            values = list(self._state["biwu_fights"].values())
            if userid is not None:
                userid = self._userid(userid)
                values = [item for item in values if str(item.get("userid")) == str(userid)]
            if status is not None:
                values = [item for item in values if item.get("status") == status]
            return copy.deepcopy(values)
