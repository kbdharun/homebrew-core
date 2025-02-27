class Nebula < Formula
  desc "Scalable overlay networking tool for connecting computers anywhere"
  homepage "https://github.com/slackhq/nebula"
  url "https://github.com/slackhq/nebula/archive/refs/tags/v1.8.0.tar.gz"
  sha256 "678ad2bda47258cce8c2d14b3fa56d17c0ba4f894d75b75afab8937d64e12da7"
  license "MIT"
  head "https://github.com/slackhq/nebula.git", branch: "master"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_sonoma:   "15cb51889cecdce9f3295af7423b2c4ee20772f1c0dab4fb52d3c31df5ff412e"
    sha256 cellar: :any_skip_relocation, arm64_ventura:  "15cb51889cecdce9f3295af7423b2c4ee20772f1c0dab4fb52d3c31df5ff412e"
    sha256 cellar: :any_skip_relocation, arm64_monterey: "15cb51889cecdce9f3295af7423b2c4ee20772f1c0dab4fb52d3c31df5ff412e"
    sha256 cellar: :any_skip_relocation, sonoma:         "70631a2193c50c4b9da35217b33c20de46f752e3af725544518fda761f72e99f"
    sha256 cellar: :any_skip_relocation, ventura:        "70631a2193c50c4b9da35217b33c20de46f752e3af725544518fda761f72e99f"
    sha256 cellar: :any_skip_relocation, monterey:       "70631a2193c50c4b9da35217b33c20de46f752e3af725544518fda761f72e99f"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "6a67772affd03ba4a04b797b4bf6ff759d96b46d5fba2cb6f6e2c1ddb40bdaf2"
  end

  depends_on "go" => :build

  def install
    ENV["BUILD_NUMBER"] = version
    system "make", "service"
    bin.install "./nebula"
    bin.install "./nebula-cert"
    prefix.install_metafiles
  end

  service do
    run [opt_bin/"nebula", "-config", etc/"nebula/config.yml"]
    keep_alive true
    require_root true
    log_path var/"log/nebula.log"
    error_log_path var/"log/nebula.log"
  end

  test do
    system "#{bin}/nebula-cert", "ca", "-name", "testorg"
    system "#{bin}/nebula-cert", "sign", "-name", "host", "-ip", "192.168.100.1/24"
    (testpath/"config.yml").write <<~EOS
      pki:
        ca: #{testpath}/ca.crt
        cert: #{testpath}/host.crt
        key: #{testpath}/host.key
    EOS
    system "#{bin}/nebula", "-test", "-config", "config.yml"
  end
end
