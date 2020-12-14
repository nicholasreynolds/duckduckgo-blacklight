# DuckDuckGo Blacklight

## What is it?
This is a proof-of-concept web extension that inserts 
an expandable "inspection" menu below each search result 
which shows the trackers and other info present on the 
site. It is intended to give users more control over their 
data by alerting them to a given website's practices prior 
to visiting or clicking the link. Tested in Chromium 87 and 
Firefox 83.

_Disclaimer: I am not a web designer, and this is a proof-of-concept. 
The interface is minimal but displays all necessary information.
I may be gradually updating the styling, but feel free to do this
yourself to meet your own standards._

## How does it do this?
The data are fetched from a user-specified api using the 
same json schema as blacklight.api.themarkup.org. Since 
The Markup's api is private, please run your own instance 
of [@themarkup/blacklight-collector](https://github.com/the-markup/blacklight-collector) 
to achieve this. Then provide the url in this plugin's 
settings. Accessing extension settings varies between browsers.

## Permissions needed

### storage
This is to allow the user to modify the api address via the 
options page.

### <all_urls>
While not ideal, I cannot predict the url of the 
user-specified api. As such, the plugin must request access 
to all urls, such that requests can be made to the provided 
endpoint. This may allow for some XSS vectors, however, so 
I hope to look into sanitizing the html in the json response.