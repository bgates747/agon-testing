from __future__ import annotations

import sys
import unittest
from pathlib import Path


SCRIPTS = Path(__file__).resolve().parent.parent / "scripts"
sys.path.insert(0, str(SCRIPTS))

from write_zinc_cfg import encode_uart_config  # noqa: E402


class ZincConfigTests(unittest.TestCase):
    def test_115200_8n1_encoding(self) -> None:
        self.assertEqual(
            encode_uart_config(),
            bytes.fromhex("00c2010801000000"),
        )

    def test_baud_must_fit_in_24_bits(self) -> None:
        with self.assertRaises(ValueError):
            encode_uart_config(baud=1 << 24)

    def test_invalid_frame_settings_are_rejected(self) -> None:
        with self.assertRaises(ValueError):
            encode_uart_config(data_bits=6)
        with self.assertRaises(ValueError):
            encode_uart_config(stop_bits=3)
        with self.assertRaises(ValueError):
            encode_uart_config(parity=3)


if __name__ == "__main__":
    unittest.main()
