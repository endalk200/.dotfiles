function tmx_bethel() {
  . $HOME/.shmux/launcher.sh

  local project_root="$HOME/src/projects/bethel/"
  local session_name="Bethel"

  cd $project_root

  if session_exists 2>/dev/null; then
    attach_to_session
  else
    echo "Creating a session"
    new_session
    rename_window "editor"

    new_window "terminal"
    split_horizontal 50%

    attach_to_session
  fi
}
