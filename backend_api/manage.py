#!/usr/bin/env python
"""Django yönetim komutlarını çalıştırmak için kullanılan komut satırı aracı."""
import os
import sys


def main():
    """Yönetimsel görevleri başlatır."""
    os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings')
    try:
        from django.core.management import execute_from_command_line
    except ImportError as exc:
        raise ImportError(
            "Django yüklenemedi. Sanal ortamınızın (venv) aktif olduğundan "
            "ve Django paketinin kurulu olduğundan emin olun."
        ) from exc
    execute_from_command_line(sys.argv)


if __name__ == '__main__':
    main()
