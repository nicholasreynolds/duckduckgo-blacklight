
let port;

(isBrowserDefined() ? browser : chrome).runtime.onConnect.addListener(function(p) {
    port = p;
    port.onMessage.addListener(requestInspection);
});

function requestInspection(message) {
    let http = getXMLHttp();
    http.onreadystatechange = function() {
        if (http.readyState === XMLHttpRequest.DONE) {
            port.postMessage({ url: message.url, body: http.responseText })
        }
    };
    http.open('POST', message.api, true);
    http.setRequestHeader("Content-Type", "application/json");
    http.withCredentials = true;
    http.send(JSON.stringify({ inUrl: message.url }));
}

function getXMLHttp(){
    try {
        return XPCNativeWrapper(new window.wrappedJSObject.XMLHttpRequest());
    }
    catch(evt){
        return new XMLHttpRequest();
    }
}

function isBrowserDefined() {
    return typeof browser !== "undefined";
}