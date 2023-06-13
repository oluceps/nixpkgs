{ llvmPackages_16
, stdenv
, fetchFromGitHub
, python3
, ninja
, gn
, lib
, fetchgit
}:
let
  gnOld = gn.overrideAttrs (oldAttrs: {
    version = "20230419";
    src = fetchgit {
      url = "https://gn.googlesource.com/gn";
      rev = "5a004f9427a050c6c393c07ddb85cba8ff3849fa";
      sha256 = "sha256-U0rinjJAToVh4zCBd/9I3O4McxW88b7Bp6ibmmqCuQc=";
    };
  });
in
stdenv.mkDerivation rec{
  pname = "naiveproxy";
  version = "114.0.5735.91-3";
  src = fetchFromGitHub {
    owner = "klzgrad";
    repo = "naiveproxy";
    rev = "v${version}";
    sha256 = "sha256-2v7Fg2UCmxze/7P3QEnHwUHD3nCiASAQjPi39xZd+Ks=";
  };
  nativeBuildInputs = [ python3 gnOld ninja llvmPackages_16.clang ];
  DEPOT_TOOLS_WIN_TOOLCHAIN = 0;

  # setSourceRoot = "sourceRoot=$src/src";
  patchPhase = ''
    substituteInPlace src/tools/clang/scripts/update.py \
    --replace "return 1" "return 0"
  '';

  configurePhase = ''
    gn gen out/Release --root="$src/src" \
    --script-executable="${lib.getExe python3}" \
    --args=" \
    is_clang=true
    use_sysroot=false

    fatal_linker_warnings=false
    treat_warnings_as_errors=false

    enable_base_tracing=false
    use_udev=false
    use_aura=false
    use_ozone=false
    use_gio=false
    use_gtk=false
    use_platform_icu_alternatives=true
    use_glib=false

    disable_file_support=true
    enable_websockets=false
    use_kerberos=false
    enable_mdns=false
    enable_reporting=false
    include_transport_security_state_preload_list=false
    use_nss_certs=false"
  '';

  buildPhase = ''
    runHook preBuild
    ninja -C out/Release naive
    runHook postBuild
  '';

  installPhase = ''
    mkdir -p $out
    cp out/Release/* $out
  '';

  meta = with lib; {
    description = " Make a fortune quietly.";
    homepage = "https://github.com/klzgrad/naiveproxy";
    license = licenses.bsd3;
    maintainers = with maintainers; [ oluceps ];
    platforms = platforms.linux;
  };


}
