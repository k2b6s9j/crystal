module Crystal
  module Config
    PATH = {{ env("CRYSTAL_CONFIG_PATH") || "" }}

    VERSION =
      ifdef linux || darwin
        {{ env("CRYSTAL_CONFIG_VERSION") || `(git describe --tags --long 2>/dev/null)`.stringify.chomp }}
      else
        {{ env("CRYSTAL_CONFIG_VERSION") || "0.7.2-win32" }}
      end
  end
end
