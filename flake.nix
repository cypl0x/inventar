{
  description = "Flutter development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux"; 
      pkgs = import nixpkgs {
        inherit system;
        config = {
          allowUnfree = true;
          android_sdk.accept_license = true;
        };
      };

      androidSdk = (pkgs.androidenv.composeAndroidPackages {
        platformVersions = [ "35" "36" ];
        includeNDK = true;
        ndkVersions = [ "28.2.13676358" ];
        buildToolsVersions = [ "35.0.0" ];
        cmakeVersions = [ "3.22.1" ];
      }).androidsdk;

    in
    {
      devShells.${system}.default = pkgs.mkShell {
        name = "flutter-env";

        buildInputs = with pkgs; [
          # Core tools
          flutter
          jdk21_headless
          androidSdk

          # Build tools
          cmake
          ninja
          clang
          pkg-config

          # Linux Desktop dependencies
          gtk3
          glib
          pcre2
          libepoxy
          libX11      # Updated from xorg.libX11
          zlib
          
          # Hardware & Info tools
          mesa-demos  # Contains glxinfo and eglinfo
          libGL
          vulkan-loader
        ];

        # Environment variables
        ANDROID_SDK_ROOT = "${androidSdk}/libexec/android-sdk";
        ANDROID_HOME = "${androidSdk}/libexec/android-sdk";
        JAVA_HOME = "${pkgs.jdk21_headless}";

        # Critical for runtime library discovery on NixOS
        LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath (with pkgs; [
          zlib
          libGL
          vulkan-loader
        ]);

        shellHook = ''
          echo "🚀 Flutter Dev Environment Loaded"
          echo "Run 'flutter run -d linux' to start your app."
        '';
      };
    };
}
