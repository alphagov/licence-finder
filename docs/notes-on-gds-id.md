Notes on `gds_id`
=================

The format of `gds_id` is interesting.

All the numbers in the databasse are of the form `\d{4}-[1-8]-\d'. Looks
suspiciously like it's formatted to be meaningful, right? But what does it mean?

It turns out the first part (the four digit bit before the dash) is a reference
to the "Local government services list (LGSL)":

[https://standards.esd.org.uk/?uri=list%2FenglishAndWelshServices][]

These are things like "Abnormal load notification (785)".

It looks like an old attempt at a register of services, but it hasn't been
maintained.  Even when the initial licence import happened, most of the licences
didn't have matching IDs in the LGSL.

From oral history, we have worked out that Dai made up prefixes for the licences
that weren't in the LGSL. He started at 9048 (for some reason), and then added
them sequentially all the way up to 9265.

New licences have been added starting from 9266.

Looking at the data in the database, the next digit after the dash is
always [1-8]. Most of the time it's 7. So that clearly has some meaning
too.

Again, from oral history we worked out that this is a region identifier:

1 - England
2 - Wales
3 - Scotland
4 - Northern Ireland
5 - England & Wales
6 - England & Wales & Scotland
7 - England & Wales & Scotland & Northern Ireland

(Aside: they've tried to cram four bits of information into a three bit
number here, so it's not possible to represent any combinations of two
nations [other than england and wales] or any combinations of three
countries [other than england, wales and scotland]. I guess this has
never come up in practice!?)

There's one service in the database which has 8 as the middle number.
This looks like a mistake.

The final digit (after the second dash) is there to make sure the IDs are
unique. So if there is more than one licence for the same service, targeting the
same nations we can still have unique IDs. For new licences this can always be
1, because we're not trying to group licences into services.

All of this is an interesting aside, but I'm pretty sure the fact that the ID is
meaningful is a huge red herring - there's nothing that parses it, so it may as
well just be a random UUID.

Software engineering lesson: don't imbue IDs with unnecessary meaning.  Use
something you can guarantee will be unique (like a uuid, or an incrementing
integer), and store the meaningful bits somewhere else on the record.
