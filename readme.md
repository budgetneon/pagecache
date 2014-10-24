# pagecache

pagecache - A fast, open source page level cache for opencart
 

## VERSION

Version 1.00

## DESCRIPTION

This is part of a collection of code intended to help improve the performance and functionality of opencart.  See [octurbo.com](http://octurbo.com) for more information on the effort.

One of the improvements is this simple, but effective, page level cache for opencart.  It includes an admin panel, and an installer that will make two simples changes to your main index.php file. 

It has been tested so far only on opencart 1.5.6.X, but should work on all of the 1.5.X versions, perhaps with minor tweaks.  This is a new piece of software, so we highly recommend you test it well before using.  See the CAVEATS section. 

## Requirements

- Opencart 1.5.X.  Has been tested on 1.5.6.X
- PHP 5.4 is STRONGLY recommended
  - It will run on PHP5.3, however:
    - PHP5.3.x does not have http_response_code(), so we'll cache things that probably shouldn't be cached, like 5XX errors and "404 Not Found".  We looked at ways around this, and there's not anything elegant. It's too bad that opencart made the $headers array within system/library/response.php a private property. 
    - Worse, when the cached pages are served, they will have a "200 OK" status. That will result in, for example, [Soft 404's](http://googlewebmastercentral.blogspot.com/2010/06/crawl-errors-now-reports-soft-404s.html)
    - There is a little hack that will fix the two problems above.  It involves a small change to a core file, so I did not want to incorporate it into this extension.  You can see it at the bottom of [this github issue](https://github.com/budgetneon/pagecache/issues/2).

## Installation

- Copy all of the files in the upload directory into your main opencart installation
- Log into the admin panel of your store
- Navigate to the Extensions > Modules tab 
- You should see the module listed there as "Page Cache"
- Click the Install link
- There should now be a new link next to "Page Cache" labeled "Edit".  Click That link.
- Make sure you have a backup copy of your main index.php first, then...
  - Click the Enable Cache button 
  - If the Enable Cache button returns an error, you may need to make the changes to your index.php file manually.  See the Manual Installation section.
- The cache should now be working

## Manual Installation
This extension has to make changes to your main index.php before it will work.  There is an "Enable Cache" button in the extension's admin page that can make those changes.  However, in some environments, this button may not be able to do that, due to file permissions, a customized installation of opencart, etc.  If that's the case, you'll have to make the changes to the index.php manually.

NOTE: THESE MANUAL INSTALLATION INSTRUCTIONS ARE ONLY FOR PEOPLE HAVING ISSUES WITH THE "ENABLE CACHE" BUTTON WITHIN THE PAGECACHE ADMIN PANEL.

There's two changes that need to be made.

1. At the top of your main index.php file, find this section of code:

```
    if (file_exists('config.php')) {
        require_once('config.php');
    }  
```

Then, add these 6 lines, exactly as shown below, just after the section of code above:

    require_once(DIR_SYSTEM . 'library/pagecache.php');             //PAGECACHE
    $pagecache = new PageCache();                                   //PAGECACHE
    if ($pagecache->ServeFromCache()) {                             //PAGECACHE
        // exit here if we served this page from the cache          //PAGECACHE
        return;                                                     //PAGECACHE
    }                                                               //PAGECACHE

2. At the bottom of your main index.php, find this section of code:

```
    // Output
    $response->output();
```

Then, add these 3 lines of code, just after the section of code above:

    if ($pagecache->OkToCache()) {                                  //PAGECACHE
        $pagecache->CachePage($response);                           //PAGECACHE
    }                                                               //PAGECACHE

## OVERVIEW
Very early in opencart's main index.php file, the following lines of code have been added:
 
    require_once(DIR_SYSTEM . 'library/pagecache.php');             //PAGECACHE
    $pagecache = new PageCache();                                   //PAGECACHE
    if ($pagecache->ServeFromCache()) {                             //PAGECACHE
        // exit here if we served this page from the cache          //PAGECACHE
        return;                                                     //PAGECACHE
    }                                                               //PAGECACHE

This section of code looks to see if there's a previously cached file for the url that's currently being requested.  If there is, and it's not expired, the request is served from the cache.  Because this is very early in the index.php file, and because it exits if served from the cache (via the return() call), it skips over almost all of the processing that opencart normally does.  No database calls, etc..so it's very fast.

Later, towards the end of the index.php, the following lines of code have been added.  This is very near the end of the file, after whatever page was requested has already been generated by opencart, and served to the end user. 

    if ($pagecache->OkToCache()) {                                  //PAGECACHE
        $pagecache->CachePage($response);                           //PAGECACHE
    }                                                               //PAGECACHE

Here, we're seeing if we should take the page that opencart just generated and cache it.  This does add a small amount of overhead in writing out the content twice (once to the browser, and once to the cache file).  That is, however, the only notable overhead added, and it's quite minimal.  
## ADMIN PANEL

This extension includes an easy to use admin panel that allows you to:

- Enable and disable the cache
- Purge cached files (either all of them, or just the expired ones)
- See statistics on the number of cached files, and disk space used, for both currently valid, as well as expired cache files
- View, but not change, the settings (you have to manually edit system/library/pagecache.php to change settings).

Here's a screenshot of the admin panel:
![Pagecache Admin Panel](https://i.imgur.com/0qkDzRJ.png)

## SETTINGS

In order to keep this page cache lightweight, we do not store settings in the opencart database like a normal opencart extension would.  This allows a cached page to be served with almost no opencart code running, and no database calls at all.  Therefore, to make changes to settings, you have to hand edit the pagecache.php file.  Here's the settings you can safely change:

     
    // These are all near the top of the pagecache.php file  
    private $expire='14400'   ; // expire time, in seconds 14400 = 4 hours
    private $lang='en'        ; // default language for site
    private $currency='USD'   ; // default currency for site

    private $addcomment = true; // set to true to add a comment to the bottom
                                // of cached html pages with info+expire time
                                // only works where headers_list() works

    private $wrapcomment=true ; // if this is set to true (and $addcoment is
                                // also set to true), we will use a comment
                                // that most html minifiers won't remove, like:
                                // <!--[if IE]><!--comment--><![endif]-->

    private $end_flush=false;   // set to true to do an ob_end_flush() before
                                // serving a cached page. Slightly faster
                                // "first byte received" times, but it creates
                                // issues in some environments, hence, it's off
                                // by default

    private $skip_urls= array(
        '#checkout/#',
        '#product/compare#',
        '#product/captcha#',
        '#contact/captcha#',
        '#register/country#'
    );


A new notes on these settings:

- $expire : Because it's in the declaration section of the class, your options to set this are limited...you can't, for example, do $expire=24*24*60.  Just figure out the number of seconds you want cached pages to exist before they expire. We used 14400, which is 4 hours.
- $lang and $currency : We cache pages for different languages and currencies in different files.  These two settings control what the default language and/or currency is if we get an http request that does not have the session variable(s) for each respective setting already set.
- $addcomment : Set to true if you want the page cache to append an html comment at the end of the stored cache file that notes the url cached and it's expiry time.  This can be helpful since you can see it with live pages via your browser's "view source" functionality.  Set to false if you don't want this.  We only add the comment if headers_list() is available and indicates that the cached resource is an html page.  This keeps us from adding an html comment to a cached JSON response, for example. 
- $wrapcomment : If true, wraps the comment (see above) with <!-[if IE]><![endif]--> so that it doesn't get stripped out by an html minifier (like Cloudflare's, for example)
- $end_flush : Set to true to run ob_end_flush() before serving a cached page. This gives you a slightly faster "first byte to browser" time, but creates issues (errors, blank pages) in some environments, so we've defaulted it to false. 
- $skip_urls : This is an array of PCRE patterns for urls that you do not want to be cached.  The default settings prevent caching for checkout pages, product comparisons, captchas, and the JSON country list.  Note that this is not the only check done to decide when a page shoudn't be cached.  You shouldn't have to, for example, mark the 'account/' pages here, because we already disable caching when a user is logged in.

Also, the cached pages are kept in a directory named 'pagecache', under the existing directory opencart uses for it's more general cache.  In most installations, this would be /your_opencart_root/system/cache/pagecache.  There is no functionality to manually expire cached pages or flush the cache.  You can, however, run this command on most linux/unix machines:

    # use caution..."find with -exec rm" can be dangerous if mis-typed
    find /your_opencart_root/system/cache/pagecache -type f -exec rm {} \;


## DEMO


We created a demo site at [octurbo.com](http://octurbo.com).  The home page has links to both a stock/vanilla installation of opencart, and one with our page cache.  Note that you may have to load a page from the pagecache enabled site twice...once to prime the cache, and a second time to see the performance improvement.

A page cache makes a much bigger difference on an opencart site that has a lot or products, categories, and other functionality.  So, for the demo site, we uploaded a large number of movies from [an Amazon AWS Cloudsearch dataset](https://aws.amazon.com/developertools/9131774809784850). You can also try our production site at [budgetneon.com](http://budgetneon.com/).  It has lots of products and nested categories.  If you view the source of a cached page, you'll see the html comment at the bottom.

## CAVEATS

- This extension has been tested, but not in a rigorous way.  Please test it thorougly before deploying on a production server.

- Using the "Enable Cache" and "Disable Cache" buttons in the admin panel makes live changes to your main index.php file.  Make sure you have a backup of the main index.php file in case anything goes wrong. 

- The "Output Compression Level" within opencart (System->Settings->Edit->Server->Output Compression Level) is disabled when a cached page is served.  If you want cached pages to be compressed, disable output compression within opencart, and use apache's mod_deflate instead. It's a better solution anyway.
 
- The page cache does not check the sanity of url parameters. So, it will happily cache '/index.php?foo=1', '/index.php?foo=2', and so on...all as separate urls and cache file.  This could result in a very large number of cached pages, and in extreme circumstances (like a robot crawling invalid pages), it could potentially fill up your hard drive.

- We did try to put in sufficient logic such that dynamically created pages that should not be cached...aren't.  However, it's possible we missed some.  Also, if you've added extensions to opencart that have url's that shouldn't be cached, that will likely be missed.  See the "$skip_urls" setting to remedy that. 

- A page cache can be a terrible crutch, that effectively hides important performance problems.  For example, if your home page is really slow, the first person to request the page when it's not cached (or when the cache expires) will see that horrible performance.  Subsequent visits will get the benefit of the page cache, which is nice...but not if that's hiding the true issue from the site owner.  In short, it's not a substitute for proper performance tuning.

## AUTHOR

Kerry Schwab, `<sales at budgetneon.com>`

We run [BudgetNeon.com](http://budgetneon.com/).  The website uses opencart, and this code was written specifically to support our website. We sell [neon open signs](http://budgetneon.com/open-signs), signs for [restaurants](http://budgetneon.com/restaurant) and [businesses](http://budgetneon.com/business), as well as [custom made neon signs](http://budgetneon.com/custom).  We plan to release more of our local opencart additions, especially those that improve performance.

## LICENSE AND COPYRIGHT

Copyright (c) 2014 Kerry Schwab & BudgetNeon.com
All rights reserved.

This program is free software; you can redistribute it and/or modify it
under the terms of the the FreeBSD License . You may obtain a
copy of the full license at:

[http://www.freebsd.org/copyright/freebsd-license.html](http://www.freebsd.org/copyright/freebsd-license.html)


Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

- Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
- Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
- Neither the name of the organization nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL <COPYRIGHT HOLDER> BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
