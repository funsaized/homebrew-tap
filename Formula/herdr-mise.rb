require "net/http"

class HerdrMise < Formula
  desc "Localhost kitchen visualizer for Herdr coding agents"
  homepage "https://github.com/funsaized/herdr-mise"
  license "MIT"
  depends_on "herdr"

  if OS.mac? && Hardware::CPU.arm?
    url "https://github.com/funsaized/herdr-mise/releases/download/v0.4.0/herdr-mise-v0.4.0-aarch64-apple-darwin.tar.gz"
    sha256 "fc72fcad450697ef5187f2672abcf44777c5da1aa70f9a23b273c5b7e395982b"
  elsif OS.mac?
    url "https://github.com/funsaized/herdr-mise/releases/download/v0.4.0/herdr-mise-v0.4.0-x86_64-apple-darwin.tar.gz"
    sha256 "51728102864d6070af1ce8bfb076dac496abfdf14398397adad883a2544f34ed"
  else
    url "https://github.com/funsaized/herdr-mise/releases/download/v0.4.0/herdr-mise-v0.4.0-x86_64-unknown-linux-gnu.tar.gz"
    sha256 "ee90811f2ad46530ff237911b66a2d93a09b2e93ba62686f4177a1d05d8dc9a1"
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
