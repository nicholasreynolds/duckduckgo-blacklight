

window.onload = function() {
    if (isBrowserDefined()) {
        browser.storage.sync.get("api").then(insertTriggers);
    } else {
        chrome.storage.sync.get("api", insertTriggers);
    }
}

function insertTriggers(res) {
    let api = res["api"];
    let browserContext = isBrowserDefined() ? browser : chrome;
    let port = browserContext.runtime.connect();
    // list is continually updated (shrunk) as nodes initialized
    let containers = document.getElementsByClassName("result__body");
    for (let cont of containers) {
        let url = cont
            .getElementsByClassName("result__extras__url")[0]
            .getElementsByClassName("result__url")[0]
            .getAttribute("href");
        let node = document.createElement("div");
        cont.appendChild(node);
        // node removed from dom when initialized
        let app = Elm.Main.init({
            node: node
            , flags: url
        });
        app.ports.requestInspection.subscribe(function(message) {
            port.onMessage.addListener(function(message) {
                if (message.url !== url) { return }
                app.ports.receiveInspection.send(message.body);
            });
            port.postMessage({
               url: message,
               api: api,
            });
        });
    }
}

function isBrowserDefined() {
    return typeof browser !== "undefined";
}
