# NAME
#   theme - quick theme switcher
#
# DESCRIPTION
#   Quick theme switcher for Oh my fish. theme is smart to auto-complete
#   as you type from the list available _oh-my-fish_ themes.
#
# SYNOPSIS
#   theme <theme name>
#         [-l --list]
#         [-u --update]
#         [-r --restore]
#         [-h --help]
#
# OPTIONS
#   theme <theme name>
#     Quick switch to theme.
#
#   theme -a --available
#     List available themes.
#
#   theme -d --download-all
#     Download all themes available online.
#
#   theme -l --list
#     List available themes.
#
#   theme -r --restore
#     Restore previous theme.
#
#   theme -h --help
#     Show usage help.
#
# AUTHORS
#   Jorge Bucaran <jbucaran@me.com>
# /

if test -z $__fish_theme_last
  set -g __fish_theme_last $fish_theme
end

function theme -d "quick theme switcher"
  set -l usage "\
    USAGE
      $_ <theme name>
        Quick switch to theme.

      $_ -a --available
        List all themes available online.

      $_ -d --download-all
        Download all available themes.

      $_ -l --list
        List installed themes.

      $_ -r --restore
        Restore previous theme.

      $_ -h --help
        Show usage help.
  "
  if test (count $argv) -gt 0
    set -l highlight (set_color green)
    set -l normal (set_color normal)
    set -l hl_start ":s"
    set -l hl_end ":e"
    set -l equivalent_space "    "

    set -l option $argv[1]
    switch $option
      case -h --help help
        echo $usage

      case -a --available
        set installed (basename -a (theme.util.get.themes) | tr " " "\n")
        set online (omf.remote --themes | tr " " "\n"); or return 1

        for theme in $online
          if contains $theme $installed
            echo "$hl_start$theme$hl_end"
          else
            echo "$theme"
          end
        end | column -c (tput cols) | \
              sed -e "s/$hl_start/$highlight/g" \
                  -e "s/$hl_end/$normal$equivalent_space/g"

      case -d --download-all
        set installed (basename -a (theme.util.get.themes) | tr " " "\n")
        set online (omf.remote --themes | tr " " "\n"); or return 1
        for theme in $online
          if not contains $theme $installed
            echo "installing $theme..."
            omf.packages.install --theme $theme
          end
        end

      case -l --list
        set -l regex "[[:<:]]($fish_theme)[[:>:]]"
        if test (uname) != "Darwin"
          set regex "\b($fish_theme)\b"
        end
        set -l color green
        for installed in (basename -a (theme.util.get.themes) | tr " " "\n")
          if test "$installed" = "$fish_theme"
            echo "$hl_start$installed*$hl_end"
          else
            echo "$installed"
          end
        end | column -c (tput cols) | \
              sed -e "s/$hl_start/$highlight/g" \
                  -e "s/$hl_end/$normal$equivalent_space/g"
        set_color normal

      case -r --restore
        if test -n "$__fish_theme_last"
          if test "$__fish_theme_last" != "$fish_theme"
            theme.util.remove.current

            set fish_theme "$__fish_theme_last"
            . "$fish_path/oh-my-fish.fish"
          end
        end

      case \*
        if test -z "$option"
          echo $usage

        else if test -d "$fish_custom/themes/$option" -o \
                     -d "$fish_path/themes/$option"

          theme.util.remove.current

          set -g fish_theme $option
          . $fish_path/oh-my-fish.fish

        else
          echo (set_color f00)"`$option` is not a theme."(set_color normal) ^&2
          theme --list
          return 1
        end
    end
  else
    theme --list
  end
end
