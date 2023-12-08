{ lib
, fetchFromGitHub
, pkg-config
, wayland
, libxkbcommon
, mesa
, seatd
, libinput
, wlroots
, wayland-protocols
, libdrm
, pipewire
, rustPlatform
}:

rustPlatform.buildRustPackage rec {
  pname = "niri";
  version = "0.1.0-Alpha.1-2022-12-08";

  src = fetchFromGitHub {
    rev = "d397375d574bc64fdc0ecb91daa267a2fedff4fe";
    owner = "YaLTeR";
    repo = pname;
    hash = "sha256-rfhRIyQjYNqQYvuECSR4q8OEY4QerG9xgN1rddW5S1w=";
  };

  cargoLock = {
    lockFile = ./Cargo.lock;
    outputHashes = { "smithay-0.3.0" = "sha256-leTKh7U5C4hLtYiTCBuYtyNec4rOXZWiyoA5GA1hhhM="; };
  };

  nativeBuildInputs = [
    pkg-config
    rustPlatform.bindgenHook
  ];

  buildInputs = [
    wayland
    libxkbcommon
    libinput
    wlroots
    wayland-protocols
    libdrm
    seatd
    pipewire.dev
    mesa
  ];

  postInstall = ''
    install -Dm444 resources/niri.service $out/lib/systemd/system/niri.service
    substituteInPlace $out/lib/systemd/system/niri.service \
      --replace /usr/bin/niri $out/bin/niri

    install -Dm444 -t $out/share/applications resources/niri.desktop
  '';

  meta = with lib; {
    homepage = "https://github.com/YaLTeR/niri";
    description = "A scrollable-tiling Wayland compositor";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ oluceps ];
  };
}
