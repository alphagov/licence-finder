Adding new licences to licence-finder
=====================================

For most of licence-finder's history, we haven't added any new licences. So the
process for adding them is not very mature.

In [a1ad3ff](https://github.com/alphagov/licence-finder/pull/1006/commits/a1ad3ff3)
we added [a rake task](https://github.com/alphagov/licence-finder/blob/a1ad3ff3/lib/tasks/data_import.rake#L29-L72)
to specifically add a licence for "costs lawyers practicising certificate"
(which was requested by BEIS).

This approach should work well enough if we occasionally need to add one or two
new licences to the tool. However, we should attempt to persuade the departments
requesting these changes to batch them up as much as possible, to reduce the
amount of toil we have to do.

There's no pattern for adding batches of licences yet. We'll have to invent
something when we need it.
