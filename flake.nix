{
  description = "Inventar – Flutter-based inventory management app";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      supportedSystems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];

      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;

      nixpkgsFor = forAllSystems (system: import nixpkgs {
        inherit system;
        config = {
          allowUnfree = true;
          android_sdk.accept_license = true;
        };
      });
    in
    {
      devShells = forAllSystems (system:
        let
          pkgs = nixpkgsFor.${system};

          androidSdk = (pkgs.androidenv.composeAndroidPackages {
            platformVersions = [ "35" "36" ];
            includeNDK = true;
            ndkVersions = [ "28.2.13676358" ];
            buildToolsVersions = [ "35.0.0" ];
            cmakeVersions = [ "3.22.1" ];
          }).androidsdk;

          # Linux desktop build dependencies (GTK, OpenGL, etc.)
          linuxDeps = pkgs.lib.optionals pkgs.stdenv.isLinux (with pkgs; [
            cmake
            ninja
            clang
            pkg-config
            gtk3
            glib
            pcre2
            libepoxy
            libX11
            zlib
            mesa-demos   # glxinfo / eglinfo
            libGL
            vulkan-loader
          ]);
        in
        {
          default = pkgs.mkShell {
            name = "flutter-env";

            buildInputs = with pkgs; [
              # Core Flutter toolchain
              flutter
              jdk21_headless
              androidSdk

              # Local CI testing (requires Docker)
              act
            ] ++ linuxDeps;

            # Android SDK environment variables
            ANDROID_SDK_ROOT = "${androidSdk}/libexec/android-sdk";
            ANDROID_HOME = "${androidSdk}/libexec/android-sdk";
            JAVA_HOME = "${pkgs.jdk21_headless}";

            # Runtime library path required on NixOS for OpenGL/Vulkan
            LD_LIBRARY_PATH = pkgs.lib.optionalString pkgs.stdenv.isLinux (
              pkgs.lib.makeLibraryPath (with pkgs; [
                zlib
                libGL
                vulkan-loader
              ])
            );

            shellHook = ''
              echo "Flutter Dev Environment Loaded (${system})"
              echo ""
              echo "  flutter run -d linux    – run on Linux desktop"
              echo "  flutter run -d android  – run on Android device/emulator"
              echo "  flutter build linux     – build Linux desktop release"
              echo "  flutter build apk       – build Android APK"
              echo "  flutter build appbundle – build Android App Bundle"
            '';
          };
        }
      );
    };
}
