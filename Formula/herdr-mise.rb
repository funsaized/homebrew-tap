require "net/http"

class HerdrMise < Formula
  desc "Localhost kitchen visualizer for Herdr coding agents"
  homepage "https://github.com/funsaized/herdr-mise"
  license "MIT"
  depends_on "herdr"

  if OS.mac? && Hardware::CPU.arm?
    url "https://github.com/funsaized/herdr-mise/releases/download/v0.5.1/herdr-mise-v0.5.1-aarch64-apple-darwin.tar.gz"
    sha256 "5e0a02d94c739668d8edff55b5670292314abf64b14e81d7acbf820f102841b0"
  elsif OS.mac?
    url "https://github.com/funsaized/herdr-mise/releases/download/v0.5.1/herdr-mise-v0.5.1-x86_64-apple-darwin.tar.gz"
    sha256 "9e15e1823f706a3c073ca2c1a3873ccd77a27f520b5ab4b39dfb65e570ce4ce0"
  else
    url "https://github.com/funsaized/herdr-mise/releases/download/v0.5.1/herdr-mise-v0.5.1-x86_64-unknown-linux-gnu.tar.gz"
    sha256 "7baccb695f831d97234fcb1e8555af3f0da1e7bb19856dd2394921bc71339061"
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
