require "./config"

def Crystal.version_string
  build_date =
    ifdef darwin || linux
      {{ `date -u`.stringify.chomp }}
    elsif windows
      # win32: TODO
      build_date = "Fri May  1 17:59:04 UTC 2015"
    end

  version = Crystal::Config::VERSION
  pieces = version.split("-")
  tag = pieces[0]? || "?"
  if sha = pieces[2]?
    sha = sha[1 .. -1] if sha.starts_with? 'g'
    "#{tag} [#{sha}] (#{build_date})"
  else
    "#{tag} (#{build_date})"
  end
end
