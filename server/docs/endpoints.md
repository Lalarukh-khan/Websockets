Endpoints: a highlevel overview

Lets forget about bearer tokens. simply authenticate with every call. So proivde message, signature, pubkey combination in headers on every endpoint

This is the order in which they will normally be called too.

Wallet Info:
    payload (json): {
        address: str 
        device: {
            name: str
            cpu: int
            disk: int
            bandwidth: int
            ram: int
        }
    }
    server will set up wallet if one not exist
    server will create or update device info
    returns: success or failure

Get Primary Subscriptions: (streams I subscribe to and do produce predictions of)
    returns: subset of wallet.subscriptions corresponding to wallet.streams (my the streams I publish to .stream_id)

Get Secondary Subscriptions: (streams I subscribe to but don't produce predictions of)
    returns: subset of wallet.subscriptions not corresponding to wallet.streams (my the streams I publish to .stream_id)

Request Subscription:
    server will verify you don't have more subscriptions than you're allowed:
        publications = wallet.streams;
        wallet.publications.length < getSubscriptionLimit(wallet.device) # lookup table based on device info
    server will choose a random stream/target without a stream_id and save a new stream record (your publish stream)
    returns: stream data

Get History of Stream: 
    payload: {stream_id: int, target_id: int}
    returns: [{ipns: str, ipfs: str}] # ordered by most recently updated first

Subscribe to Stream:
    payload: {stream_id: int, target_id: int}
    server will verify you don't have too many subscriptions
        wallet.device.subscriptions.length < 500 # or whatever hard coded number we choose
    server will save a subscription record and start sending you observations through websocket # not sure how it knows the correct websocket connection
    returns: success or failure

Publish to Stream:
    payload: {stream_id: int, target_id: int, value: str}
    server will save a subscription record and start sending you observations through websocket
    returns: success or failure

Pins:
    payload: {stream_id: int, target_id: int, ipns: str, ipfs: str}
    returns: success or failure