fixed = FixedTimeZone("UTC+01:00")
est = FixedTimeZone("EST", -18000)
warsaw = resolve("Europe/Warsaw", tzdata["europe"]...)
apia = resolve("Pacific/Apia", tzdata["australasia"]...)
dt = DateTime(1942,12,25,1,23,45)

buffer = IOBuffer()

# TimeZones as a string
@test string(fixed) == "UTC+01:00"
@test string(fixed.offset) == "+01:00"
@test string(est) == "EST"
@test string(est.offset) == "-05:00"
@test string(warsaw) == "Europe/Warsaw"
@test string(apia) == "Pacific/Apia"

showcompact(buffer, fixed)
@test takebuf_string(buffer) == "UTC+01:00"
showcompact(buffer, est)
@test takebuf_string(buffer) == "EST"
showcompact(buffer, warsaw)
@test takebuf_string(buffer) == "Europe/Warsaw"
showcompact(buffer, apia)
@test takebuf_string(buffer) == "Pacific/Apia"

show(buffer, fixed)
@test takebuf_string(buffer) == "UTC+01:00"
show(buffer, est)
@test takebuf_string(buffer) == "EST (UTC-5)"
show(buffer, warsaw)
@test takebuf_string(buffer) == "Europe/Warsaw (UTC+1/UTC+2)"
show(buffer, apia)
@test takebuf_string(buffer) == "Pacific/Apia (UTC+13/UTC+14)"


# UTC and GMT are special cases
show(buffer, FixedTimeZone("UTC"))
@test takebuf_string(buffer) == "UTC"
show(buffer, FixedTimeZone("GMT", 0))
@test takebuf_string(buffer) == "GMT"
show(buffer, FixedTimeZone("FOO", 0))
@test takebuf_string(buffer) == "FOO (UTC+0)"

# ZonedDateTime as a string
@test string(ZonedDateTime(dt, warsaw)) == "1942-12-25T01:23:45+01:00"

show(buffer, ZonedDateTime(dt, warsaw))
@test takebuf_string(buffer) == "1942-12-25T01:23:45+01:00"

# ZonedDateTime parsing.
# Note: uses compiled time zone information. If these tests are failing try to rebuild
# the TimeZones package.
@test ZonedDateTime("1942-12-25T01:23:45.0+01:00") == ZonedDateTime(dt, fixed)
@test ZonedDateTime("1942-12-25T01:23:45+0100", "yyyy-mm-ddTHH:MM:SSzzz") == ZonedDateTime(dt, fixed)
@test ZonedDateTime("1942-12-25T01:23:45 Europe/Warsaw", "yyyy-mm-ddTHH:MM:SS ZZZ") == ZonedDateTime(dt, warsaw)

# Note: CET here represents the FixedTimeZone used in Europe/Warsaw and not the
# VariableTimeZone CET.
@test_throws ArgumentError ZonedDateTime("1942-12-25T01:23:45 CET", "yyyy-mm-ddTHH:MM:SS ZZZ")

# Creating a ZonedDateTime requires a TimeZone to be present.
@test_throws ArgumentError ZonedDateTime("1942-12-25T01:23:45", "yyyy-mm-ddTHH:MM:SSzzz")


# ZonedDateTime formatting
f = "yyyy/m/d H:M:S ZZZ"
@test Dates.format(ZonedDateTime(dt, fixed), f) == "1942/12/25 1:23:45 UTC+01:00"
@test Dates.format(ZonedDateTime(dt, warsaw), f) == "1942/12/25 1:23:45 CET"

f = "yyyy/m/d H:M:S zzz"
@test Dates.format(ZonedDateTime(dt, fixed), f) == "1942/12/25 1:23:45 +01:00"
@test Dates.format(ZonedDateTime(dt, warsaw), f) == "1942/12/25 1:23:45 +01:00"


# The "Z" slot displays the time zone abbreviation for VariableTimeZones. It is fine to use
# the abbreviation for display purposes but not fine for parsing. This means that we
# currently cannot parse all strings produced by format.
f = Dates.DateFormat("yyyy-mm-ddTHH:MM:SS ZZZ")
@test_throws ArgumentError Dates.parse(Dates.format(ZonedDateTime(dt, warsaw), f), f)
