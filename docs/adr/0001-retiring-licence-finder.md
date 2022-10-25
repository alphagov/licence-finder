# Retiring Licence Finder

Date: 2022-10-25

## Context

There is a legal requirement for 900 licences need to be created and updated on GOV.UK in the next few months.
Currently licences are a mainstream document type and the responsibility for maintaining them rests with GDS content designers in Mainstream Publisher.

Developers are also needed to add licences to the search results Licence Finder. Licences are added to this tool by updating a CSV file with the [licence information], e.g. title, description, link, licence identifier and running a rake task. Licences are tagged to [sectors] and [activities] by adding the mapping in a CSV file and running a rake task.

When rendered, licence pages resemble transaction pages, and have an "Apply now" button, if the licence can be applied for online, that takes the user to one of two places: a licence managed by a competent authority on an external website (e.g. TV Licence) or a postcode lookup that allows users to apply for the licence via their local authority. These local authority licences are managed in [Licensify].

Currently users can either find licences in the tool by narrowing down a list of "sectors" and "activities" or by performing a keyword search. Regardless of the approach, the list of results shown to the user is found by querying Elasticsearch with the unique licence identifier assigned to each licence.

If the licence is found in Elasticsearch a link to the licence is displayed to the user.

If the licence cannot be found in Elasticsearch only the title of the licence is displayed to the user. This title may not match the title in the content item.

### <a name="problems"></a> Problems with the current approach

Only a few licences can be considered "mainstream". Most are for a specialist activity. However as licences are managed in Mainstream Publisher only GDS content designers can create licence pages.  As Content Designers across government cannot create licence pages, they have taken to using other Whitehall formats to create licence content. This means that the licences created in non-mainstream formats do not have a licence identifier, and therefore do not appear in the Licence Finder results.

Another reason that not all licences appear in the Licence Finder results is because a developer is needed to updated the CSV files and run a rake task. A lack of clear processes means that this step is easy to miss. This has led to a situation where only approximately 60% of licences in Mainstream Publisher can be found using the Licence Finder.

It is possible for no results to be displayed to the user if they do a text search. A text box search only queries against the list of activities and sectors, not licence names. The search also doesn't match against a substring of sector or activity names, for example "restaurants" generates results, whereas "restaurant" does not.

Design-wise, the existing tool doesn't match any of the other design patterns on GOV.UK (e.g. smart-answers or finders), nor does it properly adopt the design system components.

Finally, the existing tool doesn't contain any extra analytics tracking on the search field or the [sectors] and [activities] list making it difficult to track user behaviour.

## Decision

This Licence Finder application will be retired and replaced with a specialist finder similar to the [Air Accidents Investigation Branch reports] finder. It is expected that the facets used to refine the results will be similar to the existing sectors activities used to refine results in the current tool.

Specialist finders find documents with a particular special document schema and are configured in [Specialist Publisher].
Specialist finders are an existing pattern on GOV.UK and follow the design system. In addition, they already contain analytics tracking for the facets, search box and results clicked.

Another benefit of this approach is that licences will still appear in the GOV.UK site search. Also, the default behaviour of finders is to show all of the available licences to the user when the finder loads, so the user will always see some results. Users will also be able to use the search box on the finder to do a text search on the licence title and description, something that the current tool does not allow.

A new licence document type will be created in Specialist Publisher. This new document type in Specialist Publisher will allow content designers to populate all of the existing fields for licence, as well as tagging the individual licence to sectors and activities via a user interface rather than a rake task. As Specialist Publisher generates tagging interfaces for specialist documents from the configuration files, a new tagging interface will not need to be built.

Specialist Publisher already allows publishers in other departments to create content by either being part of a named organisation, or by being assigned a custom permission. This will move the burden of managing licence content to the department that owns them.

### Other approaches considered

#### Updating the current tool

This approach was discarded for two main reasons. First as mentioned in the [problems] section, the current tool is not fit for purpose, and second there is the overhead of needing to update so many licences at once.

#### Creating a "search" finder in Search API

The same benefits of using a specialist finder to display the results also apply to a finder configured in [Search API], the finder follows the design system and has analytics out of the box. However the licence format would still need to be migrated to another publishing application so that they can be managed by other government departments as well.

Whitehall was considered as a potential home for the licence format. However migrating a format to Whitehall would be more complex than migrating to Specialist Publisher. Also, this would negatively affect the roadmap for the Publishing team which is doing extensive work to improve Whitehall.

An admin interface would also need to be created, which would manage the list of sectors and activities and their tagging to licences.

#### Creating an API of licence data

This approach was only in consideration during the investigation into linking directly to licences hosted by competent authorities on external websites. These external licences would still need to be tagged to sectors and activities, and an API was one approach to achieve this. This approach was dismissed as it would also have required a significant change to Whitehall to add the user interface for the API. This approach would also have been an outlier and not conform to any of the existing patterns for tagging content.

## Status

Accepted

## Consequences

The default rendering application for all specialist documents is hardcoded to [Government Frontend]. This will be changed to be configurable as all of the existing rendering code for licences, including the integration with Imminence for the postcode lookup is in the [Frontend application].

The existing licence documents will need to be migrated from Mainstream Publisher to Specialist Publisher and redirects added for the existing pages.

Some changes will need to be made to how licences are rendered in the Frontend application as, although the same information will still exist in the [content item], they will be contained in a different tags.

Any changes to the sector and activity facets in the specialist finder will still need to be implemented by developers as they are configured in JSON files, however the process for [updating facets] is well documented.


[Licensify]: https://github.com/alphagov/licensify
[licence information]: https://github.com/alphagov/licence-finder/blob/main/data/licences.csv
[sectors]: https://github.com/alphagov/licence-finder/blob/main/data/sectors.csv
[activities]: https://github.com/alphagov/licence-finder/blob/main/data/activities.csv
[Specialist Publisher]: https://github.com/alphagov/specialist-publisher
[Air Accidents Investigation Branch reports]: https://www.gov.uk/aaib-reports
[problems]: #problems
[content item]: https://www.gov.uk/api/content/tv-licence
[Search API]: https://github.com/alphagov/search-api/tree/0bdded0582be4d748e62646932110691d6f32576/config/finders
[Government Frontend]: https://github.com/alphagov/specialist-publisher/blob/0d7ba2df9a7de2e6b2ad8509c9f99d8cfbec432f/app/presenters/document_presenter.rb#L17
[Frontend application]: https://github.com/alphagov/frontend/blob/d9a94a7fdf94690d37dd985724ec3960e077a65d/app/controllers/licence_controller.rb
[updating facets]: https://github.com/alphagov/specialist-publisher/blob/main/docs/creating-and-editing-specialist-document-types.md#adding-a-new-field-to-an-existing-specialist-document
