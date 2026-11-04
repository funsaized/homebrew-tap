require "net/http"

class HerdrMise < Formula
  desc "Localhost kitchen visualizer for Herdr coding agents"
  homepage "https://github.com/funsaized/herdr-mise"
  license "MIT"
  depends_on "herdr"

  if OS.mac? && Hardware::CPU.arm?
    url "https://github.com/funsaized/herdr-mise/releases/download/v0.7.0/herdr-mise-v0.7.0-aarch64-apple-darwin.tar.gz"
    sha256 "e1af1e05d45970d986fc96a6a4b673405fb480f046ce4fb42c95972e14a28ab3"
  elsif OS.mac?
    url "https://github.com/funsaized/herdr-mise/releases/download/v0.7.0/herdr-mise-v0.7.0-x86_64-apple-darwin.tar.gz"
    sha256 "fae59c996bb19e967b61c5d70ab48d32ff2770427308111c1cd11eeac429d85d"
  else
    url "https://github.com/funsaized/herdr-mise/releases/download/v0.7.0/herdr-mise-v0.7.0-x86_64-unknown-linux-gnu.tar.gz"
    sha256 "63aaf81167e773898d86d6225120a48550ad4a0afd2f5d437623064e64a65bef"
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
