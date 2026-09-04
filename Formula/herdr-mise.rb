require "net/http"

class HerdrMise < Formula
  desc "Localhost kitchen visualizer for Herdr coding agents"
  homepage "https://github.com/funsaized/herdr-mise"
  license "MIT"
  depends_on "herdr"

  if OS.mac? && Hardware::CPU.arm?
    url "https://github.com/funsaized/herdr-mise/releases/download/v0.2.0/herdr-mise-v0.2.0-aarch64-apple-darwin.tar.gz"
    sha256 "e7710aa0bb4d8e312b1156399dac4e80b4e10141d9cf29bbf1e34939a8104267"
  elsif OS.mac?
    url "https://github.com/funsaized/herdr-mise/releases/download/v0.2.0/herdr-mise-v0.2.0-x86_64-apple-darwin.tar.gz"
    sha256 "09c402aa7b7aebf781943fd8081259190ba5b278241a3b38aad02dbfca007e08"
  else
    url "https://github.com/funsaized/herdr-mise/releases/download/v0.2.0/herdr-mise-v0.2.0-x86_64-unknown-linux-gnu.tar.gz"
    sha256 "8571f6ae2fabe1126b942c502a28d66300619473451c8cf3f62d5b0262e093c8"
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
