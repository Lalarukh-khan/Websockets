# client only flows 

## startup

1. starts up, 
2. if no wallet, creates wallet
3. connects to server (all other behaviors assume established connection)
4. if no subscriptions (in config), or if max ram consumption is not high, setup primary subscription
5. starts engine

## setup primary subscription

1. requests a primary subscription saves name to config
2. compiles history
3. subscribes to primary stream-target

## compile history

1. requests history keys on a subscription
2. uses ipfs to download the most popular version of the history to disk for engine

## engine startup

1. get list of primary subscriptions from config
2. load stable models
3. load exploratory models for them
4. save max ram consumption in config

## exploratory stream search

1. get a list of possible subscriptions from server
2. compile history for one chosen by a module (random at first, by recommender later)
3. load data into memory
4. evaluate
5. discard if unused after a period of time
6. repeat 

# server only flows 

see usecases.md

# client-server communication flows

These flows describe what the server will do in response to various types of client requests in general and treats the pub-sub system as a black box. They describe the data-model and the computation relationship between the entities in the database.

## authentication

1. client provides `message` (recent datetime string), `signature` (string), and `public_key` (string), and `address` (string) to 'establish connection' endpoint
2. server verifies `message` is recent
3. server verifies `signature` is good
4. server looks up `public_key` in `wallets` table, if not exists, server creates a wallet using `public_key` and `address`.
5. server loads into memory (on the session object? wallet object? idk) the subscriptions this client has so observations on those streams are automatically sent to the client.
6. server establishes websocket connection with client (via graphql session management)
7. server provides a token (probably via graphql session management) to client.
8. client uses token on all subsequent websocket communication, (when expires, graphql should issue another one I think is how it works)

## request history on stream-target

1. client asks server for the ipns keys for a stream
2. client must provide `source_name`, `stream_name`, `wallet_id` that publishes it, and `target_name` to uniquely identify the stream-target
3. server looks up the ipns values for that stream-target from the `pins` table, and returns the list of ipns keys

## pubsub - request primary subscription

Guards: A client may request one or more primary subscriptions. The server will not give more than 10 to any single client. It knows how many a client has by how many predictive publications the wallet has (see step 4). If a client is requesting the 11th primary subsription the server will say no.

1. client asks server to choose a stream-target for it to predict.
2. server chooses a random stream target that needs a predictor.
3. server responds with a `source_name`, `stream_name`, `wallet_id` that publishes it, and `target_name` (these uniquely identify the stream-target concept).
4. server sets up a stream corresponding this on as a prediction stream using the client's `wallet_id`, `source_name = 'satori'` and `stream_name+"pred"` appended to the end, which points back to the first stream with predicting being the above chosen stream.
5. (notice the server does not yet set up a subscription).

## pubsub - setup subscription

Guards: A client may request one or more ancillary subscriptions. The server will not give more than 500 to any single client. It knows how many a client has by how many subscriptions they have in the subscription table. If a client is requesting the 501st ancilary subsription the server will say no.

1. client asks server to set up a subscription to a specific stream (by `source_name`, `stream_name`, and `target_name`).
2. server looks up stream, if exists server saves a record in the subscriptions pointing to the stream and target, (if `target_name` doen't exists in targets table it is created).
3. server loads the saved record into memory on the wallet object just as it does when the client connects, so the client gets updated upon observations
4. server responds with success or failure

## pubsub - publish

1. client gives server `source_name`, `stream_name`, `target_name` and `value` (as dynamic) as an observation
2. server looks up the stream and verifies the client is assigned as the publisher as `wallet_id`
3. server inserts the `target_name` into the `targets` table if it doesn't exist already.
4. server upserts the `value` to the `observations` table, referencing the stream an target.
5. server repsonds with success or failure
6. server uses in-memory information (since subscriptions are already loaded somewhere) to send this value to all clients that have subscribed to this stream-target.