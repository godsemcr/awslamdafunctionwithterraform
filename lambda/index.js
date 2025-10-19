exports.handler = async (event) => {
    return {
        statusCode: 200,
        body: JSON.stringify({
            message: "Hello World from node js lamda second time deploy",
            input: event
        })
    };
};