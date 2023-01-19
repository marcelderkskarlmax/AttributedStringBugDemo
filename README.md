# AttributedStringBugDemo
The purpose of this repo is to demonstrate an issue with the combination of AttributedString and WKWebView in one project.

I found out, that an iOS app will crash, when you reproduce the following steps:

1. Create an NSAttributedString with doctype html. It is not necessary to actually assign this string to a LAbel or TextView. Just creating such a String is enough.
2. Now open a WKWebView and load an html page, that uses JS MediaRecorder to record audio from device microphone.

-> The app will crash.

**Important: This bug  can only be reproduced on a physical device. Do not use Simulator. The crash won't appear there.**

To reproduce this, I created this little demo so that noone has to fire up all these components by themselves.

Just open the project in XCode and run the app and follow instructions. 

Also note, that the refcording funtions works, as long as the NSAttributedString hasnot been instantiated before.

