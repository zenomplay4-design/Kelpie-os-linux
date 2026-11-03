import tempfile
import unittest
from pathlib import Path

from kelpie_utils import format_size, has_upgradable_packages, read_cpu_model, read_nouveau_gpu_stats


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

    def test_nouveau_gpu_sysfs_metrics(self):
        with tempfile.TemporaryDirectory() as temporary:
            device = Path(temporary) / "card0" / "device"
            hwmon = device / "hwmon" / "hwmon0"
            hwmon.mkdir(parents=True)
            (device / "gpu_busy_percent").write_text("42\n", encoding="ascii")
            (hwmon / "temp1_input").write_text("61500\n", encoding="ascii")
            self.assertEqual(read_nouveau_gpu_stats(temporary), "GPU 42% · 62 °C")

    def test_nouveau_gpu_sysfs_missing_is_safe(self):
        with tempfile.TemporaryDirectory() as temporary:
            self.assertEqual(read_nouveau_gpu_stats(temporary), "Métricas Nouveau indisponíveis")

    def test_cpu_model_is_detected(self):
        with tempfile.TemporaryDirectory() as temporary:
            cpuinfo = Path(temporary) / "cpuinfo"
            cpuinfo.write_text("model name : Intel Xeon E5-2640 v3\n", encoding="utf-8")
            self.assertEqual(read_cpu_model(cpuinfo), "Intel Xeon E5-2640 v3")

    def test_cpu_model_missing_file_uses_fallback(self):
        with tempfile.TemporaryDirectory() as temporary:
            self.assertEqual(read_cpu_model(Path(temporary) / "missing"), "Modelo não identificado")

    def test_invalid_size_is_safe(self):
        self.assertEqual(format_size(None), "Tamanho desconhecido")
        self.assertEqual(format_size(-1), "Tamanho desconhecido")


if __name__ == "__main__":
    unittest.main()
