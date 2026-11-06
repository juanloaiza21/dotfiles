#!/usr/bin/env python3
"""Waybar module: upcoming Google Calendar events from a (secret) iCal URL.
URL file: ~/.config/gcal/ics-url  (chmod 600, NOT part of the dotfiles repo)
Test override: ICS_FILE=/path/to/file.ics
Output: waybar JSON {text, tooltip, class}."""
import html, json, os, re, sys, time, urllib.request
from datetime import date, datetime, timedelta, timezone
from zoneinfo import ZoneInfo

HOME = os.path.expanduser("~")
URL_FILE = f"{HOME}/.config/gcal/ics-url"
CACHE = f"{os.environ.get('XDG_CACHE_HOME', HOME + '/.cache')}/waybar-gcal.ics"
LOOKAHEAD_DAYS, REFRESH_S = 7, 600
LOCAL = datetime.now().astimezone().tzinfo
WD = ["MO", "TU", "WE", "TH", "FR", "SA", "SU"]

def out(text, tooltip="", cls=""):
    print(json.dumps({"text": text, "tooltip": tooltip, "class": cls})); sys.exit(0)

def load_ics():
    if os.environ.get("ICS_FILE"):
        return open(os.environ["ICS_FILE"], encoding="utf-8").read()
    if not os.path.exists(URL_FILE):
        out("󰃭 connect calendar", f"Put your Google Calendar secret iCal address in\n{URL_FILE}", "disconnected")
    fresh = os.path.exists(CACHE) and time.time() - os.path.getmtime(CACHE) < REFRESH_S
    if not fresh:
        try:
            url = open(URL_FILE).read().strip()
            req = urllib.request.Request(url, headers={"User-Agent": "waybar-gcal"})
            data = urllib.request.urlopen(req, timeout=15).read().decode("utf-8")
            os.makedirs(os.path.dirname(CACHE), exist_ok=True)
            with open(CACHE, "w", encoding="utf-8") as f: f.write(data)
            os.chmod(CACHE, 0o600)
        except Exception as e:
            if not os.path.exists(CACHE): out("󰃭 offline", f"Could not fetch calendar: {e}", "disconnected")
    return open(CACHE, encoding="utf-8").read()

def unfold(raw):
    lines = []
    for l in raw.replace("\r\n", "\n").split("\n"):
        if l[:1] in (" ", "\t") and lines: lines[-1] += l[1:]
        else: lines.append(l)
    return lines

def parse_dt(val, params):
    """-> (datetime aware in local tz, is_all_day)"""
    if params.get("VALUE") == "DATE" or re.fullmatch(r"\d{8}", val):
        d = datetime.strptime(val[:8], "%Y%m%d"); return d.replace(tzinfo=LOCAL), True
    if val.endswith("Z"):
        return datetime.strptime(val, "%Y%m%dT%H%M%SZ").replace(tzinfo=timezone.utc).astimezone(LOCAL), False
    d = datetime.strptime(val, "%Y%m%dT%H%M%S")
    tz = LOCAL
    if "TZID" in params:
        try: tz = ZoneInfo(params["TZID"])
        except Exception: pass
    return d.replace(tzinfo=tz).astimezone(LOCAL), False

def parse_events(raw):
    events, cur = [], None
    for line in unfold(raw):
        if line == "BEGIN:VEVENT": cur = {}
        elif line == "END:VEVENT":
            if cur is not None and "DTSTART" in cur: events.append(cur)
            cur = None
        elif cur is not None and ":" in line:
            head, val = line.split(":", 1)
            name, *ps = head.split(";")
            params = dict(p.split("=", 1) for p in ps if "=" in p)
            name = name.upper()
            if name in ("EXDATE",): cur.setdefault("EXDATE", []).append((val, params))
            else: cur[name] = (val, params)
    return events

