// lambda/test.js

const { handler } = require("./index.js");

(async () => {
    try {
        const event = { test: "local invocation" }; // mock event
        const result = await handler(event);
        console.log("Lambda response:", result);
    } catch (err) {
        console.error("Error:", err);
    }
})();
