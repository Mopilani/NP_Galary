const http = require('http');

const host = '0.0.0.0';
const port = 8001;


const onNotesRoute = function (req, res) {
    // Having our source ready
    const notes = JSON.stringify([
        { id: 0, title: 'Note 1', content: 'Lorem Ipsum 123' },
        { id: 1, title: 'Note 2', content: 'Lorem Ipsum 234' }
    ]);

    // Then Responding
    res.setHeader('Content-Type', 'application/json');
    res.writeHead(200);
    res.end(notes);
};

const onCSVRoute = function (req, res) {
    // Then Responding
    res.setHeader('Content-Type', 'text/csv');
    res.setHeader('Content-Disposition', 'attachment;filename=np_team.csv');
    res.writeHead(200);
    res.end(`id,name,email\n1,Mopilani,mopilani@nexapros.com`);
};

const onImageRoute = function (req, res) {
    // Having our source ready

    // Then Responding
    res.setHeader('Content-Type', 'application/json');
    res.writeHead(200);
    res.end(notes);
};

const onWebRoute = function (req, res) {
    // Having our source ready
    fs.readFile(__dirname + '/index.html')
        .then(contents => {
            // Then Respond
            res.setHeader('Content-Type', 'text/html');
            res.writeHead(200);
            res.end(contents);
        }).catch(err => {
            // Handle error to the client
            res.writeHead(500);
            res.end(err);
            return;
        });
};

const onTextRoute = function (req, res) {
    // Having our source ready

    // Then Respond
    res.setHeader('Content-Type', 'text/plan');
    res.writeHead(200);
    res.end('Hello World')
};


const requestListener = function (req, res) {
    // Turning to the function of route
    switch (req.url) {
        case '/notes':
            onNotesRoute(req, res);
            break;

        case '/image':
            onImageRoute(req, res);
            break;

        case '/video':
            break;

        case '/audio':
            break;

        case '/file':
            break;

        case '/csv':
            onCSVRoute(req, res);
            break;

        case '/web':
            onTextRoute(req, res);
            break;

        case '/text':
            onTextRoute(req, res);
            break;

        default:
            res.writeHead(404);
            res.setHeader('Content-Type', 'application/json');
            res.end(JSON.stringify({ error: 'Resource not found' }));
            break
    }
};

// Running the server
const server = http.createServer(requestListener);
server.listen(port, host, () => {
    console.log(`Server is running on http://${host}:${port}`);
});
