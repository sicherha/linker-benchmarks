#!/usr/bin/env python3

import gettext
import locale
import matplotlib.pyplot
import pandas
import re
import seaborn
import subprocess
import sys
import time

subprocess.run(["find", "locale", "-iname", "*.po", "-exec", "msgfmt.py", "{}", "+"])
try:
    _ = gettext.translation("evaluate", "locale").gettext
except FileNotFoundError:
    _ = lambda x: x
locale.setlocale(locale.LC_ALL, "")

TIMEDELTA_REGEX = re.compile(r"^([0-9]+):([0-9]+)\.([0-9]+)$")

ELAPSED_TIME_REGEX = re.compile(
    r"^\s*Elapsed \(wall clock\) time \(h:mm:ss or m:ss\):\s+(\S+)$"
)
RSS_REGEX = re.compile(r"^\s*Maximum resident set size \(kbytes\):\s+(\S+)$")

SIZE_REGEX = re.compile(r"^\s*Size:\s+([0-9]+)\s+")

LINKERS = ["bfd", "gold", "lld", "mold"]

PROJECT_DESCRIPTIONS = {
    "clang": "Clang $version",
    "firefox": "Firefox $version libxul",
    "qt": "Qt WebEngine $version",
}
for project, description in PROJECT_DESCRIPTIONS.items():
    with open(f"{project}/version") as version_file:
        for version in version_file:
            PROJECT_DESCRIPTIONS[project] = description.replace("$version", version)
            break


PROGRAM = _("Program")
LINK_TIME = _("Link time (s)")
RSS_SIZE = _("RSS (GiB)")

seaborn.set_theme(style="whitegrid")


def to_milliseconds(timedelta: str) -> int:
    match = TIMEDELTA_REGEX.fullmatch(timedelta)
    if not match:
        raise Exception(f"Invalid timedelta: {timedelta}")
    minutes = int(match.group(1))
    seconds = int(match.group(2))
    hundredths = int(match.group(3))
    assert hundredths < 100
    return ((minutes * 60 + seconds) * 100 + hundredths) * 10


def get_execution_stats(filename: str, skip_first: int = 0) -> dict:
    times = []
    rss = []
    with open(filename) as file:
        for line in file:
            line = line.rstrip()
            if match := ELAPSED_TIME_REGEX.fullmatch(line):
                times.append(to_milliseconds(match.group(1)))
            elif match := RSS_REGEX.fullmatch(line):
                rss.append(int(match.group(1)))
    assert len(times) == len(rss)
    return {"times": times[skip_first:], "rss": rss[skip_first:]}


def get_binary_size(filename: str) -> int:
    with open(filename) as file:
        for line in file:
            if match := SIZE_REGEX.match(line):
                return int(match.group(1))
    raise Exception(f"Could not parse binary size from {filename}")


def get_linker_version(filename: str) -> str:
    with open(filename) as file:
        return file.read().rstrip()


def add_bar_labels(grid: seaborn.FacetGrid, labels: list[str], **kwargs):
    i = 0
    for container in grid.ax.containers:
        grid.ax.bar_label(
            container, labels=labels[i : i + len(container.get_children())], **kwargs
        )
        i += len(container.get_children())


def draw_graph(metric: str, data: pandas.DataFrame, palette: str, ci=95, **kwargs):
    seaborn.set_palette(seaborn.color_palette(palette, len(LINKERS)))
    grid = seaborn.catplot(
        x=PROGRAM,
        y=metric,
        hue="Linker",
        data=data,
        ci=ci,
        kind="bar",
        aspect=1.1,
    )
    locale.setlocale(locale.LC_ALL, "")
    labels = [
        locale.format_string("%.01f", value)
        for value in data.groupby(by=["Linker", PROGRAM]).mean()[metric]
    ]
    add_bar_labels(grid, labels, **kwargs)
    grid.ax.set(xlabel=None)
    grid.despine(left=True)


link_times = pandas.DataFrame()
rss_sizes = pandas.DataFrame()

for project in ["clang", "firefox", "qt"]:
    min_binary_size = sys.maxsize
    for linker in LINKERS:
        binary_size = get_binary_size(f"results/{project}-size-{linker}.txt")
        if binary_size < min_binary_size:
            min_binary_size = binary_size
    project_description = locale.format_string(
        "%s\n(%.01f GiB)",
        (PROJECT_DESCRIPTIONS[project], min_binary_size / 1024 / 1024 / 1024),
    )

    for linker in LINKERS:
        stats = get_execution_stats(f"results/{project}-time-{linker}.txt", 1)
        times = stats["times"]
        rss = stats["rss"]
        if linker == "mold":
            rss = get_execution_stats(f"results/{project}-time-{linker}-nofork.txt")[
                "rss"
            ]
        linker_version = get_linker_version(f"results/version-{linker}.txt")
        link_times = pandas.concat(
            [
                link_times,
                pandas.DataFrame(
                    {
                        PROGRAM: project_description,
                        "Linker": f"{linker} {linker_version}",
                        LINK_TIME: [time / 1000 for time in times],
                    }
                ),
            ]
        )
        rss_sizes = pandas.concat(
            [
                rss_sizes,
                pandas.DataFrame(
                    {
                        PROGRAM: project_description,
                        "Linker": f"{linker} {linker_version}",
                        RSS_SIZE: [size / 1024 / 1024 for size in rss],
                    }
                ),
            ]
        )

draw_graph(LINK_TIME, link_times, "magma", padding=5)
matplotlib.pyplot.savefig("link-times.svg")

draw_graph(RSS_SIZE, rss_sizes, "viridis", ci=None)
matplotlib.pyplot.savefig("rss.svg")
