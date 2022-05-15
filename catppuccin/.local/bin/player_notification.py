#!/usr/bin/env python3

import os
import gi
import requests

gi.require_version("Playerctl", "2.0")
from gi.repository import Playerctl, GLib

player = Playerctl.Player()
manager = Playerctl.PlayerManager()


def notify(player):
    metadata = player.props.metadata
    keys = metadata.keys()
    if "xesam:artist" in keys and "xesam:title" in keys:
        artist = metadata["xesam:artist"][0]
        title = metadata["xesam:title"]
        album = metadata["xesam:album"]
        download_dir = "/tmp/"
        try:
            art_url = metadata["mpris:artUrl"]
            art_prefix = art_url.split(":")[0]
            art_filepath = ""
            if art_prefix == "file":
                art_filepath = art_url
            else:
                art_filename = art_url.split("/")[-1]
                art_filepath = download_dir + art_filename
                if not os.path.isfile(art_filepath):
                    art_data = requests.get(art_url).content
                    with open(art_filepath, "wb") as handler:
                        handler.write(art_data)
            title = '"{}"'.format(title)
            artist_album = artist + " - " + album
            artist_album = '"{}"'.format(artist_album)
            print(art_filepath)
            os.system(f"notify-send {title} {artist_album} --icon {art_filepath}")
        except Exception:
            pass


def on_metadata(player, metadata):
    notify(player)


def on_play(player, status):
    notify(player)


def init_player(name):
    player = Playerctl.Player.new_from_name(name)
    player.connect("playback-status::playing", on_play)
    player.connect("metadata", on_metadata)
    manager.manage_player(player)
    notify(player)


def on_name_appeared(manager, name):
    init_player(name)


manager.connect("name-appeared", on_name_appeared)

for name in manager.props.player_names:
    init_player(name)

main = GLib.MainLoop()
main.run()
