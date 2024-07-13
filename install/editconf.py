#!/usr/bin/env python3
#
# This tool edits configuration files during setup. It supports command-line
# arguments for setting values, comments, line folding, and different delimiters.

import sys
import re

def print_usage_and_exit():
    print("Usage: {} /etc/file.conf [-s] [-w] [-c <CHAR>] NAME=VAL [NAME=VAL ...]".format(sys.argv[0]))
    sys.exit(1)

def edit_config(filename, settings):
    delimiter = "="
    delimiter_re = r"\s*=\s*"
    comment_char = "#"
    folded_lines = False
    
    while settings and settings[0][0] == "-":
        opt = settings.pop(0)
        if opt == "-s":
            delimiter = " "
            delimiter_re = r"\s+"
        elif opt == "-w":
            folded_lines = True
        elif opt == "-c":
            comment_char = settings.pop(0)
        else:
            print("Invalid option: {}".format(opt))
            print_usage_and_exit()

    buf = []
    with open(filename, "r") as f:
        input_lines = f.readlines()

    while input_lines:
        line = input_lines.pop(0)
        if folded_lines and line and not line.startswith((comment_char, " ")):
            while input_lines and input_lines[0].startswith((" ", "\t")):
                line += input_lines.pop(0)

        matched = False
        for idx, setting in enumerate(settings):
            try:
                name, value = setting.split("=", 1)
            except ValueError:
                print("Invalid setting: {}".format(setting))
                continue

            pattern = r"(\s*)" + re.escape(comment_char) + r"?\s*" + re.escape(name) + delimiter_re + r"(.*?)\s*$"
            m = re.match(pattern, line, re.S)
            if m:
                indent, existing_comment, existing_value = m.groups()
                if existing_comment is None and existing_value == value:
                    if idx not in found_indices:
                        buf.append(line)
                        found_indices.add(idx)
                    matched = True
                    break
                buf.append(comment_char + line.rstrip("\n") + "\n")
                buf.append(indent + name + delimiter + value + "\n")
                found_indices.add(idx)
                matched = True
                break
        else:
            buf.append(line)

    for idx, setting in enumerate(settings):
        if idx not in found_indices:
            try:
                name, value = setting.split("=", 1)
            except ValueError:
                print("Invalid setting: {}".format(setting))
                continue
            buf.append(name + delimiter + value + "\n")

    with open(filename, "w") as f:
        f.write("".join(buf))

if __name__ == "__main__":
    if len(sys.argv) < 3 or sys.argv[2].startswith("-"):
        print_usage_and_exit()

    filename = sys.argv[1]
    settings = sys.argv[2:]

    edit_config(filename, settings)
