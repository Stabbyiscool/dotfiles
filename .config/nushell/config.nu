$env.PROMPT_COMMAND = {
  let user = (whoami)
  let host = (sys host | get hostname)
  let cwd  = ($env.PWD | path expand | str replace $env.HOME "~")

  $"(ansi white)($user)@($host)\n(ansi white)($cwd)(ansi reset)"
}

$env.PROMPT_INDICATOR = { $"(ansi white)$ (ansi reset)" }
$env.PROMPT_INDICATOR_VI_INSERT = { $"(ansi white)$ (ansi reset)" }
$env.PROMPT_INDICATOR_VI_NORMAL = { $"(ansi white)$ (ansi reset)" }

$env.config.color_config = {
    text: light_white
    shape_keyword: light_white
    shape_string: light_green
    shape_int: light_white
    shape_float: light_white
    shape_bool: light_yellow
    shape_operator: light_white
    shape_variable: light_white
    shape_flag: light_white
    shape_external: light_white
    shape_path: light_white
    shape_error: light_red
}
$env.config.show_banner = false
$env.PROMPT_COMMAND_RIGHT = { "" }
