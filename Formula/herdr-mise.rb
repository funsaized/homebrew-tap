require "net/http"

class HerdrMise < Formula
  desc "Localhost kitchen visualizer for Herdr coding agents"
  homepage "https://github.com/funsaized/herdr-mise"
  license "MIT"
  depends_on "herdr"

  if OS.mac? && Hardware::CPU.arm?
    url "https://github.com/funsaized/herdr-mise/releases/download/v0.5.2/herdr-mise-v0.5.2-aarch64-apple-darwin.tar.gz"
    sha256 "1212aa641ba39ce2be61fd0ba419cf22d60e6921c33367d70727ed81ffb5ccda"
  elsif OS.mac?
    url "https://github.com/funsaized/herdr-mise/releases/download/v0.5.2/herdr-mise-v0.5.2-x86_64-apple-darwin.tar.gz"
    sha256 "06db69309e9057bb63e9958b72fd9e9d77f0c6f2f442c3c506ef025853c49d50"
  else
    url "https://github.com/funsaized/herdr-mise/releases/download/v0.5.2/herdr-mise-v0.5.2-x86_64-unknown-linux-gnu.tar.gz"
    sha256 "a534405486538c54759f1ff45785c4ecab552a838badab914a177e38cf6439d3"
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
