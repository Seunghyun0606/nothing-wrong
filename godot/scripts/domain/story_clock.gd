## The story's clock. Times are written "Tue 09:10" (or "next Mon 07:40" for the week
## after release week) and counted in minutes from Monday 00:00 of release week.
extends RefCounted

const DAYS := ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
const DAY_NAMES := ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
const WEEK := 7 * 1440


## Minutes for "Tue 09:10", or -1 when the text is not a story time.
static func parse(text: String) -> int:
	var parts := text.strip_edges().split(" ")
	var week := 0
	if parts.size() == 3 and parts[0] == "next":
		week = WEEK
		parts = parts.slice(1)
	if parts.size() != 2 or not DAYS.has(parts[0]):
		return -1
	var hm := parts[1].split(":")
	if hm.size() != 2:
		return -1
	return week + DAYS.find(parts[0]) * 1440 + int(hm[0]) * 60 + int(hm[1])


static func day_of(minutes: int) -> String:
	return DAYS[(minutes / 1440) % 7]


static func day_name(minutes: int) -> String:
	return DAY_NAMES[(minutes / 1440) % 7]


static func hhmm(minutes: int) -> String:
	return "%02d:%02d" % [(minutes % 1440) / 60, minutes % 60]


## Whole hours from `now` until the next time it is `deadline`.
static func hours_until(now: int, deadline: int) -> int:
	var at := deadline
	while at <= now:
		at += WEEK
	return int(ceil((at - now) / 60.0))
