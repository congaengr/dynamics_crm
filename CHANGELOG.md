## 0.7.0 (March 4, 2016)
* Add EntityCollection to xml attributes #24
* Fix illegal XML characters #25
* Dynamics optimize metadata queries #26
* Add Money attribute #31
* Use `request.bytesize` instead of `request.length` #32
* Rexml sanitization on username and password for ocp request builder #33
* Adding new regions to determine region set #34
* Improve region determination #37

## 0.6.0 (December 30, 2014)

* Adds support for Relationship Metadata.
* Adds support for AliasedValue attribute type.
* Moves FetchXml condition support to Entity class.
* Adds configurable link-type attribute to LinkEntity.

## 0.5.0 (December 19, 2014)

* Adds On-Premise Authenticate support with specified hostname. PR #18

## 0.4.1 (November 23)

* Switch to TLS. SSLv3 has been disabled. PR #19

## 0.4.0 (October 11, 2014)

* Adds FetchXml module (Builder, Entity, LinkEntity) for building Xml document. (New dependency on builder)
* Merge PR #15 - Adds EntityCollection object used by Client#fetch response.

## 0.3.0 (October 11, 2014)

* Merge PR #12 - Adds support for Entity FormattedValues
* Merge PR #14 - Fix invalid hash key lookup (return nil).

## 0.2.0 (September 17, 2014)

*  Merged PR #6 - Fix requires
*  Merged PR #7 - Update README
*  Merged PR #8 - Use Ruby Logger

## 0.1.2 (June 17, 2014)

*   Fixes associate/disassociate requests

## 0.1.1 (March 23, 2014)

*   Adds support for Opportunity WinOpportunity/LoseOpportunity

## 0.1.0 (March 23, 2014)

*   Initial Release.

