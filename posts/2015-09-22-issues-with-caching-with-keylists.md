Issues with Caching with Keylists
===

When we built Virb, it was built with a lot of the core framework that built Purevolume. A new version was being developed out of what was learned from Purevolume. This involved a lot of memcache for objects and making the ORM work better for developers.

This new version of the framework didn't have any MVC, so most of the core was built as ORM (Object Related Model).

When we launched Virb we found that the MySQL server was getting hit a lot as we didn't cache a lot of the database calls to the database. We added a lot of features to reduce the amount of queries, with the goal to remove all queries to the database on a normal profile.

Objects would be cached based on the query that was being used. Using the objects to query was how it was done in the code, which would translate in to SQL and also allow use to cache according to the individual parts.

	Page(1)->getRelated('PageImageAlbum')->getRelated('PageImage')

To cache all the relationships between them, so you wouldn't need to query the database would need some list of whats their children. These would be stored in keylists, which would be pointers to the cached items of their children.

	md5(user-1-relationship-1)-keylist array(
		0 => 098f6bcd4621d373cade4e832627b4f6
		1 => ad0234829205b9033196ba818f7a872b
		...
	)

One thing that wasn't properly considered was the relationships being many to many and how those are very difficult to cache properly because both sides of the relationship would need to be uncached. Relationships of over 5M created a consistant cycle of uncaching the keylist of all the relationships.

Keylist is a simple cached value storing the keys that were related to one another, and thus keeping any listing of data from hitting the database. When you have a social network of relationships, these things can get out of hand unless understood properly.

Sample query tree to get 20 photos on their profile.

	Page > ImageAlbum > Image (limit=20)

	md5(page-1-image-album-2-images-limit-20) = array(
		0 => array(
			id => 1,
			title => "My Image",
			...
		)
	)

Anytime any of the images would update, it'd go back up the tree and clear all the parent caches.

	clear ImageAlbum-2
	clear Page-1
	clear User-1

With relationships this gets a little more tricky as going up the parent tree can clear cached relationships between other people.

	          user  other user
	Relationship (1, 2)
	Relationship (2, 1)

	clear Relationship-1
	clear User-1
	clear User-2
	clear Relationship-2
	clear User-2
	clear User-1

If a user was in a relationship with many people (say in the thousands), this would cause all the objects to clear their cache. multiple times. And the parent object would be cleared for each relationship.

Then comes the keylist. This would store all the related objects for a given query. Like getting all the relationships for a user.

	md5(user-1-relationship-1)-keylist array(
		0 => 098f6bcd4621d373cade4e832627b4f6
		1 => ad0234829205b9033196ba818f7a872b
		...
	)

If any user in that keylist was to change their relationship, it'd have to clear all the related keylist items as well, to make sure the keylist was up to date.

So now instead of spending time retrieving the data from MySQL, and spending a few miliseconds for each response, it could be cached entirely and only a couple of queries would hit the database. This significantly reduced the load on the database from 2500 queries a second to something like 150 queries as second.

With such large keylists, the constant updating and clearing of cache, even when something unrelated to their page happens. This caused saving of pages to go into 5-10 seconds or more, which made anything close to useable impossible.

People would assume it wasn't working and try to do it again, which would have the same process happen. Where these improvements were put in to reduce the load on the database, it just increased and distributed across the web nodes. At this time the web nodes were physical machines and they were being pegged to about 80% cpu load, most of this was due to having to process the uncaching of memcache constantly.

At this time I was the only developer for handling any of the core ORM framework, as well as developing features for all the new ideas coming from what was being designed. There had to be a solution for how to handle these, where their would be a reduction in cache invalidation until it was necessary.

To do this, we had to remove the idea of keylists. Keylists were great maybe in theory, but immediately in practice they fall apart because they were not properly able to handle scale because of the abstraction from the what the truth is in the database.

After removing keylists, and just allowing those requests to go to the database to get a list of results made it easier to manage the indexing required to make everything run smoothly in memory without worrying a whole lot of query load.

Since then there have been rewrites of the core ORM framework to include Object Caching and reusing objects in memory instead of having every request go to the database for every request. This allowed a reduction of memory usage because objects would be used upwards of a 200 times on a page were now reduced to referencing the same object.

This has kept the core system scalibily, fast, and efficient and allow Virb to scale without adding more web servers. Response time was down to 100-300ms on normal pages.

Since these web pages had no interactive content, they could be bundled up into a page cache, storing all the data or relevant html and make it possible to access memcache directly through nginx. Not need to hit PHP at all would make it even more scalable.
