from typing import List

from libqtile import qtile
from libqtile import bar, layout, widget, hook, extension
from libqtile.config import Click, Drag, Group, Key, Match, Screen, KeyChord
from libqtile.lazy import lazy
from libqtile.command import lazy
from libqtile.utils import guess_terminal

import os, subprocess, datetime, psutil, logging

logging.basicConfig(filename="logs.log", level=logging.DEBUG)

mod = "mod4"
terminal = "alacritty"
theme_style = {
    "vagabond":{
        "color": "#bc5c64",
        "background_img": "03.jpg",
        "bar_background": "#3a3b3b",
        "inactive": "#939393",
    },
    "noridic_type":{
        "color": "#00acce",
        "background_img": "02.jpg",
        "bar_background": "#1c1f24",
        "inactive": "#404040",
    }
}
current_theme = "vagabond"
current_color = theme_style[current_theme]["color"]
current_bg = theme_style[current_theme]["background_img"]
current_bar_bg = theme_style[current_theme]["bar_background"]
current_inactive=theme_style[current_theme]["inactive"]

keys = [
    # A list of available commands that can be bound to keys can be found
    # at https://docs.qtile.org/en/latest/manual/config/lazy.html
    # Switch between windows
    Key([mod], "h", lazy.layout.left(), desc="Move focus to left"),
    Key([mod], "l", lazy.layout.right(), desc="Move focus to right"),
    Key([mod], "j", lazy.layout.down(), desc="Move focus down"),
    Key([mod], "k", lazy.layout.up(), desc="Move focus up"),
    Key([mod], "space", lazy.layout.next(), desc="Move window focus to other window"),
    # Move windows between left/right columns or move up/down in current stack.
    # Moving out of range in Columns layout will create new column.
    Key([mod, "shift"], "h", lazy.layout.shuffle_left(), desc="Move window to the left"),
    Key([mod, "shift"], "l", lazy.layout.shuffle_right(), desc="Move window to the right"),
    Key([mod, "shift"], "j", lazy.layout.shuffle_down(), desc="Move window down"),
    Key([mod, "shift"], "k", lazy.layout.shuffle_up(), desc="Move window up"),
    # Grow windows. If current window is on the edge of screen and direction
    # will be to screen edge - window would shrink.
    Key([mod, "control"], "h", lazy.layout.grow_left(), desc="Grow window to the left"),
    Key([mod, "control"], "l", lazy.layout.grow_right(), desc="Grow window to the right"),
    Key([mod, "control"], "j", lazy.layout.grow_down(), desc="Grow window down"),
    Key([mod, "control"], "k", lazy.layout.grow_up(), desc="Grow window up"),
    Key([mod], "n", lazy.layout.normalize(), desc="Reset all window sizes"),
    # Toggle between split and unsplit sides of stack.
    # Split = all windows displayed
    # Unsplit = 1 window displayed, like Max layout, but still with
    # multiple stack panes
    Key(
        [mod],
        "Return",
        lazy.layout.toggle_split(),
        desc="Toggle between split and unsplit sides of stack",
    ),
    Key([mod, "shift"], "Return", lazy.spawn(terminal + " -e fish"), desc="Launch terminal"),
    # Toggle between different layouts as defined below
    Key([mod], "Tab", lazy.next_layout(), desc="Toggle between layouts"),
    Key([mod, "shift"], "c", lazy.window.kill(), desc="Kill focused window"),
    Key([mod, "control"], "r", lazy.reload_config(), desc="Reload the config"),
    Key([mod, "control"], "q", lazy.shutdown(), desc="Shutdown Qtile"),
    
    # My keybinds
    Key([mod], "p", lazy.spawn("dmenu_run"), desc="run dmenu"),
    Key([mod, "shift"], "b", lazy.spawn("brave"), desc="Launch brave browser"),
    Key([mod], "e", lazy.spawn("emacs"), desc="Launch (doom) emacs"),
    Key([mod], "c", lazy.spawn("emacs ~/.config/qtile/config.py"), desc="Launch dmenu script for launching config files"),
    Key([mod], "s", lazy.spawn("spotify"), desc="Launch spotify"),
]

# LOADING workspaces names and not using 1, 2, 3, ..., 9
groups_name = "WWW DEV CHAT DOC GAME SYS MUS REC MIC".split()
groups = [Group(name, layout='tile') for name in groups_name]
for i, name in enumerate(groups_name, 1):
    idx = str(i)
    keys += [
        Key([mod], idx, lazy.group[name].toscreen()),
        Key([mod, "shift"], idx, lazy.window.togroup(name)),
    ]


