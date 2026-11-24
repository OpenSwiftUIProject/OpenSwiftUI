import json
import subprocess
import sys
import threading
import unittest
from pathlib import Path
from urllib.error import HTTPError
from urllib.request import Request, urlopen


WEB_ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(WEB_ROOT))
try:
    import playground_server  # noqa: E402
finally:
    sys.path.pop(0)


class PlaygroundFrontendTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.server = playground_server.PlaygroundHTTPServer(
            ("127.0.0.1", 0),
            object(),
        )
        port = cls.server.server_address[1]
        cls.server.allowed_hosts = {
            "127.0.0.1:{}".format(port),
            "localhost:{}".format(port),
        }
        cls.server.allowed_origins = {
            "http://127.0.0.1:{}".format(port),
            "http://localhost:{}".format(port),
        }
        cls.base_url = "http://127.0.0.1:{}".format(port)
        cls.thread = threading.Thread(target=cls.server.serve_forever, daemon=True)
        cls.thread.start()

    @classmethod
    def tearDownClass(cls):
        cls.server.shutdown()
        cls.server.server_close()
        cls.thread.join(timeout=5.0)
        if cls.thread.is_alive():
            raise RuntimeError("frontend test server did not stop")

    def request(self, path, method="GET"):
        return urlopen(Request(self.base_url + path, method=method), timeout=5.0)

    def test_index_loads_pinned_same_origin_editor_assets(self):
        with self.request("/") as response:
            body = response.read().decode("utf-8")
            policy = response.headers["Content-Security-Policy"]

        self.assertIn('src="/vendor/ace/ace.js"', body)
        self.assertIn('src="/vendor/ace/mode-swift.js"', body)
        self.assertIn('src="/vendor/ace/theme-one_dark.js"', body)
        self.assertIn('src="/swift6-mode.js"', body)
        self.assertLess(
            body.index("/vendor/ace/ace.js"),
            body.index("/vendor/ace/mode-swift.js"),
        )
        self.assertLess(
            body.index("/vendor/ace/mode-swift.js"),
            body.index("/swift6-mode.js"),
        )
        self.assertLess(body.index("/swift6-mode.js"), body.index("/playground.js"))
        self.assertIn("script-src 'self'", policy)
        self.assertIn("style-src 'self' 'unsafe-inline'", policy)
        playground_script = (WEB_ROOT / "playground.js").read_text(encoding="utf-8")
        self.assertIn('setMode("ace/mode/swift6")', playground_script)

        package = json.loads((WEB_ROOT / "package.json").read_text(encoding="utf-8"))
        lock = json.loads((WEB_ROOT / "package-lock.json").read_text(encoding="utf-8"))
        self.assertEqual(package["dependencies"]["ace-builds"], "1.44.0")
        self.assertEqual(
            lock["packages"]["node_modules/ace-builds"]["version"],
            "1.44.0",
        )

    def test_editor_assets_have_javascript_mime_and_support_head(self):
        for path in (
            "/vendor/ace/ace.js",
            "/vendor/ace/mode-swift.js",
            "/vendor/ace/theme-one_dark.js",
            "/swift6-mode.js",
        ):
            with self.subTest(path=path):
                with self.request(path) as response:
                    self.assertEqual(
                        response.headers.get_content_type(),
                        "text/javascript",
                    )
                    self.assertGreater(len(response.read()), 0)
                with self.request(path, method="HEAD") as response:
                    self.assertEqual(response.status, 200)
                    self.assertGreater(int(response.headers["Content-Length"]), 0)
                    self.assertEqual(response.read(), b"")

    def test_unlisted_vendor_asset_is_not_exposed(self):
        with self.assertRaises(HTTPError) as context:
            self.request("/vendor/ace/worker-javascript.js")
        try:
            self.assertEqual(context.exception.code, 404)
        finally:
            context.exception.close()

    def test_swift6_tokenizer(self):
        result = subprocess.run(
            ["node", str(WEB_ROOT / "tests" / "swift_highlighting.test.js")],
            cwd=str(WEB_ROOT),
            capture_output=True,
            encoding="utf-8",
            timeout=10.0,
        )
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)

    def test_build_status_reconciliation(self):
        result = subprocess.run(
            ["node", str(WEB_ROOT / "tests" / "playground_status.test.js")],
            cwd=str(WEB_ROOT),
            capture_output=True,
            encoding="utf-8",
            timeout=10.0,
        )
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)


if __name__ == "__main__":
    unittest.main()
