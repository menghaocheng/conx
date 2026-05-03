import argparse
import re
import sys
import time

import paramiko


PROMPT = "__COPILOT_PROMPT__# "
EXIT_MARKER = "__COPILOT_EXIT__="


def read_available(channel, timeout=0.2):
    end_time = time.time() + timeout
    chunks = []
    while time.time() < end_time:
        if channel.recv_ready():
            chunks.append(channel.recv(65535).decode("utf-8", errors="replace"))
            end_time = time.time() + timeout
        else:
            time.sleep(0.05)
    return "".join(chunks)


def wait_for(channel, needles, timeout=15):
    if isinstance(needles, str):
        needles = [needles]
    buffer = ""
    end_time = time.time() + timeout
    while time.time() < end_time:
        buffer += read_available(channel, timeout=0.3)
        if any(needle in buffer for needle in needles):
            return buffer
        time.sleep(0.05)
    raise TimeoutError(f"Timed out waiting for: {needles}\nCaptured:\n{buffer}")


def send_line(channel, line):
    channel.send(line)
    if not line.endswith("\n"):
        channel.send("\n")


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--host", required=True)
    parser.add_argument("--user", required=True)
    parser.add_argument("--password", required=True)
    parser.add_argument("--root-password")
    parser.add_argument("--command")
    parser.add_argument("--port", type=int, default=22)
    args = parser.parse_args()

    command = args.command if args.command is not None else sys.stdin.read()
    if not command.strip():
        raise SystemExit("No command provided")

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
        channel = client.invoke_shell(width=200, height=40)
        wait_for(channel, ["#", "$", ">"], timeout=15)

        if args.root_password:
            send_line(channel, "su -")
            buffer = wait_for(channel, ["Password:", "password:", "#", "$"], timeout=10)
            if "Password:" in buffer or "password:" in buffer:
                send_line(channel, args.root_password)
                wait_for(channel, ["#", "$"], timeout=10)

        send_line(channel, f"export PS1='{PROMPT}'")
        wait_for(channel, PROMPT, timeout=10)

        wrapped = (
            "{\n"
            f"{command}\n"
            "}\n"
            "status=$?\n"
            f"printf '\n{EXIT_MARKER}%s\n' \"$status\"\n"
        )
        send_line(channel, wrapped)

        buffer = ""
        end_time = time.time() + 60
        while time.time() < end_time:
            buffer += read_available(channel, timeout=0.5)
            if EXIT_MARKER in buffer and PROMPT in buffer:
                break
            time.sleep(0.05)
        else:
            raise TimeoutError(f"Timed out waiting for command completion\nCaptured:\n{buffer}")

        matches = list(re.finditer(r"__COPILOT_EXIT__=(\d+)", buffer))
        if not matches:
            raise RuntimeError(f"Could not parse command exit marker\nCaptured:\n{buffer}")
        match = matches[-1]
        output = buffer[:match.start()]
        exit_text = match.group(1)
        sys.stdout.write(output.strip() + "\n")
        sys.stderr.write(f"exit_code={exit_text}\n")
        raise SystemExit(int(exit_text or 1))
    finally:
        client.close()


if __name__ == "__main__":
    main()