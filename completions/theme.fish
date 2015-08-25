# Add completions when the theme is loaded. Thanks Bruno!
complete --command (basename -s.fish (status -f)) \
  --arguments "(basename -a (theme.util.get.themes))" \
  --description "Oh-my-fish theme" --no-files
