Home for iOS
===============================

![Screenshot](cover_image.jpg)


This is an attempt to replicate essential elements of the Facebook Home experience in iOS as an app. The aim is to re-create features like Cover Feed with nothing but simple UIKit 
controls and the Facebook Graph API.

Development Notes:

* [Project Page](http://corgitoergosum.net/facebook-home-for-ios/ "Project Page")
* [Intro](http://corgitoergosum.net/2013/04/29/facebook-home-for-ios/ "Intro")
* [Building Home (1) – Data Layer](http://corgitoergosum.net/2013/04/30/building-facebook-home-for-ios-1-data-layer/ "Building Home (1) – Data Layer")
* [Building Home (2) – Cover Feed](http://corgitoergosum.net/2013/05/01/building-facebook-home-for-ios-2-cover-feed/ "Building Home (2) – Cover Feed")
* [Building Home (3) – Menu and App Launcher](http://corgitoergosum.net/2013/05/09/building-facebook-home-for-ios-3-menu-and-app-launcher/ "Building Home (3) – Menu and App Launcher")


Installation
---
* git clone / pull
* cd Home-For-iOS/Home
* (optional) pod install / pod update
* open and build from Home.xcworkspace
* For installation on devices, please create a facebook app that matches the app bundle id you are using. See https://github.com/kenshin03/Home-For-iOS/issues/5.


Working Features
---
* Coverfeed. Supports posts of type photo (added_photos/mobile_status_update/shared_story) and status (picture/mobile_status_update/wall_post).
* Double tap to like a post from Coverfeed.
* View comments and add comments to a post. (iPhone5 only)
* Post to your own timeline.
* Fake launcher that opens pre-installed apps like Facebook Camera, Twitter, Instagram, Mail via URL schemes.
* SSO to Facebook using iOS 6's SocialFramework.

Missing Features / Known Issues
---
* Notifications
* Chat Heads
* Comments view not re-sized properly for 3.5 inch screen sizes. 
* Intermittent crashes
* Unlike isn't working anymore


Contribution
---
Feel free to fork and implement any features or fix any issues as you see fit. Or submit an issue with an feature requests or bug reports.


License
---
MIT (https://github.com/kenshin03/Home-For-iOS/blob/master/LICENSE)


Videos
---
[Vimeo Video](https://vimeo.com/64940276 "Demo Video 1")

[Vimeo Video](https://vimeo.com/63531931 "Demo Video 2")