layouts = [
    layout.Columns(border_focus_stack=["#d75f5f", "#8f3d3d"], border_width=4),
    layout.Tile(margin=10, border_focus=current_color, ratio=0.5, border_width=2),
    layout.MonadTall(border_focus=current_color, margin=10, ratio=0.5),
]

widget_defaults = dict(
    font="sans",
    fontsize=12,
    padding=3,
)
extension_defaults = widget_defaults.copy()

screens = [

    Screen(
        top=bar.Bar(
            [
                widget.GroupBox(
                    highlight_color="#2a2b2b",
                    highlight_method="line",
                    this_current_screen_border=current_color,
                    other_current_screen_border=current_color,
                    this_screen_border="#2a2b2b",
                    inactive=current_inactive,
                ),
                widget.Prompt(),
                widget.WindowName(foreground=current_color),
                widget.Chord(
                    chords_colors={
                        "launch": ("#ff0000", "#ffffff"),
                    },
                    name_transform=lambda name: name.upper(),
                ),
                widget.CheckUpdates(
                    update_interval = 20,
                    distro="Arch_checkupdates",
                    display_format="Updates: {updates}",
                    no_update_string="Updates: 0",
                    colour_have_updates="#63d847",
                    colour_no_updates="#d84753",
                    mouse_callbacks={"Button1": lazy.spawn(terminal + " -e sudo pacman -Syu")}
                ),
                widget.Sep(),
                widget.Clock(format="%A, %B %d  [ %H:%M ]"),
                widget.Sep(),
                widget.Systray(),
                widget.Sep(),
                widget.TextBox(text="Shutdown", mouse_callbacks={"Button1": lazy.spawn("shutdown now")}),
            ],
            30,
            background=current_bar_bg
        ),
    ),
    Screen(
        top=bar.Bar(
            [
                widget.GroupBox(
                    highlight_color="#2a2b2b",
                    highlight_method="line",
                    this_current_screen_border=current_color,
                    other_current_screen_border=current_color,
                    this_screen_border="#2a2b2b",
                    inactive=current_inactive,
                ),
                widget.Prompt(),
                widget.WindowName(foreground=current_color),
                widget.Chord(
                    chords_colors={
                        "launch": ("#ff0000", "#ffffff"),
                    },
                    name_transform=lambda name: name.upper(),
                ),
            ],
            30,
            background=current_bar_bg
        ),
    ),
]

# Drag floating layouts.
mouse = [
    Drag([mod], "Button1", lazy.window.set_position_floating(), start=lazy.window.get_position()),
    Drag([mod], "Button3", lazy.window.set_size_floating(), start=lazy.window.get_size()),
    Click([mod], "Button2", lazy.window.bring_to_front()),
]

dgroups_key_binder = None
dgroups_app_rules = []  # type: List
follow_mouse_focus = True
bring_front_click = False
cursor_warp = False
floating_layout = layout.Floating(
    float_rules=[
        # Run the utility of `xprop` to see the wm class and name of an X client.
        *layout.Floating.default_float_rules,
        Match(wm_class="confirmreset"),  # gitk
        Match(wm_class="makebranch"),  # gitk
        Match(wm_class="maketag"),  # gitk
        Match(wm_class="ssh-askpass"),  # ssh-askpass
        Match(title="branchdialog"),  # gitk
        Match(title="pinentry"),  # GPG key password entry
    ]
)
auto_fullscreen = True
focus_on_window_activation = "smart"
reconfigure_screens = True

# If things like steam games want to auto-minimize themselves when losing
# focus, should we respect this or not?
auto_minimize = True


# APP RULES TO OPEN ON SPECIFIC GROUP
app_rules = {
    "Discord": "CHAT",
    "EasyEffects": "MIC",
    "Steam": "GAME",
    "raot": "GAME",
    "emacs@arch": "DEV",
}

@hook.subscribe.client_new
def client_rules(win):
    try:
        win.togroup(app_rules[win.name])
    except KeyError as e:
        logging.debug(e)

## AutoStartup
@hook.subscribe.startup
def autostartup():
    subprocess.call([os.path.expanduser('~/.config/qtile/autostart.sh')])


# XXX: Gasp! We're lying here. In fact, nobody really uses or cares about this
# string besides java UI toolkits; you can see several discussions on the
# mailing lists, GitHub issues, and other WM documentation that suggest setting
# this string if your java app doesn't work correctly. We may as well just lie
# and say that we're a working one by default.
#
# We choose LG3D to maximize irony: it is a 3D non-reparenting WM written in
# java that happens to be on java's whitelist.
wmname = "LG3D"

