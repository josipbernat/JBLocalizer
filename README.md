# JBLocalizer
Mac OS X application for extracting NSLocalizedString strings.

![alt tag](https://cloud.githubusercontent.com/assets/2537227/9875864/f2b45820-5bb1-11e5-84f3-3faa1fdc635f.png)

In my last project I wrote more than 1k lines of NSLocalizedString macros and I didn't track all those strings in Localizable.strings file. After realising that writing this simple application was a logical solution.

## Unit tests
App is separated in two main targets: JBLocalizer.framework and JBLocalizerApp (Mac app) with separate tests for both targets. Because of some (still) unreasonable error I was unable to load CocoaPods resources withing Tests target and that is the reason why JBLocalierTests target is missing. If you know what the problem is and you have some free time feel free to fix it and make pull request :)

I will write tests as the time goes on. For now working app is a great success.

[Available on Mac App Store](https://itunes.apple.com/hr/app/strings-localizer/id1021897676?mt=12)
