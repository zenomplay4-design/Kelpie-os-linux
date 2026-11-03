import unittest

from kelpie_utils import format_size, has_upgradable_packages


class KelpieUtilityTests(unittest.TestCase):
    def test_update_preview_detects_install(self):
        self.assertTrue(has_upgradable_packages("Inst firefox-esr [1] (2 Debian:trixie)"))

    def test_update_preview_rejects_empty_or_non_install_output(self):
        self.assertFalse(has_upgradable_packages("0 upgraded, 0 newly installed, 0 to remove."))
        self.assertFalse(has_upgradable_packages("Conf package (1 Debian:trixie)"))

    def test_size_formatting(self):
        self.assertEqual(format_size(0), "0 B")
        self.assertEqual(format_size(1000), "1.0 KB")
        self.assertEqual(format_size(1_000_000), "1.0 MB")

    def test_invalid_size_is_safe(self):
        self.assertEqual(format_size(None), "Tamanho desconhecido")
        self.assertEqual(format_size(-1), "Tamanho desconhecido")


if __name__ == "__main__":
    unittest.main()
