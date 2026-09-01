"""Fernet-based password encryption for Restic repository passwords."""

import os
import sys

from cryptography.fernet import Fernet

KEY_FILE = os.path.expanduser("~/.restic.key")


def get_or_create_key() -> bytes:
    """Retrieve the master key or create one with secure permissions."""
    if os.path.exists(KEY_FILE):
        with open(KEY_FILE, "rb") as f:
            return f.read()

    print(f"Master key not found. Generating a new one at: {KEY_FILE}")
    key = Fernet.generate_key()

    flags = os.O_WRONLY | os.O_CREAT | os.O_TRUNC
    mode = 0o600
    fd = os.open(KEY_FILE, flags, mode)
    with os.fdopen(fd, "wb") as key_out:
        key_out.write(key)
    return key


def encrypt_password(plaintext_password: str) -> str:
    """Encrypt a plaintext string using the master key."""
    key = get_or_create_key()
    fernet = Fernet(key)
    encrypted_bytes = fernet.encrypt(plaintext_password.encode())
    return encrypted_bytes.decode()


def decrypt_password(encrypted_password: str) -> str:
    """Decrypt a cipher string using the master key."""
    key = get_or_create_key()
    fernet = Fernet(key)
    try:
        decrypted_bytes = fernet.decrypt(encrypted_password.encode())
        return decrypted_bytes.decode()
    except Exception:
        print(
            f"Error decrypting password. Is the master key file ({KEY_FILE}) missing or modified?",
            file=sys.stderr,
        )
        sys.exit(1)
