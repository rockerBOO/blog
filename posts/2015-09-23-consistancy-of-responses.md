Consistancy of responses
===

In PHP you aren't required, or have a way to make a function return something specifically. Could return anything and wouldn't know what it would return.

At Virb we had a way to retrieve an object, which would get it from cache or the database, which would load it up into cache.

In our ORM we have related objects that would load into an array of objects.

	$images = $Page->getRelated('PageImageAlbum,PageImage');

	foreach ($images as $image) {
		if (false == is_object($image)) {
			continue;
		}

		$title = $image->get("title");
	}

But it was designed so false would have to be accounted for so you'd have to make sure it was an object every time. This was left in because it was not found for years after it was created. A huge number of pages would fail if any part of the data happened to get messed up by a code update or something badly coded.

Reformed the object getting process to a simple function that returned the object in every case, and left it empty if none existed.

	$PageMeta = get('Page')->get('PageMeta');

	$PageMeta->get("title");

So if the data didn't exist for the title, we could still run method calls on it. Most of the time these calls were based on simple data retrieval and would need to be checked if they were loaded before any real work could happen.

	if ($PageMeta->loaded()) {
		$PageMeta->update(["title" => "Cool Site Name"]);
	}

So if you are running any sort of function, make sure it responds to a consistant type, and handle off cases accordingly without the errors going up into developers code having to handle the off cases constantly.

This reduced fatal error rates to very minimal and customers were much happier with the experience of their site loading without it crashing because of a simple data issue.