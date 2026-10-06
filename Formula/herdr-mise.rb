require "net/http"

class HerdrMise < Formula
  desc "Localhost kitchen visualizer for Herdr coding agents"
  homepage "https://github.com/funsaized/herdr-mise"
  license "MIT"
  depends_on "herdr"

  if OS.mac? && Hardware::CPU.arm?
    url "https://github.com/funsaized/herdr-mise/releases/download/v0.5.0/herdr-mise-v0.5.0-aarch64-apple-darwin.tar.gz"
    sha256 "83cb769831ba684a6ac2e048a42c6ba3199bdced82447d96284d27ccd3fa9db2"
  elsif OS.mac?
    url "https://github.com/funsaized/herdr-mise/releases/download/v0.5.0/herdr-mise-v0.5.0-x86_64-apple-darwin.tar.gz"
    sha256 "8b0bbd45d06c89f0f5c06c8bd17810417a1555f070670a542f65dffc950089c0"
  else
    url "https://github.com/funsaized/herdr-mise/releases/download/v0.5.0/herdr-mise-v0.5.0-x86_64-unknown-linux-gnu.tar.gz"
    sha256 "1ebd002f965a82f0c41270614d687f3a9622b5fab6d7cdaa0761d81bf8239071"
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
