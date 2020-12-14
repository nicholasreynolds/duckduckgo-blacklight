
function saveOptions(e) {
    e.preventDefault();
    let browserContext = typeof browser === "undefined" ? chrome : browser;
    browserContext.storage.sync.set({
        api: document.querySelector("#api").value
    });
}

function restoreOptions() {

    function setCurrentChoice(result) {
        document.querySelector("#api").value = result.api || "your api endpoint";
    }

    function onError(error) {
        console.log(`Error: ${error}`);
    }

    if (typeof browser !== "undefined") {
        browser.storage.sync.get("api").then(setCurrentChoice, onError);
    } else {
        chrome.storage.sync.get("api", setCurrentChoice, onError);
    }
}

document.addEventListener("DOMContentLoaded", restoreOptions);
document.querySelector("form").addEventListener("submit", saveOptions);