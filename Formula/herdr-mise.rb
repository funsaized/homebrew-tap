require "net/http"

class HerdrMise < Formula
  desc "Localhost kitchen visualizer for Herdr coding agents"
  homepage "https://github.com/funsaized/herdr-mise"
  license "MIT"
  depends_on "herdr"

  if OS.mac? && Hardware::CPU.arm?
    url "https://github.com/funsaized/herdr-mise/releases/download/v0.3.0/herdr-mise-v0.3.0-aarch64-apple-darwin.tar.gz"
    sha256 "c3634bcfdf6df0215f1dd4719a706810684cb201f3a49f6bf31baa079e7798f4"
  elsif OS.mac?
    url "https://github.com/funsaized/herdr-mise/releases/download/v0.3.0/herdr-mise-v0.3.0-x86_64-apple-darwin.tar.gz"
    sha256 "797fab376445429630c086dd24d417d4be82f102cf7eea46bdee408bcaf67fe6"
  else
    url "https://github.com/funsaized/herdr-mise/releases/download/v0.3.0/herdr-mise-v0.3.0-x86_64-unknown-linux-gnu.tar.gz"
    sha256 "dd77d1c364e8f6e46c469f56c40c6bcad912aed04fea2c0a3fd65bb10a0d73b6"
  end

  on_linux do
    depends_on arch: :x86_64
  end

  def install
    bin.install "herdr-mise"
    prefix.install "LICENSE", "THIRD_PARTY_NOTICES.txt"
  end

  test do
    port = free_port
    environment = {
      "HOME"              => testpath.to_s,
      "XDG_CONFIG_HOME"   => (testpath/"config").to_s,
      "XDG_DATA_HOME"     => (testpath/"data").to_s,
      "HERDR_MISE_PORT"   => port.to_s,
      "HERDR_SOCKET_PATH" => (testpath/"missing.sock").to_s,
    }
    pid = spawn environment, bin/"herdr-mise"

    begin
      response = nil
      30.times do
        response = Net::HTTP.get_response(URI("http://127.0.0.1:#{port}/"))
        break if response.is_a?(Net::HTTPSuccess)
      rescue Errno::ECONNREFUSED
        sleep 0.2
      end
      assert_match(%r{assets/index-[^"']+\.js}, response&.body)
    ensure
      Process.kill("TERM", pid)
      Process.wait(pid)
    end
  end
end
