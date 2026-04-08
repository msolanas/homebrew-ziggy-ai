class ZiggyAi < Formula
  desc "macOS menu bar app for local Gemma 4 inference via MLX"
  homepage "https://github.com/q6cvy7kyxj-droid/ZiggyLocalAI"
  url "https://github.com/q6cvy7kyxj-droid/ZiggyLocalAI.git",
      tag:      "v1.0.0",
      revision: "d6e6163c4c53414db61cac7175f74ac1ac035b05"
  license "MIT"

  depends_on :macos
  depends_on "python@3.14"

  def install
    # Build Swift binaries
    system "swift", "build", "-c", "release", "--disable-sandbox"
    bin.install ".build/release/ZiggyAI"
    bin.install ".build/release/ziggy-ai"

    # Install server wrapper to libexec
    libexec.install "server_wrapper.py"

    # Set up Python venv in libexec with mlx packages
    python3 = Formula["python@3.14"].opt_bin/"python3.14"
    venv = libexec/"venv"
    system python3, "-m", "venv", venv.to_s

    venv_pip = venv/"bin/pip"
    system venv_pip, "install", "--upgrade", "pip"
    system venv_pip, "install",
           "mlx-vlm @ git+https://github.com/Blaizzy/mlx-vlm.git@main",
           "mlx-lm @ git+https://github.com/ml-explore/mlx-lm.git@main",
           "huggingface_hub"

    # Symlink venv Python into libexec/bin for runtime discovery
    (libexec/"bin").mkpath
    ln_sf venv/"bin/python3", libexec/"bin/python3"
  end

  def caveats
    <<~EOS
      To download the AI model (~15GB), run:
        ziggy-ai setup

      Then start the engine:
        ziggy-ai start

      If using Starship prompt, disable the Swift module to avoid timeouts:
        echo '[swift]\ndisabled = true' >> ~/.config/starship.toml
    EOS
  end

  test do
    assert_match "Usage:", shell_output("#{bin}/ziggy-ai 2>&1")
    assert_match "stopped", shell_output("#{bin}/ziggy-ai status 2>&1")
  end
end
