#!/usr/bin/env python3
from harness_lib.stdio import configure_utf8_stdio
from harness_lib.completed_plans import main


if __name__ == '__main__':
    configure_utf8_stdio()
    raise SystemExit(main())
