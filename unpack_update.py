import os, sys, struct, zlib, binascii
from Crypto.Cipher import AES

KEY_GROUPS = {
    'JHHU02': {
        'key': b'cbIhHHuYQIJ1JkwlLupIvNIvdQDfNxSF',
        'iv':  b'PcIQIZifRalhZ88n',
    },
    'FZJH01': {
        'key': b'ae9b363b80d5cc594973ecce1f4d546d',
        'iv':  b'34857d973953e44a',
    },
    'FZJH03': {
        'key': b'880e42c8075b8f400cd72f21451c0866',
        'iv':  b'PcIQIZifRalhZ88n',
    },
    'FZJH02': {
        'key': b'0228482afef78be8b948ad8b08b24da7',
        'iv':  b'34857d973953e44a',
    },
    'FXXF03': {
        'key': b'0228482afef78be8b948ad8b08b24da7',
        'iv':  b'PcIQIZifRalhZ88n',
    },
}

def try_decrypt_content(data):
    data_stripped = data.strip()
    try:
        raw = binascii.unhexlify(data_stripped)
    except Exception:
        return data, 'plain'
    for group_name, cfg in KEY_GROUPS.items():
        magic = group_name.encode('ascii')
        if raw.startswith(magic):
            enc = raw[len(magic):]
            enc = enc[:len(enc) - (len(enc) % 16)]
            try:
                cipher = AES.new(cfg['key'], AES.MODE_CBC, cfg['iv'])
                dec = cipher.decrypt(enc).rstrip(b'0')
                return dec, group_name
            except Exception:
                pass
    return data, 'plain'

def unpack_mzip(pkg_path, out_dir):
    with open(pkg_path, 'rb') as f:
        buf = f.read()
    if len(buf) < 16:
        raise ValueError('文件过小')
    magic, total_files = struct.unpack('<4sI', buf[:8])
    if magic != b'MZIP':
        raise ValueError(f'非法魔数: {magic}')
    print(f'[*] MZIP 包包含 {total_files} 个文件')
    offset = 8
    for i in range(total_files):
        comp_sz = struct.unpack('<Q', buf[offset:offset+8])[0]
        offset += 8
        name_len = struct.unpack('<H', buf[offset:offset+2])[0]
        offset += 2
        file_name = buf[offset:offset+name_len].rstrip(b'\x00').decode('utf-8', errors='ignore')
        offset += name_len
        comp_data = buf[offset:offset+comp_sz]
        offset += comp_sz
        decomp = zlib.decompress(comp_data)
        final_data, ctype = try_decrypt_content(decomp)
        target_path = os.path.join(out_dir, file_name)
        os.makedirs(os.path.dirname(target_path), exist_ok=True)
        with open(target_path, 'wb') as out_f:
            out_f.write(final_data)
        print(f'  [{i+1:>2}/{total_files:>2}] {file_name} ({len(decomp)} -> {len(final_data)} bytes) [{ctype}]')
    print(f'[+] 解包提取完成: {os.path.abspath(out_dir)}')

def decrypt_single(file_path, out_path):
    with open(file_path, 'rb') as f:
        data = f.read()
    dec, ctype = try_decrypt_content(data)
    with open(out_path, 'wb') as out_f:
        out_f.write(dec)
    print(f'[*] 解密单文件 {file_path} -> {out_path} [{ctype}]')

if __name__ == '__main__':
    inp = sys.argv[1]
    out = sys.argv[2] if len(sys.argv) > 2 else None
    with open(inp, 'rb') as f:
        h = f.read(4)
    if h == b'MZIP':
        unpack_mzip(inp, out or inp + '_extracted')
    else:
        decrypt_single(inp, out or inp + '.dec')