### Getting Started

This is a monorepo. Serverside code is in the server folder, client code is in the node folder (the software is called the Satori Node). If you want to install the entire system for development purposes install the python this way:

```
...satori/node> python setup.py develop
( or ...satori/node> pip3 install -e .)
```

and install the server this way
```
...satori/server/satori> mix deps.get
...satori/server/satori> mix deps.compile
...satori/server/satori> mix ecto.create
...satori/server/satori> mix ecto.migrate
```

you can run the client this way
```
...satori/node/web> python app.py
```

and you can run the server this way
```
...satori/server/satori> iex -S mix phx.server
```

Some helpful things to know: clients authenticate to the server automatically with signing a message with their private key and the server authenticates it with their public key. The client doesn't have to be running to use it's helpful CLI commands: 

```
...> satori create_test_wallet_auth_payload
{'message': '2022-08-13 18:22:51.728322', 'pubkey': '024babc70bb0252c6aee5494ae4a9f4c69fbaa1eb748e5384d058c554ef341d7d9', 'sig': 'IFPa+snVqDzzy6mlv3m/nD8UcbPSeoACAIwrkFfANjyRXRKasFVUc2d2n2IcR8PHJOHPTJ8bbBdM1xZvIWJYLsg='}
```

that is all.

# A Brief Description of Satori

### Vision

Satori aims at predicting the future of all things.

### Value Proposition

Satori produces 2 main forms of value: 
1. A Public Good Offering
2. A Prediction Market

The public good offering consists of the network predicting all popular, and publicly available data streams.

The prediction market is where private actors can pay the Satori network to predict their own or any specific data stream.

### Systems

From a systems perspective Satori is made up of 3 parts: 
1. A Node
2. A Blockchain
3. A Pub/Sub network

```
B   P/S
 \ /
  N
```

The Node is a piece of software running on many computers which communicates with other Nodes through the Pub/Sub network(s) and the Blockchain.

The Blockchain is used to incentivize people to run the Node on their computer. It also will eventually serve as a marketplace for trading future predictions.

The Pub/Sub network facilitates communication between Nodes in the form of data streams. Each Node publishes one or more data streams and subscribes to many.

### The Node

The Node is made up of an Engine, a layer of application logic, and interfaces with the user, Blockchain, and Pub/Sub network(s).

Its function is to subscribe to one or more data streams and publish predictions about one or more of those data streams. These predictions are of the same data type and cadence as the target data stream.

For example, a Node may subscribe to the 4-hour-gold-price data stream. Every 4 hours, when a new observation is received, the Node will immediately produce a prediction of the next observation 4 hours in the future. This prediction is then pushed to a corresponding prediction stream, for instance, 4-hour-gold-price-prediction. That is the function of the Node software.

In order to achieve this predictive ability, it constantly generates new models, searching the parameter and feature space for the most predictive model. To that end, it may subscribe to other data streams which help it predict its primary data stream. A single Node may have several primary data streams that it produces predictions for.

### Roadmap

Generally speaking, 3 phases of development can be foreseen.

The first phase is the MVP phase where the focus is on creating an MVP version of the Node software, an in-house Pub/Sub server (the Satori Server) as well as integration with a distributed Pub/Sub solution (Streamr), and rudimentary use of a blockchain for incentivization purposes only (Ravencoin). By the end of this phase, people will be able to download and run the fully automatic Node software and earn tokens at a standard rate for providing Satori's public good offering.

The second phase is devoted to building out the blockchain with the prediction market platform, allowing buyers and sellers of data and predictions to transact. That is, phase two is about commercializing and commoditizing this new form of computational labor which specializes in prediction. This prediction market platform can be fully decentralized from the beginning of its development, unlike the public good offering which needs some centralizing policing to keep out bad actors.

The third phase of development is meant to circle back to the public good offering, and using the blockchain built in phase two, establishes as much decentralized control and coordination as possible to provide the public good offering. That is to say, the third phase is devoted to removing the training wheels of phase one (mainly parts of the Satori Server) and making Satori a fully legitimized distributed autonomous organization.

### Summary

In summary, Satori is a network of computing nodes, all constantly building better models to predict the future of specific data streams. All communication within the network is either a raw data stream or a prediction data stream. Anyone can subscribe to any data stream, giving the public at large the ability to know what the Satori network is predicting at any moment.
