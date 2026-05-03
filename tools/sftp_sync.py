import argparse
import os
import posixpath

import paramiko


def mkdir_p(sftp, path):
    parts = []
    while path not in ("", "/"):
        parts.append(path)
        path = posixpath.dirname(path)
    for item in reversed(parts):
        try:
            sftp.mkdir(item)
        except IOError:
            pass


def upload_path(sftp, local_path, remote_path):
    if os.path.isdir(local_path):
        mkdir_p(sftp, remote_path)
        for base, _, files in os.walk(local_path):
            rel = os.path.relpath(base, local_path).replace("\\", "/")
            remote_base = remote_path if rel == "." else f"{remote_path}/{rel}"
            mkdir_p(sftp, remote_base)
            for name in files:
                sftp.put(os.path.join(base, name), f"{remote_base}/{name}")
    else:
        mkdir_p(sftp, posixpath.dirname(remote_path))
        sftp.put(local_path, remote_path)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--host", required=True)
    parser.add_argument("--user", required=True)
    parser.add_argument("--password", required=True)
    parser.add_argument("--local", required=True)
    parser.add_argument("--remote", required=True)
    parser.add_argument("--port", type=int, default=22)
    args = parser.parse_args()

    client = paramiko.SSHClient()
    client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    client.connect(
        hostname=args.host,
        port=args.port,
        username=args.user,
        password=args.password,
        look_for_keys=False,
        allow_agent=False,
        timeout=15,
    )
    try:
        sftp = client.open_sftp()
        try:
            upload_path(sftp, args.local, args.remote)
        finally:
            sftp.close()
    finally:
        client.close()


if __name__ == "__main__":
    main()