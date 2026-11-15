<?php
// Global retention default for new users. FreshRSS reads this only when a user is created.
// Per-category (feed group) and per-feed retention are set in the admin UI and override this:
// feed setting > category setting > this default.
//
// An article is purged when it is older than keep_period OR beyond keep_max articles in its feed,
// unless it is protected by keep_min, keep_favourites, keep_labels, or keep_unreads.
// false disables a rule. FreshRSS's own default is P3M / 200 articles.
return [
	'archiving' => [
		'keep_period' => 'P1Y',
		'keep_max' => false,
		'keep_min' => 50,
		'keep_favourites' => true,
		'keep_labels' => true,
		'keep_unreads' => false,
	],
];
