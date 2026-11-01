# SandHouse from its Linux release: the .deb from Rotomodo/sandhouse-releases,
# unpacked, with its libraries pointed at the Nix store. sources.json says
# which release; update.sh moves it to the newest.
{
  lib,
  stdenv,
  fetchurl,
  runCommand,
  dpkg,
  autoPatchelfHook,
  wrapGAppsHook3,
  webkitgtk_4_1,
  gtk3,
  libsoup_3,
  glib,
  glib-networking,
  xdotool,
  openssl,
  gst_all_1,
}:
let
  sources = lib.importJSON ./sources.json;

  # The release is built on Ubuntu 22.04, against libxdo.so.3; nixpkgs has
  # libxdo.so.4. The app only calls xdo_new, xdo_free and
  # xdo_send_keysequence_window, which are the same in both.
  libxdo3 = runCommand "libxdo3-compat" { } ''
    mkdir -p $out/lib
    ln -s ${xdotool}/lib/libxdo.so.4 $out/lib/libxdo.so.3
  '';
in
stdenv.mkDerivation {
  pname = "sandhouse";
  inherit (sources) version;

  src = fetchurl { inherit (sources) url hash; };

  nativeBuildInputs = [
    dpkg
    autoPatchelfHook
    wrapGAppsHook3
  ];

  buildInputs = [
    webkitgtk_4_1
    gtk3
    libsoup_3
    glib
    # TLS for WebKit's own requests.
    glib-networking
    xdotool
    libxdo3
    openssl
    # Media in the web view: the microphone and audio in voice channels.
    gst_all_1.gstreamer
    gst_all_1.gst-plugins-base
    gst_all_1.gst-plugins-good
    gst_all_1.gst-plugins-bad
  ];

  unpackCmd = "dpkg-deb -x $curSrc source";

  # The .deb's layout is what the app expects: bin/sandhouse finds its
  # assets in ../lib/<name>/assets.
  installPhase = ''
    runHook preInstall
    mkdir -p $out
    cp -r usr/* $out/
    runHook postInstall
  '';

  meta = {
    description = "Go after a big goal together: boards, chat, voice and docs";
    homepage = "https://sandhouse.app";
    downloadPage = "https://sandhouse.app/download";
    license = lib.licenses.unfree;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "sandhouse";
  };
}