def expand(ev, start_w, end_w):
    """yield (start, end, all_day) occurrences overlapping [start_w, end_w]"""
    s, allday = parse_dt(*ev["DTSTART"])
    if "DTEND" in ev: e, _ = parse_dt(*ev["DTEND"])
    elif "DURATION" in ev: e = s + timedelta(hours=1)
    else: e = s + (timedelta(days=1) if allday else timedelta())
    dur = e - s
    ex = set()
    for v, p in ev.get("EXDATE", []):
        for one in v.split(","):
            try: ex.add(parse_dt(one, p)[0])
            except Exception: pass
    rr = ev.get("RRULE")
    if not rr:
        if e >= start_w and s <= end_w: yield s, e, allday
        return
    r = dict(kv.split("=", 1) for kv in rr[0].split(";") if "=" in kv)
    freq, interval = r.get("FREQ"), int(r.get("INTERVAL", 1))
    count = int(r["COUNT"]) if "COUNT" in r else None
    until = parse_dt(r["UNTIL"], {})[0] if "UNTIL" in r else None
    byday = [d[-2:] for d in r.get("BYDAY", "").split(",") if d]
    n, cursor, guard = 0, s, 0
    def emit(cs):
        nonlocal n
        n += 1
        if cs in ex: return None
        return cs
    while guard < 4000:
        guard += 1
        cands = [cursor]
        if freq == "WEEKLY" and byday:
            monday = cursor - timedelta(days=cursor.weekday())
            cands = sorted(monday + timedelta(days=WD.index(d)) for d in byday if d in WD)
            cands = [c.replace(hour=s.hour, minute=s.minute, second=s.second) for c in cands]
        for c in cands:
            if c < s: continue
            if until and c > until: return
            if count is not None and n >= count: return
            if c > end_w: return
            got = emit(c)
            if got is not None and got + dur >= start_w: yield got, got + dur, allday
        if freq == "DAILY": cursor += timedelta(days=interval)
        elif freq == "WEEKLY": cursor += timedelta(weeks=interval)
        elif freq == "MONTHLY":
            m = cursor.month - 1 + interval
            try: cursor = cursor.replace(year=cursor.year + m // 12, month=m % 12 + 1)
            except ValueError: cursor = cursor.replace(year=cursor.year + m // 12, month=m % 12 + 1, day=28)
        elif freq == "YEARLY":
            try: cursor = cursor.replace(year=cursor.year + interval)
            except ValueError: cursor = cursor.replace(year=cursor.year + interval, day=28)
        else: return

def clean(t): return re.sub(r"\\([,;nN\\])", lambda m: "\n" if m.group(1) in "nN" else m.group(1), t)

def tooltip_for(upcoming, now):
    lines, day = [], None
    for s2, e2, ad2, t2 in upcoming:
        d = s2.date()
        if d != day:
            day = d
            label = "Today" if d == now.date() else ("Tomorrow" if d == (now + timedelta(days=1)).date() else s2.strftime("%A %d"))
            lines.append(f"<b>{label}</b>")
        lines.append(f"  {'all day' if ad2 else s2.strftime('%H:%M') + '–' + e2.strftime('%H:%M')}  {html.escape(t2, quote=False)}")
    return "\n".join(lines)

def main():
    raw = load_ics()
    now = datetime.now().astimezone()
    start_w = now.replace(hour=0, minute=0, second=0, microsecond=0)
    end_w = start_w + timedelta(days=LOOKAHEAD_DAYS)
    evs = parse_events(raw)
    overrides = {(e["UID"][0], parse_dt(*e["RECURRENCE-ID"])[0]) for e in evs if "RECURRENCE-ID" in e and "UID" in e}
    occ = []
    for ev in evs:
        title = clean(ev.get("SUMMARY", ("(no title)", {}))[0])
        if ev.get("STATUS", ("", {}))[0] == "CANCELLED": continue
        for s, e, ad in expand(ev, start_w, end_w):
            if "RECURRENCE-ID" not in ev and "UID" in ev and (ev["UID"][0], s) in overrides: continue
            occ.append((s, e, ad, title))
    occ.sort(key=lambda o: (o[0], o[3]))
    upcoming = [o for o in occ if o[1] > now or (o[2] and o[0].date() == now.date())]
    if not upcoming: out("󰃭 no events", "Nothing in the next 7 days", "")
    # headline = next timed event TODAY (not yet ended); nothing else leaks in
    today = [o for o in upcoming if o[0].date() == now.date() or (not o[2] and o[0] <= now < o[1])]
    tooltip_lines = tooltip_for(upcoming, now)
    head = next((o for o in today if not o[2] and o[1] > now), None)
    if head is None:
        left = [o for o in today if o[2]]
        out("󰃭 " + ("all day: " + (re.sub(r"\s*\([^)]*\)\s*$", "", left[0][3]) or left[0][3])[:24] if left else "free today"), tooltip_lines, "")
    s, e, ad, title = head
    if s <= now: when = "now"
    else:
        m = int((s - now).total_seconds() // 60)
        when = f"in {m}m" if m < 60 else f"in {m//60}h {m%60:02d}m" if m % 60 else f"in {m//60}h"
    base = re.sub(r"\s*\([^)]*\)\s*$", "", title) or title   # drop trailing "(calendar name)"
    short = base if len(base) <= 28 else base[:27] + "…"
    cls = "soon" if (not ad and 0 <= (s - now).total_seconds() <= 1800) else ("now" if (not ad and s <= now < e) else "")
    out(f"󰃭 {html.escape(short, quote=False)} · {when} ({s.strftime('%H:%M')})", tooltip_lines, cls)

main()
