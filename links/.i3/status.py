#!/usr/bin/env python3  
# -*- coding: utf-8 -*-
import subprocess
import os

from i3pystatus import Status, IntervalModule
from i3pystatus.mail import maildir

try:
    import lifxlan
except ImportError:
    lifxlan = False


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
            'unlocked': '⚪'
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

from concurrent.futures import ThreadPoolExecutor
import concurrent.futures

class LightController(IntervalModule):
    interval = 10
    reset_every = 3
    prefix = "💡"

    settings = (
            ('group_name', 'The name of the group of lights to toggle with this switch'),
            ('hide_on_no_lights', 'If true, hide this status item if no lights are on the local network. Otherwise, show an error'),
            ('brightness_increment', 'The portion of brightness to change per single scroll wheel click, from 0 to 1')
            )

    group_name = "Bedroom"
    hide_on_no_lights=True
    brightness_increment = .05

    on_leftclick='toggle_lights'
    on_upscroll='brightness_up'
    on_downscroll='brightness_down'

    def update_all_lights(self, func_get, func_apply):
        lights = self.__lights.get_lights()
        futures = []
        for light in lights:
            fut = self.executor.submit(func_get, light)
            fut._light = light
            futures.append(fut)
        done, not_done =  concurrent.futures.wait(futures)
        futures = []
        for fut in done:
            futures.append(self.executor.submit(func_apply, fut.result(), fut._light))
        concurrent.futures.wait(futures)
        #for light in self.__lights.get_lights():
        #    data = func_get(light)
        #    func_apply(data, light)


    def _light_toggle_internal(self, existing_power, light):
        if existing_power == 0:
            light.set_power(True, rapid=True)
        else:
            light.set_power(False, rapid=True)

    def toggle_lights(self):
        self.update_all_lights(lambda l: l.get_power(), self._light_toggle_internal)

    def _adjust_brightness_internal(self, light, existing_state, increment):
        h, s, b, k = existing_state
        b = min(65535, max(0, b + (increment * 65535)))
        light.set_color([h, s, b, k])

    def brightness_up(self):
        self.update_all_lights(lambda l: l.get_color(), lambda d, l: self._adjust_brightness_internal(l, d, self.brightness_increment))

    def brightness_down(self):
        self.update_all_lights(lambda l: l.get_color(), lambda d, l: self._adjust_brightness_internal(l, d, self.brightness_increment * -1))

    def init(self):
        self.__lights = lifxlan.LifxLAN()
        num_lights = len(self.__lights.get_lights())
        self.reset_counter = 0
        self.executor = ThreadPoolExecutor()

    def run(self):
        if not lifxlan:
            raise Error("Module lifxlan is required!")
        if len(self.__lights.lights) == 0 and self.hide_on_no_lights:
            self.output = {
                    "full_text": ""
                    }
            return
        if self.reset_counter >= self.reset_every:
            self.__lights.discover_devices()
            self.reset_counter = 0
        else:
            self.reset_counter += 1

        light_brightnesses = {l.get_color()[2] / 65535 * 100 for l in self.__lights.get_lights()}

        if sum(light_brightnesses) > 0:
            self.output = {
                    "full_text": "{prefix} {brightnesses}".format(prefix = self.prefix, brightnesses=" ".join(["{:.0f}%".format(brightness) for brightness in light_brightnesses]))
                    }
        else:
            self.output = {
                    "full_text": self.prefix
                    }


status = Status(standalone=True)

status.register("text", text="")
status.register("clock", format=[("UTC: %m-%d %H:%M:%S", "UTC")])
status.register("clock", format="⏰ %Y-%m-%d %H:%M:%S")

status.register("load", format="🔥 {avg1} {avg5} {avg15}", critical_limit=4)
status.register("temp", format="🌡️ {temp} °C")

status.register("battery", format="🔋 {status} {remaining}", not_present_text="", alert=False)

mail_root = os.path.join(os.getenv("HOME"), "mail")
if os.path.isdir(mail_root):
    for acc in os.listdir(mail_root):
        if os.path.isdir(os.path.join(mail_root, acc, "INBOX")):
            status.register("mail", backends=[maildir.MaildirMail(directory=os.path.join(mail_root, acc, "INBOX"))], format=" 📧 " + acc + ": {unread}", format_plural=acc + ": {unread}")

status.register("now_playing", format="{status} {title} - {artist}", status={
    "pause": "⏸️",
    "play": "▶️",
    "stop": "⏹️"
    })
status.register("pulseaudio", format="{muted}: {db}dB", unmuted="🔊", muted="🔈")

status.register(NoLockIndicator())
# status.register(LightController())

status.run()
