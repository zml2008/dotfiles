#!/usr/bin/env python3  
# -*- coding: utf-8 -*-
import subprocess
import os

from i3pystatus import Status, IntervalModule
from i3pystatus.mail import maildir


class NoLockIndicator(IntervalModule):
    interval = 2

    settings = (
            ('path', 'The path of the file to toggle for nolock status. By default ~/.nolock'),
            ('status', 'Dictionary mapping locked and unlocked to messages'),
            ('status_color', 'Dictionary mapping locked and unlocked to colors')
            )

    path = '~/.nolock'
    status = {
            'locked': '☕',
            'unlocked': 'O'
            }
    status_color = {
            'locked': '#ff0000'
            }

    on_leftclick = 'toggle_state'

    def run(self):
        pathname = os.path.abspath(os.path.expanduser(self.path))
        if os.path.exists(pathname):
            state = "locked"
        else:
            state = "unlocked"

        self.output = {
                'full_text': self.status[state]
                }

        if state in self.status_color:
            self.output['color'] = self.status_color[state]

    def toggle_state(self):
        pathname = os.path.abspath(os.path.expanduser(self.path))
        if os.path.exists(pathname):
            os.unlink(pathname)
        else:
            with open(pathname, 'w'):
                pass


status = Status(standalone=True)

status.register("clock", format=[("UTC: %m-%d %H:%M:%S", "UTC")])
status.register("clock", format="%Y-%m-%d %H:%M:%S")

status.register("load", format="{avg1} {avg5} {avg15}", critical_limit=4)
status.register("temp")

status.register("battery", not_present_text="", alert=False)

mail_root = os.path.join(os.getenv("HOME"), "mail")
if os.path.isdir(mail_root):
    for acc in os.listdir(mail_root):
        if os.path.isdir(os.path.join(mail_root, acc, "INBOX")):
            status.register("mail", backends=[maildir.MaildirMail(directory=os.path.join(mail_root, acc, "INBOX"))], format=acc + ": {unread}", format_plural=acc + ": {unread}")

status.register("now_playing", format="{status} {title} - {artist}")
status.register("pulseaudio", format="{muted}: {db}dB", unmuted="♪")

status.register(NoLockIndicator())

status.run()
