#!/usr/bin/env python3  
# -*- coding: utf-8 -*-
import subprocess
import os

from i3pystatus import Status
from i3pystatus.mail import maildir

status = Status(standalone=True)

status.register("clock", format=[("UTC: %m-%d %H:%M:%S", "UTC")])
status.register("clock", format="%Y-%m-%d %H:%M:%S")

status.register("load", format="{avg1} {avg5} {avg15}", critical_limit=4)

status.register("battery", not_present_text="", alert=False)

mail_root = os.path.join(os.getenv("HOME"), "mail")
for acc in os.listdir(mail_root):
    status.register("mail", backends=[maildir.MaildirMail(directory=os.path.join(mail_root, acc, "INBOX"))], format=acc + ": {unread}", format_plural=acc + ": {unread}")

status.register("now_playing", format="{status} {title} - {artist}")
status.register("pulseaudio", format="{muted}: {db}dB", unmuted="♪")

status.run()
