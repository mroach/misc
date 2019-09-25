function git-clone --description "Clone a git repo and include the org name"
  set git_uri $argv[1]
  set path (string replace -r '^[^:]+:(.+)\.git$' '$1' "$git_uri")
  git clone $git_uri $path
end
